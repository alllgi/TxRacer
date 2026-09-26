// Sources retrieved from Sourcify API v2.
// Deterministic best-effort flattening; original files are preserved under src/.

// File: contracts/interfaces/ISquidMulticall.sol

pragma solidity ^0.8.9;

/// @title SquidMulticall
/// @notice Multicall logic specific to Squid calls format. The contract specificity is mainly
/// to enable ERC20 and native token amounts in calldata between two calls.
/// @dev Support receiption of NFTs.
interface ISquidMulticall {
    /// @notice Call type that enables to specific behaviours of the multicall.
    enum CallType {
        // Will simply run calldata
        Default,
        // Will update amount field in calldata with ERC20 token balance of the multicall contract.
        FullTokenBalance,
        // Will update amount field in calldata with native token balance of the multicall contract.
        FullNativeBalance,
        // Will run a safeTransferFrom to get full ERC20 token balance of the caller.
        CollectTokenBalance
    }

    /// @notice Calldata format expected by multicall.
    struct Call {
        // Call type, see CallType struct description.
        CallType callType;
        // Address that will be called.
        address target;
        // Native token amount that will be sent in call.
        uint256 value;
        // Calldata that will be send in call.
        bytes callData;
        // Extra data used by multicall depending on call type.
        // Default: unused (provide 0x)
        // FullTokenBalance: address of the ERC20 token to get balance of and zero indexed position
        // of the amount parameter to update in function call contained by calldata.
        // Expect format is: abi.encode(address token, uint256 amountParameterPosition)
        // Eg: for function swap(address tokenIn, uint amountIn, address tokenOut, uint amountOutMin,)
        // amountParameterPosition would be 1.
        // FullNativeBalance: unused (provide 0x)
        // CollectTokenBalance: address of the ERC20 token to collect.
        // Expect format is: abi.encode(address token)
        bytes payload;
    }

    /// Thrown when one of the calls fails.
    /// @param callPosition Zero indexed position of the call in the call set provided to the
    /// multicall.
    /// @param reason Revert data returned by contract called in failing call.
    error CallFailed(uint256 callPosition, bytes reason);

    /// @notice Main function of the multicall that runs the call set.
    /// @param calls Call set to be ran by multicall.
    function run(Call[] calldata calls) external payable;
}

// File: contracts/interfaces/uniswap/IPermit2.sol

pragma solidity ^0.8.9;

/// @title Permit2
/// @notice Permit2 handles signature-based transfers in SignatureTransfer and allowance-based transfers in AllowanceTransfer.
/// @dev Users must approve Permit2 before calling any of the transfer functions.
interface IPermit2 {
    /// @notice The token and amount details for a transfer signed in the permit transfer signature
    struct TokenPermissions {
        // ERC20 token address
        address token;
        // the maximum amount that can be spent
        uint256 amount;
    }

    /// @notice The signed permit message for a single token transfer
    struct PermitTransferFrom {
        TokenPermissions permitted;
        // a unique value for every token owner's signature to prevent signature replays
        uint256 nonce;
        // deadline on the permit signature
        uint256 deadline;
    }

    /// @notice Specifies the recipient address and amount for batched transfers.
    /// @dev Recipients and amounts correspond to the index of the signed token permissions array.
    /// @dev Reverts if the requested amount is greater than the permitted signed amount.
    struct SignatureTransferDetails {
        // recipient address
        address to;
        // spender requested amount
        uint256 requestedAmount;
    }

    /// @notice Transfer approved tokens from one address to another
    /// @param from The address to transfer from
    /// @param to The address of the recipient
    /// @param amount The amount of the token to transfer
    /// @param token The token address to transfer
    /// @dev Requires the from address to have approved at least the desired amount
    /// of tokens to msg.sender.
    function transferFrom(address from, address to, uint160 amount, address token) external;

    /// @notice Transfers a token using a signed permit message
    /// @dev Reverts if the requested amount is greater than the permitted signed amount
    /// @param permit The permit data signed over by the owner
    /// @param owner The owner of the tokens to transfer
    /// @param transferDetails The spender's requested transfer details for the permitted token
    /// @param signature The signature to verify
    function permitTransferFrom(
        PermitTransferFrom memory permit,
        SignatureTransferDetails calldata transferDetails,
        address owner,
        bytes calldata signature
    ) external;

    /// @notice Transfers a token using a signed permit message
    /// @notice Includes extra data provided by the caller to verify signature over
    /// @dev The witness type string must follow EIP712 ordering of nested structs and must include the TokenPermissions type definition
    /// @dev Reverts if the requested amount is greater than the permitted signed amount
    /// @param permit The permit data signed over by the owner
    /// @param owner The owner of the tokens to transfer
    /// @param transferDetails The spender's requested transfer details for the permitted token
    /// @param witness Extra data to include when checking the user signature
    /// @param witnessTypeString The EIP-712 type definition for remaining string stub of the typehash
    /// @param signature The signature to verify
    function permitWitnessTransferFrom(
        PermitTransferFrom memory permit,
        SignatureTransferDetails calldata transferDetails,
        address owner,
        bytes32 witness,
        string calldata witnessTypeString,
        bytes calldata signature
    ) external;
}

// File: contracts/interfaces/ISquidRouter.sol

pragma solidity ^0.8.9;




/// @title SquidRouter
/// @notice Main entry point of the protocol. It mainly provides endpoints to interact safely
/// with the multicall or CCTP, and receiver function to handle asset reception for bridges.
interface ISquidRouter {
    /// @notice Emitted when the calldata content of a payload is successfully ran on destination chain.
    /// @param payloadHash Keccak256 of the payload bytes value. Differ from one call to another in case of
    /// identical parameters value thanks to a salt value.
    event CrossMulticallExecuted(bytes32 indexed payloadHash);
    /// @notice Emitted when the calldata content of a payload failed to be ran on destination chain and
    /// ERC20 tokens are sent to refund recipient address.
    /// @param payloadHash Keccak256 hash of the payload bytes value. Differ from one call to another in case
    /// of identical parameters value thanks to a salt value.
    /// @param reason Revert data returned by contract called in failing call.
    /// @param refundRecipient Address that will receive bridged ERC20 tokens on destination chain in case
    /// of multicall failure.
    event CrossMulticallFailed(
        bytes32 indexed payloadHash,
        bytes reason,
        address indexed refundRecipient
    );

    /// @notice Thrown when address(0) is provided to a parameter that does not allow it.
    error ZeroAddressProvided();
    /// @notice Thrown when Chainflip receiver function is called by any address other that Chainflip
    /// vault contract.
    error OnlyCfVault();

    /// @notice Collect ERC20 and/or native tokens from user and send them to multicall. Then run multicall.
    /// @dev Require either ERC20 or permit2 allowance from the user to the router address.
    /// Indeed, permit2's transferFrom2 is used instead of regulat transferFrom. Meaning that if there is no
    /// regular allowance from user to the router for ERC20 token, permit2 allowance will be used if granted.
    /// @dev Native tokens can be provided on top of ERC20 tokens, both will be sent to multicall.
    /// @param token Address of the ERC20 token to be provided to the multicall to run the calls.
    /// 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE in case of native token.
    /// @param amount Amount of ERC20 tokens to be provided to the multicall. If native token is selected, this
    /// value has not effect.
    /// @param calls Calls to be ran by the multicall, formatted in accordance to Call struct.
    function fundAndRunMulticall(
        address token,
        uint256 amount,
        ISquidMulticall.Call[] calldata calls
    ) external payable;

    /// @notice Collect ERC20 tokens from user and send them to multicall thanks to a permit2 signed permit. Then run
    /// multicall.
    /// @dev Native tokens can be provided on top of ERC20 tokens by the relayer of the permit, both will be sent
    /// to multicall.
    /// @dev Transaction sender can either be the holder of the funds, or the separate relayer. In the later case,
    /// witness must be included in the data signed, according to the permit2 protocol.
    /// @dev See https://docs.uniswap.org/contracts/permit2/reference/signature-transfer for more information about
    /// permit2 protocol requirements.
    /// @dev ERC20 token and amount values to be used are provided in the permit data.
    /// @param calls Calls to be ran by the multicall, formatted in accordance to Call struct.
    /// @param from Holder of the funds to be provided. Can defer from the sender of the transaction in case of a
    /// relayed transaction.
    /// @param permit Permit data according to permit2 protocol.
    /// @param signature Signature data according to permit2 protocol.
    function permitFundAndRunMulticall(
        ISquidMulticall.Call[] memory calls,
        address from,
        IPermit2.PermitTransferFrom calldata permit,
        bytes calldata signature
    ) external payable;

    /// @notice Collect USDC tokens from user and trigger CCTP bridging.
    /// @dev This endpoint is meant to enable CCTP bridging at the end of a multicall. It also enable integrations
    /// with Squid CCTP bridging relayer infrasctructure.
    /// @dev Require either ERC20 or permit2 allowance from the user to the router address.
    /// Indeed, permit2's transferFrom2 is used instead of regulat transferFrom. Meaning that if there is no
    /// regular allowance from user to the router for ERC20 token, permit2 allowance will be used if granted.
    /// @dev CCTP's replaceDepositForBurn function is not made available for security reason. Integrators need to
    /// be careful with the parameters they provide.
    /// @dev Require owner to call `approveCctpTokenMessenger` function first.
    /// @param amount Amount of USDC tokens to be bridged.
    /// @param destinationDomain Destination chain according to CCTP's nomenclature.
    /// This param is checked for potential irrelevant values by CCTP contract.
    /// See https://developers.circle.com/stablecoins/docs/cctp-technical-reference.
    /// @param destinationAddress Address that will receive USDC tokens on destination chain.
    /// This param is checked for not zero value by CCTP contract.
    /// @param destinationCaller Address that will be able to trigger USDC tokens reception on destination chain.
    /// This param is checked for not zero value to disable anonymous actions.
    function cctpBridge(
        uint256 amount,
        uint32 destinationDomain,
        bytes32 destinationAddress,
        bytes32 destinationCaller
    ) external;

