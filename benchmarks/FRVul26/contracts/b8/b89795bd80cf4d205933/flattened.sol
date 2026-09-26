// Sources retrieved from Sourcify API v2.
// Deterministic best-effort flattening; original files are preserved under src/.

// File: src/interfaces/ISuperRegistry.sol

pragma solidity ^0.8.23;

/// @title ISuperRegistry
/// @dev Interface for SuperRegistry
/// @author Zeropoint Labs
interface ISuperRegistry {
    //////////////////////////////////////////////////////////////
    //                          EVENTS                          //
    //////////////////////////////////////////////////////////////

    /// @dev emitted when permit2 is set.
    event SetPermit2(address indexed permit2);

    /// @dev is emitted when an address is set.
    event AddressUpdated(
        bytes32 indexed protocolAddressId, uint64 indexed chainId, address indexed oldAddress, address newAddress
    );

    /// @dev is emitted when a new token bridge is configured.
    event SetBridgeAddress(uint256 indexed bridgeId, address indexed bridgeAddress);

    /// @dev is emitted when a new bridge validator is configured.
    event SetBridgeValidator(uint256 indexed bridgeId, address indexed bridgeValidator);

    /// @dev is emitted when a new amb is configured.
    event SetAmbAddress(uint8 indexed ambId_, address indexed ambAddress_, bool indexed isBroadcastAMB_);

    /// @dev is emitted when a new state registry is configured.
    event SetStateRegistryAddress(uint8 indexed registryId_, address indexed registryAddress_);

    /// @dev is emitted when a new delay is configured.
    event SetDelay(uint256 indexed oldDelay_, uint256 indexed newDelay_);

    /// @dev is emitted when a new vault limit is configured
    event SetVaultLimitPerDestination(uint64 indexed chainId_, uint256 indexed vaultLimit_);

    //////////////////////////////////////////////////////////////
    //              EXTERNAL VIEW FUNCTIONS                     //
    //////////////////////////////////////////////////////////////

    /// @dev gets the deposit rescue delay
    function delay() external view returns (uint256);

    /// @dev returns the permit2 address
    function PERMIT2() external view returns (address);

    /// @dev returns the id of the superform router module
    function SUPERFORM_ROUTER() external view returns (bytes32);

    /// @dev returns the id of the superform factory module
    function SUPERFORM_FACTORY() external view returns (bytes32);

    /// @dev returns the id of the superform paymaster contract
    function PAYMASTER() external view returns (bytes32);

    /// @dev returns the id of the superform payload helper contract
    function PAYMENT_HELPER() external view returns (bytes32);

    /// @dev returns the id of the core state registry module
    function CORE_STATE_REGISTRY() external view returns (bytes32);

    /// @dev returns the id of the timelock form state registry module
    function TIMELOCK_STATE_REGISTRY() external view returns (bytes32);

    /// @dev returns the id of the broadcast state registry module
    function BROADCAST_REGISTRY() external view returns (bytes32);

    /// @dev returns the id of the super positions module
    function SUPER_POSITIONS() external view returns (bytes32);

    /// @dev returns the id of the super rbac module
    function SUPER_RBAC() external view returns (bytes32);

    /// @dev returns the id of the payload helper module
    function PAYLOAD_HELPER() external view returns (bytes32);

    /// @dev returns the id of the dst swapper keeper
    function DST_SWAPPER() external view returns (bytes32);

    /// @dev returns the id of the emergency queue
    function EMERGENCY_QUEUE() external view returns (bytes32);

    /// @dev returns the id of the superform receiver
    function SUPERFORM_RECEIVER() external view returns (bytes32);

    /// @dev returns the id of the payment admin keeper
    function PAYMENT_ADMIN() external view returns (bytes32);

    /// @dev returns the id of the core state registry processor keeper
    function CORE_REGISTRY_PROCESSOR() external view returns (bytes32);

    /// @dev returns the id of the broadcast registry processor keeper
    function BROADCAST_REGISTRY_PROCESSOR() external view returns (bytes32);

    /// @dev returns the id of the timelock form state registry processor keeper
    function TIMELOCK_REGISTRY_PROCESSOR() external view returns (bytes32);

    /// @dev returns the id of the core state registry updater keeper
    function CORE_REGISTRY_UPDATER() external view returns (bytes32);

    /// @dev returns the id of the core state registry updater keeper
    function CORE_REGISTRY_RESCUER() external view returns (bytes32);

    /// @dev returns the id of the core state registry updater keeper
    function CORE_REGISTRY_DISPUTER() external view returns (bytes32);

    /// @dev returns the id of the core state registry updater keeper
    function DST_SWAPPER_PROCESSOR() external view returns (bytes32);

    /// @dev gets the address of a contract on current chain
    /// @param id_ is the id of the contract
    function getAddress(bytes32 id_) external view returns (address);

    /// @dev gets the address of a contract on a target chain
    /// @param id_ is the id of the contract
    /// @param chainId_ is the chain id of that chain
    function getAddressByChainId(bytes32 id_, uint64 chainId_) external view returns (address);

    /// @dev gets the address of a bridge
    /// @param bridgeId_ is the id of a bridge
    /// @return bridgeAddress_ is the address of the form
    function getBridgeAddress(uint8 bridgeId_) external view returns (address bridgeAddress_);

    /// @dev gets the address of a bridge validator
    /// @param bridgeId_ is the id of a bridge
    /// @return bridgeValidator_ is the address of the form
    function getBridgeValidator(uint8 bridgeId_) external view returns (address bridgeValidator_);

    /// @dev gets the address of a amb
    /// @param ambId_ is the id of a bridge
    /// @return ambAddress_ is the address of the form
    function getAmbAddress(uint8 ambId_) external view returns (address ambAddress_);

    /// @dev gets the id of the amb
    /// @param ambAddress_ is the address of an amb
    /// @return ambId_ is the identifier of an amb
    function getAmbId(address ambAddress_) external view returns (uint8 ambId_);

    /// @dev gets the address of the registry
    /// @param registryId_ is the id of the state registry
    /// @return registryAddress_ is the address of the state registry
    function getStateRegistry(uint8 registryId_) external view returns (address registryAddress_);

    /// @dev gets the id of the registry
    /// @notice reverts if the id is not found
    /// @param registryAddress_ is the address of the state registry
    /// @return registryId_ is the id of the state registry
    function getStateRegistryId(address registryAddress_) external view returns (uint8 registryId_);

    /// @dev gets the safe vault limit
    /// @param chainId_ is the id of the remote chain
    /// @return vaultLimitPerDestination_ is the safe number of vaults to deposit
    /// without hitting out of gas error
    function getVaultLimitPerDestination(uint64 chainId_) external view returns (uint256 vaultLimitPerDestination_);

    /// @dev helps validate if an address is a valid state registry
    /// @param registryAddress_ is the address of the state registry
    /// @return valid_ a flag indicating if its valid.
    function isValidStateRegistry(address registryAddress_) external view returns (bool valid_);

    /// @dev helps validate if an address is a valid amb implementation
    /// @param ambAddress_ is the address of the amb implementation
    /// @return valid_ a flag indicating if its valid.
    function isValidAmbImpl(address ambAddress_) external view returns (bool valid_);

    /// @dev helps validate if an address is a valid broadcast amb implementation
    /// @param ambAddress_ is the address of the broadcast amb implementation
    /// @return valid_ a flag indicating if its valid.
    function isValidBroadcastAmbImpl(address ambAddress_) external view returns (bool valid_);

    //////////////////////////////////////////////////////////////
    //              EXTERNAL WRITE FUNCTIONS                    //
    //////////////////////////////////////////////////////////////

    /// @dev sets the deposit rescue delay
    /// @param delay_ the delay in seconds before the deposit rescue can be finalized
    function setDelay(uint256 delay_) external;

    /// @dev sets the permit2 address
    /// @param permit2_ the address of the permit2 contract
    function setPermit2(address permit2_) external;

    /// @dev sets the safe vault limit
    /// @param chainId_ is the remote chain identifier
    /// @param vaultLimit_ is the max limit of vaults per transaction
    function setVaultLimitPerDestination(uint64 chainId_, uint256 vaultLimit_) external;

    /// @dev sets new addresses on specific chains.
    /// @param ids_ are the identifiers of the address on that chain
    /// @param newAddresses_  are the new addresses on that chain
    /// @param chainIds_ are the chain ids of that chain
    function batchSetAddress(
        bytes32[] calldata ids_,
        address[] calldata newAddresses_,
        uint64[] calldata chainIds_
    )
        external;

    /// @dev sets a new address on a specific chain.
    /// @param id_ the identifier of the address on that chain
    /// @param newAddress_ the new address on that chain
    /// @param chainId_ the chain id of that chain
    function setAddress(bytes32 id_, address newAddress_, uint64 chainId_) external;

    /// @dev allows admin to set the bridge address for an bridge id.
    /// @notice this function operates in an APPEND-ONLY fashion.
    /// @param bridgeId_         represents the bridge unique identifier.
    /// @param bridgeAddress_    represents the bridge address.
    /// @param bridgeValidator_  represents the bridge validator address.
    function setBridgeAddresses(
        uint8[] memory bridgeId_,
        address[] memory bridgeAddress_,
        address[] memory bridgeValidator_
    )
        external;

    /// @dev allows admin to set the amb address for an amb id.
    /// @notice this function operates in an APPEND-ONLY fashion.
    /// @param ambId_         represents the bridge unique identifier.
    /// @param ambAddress_    represents the bridge address.
    /// @param isBroadcastAMB_ represents whether the amb implementation supports broadcasting
    function setAmbAddress(
        uint8[] memory ambId_,
        address[] memory ambAddress_,
        bool[] memory isBroadcastAMB_
    )
        external;

    /// @dev allows admin to set the state registry address for an state registry id.
    /// @notice this function operates in an APPEND-ONLY fashion.
    /// @param registryId_    represents the state registry's unique identifier.
    /// @param registryAddress_    represents the state registry's address.
    function setStateRegistryAddress(uint8[] memory registryId_, address[] memory registryAddress_) external;
}

// File: src/interfaces/IBridgeValidator.sol

pragma solidity ^0.8.23;

/// @title Bridge Validator Interface
/// @dev Interface all Bridge Validators must follow
/// @author Zeropoint Labs
interface IBridgeValidator {
    //////////////////////////////////////////////////////////////
    //                           STRUCTS                        //
    //////////////////////////////////////////////////////////////

    struct ValidateTxDataArgs {
        bytes txData;
        uint64 srcChainId;
        uint64 dstChainId;
        uint64 liqDstChainId;
        bool deposit;
        address superform;
        address receiverAddress;
        address liqDataToken;
        address liqDataInterimToken;
    }

    //////////////////////////////////////////////////////////////
    //              EXTERNAL VIEW FUNCTIONS                     //
    //////////////////////////////////////////////////////////////

    /// @dev validates the receiver of the liquidity request
    /// @param txData_ is the txData of the cross chain deposit
    /// @param receiver_ is the address of the receiver to validate
    /// @return valid_ if the address is valid
    function validateReceiver(bytes calldata txData_, address receiver_) external view returns (bool valid_);

