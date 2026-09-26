// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { IERC20 } from "openzeppelin-contracts/token/ERC20/IERC20.sol";

import { IERC3156FlashBorrower } from "openzeppelin-contracts/interfaces/IERC3156FlashBorrower.sol";
import { AccessControlEnumerable } from "openzeppelin-contracts/access/AccessControlEnumerable.sol";

import { IStrategy } from "src/contracts/interfaces/external/tokemak/IStrategy.sol";
import { ISystemRegistry } from "src/contracts/interfaces/external/tokemak/ISystemRegistry.sol";
import { IAutopoolRegistry } from "src/contracts/interfaces/external/tokemak/IAutopoolRegistry.sol";
import { SafeERC20 } from "openzeppelin-contracts/token/ERC20/utils/SafeERC20.sol";

import { VM } from "src/contracts/solver/VM.sol";

// solhint-disable var-name-mixedcase

/**
 * @dev A contract that implements the IERC3156FlashBorrower interface.
 * It allows executing flash loans and rebalancing strategies.
 */
contract FlashBorrowerSolver is VM, IERC3156FlashBorrower, AccessControlEnumerable {
    using SafeERC20 for IERC20;

    ISystemRegistry public immutable getSystemRegistry;

    bytes32 public immutable SOLVER_EXECUTION_ROLE = keccak256("SOLVER_EXECUTION_ROLE");
    bytes32 public immutable SOLVER_RECOVERY_ROLE = keccak256("SOLVER_RECOVERY_ROLE");

    constructor(ISystemRegistry _systemRegistry) {
        _verifyNotZero(address(_systemRegistry), "systemRegistry");
        _verifyNotZero(address(_systemRegistry.autoPoolRegistry()), "autopoolRegistry");

        getSystemRegistry = _systemRegistry;

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    event TokensRecovered(address[] tokens, uint256[] amounts, address[] destinations);

    error CannotRenounceOwnership();
    error OnlyAutoPool();
    error ZeroAddress(string name);
    error ZeroParam(string name);
    error ArraysLengthMismatch();

    modifier onlyAutoPool(address vault) {
        if (!getSystemRegistry.autoPoolRegistry().isVault(vault)) {
            revert OnlyAutoPool();
        }
        _;
    }

    /**
     * @inheritdoc IERC3156FlashBorrower
     * @dev Executes the Weiroll Plan by decoding the commands and state from the data parameter.
     * @param data The encoded commands and state for execution.
     * @return A bytes32 hash of the encoded 'ERC3156FlashBorrower.onFlashLoan' function selector.
     */
    function onFlashLoan(
        address,
        address tokenIn,
        uint256,
        uint256,
        bytes calldata data
    ) external override onlyAutoPool(msg.sender) returns (bytes32) {
        IERC20 target = IERC20(tokenIn);

        (bytes32[] memory commands, bytes[] memory state) = abi.decode(data, (bytes32[], bytes[]));

        _execute(commands, state);

        // Transfer the tokenIn back to the vault.
        // Send the entire balance to the vault so that no funds are left in this contract.
        uint256 targetBalance = target.balanceOf(address(this));

        target.safeTransfer(msg.sender, targetBalance);

        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

    /**
     * @dev Call `flashRebalance` function on the vault.
     * This will call `onFlashLoan` on this contract.
     * `payable` is required for weth wrapping capabilities.
     * @param vault The address of the vault.
     * @param rebalanceParams The parameters for rebalancing ('IStrategy.RebalanceParams').
     * @param data Weiroll  data for the rebalance execution.
     */
    function execute(
        address vault,
        IStrategy.RebalanceParams calldata rebalanceParams,
        bytes calldata data
    ) external payable onlyRole(SOLVER_EXECUTION_ROLE) {
        IStrategy strategy = IStrategy(vault);

        strategy.flashRebalance(IERC3156FlashBorrower(this), rebalanceParams, data);
    }

    /**
     * @dev Recovers tokens and ether from the contract.
     * @param tokens The tokens to recover.
     * @param amounts The amounts to recover.
     * @param destinations The destinations to send the recovered tokens.
     */
    function recover(
        address[] calldata tokens,
        uint256[] calldata amounts,
        address[] calldata destinations
    ) external payable onlyRole(SOLVER_RECOVERY_ROLE) {
        uint256 length = tokens.length;
        _verifyNotZero(length, "length");

        if (length != amounts.length || length != destinations.length) {
            revert ArraysLengthMismatch();
        }

        emit TokensRecovered(tokens, amounts, destinations);

        for (uint256 i = 0; i < length; ++i) {
            (address token, uint256 amount, address destination) = (tokens[i], amounts[i], destinations[i]);
            if (token == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) {
                // solhint-disable-next-line avoid-low-level-calls
                payable(destination).call{ value: amount };
            } else {
                IERC20(token).safeTransfer(destination, amount);
            }
        }
    }

    /**
     * @dev Verifies that the address is not zero.
     * @param addr The address to verify.
     * @param paramName The name of the parameter.
     */
    function _verifyNotZero(address addr, string memory paramName) internal pure {
        if (addr == address(0)) {
            revert ZeroAddress(paramName);
        }
    }

    /**
     * @dev Verifies that the a uint256 is not zero.
     * @param param The uint256 to verify.
     * @param paramName The name of the parameter.
     */
    function _verifyNotZero(uint256 param, string memory paramName) internal pure {
        if (param == 0) {
            revert ZeroParam(paramName);
        }
    }
}