    /// @notice Collect USDC tokens from user thanks to a permit2 signed permit and trigger CCTP bridging.
    /// @dev Transaction sender can either be the holder of the funds, or the separate relayer. In the later case,
    /// witness must be included in the data signed, according to the permit2 protocol.
    /// @dev See https://docs.uniswap.org/contracts/permit2/reference/signature-transfer for more information about
    /// permit2 protocol requirements.
    /// @dev USDC token and amount values to be used are provided in the permit data.
    /// Permit token address value is checked to match USDC token address.
    /// @dev CCTP's replaceDepositForBurn function is not made available for security reason. Integrators need to
    /// be careful with the parameters they provide.
    /// @dev Require owner to call `approveCctpTokenMessenger` function first.
    /// @param destinationDomain Destination chain according to CCTP's nomenclature.
    /// This param is checked for potential irrelevant values by CCTP contract.
    /// See https://developers.circle.com/stablecoins/docs/cctp-technical-reference.
    /// @param destinationAddress Address that will receive USDC tokens on destination chain.
    /// This param is checked for not zero value by CCTP contract.
    /// @param destinationCaller Address that will be able to trigger USDC tokens reception on destination chain.
    /// This param is checked for not zero value to disable anonymous actions.
    /// @param from Holder of the funds to be provided. Can defer from the sender of the transaction in case of a
    /// relayed transaction.
    /// @param permit Permit data according to permit2 protocol.
    /// @param signature Signature data according to permit2 protocol.
    function permitCctpBridge(
        uint32 destinationDomain,
        bytes32 destinationAddress,
        bytes32 destinationCaller,
        address from,
        IPermit2.PermitTransferFrom calldata permit,
        bytes calldata signature
    ) external;

    /// @notice Approve CCTP Token Messenger to access unlimited amount of USDC. Enables to not have to
    /// approve each time a user wants to bridge USDC. Requires to monitor CCTP Token Messenger allowance.
    /// @dev Only owner can call.
    function approveCctpTokenMessenger() external;

    /// @notice Collect ERC20 and/or native tokens from user and send them to multicall. Then bridge tokens
    /// through Axelar bridge and run multicall on destination chain. This endpoint is deprecated and will be
    /// removed in a future upgrade.
    /// @dev Require either ERC20 or permit2 allowance from the user to the router address.
    /// Indeed, permit2's transferFrom2 is used instead of regulat transferFrom. Meaning that if there is no
    /// regular allowance from user to the router for ERC20 token, permit2 allowance will be used if granted.
    /// @dev Require to provide native amount to cover gas service. The amount has to be computed off chain with
    /// Axelar SDK.
    /// @dev Native tokens provided on top of an ERC20 token will be sent to gas service. Thus you need to provide
    /// native amount to cover gas service on top of native amount for calls
    /// @dev Gas service providing is handled internally.
    /// @param bridgedTokenSymbol Symbol of the token that will be sent to Axelar bridge.
    /// @param amount Amount of ERC20 tokens to be collect for bridging.
    /// @param destinationChain Destination chain for bridging according to Axelar's nomenclature.
    /// @param destinationAddress Address that will receive bridged ERC20 tokens on destination chain.
    /// @param payload Bytes value containing calls to be ran by the multicall on destination chain.
    /// Expected format is: abi.encode(ISquidMulticall.Call[] calls, address refundRecipient, bytes32 salt).
    /// @param gasRefundRecipient Address that will receive native tokens left on gas service after process is
    /// done.
    /// @param enableExpress If true is provided, Axelar's express (aka Squid's boost) feature will be used.
    function bridgeCall(
        string calldata bridgedTokenSymbol,
        uint256 amount,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        address gasRefundRecipient,
        bool enableExpress
    ) external payable;

    /// @notice Collect ERC20 and/or native tokens from user and send them to multicall. Then run multicall and
    /// bridge tokens through Axelar bridge before running multicall on destination chain. This endpoint is
    /// deprecated and will be removed in a future upgrade.
    /// @dev Require either ERC20 or permit2 allowance from the user to the router address.
    /// Indeed, permit2's transferFrom2 is used instead of regulat transferFrom. Meaning that if there is no
    /// regular allowance from user to the router for ERC20 token, permit2 allowance will be used if granted.
    /// @dev Require to provide native amount to cover gas service. The amount has to be computed off chain with
    /// Axelar SDK.
    /// @dev Native tokens provided on top of an ERC20 token will be sent to gas service. If input token is native
    /// tokens, input amount will be sent to multicall and the rest to gas service. Thus you need to provide native
    /// amount to cover gas service on top of native amount for calls.
    /// @dev Gas service providing is handled internally.
    /// @param token Address of the ERC20 token to be provided to the multicall to run the calls.
    /// 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE in case of native token.
    /// @param amount Amount of ERC20 or native tokens to be provided to the multicall.
    /// @param calls Calls to be ran by the multicall on source chain, formatted in accordance to Call struct.
    /// @param bridgedTokenSymbol Symbol of the token that will be sent to Axelar bridge.
    /// @param destinationChain Destination chain for bridging according to Axelar's nomenclature.
    /// @param destinationAddress Address that will receive bridged ERC20 tokens on destination chain.
    /// @param payload Bytes value containing calls to be ran by the multicall on destination chain.
    /// Expected format is: abi.encode(ISquidMulticall.Call[] calls, address refundRecipient, bytes32 salt).
    /// @param gasRefundRecipient Address that will receive native tokens left on gas service after process is
    /// done.
    /// @param enableExpress If true is provided, Axelar's express (aka Squid's boost) feature will be used.
    function callBridgeCall(
        address token,
        uint256 amount,
        ISquidMulticall.Call[] calldata calls,
        string calldata bridgedTokenSymbol,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        address gasRefundRecipient,
        bool enableExpress
    ) external payable;
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

// File: contracts/interfaces/its/IExpressCallHandler.sol

pragma solidity ^0.8.9;

interface IExpressCallHandler {
    error AlreadyExpressCalled();
    error SameDestinationAsCaller();

    event ExpressReceive(bytes payload, bytes32 indexed sendHash, address indexed expressCaller);
    event ExpressExecutionFulfilled(bytes payload, bytes32 indexed sendHash, address indexed expressCaller);

    /**
     * @notice Gets the address of the express caller for a specific token transfer
     * @param payload the payload for the receive token
     * @param commandId The unique hash for this token transfer
     * @return expressCaller The address of the express caller for this token transfer
     */
    function getExpressReceiveToken(
        bytes calldata payload,
        bytes32 commandId
    ) external view returns (address expressCaller);
}

// File: contracts/interfaces/its/ITokenManagerType.sol

pragma solidity ^0.8.9;

/**
 * @title ITokenManagerType
 * @notice A simple interface that defines all the token manager types
 */
interface ITokenManagerType {
    enum TokenManagerType {
        MINT_BURN,
        MINT_BURN_FROM,
        LOCK_UNLOCK,
        LOCK_UNLOCK_FEE
    }
}

// File: contracts/interfaces/its/IPausable.sol

pragma solidity ^0.8.9;

/**
 * @title Pausable
 * @notice This contract provides a mechanism to halt the execution of specific functions
 * if a pause condition is activated.
 */
interface IPausable {
    event PausedSet(bool indexed paused);

    error Paused();

