// Sources retrieved from Sourcify API v2.
// Deterministic best-effort flattening; original files are preserved under src/.

// File: src/v0.8/liquiditymanager/interfaces/ILiquidityContainer.sol

pragma solidity ^0.8.0;

/// @notice Interface for a liquidity container, this can be a CCIP token pool.
interface ILiquidityContainer {
  event LiquidityAdded(address indexed provider, uint256 indexed amount);
  event LiquidityRemoved(address indexed provider, uint256 indexed amount);

  /// @notice Provide additional liquidity to the container.
  /// @dev Should emit LiquidityAdded
  function provideLiquidity(uint256 amount) external;

  /// @notice Withdraws liquidity from the container to the msg sender
  /// @dev Should emit LiquidityRemoved
  function withdrawLiquidity(uint256 amount) external;
}

// File: src/v0.8/ccip/pools/USDC/ITokenMessenger.sol

/*
 * Copyright (c) 2022, Circle Internet Financial Limited.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
pragma solidity ^0.8.0;

interface ITokenMessenger {
  /// @notice Emitted when a DepositForBurn message is sent
  /// @param nonce Unique nonce reserved by message
  /// @param burnToken Address of token burnt on source domain
  /// @param amount Deposit amount
  /// @param depositor Address where deposit is transferred from
  /// @param mintRecipient Address receiving minted tokens on destination domain as bytes32
  /// @param destinationDomain Destination domain
  /// @param destinationTokenMessenger Address of TokenMessenger on destination domain as bytes32
  /// @param destinationCaller Authorized caller as bytes32 of receiveMessage() on destination domain,
  /// if not equal to bytes32(0). If equal to bytes32(0), any address can call receiveMessage().
  event DepositForBurn(
    uint64 indexed nonce,
    address indexed burnToken,
    uint256 amount,
    address indexed depositor,
    bytes32 mintRecipient,
    uint32 destinationDomain,
    bytes32 destinationTokenMessenger,
    bytes32 destinationCaller
  );

  /// @notice Burns the tokens on the source side to produce a nonce through
  /// Circles Cross Chain Transfer Protocol.
  /// @param amount Amount of tokens to deposit and burn.
  /// @param destinationDomain Destination domain identifier.
  /// @param mintRecipient Address of mint recipient on destination domain.
  /// @param burnToken Address of contract to burn deposited tokens, on local domain.
  /// @param destinationCaller Caller on the destination domain, as bytes32.
  /// @return nonce The unique nonce used in unlocking the funds on the destination chain.
  /// @dev emits DepositForBurn
  function depositForBurnWithCaller(
    uint256 amount,
    uint32 destinationDomain,
    bytes32 mintRecipient,
    address burnToken,
    bytes32 destinationCaller
  ) external returns (uint64 nonce);

  /// Returns the version of the message body format.
  /// @dev immutable
  function messageBodyVersion() external view returns (uint32);

  /// Returns local Message Transmitter responsible for sending and receiving messages
  /// to/from remote domainsmessage transmitter for this token messenger.
  /// @dev immutable
  function localMessageTransmitter() external view returns (address);
}

// File: src/v0.8/shared/interfaces/IOwnable.sol

pragma solidity ^0.8.0;

interface IOwnable {
  function owner() external returns (address);

  function transferOwnership(address recipient) external;

  function acceptOwnership() external;
}

// File: src/v0.8/shared/access/Ownable2Step.sol

pragma solidity ^0.8.4;



/// @notice A minimal contract that implements 2-step ownership transfer and nothing more. It's made to be minimal
/// to reduce the impact of the bytecode size on any contract that inherits from it.
contract Ownable2Step is IOwnable {
  /// @notice The pending owner is the address to which ownership may be transferred.
  address private s_pendingOwner;
  /// @notice The owner is the current owner of the contract.
  /// @dev The owner is the second storage variable so any implementing contract could pack other state with it
  /// instead of the much less used s_pendingOwner.
  address private s_owner;

  error OwnerCannotBeZero();
  error MustBeProposedOwner();
  error CannotTransferToSelf();
  error OnlyCallableByOwner();

  event OwnershipTransferRequested(address indexed from, address indexed to);
  event OwnershipTransferred(address indexed from, address indexed to);

  constructor(address newOwner, address pendingOwner) {
    if (newOwner == address(0)) {
      revert OwnerCannotBeZero();
    }

    s_owner = newOwner;
    if (pendingOwner != address(0)) {
      _transferOwnership(pendingOwner);
    }
  }

  /// @notice Get the current owner
  function owner() public view override returns (address) {
    return s_owner;
  }

  /// @notice Allows an owner to begin transferring ownership to a new address. The new owner needs to call
  /// `acceptOwnership` to accept the transfer before any permissions are changed.
  /// @param to The address to which ownership will be transferred.
  function transferOwnership(address to) public override onlyOwner {
    _transferOwnership(to);
  }

  /// @notice validate, transfer ownership, and emit relevant events
  /// @param to The address to which ownership will be transferred.
  function _transferOwnership(address to) private {
    if (to == msg.sender) {
      revert CannotTransferToSelf();
    }

    s_pendingOwner = to;

    emit OwnershipTransferRequested(s_owner, to);
  }

  /// @notice Allows an ownership transfer to be completed by the recipient.
  function acceptOwnership() external override {
    if (msg.sender != s_pendingOwner) {
      revert MustBeProposedOwner();
    }

    address oldOwner = s_owner;
    s_owner = msg.sender;
    s_pendingOwner = address(0);

    emit OwnershipTransferred(oldOwner, msg.sender);
  }

  /// @notice validate access
  function _validateOwnership() internal view {
    if (msg.sender != s_owner) {
      revert OnlyCallableByOwner();
    }
  }

  /// @notice Reverts if called by anyone other than the contract owner.
  modifier onlyOwner() {
    _validateOwnership();
    _;
  }
}

// File: src/v0.8/shared/access/Ownable2StepMsgSender.sol

pragma solidity ^0.8.4;



/// @notice Sets the msg.sender to be the owner of the contract and does not set a pending owner.
contract Ownable2StepMsgSender is Ownable2Step {
  constructor() Ownable2Step(msg.sender, address(0)) {}
}

// File: src/v0.8/ccip/libraries/Pool.sol

pragma solidity ^0.8.0;

/// @notice This library contains various token pool functions to aid constructing the return data.
library Pool {
  // The tag used to signal support for the pool v1 standard
  // bytes4(keccak256("CCIP_POOL_V1"))
  bytes4 public constant CCIP_POOL_V1 = 0xaff2afbf;

  // The number of bytes in the return data for a pool v1 releaseOrMint call.
  // This should match the size of the ReleaseOrMintOutV1 struct.
  uint16 public constant CCIP_POOL_V1_RET_BYTES = 32;

  // The default max number of bytes in the return data for a pool v1 lockOrBurn call.
  // This data can be used to send information to the destination chain token pool. Can be overwritten
  // in the TokenTransferFeeConfig.destBytesOverhead if more data is required.
  uint32 public constant CCIP_LOCK_OR_BURN_V1_RET_BYTES = 32;

  struct LockOrBurnInV1 {
    bytes receiver; //  The recipient of the tokens on the destination chain, abi encoded
    uint64 remoteChainSelector; // ─╮ The chain ID of the destination chain
    address originalSender; // ─────╯ The original sender of the tx on the source chain
    uint256 amount; //  The amount of tokens to lock or burn, denominated in the source token's decimals
    address localToken; //  The address on this chain of the token to lock or burn
  }

  struct LockOrBurnOutV1 {
    // The address of the destination token, abi encoded in the case of EVM chains
    // This value is UNTRUSTED as any pool owner can return whatever value they want.
    bytes destTokenAddress;
    // Optional pool data to be transferred to the destination chain. Be default this is capped at
    // CCIP_LOCK_OR_BURN_V1_RET_BYTES bytes. If more data is required, the TokenTransferFeeConfig.destBytesOverhead
    // has to be set for the specific token.
    bytes destPoolData;
  }

  struct ReleaseOrMintInV1 {
    bytes originalSender; //          The original sender of the tx on the source chain
    uint64 remoteChainSelector; // ─╮ The chain ID of the source chain
    address receiver; // ───────────╯ The recipient of the tokens on the destination chain.
    uint256 amount; //                The amount of tokens to release or mint, denominated in the source token's decimals
    address localToken; //            The address on this chain of the token to release or mint
    /// @dev WARNING: sourcePoolAddress should be checked prior to any processing of funds. Make sure it matches the
    /// expected pool address for the given remoteChainSelector.
    bytes sourcePoolAddress; //       The address of the source pool, abi encoded in the case of EVM chains
    bytes sourcePoolData; //          The data received from the source pool to process the release or mint
    /// @dev WARNING: offchainTokenData is untrusted data.
    bytes offchainTokenData; //       The offchain data to process the release or mint
  }

  struct ReleaseOrMintOutV1 {
    // The number of tokens released or minted on the destination chain, denominated in the local token's decimals.
    // This value is expected to be equal to the ReleaseOrMintInV1.amount in the case where the source and destination
    // chain have the same number of decimals.
    uint256 destinationAmount;
  }
}

// File: src/v0.8/vendor/openzeppelin-solidity/v5.0.2/contracts/utils/introspection/IERC165.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/IERC165.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: src/v0.8/ccip/interfaces/IPool.sol

pragma solidity ^0.8.0;





/// @notice Shared public interface for multiple V1 pool types.
/// Each pool type handles a different child token model (lock/unlock, mint/burn.)
interface IPoolV1 is IERC165 {
  /// @notice Lock tokens into the pool or burn the tokens.
  /// @param lockOrBurnIn Encoded data fields for the processing of tokens on the source chain.
  /// @return lockOrBurnOut Encoded data fields for the processing of tokens on the destination chain.
  function lockOrBurn(
    Pool.LockOrBurnInV1 calldata lockOrBurnIn
  ) external returns (Pool.LockOrBurnOutV1 memory lockOrBurnOut);

  /// @notice Releases or mints tokens to the receiver address.
  /// @param releaseOrMintIn All data required to release or mint tokens.
  /// @return releaseOrMintOut The amount of tokens released or minted on the local chain, denominated
  /// in the local token's decimals.
  /// @dev The offramp asserts that the balanceOf of the receiver has been incremented by exactly the number
  /// of tokens that is returned in ReleaseOrMintOutV1.destinationAmount. If the amounts do not match, the tx reverts.
  function releaseOrMint(
    Pool.ReleaseOrMintInV1 calldata releaseOrMintIn
  ) external returns (Pool.ReleaseOrMintOutV1 memory);

  /// @notice Checks whether a remote chain is supported in the token pool.
  /// @param remoteChainSelector The selector of the remote chain.
  /// @return true if the given chain is a permissioned remote chain.
  function isSupportedChain(
    uint64 remoteChainSelector
  ) external view returns (bool);

  /// @notice Returns if the token pool supports the given token.
  /// @param token The address of the token.
  /// @return true if the token is supported by the pool.
  function isSupportedToken(
    address token
  ) external view returns (bool);
}

// File: src/v0.8/ccip/interfaces/IRMN.sol

pragma solidity ^0.8.0;

/// @notice This interface contains the only RMN-related functions that might be used on-chain by other CCIP contracts.
interface IRMN {
  /// @notice A Merkle root tagged with the address of the commit store contract it is destined for.
  struct TaggedRoot {
    address commitStore;
    bytes32 root;
  }

  /// @notice Callers MUST NOT cache the return value as a blessed tagged root could become unblessed.
  function isBlessed(
    TaggedRoot calldata taggedRoot
  ) external view returns (bool);

  /// @notice Iff there is an active global or legacy curse, this function returns true.
  function isCursed() external view returns (bool);

  /// @notice Iff there is an active global curse, or an active curse for `subject`, this function returns true.
  /// @param subject To check whether a particular chain is cursed, set to bytes16(uint128(chainSelector)).
  function isCursed(
    bytes16 subject
  ) external view returns (bool);
}

// File: src/v0.8/ccip/libraries/Client.sol

pragma solidity ^0.8.0;

// End consumer library.
library Client {
  /// @dev RMN depends on this struct, if changing, please notify the RMN maintainers.
  struct EVMTokenAmount {
    address token; // token address on the local chain.
    uint256 amount; // Amount of tokens.
  }

  struct Any2EVMMessage {
    bytes32 messageId; // MessageId corresponding to ccipSend on source.
    uint64 sourceChainSelector; // Source chain selector.
    bytes sender; // abi.decode(sender) if coming from an EVM chain.
    bytes data; // payload sent in original message.
    EVMTokenAmount[] destTokenAmounts; // Tokens and their amounts in their destination chain representation.
  }

  // If extraArgs is empty bytes, the default is 200k gas limit.
  struct EVM2AnyMessage {
    bytes receiver; // abi.encode(receiver address) for dest EVM chains
    bytes data; // Data payload
    EVMTokenAmount[] tokenAmounts; // Token transfers
    address feeToken; // Address of feeToken. address(0) means you will send msg.value.
    bytes extraArgs; // Populate this with _argsToBytes(EVMExtraArgsV2)
  }

  // bytes4(keccak256("CCIP EVMExtraArgsV1"));
  bytes4 public constant EVM_EXTRA_ARGS_V1_TAG = 0x97a657c9;

  struct EVMExtraArgsV1 {
    uint256 gasLimit;
  }

  function _argsToBytes(
    EVMExtraArgsV1 memory extraArgs
  ) internal pure returns (bytes memory bts) {
    return abi.encodeWithSelector(EVM_EXTRA_ARGS_V1_TAG, extraArgs);
  }

  // bytes4(keccak256("CCIP EVMExtraArgsV2"));
  bytes4 public constant EVM_EXTRA_ARGS_V2_TAG = 0x181dcf10;

  /// @param gasLimit: gas limit for the callback on the destination chain.
  /// @param allowOutOfOrderExecution: if true, it indicates that the message can be executed in any order relative to other messages from the same sender.
  /// This value's default varies by chain. On some chains, a particular value is enforced, meaning if the expected value
  /// is not set, the message request will revert.
  struct EVMExtraArgsV2 {
    uint256 gasLimit;
    bool allowOutOfOrderExecution;
  }

  function _argsToBytes(
    EVMExtraArgsV2 memory extraArgs
  ) internal pure returns (bytes memory bts) {
    return abi.encodeWithSelector(EVM_EXTRA_ARGS_V2_TAG, extraArgs);
  }
}

// File: src/v0.8/ccip/interfaces/IRouter.sol

pragma solidity ^0.8.0;



interface IRouter {
  error OnlyOffRamp();

  /// @notice Route the message to its intended receiver contract.
  /// @param message Client.Any2EVMMessage struct.
  /// @param gasForCallExactCheck of params for exec
  /// @param gasLimit set of params for exec
  /// @param receiver set of params for exec
  /// @dev if the receiver is a contracts that signals support for CCIP execution through EIP-165.
  /// the contract is called. If not, only tokens are transferred.
  /// @return success A boolean value indicating whether the ccip message was received without errors.
  /// @return retBytes A bytes array containing return data form CCIP receiver.
  /// @return gasUsed the gas used by the external customer call. Does not include any overhead.
  function routeMessage(
    Client.Any2EVMMessage calldata message,
    uint16 gasForCallExactCheck,
    uint256 gasLimit,
    address receiver
  ) external returns (bool success, bytes memory retBytes, uint256 gasUsed);

  /// @notice Returns the configured onramp for a specific destination chain.
  /// @param destChainSelector The destination chain Id to get the onRamp for.
  /// @return onRampAddress The address of the onRamp.
  function getOnRamp(
    uint64 destChainSelector
  ) external view returns (address onRampAddress);

  /// @notice Return true if the given offRamp is a configured offRamp for the given source chain.
  /// @param sourceChainSelector The source chain selector to check.
  /// @param offRamp The address of the offRamp to check.
  function isOffRamp(uint64 sourceChainSelector, address offRamp) external view returns (bool isOffRamp);
}

// File: src/v0.8/ccip/libraries/RateLimiter.sol

pragma solidity ^0.8.4;

/// @notice Implements Token Bucket rate limiting.
/// @dev uint128 is safe for rate limiter state.
/// For USD value rate limiting, it can adequately store USD value in 18 decimals.
/// For ERC20 token amount rate limiting, all tokens that will be listed will have at most
/// a supply of uint128.max tokens, and it will therefore not overflow the bucket.
/// In exceptional scenarios where tokens consumed may be larger than uint128,
/// e.g. compromised issuer, an enabled RateLimiter will check and revert.
library RateLimiter {
  error BucketOverfilled();
  error OnlyCallableByAdminOrOwner();
  error TokenMaxCapacityExceeded(uint256 capacity, uint256 requested, address tokenAddress);
  error TokenRateLimitReached(uint256 minWaitInSeconds, uint256 available, address tokenAddress);
  error AggregateValueMaxCapacityExceeded(uint256 capacity, uint256 requested);
  error AggregateValueRateLimitReached(uint256 minWaitInSeconds, uint256 available);
  error InvalidRateLimitRate(Config rateLimiterConfig);
  error DisabledNonZeroRateLimit(Config config);
  error RateLimitMustBeDisabled();

  event TokensConsumed(uint256 tokens);
  event ConfigChanged(Config config);

  struct TokenBucket {
    uint128 tokens; // ──────╮ Current number of tokens that are in the bucket.
    uint32 lastUpdated; //   │ Timestamp in seconds of the last token refill, good for 100+ years.
    bool isEnabled; // ──────╯ Indication whether the rate limiting is enabled or not
    uint128 capacity; // ────╮ Maximum number of tokens that can be in the bucket.
    uint128 rate; // ────────╯ Number of tokens per second that the bucket is refilled.
  }

  struct Config {
    bool isEnabled; // Indication whether the rate limiting should be enabled
    uint128 capacity; // ────╮ Specifies the capacity of the rate limiter
    uint128 rate; //  ───────╯ Specifies the rate of the rate limiter
  }

  /// @notice _consume removes the given tokens from the pool, lowering the
  /// rate tokens allowed to be consumed for subsequent calls.
  /// @param requestTokens The total tokens to be consumed from the bucket.
  /// @param tokenAddress The token to consume capacity for, use 0x0 to indicate aggregate value capacity.
  /// @dev Reverts when requestTokens exceeds bucket capacity or available tokens in the bucket
  /// @dev emits removal of requestTokens if requestTokens is > 0
  function _consume(TokenBucket storage s_bucket, uint256 requestTokens, address tokenAddress) internal {
    // If there is no value to remove or rate limiting is turned off, skip this step to reduce gas usage
    if (!s_bucket.isEnabled || requestTokens == 0) {
      return;
    }

    uint256 tokens = s_bucket.tokens;
    uint256 capacity = s_bucket.capacity;
    uint256 timeDiff = block.timestamp - s_bucket.lastUpdated;

    if (timeDiff != 0) {
      if (tokens > capacity) revert BucketOverfilled();

      // Refill tokens when arriving at a new block time
      tokens = _calculateRefill(capacity, tokens, timeDiff, s_bucket.rate);

      s_bucket.lastUpdated = uint32(block.timestamp);
    }

    if (capacity < requestTokens) {
      // Token address 0 indicates consuming aggregate value rate limit capacity.
      if (tokenAddress == address(0)) revert AggregateValueMaxCapacityExceeded(capacity, requestTokens);
      revert TokenMaxCapacityExceeded(capacity, requestTokens, tokenAddress);
    }
    if (tokens < requestTokens) {
      uint256 rate = s_bucket.rate;
      // Wait required until the bucket is refilled enough to accept this value, round up to next higher second
      // Consume is not guaranteed to succeed after wait time passes if there is competing traffic.
      // This acts as a lower bound of wait time.
      uint256 minWaitInSeconds = ((requestTokens - tokens) + (rate - 1)) / rate;

      if (tokenAddress == address(0)) revert AggregateValueRateLimitReached(minWaitInSeconds, tokens);
      revert TokenRateLimitReached(minWaitInSeconds, tokens, tokenAddress);
    }
    tokens -= requestTokens;

    // Downcast is safe here, as tokens is not larger than capacity
    s_bucket.tokens = uint128(tokens);
    emit TokensConsumed(requestTokens);
  }

  /// @notice Gets the token bucket with its values for the block it was requested at.
  /// @return The token bucket.
  function _currentTokenBucketState(
    TokenBucket memory bucket
  ) internal view returns (TokenBucket memory) {
    // We update the bucket to reflect the status at the exact time of the
    // call. This means we might need to refill a part of the bucket based
    // on the time that has passed since the last update.
    bucket.tokens =
      uint128(_calculateRefill(bucket.capacity, bucket.tokens, block.timestamp - bucket.lastUpdated, bucket.rate));
    bucket.lastUpdated = uint32(block.timestamp);
    return bucket;
  }

  /// @notice Sets the rate limited config.
  /// @param s_bucket The token bucket
  /// @param config The new config
  function _setTokenBucketConfig(TokenBucket storage s_bucket, Config memory config) internal {
    // First update the bucket to make sure the proper rate is used for all the time
    // up until the config change.
    uint256 timeDiff = block.timestamp - s_bucket.lastUpdated;
    if (timeDiff != 0) {
      s_bucket.tokens = uint128(_calculateRefill(s_bucket.capacity, s_bucket.tokens, timeDiff, s_bucket.rate));

      s_bucket.lastUpdated = uint32(block.timestamp);
    }

    s_bucket.tokens = uint128(_min(config.capacity, s_bucket.tokens));
    s_bucket.isEnabled = config.isEnabled;
    s_bucket.capacity = config.capacity;
    s_bucket.rate = config.rate;

    emit ConfigChanged(config);
  }

  /// @notice Validates the token bucket config
  function _validateTokenBucketConfig(Config memory config, bool mustBeDisabled) internal pure {
    if (config.isEnabled) {
      if (config.rate >= config.capacity || config.rate == 0) {
        revert InvalidRateLimitRate(config);
      }
      if (mustBeDisabled) {
        revert RateLimitMustBeDisabled();
      }
    } else {
      if (config.rate != 0 || config.capacity != 0) {
        revert DisabledNonZeroRateLimit(config);
      }
    }
  }

  /// @notice Calculate refilled tokens
  /// @param capacity bucket capacity
  /// @param tokens current bucket tokens
  /// @param timeDiff block time difference since last refill
  /// @param rate bucket refill rate
  /// @return the value of tokens after refill
  function _calculateRefill(
    uint256 capacity,
    uint256 tokens,
    uint256 timeDiff,
    uint256 rate
  ) private pure returns (uint256) {
    return _min(capacity, tokens + timeDiff * rate);
  }

  /// @notice Return the smallest of two integers
  /// @param a first int
  /// @param b second int
  /// @return smallest
  function _min(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }
}

// File: src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
  /**
   * @dev Emitted when `value` tokens are moved from one account (`from`) to
   * another (`to`).
   *
   * Note that `value` may be zero.
   */
  event Transfer(address indexed from, address indexed to, uint256 value);

  /**
   * @dev Emitted when the allowance of a `spender` for an `owner` is set by
   * a call to {approve}. `value` is the new allowance.
   */
  event Approval(address indexed owner, address indexed spender, uint256 value);

  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `to`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address to, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
  function allowance(address owner, address spender) external view returns (uint256);

  /**
   * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * IMPORTANT: Beware that changing an allowance with this method brings the risk
   * that someone may use both the old and the new allowance by unfortunate
   * transaction ordering. One possible solution to mitigate this race
   * condition is to first reduce the spender's allowance to 0 and set the
   * desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   *
   * Emits an {Approval} event.
   */
  function approve(address spender, uint256 amount) external returns (bool);

  /**
   * @dev Moves `amount` tokens from `from` to `to` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

// File: src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/extensions/IERC20Metadata.sol

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;



/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
  /**
   * @dev Returns the name of the token.
   */
  function name() external view returns (string memory);

  /**
   * @dev Returns the symbol of the token.
   */
  function symbol() external view returns (string memory);

  /**
   * @dev Returns the decimals places of the token.
   */
  function decimals() external view returns (uint8);
}

