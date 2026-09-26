// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import {IIntentHelper} from "./interfaces/IIntentHelper.sol";
import {IAA} from "./interfaces/IAA.sol";
import {IWETH, IERC20} from "./interfaces/IWETH.sol";
import {IIntentManager} from "./interfaces/IIntentManager.sol";
import {
    IUniswapV2Router01,
    IUniswapV2Router02
} from "./mocks/uniswapv2/interfaces/IUniswapV2Router02.sol";

contract EOA is ReentrancyGuard {
    using SafeERC20 for IERC20;
    using Address for address;
    using Address for address payable;

    enum Command {
        V3_SWAP_EXACT_IN,
        V3_SWAP_EXACT_OUT,
        V2_SWAP_EXACT_IN,
        V2_SWAP_EXACT_OUT,
        V2_SWAP_EXACT_ETH_IN,
        V2_SWAP_EXACT_IN_FEE
    }

    struct Parsed {
        uint256 feePoint;
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        Call[] calls;
    }

    struct Call {
        address target;
        bytes data;
    }

    address public immutable WETH;
    address public immutable UNISWAP_V2_ROUTER02;
    IIntentManager public immutable INTENT_MANAGER;
    uint256 public immutable ID_INVITE_REWARD_CLAIM;

    address public claimContract;

    receive() external payable {}

    constructor(
        address weth,
        address uniswapV2Router02,
        IIntentManager intentManager,
        uint256 idInviteRewardClaim
    ) {
        WETH = weth;
        UNISWAP_V2_ROUTER02 = uniswapV2Router02;
        INTENT_MANAGER = intentManager;
        ID_INVITE_REWARD_CLAIM = idInviteRewardClaim;

        IERC20(WETH).approve(UNISWAP_V2_ROUTER02, type(uint256).max);
    }

    function handleIntent(IAA.Intent calldata intent) external payable nonReentrant {
        if (intent.intentId == ID_INVITE_REWARD_CLAIM) {
            if (claimContract == address(0)) {
                claimContract = INTENT_MANAGER.getValidHelper(ID_INVITE_REWARD_CLAIM);
                require(claimContract != address(0), "EOA: no claim contract");
            }
            IIntentHelper(claimContract).parse(abi.encode(msg.sender, intent.params));
            if (msg.value > 0) {
                payable(msg.sender).sendValue(msg.value);
            }
            return;
        }

        address recipient = INTENT_MANAGER.getTaxRecipient();
        Parsed memory parsed = _parse(intent.params);

        bool isBuy = parsed.tokenIn == WETH;
        uint256 fee;
        if (isBuy) {
            fee = (parsed.amountIn * parsed.feePoint) / 10000;
            require(msg.value >= parsed.amountIn + fee, "EOA: insufficient value");
            uint256 refundEther = msg.value - parsed.amountIn - fee;
            if (refundEther > 0) {
                payable(msg.sender).sendValue(refundEther);
            }
            if (fee > 0) {
                payable(recipient).sendValue(fee);
            }
            IWETH(WETH).deposit{value: parsed.amountIn}();
        } else {
            if (msg.value > 0) {
                payable(msg.sender).sendValue(msg.value);
            }
            IERC20(parsed.tokenIn).safeTransferFrom(msg.sender, address(this), parsed.amountIn);
        }

        for (uint256 i = 0; i < parsed.calls.length; ++i) {
            Call memory call = parsed.calls[i];
            call.target.functionCall(call.data, "EOA: call failed");
        }

        uint256 gainAmount = IERC20(parsed.tokenOut).balanceOf(address(this));
        if (isBuy) {
            IERC20(parsed.tokenOut).safeTransfer(msg.sender, gainAmount);
        } else {
            IWETH(WETH).withdraw(gainAmount);
            fee = (gainAmount * parsed.feePoint) / 10000;
            gainAmount -= fee;
            if (gainAmount > 0) {
                payable(msg.sender).sendValue(gainAmount);
            }
            if (address(this).balance > 0) {
                payable(recipient).sendValue(address(this).balance);
            }
        }

        emit BotEOAIntentHandled(msg.sender, intent.intentId, fee, parsed.amountIn, gainAmount);
    }

    function _parse(bytes calldata _params) internal view returns (Parsed memory parsed) {
        (
            uint8 v,
            bool approve,
            uint256 amountInOrOut,
            uint256 minOutOrMaxIn,
            bytes memory path
        ) = abi.decode(_params, (uint8, bool, uint256, uint256, bytes));

        address[] memory v2path = new address[](2);
        (v2path[0], v2path[1]) = abi.decode(path, (address, address));

        parsed.feePoint = _mustHaveWETH(v2path[0], v2path[1]);
        parsed.tokenIn = v2path[0];
        parsed.tokenOut = v2path[1];
        parsed.amountIn = amountInOrOut;

        Command command = Command(v);
        if (command == Command.V2_SWAP_EXACT_ETH_IN) {
            parsed.calls = new Call[](1);
            parsed.calls[0] = Call({
                target: UNISWAP_V2_ROUTER02,
                data: abi.encodeWithSelector(
                    IUniswapV2Router01.swapExactETHForTokens.selector,
                    minOutOrMaxIn,
                    v2path,
                    address(this),
                    block.timestamp + 15 minutes
                )
            });
            return (parsed);
        } else if (command == Command.V2_SWAP_EXACT_IN) {
            if (!approve) {
                parsed.calls = new Call[](1);
            } else {
                parsed.calls = new Call[](2);
                parsed.calls[0] = Call({
                    target: v2path[0],
                    data: abi.encodeWithSelector(
                        IERC20.approve.selector,
                        UNISWAP_V2_ROUTER02,
                        type(uint256).max
                    )
                });
            }
            parsed.calls[parsed.calls.length - 1] = Call({
                target: UNISWAP_V2_ROUTER02,
                data: abi.encodeWithSelector(
                    IUniswapV2Router01.swapExactTokensForTokens.selector,
                    amountInOrOut,
                    minOutOrMaxIn,
                    v2path,
                    address(this),
                    block.timestamp + 15 minutes
                )
            });
        } else if (command == Command.V2_SWAP_EXACT_IN_FEE) {
            if (!approve) {
                parsed.calls = new Call[](1);
            } else {
                parsed.calls = new Call[](2);
                parsed.calls[0] = Call({
                    target: v2path[0],
                    data: abi.encodeWithSelector(
                        IERC20.approve.selector,
                        UNISWAP_V2_ROUTER02,
                        type(uint256).max
                    )
                });
            }
            parsed.calls[parsed.calls.length - 1] = Call({
                target: UNISWAP_V2_ROUTER02,
                data: abi.encodeWithSelector(
                    IUniswapV2Router02
                        .swapExactTokensForTokensSupportingFeeOnTransferTokens
                        .selector,
                    amountInOrOut,
                    minOutOrMaxIn,
                    v2path,
                    address(this),
                    block.timestamp + 15 minutes
                )
            });
        } else {
            revert("EOA: unknown command");
        }
    }

    function _mustHaveWETH(address tokenIn, address tokenOut) internal view returns (uint256) {
        address[] memory tokens = new address[](1);
        if (tokenIn == WETH) {
            tokens[0] = tokenOut;
        } else if (tokenOut == WETH) {
            tokens[0] = tokenIn;
        } else {
            revert("EOA: unsupported pair");
        }
        (, uint256[] memory points) = INTENT_MANAGER.getTaxPoints(tokens);
        return points[0];
    }

    event BotEOAIntentHandled(
        address indexed account,
        uint256 indexed intentId,
        uint256 tax,
        uint256 payAmount,
        uint256 gainAmount
    );
}