    /**
     * @notice Check if the contract is paused
     * @return paused A boolean representing the pause status. True if paused, false otherwise.
     */
    function isPaused() external view returns (bool);
}

// File: contracts/interfaces/its/IMulticall.sol

pragma solidity ^0.8.9;

/**
 * @title IMulticall
 * @notice This contract is a multi-functional smart contract which allows for multiple
 * contract calls in a single transaction.
 */
interface IMulticall {
    /**
     * @notice Performs multiple delegate calls and returns the results of all calls as an array
     * @dev This function requires that the contract has sufficient balance for the delegate calls.
     * If any of the calls fail, the function will revert with the failure message.
     * @param data An array of encoded function calls
     * @return results An bytes array with the return data of each function call
     */
    function multicall(bytes[] calldata data) external payable returns (bytes[] memory results);
}

// File: contracts/interfaces/its/IInterchainTokenService.sol

pragma solidity ^0.8.9;









interface IInterchainTokenService is
    ITokenManagerType,
    IExpressCallHandler,
    IAxelarExecutable,
    IPausable,
    IMulticall,
    IContractIdentifier
{
    error ZeroAddress();
    error LengthMismatch();
    error InvalidTokenManagerImplementation();
    error NotRemoteService();
    error TokenManagerDoesNotExist(bytes32 tokenId);
    error NotTokenManager();
    error ExecuteWithInterchainTokenFailed(address contractAddress);
    error NotCanonicalTokenManager();
    error GatewayToken();
    error TokenManagerDeploymentFailed();
    error StandardizedTokenDeploymentFailed();
    error DoesNotAcceptExpressExecute(address contractAddress);
    error SelectorUnknown();
    error InvalidMetadataVersion(uint32 version);
    error AlreadyExecuted(bytes32 commandId);
    error ExecuteWithTokenNotSupported();
    error InvalidExpressSelector();

    event TokenSent(bytes32 indexed tokenId, string destinationChain, bytes destinationAddress, uint256 indexed amount);
    event TokenSentWithData(
        bytes32 indexed tokenId,
        string destinationChain,
        bytes destinationAddress,
        uint256 indexed amount,
        address indexed sourceAddress,
        bytes data
    );
    event TokenReceived(
        bytes32 indexed tokenId,
        string sourceChain,
        address indexed destinationAddress,
        uint256 indexed amount
    );
    event TokenReceivedWithData(
        bytes32 indexed tokenId,
        string sourceChain,
        address indexed destinationAddress,
        uint256 indexed amount,
        bytes sourceAddress,
        bytes data
    );
    event RemoteTokenManagerDeploymentInitialized(
        bytes32 indexed tokenId,
        string destinationChain,
        uint256 indexed gasValue,
        TokenManagerType indexed tokenManagerType,
        bytes params
    );
    event RemoteStandardizedTokenAndManagerDeploymentInitialized(
        bytes32 indexed tokenId,
        string tokenName,
        string tokenSymbol,
        uint8 tokenDecimals,
        bytes distributor,
        bytes mintTo,
        uint256 indexed mintAmount,
        bytes operator,
        string destinationChain,
        uint256 indexed gasValue
    );
    event TokenManagerDeployed(bytes32 indexed tokenId, TokenManagerType indexed tokenManagerType, bytes params);
    event StandardizedTokenDeployed(
        bytes32 indexed tokenId,
        address indexed distributor,
        string name,
        string symbol,
        uint8 decimals,
        uint256 indexed mintAmount,
        address mintTo
    );
    event CustomTokenIdClaimed(bytes32 indexed tokenId, address indexed deployer, bytes32 indexed salt);

    /**
     * @notice Returns the address of the token manager deployer contract.
     * @return tokenManagerDeployerAddress The address of the token manager deployer contract.
     */
    function tokenManagerDeployer() external view returns (address tokenManagerDeployerAddress);

    /**
     * @notice Returns the address of the standardized token deployer contract.
     * @return standardizedTokenDeployerAddress The address of the standardized token deployer contract.
     */
    function standardizedTokenDeployer() external view returns (address standardizedTokenDeployerAddress);

    /**
     * @notice Returns the address of the token manager associated with the given tokenId.
     * @param tokenId The tokenId of the token manager.
     * @return tokenManagerAddress The address of the token manager.
     */
    function getTokenManagerAddress(bytes32 tokenId) external view returns (address tokenManagerAddress);

    /**
     * @notice Returns the address of the valid token manager associated with the given tokenId.
     * @param tokenId The tokenId of the token manager.
     * @return tokenManagerAddress The address of the valid token manager.
     */
    function getValidTokenManagerAddress(bytes32 tokenId) external view returns (address tokenManagerAddress);

    /**
     * @notice Returns the address of the token associated with the given tokenId.
     * @param tokenId The tokenId of the token manager.
     * @return tokenAddress The address of the token.
     */
    function getTokenAddress(bytes32 tokenId) external view returns (address tokenAddress);

    /**
     * @notice Returns the address of the standardized token associated with the given tokenId.
     * @param tokenId The tokenId of the standardized token.
     * @return tokenAddress The address of the standardized token.
     */
    function getStandardizedTokenAddress(bytes32 tokenId) external view returns (address tokenAddress);

    /**
     * @notice Returns the canonical tokenId associated with the given tokenAddress.
     * @param tokenAddress The address of the token.
     * @return tokenId The canonical tokenId associated with the tokenAddress.
     */
    function getCanonicalTokenId(address tokenAddress) external view returns (bytes32 tokenId);

    /**
     * @notice Returns the custom tokenId associated with the given operator and salt.
     * @param operator The operator address.
     * @param salt The salt used for token id calculation.
     * @return tokenId The custom tokenId associated with the operator and salt.
     */
    function getCustomTokenId(address operator, bytes32 salt) external view returns (bytes32 tokenId);

    /**
     * @notice Registers a canonical token and returns its associated tokenId.
     * @param tokenAddress The address of the canonical token.
     * @return tokenId The tokenId associated with the registered canonical token.
     */
    function registerCanonicalToken(address tokenAddress) external payable returns (bytes32 tokenId);

    /**
     * @notice Deploys a standardized canonical token on a remote chain.
     * @param tokenId The tokenId of the canonical token.
     * @param destinationChain The name of the destination chain.
     * @param gasValue The gas value for deployment.
     */
    function deployRemoteCanonicalToken(
        bytes32 tokenId,
        string calldata destinationChain,
        uint256 gasValue
    ) external payable;

    /**
     * @notice Deploys a custom token manager contract.
     * @param salt The salt used for token manager deployment.
     * @param tokenManagerType The type of token manager.
     * @param params The deployment parameters.
     * @return tokenId The tokenId of the deployed token manager.
     */
    function deployCustomTokenManager(
        bytes32 salt,
        TokenManagerType tokenManagerType,
        bytes memory params
    ) external payable returns (bytes32 tokenId);

    /**
     * @notice Deploys a custom token manager contract on a remote chain.
     * @param salt The salt used for token manager deployment.
     * @param destinationChain The name of the destination chain.
     * @param tokenManagerType The type of token manager.
     * @param params The deployment parameters.
     * @param gasValue The gas value for deployment.
     */
    function deployRemoteCustomTokenManager(
        bytes32 salt,
        string calldata destinationChain,
        TokenManagerType tokenManagerType,
        bytes calldata params,
        uint256 gasValue
    ) external payable returns (bytes32 tokenId);

    /**
     * @notice Deploys a standardized token and registers it. The token manager type will be lock/unlock unless the distributor matches its address, in which case it will be a mint/burn one.
     * @param salt The salt used for token deployment.
     * @param name The name of the standardized token.
     * @param symbol The symbol of the standardized token.
     * @param decimals The number of decimals for the standardized token.
     * @param mintAmount The amount of tokens to mint to the deployer.
     * @param distributor The address of the distributor for mint/burn operations.
     */
    function deployAndRegisterStandardizedToken(
        bytes32 salt,
        string calldata name,
        string calldata symbol,
        uint8 decimals,
        uint256 mintAmount,
        address distributor
    ) external payable;

    /**
     * @notice Deploys and registers a standardized token on a remote chain.
     * @param salt The salt used for token deployment.
     * @param name The name of the standardized tokens.
     * @param symbol The symbol of the standardized tokens.
     * @param decimals The number of decimals for the standardized tokens.
     * @param distributor The distributor data for mint/burn operations.
     * @param mintTo The address where the minted tokens will be sent upon deployment.
     * @param mintAmount The amount of tokens to be minted upon deployment.
     * @param operator The operator data for standardized tokens.
     * @param destinationChain The name of the destination chain.
     * @param gasValue The gas value for deployment.
     */
    function deployAndRegisterRemoteStandardizedToken(
        bytes32 salt,
        string memory name,
        string memory symbol,
        uint8 decimals,
        bytes memory distributor,
        bytes memory mintTo,
        uint256 mintAmount,
        bytes memory operator,
        string calldata destinationChain,
        uint256 gasValue
    ) external payable;

    /**
     * @notice Returns the implementation address for a given token manager type.
     * @param tokenManagerType The type of token manager.
     * @return tokenManagerAddress The address of the token manager implementation.
     */
    function getImplementation(uint256 tokenManagerType) external view returns (address tokenManagerAddress);

    function interchainTransfer(
        bytes32 tokenId,
        string calldata destinationChain,
        bytes calldata destinationAddress,
        uint256 amount,
        bytes calldata metadata
    ) external;

    function sendTokenWithData(
        bytes32 tokenId,
        string calldata destinationChain,
        bytes calldata destinationAddress,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @notice Initiates an interchain token transfer. Only callable by TokenManagers
     * @param tokenId The tokenId of the token to be transmitted.
     * @param sourceAddress The source address of the token.
     * @param destinationChain The name of the destination chain.
     * @param destinationAddress The destination address on the destination chain.
     * @param amount The amount of tokens to transmit.
     * @param metadata The metadata associated with the transmission.
     */
    function transmitSendToken(
        bytes32 tokenId,
        address sourceAddress,
        string calldata destinationChain,
        bytes memory destinationAddress,
        uint256 amount,
        bytes calldata metadata
    ) external payable;

    /**
     * @notice Sets the flow limits for multiple tokens.
     * @param tokenIds An array of tokenIds.
     * @param flowLimits An array of flow limits corresponding to the tokenIds.
     */
    function setFlowLimits(bytes32[] calldata tokenIds, uint256[] calldata flowLimits) external;

    /**
     * @notice Returns the flow limit for a specific token.
     * @param tokenId The tokenId of the token.
     * @return flowLimit The flow limit for the token.
     */
    function getFlowLimit(bytes32 tokenId) external view returns (uint256 flowLimit);

    /**
     * @notice Returns the total amount of outgoing flow for a specific token.
     * @param tokenId The tokenId of the token.
     * @return flowOutAmount The total amount of outgoing flow for the token.
     */
    function getFlowOutAmount(bytes32 tokenId) external view returns (uint256 flowOutAmount);

    /**
     * @notice Returns the total amount of incoming flow for a specific token.
     * @param tokenId The tokenId of the token.
     * @return flowInAmount The total amount of incoming flow for the token.
     */
    function getFlowInAmount(bytes32 tokenId) external view returns (uint256 flowInAmount);

    /**
     * @notice Sets the paused state of the contract.
     * @param paused The boolean value indicating whether the contract is paused or not.
     */
    function setPaused(bool paused) external;

    /**
     * @notice Uses the caller's tokens to fullfill a sendCall ahead of time. Use this only if you have detected an outgoing interchainTransfer that matches the parameters passed here.
     * @param payload the payload of the receive token
     * @param commandId the commandId calculated from the event at the sourceChain.
     */
    function expressReceiveToken(bytes calldata payload, bytes32 commandId, string calldata sourceChain) external;
}

// File: contracts/interfaces/chainflip/ICFReceiver.sol

pragma solidity ^0.8.9;

/// @title Chainflip Receiver Interface
/// @dev The ICFReceiver interface is the interface required to receive tokens and
/// cross-chain calls from the Chainflip Protocol.
interface ICFReceiver {
    /// @notice Called by Chainflip protocol when receiving tokens on destination chain.
    /// Contains the logic that will run the payload calldata content.
    /// @param sourceChain Source chain according to the Chainflip Protocol's nomenclature.
    /// @param sourceAddress Source address on the source chain.
    /// @param payload Value provided by Squid containing the calldata that will be ran on destination chain.
    /// Expected format is: abi.encode(ISquidMulticall.Call[] calls, address refundRecipient,
    /// bytes32 salt).
    /// @param token Address of the ERC20 token received. 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
    /// in case of native token.
    /// @param amount Amount of ERC20 token received. This will match msg.value for native tokens.
    function cfReceive(
        uint32 sourceChain,
        bytes calldata sourceAddress,
        bytes calldata payload,
        address token,
        uint256 amount
    ) external payable;
}

// File: contracts/interfaces/cctp/ICCTPTokenMessenger.sol

pragma solidity ^0.8.9;

/// @title TokenMessenger
/// @notice Sends messages and receives messages to/from MessageTransmitters
/// and to/from TokenMinters
interface ICCTPTokenMessenger {
    /// @notice Deposits and burns tokens from sender to be minted on destination domain.
    /// Emits a `DepositForBurn` event.
    /// @dev reverts if:
    /// - given burnToken is not supported
    /// - given destinationDomain has no TokenMessenger registered
    /// - transferFrom() reverts. For example, if sender's burnToken balance or approved allowance
    /// to this contract is less than `amount`.
    /// - burn() reverts. For example, if `amount` is 0.
    /// - MessageTransmitter returns false or reverts.
    /// @param amount amount of tokens to burn
    /// @param destinationDomain destination domain
    /// @param mintRecipient address of mint recipient on destination domain
    /// @param burnToken address of contract to burn deposited tokens, on local domain
    /// @return nonce unique nonce reserved by message
    function depositForBurn(
        uint256 amount,
        uint32 destinationDomain,
        bytes32 mintRecipient,
        address burnToken
    ) external returns (uint64 nonce);

    /// @notice Deposits and burns tokens from sender to be minted on destination domain. The mint
    /// on the destination domain must be called by `destinationCaller`.
    /// WARNING: if the `destinationCaller` does not represent a valid address as bytes32, then it will not be possible
    /// to broadcast the message on the destination domain. This is an advanced feature, and the standard
    /// depositForBurn() should be preferred for use cases where a specific destination caller is not required.
    /// Emits a `DepositForBurn` event.
    /// @dev reverts if:
    /// - given destinationCaller is zero address
    /// - given burnToken is not supported
    /// - given destinationDomain has no TokenMessenger registered
    /// - transferFrom() reverts. For example, if sender's burnToken balance or approved allowance
    /// to this contract is less than `amount`.
    /// - burn() reverts. For example, if `amount` is 0.
    /// - MessageTransmitter returns false or reverts.
    /// @param amount amount of tokens to burn
    /// @param destinationDomain destination domain
    /// @param mintRecipient address of mint recipient on destination domain
    /// @param burnToken address of contract to burn deposited tokens, on local domain
    /// @param destinationCaller caller on the destination domain, as bytes32
    /// @return nonce unique nonce reserved by message
    function depositForBurnWithCaller(
        uint256 amount,
        uint32 destinationDomain,
        bytes32 mintRecipient,
        address burnToken,
        bytes32 destinationCaller
    ) external returns (uint64 nonce);
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

// File: @axelar-network/axelar-cgp-solidity/contracts/interfaces/IAxelarGasService.sol

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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

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

// File: @axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarExpressExecutable.sol

pragma solidity ^0.8.0;



/**
 * @title IAxelarExpressExecutable
 * @notice Interface for the Axelar Express Executable contract.
 */
interface IAxelarExpressExecutable is IAxelarExecutable {
    // Custom errors
    error AlreadyExecuted();
    error InsufficientValue();
    error ExpressExecutorAlreadySet();

    /**
     * @notice Emitted when an express execution is successfully performed.
     * @param commandId The unique identifier for the command.
     * @param sourceChain The source chain.
     * @param sourceAddress The source address.
     * @param payloadHash The hash of the payload.
     * @param expressExecutor The address of the express executor.
     */
    event ExpressExecuted(
        bytes32 indexed commandId,
        string sourceChain,
        string sourceAddress,
        bytes32 payloadHash,
        address indexed expressExecutor
    );

    /**
     * @notice Emitted when an express execution with a token is successfully performed.
     * @param commandId The unique identifier for the command.
     * @param sourceChain The source chain.
     * @param sourceAddress The source address.
     * @param payloadHash The hash of the payload.
     * @param symbol The token symbol.
     * @param amount The amount of tokens.
     * @param expressExecutor The address of the express executor.
     */
    event ExpressExecutedWithToken(
        bytes32 indexed commandId,
        string sourceChain,
        string sourceAddress,
        bytes32 payloadHash,
        string symbol,
        uint256 indexed amount,
        address indexed expressExecutor
    );

    /**
     * @notice Emitted when an express execution is fulfilled.
     * @param commandId The commandId for the contractCall.
     * @param sourceChain The source chain.
     * @param sourceAddress The source address.
     * @param payloadHash The hash of the payload.
     * @param expressExecutor The address of the express executor.
     */
    event ExpressExecutionFulfilled(
        bytes32 indexed commandId,
        string sourceChain,
        string sourceAddress,
        bytes32 payloadHash,
        address indexed expressExecutor
    );

    /**
     * @notice Emitted when an express execution with a token is fulfilled.
     * @param commandId The commandId for the contractCallWithToken.
     * @param sourceChain The source chain.
     * @param sourceAddress The source address.
     * @param payloadHash The hash of the payload.
     * @param symbol The token symbol.
     * @param amount The amount of tokens.
     * @param expressExecutor The address of the express executor.
     */
    event ExpressExecutionWithTokenFulfilled(
        bytes32 indexed commandId,
        string sourceChain,
        string sourceAddress,
        bytes32 payloadHash,
        string symbol,
        uint256 indexed amount,
        address indexed expressExecutor
    );

    /**
     * @notice Returns the express executor for a given command.
     * @param commandId The commandId for the contractCall.
     * @param sourceChain The source chain.
     * @param sourceAddress The source address.
     * @param payloadHash The hash of the payload.
     * @return expressExecutor The address of the express executor.
     */
    function getExpressExecutor(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes32 payloadHash
    ) external view returns (address expressExecutor);

    /**
     * @notice Returns the express executor with token for a given command.
     * @param commandId The commandId for the contractCallWithToken.
     * @param sourceChain The source chain.
     * @param sourceAddress The source address.
     * @param payloadHash The hash of the payload.
     * @param symbol The token symbol.
     * @param amount The amount of tokens.
     * @return expressExecutor The address of the express executor.
     */
    function getExpressExecutorWithToken(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes32 payloadHash,
        string calldata symbol,
        uint256 amount
    ) external view returns (address expressExecutor);

    /**
     * @notice Express executes a contract call.
     * @param commandId The commandId for the contractCall.
     * @param sourceChain The source chain.
     * @param sourceAddress The source address.
     * @param payload The payload data.
     */
    function expressExecute(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload
    ) external payable;

    /**
     * @notice Express executes a contract call with token.
     * @param commandId The commandId for the contractCallWithToken.
     * @param sourceChain The source chain.
     * @param sourceAddress The source address.
     * @param payload The payload data.
     * @param symbol The token symbol.
     * @param amount The amount of token.
     */
    function expressExecuteWithToken(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload,
        string calldata symbol,
        uint256 amount
    ) external payable;
}

// File: @axelar-network/axelar-gmp-sdk-solidity/contracts/express/ExpressExecutorTracker.sol

pragma solidity ^0.8.0;



abstract contract ExpressExecutorTracker is IAxelarExpressExecutable {
    bytes32 internal constant PREFIX_EXPRESS_EXECUTE = keccak256('express-execute');
    bytes32 internal constant PREFIX_EXPRESS_EXECUTE_WITH_TOKEN = keccak256('express-execute-with-token');

    function _expressExecuteSlot(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes32 payloadHash
    ) internal pure returns (bytes32 slot) {
        slot = keccak256(abi.encode(PREFIX_EXPRESS_EXECUTE, commandId, sourceChain, sourceAddress, payloadHash));
    }

    function _expressExecuteWithTokenSlot(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes32 payloadHash,
        string calldata symbol,
        uint256 amount
    ) internal pure returns (bytes32 slot) {
        slot = keccak256(
            abi.encode(
                PREFIX_EXPRESS_EXECUTE_WITH_TOKEN,
                commandId,
                sourceChain,
                sourceAddress,
                payloadHash,
                symbol,
                amount
            )
        );
    }

    function getExpressExecutor(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes32 payloadHash
    ) external view returns (address expressExecutor) {
        bytes32 slot = _expressExecuteSlot(commandId, sourceChain, sourceAddress, payloadHash);

        assembly {
            expressExecutor := sload(slot)
        }
    }

    function getExpressExecutorWithToken(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes32 payloadHash,
        string calldata symbol,
        uint256 amount
    ) external view returns (address expressExecutor) {
        bytes32 slot = _expressExecuteWithTokenSlot(commandId, sourceChain, sourceAddress, payloadHash, symbol, amount);

        assembly {
            expressExecutor := sload(slot)
        }
    }

    function _setExpressExecutor(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes32 payloadHash,
        address expressExecutor
    ) internal {
        bytes32 slot = _expressExecuteSlot(commandId, sourceChain, sourceAddress, payloadHash);
        address currentExecutor;

        assembly {
            currentExecutor := sload(slot)
        }

        if (currentExecutor != address(0)) revert ExpressExecutorAlreadySet();

        assembly {
            sstore(slot, expressExecutor)
        }
    }

    function _setExpressExecutorWithToken(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes32 payloadHash,
        string calldata symbol,
        uint256 amount,
        address expressExecutor
    ) internal {
        bytes32 slot = _expressExecuteWithTokenSlot(commandId, sourceChain, sourceAddress, payloadHash, symbol, amount);
        address currentExecutor;

        assembly {
            currentExecutor := sload(slot)
        }

        if (currentExecutor != address(0)) revert ExpressExecutorAlreadySet();

        assembly {
            sstore(slot, expressExecutor)
        }
    }

    function _popExpressExecutor(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes32 payloadHash
    ) internal returns (address expressExecutor) {
        bytes32 slot = _expressExecuteSlot(commandId, sourceChain, sourceAddress, payloadHash);

        assembly {
            expressExecutor := sload(slot)
            if expressExecutor {
                sstore(slot, 0)
            }
        }
    }

    function _popExpressExecutorWithToken(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes32 payloadHash,
        string calldata symbol,
        uint256 amount
    ) internal returns (address expressExecutor) {
        bytes32 slot = _expressExecuteWithTokenSlot(commandId, sourceChain, sourceAddress, payloadHash, symbol, amount);

        assembly {
            expressExecutor := sload(slot)
            if expressExecutor {
                sstore(slot, 0)
            }
        }
    }
}

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

// File: @axelar-network/axelar-gmp-sdk-solidity/contracts/express/AxelarExpressExecutable.sol

pragma solidity ^0.8.0;







contract AxelarExpressExecutable is ExpressExecutorTracker {
    using SafeTokenTransfer for IERC20;
    using SafeTokenTransferFrom for IERC20;

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

        address expressExecutor = _popExpressExecutor(commandId, sourceChain, sourceAddress, payloadHash);

        if (expressExecutor != address(0)) {
            // slither-disable-next-line reentrancy-events
            emit ExpressExecutionFulfilled(commandId, sourceChain, sourceAddress, payloadHash, expressExecutor);
        } else {
            _execute(sourceChain, sourceAddress, payload);
        }
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

        address expressExecutor = _popExpressExecutorWithToken(
            commandId,
            sourceChain,
            sourceAddress,
            payloadHash,
            tokenSymbol,
            amount
        );

        if (expressExecutor != address(0)) {
            // slither-disable-next-line reentrancy-events
            emit ExpressExecutionWithTokenFulfilled(
                commandId,
                sourceChain,
                sourceAddress,
                payloadHash,
                tokenSymbol,
                amount,
                expressExecutor
            );

            address gatewayToken = gateway.tokenAddresses(tokenSymbol);
            IERC20(gatewayToken).safeTransfer(expressExecutor, amount);
        } else {
            _executeWithToken(sourceChain, sourceAddress, payload, tokenSymbol, amount);
        }
    }

    function expressExecute(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload
    ) external payable virtual {
        if (gateway.isCommandExecuted(commandId)) revert AlreadyExecuted();

        address expressExecutor = msg.sender;
        bytes32 payloadHash = keccak256(payload);

        emit ExpressExecuted(commandId, sourceChain, sourceAddress, payloadHash, expressExecutor);

        _setExpressExecutor(commandId, sourceChain, sourceAddress, payloadHash, expressExecutor);

        _execute(sourceChain, sourceAddress, payload);
    }

    function expressExecuteWithToken(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload,
        string calldata symbol,
        uint256 amount
    ) external payable virtual {
        if (gateway.isCommandExecuted(commandId)) revert AlreadyExecuted();

        address expressExecutor = msg.sender;
        address gatewayToken = gateway.tokenAddresses(symbol);
        bytes32 payloadHash = keccak256(payload);

        emit ExpressExecutedWithToken(
            commandId,
            sourceChain,
            sourceAddress,
            payloadHash,
            symbol,
            amount,
            expressExecutor
        );

        _setExpressExecutorWithToken(
            commandId,
            sourceChain,
            sourceAddress,
            payloadHash,
            symbol,
            amount,
            expressExecutor
        );

        IERC20(gatewayToken).safeTransferFrom(expressExecutor, address(this), amount);

        _executeWithToken(sourceChain, sourceAddress, payload, symbol, amount);
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

// File: contracts/interfaces/its/IInterchainTokenExecutable.sol

pragma solidity ^0.8.0;

/**
 * @title IInterchainTokenExecutable
 * @notice Contracts should implement this interface to accept calls from the InterchainTokenService.
 */
interface IInterchainTokenExecutable {
    /**
     * @notice This will be called after the tokens are sent to this contract.
     * @dev Execution should revert unless the msg.sender is the InterchainTokenService
     * @param commandId The unique message id for the call.
     * @param sourceChain The name of the source chain.
     * @param sourceAddress The address that sent the contract call.
     * @param data The data to be processed.
     * @param tokenId The tokenId of the token manager managing the token.
     * @param token The address of the token.
     * @param amount The amount of tokens that were sent.
     * @return bytes32 Hash indicating success of the execution.
     */
    function executeWithInterchainToken(
        bytes32 commandId,
        string calldata sourceChain,
        bytes calldata sourceAddress,
        bytes calldata data,
        bytes32 tokenId,
        address token,
        uint256 amount
    ) external returns (bytes32);
}

// File: contracts/interfaces/its/IInterchainTokenExpressExecutable.sol

pragma solidity ^0.8.0;



/**
 * @title IInterchainTokenExpressExecutable
 * @notice Contracts should implement this interface to accept express calls from the InterchainTokenService.
 */
interface IInterchainTokenExpressExecutable is IInterchainTokenExecutable {
    /**
     * @notice Executes express logic in the context of an interchain token transfer.
     * @dev Only callable by the interchain token service.
     * @param commandId The unique message id for the call.
     * @param sourceChain The source chain of the token transfer.
     * @param sourceAddress The source address of the token transfer.
     * @param data The data associated with the token transfer.
     * @param tokenId The token ID.
     * @param token The token address.
     * @param amount The amount of tokens to be transferred.
     * @return bytes32 Hash indicating success of the express execution.
     */
    function expressExecuteWithInterchainToken(
        bytes32 commandId,
        string calldata sourceChain,
        bytes calldata sourceAddress,
        bytes calldata data,
        bytes32 tokenId,
        address token,
        uint256 amount
    ) external returns (bytes32);
}

// File: contracts/interfaces/its/InterchainTokenExecutable.sol

pragma solidity ^0.8.0;



/**
 * @title InterchainTokenExecutable
 * @notice Abstract contract that defines an interface for executing arbitrary logic
 * in the context of interchain token operations.
 * @dev This contract should be inherited by contracts that intend to execute custom
 * logic in response to interchain token actions such as transfers. This contract
 * will only be called by the interchain token service.
 */
abstract contract InterchainTokenExecutable is IInterchainTokenExecutable {
    error NotService(address caller);

    address public immutable interchainTokenService;

    bytes32 internal constant EXECUTE_SUCCESS = keccak256("its-execute-success");

    /**
     * @notice Creates a new InterchainTokenExecutable contract.
     * @param interchainTokenService_ The address of the interchain token service that will call this contract.
     */
    constructor(address interchainTokenService_) {
        interchainTokenService = interchainTokenService_;
    }

    /**
     * Modifier to restrict function execution to the interchain token service.
     */
    modifier onlyService() {
        if (msg.sender != interchainTokenService) revert NotService(msg.sender);
        _;
    }

    /**
     * @notice Executes logic in the context of an interchain token transfer.
     * @dev Only callable by the interchain token service.
     * @param commandId The message id for the call.
     * @param sourceChain The source chain of the token transfer.
     * @param sourceAddress The source address of the token transfer.
     * @param data The data associated with the token transfer.
     * @param tokenId The token ID.
     * @param token The token address.
     * @param amount The amount of tokens being transferred.
     * @return bytes32 Hash indicating success of the execution.
     */
    function executeWithInterchainToken(
        bytes32 commandId,
        string calldata sourceChain,
        bytes calldata sourceAddress,
        bytes calldata data,
        bytes32 tokenId,
        address token,
        uint256 amount
    ) external virtual onlyService returns (bytes32) {
        _executeWithInterchainToken(commandId, sourceChain, sourceAddress, data, tokenId, token, amount);
        return EXECUTE_SUCCESS;
    }

    /**
     * @notice Internal function containing the logic to be executed with interchain token transfer.
     * @dev Logic must be implemented by derived contracts.
     * @param sourceChain The source chain of the token transfer.
     * @param sourceAddress The source address of the token transfer.
     * @param data The data associated with the token transfer.
     * @param tokenId The token ID.
     * @param token The token address.
     * @param amount The amount of tokens being transferred.
     */
    function _executeWithInterchainToken(
        bytes32 commandId,
        string calldata sourceChain,
        bytes calldata sourceAddress,
        bytes calldata data,
        bytes32 tokenId,
        address token,
        uint256 amount
    ) internal virtual;
}

// File: contracts/interfaces/its/InterchainTokenExpressExecutable.sol

pragma solidity ^0.8.0;




/**
 * @title InterchainTokenExpressExecutable
 * @notice Abstract contract that defines an interface for executing express logic in the context of interchain token operations.
 * @dev This contract extends `InterchainTokenExecutable` to provide express execution capabilities. It is intended to be inherited by contracts
 * that implement express logic for interchain token actions. This contract will only be called by the interchain token service.
 */
abstract contract InterchainTokenExpressExecutable is IInterchainTokenExpressExecutable, InterchainTokenExecutable {
    bytes32 internal constant EXPRESS_EXECUTE_SUCCESS = keccak256("its-express-execute-success");

    /**
     * @notice Creates a new InterchainTokenExpressExecutable contract.
     * @param interchainTokenService_ The address of the interchain token service that will call this contract.
     */
    constructor(address interchainTokenService_) InterchainTokenExecutable(interchainTokenService_) {}

    /**
     * @notice Executes express logic in the context of an interchain token transfer.
     * @dev Only callable by the interchain token service.
     * @param commandId The message id for the call.
     * @param sourceChain The source chain of the token transfer.
     * @param sourceAddress The source address of the token transfer.
     * @param data The data associated with the token transfer.
     * @param tokenId The token ID.
     * @param token The token address.
     * @param amount The amount of tokens to be transferred.
     * @return bytes32 Hash indicating success of the express execution.
     */
    function expressExecuteWithInterchainToken(
        bytes32 commandId,
        string calldata sourceChain,
        bytes calldata sourceAddress,
        bytes calldata data,
        bytes32 tokenId,
        address token,
        uint256 amount
    ) external virtual onlyService returns (bytes32) {
        _executeWithInterchainToken(commandId, sourceChain, sourceAddress, data, tokenId, token, amount);
        return EXPRESS_EXECUTE_SUCCESS;
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

        assembly {
            sstore(_IMPLEMENTATION_SLOT, newImplementation)
        }

        emit Upgraded(newImplementation);

        if (params.length > 0) {
            // slither-disable-next-line controlled-delegatecall
            (bool success, ) = newImplementation.delegatecall(abi.encodeWithSelector(this.setup.selector, params));

            if (!success) revert SetupFailed();
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

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/extensions/IERC20Permit.sol)

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

// File: @openzeppelin/contracts/utils/Address.sol

// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)

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
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
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
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
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
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
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

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol

// OpenZeppelin Contracts (last updated v4.9.3) (token/ERC20/utils/SafeERC20.sol)

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

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
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

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance + value));
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance - value));
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeWithSelector(token.approve.selector, spender, value);

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, 0));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Use a ERC-2612 signature to set the `owner` approval toward `spender` on `token`.
     * Revert on invalid signature.
     */
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
        require(returndata.length == 0 || abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return
            success && (returndata.length == 0 || abi.decode(returndata, (bool))) && Address.isContract(address(token));
    }
}