    /// @dev validates the txData of a cross chain deposit
    /// @param args_ the txData arguments to validate in txData
    /// @return hasDstSwap if the txData contains a destination swap
    function validateTxData(ValidateTxDataArgs calldata args_) external view returns (bool hasDstSwap);

    /// @dev decodes the txData and returns the amount of input token on source
    /// @param txData_ is the txData of the cross chain deposit
    /// @param genericSwapDisallowed_ true if generic swaps are disallowed
    /// @return amount_ the amount expected
    function decodeAmountIn(
        bytes calldata txData_,
        bool genericSwapDisallowed_
    )
        external
        view
        returns (uint256 amount_);

    /// @dev decodes neccesary information for processing swaps on the destination chain
    /// @param txData_ is the txData to be decoded
    /// @return token_ is the address of the token
    /// @return amount_ the amount expected
    function decodeDstSwap(bytes calldata txData_) external pure returns (address token_, uint256 amount_);

    /// @dev decodes the final output token address (for only direct chain actions!)
    /// @param txData_ is the txData to be decoded
    /// @return token_ the address of the token
    function decodeSwapOutputToken(bytes calldata txData_) external pure returns (address token_);
}

// File: src/libraries/Error.sol

pragma solidity ^0.8.23;

library Error {
    //////////////////////////////////////////////////////////////
    //                  CONFIGURATION ERRORS                    //
    //////////////////////////////////////////////////////////////
    ///@notice errors thrown in protocol setup

    /// @dev thrown if chain id exceeds max(uint64)
    error BLOCK_CHAIN_ID_OUT_OF_BOUNDS();

    /// @dev thrown if not possible to revoke a role in broadcasting
    error CANNOT_REVOKE_NON_BROADCASTABLE_ROLES();

    /// @dev thrown if not possible to revoke last admin
    error CANNOT_REVOKE_LAST_ADMIN();

    /// @dev thrown if trying to set again pseudo immutables in super registry
    error DISABLED();

    /// @dev thrown if rescue delay is not yet set for a chain
    error DELAY_NOT_SET();

    /// @dev thrown if get native token price estimate in paymentHelper is 0
    error INVALID_NATIVE_TOKEN_PRICE();

    /// @dev thrown if wormhole refund chain id is not set
    error REFUND_CHAIN_ID_NOT_SET();

    /// @dev thrown if wormhole relayer is not set
    error RELAYER_NOT_SET();

    /// @dev thrown if a role to be revoked is not assigned
    error ROLE_NOT_ASSIGNED();

    //////////////////////////////////////////////////////////////
    //                  AUTHORIZATION ERRORS                    //
    //////////////////////////////////////////////////////////////
    ///@notice errors thrown if functions cannot be called

    /// COMMON AUTHORIZATION ERRORS
    /// ---------------------------------------------------------

    /// @dev thrown if caller is not address(this), internal call
    error INVALID_INTERNAL_CALL();

    /// @dev thrown if msg.sender is not a valid amb implementation
    error NOT_AMB_IMPLEMENTATION();

    /// @dev thrown if msg.sender is not an allowed broadcaster
    error NOT_ALLOWED_BROADCASTER();

    /// @dev thrown if msg.sender is not broadcast amb implementation
    error NOT_BROADCAST_AMB_IMPLEMENTATION();

    /// @dev thrown if msg.sender is not broadcast state registry
    error NOT_BROADCAST_REGISTRY();

    /// @dev thrown if msg.sender is not core state registry
    error NOT_CORE_STATE_REGISTRY();

    /// @dev thrown if msg.sender is not emergency admin
    error NOT_EMERGENCY_ADMIN();

    /// @dev thrown if msg.sender is not emergency queue
    error NOT_EMERGENCY_QUEUE();

    /// @dev thrown if msg.sender is not minter
    error NOT_MINTER();

    /// @dev thrown if msg.sender is not minter state registry
    error NOT_MINTER_STATE_REGISTRY_ROLE();

    /// @dev thrown if msg.sender is not paymaster
    error NOT_PAYMASTER();

    /// @dev thrown if msg.sender is not payment admin
    error NOT_PAYMENT_ADMIN();

    /// @dev thrown if msg.sender is not protocol admin
    error NOT_PROTOCOL_ADMIN();

    /// @dev thrown if msg.sender is not state registry
    error NOT_STATE_REGISTRY();

    /// @dev thrown if msg.sender is not super registry
    error NOT_SUPER_REGISTRY();

    /// @dev thrown if msg.sender is not superform router
    error NOT_SUPERFORM_ROUTER();

    /// @dev thrown if msg.sender is not a superform
    error NOT_SUPERFORM();

    /// @dev thrown if msg.sender is not superform factory
    error NOT_SUPERFORM_FACTORY();

    /// @dev thrown if msg.sender is not timelock form
    error NOT_TIMELOCK_SUPERFORM();

    /// @dev thrown if msg.sender is not timelock state registry
    error NOT_TIMELOCK_STATE_REGISTRY();

    /// @dev thrown if msg.sender is not user or disputer
    error NOT_VALID_DISPUTER();

    /// @dev thrown if the msg.sender is not privileged caller
    error NOT_PRIVILEGED_CALLER(bytes32 role);

    /// STATE REGISTRY AUTHORIZATION ERRORS
    /// ---------------------------------------------------------

    /// @dev layerzero adapter specific error, thrown if caller not layerzero endpoint
    error CALLER_NOT_ENDPOINT();

    /// @dev hyperlane adapter specific error, thrown if caller not hyperlane mailbox
    error CALLER_NOT_MAILBOX();

    /// @dev wormhole relayer specific error, thrown if caller not wormhole relayer
    error CALLER_NOT_RELAYER();

    /// @dev thrown if src chain sender is not valid
    error INVALID_SRC_SENDER();

    //////////////////////////////////////////////////////////////
    //                  INPUT VALIDATION ERRORS                 //
    //////////////////////////////////////////////////////////////
    ///@notice errors thrown if input variables are not valid

    /// COMMON INPUT VALIDATION ERRORS
    /// ---------------------------------------------------------

    /// @dev thrown if there is an array length mismatch
    error ARRAY_LENGTH_MISMATCH();

    /// @dev thrown if payload id does not exist
    error INVALID_PAYLOAD_ID();

    /// @dev error thrown when msg value should be zero in certain payable functions
    error MSG_VALUE_NOT_ZERO();

    /// @dev thrown if amb ids length is 0
    error ZERO_AMB_ID_LENGTH();

    /// @dev thrown if address input is address 0
    error ZERO_ADDRESS();

    /// @dev thrown if amount input is 0
    error ZERO_AMOUNT();

    /// @dev thrown if final token is address 0
    error ZERO_FINAL_TOKEN();

    /// @dev thrown if value input is 0
    error ZERO_INPUT_VALUE();

    /// SUPERFORM ROUTER INPUT VALIDATION ERRORS
    /// ---------------------------------------------------------

    /// @dev thrown if the vaults data is invalid
    error INVALID_SUPERFORMS_DATA();

    /// @dev thrown if receiver address is not set
    error RECEIVER_ADDRESS_NOT_SET();

    /// SUPERFORM FACTORY INPUT VALIDATION ERRORS
    /// ---------------------------------------------------------

    /// @dev thrown if a form is not ERC165 compatible
    error ERC165_UNSUPPORTED();

    /// @dev thrown if a form is not form interface compatible
    error FORM_INTERFACE_UNSUPPORTED();

    /// @dev error thrown if form implementation address already exists
    error FORM_IMPLEMENTATION_ALREADY_EXISTS();

    /// @dev error thrown if form implementation id already exists
    error FORM_IMPLEMENTATION_ID_ALREADY_EXISTS();

    /// @dev thrown if a form does not exist
    error FORM_DOES_NOT_EXIST();

    /// @dev thrown if form id is larger than max uint16
    error INVALID_FORM_ID();

    /// @dev thrown if superform not on factory
    error SUPERFORM_ID_NONEXISTENT();

    /// @dev thrown if same vault and form implementation is used to create new superform
    error VAULT_FORM_IMPLEMENTATION_COMBINATION_EXISTS();

    /// FORM INPUT VALIDATION ERRORS
    /// ---------------------------------------------------------

    /// @dev thrown if in case of no txData, if liqData.token != vault.asset()
    /// in case of txData, if token output of swap != vault.asset()
    error DIFFERENT_TOKENS();

    /// @dev thrown if the amount in direct withdraw is not correct
    error DIRECT_WITHDRAW_INVALID_LIQ_REQUEST();

    /// @dev thrown if the amount in xchain withdraw is not correct
    error XCHAIN_WITHDRAW_INVALID_LIQ_REQUEST();

    /// LIQUIDITY BRIDGE INPUT VALIDATION ERRORS
    /// ---------------------------------------------------------

    /// @dev thrown if route id is blacklisted in socket
    error BLACKLISTED_ROUTE_ID();

    /// @dev thrown if route id is not blacklisted in socket
    error NOT_BLACKLISTED_ROUTE_ID();

    /// @dev error thrown when txData selector of lifi bridge is a blacklisted selector
    error BLACKLISTED_SELECTOR();

    /// @dev error thrown when txData selector of lifi bridge is not a blacklisted selector
    error NOT_BLACKLISTED_SELECTOR();

    /// @dev thrown if a certain action of the user is not allowed given the txData provided
    error INVALID_ACTION();

    /// @dev thrown if in deposits, the liqDstChainId doesn't match the stateReq dstChainId
    error INVALID_DEPOSIT_LIQ_DST_CHAIN_ID();

    /// @dev thrown if index is invalid
    error INVALID_INDEX();

    /// @dev thrown if the chain id in the txdata is invalid
    error INVALID_TXDATA_CHAIN_ID();

    /// @dev thrown if the validation of bridge txData fails due to a destination call present
    error INVALID_TXDATA_NO_DESTINATIONCALL_ALLOWED();

    /// @dev thrown if the validation of bridge txData fails due to wrong receiver
    error INVALID_TXDATA_RECEIVER();

    /// @dev thrown if the validation of bridge txData fails due to wrong token
    error INVALID_TXDATA_TOKEN();

    /// @dev thrown if txData is not present (in case of xChain actions)
    error NO_TXDATA_PRESENT();

    /// STATE REGISTRY INPUT VALIDATION ERRORS
    /// ---------------------------------------------------------

    /// @dev thrown if payload is being updated with final amounts length different than amounts length
    error DIFFERENT_PAYLOAD_UPDATE_AMOUNTS_LENGTH();

    /// @dev thrown if payload is being updated with tx data length different than liq data length
    error DIFFERENT_PAYLOAD_UPDATE_TX_DATA_LENGTH();

    /// @dev thrown if keeper update final token is different than the vault underlying
    error INVALID_UPDATE_FINAL_TOKEN();

    /// @dev thrown if broadcast finality for wormhole is invalid
    error INVALID_BROADCAST_FINALITY();

    /// @dev thrown if amb id is not valid leading to an address 0 of the implementation
    error INVALID_BRIDGE_ID();

    /// @dev thrown if chain id involved in xchain message is invalid
    error INVALID_CHAIN_ID();

    /// @dev thrown if payload update amount isn't equal to dst swapper amount
    error INVALID_DST_SWAP_AMOUNT();

    /// @dev thrown if message amb and proof amb are the same
    error INVALID_PROOF_BRIDGE_ID();

    /// @dev thrown if order of proof AMBs is incorrect, either duplicated or not incrementing
    error INVALID_PROOF_BRIDGE_IDS();

    /// @dev thrown if rescue data lengths are invalid
    error INVALID_RESCUE_DATA();

    /// @dev thrown if delay is invalid
    error INVALID_TIMELOCK_DELAY();

    /// @dev thrown if amounts being sent in update payload mean a negative slippage
    error NEGATIVE_SLIPPAGE();

    /// @dev thrown if slippage is outside of bounds
    error SLIPPAGE_OUT_OF_BOUNDS();

    /// SUPERPOSITION INPUT VALIDATION ERRORS
    /// ---------------------------------------------------------

    /// @dev thrown if src senders mismatch in state sync
    error SRC_SENDER_MISMATCH();

    /// @dev thrown if src tx types mismatch in state sync
    error SRC_TX_TYPE_MISMATCH();

    //////////////////////////////////////////////////////////////
    //                  EXECUTION ERRORS                        //
    //////////////////////////////////////////////////////////////
    ///@notice errors thrown due to function execution logic

    /// COMMON EXECUTION ERRORS
    /// ---------------------------------------------------------

    /// @dev thrown if the swap in a direct deposit resulted in insufficient tokens
    error DIRECT_DEPOSIT_SWAP_FAILED();

    /// @dev thrown if payload is not unique
    error DUPLICATE_PAYLOAD();

    /// @dev thrown if native tokens fail to be sent to superform contracts
    error FAILED_TO_SEND_NATIVE();

    /// @dev thrown if allowance is not correct to deposit
    error INSUFFICIENT_ALLOWANCE_FOR_DEPOSIT();

    /// @dev thrown if contract has insufficient balance for operations
    error INSUFFICIENT_BALANCE();

    /// @dev thrown if native amount is not at least equal to the amount in the request
    error INSUFFICIENT_NATIVE_AMOUNT();

    /// @dev thrown if payload cannot be decoded
    error INVALID_PAYLOAD();

    /// @dev thrown if payload status is invalid
    error INVALID_PAYLOAD_STATUS();

    /// @dev thrown if payload type is invalid
    error INVALID_PAYLOAD_TYPE();

    /// LIQUIDITY BRIDGE EXECUTION ERRORS
    /// ---------------------------------------------------------

    /// @dev thrown if we try to decode the final swap output token in a xChain liquidity bridging action
    error CANNOT_DECODE_FINAL_SWAP_OUTPUT_TOKEN();

    /// @dev thrown if liquidity bridge fails for erc20 or native tokens
    error FAILED_TO_EXECUTE_TXDATA(address token);

    /// @dev thrown if asset being used for deposit mismatches in multivault deposits
    error INVALID_DEPOSIT_TOKEN();

    /// STATE REGISTRY EXECUTION ERRORS
    /// ---------------------------------------------------------

    /// @dev thrown if bridge tokens haven't arrived to destination
    error BRIDGE_TOKENS_PENDING();

    /// @dev thrown if withdrawal tx data cannot be updated
    error CANNOT_UPDATE_WITHDRAW_TX_DATA();

    /// @dev thrown if rescue passed dispute deadline
    error DISPUTE_TIME_ELAPSED();

    /// @dev thrown if message failed to reach the specified level of quorum needed
    error INSUFFICIENT_QUORUM();

    /// @dev thrown if broadcast payload is invalid
    error INVALID_BROADCAST_PAYLOAD();

    /// @dev thrown if broadcast fee is invalid
    error INVALID_BROADCAST_FEE();

    /// @dev thrown if retry fees is less than required
    error INVALID_RETRY_FEE();

    /// @dev thrown if broadcast message type is wrong
    error INVALID_MESSAGE_TYPE();

    /// @dev thrown if payload hash is invalid during `retryMessage` on Layezero implementation
    error INVALID_PAYLOAD_HASH();

    /// @dev thrown if update payload function was called on a wrong payload
    error INVALID_PAYLOAD_UPDATE_REQUEST();

    /// @dev thrown if a state registry id is 0
    error INVALID_REGISTRY_ID();

    /// @dev thrown if a form state registry id is 0
    error INVALID_FORM_REGISTRY_ID();

    /// @dev thrown if trying to finalize the payload but the withdraw is still locked
    error LOCKED();

    /// @dev thrown if payload is already updated (during xChain deposits)
    error PAYLOAD_ALREADY_UPDATED();

    /// @dev thrown if payload is already processed
    error PAYLOAD_ALREADY_PROCESSED();

    /// @dev thrown if payload is not in UPDATED state
    error PAYLOAD_NOT_UPDATED();

    /// @dev thrown if rescue is still in timelocked state
    error RESCUE_LOCKED();

    /// @dev thrown if rescue is already proposed
    error RESCUE_ALREADY_PROPOSED();

    /// @dev thrown if payload hash is zero during `retryMessage` on Layezero implementation
    error ZERO_PAYLOAD_HASH();

    /// DST SWAPPER EXECUTION ERRORS
    /// ---------------------------------------------------------

    /// @dev thrown if process dst swap is tried for processed payload id
    error DST_SWAP_ALREADY_PROCESSED();

    /// @dev thrown if indices have duplicates
    error DUPLICATE_INDEX();

    /// @dev thrown if failed dst swap is already updated
    error FAILED_DST_SWAP_ALREADY_UPDATED();

    /// @dev thrown if indices are out of bounds
    error INDEX_OUT_OF_BOUNDS();

    /// @dev thrown if failed swap token amount is 0
    error INVALID_DST_SWAPPER_FAILED_SWAP();

    /// @dev thrown if failed swap token amount is not 0 and if token balance is less than amount (non zero)
    error INVALID_DST_SWAPPER_FAILED_SWAP_NO_TOKEN_BALANCE();

    /// @dev thrown if failed swap token amount is not 0 and if native amount is less than amount (non zero)
    error INVALID_DST_SWAPPER_FAILED_SWAP_NO_NATIVE_BALANCE();

    /// @dev forbid xChain deposits with destination swaps without interim token set (for user protection)
    error INVALID_INTERIM_TOKEN();

    /// @dev thrown if dst swap output is less than minimum expected
    error INVALID_SWAP_OUTPUT();

    /// FORM EXECUTION ERRORS
    /// ---------------------------------------------------------

    /// @dev thrown if try to forward 4626 share from the superform
    error CANNOT_FORWARD_4646_TOKEN();

    /// @dev thrown in KYCDAO form if no KYC token is present
    error NO_VALID_KYC_TOKEN();

    /// @dev thrown in forms where a certain functionality is not allowed or implemented
    error NOT_IMPLEMENTED();

    /// @dev thrown if form implementation is PAUSED, users cannot perform any action
    error PAUSED();

    /// @dev thrown if shares != deposit output or assets != redeem output when minting SuperPositions
    error VAULT_IMPLEMENTATION_FAILED();

    /// @dev thrown if withdrawal tx data is not updated
    error WITHDRAW_TOKEN_NOT_UPDATED();

    /// @dev thrown if withdrawal tx data is not updated
    error WITHDRAW_TX_DATA_NOT_UPDATED();

    /// @dev thrown when redeeming from vault yields zero collateral
    error WITHDRAW_ZERO_COLLATERAL();

    /// PAYMENT HELPER EXECUTION ERRORS
    /// ---------------------------------------------------------

    /// @dev thrown if chainlink is reporting an improper price
    error CHAINLINK_MALFUNCTION();

    /// @dev thrown if chainlink is reporting an incomplete round
    error CHAINLINK_INCOMPLETE_ROUND();

    /// @dev thrown if feed decimals is not 8
    error CHAINLINK_UNSUPPORTED_DECIMAL();

    /// EMERGENCY QUEUE EXECUTION ERRORS
    /// ---------------------------------------------------------

    /// @dev thrown if emergency withdraw is not queued
    error EMERGENCY_WITHDRAW_NOT_QUEUED();

    /// @dev thrown if emergency withdraw is already processed
    error EMERGENCY_WITHDRAW_PROCESSED_ALREADY();

    /// SUPERPOSITION EXECUTION ERRORS
    /// ---------------------------------------------------------

    /// @dev thrown if uri cannot be updated
    error DYNAMIC_URI_FROZEN();

    /// @dev thrown if tx history is not found while state sync
    error TX_HISTORY_NOT_FOUND();
}

