// Sources retrieved from Sourcify API v2.
// Deterministic best-effort flattening; original files are preserved under src/.

// File: @axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IERC20.sol

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    error InvalidAccount();

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}

// File: @axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IContractIdentifier.sol

pragma solidity ^0.8.0;

// General interface for upgradable contracts
interface IContractIdentifier {
    /**
     * @notice Returns the contract ID. It can be used as a check during upgrades.
     * @dev Meant to be overridden in derived contracts.
     * @return bytes32 The contract ID
     */
    function contractId() external pure returns (bytes32);
}

// File: @axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IImplementation.sol

pragma solidity ^0.8.0;



interface IImplementation is IContractIdentifier {
    error NotProxy();

    function setup(bytes calldata data) external;
}

// File: @axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IGovernable.sol

pragma solidity ^0.8.0;

/**
 * @title IGovernable Interface
 * @notice This is an interface used by the AxelarGateway contract to manage governance and mint limiter roles.
 */
interface IGovernable {
    error NotGovernance();
    error NotMintLimiter();
    error InvalidGovernance();
    error InvalidMintLimiter();

    event GovernanceTransferred(address indexed previousGovernance, address indexed newGovernance);
    event MintLimiterTransferred(address indexed previousGovernance, address indexed newGovernance);

    /**
     * @notice Returns the governance address.
     * @return address of the governance
     */
    function governance() external view returns (address);

    /**
     * @notice Returns the mint limiter address.
     * @return address of the mint limiter
     */
    function mintLimiter() external view returns (address);

    /**
     * @notice Transfer the governance role to another address.
     * @param newGovernance The new governance address
     */
    function transferGovernance(address newGovernance) external;

    /**
     * @notice Transfer the mint limiter role to another address.
     * @param newGovernance The new mint limiter address
     */
    function transferMintLimiter(address newGovernance) external;
}

// File: @axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol

pragma solidity ^0.8.0;




interface IAxelarGateway is IImplementation, IGovernable {
    /**********\
    |* Errors *|
    \**********/

    error NotSelf();
    error InvalidCodeHash();
    error SetupFailed();
    error InvalidAuthModule();
    error InvalidTokenDeployer();
    error InvalidAmount();
    error InvalidChainId();
    error InvalidCommands();
    error TokenDoesNotExist(string symbol);
    error TokenAlreadyExists(string symbol);
    error TokenDeployFailed(string symbol);
    error TokenContractDoesNotExist(address token);
    error BurnFailed(string symbol);
    error MintFailed(string symbol);
    error InvalidSetMintLimitsParams();
    error ExceedMintLimit(string symbol);

    /**********\
    |* Events *|
    \**********/

    event TokenSent(
        address indexed sender,
        string destinationChain,
        string destinationAddress,
        string symbol,
        uint256 amount
    );

    event ContractCall(
        address indexed sender,
        string destinationChain,
        string destinationContractAddress,
        bytes32 indexed payloadHash,
        bytes payload
    );

    event ContractCallWithToken(
        address indexed sender,
        string destinationChain,
        string destinationContractAddress,
        bytes32 indexed payloadHash,
        bytes payload,
        string symbol,
        uint256 amount
    );

    event Executed(bytes32 indexed commandId);

    event TokenDeployed(string symbol, address tokenAddresses);

    event ContractCallApproved(
        bytes32 indexed commandId,
        string sourceChain,
        string sourceAddress,
        address indexed contractAddress,
        bytes32 indexed payloadHash,
        bytes32 sourceTxHash,
        uint256 sourceEventIndex
    );

    event ContractCallApprovedWithMint(
        bytes32 indexed commandId,
        string sourceChain,
        string sourceAddress,
        address indexed contractAddress,
        bytes32 indexed payloadHash,
        string symbol,
        uint256 amount,
        bytes32 sourceTxHash,
        uint256 sourceEventIndex
    );

    event ContractCallExecuted(bytes32 indexed commandId);

    event TokenMintLimitUpdated(string symbol, uint256 limit);

    event OperatorshipTransferred(bytes newOperatorsData);

    event Upgraded(address indexed implementation);

    /********************\
    |* Public Functions *|
    \********************/

    function sendToken(
        string calldata destinationChain,
        string calldata destinationAddress,
        string calldata symbol,
        uint256 amount
    ) external;

    function callContract(
        string calldata destinationChain,
        string calldata contractAddress,
        bytes calldata payload
    ) external;

    function callContractWithToken(
        string calldata destinationChain,
        string calldata contractAddress,
        bytes calldata payload,
        string calldata symbol,
        uint256 amount
    ) external;

    function isContractCallApproved(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        address contractAddress,
        bytes32 payloadHash
    ) external view returns (bool);

    function isContractCallAndMintApproved(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        address contractAddress,
        bytes32 payloadHash,
        string calldata symbol,
        uint256 amount
    ) external view returns (bool);

    function validateContractCall(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes32 payloadHash
    ) external returns (bool);

    function validateContractCallAndMint(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes32 payloadHash,
        string calldata symbol,
        uint256 amount
    ) external returns (bool);

    /***********\
    |* Getters *|
    \***********/

    function authModule() external view returns (address);

    function tokenDeployer() external view returns (address);

    function tokenMintLimit(string memory symbol) external view returns (uint256);

    function tokenMintAmount(string memory symbol) external view returns (uint256);

    function allTokensFrozen() external view returns (bool);

    function implementation() external view returns (address);

    function tokenAddresses(string memory symbol) external view returns (address);

    function tokenFrozen(string memory symbol) external view returns (bool);

    function isCommandExecuted(bytes32 commandId) external view returns (bool);

    /************************\
    |* Governance Functions *|
    \************************/

    function setTokenMintLimits(string[] calldata symbols, uint256[] calldata limits) external;

    function upgrade(
        address newImplementation,
        bytes32 newImplementationCodeHash,
        bytes calldata setupParams
    ) external;

    /**********************\
    |* External Functions *|
    \**********************/

    function execute(bytes calldata input) external;
}

// File: @axelar-network/axelar-gmp-sdk-solidity/contracts/libs/SafeTransfer.sol

pragma solidity ^0.8.0;



error TokenTransferFailed();

/*
 * @title SafeTokenCall
 * @dev This library is used for performing safe token transfers.
 */
library SafeTokenCall {
    /*
     * @notice Make a safe call to a token contract.
     * @param token The token contract to interact with.
     * @param callData The function call data.
     * @throws TokenTransferFailed error if transfer of token is not successful.
     */
    function safeCall(IERC20 token, bytes memory callData) internal {
        (bool success, bytes memory returnData) = address(token).call(callData);
        bool transferred = success && (returnData.length == uint256(0) || abi.decode(returnData, (bool)));

        if (!transferred || address(token).code.length == 0) revert TokenTransferFailed();
    }
}

/*
 * @title SafeTokenTransfer
 * @dev This library safely transfers tokens from the contract to a recipient.
 */
library SafeTokenTransfer {
    /*
     * @notice Transfer tokens to a recipient.
     * @param token The token contract.
     * @param receiver The recipient of the tokens.
     * @param amount The amount of tokens to transfer.
     */
    function safeTransfer(
        IERC20 token,
        address receiver,
        uint256 amount
    ) internal {
        SafeTokenCall.safeCall(token, abi.encodeWithSelector(IERC20.transfer.selector, receiver, amount));
    }
}

/*
 * @title SafeTokenTransferFrom
 * @dev This library helps to safely transfer tokens on behalf of a token holder.
 */
library SafeTokenTransferFrom {
    /*
     * @notice Transfer tokens on behalf of a token holder.
     * @param token The token contract.
     * @param from The address of the token holder.
     * @param to The address the tokens are to be sent to.
     * @param amount The amount of tokens to be transferred.
     */
    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        SafeTokenCall.safeCall(token, abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, amount));
    }
}

// File: @axelar-network/axelar-gmp-sdk-solidity/contracts/libs/ContractAddress.sol

pragma solidity ^0.8.0;

library ContractAddress {
    function isContract(address contractAddress) internal view returns (bool) {
        bytes32 existingCodeHash = contractAddress.codehash;

        // https://eips.ethereum.org/EIPS/eip-1052
        // keccak256('') == 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470
        return
            existingCodeHash != bytes32(0) &&
            existingCodeHash != 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
    }
}

// File: @axelar-network/axelar-gmp-sdk-solidity/contracts/upgradable/Implementation.sol

pragma solidity ^0.8.0;



/**
 * @title Implementation
 * @notice This contract serves as a base for other contracts and enforces a proxy-first access restriction.
 * @dev Derived contracts must implement the setup function.
 */
abstract contract Implementation is IImplementation {
    address private immutable implementationAddress;

    /**
     * @dev Contract constructor that sets the implementation address to the address of this contract.
     */
    constructor() {
        implementationAddress = address(this);
    }

    /**
     * @dev Modifier to require the caller to be the proxy contract.
     * Reverts if the caller is the current contract (i.e., the implementation contract itself).
     */
    modifier onlyProxy() {
        if (implementationAddress == address(this)) revert NotProxy();
        _;
    }

    /**
     * @notice Initializes contract parameters.
     * This function is intended to be overridden by derived contracts.
     * The overriding function must have the onlyProxy modifier.
     * @param params The parameters to be used for initialization
     */
    function setup(bytes calldata params) external virtual;
}

// File: @axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IOwnable.sol

pragma solidity ^0.8.0;

/**
 * @title IOwnable Interface
 * @notice IOwnable is an interface that abstracts the implementation of a
 * contract with ownership control features. It's commonly used in upgradable
 * contracts and includes the functionality to get current owner, transfer
 * ownership, and propose and accept ownership.
 */
interface IOwnable {
    error NotOwner();
    error InvalidOwner();
    error InvalidOwnerAddress();

    event OwnershipTransferStarted(address indexed newOwner);
    event OwnershipTransferred(address indexed newOwner);

    /**
     * @notice Returns the current owner of the contract.
     * @return address The address of the current owner
     */
    function owner() external view returns (address);

    /**
     * @notice Returns the address of the pending owner of the contract.
     * @return address The address of the pending owner
     */
    function pendingOwner() external view returns (address);

    /**
     * @notice Transfers ownership of the contract to a new address
     * @param newOwner The address to transfer ownership to
     */
    function transferOwnership(address newOwner) external;

    /**
     * @notice Proposes to transfer the contract's ownership to a new address.
     * The new owner needs to accept the ownership explicitly.
     * @param newOwner The address to transfer ownership to
     */
    function proposeOwnership(address newOwner) external;

    /**
     * @notice Transfers ownership to the pending owner.
     * @dev Can only be called by the pending owner
     */
    function acceptOwnership() external;
}

// File: contracts/interfaces/IAxelarAuth.sol

pragma solidity ^0.8.0;



interface IAxelarAuth is IOwnable {
    function validateProof(bytes32 messageHash, bytes calldata proof) external returns (bool currentOperators);

    function transferOperatorship(bytes calldata params) external;
}

// File: contracts/interfaces/IERC20Burn.sol

pragma solidity ^0.8.9;

interface IERC20Burn {
    function burn(bytes32 salt) external;
}

// File: contracts/interfaces/IERC20BurnFrom.sol

pragma solidity ^0.8.9;

interface IERC20BurnFrom {
    function burnFrom(address account, uint256 amount) external;
}

// File: contracts/interfaces/IERC20.sol

pragma solidity ^0.8.9;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    error InvalidAccount();

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}

// File: contracts/interfaces/IERC20Permit.sol

pragma solidity ^0.8.9;

interface IERC20Permit {
    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function nonces(address account) external view returns (uint256);

    function permit(
        address issuer,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

// File: contracts/interfaces/IOwnable.sol

pragma solidity ^0.8.9;

interface IOwnable {
    error NotOwner();
    error InvalidOwner();

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() external view returns (address);

    function transferOwnership(address newOwner) external;
}

// File: contracts/interfaces/IMintableCappedERC20.sol

pragma solidity ^0.8.9;





interface IMintableCappedERC20 is IERC20, IERC20Permit, IOwnable {
    error CapExceeded();

    function cap() external view returns (uint256);

    function mint(address account, uint256 amount) external;
}

// File: contracts/interfaces/IBurnableMintableCappedERC20.sol

pragma solidity ^0.8.9;





interface IBurnableMintableCappedERC20 is IERC20Burn, IERC20BurnFrom, IMintableCappedERC20 {
    function depositAddress(bytes32 salt) external view returns (address);

    function burn(bytes32 salt) external;

    function burnFrom(address account, uint256 amount) external;
}

// File: contracts/interfaces/ITokenDeployer.sol

pragma solidity ^0.8.0;

interface ITokenDeployer {
    function deployToken(
        string calldata name,
        string calldata symbol,
        uint8 decimals,
        uint256 cap,
        bytes32 salt
    ) external returns (address tokenAddress);
}

// File: contracts/ECDSA.sol

pragma solidity 0.8.9;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    error InvalidSignatureLength();
    error InvalidS();
    error InvalidV();
    error InvalidSignature();

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address signer) {
        // Check the signature length
        if (signature.length != 65) revert InvalidSignatureLength();

        // Divide the signature in r, s and v variables
        bytes32 r;
        bytes32 s;
        uint8 v;

        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solhint-disable-next-line no-inline-assembly
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (281): 0 < s < secp256k1n ÷ 2 + 1, and for v in (282): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) revert InvalidS();

        if (v != 27 && v != 28) revert InvalidV();

        // If the signature is valid (and not malleable), return the signer address
        if ((signer = ecrecover(hash, v, r, s)) == address(0)) revert InvalidSignature();
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * replicates the behavior of the
     * https://github.com/ethereum/wiki/wiki/JSON-RPC#eth_sign[`eth_sign`]
     * JSON-RPC method.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked('\x19Ethereum Signed Message:\n32', hash));
    }
}

// File: contracts/DepositHandler.sol

pragma solidity 0.8.9;

contract DepositHandler {
    error IsLocked();
    error NotContract();

    uint256 internal constant IS_NOT_LOCKED = uint256(1);
    uint256 internal constant IS_LOCKED = uint256(2);

    uint256 internal _lockedStatus = IS_NOT_LOCKED;

    modifier noReenter() {
        if (_lockedStatus == IS_LOCKED) revert IsLocked();

        _lockedStatus = IS_LOCKED;
        _;
        _lockedStatus = IS_NOT_LOCKED;
    }

    function execute(address callee, bytes calldata data) external noReenter returns (bool success, bytes memory returnData) {
        if (callee.code.length == 0) revert NotContract();
        (success, returnData) = callee.call(data);
    }

    // NOTE: The gateway should always destroy the `DepositHandler` in the same runtime context that deploys it.
    function destroy(address etherDestination) external noReenter {
        selfdestruct(payable(etherDestination));
    }
}

// File: contracts/EternalStorage.sol

pragma solidity 0.8.9;

/**
 * @title EternalStorage
 * @dev This contract holds all the necessary state variables to carry out the storage of any contract.
 */
contract EternalStorage {
    mapping(bytes32 => uint256) private _uintStorage;
    mapping(bytes32 => string) private _stringStorage;
    mapping(bytes32 => address) private _addressStorage;
    mapping(bytes32 => bytes) private _bytesStorage;
    mapping(bytes32 => bool) private _boolStorage;
    mapping(bytes32 => int256) private _intStorage;

    // *** Getter Methods ***
    function getUint(bytes32 key) public view returns (uint256) {
        return _uintStorage[key];
    }

    function getString(bytes32 key) public view returns (string memory) {
        return _stringStorage[key];
    }

    function getAddress(bytes32 key) public view returns (address) {
        return _addressStorage[key];
    }

    function getBytes(bytes32 key) public view returns (bytes memory) {
        return _bytesStorage[key];
    }

    function getBool(bytes32 key) public view returns (bool) {
        return _boolStorage[key];
    }

    function getInt(bytes32 key) public view returns (int256) {
        return _intStorage[key];
    }

    // *** Setter Methods ***
    function _setUint(bytes32 key, uint256 value) internal {
        _uintStorage[key] = value;
    }

    function _setString(bytes32 key, string memory value) internal {
        _stringStorage[key] = value;
    }

    function _setAddress(bytes32 key, address value) internal {
        _addressStorage[key] = value;
    }

    function _setBytes(bytes32 key, bytes memory value) internal {
        _bytesStorage[key] = value;
    }

    function _setBool(bytes32 key, bool value) internal {
        _boolStorage[key] = value;
    }

    function _setInt(bytes32 key, int256 value) internal {
        _intStorage[key] = value;
    }

    // *** Delete Methods ***
    function _deleteUint(bytes32 key) internal {
        delete _uintStorage[key];
    }

    function _deleteString(bytes32 key) internal {
        delete _stringStorage[key];
    }

    function _deleteAddress(bytes32 key) internal {
        delete _addressStorage[key];
    }

    function _deleteBytes(bytes32 key) internal {
        delete _bytesStorage[key];
    }

    function _deleteBool(bytes32 key) internal {
        delete _boolStorage[key];
    }

    function _deleteInt(bytes32 key) internal {
        delete _intStorage[key];
    }
}