// File: contracts/libraries/StorageSlot.sol

pragma solidity ^0.8.9;

/// @title StorageSlot
/// @notice Provide functions to easily read and write different type of
/// values at specific slots in storage.
library StorageSlot {
    /// @notice Enable to set a uint256 value at a specific slot in storage.
    /// @param slot Slot to be written in.
    /// @param value Value to be written in the slot.
    function setUint256(bytes32 slot, uint256 value) internal {
        assembly {
            sstore(slot, value)
        }
    }

    /// @notice Enable to get a uint256 value at a specific slot in storage.
    /// @param slot Slot to get value from.
    function getUint256(bytes32 slot) internal view returns (uint256 value) {
        assembly {
            value := sload(slot)
        }
    }

    /// @notice Enable to set an address value at a specific slot in storage.
    /// @param slot Slot to be written in.
    /// @param value Value to be written in the slot.
    function setAddress(bytes32 slot, address value) internal {
        assembly {
            sstore(slot, value)
        }
    }

    /// @notice Enable to get a address value at a specific slot in storage.
    /// @param slot Slot to get value from.
    function getAddress(bytes32 slot) internal view returns (address value) {
        assembly {
            value := sload(slot)
        }
    }

    /// @notice Enable to set a bool value at a specific slot in storage.
    /// @param slot Slot to be written in.
    /// @param value Value to be written in the slot.
    function setBool(bytes32 slot, bool value) internal {
        assembly {
            sstore(slot, value)
        }
    }

    /// @notice Enable to get a bool value at a specific slot in storage.
    /// @param slot Slot to get value from.
    function getBool(bytes32 slot) internal view returns (bool value) {
        assembly {
            value := sload(slot)
        }
    }
}