// File: src/crosschain-liquidity/BridgeValidator.sol

pragma solidity ^0.8.23;





/// @title BridgeValidator
/// @dev Inherited by specific bridge handlers to verify the calldata being sent
/// @author Zeropoint Labs
abstract contract BridgeValidator is IBridgeValidator {
    //////////////////////////////////////////////////////////////
    //                         CONSTANTS                        //
    //////////////////////////////////////////////////////////////

    ISuperRegistry public immutable superRegistry;
    address constant NATIVE = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    //////////////////////////////////////////////////////////////
    //                      CONSTRUCTOR                         //
    //////////////////////////////////////////////////////////////

    constructor(address superRegistry_) {
        if (superRegistry_ == address(0)) {
            revert Error.ZERO_ADDRESS();
        }
        superRegistry = ISuperRegistry(superRegistry_);
    }

    //////////////////////////////////////////////////////////////
    //              EXTERNAL VIEW FUNCTIONS                     //
    //////////////////////////////////////////////////////////////

    /// @inheritdoc IBridgeValidator
    function validateReceiver(
        bytes calldata txData_,
        address receiver_
    )
        external
        view
        virtual
        override
        returns (bool valid_);

    /// @inheritdoc IBridgeValidator
    function validateTxData(ValidateTxDataArgs calldata args_)
        external
        view
        virtual
        override
        returns (bool hasDstSwap);

    /// @inheritdoc IBridgeValidator
    function decodeAmountIn(
        bytes calldata txData_,
        bool genericSwapDisallowed_
    )
        external
        view
        virtual
        override
        returns (uint256 amount_);

    /// @inheritdoc IBridgeValidator
    function decodeDstSwap(bytes calldata txData_)
        external
        pure
        virtual
        override
        returns (address token_, uint256 amount_);

    /// @inheritdoc IBridgeValidator
    function decodeSwapOutputToken(bytes calldata txData_)
        external
        pure
        virtual
        override
        returns (address outputToken_);
}

// File: src/vendor/lifi/ILiFi.sol

pragma solidity ^0.8.23;

/// @title ILiFi
/// @notice Interface containing useful structs when using LiFi as a bridge
/// @notice taken from LiFi contracts https://github.com/lifinance/contracts
interface ILiFi {
    struct BridgeData {
        bytes32 transactionId;
        string bridge;
        string integrator;
        address referrer;
        address sendingAssetId;
        address receiver;
        uint256 minAmount;
        uint256 destinationChainId;
        bool hasSourceSwaps;
        bool hasDestinationCall; // is there a destination call? we should disable this
    }
}

// File: src/vendor/lifi/LibSwap.sol

pragma solidity ^0.8.23;