// File: contracts/AxelarGateway.sol

pragma solidity ^0.8.0;

















/**
 * @title AxelarGateway Contract
 * @notice This contract serves as the gateway for cross-chain contract calls,
 * and token transfers within the Axelar network.
 * It includes functions for sending tokens, calling contracts, and validating contract calls.
 * The contract is managed via the decentralized governance mechanism on the Axelar network.
 * @dev EternalStorage is used to simplify storage for upgradability, and InterchainGovernance module is used for governance.
 */
contract AxelarGateway is IAxelarGateway, Implementation, EternalStorage {
    using SafeTokenCall for IERC20;
    using SafeTokenTransfer for IERC20;
    using SafeTokenTransferFrom for IERC20;
    using ContractAddress for address;

    error InvalidImplementation();

    enum TokenType {
        InternalBurnable,
        InternalBurnableFrom,
        External
    }

    /**
     * @dev Deprecated slots. Should not be reused.
     */
    // bytes32 internal constant KEY_ALL_TOKENS_FROZEN = keccak256('all-tokens-frozen');
    // bytes32 internal constant PREFIX_TOKEN_FROZEN = keccak256('token-frozen');

    /**
     * @dev Storage slot with the address of the current implementation. `keccak256('eip1967.proxy.implementation') - 1`.
     */
    bytes32 internal constant KEY_IMPLEMENTATION = bytes32(0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc);

    /**
     * @dev Storage slot with the address of the current governance. keccak256('governance')) - 1
     */
    bytes32 internal constant KEY_GOVERNANCE = bytes32(0xabea6fd3db56a6e6d0242111b43ebb13d1c42709651c032c7894962023a1f909);

    /**
     * @dev Storage slot with the address of the current mint limiter. keccak256('mint-limiter')) - 1
     */
    bytes32 internal constant KEY_MINT_LIMITER = bytes32(0x627f0c11732837b3240a2de89c0b6343512886dd50978b99c76a68c6416a4d92);

    bytes32 internal constant PREFIX_COMMAND_EXECUTED = keccak256('command-executed');
    bytes32 internal constant PREFIX_TOKEN_ADDRESS = keccak256('token-address');
    bytes32 internal constant PREFIX_TOKEN_TYPE = keccak256('token-type');
    bytes32 internal constant PREFIX_CONTRACT_CALL_APPROVED = keccak256('contract-call-approved');
    bytes32 internal constant PREFIX_CONTRACT_CALL_APPROVED_WITH_MINT = keccak256('contract-call-approved-with-mint');
    bytes32 internal constant PREFIX_TOKEN_MINT_LIMIT = keccak256('token-mint-limit');
    bytes32 internal constant PREFIX_TOKEN_MINT_AMOUNT = keccak256('token-mint-amount');

    bytes32 internal constant SELECTOR_BURN_TOKEN = keccak256('burnToken');
    bytes32 internal constant SELECTOR_DEPLOY_TOKEN = keccak256('deployToken');
    bytes32 internal constant SELECTOR_MINT_TOKEN = keccak256('mintToken');
    bytes32 internal constant SELECTOR_APPROVE_CONTRACT_CALL = keccak256('approveContractCall');
    bytes32 internal constant SELECTOR_APPROVE_CONTRACT_CALL_WITH_MINT = keccak256('approveContractCallWithMint');
    bytes32 internal constant SELECTOR_TRANSFER_OPERATORSHIP = keccak256('transferOperatorship');

    address public immutable authModule;
    address public immutable tokenDeployer;

    /**
     * @notice Constructs the AxelarGateway contract.
     * @param authModule_ The address of the authentication module
     * @param tokenDeployer_ The address of the token deployer
     */
    constructor(address authModule_, address tokenDeployer_) {
        if (authModule_.code.length == 0) revert InvalidAuthModule();
        if (tokenDeployer_.code.length == 0) revert InvalidTokenDeployer();

        authModule = authModule_;
        tokenDeployer = tokenDeployer_;
    }

    /**
     * @notice Ensures that the caller of the function is the gateway contract itself.
     */
    modifier onlySelf() {
        if (msg.sender != address(this)) revert NotSelf();

        _;
    }

    /**
     * @notice Ensures that the caller of the function is the governance address.
     */
    modifier onlyGovernance() {
        if (msg.sender != getAddress(KEY_GOVERNANCE)) revert NotGovernance();

        _;
    }

    /**
     * @notice Ensures that the caller of the function is either the mint limiter or governance.
     */
    modifier onlyMintLimiter() {
        if (msg.sender != getAddress(KEY_MINT_LIMITER) && msg.sender != getAddress(KEY_GOVERNANCE)) revert NotMintLimiter();

        _;
    }

    /******************\
    |* Public Methods *|
    \******************/

    /**
     * @notice Send the specified token to the destination chain and address.
     * @param destinationChain The chain to send tokens to. A registered chain name on Axelar must be used here
     * @param destinationAddress The address on the destination chain to send tokens to
     * @param symbol The symbol of the token to send
     * @param amount The amount of tokens to send
     */
    function sendToken(
        string calldata destinationChain,
        string calldata destinationAddress,
        string calldata symbol,
        uint256 amount
    ) external {
        _burnTokenFrom(msg.sender, symbol, amount);
        emit TokenSent(msg.sender, destinationChain, destinationAddress, symbol, amount);
    }

    /**
     * @notice Calls a contract on the specified destination chain with a given payload.
     * This function is the entry point for general message passing between chains.
     * @param destinationChain The chain where the destination contract exists. A registered chain name on Axelar must be used here
     * @param destinationContractAddress The address of the contract to call on the destination chain
     * @param payload The payload to be sent to the destination contract, usually representing an encoded function call with arguments
     */
    function callContract(
        string calldata destinationChain,
        string calldata destinationContractAddress,
        bytes calldata payload
    ) external {
        emit ContractCall(msg.sender, destinationChain, destinationContractAddress, keccak256(payload), payload);
    }

    /**
     * @notice Calls a contract on the specified destination chain with a given payload and token amount.
     * This function is the entry point for general message passing with token transfer between chains.
     * @param destinationChain The chain where the destination contract exists. A registered chain name on Axelar must be used here
     * @param destinationContractAddress The address of the contract to call with tokens on the destination chain
     * @param payload The payload to be sent to the destination contract, usually representing an encoded function call with arguments
     * @param symbol The symbol of the token to be sent with the call
     * @param amount The amount of tokens to be sent with the call
     */
    function callContractWithToken(
        string calldata destinationChain,
        string calldata destinationContractAddress,
        bytes calldata payload,
        string calldata symbol,
        uint256 amount
    ) external {
        _burnTokenFrom(msg.sender, symbol, amount);
        emit ContractCallWithToken(msg.sender, destinationChain, destinationContractAddress, keccak256(payload), payload, symbol, amount);
    }

    /**
     * @notice Checks whether a contract call has been approved by the gateway.
     * @param commandId The gateway command ID
     * @param sourceChain The source chain of the contract call
     * @param sourceAddress The source address of the contract call
     * @param contractAddress The contract address that will be called
     * @param payloadHash The hash of the payload for that will be sent with the call
     * @return bool A boolean value indicating whether the contract call has been approved by the gateway.
     */
    function isContractCallApproved(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        address contractAddress,
        bytes32 payloadHash
    ) external view override returns (bool) {
        return getBool(_getIsContractCallApprovedKey(commandId, sourceChain, sourceAddress, contractAddress, payloadHash));
    }

    /**
     * @notice Checks whether a contract call with token has been approved by the gateway.
     * @param commandId The gateway command ID
     * @param sourceChain The source chain of the contract call
     * @param sourceAddress The source address of the contract call
     * @param contractAddress The contract address that will be called, and where tokens will be sent
     * @param payloadHash The hash of the payload for that will be sent with the call
     * @param symbol The symbol of the token to be sent with the call
     * @param amount The amount of tokens to be sent with the call
     * @return bool A boolean value indicating whether the contract call with token has been approved by the gateway.
     */
    function isContractCallAndMintApproved(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        address contractAddress,
        bytes32 payloadHash,
        string calldata symbol,
        uint256 amount
    ) external view override returns (bool) {
        return
            getBool(
                _getIsContractCallApprovedWithMintKey(commandId, sourceChain, sourceAddress, contractAddress, payloadHash, symbol, amount)
            );
    }

    /**
     * @notice Called on the destination chain gateway by the recipient of the cross-chain contract call to validate it and only allow execution
     * if this function returns true.
     * @dev Once validated, the gateway marks the message as executed so the contract call is not executed twice.
     * @param commandId The gateway command ID
     * @param sourceChain The source chain of the contract call
     * @param sourceAddress The source address of the contract call
     * @param payloadHash The hash of the payload for that will be sent with the call
     * @return valid True if the contract call is approved, false otherwise
     */
    function validateContractCall(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes32 payloadHash
    ) external override returns (bool valid) {
        bytes32 key = _getIsContractCallApprovedKey(commandId, sourceChain, sourceAddress, msg.sender, payloadHash);
        valid = getBool(key);
        if (valid) {
            _setBool(key, false);

            emit ContractCallExecuted(commandId);
        }
    }

    /**
     * @notice Called on the destination chain gateway to validate the approval of a contract call with token transfer and only
     * allow execution if this function returns true.
     * @dev Once validated, the gateway marks the message as executed so the contract call with token is not executed twice.
     * @param commandId The gateway command ID
     * @param sourceChain The source chain of the contract call
     * @param sourceAddress The source address of the contract call
     * @param payloadHash The hash of the payload for that will be sent with the call
     * @param symbol The symbol of the token to be sent with the call
     * @param amount The amount of tokens to be sent with the call
     * @return valid True if the contract call with token is approved, false otherwise
     */
    function validateContractCallAndMint(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes32 payloadHash,
        string calldata symbol,
        uint256 amount
    ) external override returns (bool valid) {
        bytes32 key = _getIsContractCallApprovedWithMintKey(commandId, sourceChain, sourceAddress, msg.sender, payloadHash, symbol, amount);
        valid = getBool(key);
        if (valid) {
            // Prevent re-entrancy
            _setBool(key, false);

            emit ContractCallExecuted(commandId);

            _mintToken(symbol, msg.sender, amount);
        }
    }

    /***********\
    |* Getters *|
    \***********/

    /**
     * @notice Gets the address of governance, should be the address of InterchainGovernance.
     * @return address The address of governance.
     */
    function governance() public view override returns (address) {
        return getAddress(KEY_GOVERNANCE);
    }

    /**
     * @notice Gets the address of the mint limiter, should be the address of Multisig.
     * @return address The address of the mint limiter.
     */
    function mintLimiter() public view override returns (address) {
        return getAddress(KEY_MINT_LIMITER);
    }

    /**
     * @notice Gets the transfer limit for a specific token symbol within the configured epoch.
     * @param symbol The symbol of the token
     * @return uint The transfer limit for the given token.
     */
    function tokenMintLimit(string memory symbol) public view override returns (uint256) {
        return getUint(_getTokenMintLimitKey(symbol));
    }

    /**
     * @notice Gets the transfer amount for a specific token symbol within the configured epoch.
     * @param symbol The symbol of the token
     * @return uint The transfer amount for the given token.
     */
    function tokenMintAmount(string memory symbol) public view override returns (uint256) {
        return getUint(_getTokenMintAmountKey(symbol, block.timestamp / 6 hours));
    }

    /**
     * @dev This function is kept around to keep things working for internal
     * tokens that were deployed before the token freeze functionality was removed
     */
    function allTokensFrozen() external pure override returns (bool) {
        return false;
    }

    /**
     * @notice Gets the address of the gateway implementation contract.
     * @return address The address of the gateway implementation.
     */
    function implementation() public view override returns (address) {
        return getAddress(KEY_IMPLEMENTATION);
    }

    /**
     * @notice Gets the address of a specific token using its symbol.
     * @param symbol The symbol of the token
     * @return address The address of the token associated with the given symbol.
     */
    function tokenAddresses(string memory symbol) public view override returns (address) {
        return getAddress(_getTokenAddressKey(symbol));
    }

    /**
     * @dev Deprecated. This function is kept around to keep things working for internal tokens that were deployed before the token freeze functionality was removed
     */
    function tokenFrozen(string memory) external pure override returns (bool) {
        return false;
    }

    /**
     * @notice Checks whether a command with a given command ID has been executed.
     * @param commandId The command ID to check
     * @return bool True if the command has been executed, false otherwise
     */
    function isCommandExecuted(bytes32 commandId) public view override returns (bool) {
        return getBool(_getIsCommandExecutedKey(commandId));
    }

    /**
     * @notice Gets the contract ID of the Axelar Gateway.
     * @return bytes32 The keccak256 hash of the string 'axelar-gateway'
     */
    function contractId() public pure returns (bytes32) {
        return keccak256('axelar-gateway');
    }

    /************************\
    |* Governance Functions *|
    \************************/

    /**
     * @notice Transfers the governance role to a new address.
     * @param newGovernance The address to transfer the governance role to.
     * @dev Only the current governance entity can call this function.
     */
    function transferGovernance(address newGovernance) external override onlyGovernance {
        if (newGovernance == address(0)) revert InvalidGovernance();

        _transferGovernance(newGovernance);
    }

    /**
     * @notice Transfers the mint limiter role to a new address.
     * @param newMintLimiter The address to transfer the mint limiter role to.
     * @dev Only the current mint limiter or the governance address can call this function.
     */
    function transferMintLimiter(address newMintLimiter) external override onlyMintLimiter {
        if (newMintLimiter == address(0)) revert InvalidMintLimiter();

        _transferMintLimiter(newMintLimiter);
    }

    /**
     * @notice Sets the transfer limits for an array of tokens.
     * @param symbols The array of token symbols to set the transfer limits for
     * @param limits The array of transfer limits corresponding to the symbols
     * @dev Only the mint limiter or the governance address can call this function.
     */
    function setTokenMintLimits(string[] calldata symbols, uint256[] calldata limits) external override onlyMintLimiter {
        uint256 length = symbols.length;
        if (length != limits.length) revert InvalidSetMintLimitsParams();

        for (uint256 i; i < length; ++i) {
            string memory symbol = symbols[i];
            uint256 limit = limits[i];

            if (tokenAddresses(symbol) == address(0)) revert TokenDoesNotExist(symbol);

            _setTokenMintLimit(symbol, limit);
        }
    }

    /**
     * @notice Upgrades the contract to a new implementation.
     * @param newImplementation The address of the new implementation
     * @param newImplementationCodeHash The code hash of the new implementation
     * @param setupParams Optional setup params for the new implementation
     * @dev Only the governance address can call this function.
     */
    function upgrade(
        address newImplementation,
        bytes32 newImplementationCodeHash,
        bytes calldata setupParams
    ) external override onlyGovernance {
        if (newImplementationCodeHash != newImplementation.codehash) revert InvalidCodeHash();

        if (contractId() != IContractIdentifier(newImplementation).contractId()) revert InvalidImplementation();

        emit Upgraded(newImplementation);

        _setImplementation(newImplementation);

        if (setupParams.length != 0) {
            // slither-disable-next-line controlled-delegatecall
            (bool success, ) = newImplementation.delegatecall(abi.encodeWithSelector(IImplementation.setup.selector, setupParams));

            if (!success) revert SetupFailed();
        }
    }

    /**********************\
    |* External Functions *|
    \**********************/

    /**
     * @notice Sets up the governance and mint limiter roles, and transfers operatorship if necessary.
     * This function is called by the proxy during initial deployment, and optionally called during gateway upgrades.
     * @param params The encoded parameters containing the governance and mint limiter addresses, as well as the new operator data.
     * @dev Not publicly accessible as it's overshadowed in the proxy.
     */
    function setup(bytes calldata params) external override(IImplementation, Implementation) onlyProxy {
        (address governance_, address mintLimiter_, bytes memory newOperatorsData) = abi.decode(params, (address, address, bytes));

        if (governance_ != address(0)) _transferGovernance(governance_);
        if (mintLimiter_ != address(0)) _transferMintLimiter(mintLimiter_);

        if (newOperatorsData.length != 0) {
            emit OperatorshipTransferred(newOperatorsData);

            IAxelarAuth(authModule).transferOperatorship(newOperatorsData);
        }
    }

    /**
     * @notice Executes a batch of commands signed by the Axelar network. There are a finite set of command types that can be executed.
     * @param input The encoded input containing the data for the batch of commands, as well as the proof that verifies the integrity of the data.
     * @dev Each command has a corresponding commandID that is guaranteed to be unique from the Axelar network.
     * @dev This function allows retrying a commandID if the command initially failed to be processed.
     * @dev Ignores unknown commands or duplicate commandIDs.
     * @dev Emits an Executed event for successfully executed commands.
     */
    // slither-disable-next-line cyclomatic-complexity
    function execute(bytes calldata input) external override {
        (bytes memory data, bytes memory proof) = abi.decode(input, (bytes, bytes));

        bytes32 messageHash = ECDSA.toEthSignedMessageHash(keccak256(data));

        // returns true for current operators
        // slither-disable-next-line reentrancy-no-eth
        bool allowOperatorshipTransfer = IAxelarAuth(authModule).validateProof(messageHash, proof);

        uint256 chainId;
        bytes32[] memory commandIds;
        string[] memory commands;
        bytes[] memory params;

        (chainId, commandIds, commands, params) = abi.decode(data, (uint256, bytes32[], string[], bytes[]));

        if (chainId != block.chainid) revert InvalidChainId();

        uint256 commandsLength = commandIds.length;

        if (commandsLength != commands.length || commandsLength != params.length) revert InvalidCommands();

        for (uint256 i; i < commandsLength; ++i) {
            bytes32 commandId = commandIds[i];

            // Ignore if duplicate commandId received
            if (isCommandExecuted(commandId)) continue;

            bytes4 commandSelector;
            bytes32 commandHash = keccak256(abi.encodePacked(commands[i]));

            if (commandHash == SELECTOR_DEPLOY_TOKEN) {
                commandSelector = AxelarGateway.deployToken.selector;
            } else if (commandHash == SELECTOR_MINT_TOKEN) {
                commandSelector = AxelarGateway.mintToken.selector;
            } else if (commandHash == SELECTOR_APPROVE_CONTRACT_CALL) {
                commandSelector = AxelarGateway.approveContractCall.selector;
            } else if (commandHash == SELECTOR_APPROVE_CONTRACT_CALL_WITH_MINT) {
                commandSelector = AxelarGateway.approveContractCallWithMint.selector;
            } else if (commandHash == SELECTOR_BURN_TOKEN) {
                commandSelector = AxelarGateway.burnToken.selector;
            } else if (commandHash == SELECTOR_TRANSFER_OPERATORSHIP) {
                if (!allowOperatorshipTransfer) continue;

                allowOperatorshipTransfer = false;
                commandSelector = AxelarGateway.transferOperatorship.selector;
            } else {
                // Ignore unknown commands
                continue;
            }

            // Prevent a re-entrancy from executing this command before it can be marked as successful.
            _setCommandExecuted(commandId, true);

            // slither-disable-next-line calls-loop,reentrancy-no-eth
            (bool success, ) = address(this).call(abi.encodeWithSelector(commandSelector, params[i], commandId));

            // slither-disable-next-line reentrancy-events
            if (success) emit Executed(commandId);
            else _setCommandExecuted(commandId, false);
        }
    }

    /******************\
    |* Self Functions *|
    \******************/

    /**
     * @notice Deploys a new token or registers an existing token in the gateway contract itself.
     * @param params Encoded parameters including the token name, symbol, decimals, cap, token address, and mint limit
     * @dev If the token address is not specified, a new token is deployed and registed as InternalBurnableFrom
     * @dev If the token address is specified, the token is marked as External.
     * @dev Emits a TokenDeployed event with the symbol and token address.
     */
    function deployToken(bytes calldata params, bytes32) external onlySelf {
        (string memory name, string memory symbol, uint8 decimals, uint256 cap, address tokenAddress, uint256 mintLimit) = abi.decode(
            params,
            (string, string, uint8, uint256, address, uint256)
        );

        // Ensure that this symbol has not been taken.
        if (tokenAddresses(symbol) != address(0)) revert TokenAlreadyExists(symbol);

        _setTokenMintLimit(symbol, mintLimit);

        if (tokenAddress == address(0)) {
            // If token address is not specified, it indicates a request to deploy one.
            bytes32 salt = keccak256(abi.encodePacked(symbol));

            _setTokenType(symbol, TokenType.InternalBurnableFrom);

            // slither-disable-next-line reentrancy-no-eth,controlled-delegatecall
            (bool success, bytes memory data) = tokenDeployer.delegatecall(
                abi.encodeWithSelector(ITokenDeployer.deployToken.selector, name, symbol, decimals, cap, salt)
            );

            if (!success) revert TokenDeployFailed(symbol);

            tokenAddress = abi.decode(data, (address));
        } else {
            // If token address is specified, ensure that there is a contact at the specified address.
            if (tokenAddress.code.length == uint256(0)) revert TokenContractDoesNotExist(tokenAddress);

            // Mark that this symbol is an external token, which is needed to differentiate between operations on mint and burn.
            _setTokenType(symbol, TokenType.External);
        }

        // slither-disable-next-line reentrancy-events
        emit TokenDeployed(symbol, tokenAddress);

        _setTokenAddress(symbol, tokenAddress);
    }

    /**
     * @notice Transfers a specific amount of tokens to an account, based on the provided symbol.
     * @param params Encoded parameters including the token symbol, recipient address, and amount to mint.
     * @dev This function will revert if the token is not registered with the gatewaty.
     * @dev If the token type is External, a safe transfer is performed to the recipient account.
     * @dev If the token type is Internal (InternalBurnable or InternalBurnableFrom), the mint function is called on the token address.
     */
    function mintToken(bytes calldata params, bytes32) external onlySelf {
        (string memory symbol, address account, uint256 amount) = abi.decode(params, (string, address, uint256));

        _mintToken(symbol, account, amount);
    }

    /**
     * @notice Burns tokens of a given symbol, either through an external deposit handler or a token defined burn method.
     * @param params Encoded parameters including the token symbol and a salt value for the deposit handler
     */
    function burnToken(bytes calldata params, bytes32) external onlySelf {
        (string memory symbol, bytes32 salt) = abi.decode(params, (string, bytes32));

        address tokenAddress = tokenAddresses(symbol);

        if (tokenAddress == address(0)) revert TokenDoesNotExist(symbol);

        if (_getTokenType(symbol) == TokenType.External) {
            address depositHandlerAddress = _getCreate2Address(salt, keccak256(abi.encodePacked(type(DepositHandler).creationCode)));

            if (depositHandlerAddress.isContract()) return;

            DepositHandler depositHandler = new DepositHandler{ salt: salt }();

            (bool success, bytes memory returnData) = depositHandler.execute(
                tokenAddress,
                abi.encodeWithSelector(IERC20.transfer.selector, address(this), IERC20(tokenAddress).balanceOf(address(depositHandler)))
            );

            if (!success || (returnData.length != uint256(0) && !abi.decode(returnData, (bool)))) revert BurnFailed(symbol);

            // NOTE: `depositHandler` must always be destroyed in the same runtime context that it is deployed.
            depositHandler.destroy(address(this));
        } else {
            IBurnableMintableCappedERC20(tokenAddress).burn(salt);
        }
    }

    /**
     * @notice Approves a contract call.
     * @param params Encoded parameters including the source chain, source address, contract address, payload hash, transaction hash, and event index
     * @param commandId to associate with the approval
     */
    function approveContractCall(bytes calldata params, bytes32 commandId) external onlySelf {
        (
            string memory sourceChain,
            string memory sourceAddress,
            address contractAddress,
            bytes32 payloadHash,
            bytes32 sourceTxHash,
            uint256 sourceEventIndex
        ) = abi.decode(params, (string, string, address, bytes32, bytes32, uint256));

        _setContractCallApproved(commandId, sourceChain, sourceAddress, contractAddress, payloadHash);
        emit ContractCallApproved(commandId, sourceChain, sourceAddress, contractAddress, payloadHash, sourceTxHash, sourceEventIndex);
    }

    /**
     * @notice Approves a contract call with token transfer.
     * @param params Encoded parameters including the source chain, source address, contract address, payload hash, token symbol,
     * token amount, transaction hash, and event index.
     * @param commandId to associate with the approval
     */
    function approveContractCallWithMint(bytes calldata params, bytes32 commandId) external onlySelf {
        (
            string memory sourceChain,
            string memory sourceAddress,
            address contractAddress,
            bytes32 payloadHash,
            string memory symbol,
            uint256 amount,
            bytes32 sourceTxHash,
            uint256 sourceEventIndex
        ) = abi.decode(params, (string, string, address, bytes32, string, uint256, bytes32, uint256));

        _setContractCallApprovedWithMint(commandId, sourceChain, sourceAddress, contractAddress, payloadHash, symbol, amount);
        emit ContractCallApprovedWithMint(
            commandId,
            sourceChain,
            sourceAddress,
            contractAddress,
            payloadHash,
            symbol,
            amount,
            sourceTxHash,
            sourceEventIndex
        );
    }

    /**
     * @notice Transfers operatorship with the provided data by calling the transferOperatorship function on the auth module.
     * @param newOperatorsData Encoded data for the new operators
     */
    function transferOperatorship(bytes calldata newOperatorsData, bytes32) external onlySelf {
        emit OperatorshipTransferred(newOperatorsData);

        IAxelarAuth(authModule).transferOperatorship(newOperatorsData);
    }

    /********************\
    |* Internal Methods *|
    \********************/

    function _mintToken(
        string memory symbol,
        address account,
        uint256 amount
    ) internal {
        address tokenAddress = tokenAddresses(symbol);

        if (tokenAddress == address(0)) revert TokenDoesNotExist(symbol);

        _setTokenMintAmount(symbol, tokenMintAmount(symbol) + amount);

        if (_getTokenType(symbol) == TokenType.External) {
            IERC20(tokenAddress).safeTransfer(account, amount);
        } else {
            IBurnableMintableCappedERC20(tokenAddress).mint(account, amount);
        }
    }

    /**
     * @notice Burns or locks a specific amount of tokens from a sender's account based on the provided symbol.
     * @param sender Address of the account from which to burn the tokens
     * @param symbol Symbol of the token to burn
     * @param amount Amount of tokens to burn
     * @dev Depending on the token type (External, InternalBurnableFrom, or InternalBurnable), the function either
     * transfers the tokens to gateway contract itself or calls a burn function on the token contract.
     */
    function _burnTokenFrom(
        address sender,
        string memory symbol,
        uint256 amount
    ) internal {
        address tokenAddress = tokenAddresses(symbol);

        if (tokenAddress == address(0)) revert TokenDoesNotExist(symbol);
        if (amount == 0) revert InvalidAmount();

        TokenType tokenType = _getTokenType(symbol);

        if (tokenType == TokenType.External) {
            IERC20(tokenAddress).safeTransferFrom(sender, address(this), amount);
        } else if (tokenType == TokenType.InternalBurnableFrom) {
            IERC20(tokenAddress).safeCall(abi.encodeWithSelector(IBurnableMintableCappedERC20.burnFrom.selector, sender, amount));
        } else {
            IERC20(tokenAddress).safeTransferFrom(sender, IBurnableMintableCappedERC20(tokenAddress).depositAddress(bytes32(0)), amount);
            IBurnableMintableCappedERC20(tokenAddress).burn(bytes32(0));
        }
    }

    /********************\
    |* Pure Key Getters *|
    \********************/

    function _getTokenMintLimitKey(string memory symbol) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(PREFIX_TOKEN_MINT_LIMIT, symbol));
    }

    function _getTokenMintAmountKey(string memory symbol, uint256 day) internal pure returns (bytes32) {
        return keccak256(abi.encode(PREFIX_TOKEN_MINT_AMOUNT, symbol, day));
    }

    function _getTokenTypeKey(string memory symbol) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(PREFIX_TOKEN_TYPE, symbol));
    }

    function _getTokenAddressKey(string memory symbol) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(PREFIX_TOKEN_ADDRESS, symbol));
    }

    function _getIsCommandExecutedKey(bytes32 commandId) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(PREFIX_COMMAND_EXECUTED, commandId));
    }

    function _getIsContractCallApprovedKey(
        bytes32 commandId,
        string memory sourceChain,
        string memory sourceAddress,
        address contractAddress,
        bytes32 payloadHash
    ) internal pure returns (bytes32) {
        return keccak256(abi.encode(PREFIX_CONTRACT_CALL_APPROVED, commandId, sourceChain, sourceAddress, contractAddress, payloadHash));
    }

    function _getIsContractCallApprovedWithMintKey(
        bytes32 commandId,
        string memory sourceChain,
        string memory sourceAddress,
        address contractAddress,
        bytes32 payloadHash,
        string memory symbol,
        uint256 amount
    ) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    PREFIX_CONTRACT_CALL_APPROVED_WITH_MINT,
                    commandId,
                    sourceChain,
                    sourceAddress,
                    contractAddress,
                    payloadHash,
                    symbol,
                    amount
                )
            );
    }

    /********************\
    |* Internal Getters *|
    \********************/

    function _getCreate2Address(bytes32 salt, bytes32 codeHash) internal view returns (address) {
        return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xff), address(this), salt, codeHash)))));
    }

    function _getTokenType(string memory symbol) internal view returns (TokenType) {
        return TokenType(getUint(_getTokenTypeKey(symbol)));
    }

    /********************\
    |* Internal Setters *|
    \********************/

    function _setTokenMintLimit(string memory symbol, uint256 limit) internal {
        emit TokenMintLimitUpdated(symbol, limit);

        _setUint(_getTokenMintLimitKey(symbol), limit);
    }

    function _setTokenMintAmount(string memory symbol, uint256 amount) internal {
        uint256 limit = tokenMintLimit(symbol);
        if (limit > 0 && amount > limit) revert ExceedMintLimit(symbol);

        _setUint(_getTokenMintAmountKey(symbol, block.timestamp / 6 hours), amount);
    }

    function _setTokenType(string memory symbol, TokenType tokenType) internal {
        _setUint(_getTokenTypeKey(symbol), uint256(tokenType));
    }

    function _setTokenAddress(string memory symbol, address tokenAddress) internal {
        _setAddress(_getTokenAddressKey(symbol), tokenAddress);
    }

    function _setCommandExecuted(bytes32 commandId, bool executed) internal {
        _setBool(_getIsCommandExecutedKey(commandId), executed);
    }

    function _setContractCallApproved(
        bytes32 commandId,
        string memory sourceChain,
        string memory sourceAddress,
        address contractAddress,
        bytes32 payloadHash
    ) internal {
        _setBool(_getIsContractCallApprovedKey(commandId, sourceChain, sourceAddress, contractAddress, payloadHash), true);
    }

    function _setContractCallApprovedWithMint(
        bytes32 commandId,
        string memory sourceChain,
        string memory sourceAddress,
        address contractAddress,
        bytes32 payloadHash,
        string memory symbol,
        uint256 amount
    ) internal {
        _setBool(
            _getIsContractCallApprovedWithMintKey(commandId, sourceChain, sourceAddress, contractAddress, payloadHash, symbol, amount),
            true
        );
    }

    function _setImplementation(address newImplementation) internal {
        _setAddress(KEY_IMPLEMENTATION, newImplementation);
    }

    function _transferGovernance(address newGovernance) internal {
        emit GovernanceTransferred(getAddress(KEY_GOVERNANCE), newGovernance);

        _setAddress(KEY_GOVERNANCE, newGovernance);
    }

    function _transferMintLimiter(address newMintLimiter) internal {
        emit MintLimiterTransferred(getAddress(KEY_MINT_LIMITER), newMintLimiter);

        _setAddress(KEY_MINT_LIMITER, newMintLimiter);
    }
}