// File: src/v0.8/vendor/openzeppelin-solidity/v5.0.2/contracts/utils/structs/EnumerableSet.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity ^0.8.20;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```solidity
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position is the index of the value in the `values` array plus 1.
        // Position 0 is used to mean a value is not in the set.
        mapping(bytes32 value => uint256) _positions;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._positions[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We cache the value's position to prevent multiple reads from the same storage slot
        uint256 position = set._positions[value];

        if (position != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 valueIndex = position - 1;
            uint256 lastIndex = set._values.length - 1;

            if (valueIndex != lastIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the lastValue to the index where the value to delete is
                set._values[valueIndex] = lastValue;
                // Update the tracked position of the lastValue (that was just moved)
                set._positions[lastValue] = position;
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the tracked position for the deleted slot
            delete set._positions[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._positions[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

// File: src/v0.8/ccip/pools/TokenPool.sol

pragma solidity 0.8.24;














/// @dev This pool supports different decimals on different chains but using this feature could impact the total number
/// of tokens in circulation. Since all of the tokens are locked/burned on the source, and a rounded amount is minted/released on the
/// destination, the number of tokens minted/released could be less than the number of tokens burned/locked. This is because the source
/// chain does not know about the destination token decimals. This is not a problem if the decimals are the same on both
/// chains.
///
/// Example:
/// Assume there is a token with 6 decimals on chain A and 3 decimals on chain B.
/// - 1.234567 tokens are burned on chain A.
/// - 1.234    tokens are minted on chain B.
/// When sending the 1.234 tokens back to chain A, you will receive 1.234000 tokens on chain A, effectively losing
/// 0.000567 tokens.
/// In the case of a burnMint pool on chain A, these funds are burned in the pool on chain A.
/// In the case of a lockRelease pool on chain A, these funds accumulate in the pool on chain A.
abstract contract TokenPool is IPoolV1, Ownable2StepMsgSender {
  using EnumerableSet for EnumerableSet.Bytes32Set;
  using EnumerableSet for EnumerableSet.AddressSet;
  using EnumerableSet for EnumerableSet.UintSet;
  using RateLimiter for RateLimiter.TokenBucket;

  error CallerIsNotARampOnRouter(address caller);
  error ZeroAddressNotAllowed();
  error SenderNotAllowed(address sender);
  error AllowListNotEnabled();
  error NonExistentChain(uint64 remoteChainSelector);
  error ChainNotAllowed(uint64 remoteChainSelector);
  error CursedByRMN();
  error ChainAlreadyExists(uint64 chainSelector);
  error InvalidSourcePoolAddress(bytes sourcePoolAddress);
  error InvalidToken(address token);
  error Unauthorized(address caller);
  error PoolAlreadyAdded(uint64 remoteChainSelector, bytes remotePoolAddress);
  error InvalidRemotePoolForChain(uint64 remoteChainSelector, bytes remotePoolAddress);
  error InvalidRemoteChainDecimals(bytes sourcePoolData);
  error OverflowDetected(uint8 remoteDecimals, uint8 localDecimals, uint256 remoteAmount);
  error InvalidDecimalArgs(uint8 expected, uint8 actual);

  event Locked(address indexed sender, uint256 amount);
  event Burned(address indexed sender, uint256 amount);
  event Released(address indexed sender, address indexed recipient, uint256 amount);
  event Minted(address indexed sender, address indexed recipient, uint256 amount);
  event ChainAdded(
    uint64 remoteChainSelector,
    bytes remoteToken,
    RateLimiter.Config outboundRateLimiterConfig,
    RateLimiter.Config inboundRateLimiterConfig
  );
  event ChainConfigured(
    uint64 remoteChainSelector,
    RateLimiter.Config outboundRateLimiterConfig,
    RateLimiter.Config inboundRateLimiterConfig
  );
  event ChainRemoved(uint64 remoteChainSelector);
  event RemotePoolAdded(uint64 indexed remoteChainSelector, bytes remotePoolAddress);
  event RemotePoolRemoved(uint64 indexed remoteChainSelector, bytes remotePoolAddress);
  event AllowListAdd(address sender);
  event AllowListRemove(address sender);
  event RouterUpdated(address oldRouter, address newRouter);
  event RateLimitAdminSet(address rateLimitAdmin);

  struct ChainUpdate {
    uint64 remoteChainSelector; // Remote chain selector
    bytes[] remotePoolAddresses; // Address of the remote pool, ABI encoded in the case of a remote EVM chain.
    bytes remoteTokenAddress; // Address of the remote token, ABI encoded in the case of a remote EVM chain.
    RateLimiter.Config outboundRateLimiterConfig; // Outbound rate limited config, meaning the rate limits for all of the onRamps for the given chain
    RateLimiter.Config inboundRateLimiterConfig; // Inbound rate limited config, meaning the rate limits for all of the offRamps for the given chain
  }

  struct RemoteChainConfig {
    RateLimiter.TokenBucket outboundRateLimiterConfig; // Outbound rate limited config, meaning the rate limits for all of the onRamps for the given chain
    RateLimiter.TokenBucket inboundRateLimiterConfig; // Inbound rate limited config, meaning the rate limits for all of the offRamps for the given chain
    bytes remoteTokenAddress; // Address of the remote token, ABI encoded in the case of a remote EVM chain.
    EnumerableSet.Bytes32Set remotePools; // Set of remote pool hashes, ABI encoded in the case of a remote EVM chain.
  }

  /// @dev The bridgeable token that is managed by this pool. Pools could support multiple tokens at the same time if
  /// required, but this implementation only supports one token.
  IERC20 internal immutable i_token;
  /// @dev The number of decimals of the token managed by this pool.
  uint8 internal immutable i_tokenDecimals;
  /// @dev The address of the RMN proxy
  address internal immutable i_rmnProxy;
  /// @dev The immutable flag that indicates if the pool is access-controlled.
  bool internal immutable i_allowlistEnabled;
  /// @dev A set of addresses allowed to trigger lockOrBurn as original senders.
  /// Only takes effect if i_allowlistEnabled is true.
  /// This can be used to ensure only token-issuer specified addresses can move tokens.
  EnumerableSet.AddressSet internal s_allowlist;
  /// @dev The address of the router
  IRouter internal s_router;
  /// @dev A set of allowed chain selectors. We want the allowlist to be enumerable to
  /// be able to quickly determine (without parsing logs) who can access the pool.
  /// @dev The chain selectors are in uint256 format because of the EnumerableSet implementation.
  EnumerableSet.UintSet internal s_remoteChainSelectors;
  mapping(uint64 remoteChainSelector => RemoteChainConfig) internal s_remoteChainConfigs;
  /// @notice A mapping of hashed pool addresses to their unhashed form. This is used to be able to find the actually
  /// configured pools and not just their hashed versions.
  mapping(bytes32 poolAddressHash => bytes poolAddress) internal s_remotePoolAddresses;
  /// @notice The address of the rate limiter admin.
  /// @dev Can be address(0) if none is configured.
  address internal s_rateLimitAdmin;

  constructor(IERC20 token, uint8 localTokenDecimals, address[] memory allowlist, address rmnProxy, address router) {
    if (address(token) == address(0) || router == address(0) || rmnProxy == address(0)) revert ZeroAddressNotAllowed();
    i_token = token;
    i_rmnProxy = rmnProxy;

    try IERC20Metadata(address(token)).decimals() returns (uint8 actualTokenDecimals) {
      if (localTokenDecimals != actualTokenDecimals) {
        revert InvalidDecimalArgs(localTokenDecimals, actualTokenDecimals);
      }
    } catch {
      // The decimals function doesn't exist, which is possible since it's optional in the ERC20 spec. We skip the check and
      // assume the supplied token decimals are correct.
    }
    i_tokenDecimals = localTokenDecimals;

    s_router = IRouter(router);

    // Pool can be set as permissioned or permissionless at deployment time only to save hot-path gas.
    i_allowlistEnabled = allowlist.length > 0;
    if (i_allowlistEnabled) {
      _applyAllowListUpdates(new address[](0), allowlist);
    }
  }

  /// @inheritdoc IPoolV1
  function isSupportedToken(
    address token
  ) public view virtual returns (bool) {
    return token == address(i_token);
  }

  /// @notice Gets the IERC20 token that this pool can lock or burn.
  /// @return token The IERC20 token representation.
  function getToken() public view returns (IERC20 token) {
    return i_token;
  }

  /// @notice Get RMN proxy address
  /// @return rmnProxy Address of RMN proxy
  function getRmnProxy() public view returns (address rmnProxy) {
    return i_rmnProxy;
  }

  /// @notice Gets the pool's Router
  /// @return router The pool's Router
  function getRouter() public view returns (address router) {
    return address(s_router);
  }

  /// @notice Sets the pool's Router
  /// @param newRouter The new Router
  function setRouter(
    address newRouter
  ) public onlyOwner {
    if (newRouter == address(0)) revert ZeroAddressNotAllowed();
    address oldRouter = address(s_router);
    s_router = IRouter(newRouter);

    emit RouterUpdated(oldRouter, newRouter);
  }

  /// @notice Signals which version of the pool interface is supported
  function supportsInterface(
    bytes4 interfaceId
  ) public pure virtual override returns (bool) {
    return interfaceId == Pool.CCIP_POOL_V1 || interfaceId == type(IPoolV1).interfaceId
      || interfaceId == type(IERC165).interfaceId;
  }

  // ================================================================
  // │                         Validation                           │
  // ================================================================

  /// @notice Validates the lock or burn input for correctness on
  /// - token to be locked or burned
  /// - RMN curse status
  /// - allowlist status
  /// - if the sender is a valid onRamp
  /// - rate limit status
  /// @param lockOrBurnIn The input to validate.
  /// @dev This function should always be called before executing a lock or burn. Not doing so would allow
  /// for various exploits.
  function _validateLockOrBurn(
    Pool.LockOrBurnInV1 calldata lockOrBurnIn
  ) internal {
    if (!isSupportedToken(lockOrBurnIn.localToken)) revert InvalidToken(lockOrBurnIn.localToken);
    if (IRMN(i_rmnProxy).isCursed(bytes16(uint128(lockOrBurnIn.remoteChainSelector)))) revert CursedByRMN();
    _checkAllowList(lockOrBurnIn.originalSender);

    _onlyOnRamp(lockOrBurnIn.remoteChainSelector);
    _consumeOutboundRateLimit(lockOrBurnIn.remoteChainSelector, lockOrBurnIn.amount);
  }

  /// @notice Validates the release or mint input for correctness on
  /// - token to be released or minted
  /// - RMN curse status
  /// - if the sender is a valid offRamp
  /// - if the source pool is valid
  /// - rate limit status
  /// @param releaseOrMintIn The input to validate.
  /// @dev This function should always be called before executing a release or mint. Not doing so would allow
  /// for various exploits.
  function _validateReleaseOrMint(
    Pool.ReleaseOrMintInV1 calldata releaseOrMintIn
  ) internal {
    if (!isSupportedToken(releaseOrMintIn.localToken)) revert InvalidToken(releaseOrMintIn.localToken);
    if (IRMN(i_rmnProxy).isCursed(bytes16(uint128(releaseOrMintIn.remoteChainSelector)))) revert CursedByRMN();
    _onlyOffRamp(releaseOrMintIn.remoteChainSelector);

    // Validates that the source pool address is configured on this pool.
    if (!isRemotePool(releaseOrMintIn.remoteChainSelector, releaseOrMintIn.sourcePoolAddress)) {
      revert InvalidSourcePoolAddress(releaseOrMintIn.sourcePoolAddress);
    }

    _consumeInboundRateLimit(releaseOrMintIn.remoteChainSelector, releaseOrMintIn.amount);
  }

  // ================================================================
  // │                      Token decimals                          │
  // ================================================================

  /// @notice Gets the IERC20 token decimals on the local chain.
  function getTokenDecimals() public view virtual returns (uint8 decimals) {
    return i_tokenDecimals;
  }

  function _encodeLocalDecimals() internal view virtual returns (bytes memory) {
    return abi.encode(i_tokenDecimals);
  }

  function _parseRemoteDecimals(
    bytes memory sourcePoolData
  ) internal view virtual returns (uint8) {
    // Fallback to the local token decimals if the source pool data is empty. This allows for backwards compatibility.
    if (sourcePoolData.length == 0) {
      return i_tokenDecimals;
    }
    if (sourcePoolData.length != 32) {
      revert InvalidRemoteChainDecimals(sourcePoolData);
    }
    uint256 remoteDecimals = abi.decode(sourcePoolData, (uint256));
    if (remoteDecimals > type(uint8).max) {
      revert InvalidRemoteChainDecimals(sourcePoolData);
    }
    return uint8(remoteDecimals);
  }

  /// @notice Calculates the local amount based on the remote amount and decimals.
  /// @param remoteAmount The amount on the remote chain.
  /// @param remoteDecimals The decimals of the token on the remote chain.
  /// @return The local amount.
  /// @dev This function protects against overflows. If there is a transaction that hits the overflow check, it is
  /// probably incorrect as that means the amount cannot be represented on this chain. If the local decimals have been
  /// wrongly configured, the token issuer could redeploy the pool with the correct decimals and manually re-execute the
  /// CCIP tx to fix the issue.
  function _calculateLocalAmount(uint256 remoteAmount, uint8 remoteDecimals) internal view virtual returns (uint256) {
    if (remoteDecimals == i_tokenDecimals) {
      return remoteAmount;
    }
    if (remoteDecimals > i_tokenDecimals) {
      uint8 decimalsDiff = remoteDecimals - i_tokenDecimals;
      if (decimalsDiff > 77) {
        // This is a safety check to prevent overflow in the next calculation.
        revert OverflowDetected(remoteDecimals, i_tokenDecimals, remoteAmount);
      }
      // Solidity rounds down so there is no risk of minting more tokens than the remote chain sent.
      return remoteAmount / (10 ** decimalsDiff);
    }

    // This is a safety check to prevent overflow in the next calculation.
    // More than 77 would never fit in a uint256 and would cause an overflow. We also check if the resulting amount
    // would overflow.
    uint8 diffDecimals = i_tokenDecimals - remoteDecimals;
    if (diffDecimals > 77 || remoteAmount > type(uint256).max / (10 ** diffDecimals)) {
      revert OverflowDetected(remoteDecimals, i_tokenDecimals, remoteAmount);
    }

    return remoteAmount * (10 ** diffDecimals);
  }

  // ================================================================
  // │                     Chain permissions                        │
  // ================================================================

  /// @notice Gets the pool address on the remote chain.
  /// @param remoteChainSelector Remote chain selector.
  /// @dev To support non-evm chains, this value is encoded into bytes
  function getRemotePools(
    uint64 remoteChainSelector
  ) public view returns (bytes[] memory) {
    bytes32[] memory remotePoolHashes = s_remoteChainConfigs[remoteChainSelector].remotePools.values();

    bytes[] memory remotePools = new bytes[](remotePoolHashes.length);
    for (uint256 i = 0; i < remotePoolHashes.length; ++i) {
      remotePools[i] = s_remotePoolAddresses[remotePoolHashes[i]];
    }

    return remotePools;
  }

  /// @notice Checks if the pool address is configured on the remote chain.
  /// @param remoteChainSelector Remote chain selector.
  /// @param remotePoolAddress The address of the remote pool.
  function isRemotePool(uint64 remoteChainSelector, bytes calldata remotePoolAddress) public view returns (bool) {
    return s_remoteChainConfigs[remoteChainSelector].remotePools.contains(keccak256(remotePoolAddress));
  }

  /// @notice Gets the token address on the remote chain.
  /// @param remoteChainSelector Remote chain selector.
  /// @dev To support non-evm chains, this value is encoded into bytes
  function getRemoteToken(
    uint64 remoteChainSelector
  ) public view returns (bytes memory) {
    return s_remoteChainConfigs[remoteChainSelector].remoteTokenAddress;
  }

  /// @notice Adds a remote pool for a given chain selector. This could be due to a pool being upgraded on the remote
  /// chain. We don't simply want to replace the old pool as there could still be valid inflight messages from the old
  /// pool. This function allows for multiple pools to be added for a single chain selector.
  /// @param remoteChainSelector The remote chain selector for which the remote pool address is being added.
  /// @param remotePoolAddress The address of the new remote pool.
  function addRemotePool(uint64 remoteChainSelector, bytes calldata remotePoolAddress) external onlyOwner {
    if (!isSupportedChain(remoteChainSelector)) revert NonExistentChain(remoteChainSelector);

    _setRemotePool(remoteChainSelector, remotePoolAddress);
  }

  /// @notice Removes the remote pool address for a given chain selector.
  /// @dev All inflight txs from the remote pool will be rejected after it is removed. To ensure no loss of funds, there
  /// should be no inflight txs from the given pool.
  function removeRemotePool(uint64 remoteChainSelector, bytes calldata remotePoolAddress) external onlyOwner {
    if (!isSupportedChain(remoteChainSelector)) revert NonExistentChain(remoteChainSelector);

    if (!s_remoteChainConfigs[remoteChainSelector].remotePools.remove(keccak256(remotePoolAddress))) {
      revert InvalidRemotePoolForChain(remoteChainSelector, remotePoolAddress);
    }

    emit RemotePoolRemoved(remoteChainSelector, remotePoolAddress);
  }

  /// @inheritdoc IPoolV1
  function isSupportedChain(
    uint64 remoteChainSelector
  ) public view returns (bool) {
    return s_remoteChainSelectors.contains(remoteChainSelector);
  }

  /// @notice Get list of allowed chains
  /// @return list of chains.
  function getSupportedChains() public view returns (uint64[] memory) {
    uint256[] memory uint256ChainSelectors = s_remoteChainSelectors.values();
    uint64[] memory chainSelectors = new uint64[](uint256ChainSelectors.length);
    for (uint256 i = 0; i < uint256ChainSelectors.length; ++i) {
      chainSelectors[i] = uint64(uint256ChainSelectors[i]);
    }

    return chainSelectors;
  }

  /// @notice Sets the permissions for a list of chains selectors. Actual senders for these chains
  /// need to be allowed on the Router to interact with this pool.
  /// @param remoteChainSelectorsToRemove A list of chain selectors to remove.
  /// @param chainsToAdd A list of chains and their new permission status & rate limits. Rate limits
  /// are only used when the chain is being added through `allowed` being true.
  /// @dev Only callable by the owner
  function applyChainUpdates(
    uint64[] calldata remoteChainSelectorsToRemove,
    ChainUpdate[] calldata chainsToAdd
  ) external virtual onlyOwner {
    for (uint256 i = 0; i < remoteChainSelectorsToRemove.length; ++i) {
      uint64 remoteChainSelectorToRemove = remoteChainSelectorsToRemove[i];
      // If the chain doesn't exist, revert
      if (!s_remoteChainSelectors.remove(remoteChainSelectorToRemove)) {
        revert NonExistentChain(remoteChainSelectorToRemove);
      }

      // Remove all remote pool hashes for the chain
      bytes32[] memory remotePools = s_remoteChainConfigs[remoteChainSelectorToRemove].remotePools.values();
      for (uint256 j = 0; j < remotePools.length; ++j) {
        s_remoteChainConfigs[remoteChainSelectorToRemove].remotePools.remove(remotePools[j]);
      }

      delete s_remoteChainConfigs[remoteChainSelectorToRemove];

      emit ChainRemoved(remoteChainSelectorToRemove);
    }

    for (uint256 i = 0; i < chainsToAdd.length; ++i) {
      ChainUpdate memory newChain = chainsToAdd[i];
      RateLimiter._validateTokenBucketConfig(newChain.outboundRateLimiterConfig, false);
      RateLimiter._validateTokenBucketConfig(newChain.inboundRateLimiterConfig, false);

      if (newChain.remoteTokenAddress.length == 0) {
        revert ZeroAddressNotAllowed();
      }

      // If the chain already exists, revert
      if (!s_remoteChainSelectors.add(newChain.remoteChainSelector)) {
        revert ChainAlreadyExists(newChain.remoteChainSelector);
      }

      RemoteChainConfig storage remoteChainConfig = s_remoteChainConfigs[newChain.remoteChainSelector];

      remoteChainConfig.outboundRateLimiterConfig = RateLimiter.TokenBucket({
        rate: newChain.outboundRateLimiterConfig.rate,
        capacity: newChain.outboundRateLimiterConfig.capacity,
        tokens: newChain.outboundRateLimiterConfig.capacity,
        lastUpdated: uint32(block.timestamp),
        isEnabled: newChain.outboundRateLimiterConfig.isEnabled
      });
      remoteChainConfig.inboundRateLimiterConfig = RateLimiter.TokenBucket({
        rate: newChain.inboundRateLimiterConfig.rate,
        capacity: newChain.inboundRateLimiterConfig.capacity,
        tokens: newChain.inboundRateLimiterConfig.capacity,
        lastUpdated: uint32(block.timestamp),
        isEnabled: newChain.inboundRateLimiterConfig.isEnabled
      });
      remoteChainConfig.remoteTokenAddress = newChain.remoteTokenAddress;

      for (uint256 j = 0; j < newChain.remotePoolAddresses.length; ++j) {
        _setRemotePool(newChain.remoteChainSelector, newChain.remotePoolAddresses[j]);
      }

      emit ChainAdded(
        newChain.remoteChainSelector,
        newChain.remoteTokenAddress,
        newChain.outboundRateLimiterConfig,
        newChain.inboundRateLimiterConfig
      );
    }
  }

  /// @notice Adds a pool address to the allowed remote token pools for a particular chain.
  /// @param remoteChainSelector The remote chain selector for which the remote pool address is being added.
  /// @param remotePoolAddress The address of the new remote pool.
  function _setRemotePool(uint64 remoteChainSelector, bytes memory remotePoolAddress) internal {
    if (remotePoolAddress.length == 0) {
      revert ZeroAddressNotAllowed();
    }

    bytes32 poolHash = keccak256(remotePoolAddress);

    // Check if the pool already exists.
    if (!s_remoteChainConfigs[remoteChainSelector].remotePools.add(poolHash)) {
      revert PoolAlreadyAdded(remoteChainSelector, remotePoolAddress);
    }

    // Add the pool to the mapping to be able to un-hash it later.
    s_remotePoolAddresses[poolHash] = remotePoolAddress;

    emit RemotePoolAdded(remoteChainSelector, remotePoolAddress);
  }

  // ================================================================
  // │                        Rate limiting                         │
  // ================================================================

  /// @dev The inbound rate limits should be slightly higher than the outbound rate limits. This is because many chains
  /// finalize blocks in batches. CCIP also commits messages in batches: the commit plugin bundles multiple messages in
  /// a single merkle root.
  /// Imagine the following scenario.
  /// - Chain A has an inbound and outbound rate limit of 100 tokens capacity and 1 token per second refill rate.
  /// - Chain B has an inbound and outbound rate limit of 100 tokens capacity and 1 token per second refill rate.
  ///
  /// At time 0:
  /// - Chain A sends 100 tokens to Chain B.
  /// At time 5:
  /// - Chain A sends 5 tokens to Chain B.
  /// At time 6:
  /// The epoch that contains blocks [0-5] is finalized.
  /// Both transactions will be included in the same merkle root and become executable at the same time. This means
  /// the token pool on chain B requires a capacity of 105 to successfully execute both messages at the same time.
  /// The exact additional capacity required depends on the refill rate and the size of the source chain epochs and the
  /// CCIP round time. For simplicity, a 5-10% buffer should be sufficient in most cases.

  /// @notice Sets the rate limiter admin address.
  /// @dev Only callable by the owner.
  /// @param rateLimitAdmin The new rate limiter admin address.
  function setRateLimitAdmin(
    address rateLimitAdmin
  ) external onlyOwner {
    s_rateLimitAdmin = rateLimitAdmin;
    emit RateLimitAdminSet(rateLimitAdmin);
  }

  /// @notice Gets the rate limiter admin address.
  function getRateLimitAdmin() external view returns (address) {
    return s_rateLimitAdmin;
  }

  /// @notice Consumes outbound rate limiting capacity in this pool
  function _consumeOutboundRateLimit(uint64 remoteChainSelector, uint256 amount) internal {
    s_remoteChainConfigs[remoteChainSelector].outboundRateLimiterConfig._consume(amount, address(i_token));
  }

  /// @notice Consumes inbound rate limiting capacity in this pool
  function _consumeInboundRateLimit(uint64 remoteChainSelector, uint256 amount) internal {
    s_remoteChainConfigs[remoteChainSelector].inboundRateLimiterConfig._consume(amount, address(i_token));
  }

  /// @notice Gets the token bucket with its values for the block it was requested at.
  /// @return The token bucket.
  function getCurrentOutboundRateLimiterState(
    uint64 remoteChainSelector
  ) external view returns (RateLimiter.TokenBucket memory) {
    return s_remoteChainConfigs[remoteChainSelector].outboundRateLimiterConfig._currentTokenBucketState();
  }

  /// @notice Gets the token bucket with its values for the block it was requested at.
  /// @return The token bucket.
  function getCurrentInboundRateLimiterState(
    uint64 remoteChainSelector
  ) external view returns (RateLimiter.TokenBucket memory) {
    return s_remoteChainConfigs[remoteChainSelector].inboundRateLimiterConfig._currentTokenBucketState();
  }

  /// @notice Sets the chain rate limiter config.
  /// @param remoteChainSelector The remote chain selector for which the rate limits apply.
  /// @param outboundConfig The new outbound rate limiter config, meaning the onRamp rate limits for the given chain.
  /// @param inboundConfig The new inbound rate limiter config, meaning the offRamp rate limits for the given chain.
  function setChainRateLimiterConfig(
    uint64 remoteChainSelector,
    RateLimiter.Config memory outboundConfig,
    RateLimiter.Config memory inboundConfig
  ) external {
    if (msg.sender != s_rateLimitAdmin && msg.sender != owner()) revert Unauthorized(msg.sender);

    _setRateLimitConfig(remoteChainSelector, outboundConfig, inboundConfig);
  }

  function _setRateLimitConfig(
    uint64 remoteChainSelector,
    RateLimiter.Config memory outboundConfig,
    RateLimiter.Config memory inboundConfig
  ) internal {
    if (!isSupportedChain(remoteChainSelector)) revert NonExistentChain(remoteChainSelector);
    RateLimiter._validateTokenBucketConfig(outboundConfig, false);
    s_remoteChainConfigs[remoteChainSelector].outboundRateLimiterConfig._setTokenBucketConfig(outboundConfig);
    RateLimiter._validateTokenBucketConfig(inboundConfig, false);
    s_remoteChainConfigs[remoteChainSelector].inboundRateLimiterConfig._setTokenBucketConfig(inboundConfig);
    emit ChainConfigured(remoteChainSelector, outboundConfig, inboundConfig);
  }

  // ================================================================
  // │                           Access                             │
  // ================================================================

  /// @notice Checks whether remote chain selector is configured on this contract, and if the msg.sender
  /// is a permissioned onRamp for the given chain on the Router.
  function _onlyOnRamp(
    uint64 remoteChainSelector
  ) internal view {
    if (!isSupportedChain(remoteChainSelector)) revert ChainNotAllowed(remoteChainSelector);
    if (!(msg.sender == s_router.getOnRamp(remoteChainSelector))) revert CallerIsNotARampOnRouter(msg.sender);
  }

  /// @notice Checks whether remote chain selector is configured on this contract, and if the msg.sender
  /// is a permissioned offRamp for the given chain on the Router.
  function _onlyOffRamp(
    uint64 remoteChainSelector
  ) internal view {
    if (!isSupportedChain(remoteChainSelector)) revert ChainNotAllowed(remoteChainSelector);
    if (!s_router.isOffRamp(remoteChainSelector, msg.sender)) revert CallerIsNotARampOnRouter(msg.sender);
  }

  // ================================================================
  // │                          Allowlist                           │
  // ================================================================

  function _checkAllowList(
    address sender
  ) internal view {
    if (i_allowlistEnabled) {
      if (!s_allowlist.contains(sender)) {
        revert SenderNotAllowed(sender);
      }
    }
  }

  /// @notice Gets whether the allowlist functionality is enabled.
  /// @return true is enabled, false if not.
  function getAllowListEnabled() external view returns (bool) {
    return i_allowlistEnabled;
  }

  /// @notice Gets the allowed addresses.
  /// @return The allowed addresses.
  function getAllowList() external view returns (address[] memory) {
    return s_allowlist.values();
  }

  /// @notice Apply updates to the allow list.
  /// @param removes The addresses to be removed.
  /// @param adds The addresses to be added.
  function applyAllowListUpdates(address[] calldata removes, address[] calldata adds) external onlyOwner {
    _applyAllowListUpdates(removes, adds);
  }

  /// @notice Internal version of applyAllowListUpdates to allow for reuse in the constructor.
  function _applyAllowListUpdates(address[] memory removes, address[] memory adds) internal {
    if (!i_allowlistEnabled) revert AllowListNotEnabled();

    for (uint256 i = 0; i < removes.length; ++i) {
      address toRemove = removes[i];
      if (s_allowlist.remove(toRemove)) {
        emit AllowListRemove(toRemove);
      }
    }
    for (uint256 i = 0; i < adds.length; ++i) {
      address toAdd = adds[i];
      if (toAdd == address(0)) {
        continue;
      }
      if (s_allowlist.add(toAdd)) {
        emit AllowListAdd(toAdd);
      }
    }
  }
}

// File: src/v0.8/shared/interfaces/ITypeAndVersion.sol

pragma solidity ^0.8.0;

interface ITypeAndVersion {
  function typeAndVersion() external pure returns (string memory);
}

// File: src/v0.8/ccip/pools/USDC/IMessageTransmitter.sol

/*
 * Copyright (c) 2022, Circle Internet Financial Limited.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
pragma solidity ^0.8.0;

interface IMessageTransmitter {
  /// @notice Unlocks USDC tokens on the destination chain
  /// @param message The original message on the source chain
  ///     * Message format:
  ///     * Field                 Bytes      Type       Index
  ///     * version               4          uint32     0
  ///     * sourceDomain          4          uint32     4
  ///     * destinationDomain     4          uint32     8
  ///     * nonce                 8          uint64     12
  ///     * sender                32         bytes32    20
  ///     * recipient             32         bytes32    52
  ///     * destinationCaller     32         bytes32    84
  ///     * messageBody           dynamic    bytes      116
  /// param attestation A valid attestation is the concatenated 65-byte signature(s) of
  /// exactly `thresholdSignature` signatures, in increasing order of attester address.
  /// ***If the attester addresses recovered from signatures are not in increasing order,
  /// signature verification will fail.***
  /// If incorrect number of signatures or duplicate signatures are supplied,
  /// signature verification will fail.
  function receiveMessage(bytes calldata message, bytes calldata attestation) external returns (bool success);

  /// Returns domain of chain on which the contract is deployed.
  /// @dev immutable
  function localDomain() external view returns (uint32);

  /// Returns message format version.
  /// @dev immutable
  function version() external view returns (uint32);
}

// File: src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/extensions/draft-IERC20Permit.sol

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
  /**
   * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
   * given ``owner``'s signed approval.
   *
   * IMPORTANT: The same issues {IERC20-approve} has related to transaction
   * ordering also apply here.
   *
   * Emits an {Approval} event.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   * - `deadline` must be a timestamp in the future.
   * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
   * over the EIP712-formatted function arguments.
   * - the signature must use ``owner``'s current nonce (see {nonces}).
   *
   * For more information on the signature format, see the
   * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
   * section].
   */
  function permit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;

  /**
   * @dev Returns the current nonce for `owner`. This value must be
   * included whenever a signature is generated for {permit}.
   *
   * Every successful call to {permit} increases ``owner``'s nonce by one. This
   * prevents a signature from being used multiple times.
   */
  function nonces(address owner) external view returns (uint256);

  /**
   * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
   */
  // solhint-disable-next-line func-name-mixedcase
  function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// File: src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/utils/Address.sol

// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
  /**
   * @dev Returns true if `account` is a contract.
   *
   * [IMPORTANT]
   * ====
   * It is unsafe to assume that an address for which this function returns
   * false is an externally-owned account (EOA) and not a contract.
   *
   * Among others, `isContract` will return false for the following
   * types of addresses:
   *
   *  - an externally-owned account
   *  - a contract in construction
   *  - an address where a contract will be created
   *  - an address where a contract lived, but was destroyed
   * ====
   *
   * [IMPORTANT]
   * ====
   * You shouldn't rely on `isContract` to protect against flash loan attacks!
   *
   * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
   * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
   * constructor.
   * ====
   */
  function isContract(address account) internal view returns (bool) {
    // This method relies on extcodesize/address.code.length, which returns 0
    // for contracts in construction, since the code is only stored at the end
    // of the constructor execution.

    return account.code.length > 0;
  }

  /**
   * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
   * `recipient`, forwarding all available gas and reverting on errors.
   *
   * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
   * of certain opcodes, possibly making contracts go over the 2300 gas limit
   * imposed by `transfer`, making them unable to receive funds via
   * `transfer`. {sendValue} removes this limitation.
   *
   * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
   *
   * IMPORTANT: because control is transferred to `recipient`, care must be
   * taken to not create reentrancy vulnerabilities. Consider using
   * {ReentrancyGuard} or the
   * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
   */
  function sendValue(address payable recipient, uint256 amount) internal {
    require(address(this).balance >= amount, "Address: insufficient balance");

    (bool success, ) = recipient.call{value: amount}("");
    require(success, "Address: unable to send value, recipient may have reverted");
  }

  /**
   * @dev Performs a Solidity function call using a low level `call`. A
   * plain `call` is an unsafe replacement for a function call: use this
   * function instead.
   *
   * If `target` reverts with a revert reason, it is bubbled up by this
   * function (like regular Solidity function calls).
   *
   * Returns the raw returned data. To convert to the expected return value,
   * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
   *
   * Requirements:
   *
   * - `target` must be a contract.
   * - calling `target` with `data` must not revert.
   *
   * _Available since v3.1._
   */
  function functionCall(address target, bytes memory data) internal returns (bytes memory) {
    return functionCallWithValue(target, data, 0, "Address: low-level call failed");
  }

  /**
   * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
   * `errorMessage` as a fallback revert reason when `target` reverts.
   *
   * _Available since v3.1._
   */
  function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
    return functionCallWithValue(target, data, 0, errorMessage);
  }

  /**
   * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
   * but also transferring `value` wei to `target`.
   *
   * Requirements:
   *
   * - the calling contract must have an ETH balance of at least `value`.
   * - the called Solidity function must be `payable`.
   *
   * _Available since v3.1._
   */
  function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
    return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
  }

  /**
   * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
   * with `errorMessage` as a fallback revert reason when `target` reverts.
   *
   * _Available since v3.1._
   */
  function functionCallWithValue(
    address target,
    bytes memory data,
    uint256 value,
    string memory errorMessage
  ) internal returns (bytes memory) {
    require(address(this).balance >= value, "Address: insufficient balance for call");
    (bool success, bytes memory returndata) = target.call{value: value}(data);
    return verifyCallResultFromTarget(target, success, returndata, errorMessage);
  }

  /**
   * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
   * but performing a static call.
   *
   * _Available since v3.3._
   */
  function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
    return functionStaticCall(target, data, "Address: low-level static call failed");
  }

  /**
   * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
   * but performing a static call.
   *
   * _Available since v3.3._
   */
  function functionStaticCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal view returns (bytes memory) {
    (bool success, bytes memory returndata) = target.staticcall(data);
    return verifyCallResultFromTarget(target, success, returndata, errorMessage);
  }

  /**
   * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
   * but performing a delegate call.
   *
   * _Available since v3.4._
   */
  function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
    return functionDelegateCall(target, data, "Address: low-level delegate call failed");
  }

  /**
   * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
   * but performing a delegate call.
   *
   * _Available since v3.4._
   */
  function functionDelegateCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal returns (bytes memory) {
    (bool success, bytes memory returndata) = target.delegatecall(data);
    return verifyCallResultFromTarget(target, success, returndata, errorMessage);
  }

  /**
   * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
   * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
   *
   * _Available since v4.8._
   */
  function verifyCallResultFromTarget(
    address target,
    bool success,
    bytes memory returndata,
    string memory errorMessage
  ) internal view returns (bytes memory) {
    if (success) {
      if (returndata.length == 0) {
        // only check isContract if the call was successful and the return data is empty
        // otherwise we already know that it was a contract
        require(isContract(target), "Address: call to non-contract");
      }
      return returndata;
    } else {
      _revert(returndata, errorMessage);
    }
  }

  /**
   * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
   * revert reason or using the provided one.
   *
   * _Available since v4.3._
   */
  function verifyCallResult(
    bool success,
    bytes memory returndata,
    string memory errorMessage
  ) internal pure returns (bytes memory) {
    if (success) {
      return returndata;
    } else {
      _revert(returndata, errorMessage);
    }
  }

  function _revert(bytes memory returndata, string memory errorMessage) private pure {
    // Look for revert reason and bubble it up if present
    if (returndata.length > 0) {
      // The easiest way to bubble the revert reason is using memory via assembly
      /// @solidity memory-safe-assembly
      assembly {
        let returndata_size := mload(returndata)
        revert(add(32, returndata), returndata_size)
      }
    } else {
      revert(errorMessage);
    }
  }
}

