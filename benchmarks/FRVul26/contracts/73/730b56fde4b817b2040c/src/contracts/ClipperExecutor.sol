// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IReactorCallback.sol";
import "./interfaces/IReactor.sol";
import "./interfaces/IValidationCallback.sol";
import {ResolvedOrder, OutputToken, SignedOrder} from "./base/ReactorStructs.sol";

struct Signature {
    uint8 v;
    bytes32 r;
    bytes32 s;
}

struct ClipperSwapParams {
        uint256 packedInput;
        uint256 packedOutput;
        uint256 goodUntil;
        bytes32 r;
        bytes32 vs;
}

interface ClipperCommonInterface {
    function swap(address inputToken, address outputToken, uint256 inputAmount, uint256 outputAmount, uint256 goodUntil, address destinationAddress, Signature calldata theSignature, bytes calldata auxiliaryData) external;
    function sellEthForToken(address outputToken, uint256 inputAmount, uint256 outputAmount, uint256 goodUntil, address destinationAddress, Signature calldata theSignature, bytes calldata auxiliaryData) external payable;
    function sellTokenForEth(address inputToken, uint256 inputAmount, uint256 outputAmount, uint256 goodUntil, address destinationAddress, Signature calldata theSignature, bytes calldata auxiliaryData) external;
    function nTokens() external view returns (uint);
    function tokenAt(uint i) external view returns (address);
}

/// @notice A fill contract that uses Clipper to execute trades
contract ClipperExecutor is IReactorCallback, Ownable {
    using SafeERC20 for IERC20;

    /// @notice thrown if reactorCallback is called with a non-whitelisted filler
    error CallerNotWhitelisted();
    /// @notice thrown if reactorCallback is called by an adress other than the reactor
    error MsgSenderNotReactor();
    error NativeTransferFailed();

    address private immutable CLIPPER_EXCHANGE;
    address public whitelistedCaller;
    IReactor public reactorV1;
    IReactor public reactorV2;
    address constant NATIVE = 0x0000000000000000000000000000000000000000;
    uint256 constant TRANSFER_NATIVE_GAS_LIMIT = 6900;

    modifier onlyWhitelistedCaller() {
        if (msg.sender != whitelistedCaller) {
            revert CallerNotWhitelisted();
        }
        _;
    }

    modifier onlyReactor() {
        if (msg.sender != address(reactorV1) && msg.sender != address(reactorV2)) {
            revert MsgSenderNotReactor();
        }
        _;
    }

    constructor(IReactor _reactorV1, IReactor _reactorV2, address clipperExchange, address _whitelistedCaller, address initialOwner) Ownable(initialOwner)
    {
        whitelistedCaller = _whitelistedCaller;
        reactorV1 = _reactorV1;
        reactorV2 = _reactorV2;
        CLIPPER_EXCHANGE = clipperExchange;
    }

    // to receive ETH in a swap using native ETH
    receive() external payable {}

    /// @notice assume that we already have all output tokens
    function execute(IReactor _reactor, SignedOrder calldata order, bytes calldata callbackData) external onlyWhitelistedCaller {
        _reactor.executeWithCallback(order, callbackData);
    }

    /// @notice fill UniswapX orders using Clipper
    function reactorCallback(ResolvedOrder[] calldata resolvedOrders, bytes calldata callbackData) external onlyReactor {
        if (callbackData.length > 0) {
            (address[] memory contracts, bytes[] memory swaps, address approvalToken, uint256 approvalAmount, uint256 reactorOutput) = abi.decode(callbackData, (address[], bytes[], address, uint256, uint256));
            for (uint i = 0; i < contracts.length; i++){
                executeSwap(contracts[i], swaps[i], approvalToken, approvalAmount);
            }

            if (address(resolvedOrders[0].outputs[0].token) == NATIVE) {
                // sends native token back to the reactor
                transferNative(msg.sender, reactorOutput);
            } else {
                IERC20(address(resolvedOrders[0].outputs[0].token)).forceApprove(msg.sender, reactorOutput);
            }
        }
    }

    function executeSwap(address _contract, bytes memory swap, address approvalToken, uint256 approvalAmount) internal {
        if(_contract == CLIPPER_EXCHANGE) {
            ClipperSwapParams memory swapParams = abi.decode(
                swap,
                (ClipperSwapParams)
            );
            bytes32 s = swapParams.vs & 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
            uint8 v = 27 + uint8(uint256(swapParams.vs) >> 255);
            Signature memory theSignature = Signature(v,swapParams.r,s);
            delete v;
            delete s;
            if (address(uint160(swapParams.packedInput)) == NATIVE) {
                ClipperCommonInterface(CLIPPER_EXCHANGE).sellEthForToken{value: (swapParams.packedInput >> 160) }(address(uint160(swapParams.packedOutput)),
                (swapParams.packedInput >> 160) , (swapParams.packedOutput >>160),
                swapParams.goodUntil, address(this), theSignature, "ClipperUniswapX");
            } else if (address(uint160(swapParams.packedOutput)) == NATIVE) {
                IERC20(address(uint160(swapParams.packedInput))).safeTransfer(CLIPPER_EXCHANGE, (swapParams.packedInput >> 160));
                ClipperCommonInterface(CLIPPER_EXCHANGE).sellTokenForEth(address(uint160(swapParams.packedInput)),
                (swapParams.packedInput >> 160) , (swapParams.packedOutput >>160),
                swapParams.goodUntil, address(this), theSignature, "ClipperUniswapX");

            } else {
                IERC20(address(uint160(swapParams.packedInput))).safeTransfer(CLIPPER_EXCHANGE, (swapParams.packedInput >> 160));
                ClipperCommonInterface(CLIPPER_EXCHANGE).swap(address(uint160(swapParams.packedInput)), address(uint160(swapParams.packedOutput)),
                 (swapParams.packedInput >> 160) , (swapParams.packedOutput >>160),
                 swapParams.goodUntil, address(this), theSignature, "ClipperUniswapX");
            }
        }
        else {
            IERC20(approvalToken).safeTransfer(_contract, approvalAmount);
            _contract.call(swap);
        }
    }

    function updateWhitelistedCaller(address newCaller) external onlyOwner {
        whitelistedCaller = newCaller;
    }

    function updateReactorV1(IReactor newReactor) external onlyOwner {
        reactorV1 = newReactor;
    }

    function updateReactorV2(IReactor newReactor) external onlyOwner {
        reactorV2 = newReactor;
    }

    function rescueFunds(IERC20 token) external {
        token.safeTransfer(owner(), token.balanceOf(address(this)));
    }

    function tokenEscapeAll() external {
        uint n = ClipperCommonInterface(CLIPPER_EXCHANGE).nTokens();
        for (uint i = 0; i < n; i++) {
            address token = ClipperCommonInterface(CLIPPER_EXCHANGE).tokenAt(i);
            uint256 toSend = IERC20(token).balanceOf(address(this));
            if(toSend > 1){
                toSend = toSend - 1;
            }
            IERC20(token).safeTransfer(owner(), toSend);
        }
        transferNative(owner(), address(this).balance);
    }

    function transferNative(address recipient, uint256 amount) internal {
        (bool success,) = recipient.call{value: amount, gas: TRANSFER_NATIVE_GAS_LIMIT}("");
        if (!success) revert NativeTransferFailed();
    }
}
