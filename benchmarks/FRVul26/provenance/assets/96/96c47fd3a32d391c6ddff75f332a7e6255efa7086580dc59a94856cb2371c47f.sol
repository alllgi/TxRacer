// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IDeBridgeGate} from "./../interfaces/IDeBridgeGate.sol";
import {ERC20Utils} from "./../libraries/ERC20Utils.sol";
import {DownscaledToken} from "./DownscaledToken.sol";

contract DownscaledTokenFactory is Initializable, AccessControlUpgradeable {
    using ERC20Utils for IERC20;
    using ERC20Utils for DownscaledToken;

    IDeBridgeGate _deBridgeGate;

    // Mapping from original token address to deployed wrapped token address
    mapping(address => DownscaledToken) public wrappedTokens;
    mapping(DownscaledToken => address) public originalTokens;

    // Event to emit when a new WrappedToken is created
    event DownscaledTokenCreated(address token, address downscaledToken);

    error WrongArgument();
    error SupplyTooLarge();

    /* ========== INITIALIZERS ========== */

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(IDeBridgeGate deBridgeGate_) external initializer {
        _deBridgeGate = deBridgeGate_;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function deployDownscaledToken(
        address token_
    ) public returns (DownscaledToken) {
        // state checks
        if (!(token_ != address(0))) {
            revert WrongArgument();
        }
        // require(token_ != address(0), WrongArgument());
        if (!(wrappedTokens[token_] == DownscaledToken(address(0)))) {
            revert WrongArgument();
        }
        // require(wrappedTokens[token_] == DownscaledToken(address(0)), WrongArgument());

        // reasonable constraints check
        uint256 totalSupply = IERC20(token_).totalSupply();

        // scale check
        uint8 decimals = ERC20(token_).decimals();
        uint8 scaledDecimals = getMaxDecimals(totalSupply, decimals);
        if (!(scaledDecimals < decimals)) {
            revert WrongArgument();
        }
        // require(scaledDecimals < decimals, WrongArgument());

        // debridgeId is a salt
        bytes32 debridgeId = _deBridgeGate.getDebridgeId(
            _deBridgeGate.getChainId(),
            token_
        );

        // deployment code
        bytes memory bytecode = abi.encodePacked(
            type(DownscaledToken).creationCode,
            abi.encode(token_, scaledDecimals)
        );

        DownscaledToken wrappedToken;
        assembly {
            wrappedToken := create2(
                0,
                add(bytecode, 0x20),
                mload(bytecode),
                debridgeId
            )

            if iszero(extcodesize(wrappedToken)) {
                revert(0, 0)
            }
        }

        wrappedTokens[token_] = wrappedToken;
        originalTokens[wrappedToken] = token_;
        emit DownscaledTokenCreated(token_, address(wrappedToken));

        return wrappedToken;
    }

    function deployAndWrapAndSend(
        IERC20 token_,
        uint256 amount_,
        uint256 chainId_,
        bytes memory recipient_,
        uint256 executionFee_
    ) external payable returns (bytes32) {
        deployDownscaledToken(address(token_));
        return
            wrapAndSend(token_, amount_, chainId_, recipient_, executionFee_);
    }

    function wrapAndSend(
        IERC20 token_,
        uint256 amount_,
        uint256 chainId_,
        bytes memory recipient_,
        uint256 executionFee_
    ) public payable returns (bytes32) {
        DownscaledToken wToken = wrappedTokens[address(token_)];
        if (!(address(wToken) != address(0))) {
            revert WrongArgument();
        }
        // require(address(wToken) != address(0), WrongArgument());

        // Adjust _amount so we pull only what is going to be wrapped (avoiding dust)
        uint256 adjustedAmount = wToken.adjustAmount(amount_);

        token_.safePull(adjustedAmount);

        token_.lazyApprove(address(wToken), adjustedAmount);
        uint64 wrappedAmount = wToken.wrap(adjustedAmount);

        wToken.lazyApprove(address(_deBridgeGate), wrappedAmount);
        return
            _sendToBridge(
                wToken,
                wrappedAmount,
                chainId_,
                recipient_,
                wToken.downscaleAmount(executionFee_)
            );
    }

    function getMaxDecimals(
        uint256 totalSupply_,
        uint8 originalDecimals_
    ) public pure returns (uint8) {
        for (
            uint8 wrappedDecimals = originalDecimals_;
            wrappedDecimals > 0;
            wrappedDecimals--
        ) {
            uint256 scaledSupply = totalSupply_ /
                (10 ** (originalDecimals_ - wrappedDecimals));

            // Check if the scaled supply fits within uint64
            if (scaledSupply <= type(uint64).max) {
                return wrappedDecimals; // Return the max valid decimals difference
            }
        }

        // If we reach here, it means we cannot reduce decimals enough to fit in uint64
        revert SupplyTooLarge();
    }

    function _sendToBridge(
        DownscaledToken token_,
        uint64 amount_,
        uint256 chainId_,
        bytes memory recipient_,
        uint64 executionFee_
    ) internal returns (bytes32) {
        IDeBridgeGate.SubmissionAutoParamsTo memory autoParams;
        autoParams.fallbackAddress = recipient_;
        autoParams.executionFee = executionFee_;

        // send to deBridge gate
        return
            _deBridgeGate.send{value: msg.value}(
                address(token_), // _tokenAddress
                amount_, // _amount
                chainId_, // _chainIdTo
                recipient_, // _receiver
                "", // _permit
                false, // _useAssetFee
                0, // _referralCode
                executionFee_ == 0 ? bytes("") : abi.encode(autoParams) // _autoParams
            );
    }

    function version() external pure returns (string memory) {
        return "1.0.0";
    }
}