// File: contracts/router/SquidPermit2.sol

pragma solidity 0.8.23;




abstract contract SquidPermit2 {
    // Type hashes required for witness encoding for permit2 in SquidRouter.
    bytes32 public constant FUND_AND_RUN_MULTICALL_DATA_TYPEHASH =
        keccak256("FundAndRunMulticallData(bytes32 hashedCalls)");
    bytes32 public constant CCTP_BRIDGE_DATA_TYPEHASH =
        keccak256(
            "CCTPBridgeData(uint32 destinationDomain,bytes32 destinationAddress,bytes32 destinationCaller)"
        );

    // Witness type strings required for witness encoding for permit2 in SquidRouter.
    string public constant FUND_AND_RUN_MULTICALL_WITNESS_TYPE_STRING =
        "FundAndRunMulticallData witness)FundAndRunMulticallData(bytes32 hashedCalls)TokenPermissions(address token,uint256 amount)";
    string public constant CCTP_BRIDGE_WITNESS_TYPE_STRING =
        "CCTPBridgeData witness)CCTPBridgeData(uint32 destinationDomain,bytes32 destinationAddress,bytes32 destinationCaller)TokenPermissions(address token,uint256 amount)";

    IPermit2 public immutable permit2;

    /// @notice Thrown when a function using permit2 protocol is called why it is not available on current network.
    error Permit2Unavailable();
    /// @notice Thrown when a transferFrom2 call does not either have regular ERC20 or permit2 allowance.
    error TransferFailed();
    /// @notice Thrown when a value greater than type(uint160).max is cast to uint160.
    error UnsafeCast();

    /// @param _permit2 Address of the relevant Uniswap's Permit2.sol contract deployment
    /// Can be zero address if permit2 is not available on current network.
    constructor(address _permit2) {
        permit2 = IPermit2(_permit2);
    }

    /// @notice Check if permit2 is available on current network and revert otherwise.
    modifier onlyIfPermit2Available() {
        if (address(permit2) == address(0)) revert Permit2Unavailable();
        _;
    }

    /// @notice Try to transferFrom tokens with regular ERC20 allowance, and falls back to permit2 allowance
    /// if not.
    /// @param token Address of the ERC20 token to be collected.
    /// @param from Address of the holder of the funds to be collected.
    /// @param to Address of the receiver of the funds to be collected.
    /// @param amount Amount of ERC20 token to be collected.
    function _transferFrom2(address token, address from, address to, uint256 amount) internal {
        // Generate calldata for a standard transferFrom call.
        bytes memory inputData = abi.encodeCall(IERC20.transferFrom, (from, to, amount));

        bool success; // Call the token contract as normal, capturing whether it succeeded.
        assembly {
            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(eq(mload(0), 1), iszero(returndatasize())),
                // Counterintuitively, this call() must be positioned after the or() in the
                // surrounding and() because and() evaluates its arguments from right to left.
                // We use 0 and 32 to copy up to 32 bytes of return data into the first slot of scratch space.
                call(gas(), token, 0, add(inputData, 32), mload(inputData), 0, 32)
            )
        }

        // We'll fall back to using Permit2 if calling transferFrom on the token directly reverted.
        if (!success) {
            // Revert transfer if Permit2 is not available.
            if (address(permit2) == address(0)) revert TransferFailed();
            permit2.transferFrom(from, to, _toUint160(amount), address(token));
        }
    }

    /// @notice Safely casts uint256 to uint160.
    /// @param value The uint256 to be cast.
    /// @return Casted uint160 value.
    function _toUint160(uint256 value) private pure returns (uint160) {
        if (value > type(uint160).max) revert UnsafeCast();
        return uint160(value);
    }
}