library LibSwap {
    struct SwapData {
        address callTo;
        address approveTo;
        address sendingAssetId;
        address receivingAssetId;
        uint256 fromAmount;
        bytes callData;
        bool requiresDeposit;
    }
}

// File: src/vendor/lifi/StandardizedCallFacet.sol

pragma solidity ^0.8.23;

/// @title StandardizedCallFacet
/// @author LI.FI (https://li.fi)
/// @notice taken from LiFi contracts https://github.com/lifinance/contracts
/// @custom:version 2.2.0
contract StandardizedCallFacet {
    /// External Methods ///

    /// @notice Make a standardized call to a facet
    /// @param callData The calldata to forward to the facet
    function standardizedCall(bytes memory callData) external payable { }
}

// File: src/vendor/lifi/AmarokFacet.sol

pragma solidity ^0.8.23;




/// @title Amarok Facet
/// @author LI.FI (https://li.fi)
/// @notice Provides functionality for bridging through Connext Amarok
/// @notice taken from LiFi contracts https://github.com/lifinance/contracts and stripped down to needs
/// @custom:version 2.0.0
contract AmarokFacet {
    /// @param callData The data to execute on the receiving chain. If no crosschain call is needed, then leave empty.
    /// @param callTo The address of the contract on dest chain that will receive bridged funds and execute data
    /// @param relayerFee The amount of relayer fee the tx called xcall with
    /// @param slippageTol Max bps of original due to slippage (i.e. would be 9995 to tolerate .05% slippage)
    /// @param delegate Destination delegate address
    /// @param destChainDomainId The Amarok-specific domainId of the destination chain
    /// @param payFeeWithSendingAsset Whether to pay the relayer fee with the sending asset or not
    struct AmarokData {
        bytes callData;
        address callTo;
        uint256 relayerFee;
        uint256 slippageTol;
        address delegate;
        uint32 destChainDomainId;
        bool payFeeWithSendingAsset;
    }

    /// External Methods ///

    /// @notice Bridges tokens via Amarok
    /// @param _bridgeData Data containing core information for bridging
    /// @param _amarokData Data specific to bridge
    function startBridgeTokensViaAmarok(
        ILiFi.BridgeData calldata _bridgeData,
        AmarokData calldata _amarokData
    )
        external
        payable
    { }

    /// @notice Performs a swap before bridging via Amarok
    /// @param _bridgeData The core information needed for bridging
    /// @param _swapData An array of swap related data for performing swaps before bridging
    /// @param _amarokData Data specific to Amarok
    function swapAndStartBridgeTokensViaAmarok(
        ILiFi.BridgeData memory _bridgeData,
        LibSwap.SwapData[] calldata _swapData,
        AmarokData calldata _amarokData
    )
        external
        payable
    { }
}

// File: src/vendor/lifi/celer-network/MsgDataTypes.sol

pragma solidity >=0.8.0;

/// @notice taken from https://github.com/celer-network/sgn-v2-contracts on 19/12/2023
library MsgDataTypes {
    string constant ABORT_PREFIX = "MSG::ABORT:";

    // bridge operation type at the sender side (src chain)
    enum BridgeSendType {
        Null,
        Liquidity,
        PegDeposit,
        PegBurn,
        PegV2Deposit,
        PegV2Burn,
        PegV2BurnFrom
    }

    // bridge operation type at the receiver side (dst chain)
    enum TransferType {
        Null,
        LqRelay, // relay through liquidity bridge
        LqWithdraw, // withdraw from liquidity bridge
        PegMint, // mint through pegged token bridge
        PegWithdraw, // withdraw from original token vault
        PegV2Mint, // mint through pegged token bridge v2
        PegV2Withdraw // withdraw from original token vault v2
    }

    enum MsgType {
        MessageWithTransfer,
        MessageOnly
    }

    enum TxStatus {
        Null,
        Success,
        Fail,
        Fallback,
        Pending // transient state within a transaction
    }

    struct TransferInfo {
        TransferType t;
        address sender;
        address receiver;
        address token;
        uint256 amount;
        uint64 wdseq; // only needed for LqWithdraw (refund)
        uint64 srcChainId;
        bytes32 refId;
        bytes32 srcTxHash; // src chain msg tx hash
    }

    struct RouteInfo {
        address sender;
        address receiver;
        uint64 srcChainId;
        bytes32 srcTxHash; // src chain msg tx hash
    }

    // used for msg from non-evm chains with longer-bytes address
    struct RouteInfo2 {
        bytes sender;
        address receiver;
        uint64 srcChainId;
        bytes32 srcTxHash;
    }

    // combination of RouteInfo and RouteInfo2 for easier processing
    struct Route {
        address sender; // from RouteInfo
        bytes senderBytes; // from RouteInfo2
        address receiver;
        uint64 srcChainId;
        bytes32 srcTxHash;
    }

    struct MsgWithTransferExecutionParams {
        bytes message;
        TransferInfo transfer;
        bytes[] sigs;
        address[] signers;
        uint256[] powers;
    }

    struct BridgeTransferParams {
        bytes request;
        bytes[] sigs;
        address[] signers;
        uint256[] powers;
    }
}

// File: src/vendor/lifi/CelerIMFacetBase.sol

pragma solidity ^0.8.23;





interface CelerIM {
    /// @param maxSlippage The max slippage accepted, given as percentage in point (pip).
    /// @param nonce A number input to guarantee uniqueness of transferId. Can be timestamp in practice.
    /// @param callTo The address of the contract to be called at destination.
    /// @param callData The encoded calldata with below data
    ///                 bytes32 transactionId,
    ///                 LibSwap.SwapData[] memory swapData,
    ///                 address receiver,
    ///                 address refundAddress
    /// @param messageBusFee The fee to be paid to CBridge message bus for relaying the message
    /// @param bridgeType Defines the bridge operation type (must be one of the values of CBridge library
    /// MsgDataTypes.BridgeSendType)
    struct CelerIMData {
        uint32 maxSlippage;
        uint64 nonce;
        bytes callTo;
        bytes callData;
        uint256 messageBusFee;
        MsgDataTypes.BridgeSendType bridgeType;
    }
}

/// @title CelerIM Facet Base
/// @author LI.FI (https://li.fi)
/// @notice Provides functionality for bridging tokens and data through CBridge
/// @notice Used to differentiate between contract instances for mutable and immutable diamond as these cannot be shared
/// @notice taken from LiFi contracts https://github.com/lifinance/contracts and stripped down to needs
/// @custom:version 2.0.0
abstract contract CelerIMFacetBase {
    /// External Methods ///

    /// @notice Bridges tokens via CBridge
    /// @param _bridgeData The core information needed for bridging
    /// @param _celerIMData Data specific to CelerIM
    function startBridgeTokensViaCelerIM(
        ILiFi.BridgeData memory _bridgeData,
        CelerIM.CelerIMData calldata _celerIMData
    )
        external
        payable
    { }

    /// @notice Performs a swap before bridging via CBridge
    /// @param _bridgeData The core information needed for bridging
    /// @param _swapData An array of swap related data for performing swaps before bridging
    /// @param _celerIMData Data specific to CelerIM
    function swapAndStartBridgeTokensViaCelerIM(
        ILiFi.BridgeData memory _bridgeData,
        LibSwap.SwapData[] calldata _swapData,
        CelerIM.CelerIMData calldata _celerIMData
    )
        external
        payable
    { }
}

// File: src/vendor/lifi/StargateFacet.sol

pragma solidity ^0.8.23;




/// @title Stargate Facet
/// @author Li.Finance (https://li.finance)
/// @notice Provides functionality for bridging through Stargate
/// @notice taken from LiFi contracts https://github.com/lifinance/contracts and stripped down to needs
/// @custom:version 2.2.0
contract StargateFacet {
    /// @param srcPoolId Source pool id.
    /// @param dstPoolId Dest pool id.
    /// @param minAmountLD The min qty you would accept on the destination.
    /// @param dstGasForCall Additional gas fee for extral call on the destination.
    /// @param lzFee Estimated message fee.
    /// @param refundAddress Refund adddress. Extra gas (if any) is returned to this address
    /// @param callTo The address to send the tokens to on the destination.
    /// @param callData Additional payload.
    struct StargateData {
        uint256 srcPoolId;
        uint256 dstPoolId;
        uint256 minAmountLD;
        uint256 dstGasForCall;
        uint256 lzFee;
        address payable refundAddress;
        bytes callTo;
        bytes callData;
    }

    /// External Methods ///

    /// @notice Bridges tokens via Stargate Bridge
    /// @param _bridgeData Data used purely for tracking and analytics
    /// @param _stargateData Data specific to Stargate Bridge
    function startBridgeTokensViaStargate(
        ILiFi.BridgeData calldata _bridgeData,
        StargateData calldata _stargateData
    )
        external
        payable
    { }

    /// @notice Performs a swap before bridging via Stargate Bridge
    /// @param _bridgeData Data used purely for tracking and analytics
    /// @param _swapData An array of swap related data for performing swaps before bridging
    /// @param _stargateData Data specific to Stargate Bridge
    function swapAndStartBridgeTokensViaStargate(
        ILiFi.BridgeData memory _bridgeData,
        LibSwap.SwapData[] calldata _swapData,
        StargateData calldata _stargateData
    )
        external
        payable
    { }
}

// File: src/vendor/lifi/LiFiTxDataExtractor.sol

pragma solidity ^0.8.23;








