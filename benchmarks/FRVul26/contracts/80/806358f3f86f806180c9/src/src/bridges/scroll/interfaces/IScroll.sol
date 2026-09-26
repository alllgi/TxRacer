// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.0;

interface IScrollL1GatewayRouter {
    /// @notice Deposit ETH to some recipient's account in L2.
    /// @param to The address of recipient's account on L2.
    /// @param amount The amount of ETH to be deposited.
    /// @param gasLimit Gas limit required to complete the deposit on L2.
    function depositETH(
        address to,
        uint256 amount,
        uint256 gasLimit
    ) external payable;

    /// @notice Deposit some token to a recipient's account on L2.
    /// @dev Make this function payable to send relayer fee in Ether.
    /// @param _token The address of token in L1.
    /// @param _to The address of recipient's account on L2.
    /// @param _amount The amount of token to transfer.
    /// @param _gasLimit Gas limit required to complete the deposit on L2.
    function depositERC20(
        address _token,
        address _to,
        uint256 _amount,
        uint256 _gasLimit
    ) external payable;
}
