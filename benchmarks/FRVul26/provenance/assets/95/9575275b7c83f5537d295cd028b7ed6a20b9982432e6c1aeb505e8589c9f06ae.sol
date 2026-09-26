pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract PmmSourceMock {
    using SafeERC20 for IERC20;

    struct OrderTakeState {
        uint8 status;
        address takerAddress;
        uint256 giveChainId;
    }

    mapping(bytes32 => OrderTakeState) public takeOrders;

    uint256 public globalFixedNativeFee;

    error PmmSourceCustomError();

    constructor(uint256 _globalFixedNativeFee) {
        globalFixedNativeFee = _globalFixedNativeFee;
    }

    event OrderCreated(address giveTokenAddress, uint256 giveAmount);

    function setTakeOrders(bytes32 _orderId, uint8 _status) external {
        OrderTakeState storage order = takeOrders[_orderId];
        order.status = _status;
        order.takerAddress = msg.sender;
        order.giveChainId = getChainId();
    }

    function getChainId() public view virtual returns (uint256 cid) {
        assembly {
            cid := chainid()
        }
    }

    ///@dev This method emulates createOrder() which accepts arbitrary amount of arbitrary token (incl. native)
    ///     and the fixed fee in native token
    function paidAction(address tokenIn, uint256 amountIn) external payable {
        if (tokenIn == address(0)) {
            require(
                msg.value == amountIn + globalFixedNativeFee,
                "native fee not covered"
            );
        } else {
            require(
                msg.value == globalFixedNativeFee,
                "msg.value does not cover fee"
            );
            IERC20(tokenIn).safeTransferFrom(
                msg.sender,
                address(this),
                amountIn
            );
        }

        emit OrderCreated(tokenIn, amountIn);
    }

    ///@dev This method emulates fulfill() which accepts arbitrary amount of arbitrary token (incl. native)
    function freeAction(address tokenIn, uint256 amountIn) external payable {
        if (tokenIn == address(0)) {
            require(msg.value == amountIn, "amount in is not exactly the same");
        } else {
            require(msg.value == 0, "msg.value should be zero");
            IERC20(tokenIn).safeTransferFrom(
                msg.sender,
                address(this),
                amountIn
            );
        }

        emit OrderCreated(tokenIn, amountIn);
    }

    ///@dev This method takes the given arbitrary amount of arbitrary token (incl. native) and sends the given amount
    ///     to another address. This is useful to emulate refunds
    function bypass(
        address token,
        uint256 amountIn,
        address refundTo,
        uint256 amountOut
    ) external payable {
        if (token != address(0)) {
            IERC20(token).safeTransferFrom(msg.sender, address(this), amountIn);
        }

        if (token == address(0)) {
            (bool success, ) = refundTo.call{value: amountOut}("");
            require(success);
        } else IERC20(token).safeTransfer(refundTo, amountOut);
    }

    function raiseCustomError() external payable {
        revert PmmSourceCustomError();
    }

    function raiseError() external payable {
        require(false, "error");
    }
}
