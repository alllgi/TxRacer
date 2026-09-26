// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.0;

interface IMayanForwarderContract {
    struct PermitParams {
        uint256 value;
        uint256 deadline;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    function forwardERC20(
        address tokenIn,
        uint256 amountIn,
        PermitParams calldata permitParams,
        address mayanProtocol,
        bytes calldata protocolData
    ) external payable;

    function forwardEth(
        address mayanProtocol,
        bytes calldata protocolData
    ) external payable;

    function replaceMiddleAmount(
        bytes calldata mayanData,
        uint256 middleAmount
    ) external pure returns (bytes memory);
}