// File: src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/utils/SafeERC20.sol

// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;





/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  using Address for address;

  function safeTransfer(IERC20 token, address to, uint256 value) internal {
    _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
  }

  function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
    _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
  }

  /**
   * @dev Deprecated. This function has issues similar to the ones found in
   * {IERC20-approve}, and its usage is discouraged.
   *
   * Whenever possible, use {safeIncreaseAllowance} and
   * {safeDecreaseAllowance} instead.
   */
  function safeApprove(IERC20 token, address spender, uint256 value) internal {
    // safeApprove should only be called when setting an initial allowance,
    // or when resetting it to zero. To increase and decrease it, use
    // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
    require(
      (value == 0) || (token.allowance(address(this), spender) == 0),
      "SafeERC20: approve from non-zero to non-zero allowance"
    );
    _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
  }

  function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
    uint256 newAllowance = token.allowance(address(this), spender) + value;
    _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
  }

  function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
    unchecked {
      uint256 oldAllowance = token.allowance(address(this), spender);
      require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
      uint256 newAllowance = oldAllowance - value;
      _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
  }

  function safePermit(
    IERC20Permit token,
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) internal {
    uint256 nonceBefore = token.nonces(owner);
    token.permit(owner, spender, value, deadline, v, r, s);
    uint256 nonceAfter = token.nonces(owner);
    require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
  }

  /**
   * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
   * on the return value: the return value is optional (but if data is returned, it must not be false).
   * @param token The token targeted by the call.
   * @param data The call data (encoded using abi.encode or one of its variants).
   */
  function _callOptionalReturn(IERC20 token, bytes memory data) private {
    // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
    // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
    // the target address contains contract code and also asserts for success in the low-level call.

    bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
    if (returndata.length > 0) {
      // Return data is optional
      require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }
  }
}

