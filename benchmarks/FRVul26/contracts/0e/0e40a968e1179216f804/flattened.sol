// Sources retrieved from Sourcify API v2.
// Deterministic best-effort flattening; original files are preserved under src/.

// File: lib/ethereum-vault-connector/src/Set.sol

pragma solidity ^0.8.0;

/// @dev Represents the maximum number of elements that can be stored in the set.
/// Must not exceed 255 due to the uint8 data type limit.
uint8 constant SET_MAX_ELEMENTS = 10;

/// @title ElementStorage
/// @notice This struct is used to store the value and stamp of an element.
/// @dev The stamp field is used to keep the storage slot non-zero when the element is removed.
/// @dev It allows for cheaper SSTORE when an element is inserted.
struct ElementStorage {
    /// @notice The value of the element.
    address value;
    /// @notice The stamp of the element.
    uint96 stamp;
}

/// @title SetStorage
/// @notice This struct is used to store the set data.
/// @dev To optimize the gas consumption, firstElement is stored in the same storage slot as the numElements
/// @dev so that for sets with one element, only one storage slot has to be read/written. To keep the elements
/// @dev array indexing consistent and because the first element is stored outside of the array, the elements[0]
/// @dev is not utilized. The stamp field is used to keep the storage slot non-zero when the element is removed.
/// @dev It allows for cheaper SSTORE when an element is inserted.
struct SetStorage {
    /// @notice The number of elements in the set.
    uint8 numElements;
    /// @notice The first element in the set.
    address firstElement;
    /// @notice The metadata of the set.
    uint80 metadata;
    /// @notice The stamp of the set.
    uint8 stamp;
    /// @notice The array of elements in the set. Stores the elements starting from index 1.
    ElementStorage[SET_MAX_ELEMENTS] elements;
}

/// @title Set
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice This library provides functions for managing sets of addresses.
/// @dev The maximum number of elements in the set is defined by the constant SET_MAX_ELEMENTS.
library Set {
    error TooManyElements();
    error InvalidIndex();

    uint8 internal constant EMPTY_ELEMENT_OFFSET = 1; // must be 1
    uint8 internal constant DUMMY_STAMP = 1;

    /// @notice Initializes the set by setting the stamp field of the SetStorage and the stamp field of elements to
    /// DUMMY_STAMP.
    /// @dev The stamp field is used to keep the storage slot non-zero when the element is removed. It allows for
    /// cheaper SSTORE when an element is inserted.
    /// @param setStorage The set storage whose stamp fields will be initialized.
    function initialize(SetStorage storage setStorage) internal {
        setStorage.stamp = DUMMY_STAMP;

        for (uint256 i = EMPTY_ELEMENT_OFFSET; i < SET_MAX_ELEMENTS; ++i) {
            setStorage.elements[i].stamp = DUMMY_STAMP;
        }
    }

    /// @notice Inserts an element and returns information whether the element was inserted or not.
    /// @dev Reverts if the set is full but the element is not in the set storage.
    /// @param setStorage The set storage to which the element will be inserted.
    /// @param element The element to be inserted.
    /// @return A boolean value that indicates whether the element was inserted or not. If the element was already in
    /// the set storage, it returns false.
    function insert(SetStorage storage setStorage, address element) internal returns (bool) {
        address firstElement = setStorage.firstElement;
        uint256 numElements = setStorage.numElements;
        uint80 metadata = setStorage.metadata;

        if (numElements == 0) {
            // gas optimization:
            // on the first element insertion, set the stamp to non-zero value to keep the storage slot non-zero when
            // the element is removed. when a new element is inserted after the removal, it should be cheaper
            setStorage.numElements = 1;
            setStorage.firstElement = element;
            setStorage.metadata = metadata;
            setStorage.stamp = DUMMY_STAMP;
            return true;
        }

        if (firstElement == element) return false;

        for (uint256 i = EMPTY_ELEMENT_OFFSET; i < numElements; ++i) {
            if (setStorage.elements[i].value == element) return false;
        }

        if (numElements == SET_MAX_ELEMENTS) revert TooManyElements();

        setStorage.elements[numElements].value = element;

        unchecked {
            setStorage.numElements = uint8(numElements + 1);
        }

        return true;
    }

    /// @notice Removes an element and returns information whether the element was removed or not.
    /// @dev This operation may affect the order of elements in the array of elements obtained using get() function. This
    /// function does not modify the metadata of the set, even if it becomes empty as a result of invoking this
    /// function.
    /// @param setStorage The set storage from which the element will be removed.
    /// @param element The element to be removed.
    /// @return A boolean value that indicates whether the element was removed or not. If the element was not in the set
    /// storage, it returns false.
    function remove(SetStorage storage setStorage, address element) internal returns (bool) {
        address firstElement = setStorage.firstElement;
        uint256 numElements = setStorage.numElements;
        uint80 metadata = setStorage.metadata;

        if (numElements == 0) return false;

        uint256 searchIndex;
        if (firstElement != element) {
            for (searchIndex = EMPTY_ELEMENT_OFFSET; searchIndex < numElements; ++searchIndex) {
                if (setStorage.elements[searchIndex].value == element) break;
            }

            if (searchIndex == numElements) return false;
        }

        // write full slot at once to avoid SLOAD and bit masking
        if (numElements == 1) {
            setStorage.numElements = 0;
            setStorage.firstElement = address(0);
            setStorage.metadata = metadata;
            setStorage.stamp = DUMMY_STAMP;
            return true;
        }

        uint256 lastIndex;
        unchecked {
            lastIndex = numElements - 1;
        }

        // set numElements for every execution path to avoid SSTORE and bit masking when the element removed is
        // firstElement
        ElementStorage storage lastElement = setStorage.elements[lastIndex];
        if (searchIndex != lastIndex) {
            if (searchIndex == 0) {
                setStorage.firstElement = lastElement.value;
                setStorage.numElements = uint8(lastIndex);
                setStorage.metadata = metadata;
                setStorage.stamp = DUMMY_STAMP;
            } else {
                setStorage.elements[searchIndex].value = lastElement.value;

                setStorage.firstElement = firstElement;
                setStorage.numElements = uint8(lastIndex);
                setStorage.metadata = metadata;
                setStorage.stamp = DUMMY_STAMP;
            }
        } else {
            setStorage.firstElement = firstElement;
            setStorage.numElements = uint8(lastIndex);
            setStorage.metadata = metadata;
            setStorage.stamp = DUMMY_STAMP;
        }

        lastElement.value = address(0);

        return true;
    }

    /// @notice Swaps the position of two elements so that they appear switched in the array of elements obtained using
    /// get() function.
    /// @dev The first index must not be greater than or equal to the second index. Indices must not be out of bounds.
    /// The function will revert if the indices are invalid.
    /// @param setStorage The set storage for which the elements will be swapped.
    /// @param index1 The index of the first element to be swapped.
    /// @param index2 The index of the second element to be swapped.
    function reorder(SetStorage storage setStorage, uint8 index1, uint8 index2) internal {
        address firstElement = setStorage.firstElement;
        uint256 numElements = setStorage.numElements;

        if (index1 >= index2 || index2 >= numElements) {
            revert InvalidIndex();
        }

        if (index1 == 0) {
            (setStorage.firstElement, setStorage.elements[index2].value) =
                (setStorage.elements[index2].value, firstElement);
        } else {
            (setStorage.elements[index1].value, setStorage.elements[index2].value) =
                (setStorage.elements[index2].value, setStorage.elements[index1].value);
        }
    }

    /// @notice Sets the metadata for the set storage.
    /// @param setStorage The storage structure where metadata will be set.
    /// @param metadata The metadata value to set.
    function setMetadata(SetStorage storage setStorage, uint80 metadata) internal {
        setStorage.metadata = metadata;
    }

    /// @notice Returns an array of elements contained in the storage.
    /// @dev The order of the elements in the array may be affected by performing operations on the set.
    /// @param setStorage The set storage to be processed.
    /// @return An array that contains the same elements as the set storage.
    function get(SetStorage storage setStorage) internal view returns (address[] memory) {
        address firstElement = setStorage.firstElement;
        uint256 numElements = setStorage.numElements;
        address[] memory output = new address[](numElements);

        if (numElements == 0) return output;

        output[0] = firstElement;

        for (uint256 i = EMPTY_ELEMENT_OFFSET; i < numElements; ++i) {
            output[i] = setStorage.elements[i].value;
        }

        return output;
    }

    /// @notice Retrieves the metadata from the set storage.
    /// @param setStorage The storage structure from which metadata is retrieved.
    /// @return The metadata value.
    function getMetadata(SetStorage storage setStorage) internal view returns (uint80) {
        return setStorage.metadata;
    }

    /// @notice Checks if the set storage contains a given element and returns a boolean value that indicates the
    /// result.
    /// @param setStorage The set storage to be searched.
    /// @param element The element to be searched for.
    /// @return A boolean value that indicates whether the set storage includes the element or not.
    function contains(SetStorage storage setStorage, address element) internal view returns (bool) {
        address firstElement = setStorage.firstElement;
        uint256 numElements = setStorage.numElements;

        if (numElements == 0) return false;
        if (firstElement == element) return true;

        for (uint256 i = EMPTY_ELEMENT_OFFSET; i < numElements; ++i) {
            if (setStorage.elements[i].value == element) return true;
        }

        return false;
    }

    /// @notice Iterates over each element in the set and applies the callback function to it.
    /// @dev The set is cleared as a result of this call. Considering that this function does not follow the
    /// Checks-Effects-Interactions pattern, the function using it must prevent re-entrancy. This function does not
    /// modify the metadata of the set.
    /// @param setStorage The set storage to be processed.
    /// @param callback The function to be applied to each element.
    function forEachAndClear(SetStorage storage setStorage, function(address) callback) internal {
        uint256 numElements = setStorage.numElements;
        address firstElement = setStorage.firstElement;
        uint80 metadata = setStorage.metadata;

        if (numElements == 0) return;

        setStorage.numElements = 0;
        setStorage.firstElement = address(0);
        setStorage.metadata = metadata;
        setStorage.stamp = DUMMY_STAMP;

        callback(firstElement);

        for (uint256 i = EMPTY_ELEMENT_OFFSET; i < numElements; ++i) {
            address element = setStorage.elements[i].value;
            setStorage.elements[i] = ElementStorage({value: address(0), stamp: DUMMY_STAMP});

            callback(element);
        }
    }

    /// @notice Iterates over each element in the set and applies the callback function to it, returning the array of
    /// callback results.
    /// @dev The set is cleared as a result of this call. Considering that this function does not follow the
    /// Checks-Effects-Interactions pattern, the function using it must prevent re-entrancy. This function does not
    /// modify the metadata of the set.
    /// @param setStorage The set storage to be processed.
    /// @param callback The function to be applied to each element.
    /// @return result An array of encoded bytes that are the addresses passed to the callback function and results of
    /// calling it.
    function forEachAndClearWithResult(
        SetStorage storage setStorage,
        function(address) returns (bool, bytes memory) callback
    ) internal returns (bytes[] memory) {
        uint256 numElements = setStorage.numElements;
        address firstElement = setStorage.firstElement;
        uint80 metadata = setStorage.metadata;
        bytes[] memory results = new bytes[](numElements);

        if (numElements == 0) return results;

        setStorage.numElements = 0;
        setStorage.firstElement = address(0);
        setStorage.metadata = metadata;
        setStorage.stamp = DUMMY_STAMP;

        (bool success, bytes memory result) = callback(firstElement);
        results[0] = abi.encode(firstElement, success, result);

        for (uint256 i = EMPTY_ELEMENT_OFFSET; i < numElements; ++i) {
            address element = setStorage.elements[i].value;
            setStorage.elements[i] = ElementStorage({value: address(0), stamp: DUMMY_STAMP});

            (success, result) = callback(element);
            results[i] = abi.encode(element, success, result);
        }

        return results;
    }
}

