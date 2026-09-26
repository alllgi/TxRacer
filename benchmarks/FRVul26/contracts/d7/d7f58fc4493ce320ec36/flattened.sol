// Sources retrieved from Sourcify API v2.
// Deterministic best-effort flattening; original files are preserved under src/.

// File: src/v0.8/shared/interfaces/ITypeAndVersion.sol

pragma solidity ^0.8.0;

interface ITypeAndVersion {
  function typeAndVersion() external pure returns (string memory);
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
  function lockOrBurn(Pool.LockOrBurnInV1 calldata lockOrBurnIn)
    external
    returns (Pool.LockOrBurnOutV1 memory lockOrBurnOut);

  /// @notice Releases or mints tokens to the receiver address.
  /// @param releaseOrMintIn All data required to release or mint tokens.
  /// @return releaseOrMintOut The amount of tokens released or minted on the local chain, denominated
  /// in the local token's decimals.
  /// @dev The offramp asserts that the balanceOf of the receiver has been incremented by exactly the number
  /// of tokens that is returned in ReleaseOrMintOutV1.destinationAmount. If the amounts do not match, the tx reverts.
  function releaseOrMint(Pool.ReleaseOrMintInV1 calldata releaseOrMintIn)
    external
    returns (Pool.ReleaseOrMintOutV1 memory);

  /// @notice Checks whether a remote chain is supported in the token pool.
  /// @param remoteChainSelector The selector of the remote chain.
  /// @return true if the given chain is a permissioned remote chain.
  function isSupportedChain(uint64 remoteChainSelector) external view returns (bool);

  /// @notice Returns if the token pool supports the given token.
  /// @param token The address of the token.
  /// @return true if the token is supported by the pool.
  function isSupportedToken(address token) external view returns (bool);
}

// File: src/v0.8/ccip/interfaces/ITokenAdminRegistry.sol

pragma solidity ^0.8.0;

interface ITokenAdminRegistry {
  /// @notice Returns the pool for the given token.
  function getPool(address token) external view returns (address);

  /// @notice Proposes an administrator for the given token as pending administrator.
  /// @param localToken The token to register the administrator for.
  /// @param administrator The administrator to register.
  function proposeAdministrator(address localToken, address administrator) external;
}

// File: src/v0.8/shared/interfaces/IOwnable.sol

pragma solidity ^0.8.0;

interface IOwnable {
  function owner() external returns (address);

  function transferOwnership(address recipient) external;

  function acceptOwnership() external;
}

// File: src/v0.8/shared/access/ConfirmedOwnerWithProposal.sol

pragma solidity ^0.8.0;



/// @title The ConfirmedOwner contract
/// @notice A contract with helpers for basic contract ownership.
contract ConfirmedOwnerWithProposal is IOwnable {
  address private s_owner;
  address private s_pendingOwner;

  event OwnershipTransferRequested(address indexed from, address indexed to);
  event OwnershipTransferred(address indexed from, address indexed to);

  constructor(address newOwner, address pendingOwner) {
    // solhint-disable-next-line gas-custom-errors
    require(newOwner != address(0), "Cannot set owner to zero");

    s_owner = newOwner;
    if (pendingOwner != address(0)) {
      _transferOwnership(pendingOwner);
    }
  }

  /// @notice Allows an owner to begin transferring ownership to a new address.
  function transferOwnership(address to) public override onlyOwner {
    _transferOwnership(to);
  }

  /// @notice Allows an ownership transfer to be completed by the recipient.
  function acceptOwnership() external override {
    // solhint-disable-next-line gas-custom-errors
    require(msg.sender == s_pendingOwner, "Must be proposed owner");

    address oldOwner = s_owner;
    s_owner = msg.sender;
    s_pendingOwner = address(0);

    emit OwnershipTransferred(oldOwner, msg.sender);
  }

  /// @notice Get the current owner
  function owner() public view override returns (address) {
    return s_owner;
  }

  /// @notice validate, transfer ownership, and emit relevant events
  function _transferOwnership(address to) private {
    // solhint-disable-next-line gas-custom-errors
    require(to != msg.sender, "Cannot transfer to self");

    s_pendingOwner = to;

    emit OwnershipTransferRequested(s_owner, to);
  }

  /// @notice validate access
  function _validateOwnership() internal view {
    // solhint-disable-next-line gas-custom-errors
    require(msg.sender == s_owner, "Only callable by owner");
  }

  /// @notice Reverts if called by anyone other than the contract owner.
  modifier onlyOwner() {
    _validateOwnership();
    _;
  }
}

