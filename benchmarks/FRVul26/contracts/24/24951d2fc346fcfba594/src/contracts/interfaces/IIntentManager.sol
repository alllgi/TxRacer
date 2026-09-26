// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IIntentManager {
    function getValidHelper(uint256) external view returns (address);

    function verifyForDeploy(
        address account,
        bytes32[] calldata proofs
    ) external view returns (uint32);

    function verifyForHandle(
        uint256 id,
        address account,
        bytes32[] calldata proofs
    ) external view returns (address, uint80, address, uint32, uint32);

    function verifyForWithdraw(
        address account,
        bytes32[] calldata proofs
    ) external view returns (address, uint32);

    function getTaxRecipient() external view returns (address);

    function isAAOperator(address, bytes32[] calldata) external view returns (bool);

    function isAdmin(address account) external view returns (bool);

    function getTaxPoints(
        address[] calldata tokenAddresses
    ) external view returns (bool[] memory isCustom, uint256[] memory taxPoints);
}