/// @title LiFiTxDataExtractor
/// @author LI.FI (https://li.fi)
/// @notice Provides functionality for extracting calldata
/// @notice upgraded to solidity 0.8.23 and adapted from CalldataVerificationFacet and LibBytes without any changes to
/// used functions (just stripped down functionality and renamed contract name)
/// @notice taken from LiFi contracts https://github.com/lifinance/contracts
/// @custom:version 2.2.0
contract LiFiTxDataExtractor {
    error SliceOverflow();
    error SliceOutOfBounds();

    function _extractSelector(bytes calldata data) internal pure returns (bytes4 selector) {
        selector = bytes4(data[:4]);
        if (selector == StandardizedCallFacet.standardizedCall.selector) selector = bytes4(data[4:8]);
    }

    /// @notice Extracts the bridge data from the calldata. Extracts receiver correctly pending certain facet features
    /// @param data The calldata to extract the bridge data from
    /// @return bridgeData The bridge data extracted from the calldata
    function _extractBridgeData(bytes calldata data)
        internal
        pure
        returns (ILiFi.BridgeData memory bridgeData, address receiver)
    {
        bytes memory callData = data;

        if (bytes4(data[:4]) == StandardizedCallFacet.standardizedCall.selector) {
            // StandardizedCall
            callData = abi.decode(data[4:], (bytes));
        }

        bytes4 selector = abi.decode(callData, (bytes4));

        // Case: Amarok
        if (selector == AmarokFacet.startBridgeTokensViaAmarok.selector) {
            AmarokFacet.AmarokData memory amarokData;
            (bridgeData, amarokData) =
                abi.decode(_slice(callData, 4, callData.length - 4), (ILiFi.BridgeData, AmarokFacet.AmarokData));
            receiver = amarokData.callTo;

            return (bridgeData, receiver);
        }
        if (selector == AmarokFacet.swapAndStartBridgeTokensViaAmarok.selector) {
            AmarokFacet.AmarokData memory amarokData;

            (bridgeData,, amarokData) = abi.decode(
                _slice(callData, 4, callData.length - 4), (ILiFi.BridgeData, LibSwap.SwapData[], AmarokFacet.AmarokData)
            );
            receiver = amarokData.callTo;

            return (bridgeData, receiver);
        }

        // Case: Stargate
        if (selector == StargateFacet.startBridgeTokensViaStargate.selector) {
            StargateFacet.StargateData memory stargateData;
            (bridgeData, stargateData) =
                abi.decode(_slice(callData, 4, callData.length - 4), (ILiFi.BridgeData, StargateFacet.StargateData));

            bytes memory to = stargateData.callTo;
            assembly {
                receiver := mload(add(to, 20))
            }

            return (bridgeData, receiver);
        }
        if (selector == StargateFacet.swapAndStartBridgeTokensViaStargate.selector) {
            StargateFacet.StargateData memory stargateData;
            (bridgeData,, stargateData) = abi.decode(
                _slice(callData, 4, callData.length - 4),
                (ILiFi.BridgeData, LibSwap.SwapData[], StargateFacet.StargateData)
            );
            bytes memory to = stargateData.callTo;
            assembly {
                receiver := mload(add(to, 20))
            }
            return (bridgeData, receiver);
        }

        // Case: Celer
        if (selector == CelerIMFacetBase.startBridgeTokensViaCelerIM.selector) {
            CelerIM.CelerIMData memory celerIMData;
            (bridgeData, celerIMData) =
                abi.decode(_slice(callData, 4, callData.length - 4), (ILiFi.BridgeData, CelerIM.CelerIMData));

            receiver = bridgeData.receiver;

            return (bridgeData, receiver);
        }
        if (selector == CelerIMFacetBase.swapAndStartBridgeTokensViaCelerIM.selector) {
            CelerIM.CelerIMData memory celerIMData;

            (bridgeData,, celerIMData) = abi.decode(
                _slice(callData, 4, callData.length - 4), (ILiFi.BridgeData, LibSwap.SwapData[], CelerIM.CelerIMData)
            );
            receiver = bridgeData.receiver;

            return (bridgeData, receiver);
        }

        // normal call
        bridgeData = abi.decode(data[4:], (ILiFi.BridgeData));
        receiver = bridgeData.receiver;
    }

    /// @notice Extracts the swap data from the calldata
    /// @param data The calldata to extract the swap data from
    /// @return swapData The swap data extracted from the calldata
    function _extractSwapData(bytes calldata data) internal pure returns (LibSwap.SwapData[] memory swapData) {
        if (bytes4(data[:4]) == StandardizedCallFacet.standardizedCall.selector) {
            // standardizedCall
            bytes memory unwrappedData = abi.decode(data[4:], (bytes));
            (, swapData) =
                abi.decode(_slice(unwrappedData, 4, unwrappedData.length - 4), (ILiFi.BridgeData, LibSwap.SwapData[]));
            return swapData;
        }
        // normal call
        (, swapData) = abi.decode(data[4:], (ILiFi.BridgeData, LibSwap.SwapData[]));
    }

    function _slice(bytes memory _bytes, uint256 _start, uint256 _length) internal pure returns (bytes memory) {
        if (_length + 31 < _length) revert SliceOverflow();
        if (_bytes.length < _start + _length) revert SliceOutOfBounds();

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
                // Get a location of some free memory and store it in tempBytes as
                // Solidity does for memory variables.
                tempBytes := mload(0x40)

                // The first word of the slice result is potentially a partial
                // word read from the original array. To read it, we calculate
                // the length of that partial word and start copying that many
                // bytes into the array. The first word we copy will start with
                // data we don't care about, but the last `lengthmod` bytes will
                // land at the beginning of the contents of the new array. When
                // we're done copying, we overwrite the full first word with
                // the actual length of the slice.
                let lengthmod := and(_length, 31)

                // The multiplication in the next line is necessary
                // because when slicing multiples of 32 bytes (lengthmod == 0)
                // the following copy loop was copying the origin's length
                // and then ending prematurely not copying everything it should.
                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)

                for {
                    // The multiplication in the next line has the same exact purpose
                    // as the one above.
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } { mstore(mc, mload(cc)) }

                mstore(tempBytes, _length)

                //update free-memory pointer
                //allocating the array padded to 32 bytes like the compiler does now
                mstore(0x40, and(add(mc, 31), not(31)))
            }
            //if we want a zero-length slice let's just return a zero-length array
            default {
                tempBytes := mload(0x40)
                //zero out the 32 bytes slice we are about to return
                //we need to do it because Solidity does not garbage collect
                mstore(tempBytes, 0)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }
}

// File: src/vendor/lifi/GenericSwapFacet.sol

pragma solidity ^0.8.23;



/// @title Generic Swap Facet
/// @author LI.FI (https://li.fi)
/// @notice Provides functionality for swapping through ANY APPROVED DEX
/// @dev Uses calldata to execute APPROVED arbitrary methods on DEXs
/// @notice taken from LiFi contracts https://github.com/lifinance/contracts and stripped down to needs
/// @custom:version 1.0.0
contract GenericSwapFacet {
    /// External Methods ///

    /// @notice Performs multiple swaps in one transaction
    /// @param _transactionId the transaction id associated with the operation
    /// @param _integrator the name of the integrator
    /// @param _referrer the address of the referrer
    /// @param _receiver the address to receive the swapped tokens into (also excess tokens)
    /// @param _minAmount the minimum amount of the final asset to receive
    /// @param _swapData an object containing swap related data to perform swaps before bridging
    function swapTokensGeneric(
        bytes32 _transactionId,
        string calldata _integrator,
        string calldata _referrer,
        address payable _receiver,
        uint256 _minAmount,
        LibSwap.SwapData[] calldata _swapData
    )
        external
        payable
    { }
}

// File: lib/ERC1155A/lib/openzeppelin-contracts/contracts/access/IAccessControl.sol

// OpenZeppelin Contracts (last updated v5.0.0) (access/IAccessControl.sol)

pragma solidity ^0.8.20;

/**
 * @dev External interface of AccessControl declared to support ERC-165 detection.
 */
interface IAccessControl {
    /**
     * @dev The `account` is missing a role.
     */
    error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);

    /**
     * @dev The caller of a function is not the expected one.
     *
     * NOTE: Don't confuse with {AccessControlUnauthorizedAccount}.
     */
    error AccessControlBadConfirmation();

    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `callerConfirmation`.
     */
    function renounceRole(bytes32 role, address callerConfirmation) external;
}

// File: src/interfaces/ISuperRBAC.sol

pragma solidity ^0.8.23;



/// @title ISuperRBAC
/// @dev Interface for SuperRBAC
/// @author Zeropoint Labs
interface ISuperRBAC is IAccessControl {

    //////////////////////////////////////////////////////////////
    //                           STRUCTS                         //
    //////////////////////////////////////////////////////////////

    struct InitialRoleSetup {
        address admin;
        address emergencyAdmin;
        address paymentAdmin;
        address csrProcessor;
        address tlProcessor;
        address brProcessor;
        address csrUpdater;
        address srcVaaRelayer;
        address dstSwapper;
        address csrRescuer;
        address csrDisputer;
    }

    //////////////////////////////////////////////////////////////
    //                          EVENTS                          //
    //////////////////////////////////////////////////////////////

    /// @dev is emitted when superRegistry is set
    event SuperRegistrySet(address indexed superRegistry);

    /// @dev is emitted when an admin is set for a role
    event RoleAdminSet(bytes32 role, bytes32 adminRole);

    //////////////////////////////////////////////////////////////
    //              EXTERNAL VIEW FUNCTIONS                     //
    //////////////////////////////////////////////////////////////

    /// @dev returns the id of the protocol admin role
    function PROTOCOL_ADMIN_ROLE() external view returns (bytes32);

    /// @dev returns the id of the emergency admin role
    function EMERGENCY_ADMIN_ROLE() external view returns (bytes32);

    /// @dev returns the id of the payment admin role
    function PAYMENT_ADMIN_ROLE() external view returns (bytes32);

    /// @dev returns the id of the broadcaster role
    function BROADCASTER_ROLE() external view returns (bytes32);

    /// @dev returns the id of the core state registry processor role
    function CORE_STATE_REGISTRY_PROCESSOR_ROLE() external view returns (bytes32);

    /// @dev returns the id of the timelock state registry processor role
    function TIMELOCK_STATE_REGISTRY_PROCESSOR_ROLE() external view returns (bytes32);

    /// @dev returns the id of the broadcast state registry processor role
    function BROADCAST_STATE_REGISTRY_PROCESSOR_ROLE() external view returns (bytes32);

    /// @dev returns the id of the core state registry updater role
    function CORE_STATE_REGISTRY_UPDATER_ROLE() external view returns (bytes32);

    /// @dev returns the id of the dst swapper role
    function DST_SWAPPER_ROLE() external view returns (bytes32);

    /// @dev returns the id of the core state registry rescuer role
    function CORE_STATE_REGISTRY_RESCUER_ROLE() external view returns (bytes32);

    /// @dev returns the id of the core state registry rescue disputer role
    function CORE_STATE_REGISTRY_DISPUTER_ROLE() external view returns (bytes32);

    /// @dev returns the id of wormhole vaa relayer role
    function WORMHOLE_VAA_RELAYER_ROLE() external view returns (bytes32);

    /// @dev returns whether the given address has the protocol admin role
    /// @param admin_ the address to check
    function hasProtocolAdminRole(address admin_) external view returns (bool);

    /// @dev returns whether the given address has the emergency admin role
    /// @param admin_ the address to check
    function hasEmergencyAdminRole(address admin_) external view returns (bool);

    //////////////////////////////////////////////////////////////
    //              EXTERNAL WRITE FUNCTIONS                    //
    //////////////////////////////////////////////////////////////

    /// @dev updates the super registry address
    function setSuperRegistry(address superRegistry_) external;

    /// @dev configures a new role in superForm
    /// @param role_ the role to set
    /// @param adminRole_ the admin role to set as admin
    function setRoleAdmin(bytes32 role_, bytes32 adminRole_) external;

    /// @dev revokes the role_ from superRegistryAddressId_ on all chains
    /// @param role_ the role to revoke
    /// @param extraData_ amb config if broadcasting is required
    /// @param superRegistryAddressId_ the super registry address id
    function revokeRoleSuperBroadcast(
        bytes32 role_,
        bytes memory extraData_,
        bytes32 superRegistryAddressId_
    )
        external
        payable;

    /// @dev allows sync of global roles from different chains using broadcast registry
    /// @notice may not work for all roles
    function stateSyncBroadcast(bytes memory data_) external;
}

// File: src/interfaces/ILiFiValidator.sol

pragma solidity ^0.8.23;

/// @title LiFi Validator Interface
/// @author Zeropoint Labs
interface ILiFiValidator {
    //////////////////////////////////////////////////////////////
    //                      EVENTS                              //
    //////////////////////////////////////////////////////////////
    ///@dev emitted when a selector is added to the blacklist
    event AddedToBlacklist(bytes4 selector);