// File: @axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarExecutable.sol

pragma solidity ^0.8.0;



interface IAxelarExecutable {
    error InvalidAddress();
    error NotApprovedByGateway();

    function gateway() external view returns (IAxelarGateway);

    function execute(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload
    ) external;

    function executeWithToken(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload,
        string calldata tokenSymbol,
        uint256 amount
    ) external;
}

// File: @axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol

pragma solidity ^0.8.0;




contract AxelarExecutable is IAxelarExecutable {
    IAxelarGateway public immutable gateway;

    constructor(address gateway_) {
        if (gateway_ == address(0)) revert InvalidAddress();

        gateway = IAxelarGateway(gateway_);
    }

    function execute(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload
    ) external {
        bytes32 payloadHash = keccak256(payload);

        if (!gateway.validateContractCall(commandId, sourceChain, sourceAddress, payloadHash))
            revert NotApprovedByGateway();

        _execute(sourceChain, sourceAddress, payload);
    }

    function executeWithToken(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload,
        string calldata tokenSymbol,
        uint256 amount
    ) external {
        bytes32 payloadHash = keccak256(payload);

        if (
            !gateway.validateContractCallAndMint(
                commandId,
                sourceChain,
                sourceAddress,
                payloadHash,
                tokenSymbol,
                amount
            )
        ) revert NotApprovedByGateway();

        _executeWithToken(sourceChain, sourceAddress, payload, tokenSymbol, amount);
    }

    function _execute(
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload
    ) internal virtual {}

    function _executeWithToken(
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload,
        string calldata tokenSymbol,
        uint256 amount
    ) internal virtual {}
}

