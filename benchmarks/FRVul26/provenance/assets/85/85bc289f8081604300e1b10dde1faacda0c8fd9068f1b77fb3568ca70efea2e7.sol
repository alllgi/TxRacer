// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

enum CallType {
    Default,
    FullTokenBalance,
    FullNativeBalance,
    CollectTokenBalance
}

struct Call {
    CallType callType;
    address target;
    uint256 value;
    bytes callData;
    bytes payload;
}

interface IXSwapExecutor {
    error TransferFailed();
    error AlreadyRunning();
    error OnlyWhitelistedAddresses();
    error CallFailed(uint256 callPosition, bytes reason);

    event ExecutorRoleGranted();
    event ExecutorRoleRevoked();

    function run(Call[] calldata calls) external payable;
}