    ///@dev emitted when a selector is removed from the blacklist
    event RemovedFromBlacklist(bytes4 selector);

    //////////////////////////////////////////////////////////////
    //              EXTERNAL  FUNCTIONS                         //
    //////////////////////////////////////////////////////////////

    /// @dev Adds a selector to the blacklist
    /// @param selector_ the selector to add
    function addToBlacklist(bytes4 selector_) external;

    /// @dev Removes a selector from the blacklist
    /// @param selector_ the selector to remove
    function removeFromBlacklist(bytes4 selector_) external;
    //////////////////////////////////////////////////////////////
    //              EXTERNAL VIEW FUNCTIONS                     //
    //////////////////////////////////////////////////////////////

    /// @dev Checks if given selector is blacklisted
    /// @param selector_ the selector to check
    /// @return blacklisted if selector is blacklisted
    function isSelectorBlacklisted(bytes4 selector_) external view returns (bool blacklisted);
}

// File: src/vendor/lifi/CBridgeFacetPacked.sol

pragma solidity ^0.8.23;

/// @title CBridge Facet Packed
/// @author LI.FI (https://li.fi)
/// @notice Provides functionality for bridging through CBridge
/// @notice taken from LiFi contracts https://github.com/lifinance/contracts and stripped down to needs
/// @custom:version 1.0.3
contract CBridgeFacetPacked {
    /// @notice Bridges Native tokens via cBridge (packed)
    /// No params, all data will be extracted from manually encoded callData
    function startBridgeTokensViaCBridgeNativePacked() external payable { }

    /// @notice Bridges native tokens via cBridge
    /// @param transactionId Custom transaction ID for tracking
    /// @param receiver Receiving wallet address
    /// @param destinationChainId Receiving chain
    /// @param nonce A number input to guarantee uniqueness of transferId.
    /// @param maxSlippage Destination swap minimal accepted amount
    function startBridgeTokensViaCBridgeNativeMin(
        bytes32 transactionId,
        address receiver,
        uint64 destinationChainId,
        uint64 nonce,
        uint32 maxSlippage
    )
        external
        payable
    { }

    /// @notice Bridges ERC20 tokens via cBridge
    /// No params, all data will be extracted from manually encoded callData
    function startBridgeTokensViaCBridgeERC20Packed() external { }

    /// @notice Bridges ERC20 tokens via cBridge
    /// @param transactionId Custom transaction ID for tracking
    /// @param receiver Receiving wallet address
    /// @param destinationChainId Receiving chain
    /// @param sendingAssetId Address of the source asset to bridge
    /// @param amount Amount of the source asset to bridge
    /// @param nonce A number input to guarantee uniqueness of transferId
    /// @param maxSlippage Destination swap minimal accepted amount
    function startBridgeTokensViaCBridgeERC20Min(
        bytes32 transactionId,
        address receiver,
        uint64 destinationChainId,
        address sendingAssetId,
        uint256 amount,
        uint64 nonce,
        uint32 maxSlippage
    )
        external
    { }
}

// File: src/vendor/lifi/HopFacet.sol

pragma solidity ^0.8.23;




/// @title Hop Facet
/// @author LI.FI (https://li.fi)
/// @notice Provides functionality for bridging through Hop
/// @notice taken from LiFi contracts https://github.com/lifinance/contracts and stripped down to needs
/// @custom:version 2.0.0
contract HopFacet {
    struct HopData {
        uint256 bonderFee;
        uint256 amountOutMin;
        uint256 deadline;
        uint256 destinationAmountOutMin;
        uint256 destinationDeadline;
        address relayer;
        uint256 relayerFee;
        uint256 nativeFee;
    }

    /// @notice Bridges tokens via Hop Protocol
    /// @param _bridgeData the core information needed for bridging
    /// @param _hopData data specific to Hop Protocol
    function startBridgeTokensViaHop(ILiFi.BridgeData memory _bridgeData, HopData calldata _hopData) external payable { }

    /// @notice Performs a swap before bridging via Hop Protocol
    /// @param _bridgeData the core information needed for bridging
    /// @param _swapData an array of swap related data for performing swaps before bridging
    /// @param _hopData data specific to Hop Protocol
    function swapAndStartBridgeTokensViaHop(
        ILiFi.BridgeData memory _bridgeData,
        LibSwap.SwapData[] calldata _swapData,
        HopData calldata _hopData
    )
        external
        payable
    { }
}

// File: src/vendor/lifi/IHopBridge.sol

pragma solidity ^0.8.23;

/// @notice taken from LiFi contracts https://github.com/lifinance/contracts and stripped down to needs

interface IHopBridge {
    function sendToL2(
        uint256 chainId,
        address recipient,
        uint256 amount,
        uint256 amountOutMin,
        uint256 deadline,
        address relayer,
        uint256 relayerFee
    )
        external
        payable;

    function swapAndSend(
        uint256 chainId,
        address recipient,
        uint256 amount,
        uint256 bonderFee,
        uint256 amountOutMin,
        uint256 deadline,
        uint256 destinationAmountOutMin,
        uint256 destinationDeadline
    )
        external
        payable;

    function send(
        uint256 chainId,
        address recipient,
        uint256 amount,
        uint256 bonderFee,
        uint256 amountOutMin,
        uint256 deadline
    )
        external;
}

// File: src/vendor/lifi/HopFacetOptimized.sol

pragma solidity ^0.8.23;





/// @title Hop Facet (Optimized)
/// @author LI.FI (https://li.fi)
/// @notice Provides functionality for bridging through Hop
/// @notice taken from LiFi contracts https://github.com/lifinance/contracts and stripped down to needs
/// @custom:version 2.0.0
contract HopFacetOptimized {
    /// Types ///

    struct HopData {
        uint256 bonderFee;
        uint256 amountOutMin;
        uint256 deadline;
        uint256 destinationAmountOutMin;
        uint256 destinationDeadline;
        IHopBridge hopBridge;
        address relayer;
        uint256 relayerFee;
        uint256 nativeFee;
    }

    /// @notice Bridges ERC20 tokens via Hop Protocol from L1
    /// @param _bridgeData the core information needed for bridging
    /// @param _hopData data specific to Hop Protocol
    function startBridgeTokensViaHopL1ERC20(
        ILiFi.BridgeData calldata _bridgeData,
        HopData calldata _hopData
    )
        external
        payable
    { }

    /// @notice Bridges Native tokens via Hop Protocol from L1
    /// @param _bridgeData the core information needed for bridging
    /// @param _hopData data specific to Hop Protocol
    function startBridgeTokensViaHopL1Native(
        ILiFi.BridgeData calldata _bridgeData,
        HopData calldata _hopData
    )
        external
        payable
    { }

    /// @notice Performs a swap before bridging ERC20 tokens via Hop Protocol from L1
    /// @param _bridgeData the core information needed for bridging
    /// @param _swapData an array of swap related data for performing swaps before bridging
    /// @param _hopData data specific to Hop Protocol
    function swapAndStartBridgeTokensViaHopL1ERC20(
        ILiFi.BridgeData memory _bridgeData,
        LibSwap.SwapData[] calldata _swapData,
        HopData calldata _hopData
    )
        external
        payable
    { }

    /// @notice Performs a swap before bridging Native tokens via Hop Protocol from L1
    /// @param _bridgeData the core information needed for bridging
    /// @param _swapData an array of swap related data for performing swaps before bridging
    /// @param _hopData data specific to Hop Protocol
    function swapAndStartBridgeTokensViaHopL1Native(
        ILiFi.BridgeData memory _bridgeData,
        LibSwap.SwapData[] calldata _swapData,
        HopData calldata _hopData
    )
        external
        payable
    { }

    /// @notice Bridges ERC20 tokens via Hop Protocol from L2
    /// @param _bridgeData the core information needed for bridging
    /// @param _hopData data specific to Hop Protocol
    function startBridgeTokensViaHopL2ERC20(
        ILiFi.BridgeData calldata _bridgeData,
        HopData calldata _hopData
    )
        external
    { }

    /// @notice Bridges Native tokens via Hop Protocol from L2
    /// @param _bridgeData the core information needed for bridging
    /// @param _hopData data specific to Hop Protocol
    function startBridgeTokensViaHopL2Native(
        ILiFi.BridgeData calldata _bridgeData,
        HopData calldata _hopData
    )
        external
        payable
    { }

    /// @notice Performs a swap before bridging ERC20 tokens via Hop Protocol from L2
    /// @param _bridgeData the core information needed for bridging
    /// @param _swapData an array of swap related data for performing swaps before bridging
    /// @param _hopData data specific to Hop Protocol
    function swapAndStartBridgeTokensViaHopL2ERC20(
        ILiFi.BridgeData memory _bridgeData,
        LibSwap.SwapData[] calldata _swapData,
        HopData calldata _hopData
    )
        external
        payable
    { }

    /// @notice Performs a swap before bridging Native tokens via Hop Protocol from L2
    /// @param _bridgeData the core information needed for bridging
    /// @param _swapData an array of swap related data for performing swaps before bridging
    /// @param _hopData data specific to Hop Protocol
    function swapAndStartBridgeTokensViaHopL2Native(
        ILiFi.BridgeData memory _bridgeData,
        LibSwap.SwapData[] calldata _swapData,
        HopData calldata _hopData
    )
        external
        payable
    { }
}

// File: src/vendor/lifi/HopFacetPacked.sol

pragma solidity ^0.8.23;