// File: @axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IUpgradable.sol

pragma solidity ^0.8.0;




// General interface for upgradable contracts
interface IUpgradable is IOwnable, IImplementation {
    error InvalidCodeHash();
    error InvalidImplementation();
    error SetupFailed();

    event Upgraded(address indexed newImplementation);

    function implementation() external view returns (address);

    function upgrade(
        address newImplementation,
        bytes32 newImplementationCodeHash,
        bytes calldata params
    ) external;
}

// File: @axelar-network/axelar-gmp-sdk-solidity/contracts/libs/Bytes32String.sol

pragma solidity ^0.8.0;

library StringToBytes32 {
    error InvalidStringLength();

    function toBytes32(string memory str) internal pure returns (bytes32) {
        // Converting a string to bytes32 for immutable storage
        bytes memory stringBytes = bytes(str);

        // We can store up to 31 bytes of data as 1 byte is for encoding length
        if (stringBytes.length == 0 || stringBytes.length > 31) revert InvalidStringLength();

        uint256 stringNumber = uint256(bytes32(stringBytes));

        // Storing string length as the last byte of the data
        stringNumber |= 0xff & stringBytes.length;
        return bytes32(stringNumber);
    }
}

library Bytes32ToString {
    function toTrimmedString(bytes32 stringData) internal pure returns (string memory converted) {
        // recovering string length as the last byte of the data
        uint256 length = 0xff & uint256(stringData);

        // restoring the string with the correct length
        assembly {
            converted := mload(0x40)
            // new "memory end" including padding (the string isn't larger than 32 bytes)
            mstore(0x40, add(converted, 0x40))
            // store length in memory
            mstore(converted, length)
            // write actual data
            mstore(add(converted, 0x20), stringData)
        }
    }
}

// File: @axelar-network/axelar-gmp-sdk-solidity/contracts/libs/SafeNativeTransfer.sol

pragma solidity ^0.8.0;

error NativeTransferFailed();

/*
 * @title SafeNativeTransfer
 * @dev This library is used for performing safe native value transfers in Solidity by utilizing inline assembly.
 */
library SafeNativeTransfer {
    /*
     * @notice Perform a native transfer to a given address.
     * @param receiver The recipient address to which the amount will be sent.
     * @param amount The amount of native value to send.
     * @throws NativeTransferFailed error if transfer is not successful.
     */
    function safeNativeTransfer(address receiver, uint256 amount) internal {
        bool success;

        assembly {
            success := call(gas(), receiver, amount, 0, 0, 0, 0)
        }

        if (!success) revert NativeTransferFailed();
    }
}

// File: @axelar-network/axelar-gmp-sdk-solidity/contracts/utils/Ownable.sol

pragma solidity ^0.8.0;



/**
 * @title Ownable
 * @notice A contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The owner account is set through ownership transfer. This module makes
 * it possible to transfer the ownership of the contract to a new account in one
 * step, as well as to an interim pending owner. In the second flow the ownership does not
 * change until the pending owner accepts the ownership transfer.
 */
abstract contract Ownable is IOwnable {
    // keccak256('owner')
    bytes32 internal constant _OWNER_SLOT = 0x02016836a56b71f0d02689e69e326f4f4c1b9057164ef592671cf0d37c8040c0;
    // keccak256('ownership-transfer')
    bytes32 internal constant _OWNERSHIP_TRANSFER_SLOT =
        0x9855384122b55936fbfb8ca5120e63c6537a1ac40caf6ae33502b3c5da8c87d1;

    /**
     * @notice Initializes the contract by transferring ownership to the owner parameter.
     * @param _owner Address to set as the initial owner of the contract
     */
    constructor(address _owner) {
        _transferOwnership(_owner);
    }

    /**
     * @notice Modifier that throws an error if called by any account other than the owner.
     */
    modifier onlyOwner() {
        if (owner() != msg.sender) revert NotOwner();

        _;
    }

    /**
     * @notice Returns the current owner of the contract.
     * @return owner_ The current owner of the contract
     */
    function owner() public view returns (address owner_) {
        assembly {
            owner_ := sload(_OWNER_SLOT)
        }
    }

    /**
     * @notice Returns the pending owner of the contract.
     * @return owner_ The pending owner of the contract
     */
    function pendingOwner() public view returns (address owner_) {
        assembly {
            owner_ := sload(_OWNERSHIP_TRANSFER_SLOT)
        }
    }

    /**
     * @notice Transfers ownership of the contract to a new account `newOwner`.
     * @dev Can only be called by the current owner.
     * @param newOwner The address to transfer ownership to
     */
    function transferOwnership(address newOwner) external virtual onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @notice Propose to transfer ownership of the contract to a new account `newOwner`.
     * @dev Can only be called by the current owner. The ownership does not change
     * until the new owner accepts the ownership transfer.
     * @param newOwner The address to transfer ownership to
     */
    function proposeOwnership(address newOwner) external virtual onlyOwner {
        if (newOwner == address(0)) revert InvalidOwnerAddress();

        emit OwnershipTransferStarted(newOwner);

        assembly {
            sstore(_OWNERSHIP_TRANSFER_SLOT, newOwner)
        }
    }

    /**
     * @notice Accepts ownership of the contract.
     * @dev Can only be called by the pending owner
     */
    function acceptOwnership() external virtual {
        address newOwner = pendingOwner();
        if (newOwner != msg.sender) revert InvalidOwner();

        _transferOwnership(newOwner);
    }

    /**
     * @notice Internal function to transfer ownership of the contract to a new account `newOwner`.
     * @dev Called in the constructor to set the initial owner.
     * @param newOwner The address to transfer ownership to
     */
    function _transferOwnership(address newOwner) internal virtual {
        if (newOwner == address(0)) revert InvalidOwnerAddress();

        emit OwnershipTransferred(newOwner);

        assembly {
            sstore(_OWNER_SLOT, newOwner)
            sstore(_OWNERSHIP_TRANSFER_SLOT, 0)
        }
    }
}

// File: @axelar-network/axelar-gmp-sdk-solidity/contracts/upgradable/Upgradable.sol

pragma solidity ^0.8.0;






/**
 * @title Upgradable Contract
 * @notice This contract provides an interface for upgradable smart contracts and includes the functionality to perform upgrades.
 */
abstract contract Upgradable is Ownable, Implementation, IUpgradable {
    // bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1)
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @notice Constructor sets the implementation address to the address of the contract itself
     * @dev This is used in the onlyProxy modifier to prevent certain functions from being called directly
     * on the implementation contract itself.
     * @dev The owner is initially set as address(1) because the actual owner is set within the proxy. It is not
     * set as the zero address because Ownable is designed to throw an error for ownership transfers to the zero address.
     */
    constructor() Ownable(address(1)) {}

    /**
     * @notice Returns the address of the current implementation
     * @return implementation_ Address of the current implementation
     */
    function implementation() public view returns (address implementation_) {
        assembly {
            implementation_ := sload(_IMPLEMENTATION_SLOT)
        }
    }

    /**
     * @notice Upgrades the contract to a new implementation
     * @param newImplementation The address of the new implementation contract
     * @param newImplementationCodeHash The codehash of the new implementation contract
     * @param params Optional setup parameters for the new implementation contract
     * @dev This function is only callable by the owner.
     */
    function upgrade(
        address newImplementation,
        bytes32 newImplementationCodeHash,
        bytes calldata params
    ) external override onlyOwner {
        if (IUpgradable(newImplementation).contractId() != IUpgradable(implementation()).contractId())
            revert InvalidImplementation();

        if (newImplementationCodeHash != newImplementation.codehash) revert InvalidCodeHash();

        emit Upgraded(newImplementation);

        if (params.length > 0) {
            // slither-disable-next-line controlled-delegatecall
            (bool success, ) = newImplementation.delegatecall(abi.encodeWithSelector(this.setup.selector, params));

            if (!success) revert SetupFailed();
        }

        assembly {
            sstore(_IMPLEMENTATION_SLOT, newImplementation)
        }
    }

    /**
     * @notice Sets up the contract with initial data
     * @param data Initialization data for the contract
     * @dev This function is only callable by the proxy contract.
     */
    function setup(bytes calldata data) external override(IImplementation, Implementation) onlyProxy {
        _setup(data);
    }

    /**
     * @notice Internal function to set up the contract with initial data
     * @param data Initialization data for the contract
     * @dev This function should be implemented in derived contracts.
     */
    function _setup(bytes calldata data) internal virtual {}
}

// File: contracts/interfaces/IAxelarGateway.sol

pragma solidity ^0.8.9;

interface IAxelarGateway {
    /**********\
    |* Errors *|
    \**********/

    error NotSelf();
    error NotProxy();
    error InvalidCodeHash();
    error SetupFailed();
    error InvalidAuthModule();
    error InvalidTokenDeployer();
    error InvalidAmount();
    error InvalidChainId();
    error InvalidCommands();
    error TokenDoesNotExist(string symbol);
    error TokenAlreadyExists(string symbol);
    error TokenDeployFailed(string symbol);
    error TokenContractDoesNotExist(address token);
    error BurnFailed(string symbol);
    error MintFailed(string symbol);
    error InvalidSetMintLimitsParams();
    error ExceedMintLimit(string symbol);

    /**********\
    |* Events *|
    \**********/

    event TokenSent(address indexed sender, string destinationChain, string destinationAddress, string symbol, uint256 amount);

    event ContractCall(
        address indexed sender,
        string destinationChain,
        string destinationContractAddress,
        bytes32 indexed payloadHash,
        bytes payload
    );

    event ContractCallWithToken(
        address indexed sender,
        string destinationChain,
        string destinationContractAddress,
        bytes32 indexed payloadHash,
        bytes payload,
        string symbol,
        uint256 amount
    );

    event Executed(bytes32 indexed commandId);

    event TokenDeployed(string symbol, address tokenAddresses);

    event ContractCallApproved(
        bytes32 indexed commandId,
        string sourceChain,
        string sourceAddress,
        address indexed contractAddress,
        bytes32 indexed payloadHash,
        bytes32 sourceTxHash,
        uint256 sourceEventIndex
    );

    event ContractCallApprovedWithMint(
        bytes32 indexed commandId,
        string sourceChain,
        string sourceAddress,
        address indexed contractAddress,
        bytes32 indexed payloadHash,
        string symbol,
        uint256 amount,
        bytes32 sourceTxHash,
        uint256 sourceEventIndex
    );

    event TokenMintLimitUpdated(string symbol, uint256 limit);

    event OperatorshipTransferred(bytes newOperatorsData);

    event Upgraded(address indexed implementation);

    /********************\
    |* Public Functions *|
    \********************/

    function sendToken(
        string calldata destinationChain,
        string calldata destinationAddress,
        string calldata symbol,
        uint256 amount
    ) external;

    function callContract(
        string calldata destinationChain,
        string calldata contractAddress,
        bytes calldata payload
    ) external;

    function callContractWithToken(
        string calldata destinationChain,
        string calldata contractAddress,
        bytes calldata payload,
        string calldata symbol,
        uint256 amount
    ) external;

    function isContractCallApproved(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        address contractAddress,
        bytes32 payloadHash
    ) external view returns (bool);

    function isContractCallAndMintApproved(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        address contractAddress,
        bytes32 payloadHash,
        string calldata symbol,
        uint256 amount
    ) external view returns (bool);

    function validateContractCall(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes32 payloadHash
    ) external returns (bool);

    function validateContractCallAndMint(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes32 payloadHash,
        string calldata symbol,
        uint256 amount
    ) external returns (bool);

    /***********\
    |* Getters *|
    \***********/

    function authModule() external view returns (address);

    function tokenDeployer() external view returns (address);

    function tokenMintLimit(string memory symbol) external view returns (uint256);

    function tokenMintAmount(string memory symbol) external view returns (uint256);

    function allTokensFrozen() external view returns (bool);

    function implementation() external view returns (address);

    function tokenAddresses(string memory symbol) external view returns (address);

    function tokenFrozen(string memory symbol) external view returns (bool);

    function isCommandExecuted(bytes32 commandId) external view returns (bool);

    function adminEpoch() external view returns (uint256);

    function adminThreshold(uint256 epoch) external view returns (uint256);

    function admins(uint256 epoch) external view returns (address[] memory);

    /*******************\
    |* Admin Functions *|
    \*******************/

    function setTokenMintLimits(string[] calldata symbols, uint256[] calldata limits) external;

    function upgrade(
        address newImplementation,
        bytes32 newImplementationCodeHash,
        bytes calldata setupParams
    ) external;

    /**********************\
    |* External Functions *|
    \**********************/

    function setup(bytes calldata params) external;

    function execute(bytes calldata input) external;
}

// File: contracts/ERC20.sol

pragma solidity 0.8.9;