// File: src/v0.8/ccip/pools/USDC/USDCTokenPool.sol

pragma solidity 0.8.24;











/// @notice This pool mints and burns USDC tokens through the Cross Chain Transfer
/// Protocol (CCTP).
contract USDCTokenPool is TokenPool, ITypeAndVersion {
  using SafeERC20 for IERC20;

  event DomainsSet(DomainUpdate[]);
  event ConfigSet(address tokenMessenger);

  error UnknownDomain(uint64 domain);
  error UnlockingUSDCFailed();
  error InvalidConfig();
  error InvalidDomain(DomainUpdate domain);
  error InvalidMessageVersion(uint32 version);
  error InvalidTokenMessengerVersion(uint32 version);
  error InvalidNonce(uint64 expected, uint64 got);
  error InvalidSourceDomain(uint32 expected, uint32 got);
  error InvalidDestinationDomain(uint32 expected, uint32 got);
  error InvalidReceiver(bytes receiver);

  // This data is supplied from offchain and contains everything needed
  // to receive the USDC tokens.
  struct MessageAndAttestation {
    bytes message;
    bytes attestation;
  }

  // A domain is a USDC representation of a chain.
  struct DomainUpdate {
    bytes32 allowedCaller; //       Address allowed to mint on the domain
    uint32 domainIdentifier; // ──╮ Unique domain ID
    uint64 destChainSelector; //  │ The destination chain for this domain
    bool enabled; // ─────────────╯ Whether the domain is enabled
  }

  struct SourceTokenDataPayload {
    uint64 nonce;
    uint32 sourceDomain;
  }

  string public constant override typeAndVersion = "USDCTokenPool 1.5.1";

  // We restrict to the first version. New pool may be required for subsequent versions.
  uint32 public constant SUPPORTED_USDC_VERSION = 0;

  // The local USDC config
  ITokenMessenger public immutable i_tokenMessenger;
  IMessageTransmitter public immutable i_messageTransmitter;
  uint32 public immutable i_localDomainIdentifier;

  /// A domain is a USDC representation of a destination chain.
  /// @dev Zero is a valid domain identifier.
  /// @dev The address to mint on the destination chain is the corresponding USDC pool.
  struct Domain {
    bytes32 allowedCaller; //      Address allowed to mint on the domain
    uint32 domainIdentifier; // ─╮ Unique domain ID
    bool enabled; // ────────────╯ Whether the domain is enabled
  }

  // A mapping of CCIP chain identifiers to destination domains
  mapping(uint64 chainSelector => Domain CCTPDomain) private s_chainToDomain;

  constructor(
    ITokenMessenger tokenMessenger,
    IERC20 token,
    address[] memory allowlist,
    address rmnProxy,
    address router
  ) TokenPool(token, 6, allowlist, rmnProxy, router) {
    if (address(tokenMessenger) == address(0)) revert InvalidConfig();
    IMessageTransmitter transmitter = IMessageTransmitter(tokenMessenger.localMessageTransmitter());
    uint32 transmitterVersion = transmitter.version();
    if (transmitterVersion != SUPPORTED_USDC_VERSION) revert InvalidMessageVersion(transmitterVersion);
    uint32 tokenMessengerVersion = tokenMessenger.messageBodyVersion();
    if (tokenMessengerVersion != SUPPORTED_USDC_VERSION) revert InvalidTokenMessengerVersion(tokenMessengerVersion);

    i_tokenMessenger = tokenMessenger;
    i_messageTransmitter = transmitter;
    i_localDomainIdentifier = transmitter.localDomain();
    i_token.safeIncreaseAllowance(address(i_tokenMessenger), type(uint256).max);
    emit ConfigSet(address(tokenMessenger));
  }

  /// @notice Burn the token in the pool
  /// @dev emits ITokenMessenger.DepositForBurn
  /// @dev Assumes caller has validated destinationReceiver
  function lockOrBurn(
    Pool.LockOrBurnInV1 calldata lockOrBurnIn
  ) public virtual override returns (Pool.LockOrBurnOutV1 memory) {
    _validateLockOrBurn(lockOrBurnIn);

    Domain memory domain = s_chainToDomain[lockOrBurnIn.remoteChainSelector];
    if (!domain.enabled) revert UnknownDomain(lockOrBurnIn.remoteChainSelector);

    if (lockOrBurnIn.receiver.length != 32) {
      revert InvalidReceiver(lockOrBurnIn.receiver);
    }
    bytes32 decodedReceiver = abi.decode(lockOrBurnIn.receiver, (bytes32));

    // Since this pool is the msg sender of the CCTP transaction, only this contract
    // is able to call replaceDepositForBurn. Since this contract does not implement
    // replaceDepositForBurn, the tokens cannot be maliciously re-routed to another address.
    uint64 nonce = i_tokenMessenger.depositForBurnWithCaller(
      lockOrBurnIn.amount, domain.domainIdentifier, decodedReceiver, address(i_token), domain.allowedCaller
    );

    emit Burned(msg.sender, lockOrBurnIn.amount);

    return Pool.LockOrBurnOutV1({
      destTokenAddress: getRemoteToken(lockOrBurnIn.remoteChainSelector),
      destPoolData: abi.encode(SourceTokenDataPayload({nonce: nonce, sourceDomain: i_localDomainIdentifier}))
    });
  }

  /// @notice Mint tokens from the pool to the recipient
  /// * sourceTokenData is part of the verified message and passed directly from
  /// the offRamp so it is guaranteed to be what the lockOrBurn pool released on the
  /// source chain. It contains (nonce, sourceDomain) which is guaranteed by CCTP
  /// to be unique.
  /// * offchainTokenData is untrusted (can be supplied by manual execution), but we assert
  /// that (nonce, sourceDomain) is equal to the message's (nonce, sourceDomain) and
  /// receiveMessage will assert that Attestation contains a valid attestation signature
  /// for that message, including its (nonce, sourceDomain). This way, the only
  /// non-reverting offchainTokenData that can be supplied is a valid attestation for the
  /// specific message that was sent on source.
  function releaseOrMint(
    Pool.ReleaseOrMintInV1 calldata releaseOrMintIn
  ) public virtual override returns (Pool.ReleaseOrMintOutV1 memory) {
    _validateReleaseOrMint(releaseOrMintIn);
    SourceTokenDataPayload memory sourceTokenDataPayload =
      abi.decode(releaseOrMintIn.sourcePoolData, (SourceTokenDataPayload));
    MessageAndAttestation memory msgAndAttestation =
      abi.decode(releaseOrMintIn.offchainTokenData, (MessageAndAttestation));

    _validateMessage(msgAndAttestation.message, sourceTokenDataPayload);

    if (!i_messageTransmitter.receiveMessage(msgAndAttestation.message, msgAndAttestation.attestation)) {
      revert UnlockingUSDCFailed();
    }

    emit Minted(msg.sender, releaseOrMintIn.receiver, releaseOrMintIn.amount);
    return Pool.ReleaseOrMintOutV1({destinationAmount: releaseOrMintIn.amount});
  }

  /// @notice Validates the USDC encoded message against the given parameters.
  /// @param usdcMessage The USDC encoded message
  /// @param sourceTokenData The expected source chain token data to check against
  /// @dev Only supports version SUPPORTED_USDC_VERSION of the CCTP message format
  /// @dev Message format for USDC:
  ///     * Field                 Bytes      Type       Index
  ///     * version               4          uint32     0
  ///     * sourceDomain          4          uint32     4
  ///     * destinationDomain     4          uint32     8
  ///     * nonce                 8          uint64     12
  ///     * sender                32         bytes32    20
  ///     * recipient             32         bytes32    52
  ///     * destinationCaller     32         bytes32    84
  ///     * messageBody           dynamic    bytes      116
  function _validateMessage(bytes memory usdcMessage, SourceTokenDataPayload memory sourceTokenData) internal view {
    uint32 version;
    // solhint-disable-next-line no-inline-assembly
    assembly {
      // We truncate using the datatype of the version variable, meaning
      // we will only be left with the first 4 bytes of the message.
      version := mload(add(usdcMessage, 4)) // 0 + 4 = 4
    }
    // This token pool only supports version 0 of the CCTP message format
    // We check the version prior to loading the rest of the message
    // to avoid unexpected reverts due to out-of-bounds reads.
    if (version != SUPPORTED_USDC_VERSION) revert InvalidMessageVersion(version);

    uint32 sourceDomain;
    uint32 destinationDomain;
    uint64 nonce;

    // solhint-disable-next-line no-inline-assembly
    assembly {
      sourceDomain := mload(add(usdcMessage, 8)) // 4 + 4 = 8
      destinationDomain := mload(add(usdcMessage, 12)) // 8 + 4 = 12
      nonce := mload(add(usdcMessage, 20)) // 12 + 8 = 20
    }

    if (sourceDomain != sourceTokenData.sourceDomain) {
      revert InvalidSourceDomain(sourceTokenData.sourceDomain, sourceDomain);
    }
    if (destinationDomain != i_localDomainIdentifier) {
      revert InvalidDestinationDomain(i_localDomainIdentifier, destinationDomain);
    }
    if (nonce != sourceTokenData.nonce) revert InvalidNonce(sourceTokenData.nonce, nonce);
  }

  // ================================================================
  // │                           Config                             │
  // ================================================================

  /// @notice Gets the CCTP domain for a given CCIP chain selector.
  function getDomain(
    uint64 chainSelector
  ) external view returns (Domain memory) {
    return s_chainToDomain[chainSelector];
  }

  /// @notice Sets the CCTP domain for a CCIP chain selector.
  /// @dev Must verify mapping of selectors -> (domain, caller) offchain.
  function setDomains(
    DomainUpdate[] calldata domains
  ) external onlyOwner {
    for (uint256 i = 0; i < domains.length; ++i) {
      DomainUpdate memory domain = domains[i];
      if (domain.allowedCaller == bytes32(0) || domain.destChainSelector == 0) revert InvalidDomain(domain);

      s_chainToDomain[domain.destChainSelector] = Domain({
        domainIdentifier: domain.domainIdentifier,
        allowedCaller: domain.allowedCaller,
        enabled: domain.enabled
      });
    }
    emit DomainsSet(domains);
  }
}

