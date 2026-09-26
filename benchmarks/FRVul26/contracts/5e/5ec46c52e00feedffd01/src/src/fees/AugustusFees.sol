// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

// Interfaces
import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";
import { IAugustusFeeVault } from "../interfaces/IAugustusFeeVault.sol";
import { IAugustusFees } from "../interfaces/IAugustusFees.sol";

// Libraries
import { ERC20Utils } from "../libraries/ERC20Utils.sol";

// Storage
import { AugustusStorage } from "../storage/AugustusStorage.sol";

/// @title AugustusFees
/// @notice Contract for handling fees
contract AugustusFees is AugustusStorage, IAugustusFees {
    /*//////////////////////////////////////////////////////////////
                               LIBRARIES
    //////////////////////////////////////////////////////////////*/

    using ERC20Utils for IERC20;

    /*//////////////////////////////////////////////////////////////
                               CONSTANTS
    //////////////////////////////////////////////////////////////*/

    /// @dev Fee share constants
    uint256 public constant PARTNER_SHARE_PERCENT = 8500;
    uint256 public constant MAX_FEE_PERCENT = 200;
    uint256 public constant SURPLUS_PERCENT = 100;
    uint256 public constant PARASWAP_REFERRAL_SHARE = 5000;
    uint256 public constant PARTNER_REFERRAL_SHARE = 2500;
    uint256 public constant PARASWAP_SURPLUS_SHARE = 5000;
    uint256 public constant PARASWAP_SLIPPAGE_SHARE = 10_000;
    uint256 public constant MINIMUM_SURPLUS_EPSILON_AND_ONE_WEI = 11;

    /// @dev Masks for unpacking feeData
    uint256 private constant FEE_PERCENT_IN_BASIS_POINTS_MASK = 0x3FFF;
    uint256 private constant IS_USER_SURPLUS_MASK = 1 << 90;
    uint256 private constant IS_DIRECT_TRANSFER_MASK = 1 << 91;
    uint256 private constant IS_CAP_SURPLUS_MASK = 1 << 92;
    uint256 private constant IS_SKIP_BLACKLIST_MASK = 1 << 93;
    uint256 private constant IS_REFERRAL_MASK = 1 << 94;
    uint256 private constant IS_TAKE_SURPLUS_MASK = 1 << 95;

    /// @dev A contact that stores fees collected by the protocol
    IAugustusFeeVault public immutable FEE_VAULT; // solhint-disable-line var-name-mixedcase

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _feeVault) {
        FEE_VAULT = IAugustusFeeVault(_feeVault);
    }

    /*//////////////////////////////////////////////////////////////
                       SWAP EXACT AMOUNT IN FEES
    //////////////////////////////////////////////////////////////*/

    /// @notice Process swapExactAmountIn fees and transfer the received amount to the beneficiary
    /// @param destToken The received token from the swapExactAmountIn
    /// @param partnerAndFee Packed partner and fee data
    /// @param receivedAmount The amount of destToken received from the swapExactAmountIn
    /// @param quotedAmount The quoted expected amount of destToken
    /// @return returnAmount The amount of destToken transfered to the beneficiary
    /// @return paraswapFeeShare The share of the fees for Paraswap
    /// @return partnerFeeShare The share of the fees for the partner
    function processSwapExactAmountInFeesAndTransfer(
        address beneficiary,
        IERC20 destToken,
        uint256 partnerAndFee,
        uint256 receivedAmount,
        uint256 quotedAmount
    )
        internal
        returns (uint256 returnAmount, uint256 paraswapFeeShare, uint256 partnerFeeShare)
    {
        // initialize the surplus
        uint256 surplus;

        // parse partner and fee data
        (address payable partner, uint256 feeData) = parsePartnerAndFeeData(partnerAndFee);

        // calculate the surplus, we expect there to be 1 wei dust left which we should
        // not take into account when determining if there is surplus, we only take the
        // surplus if it is greater than MINIMUM_SURPLUS_EPSILON_AND_ONE_WEI
        if (receivedAmount > quotedAmount + MINIMUM_SURPLUS_EPSILON_AND_ONE_WEI) {
            surplus = receivedAmount - quotedAmount;
            // if the cap surplus flag is passed, we cap the surplus to 1% of the quoted amount
            if (feeData & IS_CAP_SURPLUS_MASK != 0) {
                uint256 cappedSurplus = (SURPLUS_PERCENT * quotedAmount) / 10_000;
                surplus = surplus > cappedSurplus ? cappedSurplus : surplus;
            }
        }

        // calculate remainingAmount
        uint256 remainingAmount = receivedAmount - surplus;

        // if partner address is not 0x0
        if (partner != address(0x0)) {
            // Check if skip blacklist flag is true
            bool skipBlacklist = feeData & IS_SKIP_BLACKLIST_MASK != 0;
            // Check if token is blacklisted
            bool isBlacklisted = blacklistedTokens[destToken];
            // If the token is blacklisted and the skipBlacklist flag is false,
            // send the received amount to the beneficiary, we won't process fees
            if (!skipBlacklist && isBlacklisted) {
                // transfer the received amount to the beneficiary, keeping 1 wei dust
                _transferAndLeaveDust(destToken, beneficiary, receivedAmount);
                return (receivedAmount - 1, 0, 0);
            }
            // Check if direct transfer flag is true
            bool isDirectTransfer = feeData & IS_DIRECT_TRANSFER_MASK != 0;
            // partner takes fixed fees feePercent is greater than 0
            uint256 feePercent = _getAdjustedFeePercent(feeData);
            if (feePercent > 0) {
                // fee base = min (receivedAmount, quotedAmount + surplus)
                uint256 feeBase = receivedAmount > quotedAmount + surplus ? quotedAmount + surplus : receivedAmount;
                // calculate fixed fees
                uint256 fee = (feeBase * feePercent) / 10_000;
                partnerFeeShare = (fee * PARTNER_SHARE_PERCENT) / 10_000;
                paraswapFeeShare = fee - partnerFeeShare;
                // distrubite fees from destToken
                returnAmount = _distributeFees(
                    receivedAmount,
                    destToken,
                    partner,
                    partnerFeeShare,
                    paraswapFeeShare,
                    skipBlacklist,
                    isBlacklisted,
                    isDirectTransfer
                );
                // transfer the return amount to the beneficiary, keeping 1 wei dust
                _transferAndLeaveDust(destToken, beneficiary, returnAmount);
                return (returnAmount - 1, paraswapFeeShare, partnerFeeShare);
            }
            // if slippage is postive and referral flag is true
            else if (feeData & IS_REFERRAL_MASK != 0) {
                if (surplus > 0) {
                    // the split is 50% for paraswap, 25% for the referrer and 25% for the user
                    paraswapFeeShare = (surplus * PARASWAP_REFERRAL_SHARE) / 10_000;
                    partnerFeeShare = (surplus * PARTNER_REFERRAL_SHARE) / 10_000;
                    // distribute fees from destToken
                    returnAmount = _distributeFees(
                        receivedAmount,
                        destToken,
                        partner,
                        partnerFeeShare,
                        paraswapFeeShare,
                        skipBlacklist,
                        isBlacklisted,
                        isDirectTransfer
                    );
                    // transfer the return amount to the beneficiary, keeping 1 wei dust
                    _transferAndLeaveDust(destToken, beneficiary, returnAmount);
                    return (returnAmount - 1, paraswapFeeShare, partnerFeeShare);
                }
            }
            // if slippage is positive and takeSurplus flag is true
            else if (feeData & IS_TAKE_SURPLUS_MASK != 0) {
                if (surplus > 0) {
                    // paraswap takes 50% of the surplus and partner takes the other 50%
                    paraswapFeeShare = (surplus * PARASWAP_SURPLUS_SHARE) / 10_000;
                    partnerFeeShare = surplus - paraswapFeeShare;
                    // If user surplus flag is true, transfer the partner share to the user instead of the partner
                    if (feeData & IS_USER_SURPLUS_MASK != 0) {
                        partnerFeeShare = 0;
                        // Transfer the paraswap share directly to the fee wallet
                        isDirectTransfer = true;
                    }
                    // distrubite fees from destToken, partner takes 50% of the surplus
                    // and paraswap takes the other 50%
                    returnAmount = _distributeFees(
                        receivedAmount,
                        destToken,
                        partner,
                        partnerFeeShare,
                        paraswapFeeShare,
                        skipBlacklist,
                        isBlacklisted,
                        isDirectTransfer
                    );
                    // transfer the return amount to the beneficiary, keeping 1 wei dust
                    _transferAndLeaveDust(destToken, beneficiary, returnAmount);
                    return (returnAmount - 1, paraswapFeeShare, partnerFeeShare);
                }
            }
        }

        // if slippage is positive and partner address is 0x0 or fee percent is 0
        // paraswap will take the surplus and transfer the rest to the beneficiary
        // if there is no positive slippage, transfer the received amount to the beneficiary
        if (surplus > 0) {
            // If the token is blacklisted, send the received amount to the beneficiary
            // we won't process fees
            if (blacklistedTokens[destToken]) {
                // transfer the received amount to the beneficiary, keeping 1 wei dust
                _transferAndLeaveDust(destToken, beneficiary, receivedAmount);
                return (receivedAmount - 1, 0, 0);
            }
            // transfer the remaining amount to the beneficiary, keeping 1 wei dust
            _transferAndLeaveDust(destToken, beneficiary, remainingAmount);
            // transfer the surplus to the fee wallet
            destToken.safeTransfer(feeWallet, surplus);
            return (remainingAmount - 1, surplus, 0);
        } else {
            // transfer the received amount to the beneficiary, keeping 1 wei dust
            _transferAndLeaveDust(destToken, beneficiary, receivedAmount);
            return (receivedAmount - 1, 0, 0);
        }
    }

    /// @notice Process swapExactAmountIn fees and transfer the received amount to the beneficiary
    /// @param destToken The received token from the swapExactAmountIn
    /// @param partnerAndFee Packed partner and fee data
    /// @param receivedAmount The amount of destToken received from the swapExactAmountIn
    /// @param quotedAmount The quoted expected amount of destToken
    /// @return returnAmount The amount of destToken transfered to the beneficiary
    /// @return paraswapFeeShare The share of the fees for Paraswap
    /// @return partnerFeeShare The share of the fees for the partner
    function processSwapExactAmountInFeesAndTransferUniV3(
        address beneficiary,
        IERC20 destToken,
        uint256 partnerAndFee,
        uint256 receivedAmount,
        uint256 quotedAmount
    )
        internal
        returns (uint256 returnAmount, uint256 paraswapFeeShare, uint256 partnerFeeShare)
    {
        // initialize the surplus
        uint256 surplus;

        // parse partner and fee data
        (address payable partner, uint256 feeData) = parsePartnerAndFeeData(partnerAndFee);

        // calculate the surplus, we do not take the surplus into account if it is less than
        // MINIMUM_SURPLUS_EPSILON_AND_ONE_WEI
        if (receivedAmount > quotedAmount + MINIMUM_SURPLUS_EPSILON_AND_ONE_WEI) {
            surplus = receivedAmount - quotedAmount;
            // if the cap surplus flag is passed, we cap the surplus to 1% of the quoted amount
            if (feeData & IS_CAP_SURPLUS_MASK != 0) {
                uint256 cappedSurplus = (SURPLUS_PERCENT * quotedAmount) / 10_000;
                surplus = surplus > cappedSurplus ? cappedSurplus : surplus;
            }
        }

        // calculate remainingAmount
        uint256 remainingAmount = receivedAmount - surplus;

        // if partner address is not 0x0
        if (partner != address(0x0)) {
            // Check if skip blacklist flag is true
            bool skipBlacklist = feeData & IS_SKIP_BLACKLIST_MASK != 0;
            // Check if token is blacklisted
            bool isBlacklisted = blacklistedTokens[destToken];
            // If the token is blacklisted and the skipBlacklist flag is false,
            // send the received amount to the beneficiary, we won't process fees
            if (!skipBlacklist && isBlacklisted) {
                // transfer the received amount to the beneficiary
                destToken.safeTransfer(beneficiary, receivedAmount);
                return (receivedAmount, 0, 0);
            }
            // Check if direct transfer flag is true
            bool isDirectTransfer = feeData & IS_DIRECT_TRANSFER_MASK != 0;
            // partner takes fixed fees feePercent is greater than 0
            uint256 feePercent = _getAdjustedFeePercent(feeData);
            if (feePercent > 0) {
                // fee base = min (receivedAmount, quotedAmount + surplus)
                uint256 feeBase = receivedAmount > quotedAmount + surplus ? quotedAmount + surplus : receivedAmount;
                // calculate fixed fees
                uint256 fee = (feeBase * feePercent) / 10_000;
                partnerFeeShare = (fee * PARTNER_SHARE_PERCENT) / 10_000;
                paraswapFeeShare = fee - partnerFeeShare;
                // distrubite fees from destToken
                returnAmount = _distributeFees(
                    receivedAmount,
                    destToken,
                    partner,
                    partnerFeeShare,
                    paraswapFeeShare,
                    skipBlacklist,
                    isBlacklisted,
                    isDirectTransfer
                );
                // transfer the return amount to the beneficiary
                destToken.safeTransfer(beneficiary, returnAmount);
                return (returnAmount, paraswapFeeShare, partnerFeeShare);
            }
            // if slippage is postive and referral flag is true
            else if (feeData & IS_REFERRAL_MASK != 0) {
                if (surplus > 0) {
                    // the split is 50% for paraswap, 25% for the referrer and 25% for the user
                    paraswapFeeShare = (surplus * PARASWAP_REFERRAL_SHARE) / 10_000;
                    partnerFeeShare = (surplus * PARTNER_REFERRAL_SHARE) / 10_000;
                    // distribute fees from destToken
                    returnAmount = _distributeFees(
                        receivedAmount,
                        destToken,
                        partner,
                        partnerFeeShare,
                        paraswapFeeShare,
                        skipBlacklist,
                        isBlacklisted,
                        isDirectTransfer
                    );
                    // transfer the return amount to the beneficiary
                    destToken.safeTransfer(beneficiary, returnAmount);
                    return (returnAmount, paraswapFeeShare, partnerFeeShare);
                }
            }
            // if slippage is positive and takeSurplus flag is true
            else if (feeData & IS_TAKE_SURPLUS_MASK != 0) {
                if (surplus > 0) {
                    // paraswap takes 50% of the surplus and partner takes the other 50%
                    paraswapFeeShare = (surplus * PARASWAP_SURPLUS_SHARE) / 10_000;
                    partnerFeeShare = surplus - paraswapFeeShare;
                    // If user surplus flag is true, transfer the partner share to the user instead of the partner
                    if (feeData & IS_USER_SURPLUS_MASK != 0) {
                        partnerFeeShare = 0;
                        // Transfer the paraswap share directly to the fee wallet
                        isDirectTransfer = true;
                    }
                    // distrubite fees from destToken, partner takes 50% of the surplus
                    // and paraswap takes the other 50%
                    returnAmount = _distributeFees(
                        receivedAmount,
                        destToken,
                        partner,
                        partnerFeeShare,
                        paraswapFeeShare,
                        skipBlacklist,
                        isBlacklisted,
                        isDirectTransfer
                    );
                    // transfer the return amount to the beneficiary,
                    destToken.safeTransfer(beneficiary, returnAmount);
                    return (returnAmount, paraswapFeeShare, partnerFeeShare);
                }
            }
        }

        // if slippage is positive and partner address is 0x0 or fee percent is 0
        // paraswap will take the surplus and transfer the rest to the beneficiary
        // if there is no positive slippage, transfer the received amount to the beneficiary
        if (surplus > 0) {
            // If the token is blacklisted, send the received amount to the beneficiary
            // we won't process fees
            if (blacklistedTokens[destToken]) {
                // transfer the received amount to the beneficiary
                destToken.safeTransfer(beneficiary, receivedAmount);
                return (receivedAmount, 0, 0);
            }
            // transfer the remaining amount to the beneficiary
            destToken.safeTransfer(beneficiary, remainingAmount);
            // transfer the surplus to the fee wallet
            destToken.safeTransfer(feeWallet, surplus);
            return (remainingAmount, surplus, 0);
        } else {
            // transfer the received amount to the beneficiary
            destToken.safeTransfer(beneficiary, receivedAmount);
            return (receivedAmount, 0, 0);
        }
    }

    /*//////////////////////////////////////////////////////////////
                       SWAP EXACT AMOUNT OUT FEES
    //////////////////////////////////////////////////////////////*/

    /// @notice Process swapExactAmountOut fees and transfer the received amount and remaining amount to the
    /// beneficiary
    /// @param srcToken The token used to swapExactAmountOut
    /// @param destToken The token received from the swapExactAmountOut
    /// @param partnerAndFee Packed partner and fee data
    /// @param maxAmountIn The amount of srcToken passed to the swapExactAmountOut
    /// @param receivedAmount The amount of destToken received from the swapExactAmountOut
    /// @param quotedAmount The quoted expected amount of srcToken to be used to swapExactAmountOut
    /// @return spentAmount The amount of srcToken used to swapExactAmountOut
    /// @return outAmount The amount of destToken transfered to the beneficiary
    /// @return paraswapFeeShare The share of the fees for Paraswap
    /// @return partnerFeeShare The share of the fees for the partner
    function processSwapExactAmountOutFeesAndTransfer(
        address beneficiary,
        IERC20 srcToken,
        IERC20 destToken,
        uint256 partnerAndFee,
        uint256 maxAmountIn,
        uint256 remainingAmount,
        uint256 receivedAmount,
        uint256 quotedAmount
    )
        internal
        returns (uint256 spentAmount, uint256 outAmount, uint256 paraswapFeeShare, uint256 partnerFeeShare)
    {
        // calculate the amount used to swapExactAmountOut
        spentAmount = maxAmountIn - (remainingAmount > 0 ? remainingAmount - 1 : remainingAmount);

        // initialize the surplus
        uint256 surplus;

        // initialize the return amount
        uint256 returnAmount;

        // parse partner and fee data
        (address payable partner, uint256 feeData) = parsePartnerAndFeeData(partnerAndFee);

        // check if the quotedAmount is bigger than the maxAmountIn
        if (quotedAmount > maxAmountIn) {
            revert InvalidQuotedAmount();
        }

        // calculate the surplus, we do not take the surplus into account if it is less than
        // MINIMUM_SURPLUS_EPSILON_AND_ONE_WEI
        if (quotedAmount > spentAmount + MINIMUM_SURPLUS_EPSILON_AND_ONE_WEI) {
            surplus = quotedAmount - spentAmount;
            // if the cap surplus flag is passed, we cap the surplus to 1% of the quoted amount
            if (feeData & IS_CAP_SURPLUS_MASK != 0) {
                uint256 cappedSurplus = (SURPLUS_PERCENT * quotedAmount) / 10_000;
                surplus = surplus > cappedSurplus ? cappedSurplus : surplus;
            }
        }

        // if partner address is not 0x0
        if (partner != address(0x0)) {
            // Check if skip blacklist flag is true
            bool skipBlacklist = feeData & IS_SKIP_BLACKLIST_MASK != 0;
            // Check if token is blacklisted
            bool isBlacklisted = blacklistedTokens[srcToken];
            // If the token is blacklisted and the skipBlacklist flag is false,
            // send the remaining amount to the msg.sender, we won't process fees
            if (!skipBlacklist && isBlacklisted) {
                // transfer the remaining amount to msg.sender
                returnAmount = _transferIfGreaterThanOne(srcToken, msg.sender, remainingAmount);
                // transfer the received amount of destToken to the beneficiary
                destToken.safeTransfer(beneficiary, --receivedAmount);
                return (maxAmountIn - returnAmount, receivedAmount, 0, 0);
            }
            // Check if direct transfer flag is true
            bool isDirectTransfer = feeData & IS_DIRECT_TRANSFER_MASK != 0;
            // partner takes fixed fees feePercent is greater than 0
            uint256 feePercent = _getAdjustedFeePercent(feeData);
            if (feePercent > 0) {
                // fee base = min (spentAmount, quotedAmount)
                uint256 feeBase = spentAmount < quotedAmount ? spentAmount : quotedAmount;
                // calculate fixed fees
                uint256 fee = (feeBase * feePercent) / 10_000;
                partnerFeeShare = (fee * PARTNER_SHARE_PERCENT) / 10_000;
                paraswapFeeShare = fee - partnerFeeShare;
                // distrubite fees from srcToken
                returnAmount = _distributeFees(
                    remainingAmount,
                    srcToken,
                    partner,
                    partnerFeeShare,
                    paraswapFeeShare,
                    skipBlacklist,
                    isBlacklisted,
                    isDirectTransfer
                );
                // transfer the rest to msg.sender
                returnAmount = _transferIfGreaterThanOne(srcToken, msg.sender, returnAmount);
                // transfer the received amount of destToken to the beneficiary
                destToken.safeTransfer(beneficiary, --receivedAmount);
                return (maxAmountIn - returnAmount, receivedAmount, paraswapFeeShare, partnerFeeShare);
            }
            // if slippage is postive and referral flag is true
            if (feeData & IS_REFERRAL_MASK != 0) {
                if (surplus > 0) {
                    // the split is 50% for paraswap, 25% for the referrer and 25% for the user
                    paraswapFeeShare = (surplus * PARASWAP_REFERRAL_SHARE) / 10_000;
                    partnerFeeShare = (surplus * PARTNER_REFERRAL_SHARE) / 10_000;
                    // distribute fees from srcToken
                    returnAmount = _distributeFees(
                        remainingAmount,
                        srcToken,
                        partner,
                        partnerFeeShare,
                        paraswapFeeShare,
                        skipBlacklist,
                        isBlacklisted,
                        isDirectTransfer
                    );
                    // transfer the rest to msg.sender
                    returnAmount = _transferIfGreaterThanOne(srcToken, msg.sender, returnAmount);
                    // transfer the received amount of destToken to the beneficiary
                    destToken.safeTransfer(beneficiary, --receivedAmount);
                    return (maxAmountIn - returnAmount, receivedAmount, paraswapFeeShare, partnerFeeShare);
                }
            }
            // if slippage is positive and takeSurplus flag is true
            else if (feeData & IS_TAKE_SURPLUS_MASK != 0) {
                if (surplus > 0) {
                    // paraswap takes 50% of the surplus and partner takes the other 50%
                    paraswapFeeShare = (surplus * PARASWAP_SURPLUS_SHARE) / 10_000;
                    partnerFeeShare = surplus - paraswapFeeShare;
                    // If user surplus flag is true, transfer the partner share to the user instead of the partner
                    if (feeData & IS_USER_SURPLUS_MASK != 0) {
                        partnerFeeShare = 0;
                        // Transfer the paraswap share directly to the fee wallet
                        isDirectTransfer = true;
                    }
                    // distrubite fees from srcToken, partner takes 50% of the surplus
                    // and paraswap takes the other 50%
                    returnAmount = _distributeFees(
                        remainingAmount,
                        srcToken,
                        partner,
                        partnerFeeShare,
                        paraswapFeeShare,
                        skipBlacklist,
                        isBlacklisted,
                        isDirectTransfer
                    );
                    // transfer the rest to msg.sender
                    returnAmount = _transferIfGreaterThanOne(srcToken, msg.sender, returnAmount);
                    // transfer the received amount of destToken to the beneficiary
                    destToken.safeTransfer(beneficiary, --receivedAmount);
                    return (maxAmountIn - returnAmount, receivedAmount, paraswapFeeShare, partnerFeeShare);
                }
            }
        }

        // transfer the received amount of destToken to the beneficiary
        destToken.safeTransfer(beneficiary, --receivedAmount);

        // if slippage is positive and partner address is 0x0 or fee percent is 0
        // paraswap will take the surplus, and transfer the rest to msg.sender
        // if there is no positive slippage, transfer the remaining amount to msg.sender
        if (surplus > 0) {
            // If the token is blacklisted, send the remaining amount to the msg.sender
            // we won't process fees
            if (blacklistedTokens[srcToken]) {
                // transfer the remaining amount to msg.sender
                returnAmount = _transferIfGreaterThanOne(srcToken, msg.sender, remainingAmount);
                return (maxAmountIn - returnAmount, receivedAmount, 0, 0);
            }
            // transfer the surplus to the fee wallet
            srcToken.safeTransfer(feeWallet, surplus);
            // transfer the remaining amount to msg.sender
            returnAmount = _transferIfGreaterThanOne(srcToken, msg.sender, remainingAmount - surplus);
            return (maxAmountIn - returnAmount, receivedAmount, surplus, 0);
        } else {
            // transfer the remaining amount to msg.sender
            returnAmount = _transferIfGreaterThanOne(srcToken, msg.sender, remainingAmount);
            return (maxAmountIn - returnAmount, receivedAmount, 0, 0);
        }
    }

    /// @notice Process swapExactAmountOut fees for UniV3 swapExactAmountOut, doing a transferFrom user to the fee
    /// vault or partner and feeWallet
    /// @param beneficiary The user's address
    /// @param srcToken The token used to swapExactAmountOut
    /// @param destToken The token received from the swapExactAmountOut
    /// @param partnerAndFee Packed partner and fee data
    /// @param maxAmountIn The amount of srcToken passed to the swapExactAmountOut
    /// @param receivedAmount The amount of destToken received from the swapExactAmountOut
    /// @param spentAmount The amount of srcToken used to swapExactAmountOut
    /// @param quotedAmount The quoted expected amount of srcToken to be used to swapExactAmountOut
    /// @return totalSpentAmount The total amount of srcToken used to swapExactAmountOut
    /// @return returnAmount The amount of destToken transfered to the beneficiary
    /// @return paraswapFeeShare The share of the fees for Paraswap
    /// @return partnerFeeShare The share of the fees for the partner
    function processSwapExactAmountOutFeesAndTransferUniV3(
        address beneficiary,
        IERC20 srcToken,
        IERC20 destToken,
        uint256 partnerAndFee,
        uint256 maxAmountIn,
        uint256 receivedAmount,
        uint256 spentAmount,
        uint256 quotedAmount
    )
        internal
        returns (uint256 totalSpentAmount, uint256 returnAmount, uint256 paraswapFeeShare, uint256 partnerFeeShare)
    {
        // initialize the surplus
        uint256 surplus;

        // calculate remaining amount
        uint256 remainingAmount = maxAmountIn - spentAmount;

        // parse partner and fee data
        (address payable partner, uint256 feeData) = parsePartnerAndFeeData(partnerAndFee);

        // check if the quotedAmount is bigger than the fromAmount
        if (quotedAmount > maxAmountIn) {
            revert InvalidQuotedAmount();
        }

        // calculate the surplus, we do not take the surplus into account if it is less than
        // MINIMUM_SURPLUS_EPSILON_AND_ONE_WEI
        if (quotedAmount > spentAmount + MINIMUM_SURPLUS_EPSILON_AND_ONE_WEI) {
            surplus = quotedAmount - spentAmount;
            // if the cap surplus flag is passed, we cap the surplus to 1% of the quoted amount
            if (feeData & IS_CAP_SURPLUS_MASK != 0) {
                uint256 cappedSurplus = (SURPLUS_PERCENT * quotedAmount) / 10_000;
                surplus = surplus > cappedSurplus ? cappedSurplus : surplus;
            }
        }

        // if partner address is not 0x0
        if (partner != address(0x0)) {
            // Check if skip blacklist flag is true
            bool skipBlacklist = feeData & IS_SKIP_BLACKLIST_MASK != 0;
            // Check if token is blacklisted
            bool isBlacklisted = blacklistedTokens[srcToken];
            // If the token is blacklisted and the skipBlacklist flag is false,
            // we won't process fees
            if (!skipBlacklist && isBlacklisted) {
                // transfer the received amount of destToken to the beneficiary
                destToken.safeTransfer(beneficiary, receivedAmount);
                return (spentAmount, receivedAmount, 0, 0);
            }
            // Check if direct transfer flag is true
            bool isDirectTransfer = feeData & IS_DIRECT_TRANSFER_MASK != 0;
            // partner takes fixed fees feePercent is greater than 0
            uint256 feePercent = _getAdjustedFeePercent(feeData);
            if (feePercent > 0) {
                // fee base = min (spentAmount, quotedAmount)
                uint256 feeBase = spentAmount < quotedAmount ? spentAmount : quotedAmount;
                // calculate fixed fees
                uint256 fee = (feeBase * feePercent) / 10_000;
                partnerFeeShare = (fee * PARTNER_SHARE_PERCENT) / 10_000;
                paraswapFeeShare = fee - partnerFeeShare;
                // distrubite fees from srcToken
                totalSpentAmount = _distributeFeesUniV3(
                    remainingAmount,
                    msg.sender,
                    srcToken,
                    partner,
                    partnerFeeShare,
                    paraswapFeeShare,
                    skipBlacklist,
                    isBlacklisted,
                    isDirectTransfer
                ) + spentAmount;
                // transfer the received amount of destToken to the beneficiary
                destToken.safeTransfer(beneficiary, receivedAmount);
                return (totalSpentAmount, receivedAmount, paraswapFeeShare, partnerFeeShare);
            }
            // if slippage is postive and referral flag is true
            else if (feeData & IS_REFERRAL_MASK != 0) {
                if (surplus > 0) {
                    // the split is 50% for paraswap, 25% for the referrer and 25% for the user
                    paraswapFeeShare = (surplus * PARASWAP_REFERRAL_SHARE) / 10_000;
                    partnerFeeShare = (surplus * PARTNER_REFERRAL_SHARE) / 10_000;
                    // distribute fees from srcToken
                    totalSpentAmount = _distributeFeesUniV3(
                        remainingAmount,
                        msg.sender,
                        srcToken,
                        partner,
                        partnerFeeShare,
                        paraswapFeeShare,
                        skipBlacklist,
                        isBlacklisted,
                        isDirectTransfer
                    ) + spentAmount;
                    // transfer the received amount of destToken to the beneficiary
                    destToken.safeTransfer(beneficiary, receivedAmount);
                    return (totalSpentAmount, receivedAmount, paraswapFeeShare, partnerFeeShare);
                }
            }
            // if slippage is positive and takeSurplus flag is true
            else if (feeData & IS_TAKE_SURPLUS_MASK != 0) {
                if (surplus > 0) {
                    // paraswap takes 50% of the surplus and partner takes the other 50%
                    paraswapFeeShare = (surplus * PARASWAP_SURPLUS_SHARE) / 10_000;
                    partnerFeeShare = surplus - paraswapFeeShare;
                    // If user surplus flag is true, transfer the partner share to the user instead of the partner
                    if (feeData & IS_USER_SURPLUS_MASK != 0) {
                        partnerFeeShare = 0;
                        // Transfer the paraswap share directly to the fee wallet
                        isDirectTransfer = true;
                    }
                    //  partner takes 50% of the surplus and paraswap takes the other 50%
                    // distrubite fees from srcToken
                    totalSpentAmount = _distributeFeesUniV3(
                        remainingAmount,
                        msg.sender,
                        srcToken,
                        partner,
                        partnerFeeShare,
                        paraswapFeeShare,
                        skipBlacklist,
                        isBlacklisted,
                        isDirectTransfer
                    ) + spentAmount;
                    // transfer the received amount of destToken to the beneficiary
                    destToken.safeTransfer(beneficiary, receivedAmount);
                    return (totalSpentAmount, receivedAmount, paraswapFeeShare, partnerFeeShare);
                }
            }
        }

        // transfer the received amount of destToken to the beneficiary
        destToken.safeTransfer(beneficiary, receivedAmount);

        // if slippage is positive and partner address is 0x0 or fee percent is 0
        // paraswap will take the surplus
        if (surplus > 0) {
            // If the token is blacklisted, we won't process fees
            if (blacklistedTokens[srcToken]) {
                return (spentAmount, receivedAmount, 0, 0);
            }
            // transfer the surplus to the fee wallet
            srcToken.safeTransferFrom(msg.sender, feeWallet, surplus);
        }
        return (spentAmount + surplus, receivedAmount, surplus, 0);
    }

    /*//////////////////////////////////////////////////////////////
                                 PUBLIC
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IAugustusFees
    function parsePartnerAndFeeData(uint256 partnerAndFee)
        public
        pure
        returns (address payable partner, uint256 feeData)
    {
        // solhint-disable-next-line no-inline-assembly
        assembly ("memory-safe") {
            partner := shr(96, partnerAndFee)
            feeData := and(partnerAndFee, 0xFFFFFFFFFFFFFFFFFFFFFFFF)
        }
    }

    /*//////////////////////////////////////////////////////////////
                                PRIVATE
    //////////////////////////////////////////////////////////////*/

    /// @notice Distribute fees to the partner and paraswap
    /// @param currentBalance The current balance of the token before distributing the fees
    /// @param token The token to distribute the fees for
    /// @param partner The partner address
    /// @param partnerShare The partner share
    /// @param paraswapShare The paraswap share
    /// @param skipBlacklist Whether to skip the blacklist and transfer the fees directly to the partner
    /// @param isBlacklisted Whether the token is blacklisted
    /// @param directTransfer Whether to transfer the fees directly to the partner instead of the fee vault
    /// @return newBalance The new balance of the token after distributing the fees
    function _distributeFees(
        uint256 currentBalance,
        IERC20 token,
        address payable partner,
        uint256 partnerShare,
        uint256 paraswapShare,
        bool skipBlacklist,
        bool isBlacklisted,
        bool directTransfer
    )
        private
        returns (uint256 newBalance)
    {
        uint256 totalFees = partnerShare + paraswapShare;
        if (totalFees == 0) {
            return currentBalance;
        } else {
            if (skipBlacklist && isBlacklisted) {
                // totalFees should be just the partner share, paraswap does not take fees
                // on blacklisted tokens, the rest of the fees are sent to sender based on
                // newBalance = currentBalance - totalFees
                totalFees = partnerShare;
                // revert if the balance is not enough to pay the fees
                if (totalFees > currentBalance) {
                    revert InsufficientBalanceToPayFees();
                }
                if (partnerShare > 0) {
                    token.safeTransfer(partner, partnerShare);
                }
            } else {
                // revert if the balance is not enough to pay the fees
                if (totalFees > currentBalance) {
                    revert InsufficientBalanceToPayFees();
                }
                if (directTransfer) {
                    // transfer the fees directly to the partner and paraswap
                    if (paraswapShare > 0) {
                        token.safeTransfer(feeWallet, paraswapShare);
                    }
                    if (partnerShare > 0) {
                        token.safeTransfer(partner, partnerShare);
                    }
                } else {
                    // transfer the fees to the fee vault
                    token.safeTransfer(address(FEE_VAULT), totalFees);
                    // Setup fee registration data
                    address[] memory feeAddresses = new address[](2);
                    uint256[] memory feeAmounts = new uint256[](2);
                    feeAddresses[0] = partner;
                    feeAmounts[0] = partnerShare;
                    feeAddresses[1] = feeWalletDelegate;
                    feeAmounts[1] = paraswapShare;
                    IAugustusFeeVault.FeeRegistration memory feeData =
                        IAugustusFeeVault.FeeRegistration({ token: token, addresses: feeAddresses, fees: feeAmounts });
                    // Register the fees
                    FEE_VAULT.registerFees(feeData);
                }
            }
        }
        newBalance = currentBalance - totalFees;
    }

    /// @notice Distribute fees for UniV3
    /// @param currentBalance The current balance of the token before distributing the fees
    /// @param payer The user's address
    /// @param token The token to distribute the fees for
    /// @param partner The partner address
    /// @param partnerShare The partner share
    /// @param paraswapShare The paraswap share
    /// @param skipBlacklist Whether to skip the blacklist and transfer the fees directly to the partner
    /// @param isBlacklisted Whether the token is blacklisted
    /// @param directTransfer Whether to transfer the fees directly to the partner instead of the fee vault
    /// @return totalFees The total fees distributed
    function _distributeFeesUniV3(
        uint256 currentBalance,
        address payer,
        IERC20 token,
        address payable partner,
        uint256 partnerShare,
        uint256 paraswapShare,
        bool skipBlacklist,
        bool isBlacklisted,
        bool directTransfer
    )
        private
        returns (uint256 totalFees)
    {
        totalFees = partnerShare + paraswapShare;
        if (totalFees != 0) {
            if (skipBlacklist && isBlacklisted) {
                // totalFees should be just the partner share, paraswap does not take fees
                // on blacklisted tokens, the rest of the fees will remain on the payer's address
                totalFees = partnerShare;
                // revert if the balance is not enough to pay the fees
                if (totalFees > currentBalance) {
                    revert InsufficientBalanceToPayFees();
                }
                // transfer the fees to the partner
                if (partnerShare > 0) {
                    // transfer the fees to the partner
                    token.safeTransferFrom(payer, partner, partnerShare);
                }
            } else {
                // revert if the balance is not enough to pay the fees
                if (totalFees > currentBalance) {
                    revert InsufficientBalanceToPayFees();
                }
                if (directTransfer) {
                    // transfer the fees directly to the partner and paraswap
                    if (paraswapShare > 0) {
                        token.safeTransferFrom(payer, feeWallet, paraswapShare);
                    }
                    if (partnerShare > 0) {
                        token.safeTransferFrom(payer, partner, partnerShare);
                    }
                } else {
                    // transfer the fees to the fee vault
                    token.safeTransferFrom(payer, address(FEE_VAULT), totalFees);
                    // Setup fee registration data
                    address[] memory feeAddresses = new address[](2);
                    uint256[] memory feeAmounts = new uint256[](2);
                    feeAddresses[0] = partner;
                    feeAmounts[0] = partnerShare;
                    feeAddresses[1] = feeWalletDelegate;
                    feeAmounts[1] = paraswapShare;
                    IAugustusFeeVault.FeeRegistration memory feeData =
                        IAugustusFeeVault.FeeRegistration({ token: token, addresses: feeAddresses, fees: feeAmounts });
                    // Register the fees
                    FEE_VAULT.registerFees(feeData);
                }
            }
            // othwerwise do not transfer the fees
        }
        return totalFees;
    }

    /// @notice Get the adjusted fee percent by masking feePercent with FEE_PERCENT_IN_BASIS_POINTS_MASK,
    /// if the fee percent is bigger than MAX_FEE_PERCENT, then set it to MAX_FEE_PERCENT
    /// @param feePercent The fee percent
    /// @return adjustedFeePercent The adjusted fee percent
    function _getAdjustedFeePercent(uint256 feePercent) private pure returns (uint256) {
        // solhint-disable-next-line no-inline-assembly
        assembly ("memory-safe") {
            feePercent := and(feePercent, FEE_PERCENT_IN_BASIS_POINTS_MASK)
            // if feePercent is bigger than MAX_FEE_PERCENT, then set it to MAX_FEE_PERCENT
            if gt(feePercent, MAX_FEE_PERCENT) { feePercent := MAX_FEE_PERCENT }
        }
        return feePercent;
    }

    /// @notice Transfers amount to recipient if the amount is bigger than 1, leaving 1 wei dust on the contract
    /// @param token The token to transfer
    /// @param recipient The address to transfer to
    /// @param amount The amount to transfer
    function _transferIfGreaterThanOne(
        IERC20 token,
        address recipient,
        uint256 amount
    )
        private
        returns (uint256 amountOut)
    {
        if (amount > 1) {
            unchecked {
                --amount;
            }
            token.safeTransfer(recipient, amount);
            return amount;
        }
        return 0;
    }

    /// @notice Transfer amount to beneficiary, leaving 1 wei dust on the contract
    /// @param token The token to transfer
    /// @param beneficiary The address to transfer to
    /// @param amount The amount to transfer
    function _transferAndLeaveDust(IERC20 token, address beneficiary, uint256 amount) private {
        unchecked {
            --amount;
        }
        token.safeTransfer(beneficiary, amount);
    }
}