/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is IERC20 {
    mapping(address => uint256) public override balanceOf;

    mapping(address => mapping(address => uint256)) public override allowance;

    uint256 public override totalSupply;

    string public name;
    string public symbol;

    uint8 public immutable decimals;

    /**
     * @dev Sets the values for {name}, {symbol}, and {decimals}.
     */
    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) {
        name = name_;
        symbol = symbol_;
        decimals = decimals_;
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) external virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) external virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external virtual override returns (bool) {
        uint256 _allowance = allowance[sender][msg.sender];

        if (_allowance != type(uint256).max) {
            _approve(sender, msg.sender, _allowance - amount);
        }

        _transfer(sender, recipient, amount);

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) external virtual returns (bool) {
        _approve(msg.sender, spender, allowance[msg.sender][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) external virtual returns (bool) {
        _approve(msg.sender, spender, allowance[msg.sender][spender] - subtractedValue);
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        if (sender == address(0) || recipient == address(0)) revert InvalidAccount();

        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        if (account == address(0)) revert InvalidAccount();

        totalSupply += amount;
        balanceOf[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        if (account == address(0)) revert InvalidAccount();

        balanceOf[account] -= amount;
        totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        if (owner == address(0) || spender == address(0)) revert InvalidAccount();

        allowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}

// File: contracts/ERC20Permit.sol

pragma solidity 0.8.9;






abstract contract ERC20Permit is IERC20, IERC20Permit, ERC20 {
    error PermitExpired();
    error InvalidS();
    error InvalidV();
    error InvalidSignature();

    bytes32 public immutable DOMAIN_SEPARATOR;

    string private constant EIP191_PREFIX_FOR_EIP712_STRUCTURED_DATA = '\x19\x01';

    // keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)')
    bytes32 private constant DOMAIN_TYPE_SIGNATURE_HASH = bytes32(0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f);

    // keccak256('Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)')
    bytes32 private constant PERMIT_SIGNATURE_HASH = bytes32(0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9);

    mapping(address => uint256) public nonces;

    constructor(string memory name) {
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(DOMAIN_TYPE_SIGNATURE_HASH, keccak256(bytes(name)), keccak256(bytes('1')), block.chainid, address(this))
        );
    }

    function permit(
        address issuer,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        if (block.timestamp > deadline) revert PermitExpired();

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) revert InvalidS();

        if (v != 27 && v != 28) revert InvalidV();

        bytes32 digest = keccak256(
            abi.encodePacked(
                EIP191_PREFIX_FOR_EIP712_STRUCTURED_DATA,
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_SIGNATURE_HASH, issuer, spender, value, nonces[issuer]++, deadline))
            )
        );

        address recoveredAddress = ecrecover(digest, v, r, s);

        if (recoveredAddress != issuer) revert InvalidSignature();

        // _approve will revert if issuer is address(0x0)
        _approve(issuer, spender, value);
    }
}

// File: contracts/Ownable.sol

pragma solidity 0.8.9;



abstract contract Ownable is IOwnable {
    address public owner;

    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    modifier onlyOwner() {
        if (owner != msg.sender) revert NotOwner();

        _;
    }

    function transferOwnership(address newOwner) external virtual onlyOwner {
        if (newOwner == address(0)) revert InvalidOwner();

        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

// File: contracts/MintableCappedERC20.sol

pragma solidity 0.8.9;







contract MintableCappedERC20 is IMintableCappedERC20, ERC20, ERC20Permit, Ownable {
    uint256 public immutable cap;

    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals,
        uint256 capacity
    ) ERC20(name, symbol, decimals) ERC20Permit(name) Ownable() {
        cap = capacity;
    }

    function mint(address account, uint256 amount) external onlyOwner {
        uint256 capacity = cap;

        _mint(account, amount);

        if (capacity == 0) return;

        if (totalSupply > capacity) revert CapExceeded();
    }
}

// File: contracts/BurnableMintableCappedERC20.sol

pragma solidity 0.8.9;







contract BurnableMintableCappedERC20 is IBurnableMintableCappedERC20, MintableCappedERC20 {
    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals,
        uint256 capacity
    ) MintableCappedERC20(name, symbol, decimals, capacity) {}

    function depositAddress(bytes32 salt) public view returns (address) {
        /* Convert a hash which is bytes32 to an address which is 20-byte long
        according to https://docs.soliditylang.org/en/v0.8.1/control-structures.html?highlight=create2#salted-contract-creations-create2 */
        return
            address(
                uint160(
                    uint256(
                        keccak256(
                            abi.encodePacked(bytes1(0xff), owner, salt, keccak256(abi.encodePacked(type(DepositHandler).creationCode)))
                        )
                    )
                )
            );
    }

    function burn(bytes32 salt) external onlyOwner {
        address account = depositAddress(salt);
        _burn(account, balanceOf[account]);
    }

    function burnFrom(address account, uint256 amount) external onlyOwner {
        uint256 _allowance = allowance[account][msg.sender];
        if (_allowance != type(uint256).max) {
            _approve(account, msg.sender, _allowance - amount);
        }
        _burn(account, amount);
    }
}

// File: contracts/TokenDeployer.sol

pragma solidity ^0.8.0;





contract TokenDeployer is ITokenDeployer {
    function deployToken(
        string calldata name,
        string calldata symbol,
        uint8 decimals,
        uint256 cap,
        bytes32 salt
    ) external returns (address tokenAddress) {
        tokenAddress = address(new BurnableMintableCappedERC20{ salt: salt }(name, symbol, decimals, cap));
    }
}

// File: contracts/interfaces/IAxelarAuthWeighted.sol

pragma solidity ^0.8.0;



interface IAxelarAuthWeighted is IAxelarAuth {
    error InvalidOperators();
    error InvalidThreshold();
    error DuplicateOperators();
    error MalformedSigners();
    error LowSignaturesWeight();
    error InvalidWeights();

    event OperatorshipTransferred(address[] newOperators, uint256[] newWeights, uint256 newThreshold);

    function currentEpoch() external view returns (uint256);

    function hashForEpoch(uint256 epoch) external view returns (bytes32);

    function epochForHash(bytes32 hash) external view returns (uint256);
}

// File: contracts/auth/AxelarAuthWeighted.sol

pragma solidity ^0.8.0;





contract AxelarAuthWeighted is Ownable, IAxelarAuthWeighted {
    uint256 public currentEpoch;
    mapping(uint256 => bytes32) public hashForEpoch;
    mapping(bytes32 => uint256) public epochForHash;

    uint256 internal constant OLD_KEY_RETENTION = 16;

    constructor(bytes[] memory recentOperators) Ownable(msg.sender) {
        uint256 length = recentOperators.length;

        for (uint256 i; i < length; ++i) {
            _transferOperatorship(recentOperators[i]);
        }
    }

    /**************************\
    |* External Functionality *|
    \**************************/

    /// @dev This function takes messageHash and proof data and reverts if proof is invalid
    /// @return True if provided operators are the current ones
    function validateProof(bytes32 messageHash, bytes calldata proof) external view returns (bool) {
        (address[] memory operators, uint256[] memory weights, uint256 threshold, bytes[] memory signatures) = abi.decode(
            proof,
            (address[], uint256[], uint256, bytes[])
        );

        bytes32 operatorsHash = keccak256(abi.encode(operators, weights, threshold));
        uint256 operatorsEpoch = epochForHash[operatorsHash];
        uint256 epoch = currentEpoch;

        if (operatorsEpoch == 0 || epoch - operatorsEpoch >= OLD_KEY_RETENTION) revert InvalidOperators();

        _validateSignatures(messageHash, operators, weights, threshold, signatures);

        return operatorsEpoch == epoch;
    }

    /***********************\
    |* Owner Functionality *|
    \***********************/

    function transferOperatorship(bytes calldata params) external onlyOwner {
        _transferOperatorship(params);
    }

    /**************************\
    |* Internal Functionality *|
    \**************************/

    function _transferOperatorship(bytes memory params) internal {
        (address[] memory newOperators, uint256[] memory newWeights, uint256 newThreshold) = abi.decode(
            params,
            (address[], uint256[], uint256)
        );
        uint256 operatorsLength = newOperators.length;
        uint256 weightsLength = newWeights.length;

        // operators must be sorted binary or alphabetically in lower case
        if (operatorsLength == 0 || !_isSortedAscAndContainsNoDuplicate(newOperators)) revert InvalidOperators();

        if (weightsLength != operatorsLength) revert InvalidWeights();

        uint256 totalWeight;
        for (uint256 i; i < weightsLength; ++i) {
            totalWeight = totalWeight + newWeights[i];
        }
        if (newThreshold == 0 || totalWeight < newThreshold) revert InvalidThreshold();

        bytes32 newOperatorsHash = keccak256(params);

        if (epochForHash[newOperatorsHash] != 0) revert DuplicateOperators();

        uint256 epoch = currentEpoch + 1;
        // slither-disable-next-line costly-loop
        currentEpoch = epoch;
        hashForEpoch[epoch] = newOperatorsHash;
        epochForHash[newOperatorsHash] = epoch;

        emit OperatorshipTransferred(newOperators, newWeights, newThreshold);
    }

    function _validateSignatures(
        bytes32 messageHash,
        address[] memory operators,
        uint256[] memory weights,
        uint256 threshold,
        bytes[] memory signatures
    ) internal pure {
        uint256 operatorsLength = operators.length;
        uint256 signaturesLength = signatures.length;
        uint256 operatorIndex;
        uint256 weight;
        // looking for signers within operators
        // assuming that both operators and signatures are sorted
        for (uint256 i; i < signaturesLength; ++i) {
            address signer = ECDSA.recover(messageHash, signatures[i]);
            // looping through remaining operators to find a match
            for (; operatorIndex < operatorsLength && signer != operators[operatorIndex]; ++operatorIndex) {}
            // checking if we are out of operators
            if (operatorIndex == operatorsLength) revert MalformedSigners();
            // accumulating signatures weight
            weight = weight + weights[operatorIndex];
            // weight needs to reach or surpass threshold
            if (weight >= threshold) return;
            // increasing operators index if match was found
            ++operatorIndex;
        }
        // if weight sum below threshold
        revert LowSignaturesWeight();
    }

    function _isSortedAscAndContainsNoDuplicate(address[] memory accounts) internal pure returns (bool) {
        uint256 accountsLength = accounts.length;
        address prevAccount = accounts[0];

        if (prevAccount == address(0)) return false;

        for (uint256 i = 1; i < accountsLength; ++i) {
            address currAccount = accounts[i];

            if (prevAccount >= currAccount) {
                return false;
            }

            prevAccount = currAccount;
        }

        return true;
    }
}

// File: contracts/interfaces/IDepositServiceBase.sol

pragma solidity ^0.8.0;

interface IDepositServiceBase {
    error InvalidAddress();
    error InvalidSymbol();
    error InvalidAmount();
    error NothingDeposited();
    error WrapFailed();
    error UnwrapFailed();
    error TokenApproveFailed();
    error NotRefundIssuer();
    error WrappedTokenNotSupported();

    function gateway() external returns (address);

    function wrappedSymbol() external returns (string memory);

    function wrappedToken() external returns (address);
}

// File: contracts/interfaces/IAxelarDepositService.sol

pragma solidity ^0.8.0;




interface IAxelarDepositService is IUpgradable, IDepositServiceBase {
    function sendNative(string calldata destinationChain, string calldata destinationAddress) external payable;

    function addressForTokenDeposit(
        bytes32 salt,
        address refundAddress,
        string calldata destinationChain,
        string calldata destinationAddress,
        string calldata tokenSymbol
    ) external view returns (address);

    function addressForNativeDeposit(
        bytes32 salt,
        address refundAddress,
        string calldata destinationChain,
        string calldata destinationAddress
    ) external view returns (address);

    function addressForNativeUnwrap(
        bytes32 salt,
        address refundAddress,
        address recipient
    ) external view returns (address);

    function sendTokenDeposit(
        bytes32 salt,
        address refundAddress,
        string calldata destinationChain,
        string calldata destinationAddress,
        string calldata tokenSymbol
    ) external;

    function refundTokenDeposit(
        bytes32 salt,
        address refundAddress,
        string calldata destinationChain,
        string calldata destinationAddress,
        string calldata tokenSymbol,
        address[] calldata refundTokens
    ) external;

    function sendNativeDeposit(
        bytes32 salt,
        address refundAddress,
        string calldata destinationChain,
        string calldata destinationAddress
    ) external;

    function refundNativeDeposit(
        bytes32 salt,
        address refundAddress,
        string calldata destinationChain,
        string calldata destinationAddress,
        address[] calldata refundTokens
    ) external;

    function nativeUnwrap(
        bytes32 salt,
        address refundAddress,
        address payable recipient
    ) external;

    function refundNativeUnwrap(
        bytes32 salt,
        address refundAddress,
        address payable recipient,
        address[] calldata refundTokens
    ) external;

    function refundLockedAsset(
        address receiver,
        address token,
        uint256 amount
    ) external;

    function receiverImplementation() external returns (address receiver);

    function refundToken() external returns (address);
}

// File: contracts/interfaces/IWETH9.sol

pragma solidity ^0.8.9;



// WETH9 specific interface
interface IWETH9 is IERC20 {
    function deposit() external payable;

    function withdraw(uint256 amount) external;
}

// File: contracts/deposit-service/DepositServiceBase.sol

pragma solidity ^0.8.0;






// This should be owned by the microservice that is paying for gas.
abstract contract DepositServiceBase is IDepositServiceBase {
    using SafeTokenTransfer for address;
    using StringToBytes32 for string;
    using Bytes32ToString for bytes32;

    // Using immutable storage to keep the constants in the bytecode
    address public immutable gateway;
    address public immutable wrappedTokenAddress;
    bytes32 internal immutable wrappedSymbolBytes;

    constructor(address gateway_, string memory wrappedSymbol_) {
        if (gateway_ == address(0)) revert InvalidAddress();

        bool wrappedTokenEnabled = bytes(wrappedSymbol_).length > 0;

        gateway = gateway_;
        wrappedTokenAddress = wrappedTokenEnabled ? IAxelarGateway(gateway_).tokenAddresses(wrappedSymbol_) : address(0);
        wrappedSymbolBytes = wrappedTokenEnabled ? wrappedSymbol_.toBytes32() : bytes32(0);

        // Wrapped token symbol param is optional
        // When specified we are checking if token exists in the gateway
        if (wrappedTokenEnabled && wrappedTokenAddress == address(0)) revert InvalidSymbol();
    }

    function wrappedToken() public view returns (address) {
        return wrappedTokenAddress;
    }

    // @dev Converts bytes32 from immutable storage into a string
    function wrappedSymbol() public view returns (string memory) {
        return wrappedSymbolBytes.toTrimmedString();
    }
}

// File: contracts/deposit-service/DepositReceiver.sol

pragma solidity ^0.8.0;



contract DepositReceiver {
    constructor(bytes memory delegateData, address refundAddress) {
        // Reading the implementation of the AxelarDepositService
        // and delegating the call back to it
        (bool success, ) = IAxelarDepositService(msg.sender).receiverImplementation().delegatecall(delegateData);

        // if not success revert with the original revert data
        if (!success) {
            assembly {
                let ptr := mload(0x40)
                let size := returndatasize()
                returndatacopy(ptr, 0, size)
                revert(ptr, size)
            }
        }

        if (refundAddress == address(0)) refundAddress = msg.sender;

        selfdestruct(payable(refundAddress));
    }

    // @dev This function is for receiving Ether from unwrapping WETH9
    receive() external payable {}
}

// File: contracts/deposit-service/ReceiverImplementation.sol

pragma solidity ^0.8.0;









