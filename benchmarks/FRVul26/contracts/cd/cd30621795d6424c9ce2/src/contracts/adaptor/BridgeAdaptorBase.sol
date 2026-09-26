// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

import "../helpers/Constants.sol";
import "../helpers/Errors.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title BridgeAdaptorBase
/// @notice All Bridge adaptor must implement it
/// @dev All Bridge adaptor must implement it
abstract contract BridgeAdaptorBase is Ownable {
    using SafeERC20 for IERC20;

    address public immutable xBridge;

    mapping(address => bool) public routers;

    constructor(address _xBridge, address[] memory _routersList) {
        require(_xBridge != address(0), XBridgeErrors.ADDRESS_0);
        xBridge = _xBridge;
        for (uint256 i = 0; i < _routersList.length; i++) {
            routers[_routersList[i]] = true;
        }
    }

    //-------------------------------
    //------- Events ----------------
    //-------------------------------
    event LogOutboundBridgeTo(address _from, address _to, address _token, uint256 _amount, bytes32 _extraData);

    event EmergencyWithdraw(address indexed _to, address _token, uint amount);

    //-------------------------------
    //------- Modifier --------------
    //-------------------------------
    modifier onlyXBridge() {
        require(msg.sender == xBridge, XBridgeErrors.ONLY_X_BRIDGE);
        _;
    }

    //-------------------------------
    //------- Internal Functions ----
    //-------------------------------
    function _approve(address token, address spender, uint256 amount) internal {
        if (IERC20(token).allowance(address(this), spender) == 0) {
            IERC20(token).safeApprove(spender, amount);
        } else {
            IERC20(token).safeApprove(spender, 0);
            IERC20(token).safeApprove(spender, amount);
        }
    }

    function _approve2(address token, address spender, uint256 amount) internal {
        uint256 preAllowance = IERC20(token).allowance(address(this), spender);
        if (preAllowance == 0) {
            IERC20(token).safeApprove(spender, type(uint256).max);
        } else if (preAllowance < amount){
            IERC20(token).safeApprove(spender, 0);
            IERC20(token).safeApprove(spender, type(uint256).max);
        }
    }
    //-------------------------------
    //------- Admin functions -------
    //-------------------------------
    function setRouters(address[] calldata _routersList, bool[] calldata _v) public onlyOwner {
        for (uint256 i = 0; i < _routersList.length; i++) {
            routers[_routersList[i]] = _v[i];
        }
    }

    // workaround for a possible solidity bug
    function withdrawEmergency(address _to, address _token, uint _amount) public onlyOwner {
        if (_token == XBridgeConstants.NATIVE_TOKEN) {
            payable(_to).transfer(_amount);
        } else {
            IERC20(_token).safeTransfer(_to, _amount);
        }
        emit EmergencyWithdraw(_to, _token, _amount);
    }

    //-------------------------------
    //------- Users Functions -------
    //-------------------------------
    function outboundBridgeTo(
        address _from,
        address _to,
        address _refundAddress,
        address _token,
        uint256 _amount,
        uint256 _toChainId,
        bytes memory _data
    ) external payable virtual;

    receive() external payable {}
}