// File: lib/ethereum-vault-connector/src/Events.sol

pragma solidity ^0.8.0;

/// @title Events
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice This contract implements the events for the Ethereum Vault Connector.
contract Events {
    /// @notice Emitted when an owner is registered for an address prefix.
    /// @param addressPrefix The address prefix for which the owner is registered.
    /// @param owner The address of the owner registered.
    event OwnerRegistered(bytes19 indexed addressPrefix, address indexed owner);

    /// @notice Emitted when the lockdown mode status is changed for an address prefix.
    /// @param addressPrefix The address prefix for which the lockdown mode status is changed.
    /// @param enabled True if the lockdown mode is enabled, false otherwise.
    event LockdownModeStatus(bytes19 indexed addressPrefix, bool enabled);

    /// @notice Emitted when the permit disabled mode status is changed for an address prefix.
    /// @param addressPrefix The address prefix for which the permit disabled mode status is changed.
    /// @param enabled True if the permit disabled mode is enabled, false otherwise.
    event PermitDisabledModeStatus(bytes19 indexed addressPrefix, bool enabled);

    /// @notice Emitted when the nonce status is updated for a given address prefix and nonce namespace.
    /// @param addressPrefix The prefix of the address for which the nonce status is updated.
    /// @param nonceNamespace The namespace of the nonce being updated.
    /// @param oldNonce The previous nonce value before the update.
    /// @param newNonce The new nonce value after the update.
    event NonceStatus(
        bytes19 indexed addressPrefix, uint256 indexed nonceNamespace, uint256 oldNonce, uint256 newNonce
    );

    /// @notice Emitted when a nonce is used for an address prefix and nonce namespace as part of permit execution.
    /// @param addressPrefix The address prefix for which the nonce is used.
    /// @param nonceNamespace The namespace of the nonce used.
    /// @param nonce The nonce that was used.
    event NonceUsed(bytes19 indexed addressPrefix, uint256 indexed nonceNamespace, uint256 nonce);

    /// @notice Emitted when the operator status is changed for an address prefix.
    /// @param addressPrefix The address prefix for which the operator status is changed.
    /// @param operator The address of the operator.
    /// @param accountOperatorAuthorized The new authorization bitfield of the operator.
    event OperatorStatus(bytes19 indexed addressPrefix, address indexed operator, uint256 accountOperatorAuthorized);

    /// @notice Emitted when the collateral status is changed for an account.
    /// @param account The account for which the collateral status is changed.
    /// @param collateral The address of the collateral.
    /// @param enabled True if the collateral is enabled, false otherwise.
    event CollateralStatus(address indexed account, address indexed collateral, bool enabled);

    /// @notice Emitted when the controller status is changed for an account.
    /// @param account The account for which the controller status is changed.
    /// @param controller The address of the controller.
    /// @param enabled True if the controller is enabled, false otherwise.
    event ControllerStatus(address indexed account, address indexed controller, bool enabled);

    /// @notice Emitted when an external call is made through the EVC.
    /// @param caller The address of the caller.
    /// @param onBehalfOfAddressPrefix The address prefix of the account on behalf of which the call is made.
    /// @param onBehalfOfAccount The account on behalf of which the call is made.
    /// @param targetContract The target contract of the call.
    /// @param selector The selector of the function called on the target contract.
    event CallWithContext(
        address indexed caller,
        bytes19 indexed onBehalfOfAddressPrefix,
        address onBehalfOfAccount,
        address indexed targetContract,
        bytes4 selector
    );

    /// @notice Emitted when an account status check is performed.
    /// @param account The account for which the status check is performed.
    /// @param controller The controller performing the status check.
    event AccountStatusCheck(address indexed account, address indexed controller);

    /// @notice Emitted when a vault status check is performed.
    /// @param vault The vault for which the status check is performed.
    event VaultStatusCheck(address indexed vault);
}

// File: lib/ethereum-vault-connector/src/interfaces/IEthereumVaultConnector.sol

pragma solidity >=0.8.0;

/// @title IEVC
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice This interface defines the methods for the Ethereum Vault Connector.
interface IEVC {
    /// @notice A struct representing a batch item.
    /// @dev Each batch item represents a single operation to be performed within a checks deferred context.
    struct BatchItem {
        /// @notice The target contract to be called.
        address targetContract;
        /// @notice The account on behalf of which the operation is to be performed. msg.sender must be authorized to
        /// act on behalf of this account. Must be address(0) if the target contract is the EVC itself.
        address onBehalfOfAccount;
        /// @notice The amount of value to be forwarded with the call. If the value is type(uint256).max, the whole
        /// balance of the EVC contract will be forwarded. Must be 0 if the target contract is the EVC itself.
        uint256 value;
        /// @notice The encoded data which is called on the target contract.
        bytes data;
    }

    /// @notice A struct representing the result of a batch item operation.
    /// @dev Used only for simulation purposes.
    struct BatchItemResult {
        /// @notice A boolean indicating whether the operation was successful.
        bool success;
        /// @notice The result of the operation.
        bytes result;
    }

    /// @notice A struct representing the result of the account or vault status check.
    /// @dev Used only for simulation purposes.
    struct StatusCheckResult {
        /// @notice The address of the account or vault for which the check was performed.
        address checkedAddress;
        /// @notice A boolean indicating whether the status of the account or vault is valid.
        bool isValid;
        /// @notice The result of the check.
        bytes result;
    }

    /// @notice Returns current raw execution context.
    /// @dev When checks in progress, on behalf of account is always address(0).
    /// @return context Current raw execution context.
    function getRawExecutionContext() external view returns (uint256 context);

    /// @notice Returns an account on behalf of which the operation is being executed at the moment and whether the
    /// controllerToCheck is an enabled controller for that account.
    /// @dev This function should only be used by external smart contracts if msg.sender is the EVC. Otherwise, the
    /// account address returned must not be trusted.
    /// @dev When checks in progress, on behalf of account is always address(0). When address is zero, the function
    /// reverts to protect the consumer from ever relying on the on behalf of account address which is in its default
    /// state.
    /// @param controllerToCheck The address of the controller for which it is checked whether it is an enabled
    /// controller for the account on behalf of which the operation is being executed at the moment.
    /// @return onBehalfOfAccount An account that has been authenticated and on behalf of which the operation is being
    /// executed at the moment.
    /// @return controllerEnabled A boolean value that indicates whether controllerToCheck is an enabled controller for
    /// the account on behalf of which the operation is being executed at the moment. Always false if controllerToCheck
    /// is address(0).
    function getCurrentOnBehalfOfAccount(address controllerToCheck)
        external
        view
        returns (address onBehalfOfAccount, bool controllerEnabled);

    /// @notice Checks if checks are deferred.
    /// @return A boolean indicating whether checks are deferred.
    function areChecksDeferred() external view returns (bool);

    /// @notice Checks if checks are in progress.
    /// @return A boolean indicating whether checks are in progress.
    function areChecksInProgress() external view returns (bool);

    /// @notice Checks if control collateral is in progress.
    /// @return A boolean indicating whether control collateral is in progress.
    function isControlCollateralInProgress() external view returns (bool);

    /// @notice Checks if an operator is authenticated.
    /// @return A boolean indicating whether an operator is authenticated.
    function isOperatorAuthenticated() external view returns (bool);

    /// @notice Checks if a simulation is in progress.
    /// @return A boolean indicating whether a simulation is in progress.
    function isSimulationInProgress() external view returns (bool);

    /// @notice Checks whether the specified account and the other account have the same owner.
    /// @dev The function is used to check whether one account is authorized to perform operations on behalf of the
    /// other. Accounts are considered to have a common owner if they share the first 19 bytes of their address.
    /// @param account The address of the account that is being checked.
    /// @param otherAccount The address of the other account that is being checked.
    /// @return A boolean flag that indicates whether the accounts have the same owner.
    function haveCommonOwner(address account, address otherAccount) external pure returns (bool);

    /// @notice Returns the address prefix of the specified account.
    /// @dev The address prefix is the first 19 bytes of the account address.
    /// @param account The address of the account whose address prefix is being retrieved.
    /// @return A bytes19 value that represents the address prefix of the account.
    function getAddressPrefix(address account) external pure returns (bytes19);

    /// @notice Returns the owner for the specified account.
    /// @dev The function returns address(0) if the owner is not registered. Registration of the owner happens on the
    /// initial
    /// interaction with the EVC that requires authentication of an owner.
    /// @param account The address of the account whose owner is being retrieved.
    /// @return owner The address of the account owner. An account owner is an EOA/smart contract which address matches
    /// the first 19 bytes of the account address.
    function getAccountOwner(address account) external view returns (address);

    /// @notice Checks if lockdown mode is enabled for a given address prefix.
    /// @param addressPrefix The address prefix to check for lockdown mode status.
    /// @return A boolean indicating whether lockdown mode is enabled.
    function isLockdownMode(bytes19 addressPrefix) external view returns (bool);

    /// @notice Checks if permit functionality is disabled for a given address prefix.
    /// @param addressPrefix The address prefix to check for permit functionality status.
    /// @return A boolean indicating whether permit functionality is disabled.
    function isPermitDisabledMode(bytes19 addressPrefix) external view returns (bool);

    /// @notice Returns the current nonce for a given address prefix and nonce namespace.
    /// @dev Each nonce namespace provides 256 bit nonce that has to be used sequentially. There's no requirement to use
    /// all the nonces for a given nonce namespace before moving to the next one which allows to use permit messages in
    /// a non-sequential manner.
    /// @param addressPrefix The address prefix for which the nonce is being retrieved.
    /// @param nonceNamespace The nonce namespace for which the nonce is being retrieved.
    /// @return nonce The current nonce for the given address prefix and nonce namespace.
    function getNonce(bytes19 addressPrefix, uint256 nonceNamespace) external view returns (uint256 nonce);

    /// @notice Returns the bit field for a given address prefix and operator.
    /// @dev The bit field is used to store information about authorized operators for a given address prefix. Each bit
    /// in the bit field corresponds to one account belonging to the same owner. If the bit is set, the operator is
    /// authorized for the account.
    /// @param addressPrefix The address prefix for which the bit field is being retrieved.
    /// @param operator The address of the operator for which the bit field is being retrieved.
    /// @return operatorBitField The bit field for the given address prefix and operator. The bit field defines which
    /// accounts the operator is authorized for. It is a 256-position binary array like 0...010...0, marking the account
    /// positionally in a uint256. The position in the bit field corresponds to the account ID (0-255), where 0 is the
    /// owner account's ID.
    function getOperator(bytes19 addressPrefix, address operator) external view returns (uint256 operatorBitField);

    /// @notice Returns whether a given operator has been authorized for a given account.
    /// @param account The address of the account whose operator is being checked.
    /// @param operator The address of the operator that is being checked.
    /// @return authorized A boolean value that indicates whether the operator is authorized for the account.
    function isAccountOperatorAuthorized(address account, address operator) external view returns (bool authorized);

    /// @notice Enables or disables lockdown mode for a given address prefix.
    /// @dev This function can only be called by the owner of the address prefix. To disable this mode, the EVC
    /// must be called directly. It is not possible to disable this mode by using checks-deferrable call or
    /// permit message.
    /// @param addressPrefix The address prefix for which the lockdown mode is being set.
    /// @param enabled A boolean indicating whether to enable or disable lockdown mode.
    function setLockdownMode(bytes19 addressPrefix, bool enabled) external payable;