// File: contracts/interfaces/IRoledPausable.sol

pragma solidity ^0.8.9;

/// @title RoledPausable
/// @notice Provide logic to pause a contract and grant au pauser role.
/// In case of a pauser update, current pauser provide the address of the potential new
/// pauser. Potential new pauser then has to accept the role.
/// @dev Contract uses hard coded slot values for variable to prevent storage clashes when upgrading.
interface IRoledPausable {
    /// @notice Emitted when current pauser starts the update process.
    /// @param currentPauser Address of the current pauser proposing new one.
    /// @param pendingPauser Address of the potential new pauser.
    event PauserProposed(address indexed currentPauser, address indexed pendingPauser);
    /// @notice Emitted when pending pauser accepts pauser role.
    /// @param newPauser Address of the new pauser.
    event PauserUpdated(address indexed newPauser);
    /// @notice Emitted when contract is paused.
    event Paused();
    /// @notice Emitted when contract is unpaused.
    event Unpaused();

    /// @notice Thrown when a pausable function is called while the contract is paused.
    error ContractIsPaused();
    /// @notice Thrown when function is only meant to be called by current pauser.
    error OnlyPauser();
    /// @notice Thrown when function is only meant to be called by pending pauser.
    error OnlyPendingPauser();

    /// @notice Start pauser role update process by providing new pauser address.
    /// @dev Only callable by current pauser.
    /// @param newPauser Address of the potential new pauser.
    function updatePauser(address newPauser) external;

    /// @notice Let pending pauser accept pauser role.
    /// @dev Only callable by pending pauser.
    function acceptPauser() external;

    /// @notice Let pauser pause the contract.
    /// @dev Only callable by current pauser.
    function pause() external;

    /// @notice Let pauser unpause the contract.
    /// @dev Only callable by current pauser.
    function unpause() external;

    /// @notice Get pause state.
    /// @dev Return true if paused and false if not paused.
    function paused() external view returns (bool value);

    /// @notice Get pauser address.
    function pauser() external view returns (address value);

    /// @notice Get pending pauser address.
    function pendingPauser() external view returns (address value);
}

// File: contracts/libraries/RoledPausable.sol

pragma solidity ^0.8.9;




abstract contract RoledPausable is IRoledPausable {
    using StorageSlot for bytes32;

    /// Hard coded slot numbers for contract variables.
    bytes32 internal constant PAUSED_SLOT = keccak256("RoledPausable.paused");
    bytes32 internal constant PAUSER_SLOT = keccak256("RoledPausable.pauser");
    bytes32 internal constant PENDING_PAUSER_SLOT = keccak256("RoledPausable.pendingPauser");

    /// @notice msg.sender has the pauser role by default.
    constructor() {
        _setPauser(msg.sender);
    }

    /// @notice Check if contract is paused and revert if so.
    /// @dev Meant to be used in inheritor contract.
    modifier whenNotPaused() {
        if (paused()) revert ContractIsPaused();
        _;
    }

    /// @inheritdoc IRoledPausable
    function updatePauser(address newPauser) external {
        _onlyPauser();
        PENDING_PAUSER_SLOT.setAddress(newPauser);
        emit PauserProposed(msg.sender, newPauser);
    }

    /// @inheritdoc IRoledPausable
    function acceptPauser() external {
        if (msg.sender != pendingPauser()) revert OnlyPendingPauser();
        _setPauser(msg.sender);
        PENDING_PAUSER_SLOT.setAddress(address(0));
    }

    /// @inheritdoc IRoledPausable
    function pause() external virtual {
        _onlyPauser();
        PAUSED_SLOT.setBool(true);
        emit Paused();
    }

    /// @inheritdoc IRoledPausable
    function unpause() external virtual {
        _onlyPauser();
        PAUSED_SLOT.setBool(false);
        emit Unpaused();
    }

    /// @inheritdoc IRoledPausable
    function paused() public view returns (bool value) {
        value = PAUSED_SLOT.getBool();
    }

    /// @inheritdoc IRoledPausable
    function pauser() public view returns (address value) {
        value = PAUSER_SLOT.getAddress();
    }

    /// @inheritdoc IRoledPausable
    function pendingPauser() public view returns (address value) {
        value = PENDING_PAUSER_SLOT.getAddress();
    }

    /// @notice Update pauser value in storage.
    /// @param _pauser New pauser address value.
    function _setPauser(address _pauser) internal {
        PAUSER_SLOT.setAddress(_pauser);
        emit PauserUpdated(_pauser);
    }

    /// @notice Check if caller is pauser and revert if not.
    /// @dev Meant to be used in inheritor contract.
    function _onlyPauser() internal view {
        if (msg.sender != pauser()) revert OnlyPauser();
    }
}