// This should be owned by the microservice that is paying for gas.
contract ReceiverImplementation is DepositServiceBase {
    using SafeTokenTransfer for IERC20;
    using SafeNativeTransfer for address;

    constructor(address gateway_, string memory wrappedSymbol_) DepositServiceBase(gateway_, wrappedSymbol_) {}

    // @dev This function is used for delegate call by DepositReceiver
    // Context: msg.sender == AxelarDepositService, this == DepositReceiver
    function receiveAndSendToken(
        address refundAddress,
        string calldata destinationChain,
        string calldata destinationAddress,
        string calldata symbol
    ) external {
        address tokenAddress = IAxelarGateway(gateway).tokenAddresses(symbol);
        // Checking with AxelarDepositService if need to refund a token
        address refund = IAxelarDepositService(msg.sender).refundToken();

        if (refund != address(0)) {
            if (refundAddress == address(0)) refundAddress = msg.sender;
            IERC20(refund).safeTransfer(refundAddress, IERC20(refund).balanceOf(address(this)));
            return;
        }

        uint256 amount = IERC20(tokenAddress).balanceOf(address(this));

        if (tokenAddress == address(0)) revert InvalidSymbol();
        // slither-disable-next-line incorrect-equality
        if (amount == 0) revert NothingDeposited();

        // Not doing safe approval as gateway will revert anyway if approval fails
        // We expect allowance to always be 0 at this point
        // slither-disable-next-line unused-return
        IERC20(tokenAddress).approve(gateway, amount);
        // Sending the token trough the gateway
        IAxelarGateway(gateway).sendToken(destinationChain, destinationAddress, symbol, amount);
    }

    // @dev This function is used for delegate call by DepositReceiver
    // Context: msg.sender == AxelarDepositService, this == DepositReceiver
    function receiveAndSendNative(
        address refundAddress,
        string calldata destinationChain,
        string calldata destinationAddress
    ) external {
        address refund = IAxelarDepositService(msg.sender).refundToken();

        if (refund != address(0)) {
            if (refundAddress == address(0)) refundAddress = msg.sender;
            IERC20(refund).safeTransfer(refundAddress, IERC20(refund).balanceOf(address(this)));
            return;
        }

        uint256 amount = address(this).balance;

        if (wrappedTokenAddress == address(0)) revert WrappedTokenNotSupported();
        // slither-disable-next-line incorrect-equality
        if (amount == 0) revert NothingDeposited();

        // Wrapping the native currency and into WETH-like
        IWETH9(wrappedTokenAddress).deposit{ value: amount }();
        // Not doing safe approval as gateway will revert anyway if approval fails
        // We expect allowance to always be 0 at this point
        // slither-disable-next-line unused-return
        IWETH9(wrappedTokenAddress).approve(gateway, amount);
        // Sending the token trough the gateway
        IAxelarGateway(gateway).sendToken(destinationChain, destinationAddress, wrappedSymbol(), amount);
    }

    // @dev This function is used for delegate call by DepositReceiver
    // Context: msg.sender == AxelarDepositService, this == DepositReceiver
    function receiveAndUnwrapNative(address refundAddress, address recipient) external {
        address refund = IAxelarDepositService(msg.sender).refundToken();

        if (refund != address(0)) {
            if (refundAddress == address(0)) refundAddress = msg.sender;
            IERC20(refund).safeTransfer(refundAddress, IERC20(refund).balanceOf(address(this)));
            return;
        }

        uint256 amount = IERC20(wrappedTokenAddress).balanceOf(address(this));

        if (wrappedTokenAddress == address(0)) revert WrappedTokenNotSupported();
        // slither-disable-next-line incorrect-equality
        if (amount == 0) revert NothingDeposited();

        // Unwrapping the token into native currency and sending it to the recipient
        IWETH9(wrappedTokenAddress).withdraw(amount);
        recipient.safeNativeTransfer(amount);
    }
}

// File: contracts/deposit-service/AxelarDepositService.sol

pragma solidity ^0.8.0;












// This should be owned by the microservice that is paying for gas.
contract AxelarDepositService is Upgradable, DepositServiceBase, IAxelarDepositService {
    using SafeTokenTransfer for IERC20;
    using SafeNativeTransfer for address;

    // This public storage for ERC20 token intended to be refunded.
    // It triggers the DepositReceiver/ReceiverImplementation to switch into a refund mode.
    // Address is stored and deleted withing the same refund transaction.
    address public refundToken;

    address public immutable receiverImplementation;
    address public immutable refundIssuer;

    constructor(
        address gateway_,
        string memory wrappedSymbol_,
        address refundIssuer_
    ) DepositServiceBase(gateway_, wrappedSymbol_) {
        if (refundIssuer_ == address(0)) revert InvalidAddress();

        refundIssuer = refundIssuer_;
        receiverImplementation = address(new ReceiverImplementation(gateway_, wrappedSymbol_));
    }

    // @dev This method is meant to be called directly by user to send native token cross-chain
    function sendNative(string calldata destinationChain, string calldata destinationAddress) external payable {
        uint256 amount = msg.value;

        if (amount == 0) revert NothingDeposited();

        // Wrapping the native currency and into WETH-like token
        IWETH9(wrappedTokenAddress).deposit{ value: amount }();
        // Not doing safe approval as gateway will revert anyway if approval fails
        // We expect allowance to always be 0 at this point
        // slither-disable-next-line unused-return
        IWETH9(wrappedTokenAddress).approve(gateway, amount);
        // Sending the token trough the gateway
        IAxelarGateway(gateway).sendToken(destinationChain, destinationAddress, wrappedSymbol(), amount);
    }

    // @dev Generates a deposit address for sending an ERC20 token cross-chain
    function addressForTokenDeposit(
        bytes32 salt,
        address refundAddress,
        string calldata destinationChain,
        string calldata destinationAddress,
        string calldata tokenSymbol
    ) external view returns (address) {
        return
            _depositAddress(
                salt,
                abi.encodeWithSelector(
                    ReceiverImplementation.receiveAndSendToken.selector,
                    refundAddress,
                    destinationChain,
                    destinationAddress,
                    tokenSymbol
                ),
                refundAddress
            );
    }

    // @dev Generates a deposit address for sending native currency cross-chain
    function addressForNativeDeposit(
        bytes32 salt,
        address refundAddress,
        string calldata destinationChain,
        string calldata destinationAddress
    ) public view returns (address) {
        return
            _depositAddress(
                salt,
                abi.encodeWithSelector(
                    ReceiverImplementation.receiveAndSendNative.selector,
                    refundAddress,
                    destinationChain,
                    destinationAddress
                ),
                refundAddress
            );
    }

    // @dev Generates a deposit address for unwrapping WETH-like token into native currency
    function addressForNativeUnwrap(
        bytes32 salt,
        address refundAddress,
        address recipient
    ) external view returns (address) {
        return
            _depositAddress(
                salt,
                abi.encodeWithSelector(ReceiverImplementation.receiveAndUnwrapNative.selector, refundAddress, recipient),
                refundAddress
            );
    }

    // @dev Receives ERC20 token from the deposit address and sends it cross-chain
    function sendTokenDeposit(
        bytes32 salt,
        address refundAddress,
        string calldata destinationChain,
        string calldata destinationAddress,
        string calldata tokenSymbol
    ) external {
        // NOTE: `DepositReceiver` is destroyed in the same runtime context that it is deployed.
        new DepositReceiver{ salt: salt }(
            abi.encodeWithSelector(
                ReceiverImplementation.receiveAndSendToken.selector,
                refundAddress,
                destinationChain,
                destinationAddress,
                tokenSymbol
            ),
            refundAddress
        );
    }

    // @dev Refunds ERC20 tokens from the deposit address if they don't match the intended token
    // Only refundAddress can refund the token that was intended to go cross-chain (if not sent yet)
    function refundTokenDeposit(
        bytes32 salt,
        address refundAddress,
        string calldata destinationChain,
        string calldata destinationAddress,
        string calldata tokenSymbol,
        address[] calldata refundTokens
    ) external {
        address intendedToken = IAxelarGateway(gateway).tokenAddresses(tokenSymbol);

        uint256 tokensLength = refundTokens.length;
        for (uint256 i; i < tokensLength; ++i) {
            // Allowing only the refundAddress to refund the intended token
            if (refundTokens[i] == intendedToken && msg.sender != refundAddress) continue;

            // Saving to public storage to be accessed by the DepositReceiver
            // slither-disable-next-line costly-loop
            refundToken = refundTokens[i];
            // NOTE: `DepositReceiver` is destroyed in the same runtime context that it is deployed.
            // slither-disable-next-line reentrancy-benign
            new DepositReceiver{ salt: salt }(
                abi.encodeWithSelector(
                    ReceiverImplementation.receiveAndSendToken.selector,
                    refundAddress,
                    destinationChain,
                    destinationAddress,
                    tokenSymbol
                ),
                refundAddress
            );
        }

        refundToken = address(0);
    }

    // @dev Receives native currency, wraps it into WETH-like token and sends cross-chain
    function sendNativeDeposit(
        bytes32 salt,
        address refundAddress,
        string calldata destinationChain,
        string calldata destinationAddress
    ) external {
        // NOTE: `DepositReceiver` is destroyed in the same runtime context that it is deployed.
        new DepositReceiver{ salt: salt }(
            abi.encodeWithSelector(
                ReceiverImplementation.receiveAndSendNative.selector,
                refundAddress,
                destinationChain,
                destinationAddress
            ),
            refundAddress
        );
    }

    // @dev Refunds ERC20 tokens from the deposit address after the native deposit was sent
    // Only refundAddress can refund the native currency intended to go cross-chain (if not sent yet)
    function refundNativeDeposit(
        bytes32 salt,
        address refundAddress,
        string calldata destinationChain,
        string calldata destinationAddress,
        address[] calldata refundTokens
    ) external {
        // Allowing only the refundAddress to refund the native currency
        if (addressForNativeDeposit(salt, refundAddress, destinationChain, destinationAddress).balance > 0 && msg.sender != refundAddress)
            return;

        uint256 tokensLength = refundTokens.length;
        for (uint256 i; i < tokensLength; ++i) {
            // slither-disable-next-line costly-loop
            refundToken = refundTokens[i];
            // NOTE: `DepositReceiver` is destroyed in the same runtime context that it is deployed.
            // slither-disable-next-line reentrancy-benign
            new DepositReceiver{ salt: salt }(
                abi.encodeWithSelector(
                    ReceiverImplementation.receiveAndSendNative.selector,
                    refundAddress,
                    destinationChain,
                    destinationAddress
                ),
                refundAddress
            );
        }

        refundToken = address(0);
    }

    // @dev Receives WETH-like token, unwraps and send native currency to the recipient
    function nativeUnwrap(
        bytes32 salt,
        address refundAddress,
        address payable recipient
    ) external {
        // NOTE: `DepositReceiver` is destroyed in the same runtime context that it is deployed.
        new DepositReceiver{ salt: salt }(
            abi.encodeWithSelector(ReceiverImplementation.receiveAndUnwrapNative.selector, refundAddress, recipient),
            refundAddress
        );
    }

    // @dev Refunds ERC20 tokens from the deposit address except WETH-like token
    // Only refundAddress can refund the WETH-like token intended to be unwrapped (if not yet)
    function refundNativeUnwrap(
        bytes32 salt,
        address refundAddress,
        address payable recipient,
        address[] calldata refundTokens
    ) external {
        uint256 tokensLength = refundTokens.length;
        for (uint256 i; i < tokensLength; ++i) {
            // Allowing only the refundAddress to refund the intended WETH-like token
            if (refundTokens[i] == wrappedTokenAddress && msg.sender != refundAddress) continue;

            // slither-disable-next-line costly-loop
            refundToken = refundTokens[i];
            // NOTE: `DepositReceiver` is destroyed in the same runtime context that it is deployed.
            // slither-disable-next-line reentrancy-benign
            new DepositReceiver{ salt: salt }(
                abi.encodeWithSelector(ReceiverImplementation.receiveAndUnwrapNative.selector, refundAddress, recipient),
                refundAddress
            );
        }

        refundToken = address(0);
    }

    function refundLockedAsset(
        address receiver,
        address token,
        uint256 amount
    ) external {
        if (msg.sender != refundIssuer) revert NotRefundIssuer();
        if (receiver == address(0)) revert InvalidAddress();
        if (amount == 0) revert InvalidAmount();

        if (token == address(0)) {
            receiver.safeNativeTransfer(amount);
        } else {
            IERC20(token).safeTransfer(receiver, amount);
        }
    }

    function _depositAddress(
        bytes32 salt,
        bytes memory delegateData,
        address refundAddress
    ) internal view returns (address) {
        /* Convert a hash which is bytes32 to an address which is 20-byte long
        according to https://docs.soliditylang.org/en/v0.8.9/control-structures.html?highlight=create2#salted-contract-creations-create2 */
        return
            address(
                uint160(
                    uint256(
                        keccak256(
                            abi.encodePacked(
                                hex'ff',
                                address(this),
                                salt,
                                // Encoding delegateData and refundAddress as constructor params
                                keccak256(abi.encodePacked(type(DepositReceiver).creationCode, abi.encode(delegateData, refundAddress)))
                            )
                        )
                    )
                )
            );
    }

    function contractId() external pure returns (bytes32) {
        return keccak256('axelar-deposit-service');
    }
}

// File: contracts/interfaces/IAxelarGasService.sol

pragma solidity ^0.8.0;



/**
 * @title IAxelarGasService Interface
 * @notice This is an interface for the AxelarGasService contract which manages gas payments
 * and refunds for cross-chain communication on the Axelar network.
 * @dev This interface inherits IUpgradable
 */
interface IAxelarGasService is IUpgradable {
    error InvalidAddress();
    error NotCollector();
    error InvalidAmounts();

    event GasPaidForContractCall(
        address indexed sourceAddress,
        string destinationChain,
        string destinationAddress,
        bytes32 indexed payloadHash,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    );

    event GasPaidForContractCallWithToken(
        address indexed sourceAddress,
        string destinationChain,
        string destinationAddress,
        bytes32 indexed payloadHash,
        string symbol,
        uint256 amount,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    );

    event NativeGasPaidForContractCall(
        address indexed sourceAddress,
        string destinationChain,
        string destinationAddress,
        bytes32 indexed payloadHash,
        uint256 gasFeeAmount,
        address refundAddress
    );

    event NativeGasPaidForContractCallWithToken(
        address indexed sourceAddress,
        string destinationChain,
        string destinationAddress,
        bytes32 indexed payloadHash,
        string symbol,
        uint256 amount,
        uint256 gasFeeAmount,
        address refundAddress
    );

    event GasPaidForExpressCall(
        address indexed sourceAddress,
        string destinationChain,
        string destinationAddress,
        bytes32 indexed payloadHash,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    );

    event GasPaidForExpressCallWithToken(
        address indexed sourceAddress,
        string destinationChain,
        string destinationAddress,
        bytes32 indexed payloadHash,
        string symbol,
        uint256 amount,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    );

    event NativeGasPaidForExpressCall(
        address indexed sourceAddress,
        string destinationChain,
        string destinationAddress,
        bytes32 indexed payloadHash,
        uint256 gasFeeAmount,
        address refundAddress
    );

    event NativeGasPaidForExpressCallWithToken(
        address indexed sourceAddress,
        string destinationChain,
        string destinationAddress,
        bytes32 indexed payloadHash,
        string symbol,
        uint256 amount,
        uint256 gasFeeAmount,
        address refundAddress
    );

    event GasAdded(bytes32 indexed txHash, uint256 indexed logIndex, address gasToken, uint256 gasFeeAmount, address refundAddress);

    event NativeGasAdded(bytes32 indexed txHash, uint256 indexed logIndex, uint256 gasFeeAmount, address refundAddress);

    event ExpressGasAdded(bytes32 indexed txHash, uint256 indexed logIndex, address gasToken, uint256 gasFeeAmount, address refundAddress);

    event NativeExpressGasAdded(bytes32 indexed txHash, uint256 indexed logIndex, uint256 gasFeeAmount, address refundAddress);

    event Refunded(bytes32 indexed txHash, uint256 indexed logIndex, address payable receiver, address token, uint256 amount);

    /**
     * @notice Pay for gas using ERC20 tokens for a contract call on a destination chain.
     * @dev This function is called on the source chain before calling the gateway to execute a remote contract.
     * @param sender The address making the payment
     * @param destinationChain The target chain where the contract call will be made
     * @param destinationAddress The target address on the destination chain
     * @param payload Data payload for the contract call
     * @param gasToken The address of the ERC20 token used to pay for gas
     * @param gasFeeAmount The amount of tokens to pay for gas
     * @param refundAddress The address where refunds, if any, should be sent
     */
    function payGasForContractCall(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    ) external;

    /**
     * @notice Pay for gas using ERC20 tokens for a contract call with tokens on a destination chain.
     * @dev This function is called on the source chain before calling the gateway to execute a remote contract.
     * @param sender The address making the payment
     * @param destinationChain The target chain where the contract call with tokens will be made
     * @param destinationAddress The target address on the destination chain
     * @param payload Data payload for the contract call with tokens
     * @param symbol The symbol of the token to be sent with the call
     * @param amount The amount of tokens to be sent with the call
     * @param gasToken The address of the ERC20 token used to pay for gas
     * @param gasFeeAmount The amount of tokens to pay for gas
     * @param refundAddress The address where refunds, if any, should be sent
     */
    function payGasForContractCallWithToken(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        string calldata symbol,
        uint256 amount,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    ) external;

