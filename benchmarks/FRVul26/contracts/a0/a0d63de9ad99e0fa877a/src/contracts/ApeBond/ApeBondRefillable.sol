// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

/*
  ______                       _______                             __ 
 /      \                     |       \                           |  \
|  ▓▓▓▓▓▓\  ______    ______  | ▓▓▓▓▓▓▓\  ______   _______    ____| ▓▓
| ▓▓__| ▓▓ /      \  /      \ | ▓▓__/ ▓▓ /      \ |       \  /      ▓▓
| ▓▓    ▓▓|  ▓▓▓▓▓▓\|  ▓▓▓▓▓▓\| ▓▓    ▓▓|  ▓▓▓▓▓▓\| ▓▓▓▓▓▓▓\|  ▓▓▓▓▓▓▓
| ▓▓▓▓▓▓▓▓| ▓▓  | ▓▓| ▓▓    ▓▓| ▓▓▓▓▓▓▓\| ▓▓  | ▓▓| ▓▓  | ▓▓| ▓▓  | ▓▓
| ▓▓  | ▓▓| ▓▓__/ ▓▓| ▓▓▓▓▓▓▓▓| ▓▓__/ ▓▓| ▓▓__/ ▓▓| ▓▓  | ▓▓| ▓▓__| ▓▓
| ▓▓  | ▓▓| ▓▓    ▓▓ \▓▓     \| ▓▓    ▓▓ \▓▓    ▓▓| ▓▓  | ▓▓ \▓▓    ▓▓
 \▓▓   \▓▓| ▓▓▓▓▓▓▓   \▓▓▓▓▓▓▓ \▓▓▓▓▓▓▓   \▓▓▓▓▓▓  \▓▓   \▓▓  \▓▓▓▓▓▓▓
          | ▓▓                                                        
          | ▓▓                                                        
           \▓▓                                                         
 * App:             https://Ape.Bond
 * Medium:          https://ApeBond.medium.com
 * Twitter:         https://twitter.com/ApeBond
 * Telegram:        https://t.me/ape_bond
 * Announcements:   https://t.me/ApeBond_news
 * Discord:         https://ApeBond.click/discord
 * Reddit:          https://ApeBond.click/reddit
 * Instagram:       https://instagram.com/ape.bond
 * GitHub:          https://github.com/ApeSwapFinance
 */

import "./IApeBondRefillable.sol";
import "./ApeBond.sol";

/// @title ApeBondRefillable
/// @author ApeSwap.Finance
/// @notice Provides a method of refilling ApeBond contracts without needing owner rights
/// @dev Extends ApeBond
contract ApeBondRefillable is IApeBondRefillable, ApeBond {
    using SafeERC20Upgradeable for IERC20MetadataUpgradeable;

    event BillRefilled(address payoutToken, uint256 amountAdded);

    /**
     *  @notice Transfer payoutTokens from sender to customTreasury and update maxTotalPayout
     *  @param _refillAmount amount of payoutTokens to refill the ApeBond with
     */
    function refillPayoutToken(uint256 _refillAmount) external override nonReentrant onlyRole(OPERATIONS_ROLE) {
        require(_refillAmount > 0, "Amount is 0");
        require(customTreasury.billContract(address(this)), "Bill is disabled");
        uint256 balanceBefore = payoutToken.balanceOf(address(customTreasury));
        payoutToken.safeTransferFrom(msg.sender, address(customTreasury), _refillAmount);
        uint256 refillAmount = payoutToken.balanceOf(address(customTreasury)) - balanceBefore;
        require(refillAmount > 0, "No refill made");
        uint256 maxTotalPayout = terms.maxTotalPayout + refillAmount;
        terms.maxTotalPayout = maxTotalPayout;
        emit BillRefilled(address(payoutToken), refillAmount);
        emit MaxTotalPayoutChanged(maxTotalPayout);
    }
}