// File: contracts/libraries/Utils.sol

pragma solidity 0.8.23;





/// @title Utils
/// @notice Library for general purpose functions and values.
library Utils {
    using SafeERC20 for IERC20;
    using Address for address payable;

    /// @notice Thrown when an approval call to an ERC20 contract failed.
    error ApprovalFailed();
    /// @notice Thrown when service has zero address because not available on current chain.
    error ServiceUnavailable();

    /// @notice Arbitrary address chosen to represent native token of current network.
    address internal constant nativeToken = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    /// @notice Handle logic around approval for ERC20 token contracts depending on
    /// the context. Will give unlimited allowance on first call and only trigger
    /// again if allowance is below expected amount.
    /// @dev Handle allowance reset to comply with USDT token contract.
    /// @dev Should not be used with any contract that holds ERC20 tokens.
    /// @param token Address of the ERC20 token contract to send approval to.
    /// @param spender Address that will be granted allowance.
    /// @param amount Amount of ERC20 token to grant allowance for.
    function smartApprove(address token, address spender, uint256 amount) internal {
        uint256 allowance = IERC20(token).allowance(address(this), spender);
        if (allowance < amount) {
            if (allowance > 0) {
                _approveCall(token, spender, 0);
            }
            _approveCall(token, spender, type(uint256).max);
        }
    }

    /// @notice Create, send and check low level approval call.
    /// @dev Should not be used with any contract that holds ERC20 tokens.
    /// @param token Address of the ERC20 token contract to send approval to.
    /// @param spender Address that will be granted allowance.
    /// @param amount Amount of ERC20 token to grant allowance for.
    function _approveCall(address token, address spender, uint256 amount) private {
        // Unlimited approval is not security issue since the contract does not store any ERC20 token.
        (bool success, ) = token.call(
            abi.encodeWithSelector(IERC20.approve.selector, spender, amount)
        );
        if (!success) revert ApprovalFailed();
    }

    /// @notice Transfer token in a safe way wether it is ERC20 or native.
    /// @param token Address of the ERC20 token to be transfered.
    /// 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE in case of native token.
    /// @param to Address that will receive the tokens.
    /// @param amount Amount of ERC20 or native tokens to transfer.
    function smartTransfer(address token, address payable to, uint256 amount) internal {
        if (token == nativeToken) {
            to.sendValue(amount);
        } else {
            IERC20(token).safeTransfer(to, amount);
        }
    }

    /// @notice Make sure required service is available on current network by checking if an address
    /// have been provided for it. Revert transaction otherwise.
    /// @param service Address of the service to be checked.
    function checkServiceAvailability(address service) internal pure {
        if (service == address(0)) revert ServiceUnavailable();
    }
}

// File: contracts/router/SquidRouter.sol

pragma solidity 0.8.23;







 // Deprecated











