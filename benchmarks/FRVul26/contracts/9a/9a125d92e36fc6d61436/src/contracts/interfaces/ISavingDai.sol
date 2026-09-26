// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/interfaces/IERC4626.sol";

/// @notice SavingDai interface
interface ISavingDai is IERC4626 {
    function dai() external view returns (address);
}