/// @title Hop Facet (Optimized for Rollups)
/// @author LI.FI (https://li.fi)
/// @notice Provides functionality for bridging through Hop
/// @notice taken from LiFi contracts https://github.com/lifinance/contracts and stripped down to needs
/// @custom:version 1.0.6
contract HopFacetPacked {
    /// @notice Bridges Native tokens via Hop Protocol from L2
    /// No params, all data will be extracted from manually encoded callData
    function startBridgeTokensViaHopL2NativePacked() external payable { }

    /// @notice Bridges Native tokens via Hop Protocol from L2
    /// @param transactionId Custom transaction ID for tracking
    /// @param receiver Receiving wallet address
    /// @param destinationChainId Receiving chain
    /// @param bonderFee Fees payed to hop bonder
    /// @param amountOutMin Source swap minimal accepted amount
    /// @param destinationAmountOutMin Destination swap minimal accepted amount
    /// @param destinationDeadline Destination swap maximal time
    /// @param hopBridge Address of the Hop L2_AmmWrapper
    function startBridgeTokensViaHopL2NativeMin(
        bytes8 transactionId,
        address receiver,
        uint256 destinationChainId,
        uint256 bonderFee,
        uint256 amountOutMin,
        uint256 destinationAmountOutMin,
        uint256 destinationDeadline,
        address hopBridge
    )
        external
        payable
    { }

    /// @notice Bridges ERC20 tokens via Hop Protocol from L2
    /// No params, all data will be extracted from manually encoded callData
    function startBridgeTokensViaHopL2ERC20Packed() external { }

    /// @notice Bridges ERC20 tokens via Hop Protocol from L2
    /// @param transactionId Custom transaction ID for tracking
    /// @param receiver Receiving wallet address
    /// @param destinationChainId Receiving chain
    /// @param sendingAssetId Address of the source asset to bridge
    /// @param minAmount Amount of the source asset to bridge
    /// @param bonderFee Fees payed to hop bonder
    /// @param amountOutMin Source swap minimal accepted amount
    /// @param destinationAmountOutMin Destination swap minimal accepted amount
    /// @param destinationDeadline Destination swap maximal time
    /// @param hopBridge Address of the Hop L2_AmmWrapper
    function startBridgeTokensViaHopL2ERC20Min(
        bytes8 transactionId,
        address receiver,
        uint256 destinationChainId,
        address sendingAssetId,
        uint256 minAmount,
        uint256 bonderFee,
        uint256 amountOutMin,
        uint256 destinationAmountOutMin,
        uint256 destinationDeadline,
        address hopBridge
    )
        external
    { }

    /// @notice Bridges Native tokens via Hop Protocol from L1
    /// No params, all data will be extracted from manually encoded callData
    function startBridgeTokensViaHopL1NativePacked() external payable { }

    /// @notice Bridges Native tokens via Hop Protocol from L1
    /// @param transactionId Custom transaction ID for tracking
    /// @param receiver Receiving wallet address
    /// @param destinationChainId Receiving chain
    /// @param destinationAmountOutMin Destination swap minimal accepted amount
    /// @param relayer needed for gas spikes
    /// @param relayerFee needed for gas spikes
    /// @param hopBridge Address of the Hop Bridge
    function startBridgeTokensViaHopL1NativeMin(
        bytes8 transactionId,
        address receiver,
        uint256 destinationChainId,
        uint256 destinationAmountOutMin,
        address relayer,
        uint256 relayerFee,
        address hopBridge
    )
        external
        payable
    { }

    /// @notice Bridges Native tokens via Hop Protocol from L1
    /// No params, all data will be extracted from manually encoded callData
    function startBridgeTokensViaHopL1ERC20Packed() external payable { }

    /// @notice Bridges ERC20 tokens via Hop Protocol from L1
    /// @param transactionId Custom transaction ID for tracking
    /// @param receiver Receiving wallet address
    /// @param destinationChainId Receiving chain
    /// @param sendingAssetId Address of the source asset to bridge
    /// @param minAmount Amount of the source asset to bridge
    /// @param destinationAmountOutMin Destination swap minimal accepted amount
    /// @param relayer needed for gas spikes
    /// @param relayerFee needed for gas spikes
    /// @param hopBridge Address of the Hop Bridge
    function startBridgeTokensViaHopL1ERC20Min(
        bytes8 transactionId,
        address receiver,
        uint256 destinationChainId,
        address sendingAssetId,
        uint256 minAmount,
        uint256 destinationAmountOutMin,
        address relayer,
        uint256 relayerFee,
        address hopBridge
    )
        external
    { }
}

// File: src/crosschain-liquidity/lifi/LiFiValidator.sol

pragma solidity ^0.8.23;
