contract SquidRouter is
    ISquidRouter,
    ICFReceiver,
    AxelarExpressExecutable,
    InterchainTokenExpressExecutable,
    Upgradable,
    SquidPermit2,
    RoledPausable
{
    using SafeERC20 for IERC20;
    using StorageSlot for bytes32;

    address public immutable squidMulticall;
    address public immutable chainflipVault;
    address public immutable usdc;
    address public immutable cctpTokenMessenger;
    address public immutable axelarGasService; // Deprecated

    /// @param _squidMulticall Address of the relevant Squid's SquidMulticall.sol contract deployment.
    /// @param _permit2 Address of the relevant Uniswap's Permit2.sol contract deployment
    /// Can be zero address if not available on current network.
    /// @param _axelarGateway Address of the relevant Axelar's AxelarGateway.sol contract deployment.
    /// @param _interchainTokenService Address of the relevant Axelar's InterchainTokenService.sol contract
    /// deployment.
    /// @param _chainflipVault Address of the relevant Chainflip's Vault.sol contract deployment. Can be zero
    /// address if not available on current network.
    /// @param _usdc Address of the relevant Circle's USDC contract deployment (contract name defers from one chain
    /// to another). Can be zero address if not available on current network.
    /// @param _cctpTokenMessenger Address of the relevant Circle's TokenMessenger.sol contract deployment. Can be
    /// zero address if not available on current network.
    /// @param _axelarGasService Address of the relevant Axelar's AxelarGasService.sol contract deployment. The related
    /// logic is deprecated and will be removed in a future upgrade.
    constructor(
        address _squidMulticall,
        address _permit2,
        address _axelarGateway,
        address _interchainTokenService,
        address _chainflipVault,
        address _usdc,
        address _cctpTokenMessenger,
        address _axelarGasService // Deprecated
    )
        AxelarExpressExecutable(_axelarGateway)
        InterchainTokenExpressExecutable(_interchainTokenService)
        SquidPermit2(_permit2)
    {
        if (
            _squidMulticall == address(0) ||
            _interchainTokenService == address(0) ||
            _axelarGasService == address(0) // Deprecated
        ) revert ZeroAddressProvided();

        squidMulticall = _squidMulticall;
        chainflipVault = _chainflipVault;
        usdc = _usdc;
        cctpTokenMessenger = _cctpTokenMessenger;
        axelarGasService = _axelarGasService; // Deprecated
    }

    //////////////////////////////////////////////////////////////
    //                                                          //
    //                        Multicall                         //
    //                                                          //
    //////////////////////////////////////////////////////////////

    /// @inheritdoc ISquidRouter
    function fundAndRunMulticall(
        address token,
        uint256 amount,
        ISquidMulticall.Call[] calldata calls
    ) public payable whenNotPaused {
        // No transfer done if native token is selected as token
        if (token != Utils.nativeToken) {
            _transferFrom2(token, msg.sender, address(squidMulticall), amount);
        }

        ISquidMulticall(squidMulticall).run{value: msg.value}(calls);
    }

    /// @inheritdoc ISquidRouter
    function permitFundAndRunMulticall(
        ISquidMulticall.Call[] calldata calls,
        address from,
        IPermit2.PermitTransferFrom calldata permit,
        bytes calldata signature
    ) external payable whenNotPaused onlyIfPermit2Available {
        IPermit2.SignatureTransferDetails memory transferDetails = IPermit2
            .SignatureTransferDetails({
                to: address(squidMulticall),
                requestedAmount: permit.permitted.amount
            });

        if (from == msg.sender) {
            // If holder of the funds is sender of the transaction, call the relevant permit2 function.
            permit2.permitTransferFrom(permit, transferDetails, from, signature);
        } else {
            // If holder of the funds is not sender of the transaction, build the witness data and call the relevant
            // permit2 function.
            bytes32 hashedCalls = keccak256(abi.encode(calls));
            bytes32 witness = keccak256(
                abi.encode(FUND_AND_RUN_MULTICALL_DATA_TYPEHASH, hashedCalls)
            );
            permit2.permitWitnessTransferFrom(
                permit,
                transferDetails,
                from,
                witness,
                FUND_AND_RUN_MULTICALL_WITNESS_TYPE_STRING,
                signature
            );
        }

        ISquidMulticall(squidMulticall).run{value: msg.value}(calls);
    }

    //////////////////////////////////////////////////////////////
    //                                                          //
    //                     CCTP endpoints                       //
    //                                                          //
    //////////////////////////////////////////////////////////////

    /// @inheritdoc ISquidRouter
    function cctpBridge(
        uint256 amount,
        uint32 destinationDomain,
        bytes32 destinationAddress,
        bytes32 destinationCaller
    ) external whenNotPaused {
        Utils.checkServiceAvailability(cctpTokenMessenger);

        if (destinationCaller == bytes32(0)) revert ZeroAddressProvided();

        _transferFrom2(usdc, msg.sender, address(this), amount);

        ICCTPTokenMessenger(cctpTokenMessenger).depositForBurnWithCaller(
            amount,
            destinationDomain,
            destinationAddress,
            usdc,
            destinationCaller
        );
    }

    /// @inheritdoc ISquidRouter
    function permitCctpBridge(
        uint32 destinationDomain,
        bytes32 destinationAddress,
        bytes32 destinationCaller,
        address from,
        IPermit2.PermitTransferFrom calldata permit,
        bytes calldata signature
    ) external whenNotPaused onlyIfPermit2Available {
        Utils.checkServiceAvailability(cctpTokenMessenger);

        if (destinationCaller == bytes32(0)) revert ZeroAddressProvided();

        IPermit2.SignatureTransferDetails memory transferDetails = IPermit2
            .SignatureTransferDetails({
                to: address(this),
                requestedAmount: permit.permitted.amount
            });

        if (from == msg.sender) {
            // If holder of the funds is sender of the transaction, call the relevant permit2 function.
            permit2.permitTransferFrom(permit, transferDetails, from, signature);
        } else {
            // If holder of the funds is not sender of the transaction, build the witness data and call the relevant
            // permit2 function.
            bytes32 witness = keccak256(
                abi.encode(
                    CCTP_BRIDGE_DATA_TYPEHASH,
                    destinationDomain,
                    destinationAddress,
                    destinationCaller
                )
            );
            permit2.permitWitnessTransferFrom(
                permit,
                transferDetails,
                from,
                witness,
                CCTP_BRIDGE_WITNESS_TYPE_STRING,
                signature
            );
        }

        ICCTPTokenMessenger(cctpTokenMessenger).depositForBurnWithCaller(
            permit.permitted.amount,
            destinationDomain,
            destinationAddress,
            usdc,
            destinationCaller
        );
    }

    /// @inheritdoc ISquidRouter
    function approveCctpTokenMessenger() external onlyOwner {
        // Unlimited approval is not security issue since the contract does not store any ERC20 token.
        IERC20(usdc).approve(cctpTokenMessenger, type(uint256).max);
    }

    //////////////////////////////////////////////////////////////
    //                                                          //
    //                     Bridge receivers                     //
    //                                                          //
    //////////////////////////////////////////////////////////////

    /// @inheritdoc ICFReceiver
    function cfReceive(
        uint32,
        bytes calldata,
        bytes calldata payload,
        address token,
        uint256 amount
    ) external payable {
        if (msg.sender != chainflipVault) revert OnlyCfVault();
        _processDestinationCalls(payload, token, amount);
    }

    /// @notice Called by Axelar protocol when receiving ERC20 tokens on destination chain.
    /// Contains the logic that will run the payload calldata content.
    /// @param payload Value provided by Squid containing the calldata that will be ran on destination chain.
    /// Expected format is: abi.encode(ISquidMulticall.Call[] calls, address refundRecipient,
    /// bytes32 salt) or abi.encode(address refundRecipient, bytes32 salt) if funds need to be directly sent
    /// to destination address.
    /// @param tokenSymbol Symbol of the ERC20 token bridged.
    /// @param amount Amount of the ERC20 token bridged.
    function _executeWithToken(
        string calldata,
        string calldata,
        bytes calldata payload,
        string calldata tokenSymbol,
        uint256 amount
    ) internal override {
        address token = gateway.tokenAddresses(tokenSymbol);
        _processPayload(payload, token, amount);
    }

    /// @notice Called by Interchain Token Service when receiving tokens on destination chain.
    /// Contains the logic that will run the payload calldata content.
    /// @param payload Value provided by Squid containing the calldata that will be ran on destination chain.
    /// Expected format is: abi.encode(ISquidMulticall.Call[] calls, address refundRecipient,
    /// bytes32 salt) or abi.encode(address refundRecipient, bytes32 salt) if funds need to be directly sent
    /// to destination address.
    /// @param token Address of the ERC20 token bridged.
    /// @param amount Amount of the ERC20 token bridged.
    function _executeWithInterchainToken(
        bytes32,
        string calldata,
        bytes calldata,
        bytes calldata payload,
        bytes32,
        address token,
        uint256 amount
    ) internal override {
        _processPayload(payload, token, amount);
    }

    /// @notice Check size of payload and processes is accordingly. If there is no calls, send tokens
    /// directly to user. If there are calls, run them.
    /// @dev Does not work with native token.
    /// @param payload Value provided by Squid containing the calldata that will be ran on destination chain.
    /// Expected format is: abi.encode(ISquidMulticall.Call[] calls, address refundRecipient,
    /// bytes32 salt) or abi.encode(address refundRecipient, bytes32 salt) if funds need to be directly sent
    /// to destination address.
    /// @param token Address of the ERC20 token to be either provided to the multicall to run the calls, or
    /// sent to user.
    /// @param amount Amount of the ERC20 token used. Must match msg.value
    /// if native tokens.
    function _processPayload(bytes calldata payload, address token, uint256 amount) private {
        // If there is no call data, payload will be exactly 64 bytes (32 for padded address + 32
        // for salt)
        if (payload.length == 64) {
            (address destinationAddress, ) = abi.decode(payload, (address, bytes32));
            IERC20(token).safeTransfer(destinationAddress, amount);
        } else {
            _processDestinationCalls(payload, token, amount);
        }
    }

    /// @notice Parse payload, approve multicall and run calldata on it. In case of multicall fail,
    /// bridged ERC20 tokens are refunded to refund recipient address.
    /// @param token Address of the ERC20 token to be provided to the multicall to run the calls.
    /// 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE in case of native token.
    /// @param amount Amount of ERC20 or native tokens to be provided to the multicall. Must match msg.value
    /// if native tokens.
    /// @param payload Value to be parsed to get calldata that will be ran on multicall as well as
    /// refund recipient address.
    /// Expected format is: abi.encode(ISquidMulticall.Call[] calls, address refundRecipient,
    /// bytes32 salt).
    function _processDestinationCalls(
        bytes calldata payload,
        address token,
        uint256 amount
    ) private {
        (ISquidMulticall.Call[] memory calls, address payable refundRecipient, ) = abi.decode(
            payload,
            (ISquidMulticall.Call[], address, bytes32)
            // Last value is a salt that is only used to make to hash of payload vary in case of
            // identical content of 2 calls
        );

        if (token != Utils.nativeToken) {
            Utils.smartApprove(token, address(squidMulticall), amount);
        }

        try ISquidMulticall(squidMulticall).run{value: msg.value}(calls) {
            emit CrossMulticallExecuted(keccak256(payload));
        } catch (bytes memory reason) {
            // Refund tokens to refund recipient if swap fails
            Utils.smartTransfer(token, refundRecipient, amount);
            emit CrossMulticallFailed(keccak256(payload), reason, refundRecipient);
        }
    }

    //////////////////////////////////////////////////////////////
    //                                                          //
    //                        Utilities                         //
    //                                                          //
    //////////////////////////////////////////////////////////////

    /// @notice Enable onwer of the contract to transfer tokens that have been mistakenly sent to it.
    /// There is no custody risk as this contract is not meant to hold any funds in between users calls.
    /// @dev Only owner can call.
    /// @param token Address of the ERC20 token to be transfered.
    /// 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE in case of native token.
    /// @param to Address that will receive the tokens.
    /// @param amount Amount of ERC20 or native tokens to transfer.
    function rescueFunds(address token, address payable to, uint256 amount) external onlyOwner {
        Utils.smartTransfer(token, to, amount);
    }

    //////////////////////////////////////////////////////////////
    //                                                          //
    //                    Proxy requirements                    //
    //                                                          //
    //////////////////////////////////////////////////////////////

    /// @notice Return hard coded identifier for proxy check during upgrade.
    /// @return id Hardcoded id.
    function contractId() external pure override returns (bytes32 id) {
        id = keccak256("squid-router");
    }

    /// @notice Called by proxy during upgrade. Set pauser role to provided address.
    /// @param data Bytes containing pauser address. Checked for not zero address.
    /// Expected format is: abi.encode(address pauser).
    function _setup(bytes calldata data) internal override {
        address _pauser = abi.decode(data, (address));
        if (_pauser == address(0)) revert ZeroAddressProvided();
        _setPauser(_pauser);
    }

    //////////////////////////////////////////////////////////////
    //                                                          //
    //                    Deprecated endpoints                  //
    //                                                          //
    //////////////////////////////////////////////////////////////

    /// @inheritdoc ISquidRouter
    function bridgeCall(
        string calldata bridgedTokenSymbol,
        uint256 amount,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        address gasRefundRecipient,
        bool enableExpress
    ) external payable whenNotPaused {
        address bridgedTokenAddress = gateway.tokenAddresses(bridgedTokenSymbol);
        _transferFrom2(bridgedTokenAddress, msg.sender, address(this), amount);

        _bridgeCall(
            bridgedTokenSymbol,
            bridgedTokenAddress,
            destinationChain,
            destinationAddress,
            payload,
            gasRefundRecipient,
            enableExpress
        );
    }

    /// @inheritdoc ISquidRouter
    function callBridgeCall(
        address token,
        uint256 amount,
        ISquidMulticall.Call[] calldata calls,
        string calldata bridgedTokenSymbol,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        address gasRefundRecipient,
        bool enableExpress
    ) external payable whenNotPaused {
        uint256 valueToSend;
        if (token == Utils.nativeToken) {
            valueToSend = amount;
        } else {
            _transferFrom2(token, msg.sender, address(squidMulticall), amount);
        }

        ISquidMulticall(squidMulticall).run{value: valueToSend}(calls);

        address bridgedTokenAddress = gateway.tokenAddresses(bridgedTokenSymbol);
        _bridgeCall(
            bridgedTokenSymbol,
            bridgedTokenAddress,
            destinationChain,
            destinationAddress,
            payload,
            gasRefundRecipient,
            enableExpress
        );
    }

    /// @notice Helper for handling Axelar gas service funding and Axelar bridging.
    /// @param bridgedTokenSymbol Symbol of the ERC20 token that will be sent to Axelar bridge.
    /// @param bridgedTokenAddress Address of the ERC20 token that will be sent to Axelar bridge.
    /// @param destinationChain Destination chain for bridging according to Axelar's nomenclature.
    /// @param destinationAddress Address that will receive bridged ERC20 tokens on destination chain.
    /// @param payload Bytes value containing calls to be ran by the multicall on destination chain.
    /// Expected format is: abi.encode(ISquidMulticall.Call[] calls, address refundRecipient, bytes32 salt).
    /// @param gasRefundRecipient Address that will receive native tokens left on gas service after process is
    /// done.
    /// @param enableExpress If true is provided, Axelar's express (aka Squid's boost) feature will be used.
    function _bridgeCall(
        string calldata bridgedTokenSymbol,
        address bridgedTokenAddress,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        address gasRefundRecipient,
        bool enableExpress
    ) private {
        uint256 bridgedTokenBalance = IERC20(bridgedTokenAddress).balanceOf(address(this));

        if (address(this).balance > 0) {
            if (enableExpress) {
                IAxelarGasService(axelarGasService).payNativeGasForExpressCallWithToken{
                    value: address(this).balance
                }(
                    address(this),
                    destinationChain,
                    destinationAddress,
                    payload,
                    bridgedTokenSymbol,
                    bridgedTokenBalance,
                    gasRefundRecipient
                );
            } else {
                IAxelarGasService(axelarGasService).payNativeGasForContractCallWithToken{
                    value: address(this).balance
                }(
                    address(this),
                    destinationChain,
                    destinationAddress,
                    payload,
                    bridgedTokenSymbol,
                    bridgedTokenBalance,
                    gasRefundRecipient
                );
            }
        }

        Utils.smartApprove(bridgedTokenAddress, address(gateway), bridgedTokenBalance);
        gateway.callContractWithToken(
            destinationChain,
            destinationAddress,
            payload,
            bridgedTokenSymbol,
            bridgedTokenBalance
        );
    }
}
