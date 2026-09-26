// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

/// @title Utils
/// @notice Library for general purpose functions and values.
library Utils {
    using SafeERC20 for IERC20;
    using Address for address payable;

    /// @notice Thrown when an approval call to an ERC20 contract failed.
    error ApprovalFailed();
    /// @notice Thrown when service has zero address because not available on current chain.
    error ServiceUnavailable();

    /// @notice Arbitrary address chosen to represent native token of current network.
    address internal constant nativeToken = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    /// @notice Handle logic around approval for ERC20 token contracts depending on
    /// the context. Will give unlimited allowance on first call and only trigger
    /// again if allowance is below expected amount.
    /// @dev Handle allowance reset to comply with USDT token contract.
    /// @dev Should not be used with any contract that holds ERC20 tokens.
    /// @param token Address of the ERC20 token contract to send approval to.
    /// @param spender Address that will be granted allowance.
    /// @param amount Amount of ERC20 token to grant allowance for.
    function smartApprove(address token, address spender, uint256 amount) internal {
        uint256 allowance = IERC20(token).allowance(address(this), spender);
        if (allowance < amount) {
            if (allowance > 0) {
                _approveCall(token, spender, 0);
            }
            _approveCall(token, spender, type(uint256).max);
        }
    }

    /// @notice Create, send and check low level approval call.
    /// @dev Should not be used with any contract that holds ERC20 tokens.
    /// @param token Address of the ERC20 token contract to send approval to.
    /// @param spender Address that will be granted allowance.
    /// @param amount Amount of ERC20 token to grant allowance for.
    function _approveCall(address token, address spender, uint256 amount) private {
        // Unlimited approval is not security issue since the contract does not store any ERC20 token.
        (bool success, ) = token.call(
            abi.encodeWithSelector(IERC20.approve.selector, spender, amount)
        );
        if (!success) revert ApprovalFailed();
    }

    /// @notice Transfer token in a safe way wether it is ERC20 or native.
    /// @param token Address of the ERC20 token to be transfered.
    /// 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE in case of native token.
    /// @param to Address that will receive the tokens.
    /// @param amount Amount of ERC20 or native tokens to transfer.
    function smartTransfer(address token, address payable to, uint256 amount) internal {
        if (token == nativeToken) {
            to.sendValue(amount);
        } else {
            IERC20(token).safeTransfer(to, amount);
        }
    }

    /// @notice Make sure required service is available on current network by checking if an address
    /// have been provided for it. Revert transaction otherwise.
    /// @param service Address of the service to be checked.
    function checkServiceAvailability(address service) internal pure {
        if (service == address(0)) revert ServiceUnavailable();
    }
}