    /**
     * @notice Pay for gas using native currency for a contract call on a destination chain.
     * @dev This function is called on the source chain before calling the gateway to execute a remote contract.
     * @param sender The address making the payment
     * @param destinationChain The target chain where the contract call will be made
     * @param destinationAddress The target address on the destination chain
     * @param payload Data payload for the contract call
     * @param refundAddress The address where refunds, if any, should be sent
     */
    function payNativeGasForContractCall(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        address refundAddress
    ) external payable;

    /**
     * @notice Pay for gas using native currency for a contract call with tokens on a destination chain.
     * @dev This function is called on the source chain before calling the gateway to execute a remote contract.
     * @param sender The address making the payment
     * @param destinationChain The target chain where the contract call with tokens will be made
     * @param destinationAddress The target address on the destination chain
     * @param payload Data payload for the contract call with tokens
     * @param symbol The symbol of the token to be sent with the call
     * @param amount The amount of tokens to be sent with the call
     * @param refundAddress The address where refunds, if any, should be sent
     */
    function payNativeGasForContractCallWithToken(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        string calldata symbol,
        uint256 amount,
        address refundAddress
    ) external payable;

    /**
     * @notice Pay for gas using ERC20 tokens for an express contract call on a destination chain.
     * @dev This function is called on the source chain before calling the gateway to express execute a remote contract.
     * @param sender The address making the payment
     * @param destinationChain The target chain where the contract call will be made
     * @param destinationAddress The target address on the destination chain
     * @param payload Data payload for the contract call
     * @param gasToken The address of the ERC20 token used to pay for gas
     * @param gasFeeAmount The amount of tokens to pay for gas
     * @param refundAddress The address where refunds, if any, should be sent
     */
    function payGasForExpressCall(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    ) external;

    /**
     * @notice Pay for gas using ERC20 tokens for an express contract call with tokens on a destination chain.
     * @dev This function is called on the source chain before calling the gateway to express execute a remote contract.
     * @param sender The address making the payment
     * @param destinationChain The target chain where the contract call with tokens will be made
     * @param destinationAddress The target address on the destination chain
     * @param payload Data payload for the contract call with tokens
     * @param symbol The symbol of the token to be sent with the call
     * @param amount The amount of tokens to be sent with the call
     * @param gasToken The address of the ERC20 token used to pay for gas
     * @param gasFeeAmount The amount of tokens to pay for gas
     * @param refundAddress The address where refunds, if any, should be sent
     */
    function payGasForExpressCallWithToken(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        string calldata symbol,
        uint256 amount,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    ) external;

    /**
     * @notice Pay for gas using native currency for an express contract call on a destination chain.
     * @dev This function is called on the source chain before calling the gateway to execute a remote contract.
     * @param sender The address making the payment
     * @param destinationChain The target chain where the contract call will be made
     * @param destinationAddress The target address on the destination chain
     * @param payload Data payload for the contract call
     * @param refundAddress The address where refunds, if any, should be sent
     */
    function payNativeGasForExpressCall(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        address refundAddress
    ) external payable;

    /**
     * @notice Pay for gas using native currency for an express contract call with tokens on a destination chain.
     * @dev This function is called on the source chain before calling the gateway to execute a remote contract.
     * @param sender The address making the payment
     * @param destinationChain The target chain where the contract call with tokens will be made
     * @param destinationAddress The target address on the destination chain
     * @param payload Data payload for the contract call with tokens
     * @param symbol The symbol of the token to be sent with the call
     * @param amount The amount of tokens to be sent with the call
     * @param refundAddress The address where refunds, if any, should be sent
     */
    function payNativeGasForExpressCallWithToken(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        string calldata symbol,
        uint256 amount,
        address refundAddress
    ) external payable;

    /**
     * @notice Add additional gas payment using ERC20 tokens after initiating a cross-chain call.
     * @dev This function can be called on the source chain after calling the gateway to execute a remote contract.
     * @param txHash The transaction hash of the cross-chain call
     * @param logIndex The log index for the cross-chain call
     * @param gasToken The ERC20 token address used to add gas
     * @param gasFeeAmount The amount of tokens to add as gas
     * @param refundAddress The address where refunds, if any, should be sent
     */
    function addGas(
        bytes32 txHash,
        uint256 logIndex,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    ) external;

    /**
     * @notice Add additional gas payment using native currency after initiating a cross-chain call.
     * @dev This function can be called on the source chain after calling the gateway to execute a remote contract.
     * @param txHash The transaction hash of the cross-chain call
     * @param logIndex The log index for the cross-chain call
     * @param refundAddress The address where refunds, if any, should be sent
     */
    function addNativeGas(
        bytes32 txHash,
        uint256 logIndex,
        address refundAddress
    ) external payable;

    /**
     * @notice Add additional gas payment using ERC20 tokens after initiating an express cross-chain call.
     * @dev This function can be called on the source chain after calling the gateway to express execute a remote contract.
     * @param txHash The transaction hash of the cross-chain call
     * @param logIndex The log index for the cross-chain call
     * @param gasToken The ERC20 token address used to add gas
     * @param gasFeeAmount The amount of tokens to add as gas
     * @param refundAddress The address where refunds, if any, should be sent
     */
    function addExpressGas(
        bytes32 txHash,
        uint256 logIndex,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    ) external;

    /**
     * @notice Add additional gas payment using native currency after initiating an express cross-chain call.
     * @dev This function can be called on the source chain after calling the gateway to express execute a remote contract.
     * @param txHash The transaction hash of the cross-chain call
     * @param logIndex The log index for the cross-chain call
     * @param refundAddress The address where refunds, if any, should be sent
     */
    function addNativeExpressGas(
        bytes32 txHash,
        uint256 logIndex,
        address refundAddress
    ) external payable;

    /**
     * @notice Allows the gasCollector to collect accumulated fees from the contract.
     * @dev Use address(0) as the token address for native currency.
     * @param receiver The address to receive the collected fees
     * @param tokens Array of token addresses to be collected
     * @param amounts Array of amounts to be collected for each respective token address
     */
    function collectFees(
        address payable receiver,
        address[] calldata tokens,
        uint256[] calldata amounts
    ) external;

    /**
     * @notice Refunds gas payment to the receiver in relation to a specific cross-chain transaction.
     * @dev Only callable by the gasCollector.
     * @dev Use address(0) as the token address to refund native currency.
     * @param txHash The transaction hash of the cross-chain call
     * @param logIndex The log index for the cross-chain call
     * @param receiver The address to receive the refund
     * @param token The token address to be refunded
     * @param amount The amount to refund
     */
    function refund(
        bytes32 txHash,
        uint256 logIndex,
        address payable receiver,
        address token,
        uint256 amount
    ) external;

    /**
     * @notice Returns the address of the designated gas collector.
     * @return address of the gas collector
     */
    function gasCollector() external returns (address);
}

// File: contracts/gas-service/AxelarGasService.sol

pragma solidity ^0.8.0;







/**
 * @title AxelarGasService
 * @notice This contract manages gas payments and refunds for cross-chain communication on the Axelar network.
 * @dev The owner address of this contract should be the microservice that pays for gas.
 * @dev Users pay gas for cross-chain calls, and the gasCollector can collect accumulated fees and/or refund users if needed.
 */
contract AxelarGasService is Upgradable, IAxelarGasService {
    using SafeTokenTransfer for IERC20;
    using SafeTokenTransferFrom for IERC20;
    using SafeNativeTransfer for address payable;

    address public immutable gasCollector;

    /**
     * @notice Constructs the AxelarGasService contract.
     * @param gasCollector_ The address of the gas collector
     */
    constructor(address gasCollector_) {
        gasCollector = gasCollector_;
    }

    /**
     * @notice Modifier that ensures the caller is the designated gas collector.
     */
    modifier onlyCollector() {
        if (msg.sender != gasCollector) revert NotCollector();

        _;
    }

    /**
     * @notice Pay for gas using ERC20 tokens for a contract call on a destination chain.
     * @dev This function is called on the source chain before calling the gateway to execute a remote contract.
     * @param sender The address making the payment
     * @param destinationChain The target chain where the contract call will be made
     * @param destinationAddress The target address on the destination chain
     * @param payload Data payload for the contract call
     * @param gasToken The address of the ERC20 token used to pay for gas
     * @param gasFeeAmount The amount of tokens to pay for gas
     * @param refundAddress The address where refunds, if any, should be sent
     */
    function payGasForContractCall(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    ) external override {
        emit GasPaidForContractCall(
            sender,
            destinationChain,
            destinationAddress,
            keccak256(payload),
            gasToken,
            gasFeeAmount,
            refundAddress
        );

        IERC20(gasToken).safeTransferFrom(msg.sender, address(this), gasFeeAmount);
    }

    /**
     * @notice Pay for gas using ERC20 tokens for a contract call with tokens on a destination chain.
     * @dev This function is called on the source chain before calling the gateway to execute a remote contract.
     * @param sender The address making the payment
     * @param destinationChain The target chain where the contract call with tokens will be made
     * @param destinationAddress The target address on the destination chain
     * @param payload Data payload for the contract call with tokens
     * @param symbol The symbol of the token to be sent with the call
     * @param amount The amount of tokens to be sent with the call
     * @param gasToken The address of the ERC20 token used to pay for gas
     * @param gasFeeAmount The amount of tokens to pay for gas
     * @param refundAddress The address where refunds, if any, should be sent
     */
    function payGasForContractCallWithToken(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        string memory symbol,
        uint256 amount,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    ) external override {
        emit GasPaidForContractCallWithToken(
            sender,
            destinationChain,
            destinationAddress,
            keccak256(payload),
            symbol,
            amount,
            gasToken,
            gasFeeAmount,
            refundAddress
        );

        IERC20(gasToken).safeTransferFrom(msg.sender, address(this), gasFeeAmount);
    }

    /**
     * @notice Pay for gas using native currency for a contract call on a destination chain.
     * @dev This function is called on the source chain before calling the gateway to execute a remote contract.
     * @param sender The address making the payment
     * @param destinationChain The target chain where the contract call will be made
     * @param destinationAddress The target address on the destination chain
     * @param payload Data payload for the contract call
     * @param refundAddress The address where refunds, if any, should be sent
     */
    function payNativeGasForContractCall(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        address refundAddress
    ) external payable override {
        emit NativeGasPaidForContractCall(sender, destinationChain, destinationAddress, keccak256(payload), msg.value, refundAddress);
    }

    /**
     * @notice Pay for gas using native currency for a contract call with tokens on a destination chain.
     * @dev This function is called on the source chain before calling the gateway to execute a remote contract.
     * @param sender The address making the payment
     * @param destinationChain The target chain where the contract call with tokens will be made
     * @param destinationAddress The target address on the destination chain
     * @param payload Data payload for the contract call with tokens
     * @param symbol The symbol of the token to be sent with the call
     * @param amount The amount of tokens to be sent with the call
     * @param refundAddress The address where refunds, if any, should be sent
     */
    function payNativeGasForContractCallWithToken(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        string calldata symbol,
        uint256 amount,
        address refundAddress
    ) external payable override {
        emit NativeGasPaidForContractCallWithToken(
            sender,
            destinationChain,
            destinationAddress,
            keccak256(payload),
            symbol,
            amount,
            msg.value,
            refundAddress
        );
    }

    /**
     * @notice Pay for gas using ERC20 tokens for an express contract call on a destination chain.
     * @dev This function is called on the source chain before calling the gateway to express execute a remote contract.
     * @param sender The address making the payment
     * @param destinationChain The target chain where the contract call will be made
     * @param destinationAddress The target address on the destination chain
     * @param payload Data payload for the contract call
     * @param gasToken The address of the ERC20 token used to pay for gas
     * @param gasFeeAmount The amount of tokens to pay for gas
     * @param refundAddress The address where refunds, if any, should be sent
     */
    function payGasForExpressCall(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    ) external override {
        emit GasPaidForExpressCall(sender, destinationChain, destinationAddress, keccak256(payload), gasToken, gasFeeAmount, refundAddress);

        IERC20(gasToken).safeTransferFrom(msg.sender, address(this), gasFeeAmount);
    }

    /**
     * @notice Pay for gas using ERC20 tokens for an express contract call with tokens on a destination chain.
     * @dev This function is called on the source chain before calling the gateway to express execute a remote contract.
     * @param sender The address making the payment
     * @param destinationChain The target chain where the contract call with tokens will be made
     * @param destinationAddress The target address on the destination chain
     * @param payload Data payload for the contract call with tokens
     * @param symbol The symbol of the token to be sent with the call
     * @param amount The amount of tokens to be sent with the call
     * @param gasToken The address of the ERC20 token used to pay for gas
     * @param gasFeeAmount The amount of tokens to pay for gas
     * @param refundAddress The address where refunds, if any, should be sent
     */
    function payGasForExpressCallWithToken(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        string memory symbol,
        uint256 amount,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    ) external override {
        emit GasPaidForExpressCallWithToken(
            sender,
            destinationChain,
            destinationAddress,
            keccak256(payload),
            symbol,
            amount,
            gasToken,
            gasFeeAmount,
            refundAddress
        );

        IERC20(gasToken).safeTransferFrom(msg.sender, address(this), gasFeeAmount);
    }

    /**
     * @notice Pay for gas using native currency for an express contract call on a destination chain.
     * @dev This function is called on the source chain before calling the gateway to execute a remote contract.
     * @param sender The address making the payment
     * @param destinationChain The target chain where the contract call will be made
     * @param destinationAddress The target address on the destination chain
     * @param payload Data payload for the contract call
     * @param refundAddress The address where refunds, if any, should be sent
     */
    function payNativeGasForExpressCall(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        address refundAddress
    ) external payable override {
        emit NativeGasPaidForExpressCall(sender, destinationChain, destinationAddress, keccak256(payload), msg.value, refundAddress);
    }

    /**
     * @notice Pay for gas using native currency for an express contract call with tokens on a destination chain.
     * @dev This function is called on the source chain before calling the gateway to execute a remote contract.
     * @param sender The address making the payment
     * @param destinationChain The target chain where the contract call with tokens will be made
     * @param destinationAddress The target address on the destination chain
     * @param payload Data payload for the contract call with tokens
     * @param symbol The symbol of the token to be sent with the call
     * @param amount The amount of tokens to be sent with the call
     * @param refundAddress The address where refunds, if any, should be sent
     */
    function payNativeGasForExpressCallWithToken(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        string calldata symbol,
        uint256 amount,
        address refundAddress
    ) external payable override {
        emit NativeGasPaidForExpressCallWithToken(
            sender,
            destinationChain,
            destinationAddress,
            keccak256(payload),
            symbol,
            amount,
            msg.value,
            refundAddress
        );
    }

    /**
     * @notice Add additional gas payment using ERC20 tokens after initiating a cross-chain call.
     * @dev This function can be called on the source chain after calling the gateway to execute a remote contract.
     * @param txHash The transaction hash of the cross-chain call
     * @param logIndex The log index for the cross-chain call
     * @param gasToken The ERC20 token address used to add gas
     * @param gasFeeAmount The amount of tokens to add as gas
     * @param refundAddress The address where refunds, if any, should be sent
     */
    function addGas(
        bytes32 txHash,
        uint256 logIndex,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    ) external override {
        emit GasAdded(txHash, logIndex, gasToken, gasFeeAmount, refundAddress);

        IERC20(gasToken).safeTransferFrom(msg.sender, address(this), gasFeeAmount);
    }

    /**
     * @notice Add additional gas payment using native currency after initiating a cross-chain call.
     * @dev This function can be called on the source chain after calling the gateway to execute a remote contract.
     * @param txHash The transaction hash of the cross-chain call
     * @param logIndex The log index for the cross-chain call
     * @param refundAddress The address where refunds, if any, should be sent
     */
    function addNativeGas(
        bytes32 txHash,
        uint256 logIndex,
        address refundAddress
    ) external payable override {
        emit NativeGasAdded(txHash, logIndex, msg.value, refundAddress);
    }

    /**
     * @notice Add additional gas payment using ERC20 tokens after initiating an express cross-chain call.
     * @dev This function can be called on the source chain after calling the gateway to express execute a remote contract.
     * @param txHash The transaction hash of the cross-chain call
     * @param logIndex The log index for the cross-chain call
     * @param gasToken The ERC20 token address used to add gas
     * @param gasFeeAmount The amount of tokens to add as gas
     * @param refundAddress The address where refunds, if any, should be sent
     */
    function addExpressGas(
        bytes32 txHash,
        uint256 logIndex,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    ) external override {
        emit ExpressGasAdded(txHash, logIndex, gasToken, gasFeeAmount, refundAddress);

        IERC20(gasToken).safeTransferFrom(msg.sender, address(this), gasFeeAmount);
    }

    /**
     * @notice Add additional gas payment using native currency after initiating an express cross-chain call.
     * @dev This function can be called on the source chain after calling the gateway to express execute a remote contract.
     * @param txHash The transaction hash of the cross-chain call
     * @param logIndex The log index for the cross-chain call
     * @param refundAddress The address where refunds, if any, should be sent
     */
    function addNativeExpressGas(
        bytes32 txHash,
        uint256 logIndex,
        address refundAddress
    ) external payable override {
        emit NativeExpressGasAdded(txHash, logIndex, msg.value, refundAddress);
    }

    /**
     * @notice Allows the gasCollector to collect accumulated fees from the contract.
     * @dev Use address(0) as the token address for native currency.
     * @param receiver The address to receive the collected fees
     * @param tokens Array of token addresses to be collected
     * @param amounts Array of amounts to be collected for each respective token address
     */
    function collectFees(
        address payable receiver,
        address[] calldata tokens,
        uint256[] calldata amounts
    ) external onlyCollector {
        if (receiver == address(0)) revert InvalidAddress();

        uint256 tokensLength = tokens.length;
        if (tokensLength != amounts.length) revert InvalidAmounts();

        for (uint256 i; i < tokensLength; i++) {
            address token = tokens[i];
            uint256 amount = amounts[i];
            if (amount == 0) revert InvalidAmounts();

            if (token == address(0)) {
                if (amount <= address(this).balance) receiver.safeNativeTransfer(amount);
            } else {
                // slither-disable-next-line calls-loop
                if (amount <= IERC20(token).balanceOf(address(this))) IERC20(token).safeTransfer(receiver, amount);
            }
        }
    }

    /**
     * @dev Deprecated refund function, kept for backward compatibility.
     */
    function refund(
        address payable receiver,
        address token,
        uint256 amount
    ) external onlyCollector {
        _refund(bytes32(0), 0, receiver, token, amount);
    }

    /**
     * @notice Refunds gas payment to the receiver in relation to a specific cross-chain transaction.
     * @dev Only callable by the gasCollector.
     * @dev Use address(0) as the token address to refund native currency.
     * @param txHash The transaction hash of the cross-chain call
     * @param logIndex The log index for the cross-chain call
     * @param receiver The address to receive the refund
     * @param token The token address to be refunded
     * @param amount The amount to refund
     */
    function refund(
        bytes32 txHash,
        uint256 logIndex,
        address payable receiver,
        address token,
        uint256 amount
    ) external onlyCollector {
        _refund(txHash, logIndex, receiver, token, amount);
    }

    /**
     * @dev Internal function to implement gas refund logic.
     */
    function _refund(
        bytes32 txHash,
        uint256 logIndex,
        address payable receiver,
        address token,
        uint256 amount
    ) private {
        if (receiver == address(0)) revert InvalidAddress();

        emit Refunded(txHash, logIndex, receiver, token, amount);

        if (token == address(0)) {
            receiver.safeNativeTransfer(amount);
        } else {
            IERC20(token).safeTransfer(receiver, amount);
        }
    }

    /**
     * @notice Returns a unique identifier for the contract.
     * @return bytes32 Hash of the contract identifier
     */
    function contractId() external pure returns (bytes32) {
        return keccak256('axelar-gas-service');
    }
}

