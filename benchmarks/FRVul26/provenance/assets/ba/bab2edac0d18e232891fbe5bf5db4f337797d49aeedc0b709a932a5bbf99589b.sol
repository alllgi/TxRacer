// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

contract DummyAllowanceHolder {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    // Event emitted when tokens are pulled from a spender
    event TokensPulled(
        address indexed token,
        address indexed from,
        address indexed to,
        uint256 amount
    );

    // Pull tokens from a spender to a recipient
    function pullTokens(
        address token,
        address from,
        address to,
        uint256 amount
    ) external {
        // Pull tokens from the spender
        IERC20Upgradeable(token).safeTransferFrom(from, to, amount);
        
        emit TokensPulled(token, from, to, amount);
    }

    // Helper function to check allowance
    function checkAllowance(
        address token,
        address owner
    ) external view returns (uint256) {
        return IERC20Upgradeable(token).allowance(owner, address(this));
    }
} 