/// @title LiFiValidator
/// @dev Asserts LiFi input txData is valid
/// @author Zeropoint Labs
contract LiFiValidator is ILiFiValidator, BridgeValidator, LiFiTxDataExtractor {
    //////////////////////////////////////////////////////////////
    //                     STATE VARIABLES                      //
    //////////////////////////////////////////////////////////////

    /// @dev mapping to store the blacklisted selectors
    mapping(bytes4 selector => bool blacklisted) private blacklistedSelectors;

    //////////////////////////////////////////////////////////////
    //                       MODIFIERS                          //
    //////////////////////////////////////////////////////////////

    modifier onlyEmergencyAdmin() {
        if (!ISuperRBAC(superRegistry.getAddress(keccak256("SUPER_RBAC"))).hasEmergencyAdminRole(msg.sender)) {
            revert Error.NOT_EMERGENCY_ADMIN();
        }
        _;
    }
    //////////////////////////////////////////////////////////////
    //                      CONSTRUCTOR                         //
    //////////////////////////////////////////////////////////////

    constructor(address superRegistry_) BridgeValidator(superRegistry_) {
        /// @dev this blacklists certain packed and min selectors. Aditionally, it also blacklists all Hop & Amarok
        /// @dev selectors as superform is not compatible with unexpected refund tokens
        /// @dev see
        /// https://docs.li.fi/li.fi-api/li.fi-api/checking-the-status-of-a-transaction#handling-unexpected-receiving-token
        /// @notice this is a patch to prevent a user to bypass txData validation checks

        /// @dev blacklist packed and min selectors
        blacklistedSelectors[CBridgeFacetPacked.startBridgeTokensViaCBridgeNativePacked.selector] = true;
        emit AddedToBlacklist(CBridgeFacetPacked.startBridgeTokensViaCBridgeNativePacked.selector);

        blacklistedSelectors[CBridgeFacetPacked.startBridgeTokensViaCBridgeNativeMin.selector] = true;
        emit AddedToBlacklist(CBridgeFacetPacked.startBridgeTokensViaCBridgeNativeMin.selector);

        blacklistedSelectors[CBridgeFacetPacked.startBridgeTokensViaCBridgeERC20Packed.selector] = true;
        emit AddedToBlacklist(CBridgeFacetPacked.startBridgeTokensViaCBridgeERC20Packed.selector);

        blacklistedSelectors[CBridgeFacetPacked.startBridgeTokensViaCBridgeERC20Min.selector] = true;
        emit AddedToBlacklist(CBridgeFacetPacked.startBridgeTokensViaCBridgeERC20Min.selector);

        blacklistedSelectors[HopFacetPacked.startBridgeTokensViaHopL2NativePacked.selector] = true;
        emit AddedToBlacklist(HopFacetPacked.startBridgeTokensViaHopL2NativePacked.selector);

        blacklistedSelectors[HopFacetPacked.startBridgeTokensViaHopL2NativeMin.selector] = true;
        emit AddedToBlacklist(HopFacetPacked.startBridgeTokensViaHopL2NativeMin.selector);

        blacklistedSelectors[HopFacetPacked.startBridgeTokensViaHopL2ERC20Packed.selector] = true;
        emit AddedToBlacklist(HopFacetPacked.startBridgeTokensViaHopL2ERC20Packed.selector);

        blacklistedSelectors[HopFacetPacked.startBridgeTokensViaHopL2ERC20Min.selector] = true;
        emit AddedToBlacklist(HopFacetPacked.startBridgeTokensViaHopL2ERC20Min.selector);

        blacklistedSelectors[HopFacetPacked.startBridgeTokensViaHopL1NativePacked.selector] = true;
        emit AddedToBlacklist(HopFacetPacked.startBridgeTokensViaHopL1NativePacked.selector);

        blacklistedSelectors[HopFacetPacked.startBridgeTokensViaHopL1NativeMin.selector] = true;
        emit AddedToBlacklist(HopFacetPacked.startBridgeTokensViaHopL1NativeMin.selector);

        blacklistedSelectors[HopFacetPacked.startBridgeTokensViaHopL1ERC20Packed.selector] = true;
        emit AddedToBlacklist(HopFacetPacked.startBridgeTokensViaHopL1ERC20Packed.selector);

        blacklistedSelectors[HopFacetPacked.startBridgeTokensViaHopL1ERC20Min.selector] = true;
        emit AddedToBlacklist(HopFacetPacked.startBridgeTokensViaHopL1ERC20Min.selector);

        /// @dev blacklist normal and optimized hop facet
        blacklistedSelectors[HopFacet.startBridgeTokensViaHop.selector] = true;
        emit AddedToBlacklist(HopFacet.startBridgeTokensViaHop.selector);

        blacklistedSelectors[HopFacet.swapAndStartBridgeTokensViaHop.selector] = true;
        emit AddedToBlacklist(HopFacet.swapAndStartBridgeTokensViaHop.selector);

        blacklistedSelectors[HopFacetOptimized.startBridgeTokensViaHopL1ERC20.selector] = true;
        emit AddedToBlacklist(HopFacetOptimized.startBridgeTokensViaHopL1ERC20.selector);

        blacklistedSelectors[HopFacetOptimized.startBridgeTokensViaHopL1Native.selector] = true;
        emit AddedToBlacklist(HopFacetOptimized.startBridgeTokensViaHopL1Native.selector);

        blacklistedSelectors[HopFacetOptimized.swapAndStartBridgeTokensViaHopL1ERC20.selector] = true;
        emit AddedToBlacklist(HopFacetOptimized.swapAndStartBridgeTokensViaHopL1ERC20.selector);

        blacklistedSelectors[HopFacetOptimized.swapAndStartBridgeTokensViaHopL1Native.selector] = true;
        emit AddedToBlacklist(HopFacetOptimized.swapAndStartBridgeTokensViaHopL1Native.selector);

        blacklistedSelectors[HopFacetOptimized.startBridgeTokensViaHopL2ERC20.selector] = true;
        emit AddedToBlacklist(HopFacetOptimized.startBridgeTokensViaHopL2ERC20.selector);

        blacklistedSelectors[HopFacetOptimized.startBridgeTokensViaHopL2Native.selector] = true;
        emit AddedToBlacklist(HopFacetOptimized.startBridgeTokensViaHopL2Native.selector);

        blacklistedSelectors[HopFacetOptimized.swapAndStartBridgeTokensViaHopL2ERC20.selector] = true;
        emit AddedToBlacklist(HopFacetOptimized.swapAndStartBridgeTokensViaHopL2ERC20.selector);

        blacklistedSelectors[HopFacetOptimized.swapAndStartBridgeTokensViaHopL2Native.selector] = true;
        emit AddedToBlacklist(HopFacetOptimized.swapAndStartBridgeTokensViaHopL2Native.selector);

        /// @dev blacklist amarok facet
        blacklistedSelectors[AmarokFacet.startBridgeTokensViaAmarok.selector] = true;
        emit AddedToBlacklist(AmarokFacet.startBridgeTokensViaAmarok.selector);

        blacklistedSelectors[AmarokFacet.swapAndStartBridgeTokensViaAmarok.selector] = true;
        emit AddedToBlacklist(AmarokFacet.swapAndStartBridgeTokensViaAmarok.selector);

        /// @dev prevent recursive calls
        blacklistedSelectors[StandardizedCallFacet.standardizedCall.selector] = true;
        emit AddedToBlacklist(StandardizedCallFacet.standardizedCall.selector);
    }

    //////////////////////////////////////////////////////////////
    //              EXTERNAL  FUNCTIONS                         //
    //////////////////////////////////////////////////////////////

    /// @inheritdoc ILiFiValidator
    function addToBlacklist(bytes4 selector_) external override onlyEmergencyAdmin {
        if (blacklistedSelectors[selector_]) revert Error.BLACKLISTED_SELECTOR();

        blacklistedSelectors[selector_] = true;
        emit AddedToBlacklist(selector_);
    }

    /// @inheritdoc ILiFiValidator
    function removeFromBlacklist(bytes4 selector_) external override onlyEmergencyAdmin {
        if (!blacklistedSelectors[selector_]) revert Error.NOT_BLACKLISTED_SELECTOR();

        delete blacklistedSelectors[selector_];
        emit RemovedFromBlacklist(selector_);
    }

    //////////////////////////////////////////////////////////////
    //              EXTERNAL VIEW FUNCTIONS                     //
    //////////////////////////////////////////////////////////////

    /// @inheritdoc ILiFiValidator
    function isSelectorBlacklisted(bytes4 selector_) public view override returns (bool blacklisted) {
        return blacklistedSelectors[selector_];
    }

    /// @inheritdoc BridgeValidator
    function validateReceiver(bytes calldata txData_, address receiver_) external view override returns (bool valid_) {
        bytes4 selector = _extractSelector(txData_);
        address receiver;
        /// @dev check if it is a blacklisted selector
        if (isSelectorBlacklisted(selector)) revert Error.BLACKLISTED_SELECTOR();

        /// @dev 2 - check if it is a swapTokensGeneric call (match via selector)
        if (selector == GenericSwapFacet.swapTokensGeneric.selector) {
            /// @dev GenericSwapFacet
            (,, receiver,,) = extractGenericSwapParameters(txData_);
        } else {
            /// @dev 3 - proceed with normal extraction
            (, receiver) = _extractBridgeData(txData_);
        }

        return receiver == receiver_;
    }

    /// @inheritdoc BridgeValidator
    function validateTxData(ValidateTxDataArgs calldata args_) external view override returns (bool hasDstSwap) {
        bytes4 selector = _extractSelector(args_.txData);

        address sendingAssetId;
        address receiver;
        bool hasDestinationCall;
        uint256 destinationChainId;

        /// @dev 1 - check if it is a blacklisted selector
        if (isSelectorBlacklisted(selector)) revert Error.BLACKLISTED_SELECTOR();

        /// @dev 2 - check if it is a swapTokensGeneric call (match via selector)
        if (selector == GenericSwapFacet.swapTokensGeneric.selector) {
            /// @dev GenericSwapFacet

            (sendingAssetId,, receiver,,) = extractGenericSwapParameters(args_.txData);
            _validateGenericParameters(args_, receiver, sendingAssetId);
            /// @dev if valid return here
            return false;
        }

        /// @dev 3 - proceed with normal extraction
        (, sendingAssetId, receiver,,, destinationChainId,, hasDestinationCall) = extractMainParameters(args_.txData);

        hasDstSwap =
            _validateMainParameters(args_, hasDestinationCall, hasDstSwap, receiver, sendingAssetId, destinationChainId);

        return hasDstSwap;
    }

    /// @inheritdoc BridgeValidator
    function decodeAmountIn(
        bytes calldata txData_,
        bool genericSwapDisallowed_
    )
        external
        view
        override
        returns (uint256 amount_)
    {
        bytes4 selector = _extractSelector(txData_);

        /// @dev 1 - check if it is a  blacklisted selector
        if (isSelectorBlacklisted(selector)) revert Error.BLACKLISTED_SELECTOR();

        /// @dev 2 - check if it is a swapTokensGeneric call (match via selector)
        if (selector == GenericSwapFacet.swapTokensGeneric.selector) {
            if (genericSwapDisallowed_) {
                revert Error.INVALID_ACTION();
            }
            (, amount_,,,) = extractGenericSwapParameters(txData_);
            return amount_;
        }

        /// @dev 3 - proceed with normal extraction
        (, /*bridgeId*/,, amount_, /*amount*/, /*minAmount*/,, /*hasSourceSwaps*/ ) = extractMainParameters(txData_);
        /// @dev if there isn't a source swap, amount_ is minAmountOut from bridge data

        return amount_;
    }

    /// @inheritdoc BridgeValidator
    function decodeDstSwap(bytes calldata txData_) external pure override returns (address token_, uint256 amount_) {
        bytes4 selector = _extractSelector(txData_);
        if (selector == GenericSwapFacet.swapTokensGeneric.selector) {
            (token_, amount_,,,) = extractGenericSwapParameters(txData_);

            /// @dev remap of address 0 to NATIVE because of how LiFi produces txData
            if (token_ == address(0)) {
                token_ = NATIVE;
            }

            return (token_, amount_);
        } else {
            revert Error.INVALID_ACTION();
        }
    }

    /// @inheritdoc BridgeValidator
    function decodeSwapOutputToken(bytes calldata txData_) external pure override returns (address token_) {
        bytes4 selector = _extractSelector(txData_);

        if (selector == GenericSwapFacet.swapTokensGeneric.selector) {
            (,,, token_,) = extractGenericSwapParameters(txData_);
            return token_;
        } else {
            revert Error.CANNOT_DECODE_FINAL_SWAP_OUTPUT_TOKEN();
        }
    }

    /// @notice Extracts the main parameters from the calldata
    /// @param data_ The calldata to extract the main parameters from
    /// @return bridge The bridge extracted from the calldata
    /// @return sendingAssetId The sending asset id extracted from the calldata
    /// @return receiver The receiver extracted from the calldata
    /// @return amount The amount the calldata (which may be equal to bridge min amount)
    /// @return minAmount The min amount extracted from the bridgeData calldata
    /// @return destinationChainId The destination chain id extracted from the calldata
    /// @return hasSourceSwaps Whether the calldata has source swaps
    /// @return hasDestinationCall Whether the calldata has a destination call
    function extractMainParameters(bytes calldata data_)
        public
        pure
        returns (
            string memory bridge,
            address sendingAssetId,
            address receiver,
            uint256 amount,
            uint256 minAmount,
            uint256 destinationChainId,
            bool hasSourceSwaps,
            bool hasDestinationCall
        )
    {
        ILiFi.BridgeData memory bridgeData;
        (bridgeData, receiver) = _extractBridgeData(data_);

        if (bridgeData.hasSourceSwaps) {
            LibSwap.SwapData[] memory swapData = _extractSwapData(data_);
            sendingAssetId = swapData[0].sendingAssetId;
            amount = swapData[0].fromAmount;
        } else {
            sendingAssetId = bridgeData.sendingAssetId;
            amount = bridgeData.minAmount;
        }
        minAmount = bridgeData.minAmount;
        return (
            bridgeData.bridge,
            sendingAssetId,
            receiver,
            amount,
            minAmount,
            bridgeData.destinationChainId,
            bridgeData.hasSourceSwaps,
            bridgeData.hasDestinationCall
        );
    }

    /// @notice Extracts the generic swap parameters from the calldata
    /// @param data_ The calldata to extract the generic swap parameters from
    /// @return sendingAssetId The sending asset id extracted from the calldata
    /// @return amount The amount extracted from the calldata
    /// @return receiver The receiver extracted from the calldata
    /// @return receivingAssetId The receiving asset id extracted from the calldata
    /// @return receivingAmount The receiving amount extracted from the calldata
    function extractGenericSwapParameters(bytes calldata data_)
        public
        pure
        returns (
            address sendingAssetId,
            uint256 amount,
            address receiver,
            address receivingAssetId,
            uint256 receivingAmount
        )
    {
        LibSwap.SwapData[] memory swapData;
        bytes memory callData = data_;

        if (bytes4(data_[:4]) == StandardizedCallFacet.standardizedCall.selector) {
            // standardizedCall
            callData = abi.decode(data_[4:], (bytes));
        }
        (,,, receiver, receivingAmount, swapData) = abi.decode(
            _slice(callData, 4, callData.length - 4), (bytes32, string, string, address, uint256, LibSwap.SwapData[])
        );

        sendingAssetId = swapData[0].sendingAssetId;
        amount = swapData[0].fromAmount;
        receivingAssetId = swapData[swapData.length - 1].receivingAssetId;
    }

    function _validateMainParameters(
        ValidateTxDataArgs calldata args_,
        bool hasDestinationCall,
        bool hasDstSwap,
        address receiver,
        address sendingAssetId,
        uint256 destinationChainId
    )
        internal
        view
        returns (bool)
    {
        /// @notice xchain actions can have bridgeData or swapData + bridgeData

        /// @dev 0. Destination call validation
        if (hasDestinationCall) revert Error.INVALID_TXDATA_NO_DESTINATIONCALL_ALLOWED();

        /// @dev 1. chainId validation
        /// @dev for deposits, liqDstChainId/toChainId will be the normal destination (where the target superform
        /// is)
        /// @dev for withdraws, liqDstChainId will be the desired chain to where the underlying must be
        /// sent (post any bridge/swap). To ChainId is where the target superform is
        /// @dev to after vault redemption

        if (uint256(args_.liqDstChainId) != destinationChainId) revert Error.INVALID_TXDATA_CHAIN_ID();

        /// @dev 2. receiver address validation
        if (args_.deposit) {
            if (args_.srcChainId == args_.dstChainId) {
                revert Error.INVALID_ACTION();
            } else {
                hasDstSwap = receiver == superRegistry.getAddressByChainId(keccak256("DST_SWAPPER"), args_.dstChainId);
                /// @dev if cross chain deposits, then receiver address must be CoreStateRegistry (or) Dst Swapper
                if (
                    !(
                        receiver
                            == superRegistry.getAddressByChainId(keccak256("CORE_STATE_REGISTRY"), args_.dstChainId)
                            || hasDstSwap
                    )
                ) {
                    revert Error.INVALID_TXDATA_RECEIVER();
                }

                /// @dev forbid xChain deposits with destination swaps without interim token set (for user
                /// protection)
                if (hasDstSwap && args_.liqDataInterimToken == address(0)) {
                    revert Error.INVALID_INTERIM_TOKEN();
                }
            }
        } else {
            /// @dev if withdraws, then receiver address must be the receiverAddress
            if (receiver != args_.receiverAddress) revert Error.INVALID_TXDATA_RECEIVER();
        }

        /// @dev remap of address 0 to NATIVE because of how LiFi produces txData
        if (sendingAssetId == address(0)) {
            sendingAssetId = NATIVE;
        }

        /// @dev 3. token validations
        if (args_.liqDataToken != sendingAssetId) revert Error.INVALID_TXDATA_TOKEN();

        return hasDstSwap;
    }

    function _validateGenericParameters(
        ValidateTxDataArgs calldata args_,
        address receiver,
        address sendingAssetId
    )
        internal
        pure
    {
        /// @notice direct actions with deposit, cannot have bridge data
        /// @notice withdraw actions without bridge data (just swap) also fall in GenericSwap
        if (args_.deposit) {
            /// @dev 1. chainId validation
            if (args_.srcChainId != args_.dstChainId) revert Error.INVALID_TXDATA_CHAIN_ID();
            if (args_.dstChainId != args_.liqDstChainId) revert Error.INVALID_DEPOSIT_LIQ_DST_CHAIN_ID();

            /// @dev 2. receiver address validation
            /// @dev If same chain deposits then receiver address must be the superform
            if (receiver != args_.superform) revert Error.INVALID_TXDATA_RECEIVER();
        } else {
            /// @dev 2. receiver address validation
            /// @dev if withdraws, then receiver address must be the receiverAddress
            if (receiver != args_.receiverAddress) revert Error.INVALID_TXDATA_RECEIVER();
        }

        /// @dev remap of address 0 to NATIVE because of how LiFi produces txData
        if (sendingAssetId == address(0)) {
            sendingAssetId = NATIVE;
        }
        /// @dev 3. token validations
        if (args_.liqDataToken != sendingAssetId) revert Error.INVALID_TXDATA_TOKEN();
    }
}