    /// @notice Enables or disables permit functionality for a given address prefix.
    /// @dev This function can only be called by the owner of the address prefix. To disable this mode, the EVC
    /// must be called directly. It is not possible to disable this mode by using checks-deferrable call or (by
    /// definition) permit message. To support permit functionality by default, note that the logic was inverted here. To
    /// disable  the permit functionality, one must pass true as the second argument. To enable the permit
    /// functionality, one must pass false as the second argument.
    /// @param addressPrefix The address prefix for which the permit functionality is being set.
    /// @param enabled A boolean indicating whether to enable or disable the disable-permit mode.
    function setPermitDisabledMode(bytes19 addressPrefix, bool enabled) external payable;

    /// @notice Sets the nonce for a given address prefix and nonce namespace.
    /// @dev This function can only be called by the owner of the address prefix. Each nonce namespace provides a 256
    /// bit nonce that has to be used sequentially. There's no requirement to use all the nonces for a given nonce
    /// namespace before moving to the next one which allows the use of permit messages in a non-sequential manner. To
    /// invalidate signed permit messages, set the nonce for a given nonce namespace accordingly. To invalidate all the
    /// permit messages for a given nonce namespace, set the nonce to type(uint).max.
    /// @param addressPrefix The address prefix for which the nonce is being set.
    /// @param nonceNamespace The nonce namespace for which the nonce is being set.
    /// @param nonce The new nonce for the given address prefix and nonce namespace.
    function setNonce(bytes19 addressPrefix, uint256 nonceNamespace, uint256 nonce) external payable;

    /// @notice Sets the bit field for a given address prefix and operator.
    /// @dev This function can only be called by the owner of the address prefix. Each bit in the bit field corresponds
    /// to one account belonging to the same owner. If the bit is set, the operator is authorized for the account.
    /// @param addressPrefix The address prefix for which the bit field is being set.
    /// @param operator The address of the operator for which the bit field is being set. Can neither be the EVC address
    /// nor an address belonging to the same address prefix.
    /// @param operatorBitField The new bit field for the given address prefix and operator. Reverts if the provided
    /// value is equal to the currently stored value.
    function setOperator(bytes19 addressPrefix, address operator, uint256 operatorBitField) external payable;

    /// @notice Authorizes or deauthorizes an operator for the account.
    /// @dev Only the owner or authorized operator of the account can call this function. An operator is an address that
    /// can perform actions for an account on behalf of the owner. If it's an operator calling this function, it can
    /// only deauthorize itself.
    /// @param account The address of the account whose operator is being set or unset.
    /// @param operator The address of the operator that is being installed or uninstalled. Can neither be the EVC
    /// address nor an address belonging to the same owner as the account.
    /// @param authorized A boolean value that indicates whether the operator is being authorized or deauthorized.
    /// Reverts if the provided value is equal to the currently stored value.
    function setAccountOperator(address account, address operator, bool authorized) external payable;

    /// @notice Returns an array of collaterals enabled for an account.
    /// @dev A collateral is a vault for which an account's balances are under the control of the currently enabled
    /// controller vault.
    /// @param account The address of the account whose collaterals are being queried.
    /// @return An array of addresses that are enabled collaterals for the account.
    function getCollaterals(address account) external view returns (address[] memory);

    /// @notice Returns whether a collateral is enabled for an account.
    /// @dev A collateral is a vault for which account's balances are under the control of the currently enabled
    /// controller vault.
    /// @param account The address of the account that is being checked.
    /// @param vault The address of the collateral that is being checked.
    /// @return A boolean value that indicates whether the vault is an enabled collateral for the account or not.
    function isCollateralEnabled(address account, address vault) external view returns (bool);

    /// @notice Enables a collateral for an account.
    /// @dev A collaterals is a vault for which account's balances are under the control of the currently enabled
    /// controller vault. Only the owner or an operator of the account can call this function. Unless it's a duplicate,
    /// the collateral is added to the end of the array. There can be at most 10 unique collaterals enabled at a time.
    /// Account status checks are performed.
    /// @param account The account address for which the collateral is being enabled.
    /// @param vault The address being enabled as a collateral.
    function enableCollateral(address account, address vault) external payable;

    /// @notice Disables a collateral for an account.
    /// @dev This function does not preserve the order of collaterals in the array obtained using the getCollaterals
    /// function; the order may change. A collateral is a vault for which account’s balances are under the control of
    /// the currently enabled controller vault. Only the owner or an operator of the account can call this function.
    /// Disabling a collateral might change the order of collaterals in the array obtained using getCollaterals
    /// function. Account status checks are performed.
    /// @param account The account address for which the collateral is being disabled.
    /// @param vault The address of a collateral being disabled.
    function disableCollateral(address account, address vault) external payable;

    /// @notice Swaps the position of two collaterals so that they appear switched in the array of collaterals for a
    /// given account obtained by calling getCollaterals function.
    /// @dev A collateral is a vault for which account’s balances are under the control of the currently enabled
    /// controller vault. Only the owner or an operator of the account can call this function. The order of collaterals
    /// can be changed by specifying the indices of the two collaterals to be swapped. Indices are zero-based and must
    /// be in the range of 0 to the number of collaterals minus 1. index1 must be lower than index2. Account status
    /// checks are performed.
    /// @param account The address of the account for which the collaterals are being reordered.
    /// @param index1 The index of the first collateral to be swapped.
    /// @param index2 The index of the second collateral to be swapped.
    function reorderCollaterals(address account, uint8 index1, uint8 index2) external payable;

    /// @notice Returns an array of enabled controllers for an account.
    /// @dev A controller is a vault that has been chosen for an account to have special control over the account's
    /// balances in enabled collaterals vaults. A user can have multiple controllers during a call execution, but at
    /// most one can be selected when the account status check is performed.
    /// @param account The address of the account whose controllers are being queried.
    /// @return An array of addresses that are the enabled controllers for the account.
    function getControllers(address account) external view returns (address[] memory);

    /// @notice Returns whether a controller is enabled for an account.
    /// @dev A controller is a vault that has been chosen for an account to have special control over account’s
    /// balances in the enabled collaterals vaults.
    /// @param account The address of the account that is being checked.
    /// @param vault The address of the controller that is being checked.
    /// @return A boolean value that indicates whether the vault is enabled controller for the account or not.
    function isControllerEnabled(address account, address vault) external view returns (bool);

    /// @notice Enables a controller for an account.
    /// @dev A controller is a vault that has been chosen for an account to have special control over account’s
    /// balances in the enabled collaterals vaults. Only the owner or an operator of the account can call this function.
    /// Unless it's a duplicate, the controller is added to the end of the array. Transiently, there can be at most 10
    /// unique controllers enabled at a time, but at most one can be enabled after the outermost checks-deferrable
    /// call concludes. Account status checks are performed.
    /// @param account The address for which the controller is being enabled.
    /// @param vault The address of the controller being enabled.
    function enableController(address account, address vault) external payable;

    /// @notice Disables a controller for an account.
    /// @dev A controller is a vault that has been chosen for an account to have special control over account’s
    /// balances in the enabled collaterals vaults. Only the vault itself can call this function. Disabling a controller
    /// might change the order of controllers in the array obtained using getControllers function. Account status checks
    /// are performed.
    /// @param account The address for which the calling controller is being disabled.
    function disableController(address account) external payable;

    /// @notice Executes signed arbitrary data by self-calling into the EVC.
    /// @dev Low-level call function is used to execute the arbitrary data signed by the owner or the operator on the
    /// EVC contract. During that call, EVC becomes msg.sender.
    /// @param signer The address signing the permit message (ECDSA) or verifying the permit message signature
    /// (ERC-1271). It's also the owner or the operator of all the accounts for which authentication will be needed
    /// during the execution of the arbitrary data call.
    /// @param sender The address of the msg.sender which is expected to execute the data signed by the signer. If
    /// address(0) is passed, the msg.sender is ignored.
    /// @param nonceNamespace The nonce namespace for which the nonce is being used.
    /// @param nonce The nonce for the given account and nonce namespace. A valid nonce value is considered to be the
    /// value currently stored and can take any value between 0 and type(uint256).max - 1.
    /// @param deadline The timestamp after which the permit is considered expired.
    /// @param value The amount of value to be forwarded with the call. If the value is type(uint256).max, the whole
    /// balance of the EVC contract will be forwarded.
    /// @param data The encoded data which is self-called on the EVC contract.
    /// @param signature The signature of the data signed by the signer.
    function permit(
        address signer,
        address sender,
        uint256 nonceNamespace,
        uint256 nonce,
        uint256 deadline,
        uint256 value,
        bytes calldata data,
        bytes calldata signature
    ) external payable;

    /// @notice Calls into a target contract as per data encoded.
    /// @dev This function defers the account and vault status checks (it's a checks-deferrable call). If the outermost
    /// call ends, the account and vault status checks are performed.
    /// @dev This function can be used to interact with any contract while checks are deferred. If the target contract
    /// is msg.sender, msg.sender is called back with the calldata provided and the context set up according to the
    /// account provided. If the target contract is not msg.sender, only the owner or the operator of the account
    /// provided can call this function.
    /// @dev This function can be used to recover the remaining value from the EVC contract.
    /// @param targetContract The address of the contract to be called.
    /// @param onBehalfOfAccount  If the target contract is msg.sender, the address of the account which will be set
    /// in the context. It assumes msg.sender has authenticated the account themselves. If the target contract is
    /// not msg.sender, the address of the account for which it is checked whether msg.sender is authorized to act
    /// on behalf of.
    /// @param value The amount of value to be forwarded with the call. If the value is type(uint256).max, the whole
    /// balance of the EVC contract will be forwarded.
    /// @param data The encoded data which is called on the target contract.
    /// @return result The result of the call.
    function call(
        address targetContract,
        address onBehalfOfAccount,
        uint256 value,
        bytes calldata data
    ) external payable returns (bytes memory result);

    /// @notice For a given account, calls into one of the enabled collateral vaults from the currently enabled
    /// controller vault as per data encoded.
    /// @dev This function defers the account and vault status checks (it's a checks-deferrable call). If the outermost
    /// call ends, the account and vault status checks are performed.
    /// @dev This function can be used to interact with any contract while checks are deferred as long as the contract
    /// is enabled as a collateral of the account and the msg.sender is the only enabled controller of the account.
    /// @param targetCollateral The collateral address to be called.
    /// @param onBehalfOfAccount The address of the account for which it is checked whether msg.sender is authorized to
    /// act on behalf.
    /// @param value The amount of value to be forwarded with the call. If the value is type(uint256).max, the whole
    /// balance of the EVC contract will be forwarded.
    /// @param data The encoded data which is called on the target collateral.
    /// @return result The result of the call.
    function controlCollateral(
        address targetCollateral,
        address onBehalfOfAccount,
        uint256 value,
        bytes calldata data
    ) external payable returns (bytes memory result);

    /// @notice Executes multiple calls into the target contracts while checks deferred as per batch items provided.
    /// @dev This function defers the account and vault status checks (it's a checks-deferrable call). If the outermost
    /// call ends, the account and vault status checks are performed.
    /// @dev The authentication rules for each batch item are the same as for the call function.
    /// @param items An array of batch items to be executed.
    function batch(BatchItem[] calldata items) external payable;

    /// @notice Executes multiple calls into the target contracts while checks deferred as per batch items provided.
    /// @dev This function always reverts as it's only used for simulation purposes. This function cannot be called
    /// within a checks-deferrable call.
    /// @param items An array of batch items to be executed.
    function batchRevert(BatchItem[] calldata items) external payable;

    /// @notice Executes multiple calls into the target contracts while checks deferred as per batch items provided.
    /// @dev This function does not modify state and should only be used for simulation purposes. This function cannot
    /// be called within a checks-deferrable call.
    /// @param items An array of batch items to be executed.
    /// @return batchItemsResult An array of batch item results for each item.
    /// @return accountsStatusCheckResult An array of account status check results for each account.
    /// @return vaultsStatusCheckResult An array of vault status check results for each vault.
    function batchSimulation(BatchItem[] calldata items)
        external
        payable
        returns (
            BatchItemResult[] memory batchItemsResult,
            StatusCheckResult[] memory accountsStatusCheckResult,
            StatusCheckResult[] memory vaultsStatusCheckResult
        );

