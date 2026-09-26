// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
interface IDEXVault {
    function depositERC20(
        address token,
        uint256 amount,
        address receiver
    ) external;
    function depositETH(address receiver) external;

    function withdrawERC20(
        address to,
        uint256 amount,
        address token,
        uint256 expireTime,
        uint256 requestId,
        address[] calldata allSigners,
        bytes[] calldata signatures
    ) external;

    function withdrawETH(
        address to,
        uint256 amount,
        uint256 expireTime,
        uint256 requestId,
        address[] calldata allSigners,
        bytes[] calldata signatures
    ) external;

    function withdrawERC20TokenByOwner(
        address token_,
        address to,
        uint256 amount
    ) external returns (bool);

    function withdrawETHByOwner(
        address to,
        uint256 amount
    ) external returns (bool);

    function initialize(
        address[] memory allowedSigners,
        address usdt,
        uint256 _withdrawUSDTLimit,
        uint256 _withdrawETHLimit
    ) external;

    // for owner
    function changeSigners(address[] calldata allowedSigners) external;
    function isAllowedSigner(address signer) external view returns (bool);
    function signers(uint256) external view returns (address);
    function getSigners() external view returns (address[] memory);
    function setWithdrawLimit(address token, uint256 withdrawLimit) external;
    function tokenWithdrawLimit(address) external view returns (uint256);

    function owner() external view returns (address);
    function transferOwnership(address newOwner) external;
    function renounceOwnership() external;
    function pause() external;
    function unpause() external;
    function paused() external view returns (bool);

    // for uups
    function proxiableUUID() external view returns (bytes32);
    function upgradeToAndCall(
        address newImplementation,
        bytes memory data
    ) external;
    function upgradeTo(address newImplementation) external;
    function UPGRADE_INTERFACE_VERSION() external view returns (string memory);

    // view
    function USDT_ADDRESS() external view returns (address);
    function calcSigHash(
        address to,
        uint256 amount,
        address token,
        uint256 expireTime,
        uint256 requestId
    ) external view returns (bytes32);
}
