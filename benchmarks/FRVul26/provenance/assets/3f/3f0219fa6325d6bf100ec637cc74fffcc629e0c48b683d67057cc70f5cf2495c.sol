// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import {ERC20Utils} from "./../libraries/ERC20Utils.sol";

contract DownscaledToken is ERC20 {
    using SafeERC20 for IERC20;
    using ERC20Utils for IERC20;
    using SafeCast for uint;

    error WrongArgument();

    uint8 public decimalsDifference; // Difference between original and new decimals
    uint8 public downscaledDecimals;
    IERC20 public token;

    /* ========== INITIALIZERS ========== */

    constructor(
        address token_,
        uint8 downscaledDecimals_
    ) ERC20(ERC20(token_).name(), ERC20(token_).symbol()) {
        token = IERC20(token_);
        uint8 tokenDecimals = ERC20(token_).decimals();
        if (!(downscaledDecimals_ < tokenDecimals)) {
            revert WrongArgument();
        }
        // require(downscaledDecimals_ < tokenDecimals, WrongArgument());

        downscaledDecimals = downscaledDecimals_;
        decimalsDifference = tokenDecimals - downscaledDecimals_;
    }

    // Override decimals to return the wrapped token's decimals
    function decimals() public view virtual override returns (uint8) {
        return downscaledDecimals;
    }

    function wrap(uint256 amount_) external returns (uint64) {
        return _wrap(amount_, msg.sender);
    }

    function adjustAmount(uint256 amount_) public view returns (uint256) {
        // Adjust _amount to be divisible by 10 ** decimalsDifference
        return amount_ - (amount_ % (10 ** decimalsDifference));
    }

    function downscaleAmount(uint256 amount_) public view returns (uint64) {
        return (amount_ / (10 ** decimalsDifference)).toUint64();
    }

    // Deposit original tokens and receive wrapped tokens
    function _wrap(
        uint256 amount_,
        address to_
    ) internal returns (uint64 wrappedAmount) {
        // Adjust _amount so we pull only what is going to be wrapped (avoiding dust)
        uint256 adjustedAmount = adjustAmount(amount_);

        token.safePull(adjustedAmount);

        // Calculate equivalent wrapped amount with reduced decimals
        wrappedAmount = downscaleAmount(adjustedAmount);

        // Mint wrapped tokens to the sender
        _mint(to_, wrappedAmount);
    }

    function unwrapBalanceTo(address to_) external returns (uint256) {
        return _unwrap(balanceOf(msg.sender).toUint64(), to_);
    }

    function unwrap(uint64 wrappedAmount_) external returns (uint256) {
        return _unwrap(wrappedAmount_, msg.sender);
    }

    function unwrap(
        uint64 wrappedAmount_,
        address to_
    ) external returns (uint256) {
        return _unwrap(wrappedAmount_, to_);
    }

    // Redeem wrapped tokens and get back original tokens
    function _unwrap(
        uint64 wrappedAmount_,
        address to_
    ) internal returns (uint256 originalAmount) {
        // Calculate equivalent original amount to redeem
        originalAmount = wrappedAmount_ * (10 ** decimalsDifference);

        // Burn wrapped tokens from sender
        _burn(msg.sender, wrappedAmount_);

        // Transfer original tokens back to the sender
        token.safeTransfer(to_, originalAmount);
    }

    function version() external pure returns (string memory) {
        return "1.0.0";
    }
}