    /// @notice Retrieves the timestamp of the last successful account status check performed for a specific account.
    /// @dev This function reverts if the checks are in progress.
    /// @dev The account status check is considered to be successful if it calls into the selected controller vault and
    /// obtains expected magic value. This timestamp does not change if the account status is considered valid when no
    /// controller enabled. When consuming, one might need to ensure that the account status check is not deferred at
    /// the moment.
    /// @param account The address of the account for which the last status check timestamp is being queried.
    /// @return The timestamp of the last status check as a uint256.
    function getLastAccountStatusCheckTimestamp(address account) external view returns (uint256);

    /// @notice Checks whether the status check is deferred for a given account.
    /// @dev This function reverts if the checks are in progress.
    /// @param account The address of the account for which it is checked whether the status check is deferred.
    /// @return A boolean flag that indicates whether the status check is deferred or not.
    function isAccountStatusCheckDeferred(address account) external view returns (bool);

    /// @notice Checks the status of an account and reverts if it is not valid.
    /// @dev If checks deferred, the account is added to the set of accounts to be checked at the end of the outermost
    /// checks-deferrable call. There can be at most 10 unique accounts added to the set at a time. Account status
    /// check is performed by calling into the selected controller vault and passing the array of currently enabled
    /// collaterals. If controller is not selected, the account is always considered valid.
    /// @param account The address of the account to be checked.
    function requireAccountStatusCheck(address account) external payable;

    /// @notice Forgives previously deferred account status check.
    /// @dev Account address is removed from the set of addresses for which status checks are deferred. This function
    /// can only be called by the currently enabled controller of a given account. Depending on the vault
    /// implementation, may be needed in the liquidation flow.
    /// @param account The address of the account for which the status check is forgiven.
    function forgiveAccountStatusCheck(address account) external payable;

    /// @notice Checks whether the status check is deferred for a given vault.
    /// @dev This function reverts if the checks are in progress.
    /// @param vault The address of the vault for which it is checked whether the status check is deferred.
    /// @return A boolean flag that indicates whether the status check is deferred or not.
    function isVaultStatusCheckDeferred(address vault) external view returns (bool);

    /// @notice Checks the status of a vault and reverts if it is not valid.
    /// @dev If checks deferred, the vault is added to the set of vaults to be checked at the end of the outermost
    /// checks-deferrable call. There can be at most 10 unique vaults added to the set at a time. This function can
    /// only be called by the vault itself.
    function requireVaultStatusCheck() external payable;

    /// @notice Forgives previously deferred vault status check.
    /// @dev Vault address is removed from the set of addresses for which status checks are deferred. This function can
    /// only be called by the vault itself.
    function forgiveVaultStatusCheck() external payable;

    /// @notice Checks the status of an account and a vault and reverts if it is not valid.
    /// @dev If checks deferred, the account and the vault are added to the respective sets of accounts and vaults to be
    /// checked at the end of the outermost checks-deferrable call. Account status check is performed by calling into
    /// selected controller vault and passing the array of currently enabled collaterals. If controller is not selected,
    /// the account is always considered valid. This function can only be called by the vault itself.
    /// @param account The address of the account to be checked.
    function requireAccountAndVaultStatusCheck(address account) external payable;
}

// File: lib/ethereum-vault-connector/src/Errors.sol

pragma solidity ^0.8.0;



/// @title Errors
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice This contract implements the error messages for the Ethereum Vault Connector.
contract Errors {
    /// @notice Error for when caller is not authorized to perform an operation.
    error EVC_NotAuthorized();
    /// @notice Error for when no account has been authenticated to act on behalf of.
    error EVC_OnBehalfOfAccountNotAuthenticated();
    /// @notice Error for when an operator's to be set is no different from the current one.
    error EVC_InvalidOperatorStatus();
    /// @notice Error for when a nonce is invalid or already used.
    error EVC_InvalidNonce();
    /// @notice Error for when an address parameter passed is invalid.
    error EVC_InvalidAddress();
    /// @notice Error for when a timestamp parameter passed is expired.
    error EVC_InvalidTimestamp();
    /// @notice Error for when a value parameter passed is invalid or exceeds current balance.
    error EVC_InvalidValue();
    /// @notice Error for when data parameter passed is empty.
    error EVC_InvalidData();
    /// @notice Error for when an action is prohibited due to the lockdown mode.
    error EVC_LockdownMode();
    /// @notice Error for when permit execution is prohibited due to the permit disabled mode.
    error EVC_PermitDisabledMode();
    /// @notice Error for when checks are in progress and reentrancy is not allowed.
    error EVC_ChecksReentrancy();
    /// @notice Error for when control collateral is in progress and reentrancy is not allowed.
    error EVC_ControlCollateralReentrancy();
    /// @notice Error for when there is a different number of controllers enabled than expected.
    error EVC_ControllerViolation();
    /// @notice Error for when a simulation batch is nested within another simulation batch.
    error EVC_SimulationBatchNested();
    /// @notice Auxiliary error to pass simulation batch results.
    error EVC_RevertedBatchResult(
        IEVC.BatchItemResult[] batchItemsResult,
        IEVC.StatusCheckResult[] accountsStatusResult,
        IEVC.StatusCheckResult[] vaultsStatusResult
    );
    /// @notice Panic error for when simulation does not behave as expected. Should never be observed.
    error EVC_BatchPanic();
    /// @notice Error for when an empty or undefined error is thrown.
    error EVC_EmptyError();
}

// File: lib/ethereum-vault-connector/src/ExecutionContext.sol

pragma solidity ^0.8.0;

type EC is uint256;

/// @title ExecutionContext
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice This library provides functions for managing the execution context in the Ethereum Vault Connector.
/// @dev The execution context is a bit field that stores the following information:
/// @dev - on behalf of account - an account on behalf of which the currently executed operation is being performed
/// @dev - checks deferred flag - used to indicate whether checks are deferred
/// @dev - checks in progress flag - used to indicate that the account/vault status checks are in progress. This flag is
/// used to prevent re-entrancy.
/// @dev - control collateral in progress flag - used to indicate that the control collateral is in progress. This flag
/// is used to prevent re-entrancy.
/// @dev - operator authenticated flag - used to indicate that the currently executed operation is being performed by
/// the account operator
/// @dev - simulation flag - used to indicate that the currently executed batch call is a simulation
/// @dev - stamp - dummy value for optimization purposes
library ExecutionContext {
    uint256 internal constant ON_BEHALF_OF_ACCOUNT_MASK =
        0x000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    uint256 internal constant CHECKS_DEFERRED_MASK = 0x0000000000000000000000FF0000000000000000000000000000000000000000;
    uint256 internal constant CHECKS_IN_PROGRESS_MASK =
        0x00000000000000000000FF000000000000000000000000000000000000000000;
    uint256 internal constant CONTROL_COLLATERAL_IN_PROGRESS_LOCK_MASK =
        0x000000000000000000FF00000000000000000000000000000000000000000000;
    uint256 internal constant OPERATOR_AUTHENTICATED_MASK =
        0x0000000000000000FF0000000000000000000000000000000000000000000000;
    uint256 internal constant SIMULATION_MASK = 0x00000000000000FF000000000000000000000000000000000000000000000000;
    uint256 internal constant STAMP_OFFSET = 200;

    // None of the functions below modifies the state. All the functions operate on the copy
    // of the execution context and return its modified value as a result. In order to update
    // one should use the result of the function call as a new execution context value.

    function getOnBehalfOfAccount(EC self) internal pure returns (address result) {
        result = address(uint160(EC.unwrap(self) & ON_BEHALF_OF_ACCOUNT_MASK));
    }

    function setOnBehalfOfAccount(EC self, address account) internal pure returns (EC result) {
        result = EC.wrap((EC.unwrap(self) & ~ON_BEHALF_OF_ACCOUNT_MASK) | uint160(account));
    }

    function areChecksDeferred(EC self) internal pure returns (bool result) {
        result = EC.unwrap(self) & CHECKS_DEFERRED_MASK != 0;
    }

    function setChecksDeferred(EC self) internal pure returns (EC result) {
        result = EC.wrap(EC.unwrap(self) | CHECKS_DEFERRED_MASK);
    }

    function areChecksInProgress(EC self) internal pure returns (bool result) {
        result = EC.unwrap(self) & CHECKS_IN_PROGRESS_MASK != 0;
    }

    function setChecksInProgress(EC self) internal pure returns (EC result) {
        result = EC.wrap(EC.unwrap(self) | CHECKS_IN_PROGRESS_MASK);
    }

    function isControlCollateralInProgress(EC self) internal pure returns (bool result) {
        result = EC.unwrap(self) & CONTROL_COLLATERAL_IN_PROGRESS_LOCK_MASK != 0;
    }

    function setControlCollateralInProgress(EC self) internal pure returns (EC result) {
        result = EC.wrap(EC.unwrap(self) | CONTROL_COLLATERAL_IN_PROGRESS_LOCK_MASK);
    }

    function isOperatorAuthenticated(EC self) internal pure returns (bool result) {
        result = EC.unwrap(self) & OPERATOR_AUTHENTICATED_MASK != 0;
    }

    function setOperatorAuthenticated(EC self) internal pure returns (EC result) {
        result = EC.wrap(EC.unwrap(self) | OPERATOR_AUTHENTICATED_MASK);
    }

    function clearOperatorAuthenticated(EC self) internal pure returns (EC result) {
        result = EC.wrap(EC.unwrap(self) & ~OPERATOR_AUTHENTICATED_MASK);
    }

    function isSimulationInProgress(EC self) internal pure returns (bool result) {
        result = EC.unwrap(self) & SIMULATION_MASK != 0;
    }

    function setSimulationInProgress(EC self) internal pure returns (EC result) {
        result = EC.wrap(EC.unwrap(self) | SIMULATION_MASK);
    }
}

// File: lib/ethereum-vault-connector/src/TransientStorage.sol

pragma solidity ^0.8.0;




/// @title TransientStorage
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice This contract provides transient storage for the Ethereum Vault Connector.
/// @dev All the variables in this contract are considered transient meaning that their state does not change between
/// invocations.
abstract contract TransientStorage {
    using ExecutionContext for EC;
    using Set for SetStorage;

    enum SetType {
        Account,
        Vault
    }

    EC internal executionContext;
    SetStorage internal accountStatusChecks;
    SetStorage internal vaultStatusChecks;

    constructor() {
        // set the execution context to non-zero value to always keep the storage slot in non-zero state.
        // it allows for cheaper SSTOREs when the execution context is in its default state
        executionContext = EC.wrap(1 << ExecutionContext.STAMP_OFFSET);

        // there are two types of data that are stored using SetStorage type:
        // - the data that is transient in nature (accountStatusChecks and vaultStatusChecks)
        // - the data that is permanent (accountControllers and accountCollaterals from the EthereumVaultConnector
        // contract)

        // for the permanent data, there's no need to care that much about optimizations. each account has its two sets.
        // usually, an address inserted to either of them won't be removed within the same transaction. the only
        // optimization applied (directly in the Set contract) is that on the first element insertion, the stamp is set
        // to non-zero value to always keep that storage slot in non-zero state. it allows for cheaper SSTORE when an
        // element is inserted again after clearing the set.

        // for the transient data, an address insertion should be as cheap as possible. hence on construction, we store
        // dummy values for all the storage slots where the elements will be stored later on. it is important
        // considering that both accountStatusChecks and vaultStatusChecks are always cleared at the end of the
        // transaction. with dummy values set, the transition from zero to non-zero and back to zero will be
        // significantly cheaper than it would be otherwise
        accountStatusChecks.initialize();
        vaultStatusChecks.initialize();
    }
}