// File: contracts/interfaces/IUpgradable.sol

pragma solidity ^0.8.9;

// General interface for upgradable contracts
interface IUpgradable {
    error NotOwner();
    error InvalidOwner();
    error InvalidCodeHash();
    error InvalidImplementation();
    error SetupFailed();
    error NotProxy();

    event Upgraded(address indexed newImplementation);
    event OwnershipTransferred(address indexed newOwner);

    // Get current owner
    function owner() external view returns (address);

    function contractId() external pure returns (bytes32);

    function implementation() external view returns (address);

    function upgrade(
        address newImplementation,
        bytes32 newImplementationCodeHash,
        bytes calldata params
    ) external;

    function setup(bytes calldata data) external;
}

// File: contracts/test/TestAxelarGateway.sol

pragma solidity ^0.8.0;



contract TestAxelarGateway is AxelarGateway {
    string public name = 'Test Axelar Gateway'; // Dummy var for a different bytecode

    error Invalid();

    constructor(address authModule_, address tokenDeployer_) AxelarGateway(authModule_, tokenDeployer_) {
        if (KEY_IMPLEMENTATION != bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1)) revert Invalid();
        if (KEY_GOVERNANCE != bytes32(uint256(keccak256('governance')) - 1)) revert Invalid();
        if (KEY_MINT_LIMITER != bytes32(uint256(keccak256('mint-limiter')) - 1)) revert Invalid();
    }
}

// File: contracts/test/TestDepositHandler.sol

pragma solidity ^0.8.0;

contract TestDepositHandler {
    event Called();

    function test() external returns (bool) {
        emit Called();
        return true;
    }

    function destroy(address receiver) external {
        selfdestruct(payable(receiver));
    }

    receive() external payable {}
}

// File: contracts/test/TestECDSA.sol

pragma solidity ^0.8.0;



contract TestECDSA {
    using ECDSA for bytes32;

    function recover(bytes32 hash, bytes memory signature) external pure returns (address) {
        return hash.recover(signature);
    }

    function toEthSignedMessageHashPublic(bytes32 hash) external pure returns (bytes32) {
        return hash.toEthSignedMessageHash();
    }
}

// File: contracts/test/TestEternalStorage.sol

pragma solidity ^0.8.0;



contract TestEternalStorage is EternalStorage {
    // *** Set Methods ***
    function setUint(bytes32 key, uint256 value) external {
        _setUint(key, value);
    }

    function setString(bytes32 key, string memory value) external {
        _setString(key, value);
    }

    function setAddress(bytes32 key, address value) external {
        _setAddress(key, value);
    }

    function setBytes(bytes32 key, bytes memory value) external {
        _setBytes(key, value);
    }

    function setBool(bytes32 key, bool value) external {
        _setBool(key, value);
    }

    function setInt(bytes32 key, int256 value) external {
        _setInt(key, value);
    }

    // *** Delete Methods ***
    function deleteUint(bytes32 key) external {
        _deleteUint(key);
    }

    function deleteString(bytes32 key) external {
        _deleteString(key);
    }

    function deleteAddress(bytes32 key) external {
        _deleteAddress(key);
    }

    function deleteBytes(bytes32 key) external {
        _deleteBytes(key);
    }

    function deleteBool(bytes32 key) external {
        _deleteBool(key);
    }

    function deleteInt(bytes32 key) external {
        _deleteInt(key);
    }
}

// File: contracts/test/TestNonStandardERC20.sol

// solhint-disable no-unused-vars

pragma solidity ^0.8.9;



contract TestNonStandardERC20 is MintableCappedERC20 {
    bool public shouldFailTransfer;

    error Invalid();

    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals,
        uint256 capacity
    ) MintableCappedERC20(name, symbol, decimals, capacity) {
        shouldFailTransfer = false;
    }

    function setFailTransfer(bool _shouldFailTransfer) public {
        shouldFailTransfer = _shouldFailTransfer;
    }

    function transfer(address, uint256) public view override returns (bool) {
        if (shouldFailTransfer) {
            return false;
        }
        revert Invalid();
    }
}

// File: contracts/test/TestRpcCompatibility.sol

pragma solidity ^0.8.9;

contract TestRpcCompatibility {
    uint256 private value;
    uint256 private subscribeValue;

    event ValueUpdated(uint256 indexed value);
    event ValueUpdatedForSubscribe(uint256 indexed value);

    function getValue() public view returns (uint256) {
        return value;
    }

    function updateValue(uint256 newValue) external {
        value = newValue;
        emit ValueUpdated(newValue);
    }

    function updateValueForSubscribe(uint256 newValue) external {
        subscribeValue = newValue;
        emit ValueUpdatedForSubscribe(newValue);
    }
}

// File: contracts/test/TestWeth.sol

pragma solidity ^0.8.0;




contract TestWeth is MintableCappedERC20, IWETH9 {
    error Invalid();

    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals,
        uint256 capacity
    ) MintableCappedERC20(name, symbol, decimals, capacity) {}

    function deposit() external payable {
        balanceOf[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) external {
        if (balanceOf[msg.sender] < amount) revert Invalid();
        balanceOf[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }
}

// File: contracts/test/gmp/DestinationChainTokenSwapper.sol

pragma solidity ^0.8.0;



contract DestinationChainTokenSwapper {
    error WrongTokenPair();

    address public tokenA;
    address public tokenB;

    constructor(address tokenA_, address tokenB_) {
        tokenA = tokenA_;
        tokenB = tokenB_;
    }

    function swap(
        address tokenAddress,
        address toTokenAddress,
        uint256 amount,
        address recipient
    ) external returns (uint256 convertedAmount) {
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);

        if (tokenAddress == tokenA) {
            if (toTokenAddress != tokenB) revert WrongTokenPair();

            convertedAmount = amount * 2;
        } else {
            if (tokenAddress != tokenB || toTokenAddress != tokenA) revert WrongTokenPair();

            convertedAmount = amount / 2;
        }

        IERC20(toTokenAddress).transfer(recipient, convertedAmount);
    }
}

// File: contracts/test/gmp/DestinationChainSwapExecutable.sol

pragma solidity ^0.8.0;





contract DestinationChainSwapExecutable is AxelarExecutable {
    DestinationChainTokenSwapper public immutable swapper;

    constructor(address gatewayAddress, address swapperAddress) AxelarExecutable(gatewayAddress) {
        swapper = DestinationChainTokenSwapper(swapperAddress);
    }

    function _executeWithToken(
        string calldata sourceChain,
        string calldata,
        bytes calldata payload,
        string calldata tokenSymbolA,
        uint256 amount
    ) internal override {
        (string memory tokenSymbolB, string memory recipient) = abi.decode(payload, (string, string));

        address tokenA = gateway.tokenAddresses(tokenSymbolA);
        address tokenB = gateway.tokenAddresses(tokenSymbolB);

        IERC20(tokenA).approve(address(swapper), amount);
        uint256 convertedAmount = swapper.swap(tokenA, tokenB, amount, address(this));

        IERC20(tokenB).approve(address(gateway), convertedAmount);
        gateway.sendToken(sourceChain, recipient, tokenSymbolB, convertedAmount);
    }
}

// File: contracts/test/gmp/SourceChainSwapCaller.sol

pragma solidity ^0.8.0;





contract SourceChainSwapCaller {
    IAxelarGateway public gateway;
    IAxelarGasService public gasService;
    string public destinationChain;
    string public executableAddress;

    constructor(
        address gateway_,
        address gasService_,
        string memory destinationChain_,
        string memory executableAddress_
    ) {
        gateway = IAxelarGateway(gateway_);
        gasService = IAxelarGasService(gasService_);
        destinationChain = destinationChain_;
        executableAddress = executableAddress_;
    }

    function swapToken(
        string memory symbolA,
        string memory symbolB,
        uint256 amount,
        string memory recipient
    ) external payable {
        address tokenX = gateway.tokenAddresses(symbolA);
        bytes memory payload = abi.encode(symbolB, recipient);

        IERC20(tokenX).transferFrom(msg.sender, address(this), amount);

        if (msg.value > 0)
            gasService.payNativeGasForContractCallWithToken{ value: msg.value }(
                address(this),
                destinationChain,
                executableAddress,
                payload,
                symbolA,
                amount,
                msg.sender
            );

        IERC20(tokenX).approve(address(gateway), amount);
        gateway.callContractWithToken(destinationChain, executableAddress, payload, symbolA, amount);
    }
}

// File: contracts/test/proxy/InvalidTestImplementation.sol

pragma solidity ^0.8.0;



contract InvalidTestImplementation is IUpgradable {
    uint256 public value;
    string public name;

    function owner() external pure override returns (address) {
        return address(0);
    }

    function pendingOwner() external pure returns (address) {
        return address(0);
    }

    function proposeOwnership(address newOwner) external {}

    function acceptOwnership() external {}

    function implementation() external pure override returns (address) {
        return address(0);
    }

    function upgrade(
        address,
        bytes32,
        bytes calldata
    ) external override {}

    function set(uint256 _val) external {
        value = _val;
    }

    function setup(bytes calldata _data) external {
        (uint256 initVal, string memory _name) = abi.decode(_data, (uint256, string));
        value = initVal;
        name = _name;
    }

    function contractId() external pure returns (bytes32) {
        return keccak256('invalid-implementation');
    }
}

// File: contracts/test/proxy/TestImplementation.sol

pragma solidity ^0.8.0;



contract TestImplementation is IUpgradable {
    uint256 public value;
    string public name;

    function owner() external pure override returns (address) {
        return address(0);
    }

    function pendingOwner() external pure returns (address) {
        return address(0);
    }

    function proposeOwnership(address newOwner) external {}

    function acceptOwnership() external {}

    function implementation() external pure override returns (address) {
        return address(0);
    }

    function upgrade(
        address,
        bytes32,
        bytes calldata
    ) external override {}

    function set(uint256 _val) external {
        value = _val;
    }

    function setup(bytes calldata _data) external {
        (uint256 initVal, string memory _name) = abi.decode(_data, (uint256, string));
        value = initVal;
        name = _name;
    }

    function contractId() external pure returns (bytes32) {
        return keccak256('test');
    }
}

// File: contracts/util/Proxy.sol

pragma solidity 0.8.9;



contract Proxy {
    error InvalidImplementation();
    error SetupFailed();
    error EtherNotAccepted();
    error NotOwner();
    error AlreadyInitialized();

    // bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1)
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    // keccak256('owner')
    bytes32 internal constant _OWNER_SLOT = 0x02016836a56b71f0d02689e69e326f4f4c1b9057164ef592671cf0d37c8040c0;

    constructor() {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            sstore(_OWNER_SLOT, caller())
        }
    }

    function init(
        address implementationAddress,
        address newOwner,
        bytes memory params
    ) external {
        address owner;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            owner := sload(_OWNER_SLOT)
        }
        if (msg.sender != owner) revert NotOwner();
        if (implementation() != address(0)) revert AlreadyInitialized();
        if (IUpgradable(implementationAddress).contractId() != contractId()) revert InvalidImplementation();

        // solhint-disable-next-line no-inline-assembly
        assembly {
            sstore(_IMPLEMENTATION_SLOT, implementationAddress)
            sstore(_OWNER_SLOT, newOwner)
        }
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, ) = implementationAddress.delegatecall(
            //0x9ded06df is the setup selector.
            abi.encodeWithSelector(0x9ded06df, params)
        );
        if (!success) revert SetupFailed();
    }

    // solhint-disable-next-line no-empty-blocks
    function contractId() internal pure virtual returns (bytes32) {}

    function implementation() public view returns (address implementation_) {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            implementation_ := sload(_IMPLEMENTATION_SLOT)
        }
    }

    // solhint-disable-next-line no-empty-blocks
    function setup(bytes calldata data) public {}

    // solhint-disable-next-line no-complex-fallback
    fallback() external payable {
        address implementaion_ = implementation();
        // solhint-disable-next-line no-inline-assembly
        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(gas(), implementaion_, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    receive() external payable virtual {
        revert EtherNotAccepted();
    }
}

// File: contracts/test/proxy/TestProxy.sol

pragma solidity ^0.8.0;



contract TestProxy is Proxy {
    function contractId() internal pure override returns (bytes32) {
        return keccak256('test');
    }
}