// File: src/v0.8/shared/token/ERC20/IBurnMintERC20.sol

pragma solidity ^0.8.0;



interface IBurnMintERC20 is IERC20 {
  /// @notice Mints new tokens for a given address.
  /// @param account The address to mint the new tokens to.
  /// @param amount The number of tokens to be minted.
  /// @dev this function increases the total supply.
  function mint(address account, uint256 amount) external;

  /// @notice Burns tokens from the sender.
  /// @param amount The number of tokens to be burned.
  /// @dev this function decreases the total supply.
  function burn(uint256 amount) external;

  /// @notice Burns tokens from a given address..
  /// @param account The address to burn tokens from.
  /// @param amount The number of tokens to be burned.
  /// @dev this function decreases the total supply.
  function burn(address account, uint256 amount) external;

  /// @notice Burns tokens from a given address..
  /// @param account The address to burn tokens from.
  /// @param amount The number of tokens to be burned.
  /// @dev this function decreases the total supply.
  function burnFrom(address account, uint256 amount) external;
}

// File: src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/utils/structs/EnumerableSet.sol

// OpenZeppelin Contracts (last updated v4.8.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
 */
library EnumerableSet {
  // To implement this library for multiple types with as little code
  // repetition as possible, we write it in terms of a generic Set type with
  // bytes32 values.
  // The Set implementation uses private functions, and user-facing
  // implementations (such as AddressSet) are just wrappers around the
  // underlying Set.
  // This means that we can only create new EnumerableSets for types that fit
  // in bytes32.

  struct Set {
    // Storage of set values
    bytes32[] _values;
    // Position of the value in the `values` array, plus 1 because index 0
    // means a value is not in the set.
    mapping(bytes32 => uint256) _indexes;
  }

  /**
   * @dev Add a value to a set. O(1).
   *
   * Returns true if the value was added to the set, that is if it was not
   * already present.
   */
  function _add(Set storage set, bytes32 value) private returns (bool) {
    if (!_contains(set, value)) {
      set._values.push(value);
      // The value is stored at length-1, but we add 1 to all indexes
      // and use 0 as a sentinel value
      set._indexes[value] = set._values.length;
      return true;
    } else {
      return false;
    }
  }

  /**
   * @dev Removes a value from a set. O(1).
   *
   * Returns true if the value was removed from the set, that is if it was
   * present.
   */
  function _remove(Set storage set, bytes32 value) private returns (bool) {
    // We read and store the value's index to prevent multiple reads from the same storage slot
    uint256 valueIndex = set._indexes[value];

    if (valueIndex != 0) {
      // Equivalent to contains(set, value)
      // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
      // the array, and then remove the last element (sometimes called as 'swap and pop').
      // This modifies the order of the array, as noted in {at}.

      uint256 toDeleteIndex = valueIndex - 1;
      uint256 lastIndex = set._values.length - 1;

      if (lastIndex != toDeleteIndex) {
        bytes32 lastValue = set._values[lastIndex];

        // Move the last value to the index where the value to delete is
        set._values[toDeleteIndex] = lastValue;
        // Update the index for the moved value
        set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
      }

      // Delete the slot where the moved value was stored
      set._values.pop();

      // Delete the index for the deleted slot
      delete set._indexes[value];

      return true;
    } else {
      return false;
    }
  }

  /**
   * @dev Returns true if the value is in the set. O(1).
   */
  function _contains(Set storage set, bytes32 value) private view returns (bool) {
    return set._indexes[value] != 0;
  }

  /**
   * @dev Returns the number of values on the set. O(1).
   */
  function _length(Set storage set) private view returns (uint256) {
    return set._values.length;
  }

  /**
   * @dev Returns the value stored at position `index` in the set. O(1).
   *
   * Note that there are no guarantees on the ordering of values inside the
   * array, and it may change when more values are added or removed.
   *
   * Requirements:
   *
   * - `index` must be strictly less than {length}.
   */
  function _at(Set storage set, uint256 index) private view returns (bytes32) {
    return set._values[index];
  }

  /**
   * @dev Return the entire set in an array
   *
   * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
   * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
   * this function has an unbounded cost, and using it as part of a state-changing function may render the function
   * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
   */
  function _values(Set storage set) private view returns (bytes32[] memory) {
    return set._values;
  }

  // Bytes32Set

  struct Bytes32Set {
    Set _inner;
  }

  /**
   * @dev Add a value to a set. O(1).
   *
   * Returns true if the value was added to the set, that is if it was not
   * already present.
   */
  function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
    return _add(set._inner, value);
  }

  /**
   * @dev Removes a value from a set. O(1).
   *
   * Returns true if the value was removed from the set, that is if it was
   * present.
   */
  function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
    return _remove(set._inner, value);
  }

  /**
   * @dev Returns true if the value is in the set. O(1).
   */
  function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
    return _contains(set._inner, value);
  }

  /**
   * @dev Returns the number of values in the set. O(1).
   */
  function length(Bytes32Set storage set) internal view returns (uint256) {
    return _length(set._inner);
  }

  /**
   * @dev Returns the value stored at position `index` in the set. O(1).
   *
   * Note that there are no guarantees on the ordering of values inside the
   * array, and it may change when more values are added or removed.
   *
   * Requirements:
   *
   * - `index` must be strictly less than {length}.
   */
  function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
    return _at(set._inner, index);
  }

  /**
   * @dev Return the entire set in an array
   *
   * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
   * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
   * this function has an unbounded cost, and using it as part of a state-changing function may render the function
   * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
   */
  function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
    bytes32[] memory store = _values(set._inner);
    bytes32[] memory result;

    /// @solidity memory-safe-assembly
    assembly {
      result := store
    }

    return result;
  }

  // AddressSet

  struct AddressSet {
    Set _inner;
  }

  /**
   * @dev Add a value to a set. O(1).
   *
   * Returns true if the value was added to the set, that is if it was not
   * already present.
   */
  function add(AddressSet storage set, address value) internal returns (bool) {
    return _add(set._inner, bytes32(uint256(uint160(value))));
  }

  /**
   * @dev Removes a value from a set. O(1).
   *
   * Returns true if the value was removed from the set, that is if it was
   * present.
   */
  function remove(AddressSet storage set, address value) internal returns (bool) {
    return _remove(set._inner, bytes32(uint256(uint160(value))));
  }

  /**
   * @dev Returns true if the value is in the set. O(1).
   */
  function contains(AddressSet storage set, address value) internal view returns (bool) {
    return _contains(set._inner, bytes32(uint256(uint160(value))));
  }

  /**
   * @dev Returns the number of values in the set. O(1).
   */
  function length(AddressSet storage set) internal view returns (uint256) {
    return _length(set._inner);
  }

  /**
   * @dev Returns the value stored at position `index` in the set. O(1).
   *
   * Note that there are no guarantees on the ordering of values inside the
   * array, and it may change when more values are added or removed.
   *
   * Requirements:
   *
   * - `index` must be strictly less than {length}.
   */
  function at(AddressSet storage set, uint256 index) internal view returns (address) {
    return address(uint160(uint256(_at(set._inner, index))));
  }

  /**
   * @dev Return the entire set in an array
   *
   * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
   * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
   * this function has an unbounded cost, and using it as part of a state-changing function may render the function
   * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
   */
  function values(AddressSet storage set) internal view returns (address[] memory) {
    bytes32[] memory store = _values(set._inner);
    address[] memory result;

    /// @solidity memory-safe-assembly
    assembly {
      result := store
    }

    return result;
  }

  // UintSet

  struct UintSet {
    Set _inner;
  }

  /**
   * @dev Add a value to a set. O(1).
   *
   * Returns true if the value was added to the set, that is if it was not
   * already present.
   */
  function add(UintSet storage set, uint256 value) internal returns (bool) {
    return _add(set._inner, bytes32(value));
  }

  /**
   * @dev Removes a value from a set. O(1).
   *
   * Returns true if the value was removed from the set, that is if it was
   * present.
   */
  function remove(UintSet storage set, uint256 value) internal returns (bool) {
    return _remove(set._inner, bytes32(value));
  }

  /**
   * @dev Returns true if the value is in the set. O(1).
   */
  function contains(UintSet storage set, uint256 value) internal view returns (bool) {
    return _contains(set._inner, bytes32(value));
  }

  /**
   * @dev Returns the number of values in the set. O(1).
   */
  function length(UintSet storage set) internal view returns (uint256) {
    return _length(set._inner);
  }

  /**
   * @dev Returns the value stored at position `index` in the set. O(1).
   *
   * Note that there are no guarantees on the ordering of values inside the
   * array, and it may change when more values are added or removed.
   *
   * Requirements:
   *
   * - `index` must be strictly less than {length}.
   */
  function at(UintSet storage set, uint256 index) internal view returns (uint256) {
    return uint256(_at(set._inner, index));
  }

  /**
   * @dev Return the entire set in an array
   *
   * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
   * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
   * this function has an unbounded cost, and using it as part of a state-changing function may render the function
   * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
   */
  function values(UintSet storage set) internal view returns (uint256[] memory) {
    bytes32[] memory store = _values(set._inner);
    uint256[] memory result;

    /// @solidity memory-safe-assembly
    assembly {
      result := store
    }

    return result;
  }
}