// File: lib/ethereum-vault-connector/src/interfaces/IVault.sol

pragma solidity >=0.8.0;

/// @title IVault
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice This interface defines the methods for the Vault for the purpose of integration with the Ethereum Vault
/// Connector.
interface IVault {
    /// @notice Disables a controller (this vault) for the authenticated account.
    /// @dev A controller is a vault that has been chosen for an account to have special control over account’s
    /// balances in the enabled collaterals vaults. User calls this function in order for the vault to disable itself
    /// for the account if the conditions are met (i.e. user has repaid debt in full). If the conditions are not met,
    /// the function reverts.
    function disableController() external;

    /// @notice Checks the status of an account.
    /// @dev This function must only deliberately revert if the account status is invalid. If this function reverts due
    /// to any other reason, it may render the account unusable with possibly no way to recover funds.
    /// @param account The address of the account to be checked.
    /// @param collaterals The array of enabled collateral addresses to be considered for the account status check.
    /// @return magicValue Must return the bytes4 magic value 0xb168c58f (which is a selector of this function) when
    /// account status is valid, or revert otherwise.
    function checkAccountStatus(
        address account,
        address[] calldata collaterals
    ) external view returns (bytes4 magicValue);

    /// @notice Checks the status of the vault.
    /// @dev This function must only deliberately revert if the vault status is invalid. If this function reverts due to
    /// any other reason, it may render some accounts unusable with possibly no way to recover funds.
    /// @return magicValue Must return the bytes4 magic value 0x4b3d1223 (which is a selector of this function) when
    /// account status is valid, or revert otherwise.
    function checkVaultStatus() external returns (bytes4 magicValue);
}

// File: lib/ethereum-vault-connector/src/interfaces/IERC1271.sol

// OpenZeppelin Contracts v4.4.1 (interfaces/IERC1271.sol)

pragma solidity >=0.8.0;

/// @dev Interface of the ERC1271 standard signature validation method for
/// contracts as defined in https://eips.ethereum.org/EIPS/eip-1271[ERC-1271].
interface IERC1271 {
    /// @dev Should return whether the signature provided is valid for the provided data
    /// @param hash Hash of the data to be signed
    /// @param signature Signature byte array associated with _data
    /// @return magicValue Must return the bytes4 magic value 0x1626ba7e (which is a selector of this function) when
    /// the signature is valid.
    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4 magicValue);
}

// File: lib/ethereum-vault-connector/src/EthereumVaultConnector.sol

pragma solidity ^0.8.0;