// File: src/v0.8/shared/access/ConfirmedOwner.sol

pragma solidity ^0.8.0;



/// @title The ConfirmedOwner contract
/// @notice A contract with helpers for basic contract ownership.
contract ConfirmedOwner is ConfirmedOwnerWithProposal {
  constructor(address newOwner) ConfirmedOwnerWithProposal(newOwner, address(0)) {}
}

// File: src/v0.8/shared/access/OwnerIsCreator.sol

pragma solidity ^0.8.0;



/// @title The OwnerIsCreator contract
/// @notice A contract with helpers for basic contract ownership.
contract OwnerIsCreator is ConfirmedOwner {
  constructor() ConfirmedOwner(msg.sender) {}
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

// File: src/v0.8/ccip/tokenAdminRegistry/TokenAdminRegistry.sol

pragma solidity 0.8.24;









/// @notice This contract stores the token pool configuration for all CCIP enabled tokens. It works
/// on a self-serve basis, where tokens can be registered without intervention from the CCIP owner.
/// @dev This contract is not considered upgradable, as it is a customer facing contract that will store
/// significant amounts of data.
contract TokenAdminRegistry is ITokenAdminRegistry, ITypeAndVersion, OwnerIsCreator {
  using EnumerableSet for EnumerableSet.AddressSet;

  error OnlyRegistryModuleOrOwner(address sender);
  error OnlyAdministrator(address sender, address token);
  error OnlyPendingAdministrator(address sender, address token);
  error AlreadyRegistered(address token);
  error ZeroAddress();
  error InvalidTokenPoolToken(address token);

  event PoolSet(address indexed token, address indexed previousPool, address indexed newPool);
  event AdministratorTransferRequested(address indexed token, address indexed currentAdmin, address indexed newAdmin);
  event AdministratorTransferred(address indexed token, address indexed newAdmin);
  event RegistryModuleAdded(address module);
  event RegistryModuleRemoved(address indexed module);

  // The struct is packed in a way that optimizes the attributes that are accessed together.
  // solhint-disable-next-line gas-struct-packing
  struct TokenConfig {
    address administrator; // the current administrator of the token
    address pendingAdministrator; // the address that is pending to become the new administrator
    address tokenPool; // the token pool for this token. Can be address(0) if not deployed or not configured.
  }

  string public constant override typeAndVersion = "TokenAdminRegistry 1.5.0";

  // Mapping of token address to token configuration
  mapping(address token => TokenConfig) internal s_tokenConfig;

  // All tokens that have been configured
  EnumerableSet.AddressSet internal s_tokens;

  // Registry modules are allowed to register administrators for tokens
  EnumerableSet.AddressSet internal s_registryModules;

  /// @notice Returns all pools for the given tokens.
  /// @dev Will return address(0) for tokens that do not have a pool.
  function getPools(address[] calldata tokens) external view returns (address[] memory) {
    address[] memory pools = new address[](tokens.length);
    for (uint256 i = 0; i < tokens.length; ++i) {
      pools[i] = s_tokenConfig[tokens[i]].tokenPool;
    }
    return pools;
  }

  /// @inheritdoc ITokenAdminRegistry
  function getPool(address token) external view returns (address) {
    return s_tokenConfig[token].tokenPool;
  }

  /// @notice Returns the configuration for a token.
  /// @param token The token to get the configuration for.
  /// @return config The configuration for the token.
  function getTokenConfig(address token) external view returns (TokenConfig memory) {
    return s_tokenConfig[token];
  }

  /// @notice Returns a list of tokens that are configured in the token admin registry.
  /// @param startIndex Starting index in list, can be 0 if you want to start from the beginning.
  /// @param maxCount Maximum number of tokens to retrieve. Since the list can be large,
  /// it is recommended to use a paging mechanism to retrieve all tokens. If querying for very
  /// large lists, RPCs can time out. If you want all tokens, use type(uint64).max.
  /// @return tokens List of configured tokens.
  /// @dev The function is paginated to avoid RPC timeouts.
  /// @dev The ordering is guaranteed to remain the same as it is not possible to remove tokens
  /// from s_tokens.
  function getAllConfiguredTokens(uint64 startIndex, uint64 maxCount) external view returns (address[] memory tokens) {
    uint256 numberOfTokens = s_tokens.length();
    if (startIndex >= numberOfTokens) {
      return tokens;
    }
    uint256 count = maxCount;
    if (count + startIndex > numberOfTokens) {
      count = numberOfTokens - startIndex;
    }
    tokens = new address[](count);
    for (uint256 i = 0; i < count; ++i) {
      tokens[i] = s_tokens.at(startIndex + i);
    }

    return tokens;
  }

  // ================================================================
  // │                  Administrator functions                     │
  // ================================================================

  /// @notice Sets the pool for a token. Setting the pool to address(0) effectively delists the token
  /// from CCIP. Setting the pool to any other address enables the token on CCIP.
  /// @param localToken The token to set the pool for.
  /// @param pool The pool to set for the token.
  function setPool(address localToken, address pool) external onlyTokenAdmin(localToken) {
    // The pool has to support the token, but we want to allow removing the pool, so we only check
    // if the pool supports the token if it is not address(0).
    if (pool != address(0) && !IPoolV1(pool).isSupportedToken(localToken)) {
      revert InvalidTokenPoolToken(localToken);
    }

    TokenConfig storage config = s_tokenConfig[localToken];

    address previousPool = config.tokenPool;
    config.tokenPool = pool;

    if (previousPool != pool) {
      emit PoolSet(localToken, previousPool, pool);
    }
  }

  /// @notice Transfers the administrator role for a token to a new address with a 2-step process.
  /// @param localToken The token to transfer the administrator role for.
  /// @param newAdmin The address to transfer the administrator role to. Can be address(0) to cancel
  /// a pending transfer.
  /// @dev The new admin must call `acceptAdminRole` to accept the role.
  function transferAdminRole(address localToken, address newAdmin) external onlyTokenAdmin(localToken) {
    TokenConfig storage config = s_tokenConfig[localToken];
    config.pendingAdministrator = newAdmin;

    emit AdministratorTransferRequested(localToken, msg.sender, newAdmin);
  }

  /// @notice Accepts the administrator role for a token.
  /// @param localToken The token to accept the administrator role for.
  /// @dev This function can only be called by the pending administrator.
  function acceptAdminRole(address localToken) external {
    TokenConfig storage config = s_tokenConfig[localToken];
    if (config.pendingAdministrator != msg.sender) {
      revert OnlyPendingAdministrator(msg.sender, localToken);
    }

    config.administrator = msg.sender;
    config.pendingAdministrator = address(0);

    emit AdministratorTransferred(localToken, msg.sender);
  }

  // ================================================================
  // │                    Administrator config                      │
  // ================================================================

  /// @notice Public getter to check for permissions of an administrator
  function isAdministrator(address localToken, address administrator) external view returns (bool) {
    return s_tokenConfig[localToken].administrator == administrator;
  }

  /// @inheritdoc ITokenAdminRegistry
  /// @dev Can only be called by a registry module.
  function proposeAdministrator(address localToken, address administrator) external {
    if (!isRegistryModule(msg.sender) && msg.sender != owner()) {
      revert OnlyRegistryModuleOrOwner(msg.sender);
    }
    if (administrator == address(0)) {
      revert ZeroAddress();
    }
    TokenConfig storage config = s_tokenConfig[localToken];

    if (config.administrator != address(0)) {
      revert AlreadyRegistered(localToken);
    }

    config.pendingAdministrator = administrator;

    // We don't care if it's already in the set, as it's a no-op.
    s_tokens.add(localToken);

    emit AdministratorTransferRequested(localToken, address(0), administrator);
  }

  // ================================================================
  // │                      Registry Modules                        │
  // ================================================================

  /// @notice Checks if an address is a registry module.
  /// @param module The address to check.
  /// @return True if the address is a registry module, false otherwise.
  function isRegistryModule(address module) public view returns (bool) {
    return s_registryModules.contains(module);
  }

  /// @notice Adds a new registry module to the list of allowed modules.
  /// @param module The module to add.
  function addRegistryModule(address module) external onlyOwner {
    if (s_registryModules.add(module)) {
      emit RegistryModuleAdded(module);
    }
  }

  /// @notice Removes a registry module from the list of allowed modules.
  /// @param module The module to remove.
  function removeRegistryModule(address module) external onlyOwner {
    if (s_registryModules.remove(module)) {
      emit RegistryModuleRemoved(module);
    }
  }

  // ================================================================
  // │                           Access                             │
  // ================================================================

  /// @notice Checks if an address is the administrator of the given token.
  modifier onlyTokenAdmin(address token) {
    if (s_tokenConfig[token].administrator != msg.sender) {
      revert OnlyAdministrator(msg.sender, token);
    }
    _;
  }
}

// File: /Users/jaden/Documents/contract-verification/ccip/contracts/src/v0.8/ccip/libraries/Pool.sol

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

// File: /Users/jaden/Documents/contract-verification/ccip/contracts/src/v0.8/vendor/openzeppelin-solidity/v5.0.2/contracts/utils/introspection/IERC165.sol

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

// File: /Users/jaden/Documents/contract-verification/ccip/contracts/src/v0.8/ccip/interfaces/IPool.sol

pragma solidity ^0.8.0;





/// @notice Shared public interface for multiple V1 pool types.
/// Each pool type handles a different child token model (lock/unlock, mint/burn.)
interface IPoolV1 is IERC165 {
  /// @notice Lock tokens into the pool or burn the tokens.
  /// @param lockOrBurnIn Encoded data fields for the processing of tokens on the source chain.
  /// @return lockOrBurnOut Encoded data fields for the processing of tokens on the destination chain.
  function lockOrBurn(Pool.LockOrBurnInV1 calldata lockOrBurnIn)
    external
    returns (Pool.LockOrBurnOutV1 memory lockOrBurnOut);

  /// @notice Releases or mints tokens to the receiver address.
  /// @param releaseOrMintIn All data required to release or mint tokens.
  /// @return releaseOrMintOut The amount of tokens released or minted on the local chain, denominated
  /// in the local token's decimals.
  /// @dev The offramp asserts that the balanceOf of the receiver has been incremented by exactly the number
  /// of tokens that is returned in ReleaseOrMintOutV1.destinationAmount. If the amounts do not match, the tx reverts.
  function releaseOrMint(Pool.ReleaseOrMintInV1 calldata releaseOrMintIn)
    external
    returns (Pool.ReleaseOrMintOutV1 memory);

  /// @notice Checks whether a remote chain is supported in the token pool.
  /// @param remoteChainSelector The selector of the remote chain.
  /// @return true if the given chain is a permissioned remote chain.
  function isSupportedChain(uint64 remoteChainSelector) external view returns (bool);

  /// @notice Returns if the token pool supports the given token.
  /// @param token The address of the token.
  /// @return true if the token is supported by the pool.
  function isSupportedToken(address token) external view returns (bool);
}

// File: /Users/jaden/Documents/contract-verification/ccip/contracts/src/v0.8/ccip/interfaces/ITokenAdminRegistry.sol

pragma solidity ^0.8.0;

interface ITokenAdminRegistry {
  /// @notice Returns the pool for the given token.
  function getPool(address token) external view returns (address);

  /// @notice Proposes an administrator for the given token as pending administrator.
  /// @param localToken The token to register the administrator for.
  /// @param administrator The administrator to register.
  function proposeAdministrator(address localToken, address administrator) external;
}

// File: /Users/jaden/Documents/contract-verification/ccip/contracts/src/v0.8/shared/interfaces/ITypeAndVersion.sol

pragma solidity ^0.8.0;

interface ITypeAndVersion {
  function typeAndVersion() external pure returns (string memory);
}

// File: /Users/jaden/Documents/contract-verification/ccip/contracts/src/v0.8/shared/interfaces/IOwnable.sol

pragma solidity ^0.8.0;

interface IOwnable {
  function owner() external returns (address);

  function transferOwnership(address recipient) external;

  function acceptOwnership() external;
}

// File: /Users/jaden/Documents/contract-verification/ccip/contracts/src/v0.8/shared/access/ConfirmedOwnerWithProposal.sol

pragma solidity ^0.8.0;



/// @title The ConfirmedOwner contract
/// @notice A contract with helpers for basic contract ownership.
contract ConfirmedOwnerWithProposal is IOwnable {
  address private s_owner;
  address private s_pendingOwner;

  event OwnershipTransferRequested(address indexed from, address indexed to);
  event OwnershipTransferred(address indexed from, address indexed to);

  constructor(address newOwner, address pendingOwner) {
    // solhint-disable-next-line gas-custom-errors
    require(newOwner != address(0), "Cannot set owner to zero");

    s_owner = newOwner;
    if (pendingOwner != address(0)) {
      _transferOwnership(pendingOwner);
    }
  }

  /// @notice Allows an owner to begin transferring ownership to a new address.
  function transferOwnership(address to) public override onlyOwner {
    _transferOwnership(to);
  }

  /// @notice Allows an ownership transfer to be completed by the recipient.
  function acceptOwnership() external override {
    // solhint-disable-next-line gas-custom-errors
    require(msg.sender == s_pendingOwner, "Must be proposed owner");

    address oldOwner = s_owner;
    s_owner = msg.sender;
    s_pendingOwner = address(0);

    emit OwnershipTransferred(oldOwner, msg.sender);
  }

  /// @notice Get the current owner
  function owner() public view override returns (address) {
    return s_owner;
  }

  /// @notice validate, transfer ownership, and emit relevant events
  function _transferOwnership(address to) private {
    // solhint-disable-next-line gas-custom-errors
    require(to != msg.sender, "Cannot transfer to self");

    s_pendingOwner = to;

    emit OwnershipTransferRequested(s_owner, to);
  }

  /// @notice validate access
  function _validateOwnership() internal view {
    // solhint-disable-next-line gas-custom-errors
    require(msg.sender == s_owner, "Only callable by owner");
  }

  /// @notice Reverts if called by anyone other than the contract owner.
  modifier onlyOwner() {
    _validateOwnership();
    _;
  }
}

// File: /Users/jaden/Documents/contract-verification/ccip/contracts/src/v0.8/shared/access/ConfirmedOwner.sol

pragma solidity ^0.8.0;



/// @title The ConfirmedOwner contract
/// @notice A contract with helpers for basic contract ownership.
contract ConfirmedOwner is ConfirmedOwnerWithProposal {
  constructor(address newOwner) ConfirmedOwnerWithProposal(newOwner, address(0)) {}
}

// File: /Users/jaden/Documents/contract-verification/ccip/contracts/src/v0.8/shared/access/OwnerIsCreator.sol

pragma solidity ^0.8.0;



/// @title The OwnerIsCreator contract
/// @notice A contract with helpers for basic contract ownership.
contract OwnerIsCreator is ConfirmedOwner {
  constructor() ConfirmedOwner(msg.sender) {}
}

// File: /Users/jaden/Documents/contract-verification/ccip/contracts/src/v0.8/vendor/openzeppelin-solidity/v5.0.2/contracts/utils/structs/EnumerableSet.sol

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

// File: /Users/jaden/Documents/contract-verification/ccip/contracts/src/v0.8/ccip/tokenAdminRegistry/TokenAdminRegistry.sol

pragma solidity 0.8.24;









/// @notice This contract stores the token pool configuration for all CCIP enabled tokens. It works
/// on a self-serve basis, where tokens can be registered without intervention from the CCIP owner.
/// @dev This contract is not considered upgradable, as it is a customer facing contract that will store
/// significant amounts of data.
contract TokenAdminRegistry is ITokenAdminRegistry, ITypeAndVersion, OwnerIsCreator {
  using EnumerableSet for EnumerableSet.AddressSet;

  error OnlyRegistryModuleOrOwner(address sender);
  error OnlyAdministrator(address sender, address token);
  error OnlyPendingAdministrator(address sender, address token);
  error AlreadyRegistered(address token);
  error ZeroAddress();
  error InvalidTokenPoolToken(address token);

  event PoolSet(address indexed token, address indexed previousPool, address indexed newPool);
  event AdministratorTransferRequested(address indexed token, address indexed currentAdmin, address indexed newAdmin);
  event AdministratorTransferred(address indexed token, address indexed newAdmin);
  event RegistryModuleAdded(address module);
  event RegistryModuleRemoved(address indexed module);

  // The struct is packed in a way that optimizes the attributes that are accessed together.
  // solhint-disable-next-line gas-struct-packing
  struct TokenConfig {
    address administrator; // the current administrator of the token
    address pendingAdministrator; // the address that is pending to become the new administrator
    address tokenPool; // the token pool for this token. Can be address(0) if not deployed or not configured.
  }

  string public constant override typeAndVersion = "TokenAdminRegistry 1.5.0";

  // Mapping of token address to token configuration
  mapping(address token => TokenConfig) internal s_tokenConfig;

  // All tokens that have been configured
  EnumerableSet.AddressSet internal s_tokens;

  // Registry modules are allowed to register administrators for tokens
  EnumerableSet.AddressSet internal s_registryModules;

  /// @notice Returns all pools for the given tokens.
  /// @dev Will return address(0) for tokens that do not have a pool.
  function getPools(address[] calldata tokens) external view returns (address[] memory) {
    address[] memory pools = new address[](tokens.length);
    for (uint256 i = 0; i < tokens.length; ++i) {
      pools[i] = s_tokenConfig[tokens[i]].tokenPool;
    }
    return pools;
  }

  /// @inheritdoc ITokenAdminRegistry
  function getPool(address token) external view returns (address) {
    return s_tokenConfig[token].tokenPool;
  }

  /// @notice Returns the configuration for a token.
  /// @param token The token to get the configuration for.
  /// @return config The configuration for the token.
  function getTokenConfig(address token) external view returns (TokenConfig memory) {
    return s_tokenConfig[token];
  }

  /// @notice Returns a list of tokens that are configured in the token admin registry.
  /// @param startIndex Starting index in list, can be 0 if you want to start from the beginning.
  /// @param maxCount Maximum number of tokens to retrieve. Since the list can be large,
  /// it is recommended to use a paging mechanism to retrieve all tokens. If querying for very
  /// large lists, RPCs can time out. If you want all tokens, use type(uint64).max.
  /// @return tokens List of configured tokens.
  /// @dev The function is paginated to avoid RPC timeouts.
  /// @dev The ordering is guaranteed to remain the same as it is not possible to remove tokens
  /// from s_tokens.
  function getAllConfiguredTokens(uint64 startIndex, uint64 maxCount) external view returns (address[] memory tokens) {
    uint256 numberOfTokens = s_tokens.length();
    if (startIndex >= numberOfTokens) {
      return tokens;
    }
    uint256 count = maxCount;
    if (count + startIndex > numberOfTokens) {
      count = numberOfTokens - startIndex;
    }
    tokens = new address[](count);
    for (uint256 i = 0; i < count; ++i) {
      tokens[i] = s_tokens.at(startIndex + i);
    }

    return tokens;
  }

  // ================================================================
  // │                  Administrator functions                     │
  // ================================================================

  /// @notice Sets the pool for a token. Setting the pool to address(0) effectively delists the token
  /// from CCIP. Setting the pool to any other address enables the token on CCIP.
  /// @param localToken The token to set the pool for.
  /// @param pool The pool to set for the token.
  function setPool(address localToken, address pool) external onlyTokenAdmin(localToken) {
    // The pool has to support the token, but we want to allow removing the pool, so we only check
    // if the pool supports the token if it is not address(0).
    if (pool != address(0) && !IPoolV1(pool).isSupportedToken(localToken)) {
      revert InvalidTokenPoolToken(localToken);
    }

    TokenConfig storage config = s_tokenConfig[localToken];

    address previousPool = config.tokenPool;
    config.tokenPool = pool;

    if (previousPool != pool) {
      emit PoolSet(localToken, previousPool, pool);
    }
  }

  /// @notice Transfers the administrator role for a token to a new address with a 2-step process.
  /// @param localToken The token to transfer the administrator role for.
  /// @param newAdmin The address to transfer the administrator role to. Can be address(0) to cancel
  /// a pending transfer.
  /// @dev The new admin must call `acceptAdminRole` to accept the role.
  function transferAdminRole(address localToken, address newAdmin) external onlyTokenAdmin(localToken) {
    TokenConfig storage config = s_tokenConfig[localToken];
    config.pendingAdministrator = newAdmin;

    emit AdministratorTransferRequested(localToken, msg.sender, newAdmin);
  }

  /// @notice Accepts the administrator role for a token.
  /// @param localToken The token to accept the administrator role for.
  /// @dev This function can only be called by the pending administrator.
  function acceptAdminRole(address localToken) external {
    TokenConfig storage config = s_tokenConfig[localToken];
    if (config.pendingAdministrator != msg.sender) {
      revert OnlyPendingAdministrator(msg.sender, localToken);
    }

    config.administrator = msg.sender;
    config.pendingAdministrator = address(0);

    emit AdministratorTransferred(localToken, msg.sender);
  }

  // ================================================================
  // │                    Administrator config                      │
  // ================================================================

  /// @notice Public getter to check for permissions of an administrator
  function isAdministrator(address localToken, address administrator) external view returns (bool) {
    return s_tokenConfig[localToken].administrator == administrator;
  }

  /// @inheritdoc ITokenAdminRegistry
  /// @dev Can only be called by a registry module.
  function proposeAdministrator(address localToken, address administrator) external {
    if (!isRegistryModule(msg.sender) && msg.sender != owner()) {
      revert OnlyRegistryModuleOrOwner(msg.sender);
    }
    if (administrator == address(0)) {
      revert ZeroAddress();
    }
    TokenConfig storage config = s_tokenConfig[localToken];

    if (config.administrator != address(0)) {
      revert AlreadyRegistered(localToken);
    }

    config.pendingAdministrator = administrator;

    // We don't care if it's already in the set, as it's a no-op.
    s_tokens.add(localToken);

    emit AdministratorTransferRequested(localToken, address(0), administrator);
  }

  // ================================================================
  // │                      Registry Modules                        │
  // ================================================================

  /// @notice Checks if an address is a registry module.
  /// @param module The address to check.
  /// @return True if the address is a registry module, false otherwise.
  function isRegistryModule(address module) public view returns (bool) {
    return s_registryModules.contains(module);
  }

  /// @notice Adds a new registry module to the list of allowed modules.
  /// @param module The module to add.
  function addRegistryModule(address module) external onlyOwner {
    if (s_registryModules.add(module)) {
      emit RegistryModuleAdded(module);
    }
  }

  /// @notice Removes a registry module from the list of allowed modules.
  /// @param module The module to remove.
  function removeRegistryModule(address module) external onlyOwner {
    if (s_registryModules.remove(module)) {
      emit RegistryModuleRemoved(module);
    }
  }

  // ================================================================
  // │                           Access                             │
  // ================================================================

  /// @notice Checks if an address is the administrator of the given token.
  modifier onlyTokenAdmin(address token) {
    if (s_tokenConfig[token].administrator != msg.sender) {
      revert OnlyAdministrator(msg.sender, token);
    }
    _;
  }
}