// File: src/v0.8/ccip/pools/USDC/USDCBridgeMigrator.sol

pragma solidity 0.8.24;






/// @notice Allows migration of a lane in a token pool from Lock/Release to CCTP supported Burn/Mint. Contract
/// functionality is based on hard requirements defined by Circle to allow for future CCTP compatibility
/// https://github.com/circlefin/stablecoin-evm/blob/master/doc/bridged_USDC_standard.md
abstract contract USDCBridgeMigrator is Ownable2StepMsgSender {
  using EnumerableSet for EnumerableSet.UintSet;

  event CCTPMigrationProposed(uint64 remoteChainSelector);
  event CCTPMigrationExecuted(uint64 remoteChainSelector, uint256 USDCBurned);
  event CCTPMigrationCancelled(uint64 existingProposalSelector);
  event CircleMigratorAddressSet(address migratorAddress);
  event TokensExcludedFromBurn(
    uint64 indexed remoteChainSelector, uint256 amount, uint256 burnableAmountAfterExclusion
  );

  error onlyCircle();
  error ExistingMigrationProposal();
  error NoMigrationProposalPending();
  error InvalidChainSelector();

  IBurnMintERC20 private immutable i_USDC;

  address internal s_circleUSDCMigrator;
  uint64 internal s_proposedUSDCMigrationChain;

  mapping(uint64 chainSelector => uint256 lockedBalance) internal s_lockedTokensByChainSelector;
  mapping(uint64 remoteChainSelector => uint256 excludedTokens) internal s_tokensExcludedFromBurn;

  mapping(uint64 chainSelector => bool shouldUseLockRelease) internal s_shouldUseLockRelease;

  EnumerableSet.UintSet internal s_migratedChains;

  constructor(
    address token
  ) {
    i_USDC = IBurnMintERC20(token);
  }

  /// @notice Burn USDC locked for a specific lane so that destination USDC can be converted from
  /// non-canonical to canonical USDC.
  /// @dev This function can only be called by an address specified by the owner to be controlled by circle
  /// @dev proposeCCTPMigration must be called first on an approved lane to execute properly.
  /// @dev This function signature should NEVER be overwritten, otherwise it will be unable to be called by
  /// circle to properly migrate USDC over to CCTP.
  function burnLockedUSDC() external {
    if (msg.sender != s_circleUSDCMigrator) revert onlyCircle();
    if (s_proposedUSDCMigrationChain == 0) revert NoMigrationProposalPending();

    uint64 burnChainSelector = s_proposedUSDCMigrationChain;

    // Burnable tokens is the total locked minus the amount excluded from burn
    uint256 tokensToBurn =
      s_lockedTokensByChainSelector[burnChainSelector] - s_tokensExcludedFromBurn[burnChainSelector];

    // Even though USDC is a trusted call, ensure CEI by updating state first
    delete s_lockedTokensByChainSelector[burnChainSelector];
    delete s_proposedUSDCMigrationChain;

    // This should only be called after this contract has been granted a "zero allowance minter role" on USDC by Circle,
    // otherwise the call will revert. Executing this burn will functionally convert all USDC on the destination chain
    // to canonical USDC by removing the canonical USDC backing it from circulation.
    i_USDC.burn(tokensToBurn);

    // Disable L/R automatically on burned chain and enable CCTP
    delete s_shouldUseLockRelease[burnChainSelector];

    s_migratedChains.add(burnChainSelector);

    emit CCTPMigrationExecuted(burnChainSelector, tokensToBurn);
  }

  /// @notice Propose a destination chain to migrate from lock/release mechanism to CCTP enabled burn/mint
  /// through a Circle controlled burn.
  /// @param remoteChainSelector the CCIP specific selector for the remote chain currently using a
  /// non-canonical form of USDC which they wish to update to canonical. Function will revert if an existing migration
  /// proposal is already in progress.
  /// @dev This function can only be called by the owner
  function proposeCCTPMigration(
    uint64 remoteChainSelector
  ) external onlyOwner {
    // Prevent overwriting existing migration proposals until the current one is finished
    if (s_proposedUSDCMigrationChain != 0) revert ExistingMigrationProposal();

    // Ensure that the chain is currently using lock/release and not CCTP
    if (!s_shouldUseLockRelease[remoteChainSelector]) revert InvalidChainSelector();

    s_proposedUSDCMigrationChain = remoteChainSelector;

    emit CCTPMigrationProposed(remoteChainSelector);
  }

  /// @notice Cancel an existing proposal to migrate a lane to CCTP.
  /// @notice This function will revert if no proposal is currently in progress.
  function cancelExistingCCTPMigrationProposal() external onlyOwner {
    if (s_proposedUSDCMigrationChain == 0) revert NoMigrationProposalPending();

    uint64 currentProposalChainSelector = s_proposedUSDCMigrationChain;
    delete s_proposedUSDCMigrationChain;

    // If a migration is cancelled, the tokens excluded from burn should be reset, and must be manually
    // re-excluded if the proposal is re-proposed in the future
    delete s_tokensExcludedFromBurn[currentProposalChainSelector];

    emit CCTPMigrationCancelled(currentProposalChainSelector);
  }

  /// @notice retrieve the chain selector for an ongoing CCTP migration in progress.
  /// @return uint64 the chain selector of the lane to be migrated. Will be zero if no proposal currently
  /// exists
  function getCurrentProposedCCTPChainMigration() public view returns (uint64) {
    return s_proposedUSDCMigrationChain;
  }

  /// @notice Set the address of the circle-controlled wallet which will execute a CCTP lane migration
  /// @dev The function should only be invoked once the address has been confirmed by Circle prior to
  /// chain expansion.
  function setCircleMigratorAddress(
    address migrator
  ) external onlyOwner {
    s_circleUSDCMigrator = migrator;

    emit CircleMigratorAddressSet(migrator);
  }

  /// @notice Retrieve the amount of canonical USDC locked into this lane and minted on the destination
  /// @param remoteChainSelector the CCIP specific destination chain implementing a mintable and
  /// non-canonical form of USDC at present.
  /// @return uint256 the amount of USDC locked into the specified lane. If non-zero, the number
  /// should match the current circulating supply of USDC on the destination chain
  function getLockedTokensForChain(
    uint64 remoteChainSelector
  ) public view returns (uint256) {
    return s_lockedTokensByChainSelector[remoteChainSelector];
  }

  /// @notice Exclude tokens to be burned in a CCTP-migration because the amount are locked in an undelivered message.
  /// @dev When a message is sitting in manual execution from the L/R chain, those tokens need to be excluded from
  /// being burned in a CCTP-migration otherwise the message will never be able to be delivered due to it not having
  /// an attestation on the source-chain to mint. In that instance it should use provided liquidity that was designated
  /// @dev This function should ONLY be called on the home chain, where tokens are locked, NOT on the remote chain
  /// and strict scrutiny should be applied to ensure that the amount of tokens excluded is accurate.
  function excludeTokensFromBurn(uint64 remoteChainSelector, uint256 amount) external onlyOwner {
    if (s_proposedUSDCMigrationChain != remoteChainSelector) revert NoMigrationProposalPending();

    s_tokensExcludedFromBurn[remoteChainSelector] += amount;

    uint256 burnableAmountAfterExclusion =
      s_lockedTokensByChainSelector[remoteChainSelector] - s_tokensExcludedFromBurn[remoteChainSelector];

    emit TokensExcludedFromBurn(remoteChainSelector, amount, burnableAmountAfterExclusion);
  }

  /// @notice Get the amount of tokens excluded from being burned in a CCTP-migration
  /// @dev The sum of locked tokens and excluded tokens should equal the supply of the token on the remote chain
  /// @param remoteChainSelector The chain for which the excluded tokens are being queried
  /// @return uint256 amount of tokens excluded from being burned in a CCTP-migration
  function getExcludedTokensByChain(
    uint64 remoteChainSelector
  ) external view returns (uint256) {
    return s_tokensExcludedFromBurn[remoteChainSelector];
  }
}