/// @title EthereumVaultConnector
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice This contract implements the Ethereum Vault Connector.
contract EthereumVaultConnector is Events, Errors, TransientStorage, IEVC {
    using ExecutionContext for EC;
    using Set for SetStorage;

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //                                       CONSTANTS                                           //
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /// @notice Name of the Ethereum Vault Connector.
    string public constant name = "Ethereum Vault Connector";

    uint160 internal constant ACCOUNT_ID_OFFSET = 8;
    bytes32 internal constant HASHED_NAME = keccak256(bytes(name));

    bytes32 internal constant TYPE_HASH =
        keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    bytes32 internal constant PERMIT_TYPEHASH = keccak256(
        "Permit(address signer,address sender,uint256 nonceNamespace,uint256 nonce,uint256 deadline,uint256 value,bytes data)"
    );

    uint256 internal immutable CACHED_CHAIN_ID;
    bytes32 internal immutable CACHED_DOMAIN_SEPARATOR;

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //                                        STORAGE                                            //
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // EVC implements controller isolation, meaning that unless in transient state, only one controller per account can
    // be enabled. However, this can lead to a suboptimal user experience. In the event a user wants to have multiple
    // controllers enabled, a separate wallet must be created and funded. Although there is nothing wrong with having
    // many accounts within the same wallet, this can be a bad experience. In order to improve on this, EVC supports
    // the concept of an owner that owns 256 accounts within EVC.

    // Every Ethereum address has 256 accounts in the EVC (including the primary account - called the owner).
    // Each account has an account ID from 0-255, where 0 is the owner account's ID. In order to compute the account
    // addresses, the account ID is treated as a uint256 and XORed (exclusive ORed) with the Ethereum address.
    // In order to record the owner of a group of 256 accounts, the EVC uses a definition of an address prefix.
    // An address prefix is a part of an address having the first 19 bytes common with any of the 256 account
    // addresses belonging to the same group.
    // account/152 -> prefix/152
    // To get an address prefix for the account, it's enough to take the account address and right shift it by 8 bits.

    // Yes, this reduces the security of addresses by 8 bits, but creating multiple addresses in the wallet also reduces
    // security: if somebody is trying to brute-force one of user's N>1 private keys, they have N times as many chances
    // of succeeding per guess. It has to be admitted that the EVC model is weaker because finding a private key for
    // an owner gives access to all accounts, but there is still a very comfortable security margin.

    // Internal data structure that stores the addressPrefix owner and mode flags
    struct OwnerStorage {
        // The addressPrefix owner
        address owner;
        // Flag indicating if the addressPrefix is in lockdown mode
        bool isLockdownMode;
        // Flag indicating if the permit function is disabled for the addressPrefix
        bool isPermitDisabledMode;
    }

    mapping(bytes19 addressPrefix => OwnerStorage) internal ownerLookup;

    mapping(bytes19 addressPrefix => mapping(address operator => uint256 operatorBitField)) internal operatorLookup;

    mapping(bytes19 addressPrefix => mapping(uint256 nonceNamespace => uint256 nonce)) internal nonceLookup;

    mapping(address account => SetStorage) internal accountCollaterals;

    mapping(address account => SetStorage) internal accountControllers;

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //                                CONSTRUCTOR, FALLBACKS                                     //
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor() {
        CACHED_CHAIN_ID = block.chainid;
        CACHED_DOMAIN_SEPARATOR = calculateDomainSeparator();
    }

    /// @notice Fallback function to receive Ether.
    receive() external payable {
        // only allows to receive value when checks are deferred
        if (!executionContext.areChecksDeferred()) {
            revert EVC_NotAuthorized();
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //                                       MODIFIERS                                           //
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /// @notice A modifier that allows only the address recorded as an owner of the address prefix to call the function.
    /// @dev The owner of an address prefix is an address that matches the address that has previously been recorded (or
    /// will be) as an owner in the ownerLookup.
    /// @param addressPrefix The address prefix for which it is checked whether the caller is the owner.
    modifier onlyOwner(bytes19 addressPrefix) {
        authenticateCaller({addressPrefix: addressPrefix, allowOperator: false, checkLockdownMode: false});

        _;
    }

    /// @notice A modifier that allows only the owner or an operator of the account to call the function.
    /// @dev The owner of an address prefix is an address that matches the address that has previously been recorded (or
    /// will be) as an owner in the ownerLookup. An operator of an account is an address that has been authorized by the
    /// owner of an account to perform operations on behalf of the owner.
    /// @param account The address of the account for which it is checked whether the caller is the owner or an
    /// operator.
    modifier onlyOwnerOrOperator(address account) {
        authenticateCaller({account: account, allowOperator: true, checkLockdownMode: true});

        _;
    }

    /// @notice A modifier checks whether msg.sender is the only controller for the account.
    /// @dev The controller cannot use permit function in conjunction with this modifier.
    modifier onlyController(address account) {
        {
            uint256 numOfControllers = accountControllers[account].numElements;
            address controller = accountControllers[account].firstElement;

            if (numOfControllers != 1) {
                revert EVC_ControllerViolation();
            }

            if (controller != msg.sender) {
                revert EVC_NotAuthorized();
            }
        }

        _;
    }

    /// @notice A modifier that verifies whether account or vault status checks are re-entered.
    modifier nonReentrantChecks() {
        if (executionContext.areChecksInProgress()) {
            revert EVC_ChecksReentrancy();
        }

        _;
    }

    /// @notice A modifier that verifies whether account or vault status checks are re-entered as well as checks for
    /// controlCollateral re-entrancy.
    modifier nonReentrantChecksAndControlCollateral() {
        {
            EC context = executionContext;

            if (context.areChecksInProgress()) {
                revert EVC_ChecksReentrancy();
            }

            if (context.isControlCollateralInProgress()) {
                revert EVC_ControlCollateralReentrancy();
            }
        }

        _;
    }

    /// @notice A modifier that verifies whether account or vault status checks are re-entered and sets the lock.
    /// @dev This modifier also clears the current account on behalf of which the operation is performed as it shouldn't
    /// be relied upon when the checks are in progress.
    modifier nonReentrantChecksAcquireLock() {
        EC contextCache = executionContext;

        if (contextCache.areChecksInProgress()) {
            revert EVC_ChecksReentrancy();
        }

        executionContext = contextCache.setChecksInProgress().setOnBehalfOfAccount(address(0));

        _;

        executionContext = contextCache;
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //                                   PUBLIC FUNCTIONS                                        //
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // Execution internals

    /// @inheritdoc IEVC
    function getRawExecutionContext() external view returns (uint256 context) {
        context = EC.unwrap(executionContext);
    }

    /// @inheritdoc IEVC
    function getCurrentOnBehalfOfAccount(address controllerToCheck)
        external
        view
        returns (address onBehalfOfAccount, bool controllerEnabled)
    {
        onBehalfOfAccount = executionContext.getOnBehalfOfAccount();

        // for safety, revert if no account has been authenticated
        if (onBehalfOfAccount == address(0)) {
            revert EVC_OnBehalfOfAccountNotAuthenticated();
        }

        controllerEnabled =
            controllerToCheck == address(0) ? false : accountControllers[onBehalfOfAccount].contains(controllerToCheck);
    }

    /// @inheritdoc IEVC
    function areChecksDeferred() external view returns (bool) {
        return executionContext.areChecksDeferred();
    }

    /// @inheritdoc IEVC
    function areChecksInProgress() external view returns (bool) {
        return executionContext.areChecksInProgress();
    }

    /// @inheritdoc IEVC
    function isControlCollateralInProgress() external view returns (bool) {
        return executionContext.isControlCollateralInProgress();
    }

    /// @inheritdoc IEVC
    function isOperatorAuthenticated() external view returns (bool) {
        return executionContext.isOperatorAuthenticated();
    }

    /// @inheritdoc IEVC
    function isSimulationInProgress() external view returns (bool) {
        return executionContext.isSimulationInProgress();
    }

    // Owners and operators

    /// @inheritdoc IEVC
    function haveCommonOwner(address account, address otherAccount) external pure returns (bool) {
        return haveCommonOwnerInternal(account, otherAccount);
    }

    /// @inheritdoc IEVC
    function getAddressPrefix(address account) external pure returns (bytes19) {
        return getAddressPrefixInternal(account);
    }

    /// @inheritdoc IEVC
    function getAccountOwner(address account) external view returns (address) {
        bytes19 addressPrefix = getAddressPrefixInternal(account);
        return ownerLookup[addressPrefix].owner;
    }

    /// @inheritdoc IEVC
    function isLockdownMode(bytes19 addressPrefix) external view returns (bool) {
        return ownerLookup[addressPrefix].isLockdownMode;
    }

    /// @inheritdoc IEVC
    function isPermitDisabledMode(bytes19 addressPrefix) external view returns (bool) {
        return ownerLookup[addressPrefix].isPermitDisabledMode;
    }

    /// @inheritdoc IEVC
    function getNonce(bytes19 addressPrefix, uint256 nonceNamespace) external view returns (uint256) {
        return nonceLookup[addressPrefix][nonceNamespace];
    }

    /// @inheritdoc IEVC
    function getOperator(bytes19 addressPrefix, address operator) external view returns (uint256) {
        return operatorLookup[addressPrefix][operator];
    }

    /// @inheritdoc IEVC
    function isAccountOperatorAuthorized(address account, address operator) external view returns (bool) {
        return isAccountOperatorAuthorizedInternal(account, operator);
    }

    /// @inheritdoc IEVC
    function setLockdownMode(bytes19 addressPrefix, bool enabled) public payable virtual onlyOwner(addressPrefix) {
        if (ownerLookup[addressPrefix].isLockdownMode != enabled) {
            // to increase user security, it is prohibited to disable this mode within the self-call of the permit
            // function or within a checks-deferrable call. to disable this mode, the setLockdownMode function must be
            // called directly
            if (!enabled && (executionContext.areChecksDeferred() || inPermitSelfCall())) {
                revert EVC_NotAuthorized();
            }

            ownerLookup[addressPrefix].isLockdownMode = enabled;
            emit LockdownModeStatus(addressPrefix, enabled);
        }
    }

    /// @inheritdoc IEVC
    function setPermitDisabledMode(
        bytes19 addressPrefix,
        bool enabled
    ) public payable virtual onlyOwner(addressPrefix) {
        if (ownerLookup[addressPrefix].isPermitDisabledMode != enabled) {
            // to increase user security, it is prohibited to disable this mode within the self-call of the permit
            // function (verified in the permit function) or within a checks-deferrable call. to disable this mode the
            // setPermitDisabledMode function must be called directly
            if (!enabled && executionContext.areChecksDeferred()) {
                revert EVC_NotAuthorized();
            }

            ownerLookup[addressPrefix].isPermitDisabledMode = enabled;
            emit PermitDisabledModeStatus(addressPrefix, enabled);
        }
    }

    /// @inheritdoc IEVC
    function setNonce(
        bytes19 addressPrefix,
        uint256 nonceNamespace,
        uint256 nonce
    ) public payable virtual onlyOwner(addressPrefix) {
        uint256 currentNonce = nonceLookup[addressPrefix][nonceNamespace];

        if (currentNonce >= nonce) {
            revert EVC_InvalidNonce();
        }

        nonceLookup[addressPrefix][nonceNamespace] = nonce;

        emit NonceStatus(addressPrefix, nonceNamespace, currentNonce, nonce);
    }

    /// @inheritdoc IEVC
    /// @dev Uses authenticateCaller() function instead of onlyOwner() modifier to authenticate and get the caller
    /// address at once.
    function setOperator(bytes19 addressPrefix, address operator, uint256 operatorBitField) public payable virtual {
        address msgSender =
            authenticateCaller({addressPrefix: addressPrefix, allowOperator: false, checkLockdownMode: false});

        // the operator can neither be the EVC nor can be one of 256 accounts of the owner
        if (operator == address(this) || haveCommonOwnerInternal(msgSender, operator)) {
            revert EVC_InvalidAddress();
        }

        if (operatorLookup[addressPrefix][operator] == operatorBitField) {
            revert EVC_InvalidOperatorStatus();
        } else {
            operatorLookup[addressPrefix][operator] = operatorBitField;

            emit OperatorStatus(addressPrefix, operator, operatorBitField);
        }
    }

    /// @inheritdoc IEVC
    /// @dev Uses authenticateCaller() function instead of onlyOwnerOrOperator() modifier to authenticate and get the
    /// caller address at once.
    function setAccountOperator(address account, address operator, bool authorized) public payable virtual {
        address msgSender = authenticateCaller({account: account, allowOperator: true, checkLockdownMode: false});
        bytes19 addressPrefix = getAddressPrefixInternal(account);

        // if the account and the caller have a common owner, the caller must be the owner. if the account and the
        // caller don't have a common owner, the caller must be an operator and the owner address is taken from the
        // storage. the caller authentication above guarantees that the account owner is already registered hence
        // non-zero
        address owner = haveCommonOwnerInternal(account, msgSender) ? msgSender : ownerLookup[addressPrefix].owner;

        // if it's an operator calling, it can only act for itself and must not be able to change other operators status
        if (owner != msgSender && operator != msgSender) {
            revert EVC_NotAuthorized();
        }

        // the operator can neither be the EVC nor can be one of 256 accounts of the owner
        if (operator == address(this) || haveCommonOwnerInternal(owner, operator)) {
            revert EVC_InvalidAddress();
        }

        // The bitMask defines which accounts the operator is authorized for. The bitMask is created from the account
        // number which is a number up to 2^8 in binary, or 256. 1 << (uint160(owner) ^ uint160(account)) transforms
        // that number in an 256-position binary array like 0...010...0, marking the account positionally in a uint256.
        uint256 bitMask = 1 << (uint160(owner) ^ uint160(account));

        // The operatorBitField is a 256-position binary array, where each 1 signals by position the account that the
        // operator is authorized for.
        uint256 oldOperatorBitField = operatorLookup[addressPrefix][operator];
        uint256 newOperatorBitField = authorized ? oldOperatorBitField | bitMask : oldOperatorBitField & ~bitMask;

        if (oldOperatorBitField == newOperatorBitField) {
            revert EVC_InvalidOperatorStatus();
        } else {
            operatorLookup[addressPrefix][operator] = newOperatorBitField;

            emit OperatorStatus(addressPrefix, operator, newOperatorBitField);
        }
    }

    // Collaterals management

    /// @inheritdoc IEVC
    function getCollaterals(address account) external view returns (address[] memory) {
        return accountCollaterals[account].get();
    }

    /// @inheritdoc IEVC
    function isCollateralEnabled(address account, address vault) external view returns (bool) {
        return accountCollaterals[account].contains(vault);
    }

    /// @inheritdoc IEVC
    function enableCollateral(
        address account,
        address vault
    ) public payable virtual nonReentrantChecksAndControlCollateral onlyOwnerOrOperator(account) {
        if (vault == address(this)) revert EVC_InvalidAddress();

        if (accountCollaterals[account].insert(vault)) {
            emit CollateralStatus(account, vault, true);
        }
        requireAccountStatusCheck(account);
    }

    /// @inheritdoc IEVC
    function disableCollateral(
        address account,
        address vault
    ) public payable virtual nonReentrantChecksAndControlCollateral onlyOwnerOrOperator(account) {
        if (accountCollaterals[account].remove(vault)) {
            emit CollateralStatus(account, vault, false);
        }
        requireAccountStatusCheck(account);
    }

    /// @inheritdoc IEVC
    function reorderCollaterals(
        address account,
        uint8 index1,
        uint8 index2
    ) public payable virtual nonReentrantChecksAndControlCollateral onlyOwnerOrOperator(account) {
        accountCollaterals[account].reorder(index1, index2);
        requireAccountStatusCheck(account);
    }

    // Controllers management

    /// @inheritdoc IEVC
    function getControllers(address account) external view returns (address[] memory) {
        return accountControllers[account].get();
    }

    /// @inheritdoc IEVC
    function isControllerEnabled(address account, address vault) external view returns (bool) {
        return accountControllers[account].contains(vault);
    }

    /// @inheritdoc IEVC
    function enableController(
        address account,
        address vault
    ) public payable virtual nonReentrantChecksAndControlCollateral onlyOwnerOrOperator(account) {
        if (vault == address(this)) revert EVC_InvalidAddress();

        if (accountControllers[account].insert(vault)) {
            emit ControllerStatus(account, vault, true);
        }
        requireAccountStatusCheck(account);
    }

    /// @inheritdoc IEVC
    function disableController(address account) public payable virtual nonReentrantChecksAndControlCollateral {
        if (accountControllers[account].remove(msg.sender)) {
            emit ControllerStatus(account, msg.sender, false);
        }
        requireAccountStatusCheck(account);
    }

    // Permit

    /// @inheritdoc IEVC
    function permit(
        address signer,
        address sender,
        uint256 nonceNamespace,
        uint256 nonce,
        uint256 deadline,
        uint256 value,
        bytes calldata data,
        bytes calldata signature
    ) public payable virtual nonReentrantChecksAndControlCollateral {
        // cannot be called within the self-call of the permit function; can occur for nested calls.
        // the permit function can be called only by the specified sender, unless address zero is specified in which
        // case anyone can call it
        if (inPermitSelfCall() || (sender != address(0) && sender != msg.sender)) {
            revert EVC_NotAuthorized();
        }

        if (signer == address(0) || !isSignerValid(signer)) {
            revert EVC_InvalidAddress();
        }

        bytes19 addressPrefix = getAddressPrefixInternal(signer);

        if (ownerLookup[addressPrefix].isPermitDisabledMode) {
            revert EVC_PermitDisabledMode();
        }

        {
            uint256 currentNonce = nonceLookup[addressPrefix][nonceNamespace];

            if (currentNonce == type(uint256).max || currentNonce != nonce) {
                revert EVC_InvalidNonce();
            }
        }

        if (deadline < block.timestamp) {
            revert EVC_InvalidTimestamp();
        }

        if (data.length == 0) {
            revert EVC_InvalidData();
        }

        bytes32 permitHash = getPermitHash(signer, sender, nonceNamespace, nonce, deadline, value, data);

        if (
            signer != recoverECDSASigner(permitHash, signature)
                && !isValidERC1271Signature(signer, permitHash, signature)
        ) {
            revert EVC_NotAuthorized();
        }

        unchecked {
            nonceLookup[addressPrefix][nonceNamespace] = nonce + 1;
        }

        emit NonceUsed(addressPrefix, nonceNamespace, nonce);

        // EVC address becomes the msg.sender for the duration this self-call, no authentication is required here.
        // the signer will be later on authenticated as per data, depending on the functions that will be called
        (bool success, bytes memory result) = callWithContextInternal(address(this), signer, value, data);

        if (!success) revertBytes(result);
    }

    // Calls forwarding

    /// @inheritdoc IEVC
    function call(
        address targetContract,
        address onBehalfOfAccount,
        uint256 value,
        bytes calldata data
    ) public payable virtual nonReentrantChecksAndControlCollateral returns (bytes memory result) {
        EC contextCache = executionContext;
        executionContext = contextCache.setChecksDeferred();

        bool success;
        (success, result) = callWithAuthenticationInternal(targetContract, onBehalfOfAccount, value, data);

        if (!success) revertBytes(result);

        restoreExecutionContext(contextCache);
    }

    /// @inheritdoc IEVC
    function controlCollateral(
        address targetCollateral,
        address onBehalfOfAccount,
        uint256 value,
        bytes calldata data
    )
        public
        payable
        virtual
        nonReentrantChecksAndControlCollateral
        onlyController(onBehalfOfAccount)
        returns (bytes memory result)
    {
        if (!accountCollaterals[onBehalfOfAccount].contains(targetCollateral)) {
            revert EVC_NotAuthorized();
        }

        EC contextCache = executionContext;
        executionContext = contextCache.setChecksDeferred().setControlCollateralInProgress();

        bool success;
        (success, result) = callWithContextInternal(targetCollateral, onBehalfOfAccount, value, data);

        if (!success) revertBytes(result);

        restoreExecutionContext(contextCache);
    }

    /// @inheritdoc IEVC
    function batch(BatchItem[] calldata items) public payable virtual nonReentrantChecksAndControlCollateral {
        EC contextCache = executionContext;
        executionContext = contextCache.setChecksDeferred();

        uint256 length = items.length;
        for (uint256 i; i < length; ++i) {
            BatchItem calldata item = items[i];
            (bool success, bytes memory result) =
                callWithAuthenticationInternal(item.targetContract, item.onBehalfOfAccount, item.value, item.data);

            if (!success) revertBytes(result);
        }

        restoreExecutionContext(contextCache);
    }

    // Simulations

    /// @inheritdoc IEVC
    function batchRevert(BatchItem[] calldata items) public payable virtual nonReentrantChecksAndControlCollateral {
        BatchItemResult[] memory batchItemsResult;
        StatusCheckResult[] memory accountsStatusCheckResult;
        StatusCheckResult[] memory vaultsStatusCheckResult;

        EC contextCache = executionContext;

        if (contextCache.areChecksDeferred()) {
            revert EVC_SimulationBatchNested();
        }

        executionContext = contextCache.setChecksDeferred().setSimulationInProgress();

        uint256 length = items.length;
        batchItemsResult = new BatchItemResult[](length);

        for (uint256 i; i < length; ++i) {
            BatchItem calldata item = items[i];
            (batchItemsResult[i].success, batchItemsResult[i].result) =
                callWithAuthenticationInternal(item.targetContract, item.onBehalfOfAccount, item.value, item.data);
        }

        executionContext = contextCache.setChecksInProgress().setOnBehalfOfAccount(address(0));

        accountsStatusCheckResult = checkStatusAllWithResult(SetType.Account);
        vaultsStatusCheckResult = checkStatusAllWithResult(SetType.Vault);

        executionContext = contextCache;

        revert EVC_RevertedBatchResult(batchItemsResult, accountsStatusCheckResult, vaultsStatusCheckResult);
    }

    /// @inheritdoc IEVC
    function batchSimulation(BatchItem[] calldata items)
        external
        payable
        virtual
        returns (
            BatchItemResult[] memory batchItemsResult,
            StatusCheckResult[] memory accountsStatusCheckResult,
            StatusCheckResult[] memory vaultsStatusCheckResult
        )
    {
        (bool success, bytes memory result) = address(this).delegatecall(abi.encodeCall(this.batchRevert, items));

        if (success) {
            revert EVC_BatchPanic();
        } else if (result.length < 4 || bytes4(result) != EVC_RevertedBatchResult.selector) {
            revertBytes(result);
        }

        assembly {
            let length := mload(result)
            // skip 4-byte EVC_RevertedBatchResult selector
            result := add(result, 4)
            // write new array length = original length - 4-byte selector
            // cannot underflow as we require result.length >= 4 above
            mstore(result, sub(length, 4))
        }

        (batchItemsResult, accountsStatusCheckResult, vaultsStatusCheckResult) =
            abi.decode(result, (BatchItemResult[], StatusCheckResult[], StatusCheckResult[]));
    }

    // Account Status Check

    /// @inheritdoc IEVC
    function getLastAccountStatusCheckTimestamp(address account) external view nonReentrantChecks returns (uint256) {
        return accountControllers[account].getMetadata();
    }

    /// @inheritdoc IEVC
    function isAccountStatusCheckDeferred(address account) external view nonReentrantChecks returns (bool) {
        return accountStatusChecks.contains(account);
    }

    /// @inheritdoc IEVC
    function requireAccountStatusCheck(address account) public payable virtual {
        if (executionContext.areChecksDeferred()) {
            accountStatusChecks.insert(account);
        } else {
            requireAccountStatusCheckInternalNonReentrantChecks(account);
        }
    }

    /// @inheritdoc IEVC
    function forgiveAccountStatusCheck(address account)
        public
        payable
        virtual
        nonReentrantChecksAcquireLock
        onlyController(account)
    {
        accountStatusChecks.remove(account);
    }

    // Vault Status Check

    /// @inheritdoc IEVC
    function isVaultStatusCheckDeferred(address vault) external view nonReentrantChecks returns (bool) {
        return vaultStatusChecks.contains(vault);
    }

    /// @inheritdoc IEVC
    function requireVaultStatusCheck() public payable virtual {
        if (executionContext.areChecksDeferred()) {
            vaultStatusChecks.insert(msg.sender);
        } else {
            requireVaultStatusCheckInternalNonReentrantChecks(msg.sender);
        }
    }

    /// @inheritdoc IEVC
    function forgiveVaultStatusCheck() public payable virtual nonReentrantChecksAcquireLock {
        vaultStatusChecks.remove(msg.sender);
    }

    /// @inheritdoc IEVC
    function requireAccountAndVaultStatusCheck(address account) public payable virtual {
        if (executionContext.areChecksDeferred()) {
            accountStatusChecks.insert(account);
            vaultStatusChecks.insert(msg.sender);
        } else {
            requireAccountStatusCheckInternalNonReentrantChecks(account);
            requireVaultStatusCheckInternalNonReentrantChecks(msg.sender);
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //                                  INTERNAL FUNCTIONS                                       //
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /// @notice Authenticates the caller of a function.
    /// @dev This function checks if the caller is the owner or an authorized operator of the account, and if the
    /// account is not in lockdown mode.
    /// @param account The account address to authenticate the caller against.
    /// @param allowOperator A boolean indicating if operators are allowed to authenticate as the caller.
    /// @param checkLockdownMode A boolean indicating if the function should check for lockdown mode on the account.
    /// @return The address of the authenticated caller.
    function authenticateCaller(
        address account,
        bool allowOperator,
        bool checkLockdownMode
    ) internal virtual returns (address) {
        bytes19 addressPrefix = getAddressPrefixInternal(account);
        address owner = ownerLookup[addressPrefix].owner;
        bool lockdownMode = ownerLookup[addressPrefix].isLockdownMode;
        address msgSender = _msgSender();
        bool authenticated = false;

        // check if the caller is the owner of the account
        if (haveCommonOwnerInternal(account, msgSender)) {
            // if the owner is not registered, register it
            if (owner == address(0)) {
                ownerLookup[addressPrefix].owner = owner = msgSender;
                emit OwnerRegistered(addressPrefix, msgSender);
                authenticated = true;
            } else if (owner == msgSender) {
                authenticated = true;
            }
        }

        // if the caller is not the owner, check if it is an operator if operators are allowed
        if (!authenticated && allowOperator && isAccountOperatorAuthorizedInternal(account, msgSender)) {
            authenticated = true;
        }

        // if the authenticated account is non-owner, prevent its account from being a smart contract
        if (authenticated && owner != account && account.code.length != 0) {
            authenticated = false;
        }

        // must revert if neither the owner nor the operator were authenticated
        if (!authenticated) {
            revert EVC_NotAuthorized();
        }

        // revert if the account is in lockdown mode unless the lockdown mode is not being checked
        if (checkLockdownMode && lockdownMode) {
            revert EVC_LockdownMode();
        }

        return msgSender;
    }

    /// @notice Authenticates the caller of a function.
    /// @dev This function either passes the address prefix owner address, if the address prefix owner is already
    /// registered, or converts the bytes19 address prefix into an account address which will belong to the owner when
    /// it's finally registered.
    /// @param addressPrefix The bytes19 address prefix to authenticate the caller against.
    /// @param allowOperator A boolean indicating if operators are allowed to authenticate as the caller.
    /// @param checkLockdownMode A boolean indicating if the function should check for lockdown mode on the account.
    /// @return The address of the authenticated caller.
    function authenticateCaller(
        bytes19 addressPrefix,
        bool allowOperator,
        bool checkLockdownMode
    ) internal virtual returns (address) {
        address owner = ownerLookup[addressPrefix].owner;

        return authenticateCaller({
            account: owner == address(0) ? address(uint160(uint152(addressPrefix)) << ACCOUNT_ID_OFFSET) : owner,
            allowOperator: allowOperator,
            checkLockdownMode: checkLockdownMode
        });
    }

    /// @notice Internal function to make a call to a target contract with a specific context.
    /// @dev This function sets the execution context for the duration of the call.
    /// @param targetContract The contract address to call.
    /// @param onBehalfOfAccount The account address on behalf of which the call is made.
    /// @param value The amount of value to send with the call.
    /// @param data The calldata to send with the call.
    function callWithContextInternal(
        address targetContract,
        address onBehalfOfAccount,
        uint256 value,
        bytes calldata data
    ) internal virtual returns (bool success, bytes memory result) {
        if (value == type(uint256).max) {
            value = address(this).balance;
        } else if (value > address(this).balance) {
            revert EVC_InvalidValue();
        }

        EC contextCache = executionContext;
        address msgSender = _msgSender();

        // set the onBehalfOfAccount in the execution context for the duration of the external call.
        // considering that the operatorAuthenticated is only meant to be observable by external
        // contracts, it is sufficient to set it here rather than in the authentication function.
        // apart from the usual scenario (when an owner operates on behalf of its account),
        // the operatorAuthenticated should be cleared when about to execute the permit self-call, when
        // target contract is equal to the msg.sender in call() and batch(), or when the controlCollateral is in
        // progress (in which case the operatorAuthenticated is not relevant)
        if (
            haveCommonOwnerInternal(onBehalfOfAccount, msgSender) || targetContract == msg.sender
                || targetContract == address(this) || contextCache.isControlCollateralInProgress()
        ) {
            executionContext = contextCache.setOnBehalfOfAccount(onBehalfOfAccount).clearOperatorAuthenticated();
        } else {
            executionContext = contextCache.setOnBehalfOfAccount(onBehalfOfAccount).setOperatorAuthenticated();
        }

        emit CallWithContext(
            msgSender, getAddressPrefixInternal(onBehalfOfAccount), onBehalfOfAccount, targetContract, bytes4(data)
        );

        (success, result) = targetContract.call{value: value}(data);

        executionContext = contextCache;
    }

    /// @notice Internal function to call a target contract with necessary authentication.
    /// @dev This function decides whether to use delegatecall or a regular call based on the target contract.
    /// If the target contract is this contract, it uses delegatecall to preserve msg.sender for authentication.
    /// Otherwise, it authenticates the caller if needed and proceeds with a regular call.
    /// @param targetContract The contract address to call.
    /// @param onBehalfOfAccount The account address on behalf of which the call is made.
    /// @param value The amount of value to send with the call.
    /// @param data The calldata to send with the call.
    /// @return success A boolean indicating if the call was successful.
    /// @return result The bytes returned from the call.
    function callWithAuthenticationInternal(
        address targetContract,
        address onBehalfOfAccount,
        uint256 value,
        bytes calldata data
    ) internal virtual returns (bool success, bytes memory result) {
        if (targetContract == address(this)) {
            if (onBehalfOfAccount != address(0)) {
                revert EVC_InvalidAddress();
            }

            if (value != 0) {
                revert EVC_InvalidValue();
            }

            // delegatecall is used here to preserve msg.sender in order to be able to perform authentication
            (success, result) = address(this).delegatecall(data);
        } else {
            // when the target contract is equal to the msg.sender, both in call() and batch(), authentication is not
            // required
            if (targetContract != msg.sender) {
                authenticateCaller({account: onBehalfOfAccount, allowOperator: true, checkLockdownMode: true});
            }

            (success, result) = callWithContextInternal(targetContract, onBehalfOfAccount, value, data);
        }
    }

    /// @notice Restores the execution context from a cached state.
    /// @dev This function restores the execution context to a previously cached state, performing necessary status
    /// checks if they are no longer deferred. If checks are no longer deferred, it sets the execution context to
    /// indicate checks are in progress and clears the 'on behalf of' account. It then performs status checks for both
    /// accounts and vaults before restoring the execution context to the cached state.
    /// @param contextCache The cached execution context to restore from.
    function restoreExecutionContext(EC contextCache) internal virtual {
        if (!contextCache.areChecksDeferred()) {
            executionContext = contextCache.setChecksInProgress().setOnBehalfOfAccount(address(0));

            checkStatusAll(SetType.Account);
            checkStatusAll(SetType.Vault);
        }

        executionContext = contextCache;
    }

    /// @notice Checks the status of an account internally.
    /// @dev This function first checks the number of controllers for the account. If there are no controllers enabled,
    /// it returns true immediately, indicating the account status is valid without further checks. If there is more
    /// than one controller, it reverts with an EVC_ControllerViolation error. For a single controller, it proceeds to
    /// call the controller to check the account status.
    /// @param account The account address to check the status for.
    /// @return isValid A boolean indicating if the account status is valid.
    /// @return result The bytes returned from the controller call, indicating the account status.
    function checkAccountStatusInternal(address account) internal virtual returns (bool isValid, bytes memory result) {
        SetStorage storage accountControllersStorage = accountControllers[account];
        uint256 numOfControllers = accountControllersStorage.numElements;
        address controller = accountControllersStorage.firstElement;
        uint8 stamp = accountControllersStorage.stamp;

        if (numOfControllers == 0) return (true, "");
        else if (numOfControllers > 1) return (false, abi.encodeWithSelector(EVC_ControllerViolation.selector));

        bool success;
        (success, result) = controller.staticcall(
            abi.encodeCall(IVault.checkAccountStatus, (account, accountCollaterals[account].get()))
        );

        isValid = success && result.length == 32
            && abi.decode(result, (bytes32)) == bytes32(IVault.checkAccountStatus.selector);

        if (isValid) {
            accountControllersStorage.numElements = uint8(numOfControllers);
            accountControllersStorage.firstElement = controller;
            accountControllersStorage.metadata = uint80(block.timestamp);
            accountControllersStorage.stamp = stamp;
        }

        emit AccountStatusCheck(account, controller);
    }

    function requireAccountStatusCheckInternal(address account) internal virtual {
        (bool isValid, bytes memory result) = checkAccountStatusInternal(account);

        if (!isValid) {
            revertBytes(result);
        }
    }

    function requireAccountStatusCheckInternalNonReentrantChecks(address account)
        internal
        virtual
        nonReentrantChecksAcquireLock
    {
        requireAccountStatusCheckInternal(account);
    }

    /// @notice Checks the status of a vault internally.
    /// @dev This function makes an external call to the vault to check its status.
    /// @param vault The address of the vault to check the status for.
    /// @return isValid A boolean indicating if the vault status is valid.
    /// @return result The bytes returned from the vault call, indicating the vault status.
    function checkVaultStatusInternal(address vault) internal virtual returns (bool isValid, bytes memory result) {
        bool success;
        (success, result) = vault.call(abi.encodeCall(IVault.checkVaultStatus, ()));

        isValid =
            success && result.length == 32 && abi.decode(result, (bytes32)) == bytes32(IVault.checkVaultStatus.selector);

        emit VaultStatusCheck(vault);
    }

    function requireVaultStatusCheckInternal(address vault) internal virtual {
        (bool isValid, bytes memory result) = checkVaultStatusInternal(vault);

        if (!isValid) {
            revertBytes(result);
        }
    }

    function requireVaultStatusCheckInternalNonReentrantChecks(address vault)
        internal
        virtual
        nonReentrantChecksAcquireLock
    {
        requireVaultStatusCheckInternal(vault);
    }

    /// @notice Checks the status of all entities in a set, either accounts or vaults, and clears the checks.
    /// @dev Iterates over either accountStatusChecks or vaultStatusChecks based on the setType and performs status
    /// checks.
    /// Clears the checks while performing them.
    /// @param setType The type of set to perform the status checks on, either accounts or vaults.
    function checkStatusAll(SetType setType) internal virtual {
        setType == SetType.Account
            ? accountStatusChecks.forEachAndClear(requireAccountStatusCheckInternal)
            : vaultStatusChecks.forEachAndClear(requireVaultStatusCheckInternal);
    }

    function checkStatusAllWithResult(SetType setType)
        internal
        virtual
        returns (StatusCheckResult[] memory checksResult)
    {
        bytes[] memory callbackResult = setType == SetType.Account
            ? accountStatusChecks.forEachAndClearWithResult(checkAccountStatusInternal)
            : vaultStatusChecks.forEachAndClearWithResult(checkVaultStatusInternal);

        uint256 length = callbackResult.length;
        checksResult = new StatusCheckResult[](length);

        for (uint256 i; i < length; ++i) {
            (address checkedAddress, bool isValid, bytes memory result) =
                abi.decode(callbackResult[i], (address, bool, bytes));
            checksResult[i] = StatusCheckResult({checkedAddress: checkedAddress, isValid: isValid, result: result});
        }
    }

    // Permit-related functions

    /// @notice Determines if the signer address is valid.
    /// @dev It's important to revisit this logic when deploying on chains other than the Ethereum mainnet. If new
    /// precompiles had been added to the Ethereum mainnet, the current implementation of the function would not be
    /// future-proof and would need to be updated.
    /// @param signer The address of the signer to validate.
    /// @return bool Returns true if the signer is valid, false otherwise.
    function isSignerValid(address signer) internal pure virtual returns (bool) {
        // not valid if the signer address falls into any of the precompiles/predeploys
        // addresses space (depends on the chain ID).
        return !haveCommonOwnerInternal(signer, address(0));
    }

    /// @notice Computes the permit hash for a given set of parameters.
    /// @dev This function generates a permit hash using EIP712 typed data signing.
    /// @param signer The address of the signer.
    /// @param nonceNamespace The namespace of the nonce.
    /// @param nonce The nonce value, ensuring permits are used once.
    /// @param deadline The time until when the permit is valid.
    /// @param value The value associated with the permit.
    /// @param data Calldata associated with the permit.
    /// @return permitHash The computed permit hash.
    function getPermitHash(
        address signer,
        address sender,
        uint256 nonceNamespace,
        uint256 nonce,
        uint256 deadline,
        uint256 value,
        bytes calldata data
    ) internal view returns (bytes32 permitHash) {
        bytes32 domainSeparator =
            block.chainid == CACHED_CHAIN_ID ? CACHED_DOMAIN_SEPARATOR : calculateDomainSeparator();

        bytes32 structHash = keccak256(
            abi.encode(PERMIT_TYPEHASH, signer, sender, nonceNamespace, nonce, deadline, value, keccak256(data))
        );

        // This code overwrites the two most significant bytes of the free memory pointer,
        // and restores them to 0 after
        assembly ("memory-safe") {
            mstore(0x00, "\x19\x01")
            mstore(0x02, domainSeparator)
            mstore(0x22, structHash)
            permitHash := keccak256(0x00, 0x42)
            mstore(0x22, 0)
        }
    }

    /// @notice Recovers the signer address from a hash and a signature.
    /// Based on:
    /// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/ECDSA.sol
    /// Note that the function returns zero address if the signature is invalid hence the result always has to be
    /// checked against address zero.
    /// @param hash The hash of the signed data.
    /// @param signature The signature to recover the signer from.
    /// @return signer The address of the signer, or the zero address if signature recovery fails.
    function recoverECDSASigner(bytes32 hash, bytes memory signature) internal pure returns (address signer) {
        if (signature.length != 65) return address(0);

        bytes32 r;
        bytes32 s;
        uint8 v;

        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        /// @solidity memory-safe-assembly
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return address(0);
        }

        // return the signer address (note that it might be zero address)
        signer = ecrecover(hash, v, r, s);
    }

    /// @notice Checks if a given signature is valid according to ERC-1271 standard.
    /// @dev This function is based on the implementation found in OpenZeppelin's SignatureChecker.
    /// See:
    /// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/SignatureChecker.sol
    /// It performs a static call to the signer's address with the signature data and checks if the returned value
    /// matches the expected valid signature selector.
    /// @param signer The address of the signer to validate the signature against.
    /// @param hash The hash of the data that was signed.
    /// @param signature The signature to validate.
    /// @return isValid True if the signature is valid according to ERC-1271, false otherwise.
    function isValidERC1271Signature(
        address signer,
        bytes32 hash,
        bytes memory signature
    ) internal view returns (bool isValid) {
        if (signer.code.length == 0) return false;

        (bool success, bytes memory result) =
            signer.staticcall(abi.encodeCall(IERC1271.isValidSignature, (hash, signature)));

        isValid = success && result.length == 32
            && abi.decode(result, (bytes32)) == bytes32(IERC1271.isValidSignature.selector);
    }

    /// @notice Calculates the EIP-712 domain separator for the contract.
    /// @return The calculated EIP-712 domain separator as a bytes32 value.
    function calculateDomainSeparator() internal view returns (bytes32) {
        return keccak256(abi.encode(TYPE_HASH, HASHED_NAME, block.chainid, address(this)));
    }

    // Auxiliary functions

    /// @notice Returns the message sender's address.
    /// @dev In the context of a permit self-call, it returns the account on behalf of which the call is made.
    /// Otherwise, it returns `msg.sender`.
    /// @return The address of the message sender or the account on behalf of which the call is made.
    function _msgSender() internal view virtual returns (address) {
        return inPermitSelfCall() ? executionContext.getOnBehalfOfAccount() : msg.sender;
    }

    /// @notice Checks if the contract is in the context of a permit self-call.
    /// @dev EVC can only be `msg.sender` during the self-call in the permit function.
    /// @return True if the current call is a self-call within the permit function, false otherwise.
    function inPermitSelfCall() internal view returns (bool) {
        return address(this) == msg.sender;
    }

    /// @notice Determines if two accounts have a common owner by comparing their address prefixes.
    /// @param account The first account address to compare.
    /// @param otherAccount The second account address to compare.
    /// @return result True if the accounts have a common owner, false otherwise.
    function haveCommonOwnerInternal(address account, address otherAccount) internal pure returns (bool result) {
        assembly {
            result := lt(xor(account, otherAccount), 0x100)
        }
    }

    /// @notice Computes the address prefix for a given account address.
    /// @dev The address prefix is derived by right-shifting the account address by 8 bits which effectively reduces the
    /// address size to 19 bytes.
    /// @param account The account address to compute the prefix for.
    /// @return The computed address prefix as a bytes19 value.
    function getAddressPrefixInternal(address account) internal pure returns (bytes19) {
        return bytes19(uint152(uint160(account) >> ACCOUNT_ID_OFFSET));
    }

    /// @notice Checks if an operator is authorized for a specific account.
    /// @dev Determines operator authorization by checking if the operator's bit is set in the operator's bit field for
    /// the account's address prefix. If the owner is not registered (address(0)), it implies the operator cannot be
    /// authorized, hence returns false. The bitMask is calculated by shifting 1 left by the XOR of the owner's and
    /// account's address, effectively checking the operator's authorization for the specific account.
    /// @param account The account address to check the operator authorization for.
    /// @param operator The operator address to check authorization status.
    /// @return isAuthorized True if the operator is authorized for the account, false otherwise.
    function isAccountOperatorAuthorizedInternal(
        address account,
        address operator
    ) internal view returns (bool isAuthorized) {
        bytes19 addressPrefix = getAddressPrefixInternal(account);
        address owner = ownerLookup[addressPrefix].owner;

        // if the owner is not registered yet, it means that the operator couldn't have been authorized
        if (owner == address(0)) return false;

        // The bitMask defines which accounts the operator is authorized for. The bitMask is created from the account
        // number which is a number up to 2^8 in binary, or 256. 1 << (uint160(owner) ^ uint160(account)) transforms
        // that number in an 256-position binary array like 0...010...0, marking the account positionally in a uint256.
        uint256 bitMask = 1 << (uint160(owner) ^ uint160(account));

        return operatorLookup[addressPrefix][operator] & bitMask != 0;
    }

    /// @notice Reverts the transaction with a custom error message if provided, otherwise reverts with a generic empty
    /// error.
    /// @param errMsg The custom error message to revert the transaction with.
    function revertBytes(bytes memory errMsg) internal pure {
        if (errMsg.length != 0) {
            assembly {
                revert(add(32, errMsg), mload(errMsg))
            }
        }
        revert EVC_EmptyError();
    }
}
