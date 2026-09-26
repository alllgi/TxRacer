// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

library TokenLib {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    error EthTransferFailed();

    address private constant USDT_ON_TRON = address(0xa614f803B6FD780986A42c78Ec9c7f77e6DeD13C);

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        if (value > 0) {
            if (token == address(0)) {
                _safeTransferETH(to, value);
            }
            else if (token == USDT_ON_TRON) {
                // The return value of transfer is intentionally ignored here because the Tron USDT implementation
                // is known to deviate from the standard ERC20 pattern and can return 'false' on successful transfers.
                IERC20Upgradeable(token).transfer(to, value);
            } else {
                IERC20Upgradeable(token).safeTransfer(to, value);
            }
        }
    }

    function trySafeTransfer(
        address token,
        address to,
        uint256 value
    ) internal returns (bool success) {
        if (value == 0) return true;

        if (token == address(0)) {
            (success, ) = to.call{value: value}(new bytes(0));
            return success;
        }

        if (token.code.length == 0) {
            // ERC20 token is not contract
            return false;
        }

        bytes memory returnData;
        (success, returnData) = token.call(
            abi.encodeWithSelector(IERC20Upgradeable.transfer.selector, to, value)
        );

        if (!success) return false;

        if (token == USDT_ON_TRON) {
            // The return value of transfer is intentionally ignored here because the Tron USDT implementation
            // is known to deviate from the standard ERC20 pattern and can return 'false' on successful transfers.
            return true;
        }

        if (returnData.length == 0) {
            // Non-standard ERC20: no return value
            return true;
        }

        // Standard ERC20: check return value
        return abi.decode(returnData, (bool));
    }

    function _safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        if (!success) revert EthTransferFailed();
    }
}