// File: src/v0.8/ccip/pools/USDC/HybridLockReleaseUSDCTokenPool.sol

pragma solidity 0.8.24;














// bytes4(keccak256("NO_CCTP_USE_LOCK_RELEASE"))
bytes4 constant LOCK_RELEASE_FLAG = 0xfa7c07de;

/// @notice A token pool for USDC which uses CCTP for supported chains and Lock/Release for all others
/// @dev The functionality from LockReleaseTokenPool.sol has been duplicated due to lack of compiler support for shared
/// constructors between parents
/// @dev The primary token mechanism in this pool is Burn/Mint with CCTP, with Lock/Release as the
/// secondary, opt in mechanism for chains not currently supporting CCTP.
contract HybridLockReleaseUSDCTokenPool is USDCTokenPool, USDCBridgeMigrator {
  using SafeERC20 for IERC20;
  using EnumerableSet for EnumerableSet.UintSet;

  event LiquidityTransferred(address indexed from, uint64 indexed remoteChainSelector, uint256 amount);
  event LiquidityProviderSet(
    address indexed oldProvider, address indexed newProvider, uint64 indexed remoteChainSelector
  );

  event LockReleaseEnabled(uint64 indexed remoteChainSelector);
  event LockReleaseDisabled(uint64 indexed remoteChainSelector);

  error LanePausedForCCTPMigration(uint64 remoteChainSelector);
  error TokenLockingNotAllowedAfterMigration(uint64 remoteChainSelector);

  /// @notice The address of the liquidity provider for a specific chain.
  /// External liquidity is not required when there is one canonical token deployed to a chain,
  /// and CCIP is facilitating mint/burn on all the other chains, in which case the invariant
  /// balanceOf(pool) on home chain >= sum(totalSupply(mint/burn "wrapped" token) on all remote chains) should always hold
  mapping(uint64 remoteChainSelector => address liquidityProvider) internal s_liquidityProvider;

  constructor(
    ITokenMessenger tokenMessenger,
    IERC20 token,
    address[] memory allowlist,
    address rmnProxy,
    address router
  ) USDCTokenPool(tokenMessenger, token, allowlist, rmnProxy, router) USDCBridgeMigrator(address(token)) {}

  // ================================================================
  // │                   Incoming/Outgoing Mechanisms               |
  // ================================================================

  /// @notice Locks the token in the pool
  /// @dev The _validateLockOrBurn check is an essential security check
  function lockOrBurn(
    Pool.LockOrBurnInV1 calldata lockOrBurnIn
  ) public virtual override returns (Pool.LockOrBurnOutV1 memory) {
    // // If the alternative mechanism (L/R) for chains which have it enabled
    if (!shouldUseLockRelease(lockOrBurnIn.remoteChainSelector)) {
      return super.lockOrBurn(lockOrBurnIn);
    }

    // Circle requires a supply-lock to prevent outgoing messages once the migration process begins.
    // This prevents new outgoing messages once the migration has begun to ensure any the procedure runs as expected
    if (s_proposedUSDCMigrationChain == lockOrBurnIn.remoteChainSelector) {
      revert LanePausedForCCTPMigration(s_proposedUSDCMigrationChain);
    }

    return _lockReleaseOutgoingMessage(lockOrBurnIn);
  }

  /// @notice Release tokens from the pool to the recipient
  /// @dev The _validateReleaseOrMint check is an essential security check
  function releaseOrMint(
    Pool.ReleaseOrMintInV1 calldata releaseOrMintIn
  ) public virtual override returns (Pool.ReleaseOrMintOutV1 memory) {
    // Use CCTP Burn/Mint mechanism for chains which have it enabled. The LOCK_RELEASE_FLAG is used in sourcePoolData to
    // discern this, since the source-chain will not be a hybrid-pool but a standard burn-mint. In the event of a
    // stuck message after a migration has occurred, and the message was not executed properly before the migration
    // began, and locked tokens were not released until now, the message will already have been committed to with this
    // flag so it is safe to release the tokens. The source USDC pool is trusted to send messages with the correct
    // flag as well.
    if (bytes4(releaseOrMintIn.sourcePoolData) != LOCK_RELEASE_FLAG) {
      return super.releaseOrMint(releaseOrMintIn);
    }

    return _lockReleaseIncomingMessage(releaseOrMintIn);
  }

  /// @notice Contains the alternative mechanism for incoming tokens, in this implementation is "Release" incoming tokens
  function _lockReleaseIncomingMessage(
    Pool.ReleaseOrMintInV1 calldata releaseOrMintIn
  ) internal virtual returns (Pool.ReleaseOrMintOutV1 memory) {
    _validateReleaseOrMint(releaseOrMintIn);

    // Circle requires a supply-lock to prevent incoming messages once the migration process begins.
    // This prevents new incoming messages once the migration has begun to ensure any the procedure runs as expected
    if (s_proposedUSDCMigrationChain == releaseOrMintIn.remoteChainSelector) {
      revert LanePausedForCCTPMigration(s_proposedUSDCMigrationChain);
    }

    // Decrease internal tracking of locked tokens to ensure accurate accounting for burnLockedUSDC() migration
    // If the chain has already been migrated, then this mapping would be zero, and the operation would underflow.
    // This branch ensures that we're subtracting from the correct mapping. It is also safe to subtract from the
    // excluded tokens mapping, as this function would only be invoked in the event of a stuck tx after a migration
    if (s_lockedTokensByChainSelector[releaseOrMintIn.remoteChainSelector] == 0) {
      s_tokensExcludedFromBurn[releaseOrMintIn.remoteChainSelector] -= releaseOrMintIn.amount;
    } else {
      s_lockedTokensByChainSelector[releaseOrMintIn.remoteChainSelector] -= releaseOrMintIn.amount;
    }

    getToken().safeTransfer(releaseOrMintIn.receiver, releaseOrMintIn.amount);

    emit Released(msg.sender, releaseOrMintIn.receiver, releaseOrMintIn.amount);

    return Pool.ReleaseOrMintOutV1({destinationAmount: releaseOrMintIn.amount});
  }

  /// @notice Contains the alternative mechanism, in this implementation is "Lock" on outgoing tokens
  function _lockReleaseOutgoingMessage(
    Pool.LockOrBurnInV1 calldata lockOrBurnIn
  ) internal virtual returns (Pool.LockOrBurnOutV1 memory) {
    _validateLockOrBurn(lockOrBurnIn);

    // Increase internal accounting of locked tokens for burnLockedUSDC() migration
    s_lockedTokensByChainSelector[lockOrBurnIn.remoteChainSelector] += lockOrBurnIn.amount;

    emit Locked(msg.sender, lockOrBurnIn.amount);

    return Pool.LockOrBurnOutV1({
      destTokenAddress: getRemoteToken(lockOrBurnIn.remoteChainSelector),
      destPoolData: abi.encode(LOCK_RELEASE_FLAG)
    });
  }

  // ================================================================
  // │                   Liquidity Management                       |
  // ================================================================

  /// @notice Gets LiquidityManager, can be address(0) if none is configured.
  /// @return The current liquidity manager for the given chain selector
  function getLiquidityProvider(
    uint64 remoteChainSelector
  ) external view returns (address) {
    return s_liquidityProvider[remoteChainSelector];
  }

  /// @notice Sets the LiquidityManager address.
  /// @dev Only callable by the owner.
  function setLiquidityProvider(uint64 remoteChainSelector, address liquidityProvider) external onlyOwner {
    address oldProvider = s_liquidityProvider[remoteChainSelector];

    s_liquidityProvider[remoteChainSelector] = liquidityProvider;

    emit LiquidityProviderSet(oldProvider, liquidityProvider, remoteChainSelector);
  }

  /// @notice Adds liquidity to the pool for a specific chain. The tokens should be approved first.
  /// @dev Liquidity is expected to be added on a per chain basis. Parties are expected to provide liquidity for their
  /// own chain which implements non canonical USDC and liquidity is not shared across lanes.
  /// @dev Once liquidity is added, it is locked in the pool until it is removed by an incoming message on the
  /// lock release mechanism. This is a hard requirement by Circle to ensure parity with the destination chain
  /// supply is maintained.
  /// @param amount The amount of tokens to provide as liquidity.
  /// @param remoteChainSelector The chain for which liquidity is provided to. Necessary to ensure there's accurate
  /// parity between locked USDC in this contract and the circulating supply on the remote chain
  function provideLiquidity(uint64 remoteChainSelector, uint256 amount) external {
    if (s_liquidityProvider[remoteChainSelector] != msg.sender) revert TokenPool.Unauthorized(msg.sender);

    // Prevent adding liquidity to a chain which has already been migrated
    if (s_migratedChains.contains(remoteChainSelector)) {
      revert TokenLockingNotAllowedAfterMigration(remoteChainSelector);
    }

    // prevent adding liquidity to a chain which has been proposed for migration
    if (remoteChainSelector == s_proposedUSDCMigrationChain) {
      revert LanePausedForCCTPMigration(remoteChainSelector);
    }

    s_lockedTokensByChainSelector[remoteChainSelector] += amount;

    i_token.safeTransferFrom(msg.sender, address(this), amount);

    emit ILiquidityContainer.LiquidityAdded(msg.sender, amount);
  }

  /// @notice Removed liquidity to the pool. The tokens will be sent to msg.sender.
  /// @param remoteChainSelector The chain where liquidity is being released.
  /// @param amount The amount of liquidity to remove.
  /// @dev The function should only be called if non canonical USDC on the remote chain has been burned and is not being
  /// withdrawn on this chain, otherwise a mismatch may occur between locked token balance and remote circulating supply
  /// which may block a potential future migration of the chain to CCTP.
  function withdrawLiquidity(uint64 remoteChainSelector, uint256 amount) external onlyOwner {
    // A supply-lock is required to prevent outgoing messages once the migration process begins.
    // This prevents new outgoing messages once the migration has begun to ensure any the procedure runs as expected
    if (remoteChainSelector == s_proposedUSDCMigrationChain) {
      revert LanePausedForCCTPMigration(remoteChainSelector);
    }

    s_lockedTokensByChainSelector[remoteChainSelector] -= amount;

    i_token.safeTransfer(msg.sender, amount);

    emit ILiquidityContainer.LiquidityRemoved(msg.sender, amount);
  }

  /// @notice This function can be used to transfer liquidity from an older version of the pool to this pool. To do so
  /// this pool must be the owner of the old pool. Since the pool uses two-step ownership transfer, the old pool must
  /// first propose the ownership transfer, and then this pool must accept it. This function can only be called after
  /// the ownership transfer has been proposed, as it will accept it and then make the call to withdrawLiquidity
  /// @dev When upgrading a LockRelease pool, this function can be called at the same time as the pool is changed in the
  /// TokenAdminRegistry. This allows for a smooth transition of both liquidity and transactions to the new pool.
  /// Alternatively, when no multicall is available, a portion of the funds can be transferred to the new pool before
  /// changing which pool CCIP uses, to ensure both pools can operate. Then the pool should be changed in the
  /// TokenAdminRegistry, which will activate the new pool. All new transactions will use the new pool and its
  /// liquidity.
  /// @param from The address of the old pool.
  /// @param remoteChainSelector The chain for which liquidity is being transferred.
  function transferLiquidity(address from, uint64 remoteChainSelector) external onlyOwner {
    Ownable2StepMsgSender(from).acceptOwnership();

    // Withdraw all available liquidity from the old pool. No check is needed for pending migrations, as the old pool
    // will revert if the migration has begun.
    uint256 withdrawAmount = HybridLockReleaseUSDCTokenPool(from).getLockedTokensForChain(remoteChainSelector);
    HybridLockReleaseUSDCTokenPool(from).withdrawLiquidity(remoteChainSelector, withdrawAmount);

    s_lockedTokensByChainSelector[remoteChainSelector] += withdrawAmount;

    emit LiquidityTransferred(from, remoteChainSelector, withdrawAmount);
  }

  // ================================================================
  // │                   Alt Mechanism Logic                        |
  // ================================================================

  /// @notice Return whether a lane should use the alternative L/R mechanism in the token pool.
  /// @param remoteChainSelector the remote chain the lane is interacting with
  /// @return bool Return true if the alternative L/R mechanism should be used, and is decided by the Owner
  function shouldUseLockRelease(
    uint64 remoteChainSelector
  ) public view virtual returns (bool) {
    return s_shouldUseLockRelease[remoteChainSelector];
  }

  /// @notice Updates designations for chains on whether to use primary or alt mechanism on CCIP messages
  /// @param removes A list of chain selectors to disable Lock-Release, and enforce BM
  /// @param adds A list of chain selectors to enable LR instead of BM. These chains must not have been migrated
  /// to CCTP yet or the transaction will revert
  function updateChainSelectorMechanisms(uint64[] calldata removes, uint64[] calldata adds) external onlyOwner {
    for (uint256 i = 0; i < removes.length; ++i) {
      delete s_shouldUseLockRelease[removes[i]];
      emit LockReleaseDisabled(removes[i]);
    }

    for (uint256 i = 0; i < adds.length; ++i) {
      // Prevent enabling lock release on chains which have already been migrated
      if (s_migratedChains.contains(adds[i])) {
        revert TokenLockingNotAllowedAfterMigration(adds[i]);
      }
      s_shouldUseLockRelease[adds[i]] = true;
      emit LockReleaseEnabled(adds[i]);
    }
  }
}
