// Sources retrieved from Sourcify API v2.
// Deterministic best-effort flattening; original files are preserved under src/.

// File: lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol

// OpenZeppelin Contracts (last updated v5.1.0) (utils/structs/EnumerableSet.sol)
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

        assembly ("memory-safe") {
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

        assembly ("memory-safe") {
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

        assembly ("memory-safe") {
            result := store
        }

        return result;
    }
}

// File: lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/utils/structs/EnumerableMap.sol

// OpenZeppelin Contracts (last updated v5.1.0) (utils/structs/EnumerableMap.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableMap.js.

pragma solidity ^0.8.20;



/**
 * @dev Library for managing an enumerable variant of Solidity's
 * https://solidity.readthedocs.io/en/latest/types.html#mapping-types[`mapping`]
 * type.
 *
 * Maps have the following properties:
 *
 * - Entries are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Entries are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```solidity
 * contract Example {
 *     // Add the library methods
 *     using EnumerableMap for EnumerableMap.UintToAddressMap;
 *
 *     // Declare a set state variable
 *     EnumerableMap.UintToAddressMap private myMap;
 * }
 * ```
 *
 * The following map types are supported:
 *
 * - `uint256 -> address` (`UintToAddressMap`) since v3.0.0
 * - `address -> uint256` (`AddressToUintMap`) since v4.6.0
 * - `bytes32 -> bytes32` (`Bytes32ToBytes32Map`) since v4.6.0
 * - `uint256 -> uint256` (`UintToUintMap`) since v4.7.0
 * - `bytes32 -> uint256` (`Bytes32ToUintMap`) since v4.7.0
 * - `uint256 -> bytes32` (`UintToBytes32Map`) since v5.1.0
 * - `address -> address` (`AddressToAddressMap`) since v5.1.0
 * - `address -> bytes32` (`AddressToBytes32Map`) since v5.1.0
 * - `bytes32 -> address` (`Bytes32ToAddressMap`) since v5.1.0
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableMap, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableMap.
 * ====
 */
library EnumerableMap {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    // To implement this library for multiple types with as little code repetition as possible, we write it in
    // terms of a generic Map type with bytes32 keys and values. The Map implementation uses private functions,
    // and user-facing implementations such as `UintToAddressMap` are just wrappers around the underlying Map.
    // This means that we can only create new EnumerableMaps for types that fit in bytes32.

    /**
     * @dev Query for a nonexistent map key.
     */
    error EnumerableMapNonexistentKey(bytes32 key);

    struct Bytes32ToBytes32Map {
        // Storage of keys
        EnumerableSet.Bytes32Set _keys;
        mapping(bytes32 key => bytes32) _values;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(Bytes32ToBytes32Map storage map, bytes32 key, bytes32 value) internal returns (bool) {
        map._values[key] = value;
        return map._keys.add(key);
    }

    /**
     * @dev Removes a key-value pair from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(Bytes32ToBytes32Map storage map, bytes32 key) internal returns (bool) {
        delete map._values[key];
        return map._keys.remove(key);
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(Bytes32ToBytes32Map storage map, bytes32 key) internal view returns (bool) {
        return map._keys.contains(key);
    }

    /**
     * @dev Returns the number of key-value pairs in the map. O(1).
     */
    function length(Bytes32ToBytes32Map storage map) internal view returns (uint256) {
        return map._keys.length();
    }

    /**
     * @dev Returns the key-value pair stored at position `index` in the map. O(1).
     *
     * Note that there are no guarantees on the ordering of entries inside the
     * array, and it may change when more entries are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32ToBytes32Map storage map, uint256 index) internal view returns (bytes32 key, bytes32 value) {
        bytes32 atKey = map._keys.at(index);
        return (atKey, map._values[atKey]);
    }

    /**
     * @dev Tries to returns the value associated with `key`. O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(Bytes32ToBytes32Map storage map, bytes32 key) internal view returns (bool exists, bytes32 value) {
        bytes32 val = map._values[key];
        if (val == bytes32(0)) {
            return (contains(map, key), bytes32(0));
        } else {
            return (true, val);
        }
    }

    /**
     * @dev Returns the value associated with `key`. O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(Bytes32ToBytes32Map storage map, bytes32 key) internal view returns (bytes32) {
        bytes32 value = map._values[key];
        if (value == 0 && !contains(map, key)) {
            revert EnumerableMapNonexistentKey(key);
        }
        return value;
    }

    /**
     * @dev Return the an array containing all the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(Bytes32ToBytes32Map storage map) internal view returns (bytes32[] memory) {
        return map._keys.values();
    }

    // UintToUintMap

    struct UintToUintMap {
        Bytes32ToBytes32Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(UintToUintMap storage map, uint256 key, uint256 value) internal returns (bool) {
        return set(map._inner, bytes32(key), bytes32(value));
    }

    /**
     * @dev Removes a value from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(UintToUintMap storage map, uint256 key) internal returns (bool) {
        return remove(map._inner, bytes32(key));
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(UintToUintMap storage map, uint256 key) internal view returns (bool) {
        return contains(map._inner, bytes32(key));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(UintToUintMap storage map) internal view returns (uint256) {
        return length(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the map. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintToUintMap storage map, uint256 index) internal view returns (uint256 key, uint256 value) {
        (bytes32 atKey, bytes32 val) = at(map._inner, index);
        return (uint256(atKey), uint256(val));
    }

    /**
     * @dev Tries to returns the value associated with `key`. O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(UintToUintMap storage map, uint256 key) internal view returns (bool exists, uint256 value) {
        (bool success, bytes32 val) = tryGet(map._inner, bytes32(key));
        return (success, uint256(val));
    }

    /**
     * @dev Returns the value associated with `key`. O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(UintToUintMap storage map, uint256 key) internal view returns (uint256) {
        return uint256(get(map._inner, bytes32(key)));
    }

    /**
     * @dev Return the an array containing all the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(UintToUintMap storage map) internal view returns (uint256[] memory) {
        bytes32[] memory store = keys(map._inner);
        uint256[] memory result;

        assembly ("memory-safe") {
            result := store
        }

        return result;
    }

    // UintToAddressMap

    struct UintToAddressMap {
        Bytes32ToBytes32Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(UintToAddressMap storage map, uint256 key, address value) internal returns (bool) {
        return set(map._inner, bytes32(key), bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(UintToAddressMap storage map, uint256 key) internal returns (bool) {
        return remove(map._inner, bytes32(key));
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(UintToAddressMap storage map, uint256 key) internal view returns (bool) {
        return contains(map._inner, bytes32(key));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(UintToAddressMap storage map) internal view returns (uint256) {
        return length(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the map. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintToAddressMap storage map, uint256 index) internal view returns (uint256 key, address value) {
        (bytes32 atKey, bytes32 val) = at(map._inner, index);
        return (uint256(atKey), address(uint160(uint256(val))));
    }

    /**
     * @dev Tries to returns the value associated with `key`. O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(UintToAddressMap storage map, uint256 key) internal view returns (bool exists, address value) {
        (bool success, bytes32 val) = tryGet(map._inner, bytes32(key));
        return (success, address(uint160(uint256(val))));
    }

    /**
     * @dev Returns the value associated with `key`. O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {
        return address(uint160(uint256(get(map._inner, bytes32(key)))));
    }

    /**
     * @dev Return the an array containing all the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(UintToAddressMap storage map) internal view returns (uint256[] memory) {
        bytes32[] memory store = keys(map._inner);
        uint256[] memory result;

        assembly ("memory-safe") {
            result := store
        }

        return result;
    }

    // UintToBytes32Map

    struct UintToBytes32Map {
        Bytes32ToBytes32Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(UintToBytes32Map storage map, uint256 key, bytes32 value) internal returns (bool) {
        return set(map._inner, bytes32(key), value);
    }

    /**
     * @dev Removes a value from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(UintToBytes32Map storage map, uint256 key) internal returns (bool) {
        return remove(map._inner, bytes32(key));
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(UintToBytes32Map storage map, uint256 key) internal view returns (bool) {
        return contains(map._inner, bytes32(key));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(UintToBytes32Map storage map) internal view returns (uint256) {
        return length(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the map. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintToBytes32Map storage map, uint256 index) internal view returns (uint256 key, bytes32 value) {
        (bytes32 atKey, bytes32 val) = at(map._inner, index);
        return (uint256(atKey), val);
    }

    /**
     * @dev Tries to returns the value associated with `key`. O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(UintToBytes32Map storage map, uint256 key) internal view returns (bool exists, bytes32 value) {
        (bool success, bytes32 val) = tryGet(map._inner, bytes32(key));
        return (success, val);
    }

    /**
     * @dev Returns the value associated with `key`. O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(UintToBytes32Map storage map, uint256 key) internal view returns (bytes32) {
        return get(map._inner, bytes32(key));
    }

    /**
     * @dev Return the an array containing all the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(UintToBytes32Map storage map) internal view returns (uint256[] memory) {
        bytes32[] memory store = keys(map._inner);
        uint256[] memory result;

        assembly ("memory-safe") {
            result := store
        }

        return result;
    }

    // AddressToUintMap

    struct AddressToUintMap {
        Bytes32ToBytes32Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(AddressToUintMap storage map, address key, uint256 value) internal returns (bool) {
        return set(map._inner, bytes32(uint256(uint160(key))), bytes32(value));
    }

    /**
     * @dev Removes a value from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(AddressToUintMap storage map, address key) internal returns (bool) {
        return remove(map._inner, bytes32(uint256(uint160(key))));
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(AddressToUintMap storage map, address key) internal view returns (bool) {
        return contains(map._inner, bytes32(uint256(uint160(key))));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(AddressToUintMap storage map) internal view returns (uint256) {
        return length(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the map. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressToUintMap storage map, uint256 index) internal view returns (address key, uint256 value) {
        (bytes32 atKey, bytes32 val) = at(map._inner, index);
        return (address(uint160(uint256(atKey))), uint256(val));
    }

    /**
     * @dev Tries to returns the value associated with `key`. O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(AddressToUintMap storage map, address key) internal view returns (bool exists, uint256 value) {
        (bool success, bytes32 val) = tryGet(map._inner, bytes32(uint256(uint160(key))));
        return (success, uint256(val));
    }

    /**
     * @dev Returns the value associated with `key`. O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(AddressToUintMap storage map, address key) internal view returns (uint256) {
        return uint256(get(map._inner, bytes32(uint256(uint160(key)))));
    }

    /**
     * @dev Return the an array containing all the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(AddressToUintMap storage map) internal view returns (address[] memory) {
        bytes32[] memory store = keys(map._inner);
        address[] memory result;

        assembly ("memory-safe") {
            result := store
        }

        return result;
    }

    // AddressToAddressMap

    struct AddressToAddressMap {
        Bytes32ToBytes32Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(AddressToAddressMap storage map, address key, address value) internal returns (bool) {
        return set(map._inner, bytes32(uint256(uint160(key))), bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(AddressToAddressMap storage map, address key) internal returns (bool) {
        return remove(map._inner, bytes32(uint256(uint160(key))));
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(AddressToAddressMap storage map, address key) internal view returns (bool) {
        return contains(map._inner, bytes32(uint256(uint160(key))));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(AddressToAddressMap storage map) internal view returns (uint256) {
        return length(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the map. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressToAddressMap storage map, uint256 index) internal view returns (address key, address value) {
        (bytes32 atKey, bytes32 val) = at(map._inner, index);
        return (address(uint160(uint256(atKey))), address(uint160(uint256(val))));
    }

    /**
     * @dev Tries to returns the value associated with `key`. O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(AddressToAddressMap storage map, address key) internal view returns (bool exists, address value) {
        (bool success, bytes32 val) = tryGet(map._inner, bytes32(uint256(uint160(key))));
        return (success, address(uint160(uint256(val))));
    }

    /**
     * @dev Returns the value associated with `key`. O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(AddressToAddressMap storage map, address key) internal view returns (address) {
        return address(uint160(uint256(get(map._inner, bytes32(uint256(uint160(key)))))));
    }

    /**
     * @dev Return the an array containing all the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(AddressToAddressMap storage map) internal view returns (address[] memory) {
        bytes32[] memory store = keys(map._inner);
        address[] memory result;

        assembly ("memory-safe") {
            result := store
        }

        return result;
    }

    // AddressToBytes32Map

    struct AddressToBytes32Map {
        Bytes32ToBytes32Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(AddressToBytes32Map storage map, address key, bytes32 value) internal returns (bool) {
        return set(map._inner, bytes32(uint256(uint160(key))), value);
    }

    /**
     * @dev Removes a value from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(AddressToBytes32Map storage map, address key) internal returns (bool) {
        return remove(map._inner, bytes32(uint256(uint160(key))));
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(AddressToBytes32Map storage map, address key) internal view returns (bool) {
        return contains(map._inner, bytes32(uint256(uint160(key))));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(AddressToBytes32Map storage map) internal view returns (uint256) {
        return length(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the map. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressToBytes32Map storage map, uint256 index) internal view returns (address key, bytes32 value) {
        (bytes32 atKey, bytes32 val) = at(map._inner, index);
        return (address(uint160(uint256(atKey))), val);
    }

    /**
     * @dev Tries to returns the value associated with `key`. O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(AddressToBytes32Map storage map, address key) internal view returns (bool exists, bytes32 value) {
        (bool success, bytes32 val) = tryGet(map._inner, bytes32(uint256(uint160(key))));
        return (success, val);
    }

    /**
     * @dev Returns the value associated with `key`. O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(AddressToBytes32Map storage map, address key) internal view returns (bytes32) {
        return get(map._inner, bytes32(uint256(uint160(key))));
    }

    /**
     * @dev Return the an array containing all the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(AddressToBytes32Map storage map) internal view returns (address[] memory) {
        bytes32[] memory store = keys(map._inner);
        address[] memory result;

        assembly ("memory-safe") {
            result := store
        }

        return result;
    }

    // Bytes32ToUintMap

    struct Bytes32ToUintMap {
        Bytes32ToBytes32Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(Bytes32ToUintMap storage map, bytes32 key, uint256 value) internal returns (bool) {
        return set(map._inner, key, bytes32(value));
    }

    /**
     * @dev Removes a value from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(Bytes32ToUintMap storage map, bytes32 key) internal returns (bool) {
        return remove(map._inner, key);
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(Bytes32ToUintMap storage map, bytes32 key) internal view returns (bool) {
        return contains(map._inner, key);
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(Bytes32ToUintMap storage map) internal view returns (uint256) {
        return length(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the map. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32ToUintMap storage map, uint256 index) internal view returns (bytes32 key, uint256 value) {
        (bytes32 atKey, bytes32 val) = at(map._inner, index);
        return (atKey, uint256(val));
    }

    /**
     * @dev Tries to returns the value associated with `key`. O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(Bytes32ToUintMap storage map, bytes32 key) internal view returns (bool exists, uint256 value) {
        (bool success, bytes32 val) = tryGet(map._inner, key);
        return (success, uint256(val));
    }

    /**
     * @dev Returns the value associated with `key`. O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(Bytes32ToUintMap storage map, bytes32 key) internal view returns (uint256) {
        return uint256(get(map._inner, key));
    }

    /**
     * @dev Return the an array containing all the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(Bytes32ToUintMap storage map) internal view returns (bytes32[] memory) {
        bytes32[] memory store = keys(map._inner);
        bytes32[] memory result;

        assembly ("memory-safe") {
            result := store
        }

        return result;
    }

    // Bytes32ToAddressMap

    struct Bytes32ToAddressMap {
        Bytes32ToBytes32Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(Bytes32ToAddressMap storage map, bytes32 key, address value) internal returns (bool) {
        return set(map._inner, key, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(Bytes32ToAddressMap storage map, bytes32 key) internal returns (bool) {
        return remove(map._inner, key);
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(Bytes32ToAddressMap storage map, bytes32 key) internal view returns (bool) {
        return contains(map._inner, key);
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(Bytes32ToAddressMap storage map) internal view returns (uint256) {
        return length(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the map. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32ToAddressMap storage map, uint256 index) internal view returns (bytes32 key, address value) {
        (bytes32 atKey, bytes32 val) = at(map._inner, index);
        return (atKey, address(uint160(uint256(val))));
    }

    /**
     * @dev Tries to returns the value associated with `key`. O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(Bytes32ToAddressMap storage map, bytes32 key) internal view returns (bool exists, address value) {
        (bool success, bytes32 val) = tryGet(map._inner, key);
        return (success, address(uint160(uint256(val))));
    }

    /**
     * @dev Returns the value associated with `key`. O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(Bytes32ToAddressMap storage map, bytes32 key) internal view returns (address) {
        return address(uint160(uint256(get(map._inner, key))));
    }

    /**
     * @dev Return the an array containing all the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(Bytes32ToAddressMap storage map) internal view returns (bytes32[] memory) {
        bytes32[] memory store = keys(map._inner);
        bytes32[] memory result;

        assembly ("memory-safe") {
            result := store
        }

        return result;
    }
}

// File: lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
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
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
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
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// File: lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC20.sol)

pragma solidity ^0.8.20;

// File: lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/utils/Panic.sol

// OpenZeppelin Contracts (last updated v5.1.0) (utils/Panic.sol)

pragma solidity ^0.8.20;

/**
 * @dev Helper library for emitting standardized panic codes.
 *
 * ```solidity
 * contract Example {
 *      using Panic for uint256;
 *
 *      // Use any of the declared internal constants
 *      function foo() { Panic.GENERIC.panic(); }
 *
 *      // Alternatively
 *      function foo() { Panic.panic(Panic.GENERIC); }
 * }
 * ```
 *
 * Follows the list from https://github.com/ethereum/solidity/blob/v0.8.24/libsolutil/ErrorCodes.h[libsolutil].
 *
 * _Available since v5.1._
 */
// slither-disable-next-line unused-state
library Panic {
    /// @dev generic / unspecified error
    uint256 internal constant GENERIC = 0x00;
    /// @dev used by the assert() builtin
    uint256 internal constant ASSERT = 0x01;
    /// @dev arithmetic underflow or overflow
    uint256 internal constant UNDER_OVERFLOW = 0x11;
    /// @dev division or modulo by zero
    uint256 internal constant DIVISION_BY_ZERO = 0x12;
    /// @dev enum conversion error
    uint256 internal constant ENUM_CONVERSION_ERROR = 0x21;
    /// @dev invalid encoding in storage
    uint256 internal constant STORAGE_ENCODING_ERROR = 0x22;
    /// @dev empty array pop
    uint256 internal constant EMPTY_ARRAY_POP = 0x31;
    /// @dev array out of bounds access
    uint256 internal constant ARRAY_OUT_OF_BOUNDS = 0x32;
    /// @dev resource error (too large allocation or too large array)
    uint256 internal constant RESOURCE_ERROR = 0x41;
    /// @dev calling invalid internal function
    uint256 internal constant INVALID_INTERNAL_FUNCTION = 0x51;

    /// @dev Reverts with a panic code. Recommended to use with
    /// the internal constants with predefined codes.
    function panic(uint256 code) internal pure {
        assembly ("memory-safe") {
            mstore(0x00, 0x4e487b71)
            mstore(0x20, code)
            revert(0x1c, 0x24)
        }
    }
}

// File: lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/utils/math/SafeCast.sol

// OpenZeppelin Contracts (last updated v5.1.0) (utils/math/SafeCast.sol)
// This file was procedurally generated from scripts/generate/templates/SafeCast.js.

pragma solidity ^0.8.20;

/**
 * @dev Wrappers over Solidity's uintXX/intXX/bool casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeCast {
    /**
     * @dev Value doesn't fit in an uint of `bits` size.
     */
    error SafeCastOverflowedUintDowncast(uint8 bits, uint256 value);

    /**
     * @dev An int value doesn't fit in an uint of `bits` size.
     */
    error SafeCastOverflowedIntToUint(int256 value);

    /**
     * @dev Value doesn't fit in an int of `bits` size.
     */
    error SafeCastOverflowedIntDowncast(uint8 bits, int256 value);

    /**
     * @dev An uint value doesn't fit in an int of `bits` size.
     */
    error SafeCastOverflowedUintToInt(uint256 value);

    /**
     * @dev Returns the downcasted uint248 from uint256, reverting on
     * overflow (when the input is greater than largest uint248).
     *
     * Counterpart to Solidity's `uint248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     */
    function toUint248(uint256 value) internal pure returns (uint248) {
        if (value > type(uint248).max) {
            revert SafeCastOverflowedUintDowncast(248, value);
        }
        return uint248(value);
    }

    /**
     * @dev Returns the downcasted uint240 from uint256, reverting on
     * overflow (when the input is greater than largest uint240).
     *
     * Counterpart to Solidity's `uint240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     */
    function toUint240(uint256 value) internal pure returns (uint240) {
        if (value > type(uint240).max) {
            revert SafeCastOverflowedUintDowncast(240, value);
        }
        return uint240(value);
    }

    /**
     * @dev Returns the downcasted uint232 from uint256, reverting on
     * overflow (when the input is greater than largest uint232).
     *
     * Counterpart to Solidity's `uint232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     */
    function toUint232(uint256 value) internal pure returns (uint232) {
        if (value > type(uint232).max) {
            revert SafeCastOverflowedUintDowncast(232, value);
        }
        return uint232(value);
    }

    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        if (value > type(uint224).max) {
            revert SafeCastOverflowedUintDowncast(224, value);
        }
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint216 from uint256, reverting on
     * overflow (when the input is greater than largest uint216).
     *
     * Counterpart to Solidity's `uint216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     */
    function toUint216(uint256 value) internal pure returns (uint216) {
        if (value > type(uint216).max) {
            revert SafeCastOverflowedUintDowncast(216, value);
        }
        return uint216(value);
    }

    /**
     * @dev Returns the downcasted uint208 from uint256, reverting on
     * overflow (when the input is greater than largest uint208).
     *
     * Counterpart to Solidity's `uint208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     */
    function toUint208(uint256 value) internal pure returns (uint208) {
        if (value > type(uint208).max) {
            revert SafeCastOverflowedUintDowncast(208, value);
        }
        return uint208(value);
    }

    /**
     * @dev Returns the downcasted uint200 from uint256, reverting on
     * overflow (when the input is greater than largest uint200).
     *
     * Counterpart to Solidity's `uint200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     */
    function toUint200(uint256 value) internal pure returns (uint200) {
        if (value > type(uint200).max) {
            revert SafeCastOverflowedUintDowncast(200, value);
        }
        return uint200(value);
    }

    /**
     * @dev Returns the downcasted uint192 from uint256, reverting on
     * overflow (when the input is greater than largest uint192).
     *
     * Counterpart to Solidity's `uint192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     */
    function toUint192(uint256 value) internal pure returns (uint192) {
        if (value > type(uint192).max) {
            revert SafeCastOverflowedUintDowncast(192, value);
        }
        return uint192(value);
    }

    /**
     * @dev Returns the downcasted uint184 from uint256, reverting on
     * overflow (when the input is greater than largest uint184).
     *
     * Counterpart to Solidity's `uint184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     */
    function toUint184(uint256 value) internal pure returns (uint184) {
        if (value > type(uint184).max) {
            revert SafeCastOverflowedUintDowncast(184, value);
        }
        return uint184(value);
    }

    /**
     * @dev Returns the downcasted uint176 from uint256, reverting on
     * overflow (when the input is greater than largest uint176).
     *
     * Counterpart to Solidity's `uint176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     */
    function toUint176(uint256 value) internal pure returns (uint176) {
        if (value > type(uint176).max) {
            revert SafeCastOverflowedUintDowncast(176, value);
        }
        return uint176(value);
    }

    /**
     * @dev Returns the downcasted uint168 from uint256, reverting on
     * overflow (when the input is greater than largest uint168).
     *
     * Counterpart to Solidity's `uint168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     */
    function toUint168(uint256 value) internal pure returns (uint168) {
        if (value > type(uint168).max) {
            revert SafeCastOverflowedUintDowncast(168, value);
        }
        return uint168(value);
    }

    /**
     * @dev Returns the downcasted uint160 from uint256, reverting on
     * overflow (when the input is greater than largest uint160).
     *
     * Counterpart to Solidity's `uint160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     */
    function toUint160(uint256 value) internal pure returns (uint160) {
        if (value > type(uint160).max) {
            revert SafeCastOverflowedUintDowncast(160, value);
        }
        return uint160(value);
    }

    /**
     * @dev Returns the downcasted uint152 from uint256, reverting on
     * overflow (when the input is greater than largest uint152).
     *
     * Counterpart to Solidity's `uint152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     */
    function toUint152(uint256 value) internal pure returns (uint152) {
        if (value > type(uint152).max) {
            revert SafeCastOverflowedUintDowncast(152, value);
        }
        return uint152(value);
    }

    /**
     * @dev Returns the downcasted uint144 from uint256, reverting on
     * overflow (when the input is greater than largest uint144).
     *
     * Counterpart to Solidity's `uint144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     */
    function toUint144(uint256 value) internal pure returns (uint144) {
        if (value > type(uint144).max) {
            revert SafeCastOverflowedUintDowncast(144, value);
        }
        return uint144(value);
    }

    /**
     * @dev Returns the downcasted uint136 from uint256, reverting on
     * overflow (when the input is greater than largest uint136).
     *
     * Counterpart to Solidity's `uint136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     */
    function toUint136(uint256 value) internal pure returns (uint136) {
        if (value > type(uint136).max) {
            revert SafeCastOverflowedUintDowncast(136, value);
        }
        return uint136(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        if (value > type(uint128).max) {
            revert SafeCastOverflowedUintDowncast(128, value);
        }
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint120 from uint256, reverting on
     * overflow (when the input is greater than largest uint120).
     *
     * Counterpart to Solidity's `uint120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     */
    function toUint120(uint256 value) internal pure returns (uint120) {
        if (value > type(uint120).max) {
            revert SafeCastOverflowedUintDowncast(120, value);
        }
        return uint120(value);
    }

    /**
     * @dev Returns the downcasted uint112 from uint256, reverting on
     * overflow (when the input is greater than largest uint112).
     *
     * Counterpart to Solidity's `uint112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     */
    function toUint112(uint256 value) internal pure returns (uint112) {
        if (value > type(uint112).max) {
            revert SafeCastOverflowedUintDowncast(112, value);
        }
        return uint112(value);
    }

    /**
     * @dev Returns the downcasted uint104 from uint256, reverting on
     * overflow (when the input is greater than largest uint104).
     *
     * Counterpart to Solidity's `uint104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     */
    function toUint104(uint256 value) internal pure returns (uint104) {
        if (value > type(uint104).max) {
            revert SafeCastOverflowedUintDowncast(104, value);
        }
        return uint104(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        if (value > type(uint96).max) {
            revert SafeCastOverflowedUintDowncast(96, value);
        }
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint88 from uint256, reverting on
     * overflow (when the input is greater than largest uint88).
     *
     * Counterpart to Solidity's `uint88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     */
    function toUint88(uint256 value) internal pure returns (uint88) {
        if (value > type(uint88).max) {
            revert SafeCastOverflowedUintDowncast(88, value);
        }
        return uint88(value);
    }

    /**
     * @dev Returns the downcasted uint80 from uint256, reverting on
     * overflow (when the input is greater than largest uint80).
     *
     * Counterpart to Solidity's `uint80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     */
    function toUint80(uint256 value) internal pure returns (uint80) {
        if (value > type(uint80).max) {
            revert SafeCastOverflowedUintDowncast(80, value);
        }
        return uint80(value);
    }

    /**
     * @dev Returns the downcasted uint72 from uint256, reverting on
     * overflow (when the input is greater than largest uint72).
     *
     * Counterpart to Solidity's `uint72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     */
    function toUint72(uint256 value) internal pure returns (uint72) {
        if (value > type(uint72).max) {
            revert SafeCastOverflowedUintDowncast(72, value);
        }
        return uint72(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        if (value > type(uint64).max) {
            revert SafeCastOverflowedUintDowncast(64, value);
        }
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint56 from uint256, reverting on
     * overflow (when the input is greater than largest uint56).
     *
     * Counterpart to Solidity's `uint56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     */
    function toUint56(uint256 value) internal pure returns (uint56) {
        if (value > type(uint56).max) {
            revert SafeCastOverflowedUintDowncast(56, value);
        }
        return uint56(value);
    }

    /**
     * @dev Returns the downcasted uint48 from uint256, reverting on
     * overflow (when the input is greater than largest uint48).
     *
     * Counterpart to Solidity's `uint48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     */
    function toUint48(uint256 value) internal pure returns (uint48) {
        if (value > type(uint48).max) {
            revert SafeCastOverflowedUintDowncast(48, value);
        }
        return uint48(value);
    }

    /**
     * @dev Returns the downcasted uint40 from uint256, reverting on
     * overflow (when the input is greater than largest uint40).
     *
     * Counterpart to Solidity's `uint40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     */
    function toUint40(uint256 value) internal pure returns (uint40) {
        if (value > type(uint40).max) {
            revert SafeCastOverflowedUintDowncast(40, value);
        }
        return uint40(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        if (value > type(uint32).max) {
            revert SafeCastOverflowedUintDowncast(32, value);
        }
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint24 from uint256, reverting on
     * overflow (when the input is greater than largest uint24).
     *
     * Counterpart to Solidity's `uint24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     */
    function toUint24(uint256 value) internal pure returns (uint24) {
        if (value > type(uint24).max) {
            revert SafeCastOverflowedUintDowncast(24, value);
        }
        return uint24(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        if (value > type(uint16).max) {
            revert SafeCastOverflowedUintDowncast(16, value);
        }
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        if (value > type(uint8).max) {
            revert SafeCastOverflowedUintDowncast(8, value);
        }
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        if (value < 0) {
            revert SafeCastOverflowedIntToUint(value);
        }
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int248 from int256, reverting on
     * overflow (when the input is less than smallest int248 or
     * greater than largest int248).
     *
     * Counterpart to Solidity's `int248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     */
    function toInt248(int256 value) internal pure returns (int248 downcasted) {
        downcasted = int248(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(248, value);
        }
    }

    /**
     * @dev Returns the downcasted int240 from int256, reverting on
     * overflow (when the input is less than smallest int240 or
     * greater than largest int240).
     *
     * Counterpart to Solidity's `int240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     */
    function toInt240(int256 value) internal pure returns (int240 downcasted) {
        downcasted = int240(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(240, value);
        }
    }

    /**
     * @dev Returns the downcasted int232 from int256, reverting on
     * overflow (when the input is less than smallest int232 or
     * greater than largest int232).
     *
     * Counterpart to Solidity's `int232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     */
    function toInt232(int256 value) internal pure returns (int232 downcasted) {
        downcasted = int232(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(232, value);
        }
    }

    /**
     * @dev Returns the downcasted int224 from int256, reverting on
     * overflow (when the input is less than smallest int224 or
     * greater than largest int224).
     *
     * Counterpart to Solidity's `int224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toInt224(int256 value) internal pure returns (int224 downcasted) {
        downcasted = int224(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(224, value);
        }
    }

    /**
     * @dev Returns the downcasted int216 from int256, reverting on
     * overflow (when the input is less than smallest int216 or
     * greater than largest int216).
     *
     * Counterpart to Solidity's `int216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     */
    function toInt216(int256 value) internal pure returns (int216 downcasted) {
        downcasted = int216(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(216, value);
        }
    }

    /**
     * @dev Returns the downcasted int208 from int256, reverting on
     * overflow (when the input is less than smallest int208 or
     * greater than largest int208).
     *
     * Counterpart to Solidity's `int208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     */
    function toInt208(int256 value) internal pure returns (int208 downcasted) {
        downcasted = int208(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(208, value);
        }
    }

    /**
     * @dev Returns the downcasted int200 from int256, reverting on
     * overflow (when the input is less than smallest int200 or
     * greater than largest int200).
     *
     * Counterpart to Solidity's `int200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     */
    function toInt200(int256 value) internal pure returns (int200 downcasted) {
        downcasted = int200(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(200, value);
        }
    }

    /**
     * @dev Returns the downcasted int192 from int256, reverting on
     * overflow (when the input is less than smallest int192 or
     * greater than largest int192).
     *
     * Counterpart to Solidity's `int192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     */
    function toInt192(int256 value) internal pure returns (int192 downcasted) {
        downcasted = int192(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(192, value);
        }
    }

    /**
     * @dev Returns the downcasted int184 from int256, reverting on
     * overflow (when the input is less than smallest int184 or
     * greater than largest int184).
     *
     * Counterpart to Solidity's `int184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     */
    function toInt184(int256 value) internal pure returns (int184 downcasted) {
        downcasted = int184(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(184, value);
        }
    }

    /**
     * @dev Returns the downcasted int176 from int256, reverting on
     * overflow (when the input is less than smallest int176 or
     * greater than largest int176).
     *
     * Counterpart to Solidity's `int176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     */
    function toInt176(int256 value) internal pure returns (int176 downcasted) {
        downcasted = int176(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(176, value);
        }
    }

    /**
     * @dev Returns the downcasted int168 from int256, reverting on
     * overflow (when the input is less than smallest int168 or
     * greater than largest int168).
     *
     * Counterpart to Solidity's `int168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     */
    function toInt168(int256 value) internal pure returns (int168 downcasted) {
        downcasted = int168(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(168, value);
        }
    }

    /**
     * @dev Returns the downcasted int160 from int256, reverting on
     * overflow (when the input is less than smallest int160 or
     * greater than largest int160).
     *
     * Counterpart to Solidity's `int160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     */
    function toInt160(int256 value) internal pure returns (int160 downcasted) {
        downcasted = int160(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(160, value);
        }
    }

    /**
     * @dev Returns the downcasted int152 from int256, reverting on
     * overflow (when the input is less than smallest int152 or
     * greater than largest int152).
     *
     * Counterpart to Solidity's `int152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     */
    function toInt152(int256 value) internal pure returns (int152 downcasted) {
        downcasted = int152(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(152, value);
        }
    }

    /**
     * @dev Returns the downcasted int144 from int256, reverting on
     * overflow (when the input is less than smallest int144 or
     * greater than largest int144).
     *
     * Counterpart to Solidity's `int144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     */
    function toInt144(int256 value) internal pure returns (int144 downcasted) {
        downcasted = int144(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(144, value);
        }
    }

    /**
     * @dev Returns the downcasted int136 from int256, reverting on
     * overflow (when the input is less than smallest int136 or
     * greater than largest int136).
     *
     * Counterpart to Solidity's `int136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     */
    function toInt136(int256 value) internal pure returns (int136 downcasted) {
        downcasted = int136(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(136, value);
        }
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toInt128(int256 value) internal pure returns (int128 downcasted) {
        downcasted = int128(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(128, value);
        }
    }

    /**
     * @dev Returns the downcasted int120 from int256, reverting on
     * overflow (when the input is less than smallest int120 or
     * greater than largest int120).
     *
     * Counterpart to Solidity's `int120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     */
    function toInt120(int256 value) internal pure returns (int120 downcasted) {
        downcasted = int120(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(120, value);
        }
    }

    /**
     * @dev Returns the downcasted int112 from int256, reverting on
     * overflow (when the input is less than smallest int112 or
     * greater than largest int112).
     *
     * Counterpart to Solidity's `int112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     */
    function toInt112(int256 value) internal pure returns (int112 downcasted) {
        downcasted = int112(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(112, value);
        }
    }

    /**
     * @dev Returns the downcasted int104 from int256, reverting on
     * overflow (when the input is less than smallest int104 or
     * greater than largest int104).
     *
     * Counterpart to Solidity's `int104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     */
    function toInt104(int256 value) internal pure returns (int104 downcasted) {
        downcasted = int104(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(104, value);
        }
    }

    /**
     * @dev Returns the downcasted int96 from int256, reverting on
     * overflow (when the input is less than smallest int96 or
     * greater than largest int96).
     *
     * Counterpart to Solidity's `int96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toInt96(int256 value) internal pure returns (int96 downcasted) {
        downcasted = int96(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(96, value);
        }
    }

    /**
     * @dev Returns the downcasted int88 from int256, reverting on
     * overflow (when the input is less than smallest int88 or
     * greater than largest int88).
     *
     * Counterpart to Solidity's `int88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     */
    function toInt88(int256 value) internal pure returns (int88 downcasted) {
        downcasted = int88(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(88, value);
        }
    }

    /**
     * @dev Returns the downcasted int80 from int256, reverting on
     * overflow (when the input is less than smallest int80 or
     * greater than largest int80).
     *
     * Counterpart to Solidity's `int80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     */
    function toInt80(int256 value) internal pure returns (int80 downcasted) {
        downcasted = int80(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(80, value);
        }
    }

    /**
     * @dev Returns the downcasted int72 from int256, reverting on
     * overflow (when the input is less than smallest int72 or
     * greater than largest int72).
     *
     * Counterpart to Solidity's `int72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     */
    function toInt72(int256 value) internal pure returns (int72 downcasted) {
        downcasted = int72(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(72, value);
        }
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toInt64(int256 value) internal pure returns (int64 downcasted) {
        downcasted = int64(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(64, value);
        }
    }

    /**
     * @dev Returns the downcasted int56 from int256, reverting on
     * overflow (when the input is less than smallest int56 or
     * greater than largest int56).
     *
     * Counterpart to Solidity's `int56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     */
    function toInt56(int256 value) internal pure returns (int56 downcasted) {
        downcasted = int56(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(56, value);
        }
    }

    /**
     * @dev Returns the downcasted int48 from int256, reverting on
     * overflow (when the input is less than smallest int48 or
     * greater than largest int48).
     *
     * Counterpart to Solidity's `int48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     */
    function toInt48(int256 value) internal pure returns (int48 downcasted) {
        downcasted = int48(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(48, value);
        }
    }

    /**
     * @dev Returns the downcasted int40 from int256, reverting on
     * overflow (when the input is less than smallest int40 or
     * greater than largest int40).
     *
     * Counterpart to Solidity's `int40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     */
    function toInt40(int256 value) internal pure returns (int40 downcasted) {
        downcasted = int40(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(40, value);
        }
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toInt32(int256 value) internal pure returns (int32 downcasted) {
        downcasted = int32(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(32, value);
        }
    }

    /**
     * @dev Returns the downcasted int24 from int256, reverting on
     * overflow (when the input is less than smallest int24 or
     * greater than largest int24).
     *
     * Counterpart to Solidity's `int24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     */
    function toInt24(int256 value) internal pure returns (int24 downcasted) {
        downcasted = int24(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(24, value);
        }
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toInt16(int256 value) internal pure returns (int16 downcasted) {
        downcasted = int16(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(16, value);
        }
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     */
    function toInt8(int256 value) internal pure returns (int8 downcasted) {
        downcasted = int8(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(8, value);
        }
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        if (value > uint256(type(int256).max)) {
            revert SafeCastOverflowedUintToInt(value);
        }
        return int256(value);
    }

    /**
     * @dev Cast a boolean (false or true) to a uint256 (0 or 1) with no jump.
     */
    function toUint(bool b) internal pure returns (uint256 u) {
        assembly ("memory-safe") {
            u := iszero(iszero(b))
        }
    }
}

// File: lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/utils/math/Math.sol

// OpenZeppelin Contracts (last updated v5.1.0) (utils/math/Math.sol)

pragma solidity ^0.8.20;




/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Floor, // Toward negative infinity
        Ceil, // Toward positive infinity
        Trunc, // Toward zero
        Expand // Away from zero
    }

    /**
     * @dev Returns the addition of two unsigned integers, with an success flag (no overflow).
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an success flag (no overflow).
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an success flag (no overflow).
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a success flag (no division by zero).
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a success flag (no division by zero).
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Branchless ternary evaluation for `a ? b : c`. Gas costs are constant.
     *
     * IMPORTANT: This function may reduce bytecode size and consume less gas when used standalone.
     * However, the compiler may optimize Solidity ternary operations (i.e. `a ? b : c`) to only compute
     * one branch when needed, making this function more expensive.
     */
    function ternary(bool condition, uint256 a, uint256 b) internal pure returns (uint256) {
        unchecked {
            // branchless ternary works because:
            // b ^ (a ^ b) == a
            // b ^ 0 == b
            return b ^ ((a ^ b) * SafeCast.toUint(condition));
        }
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return ternary(a > b, a, b);
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return ternary(a < b, a, b);
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds towards infinity instead
     * of rounding towards zero.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b == 0) {
            // Guarantee the same behavior as in a regular Solidity division.
            Panic.panic(Panic.DIVISION_BY_ZERO);
        }

        // The following calculation ensures accurate ceiling division without overflow.
        // Since a is non-zero, (a - 1) / b will not overflow.
        // The largest possible result occurs when (a - 1) / b is type(uint256).max,
        // but the largest value we can obtain is type(uint256).max - 1, which happens
        // when a = type(uint256).max and b = 1.
        unchecked {
            return SafeCast.toUint(a > 0) * ((a - 1) / b + 1);
        }
    }

    /**
     * @dev Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or
     * denominator == 0.
     *
     * Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv) with further edits by
     * Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2²⁵⁶ and mod 2²⁵⁶ - 1, then use
            // the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2²⁵⁶ + prod0.
            uint256 prod0 = x * y; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2²⁵⁶. Also prevents denominator == 0.
            if (denominator <= prod1) {
                Panic.panic(ternary(denominator == 0, Panic.DIVISION_BY_ZERO, Panic.UNDER_OVERFLOW));
            }

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator.
            // Always >= 1. See https://cs.stackexchange.com/q/138556/92363.

            uint256 twos = denominator & (0 - denominator);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2²⁵⁶ / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2²⁵⁶. Now that denominator is an odd number, it has an inverse modulo 2²⁵⁶ such
            // that denominator * inv ≡ 1 mod 2²⁵⁶. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv ≡ 1 mod 2⁴.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also
            // works in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2⁸
            inverse *= 2 - denominator * inverse; // inverse mod 2¹⁶
            inverse *= 2 - denominator * inverse; // inverse mod 2³²
            inverse *= 2 - denominator * inverse; // inverse mod 2⁶⁴
            inverse *= 2 - denominator * inverse; // inverse mod 2¹²⁸
            inverse *= 2 - denominator * inverse; // inverse mod 2²⁵⁶

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2²⁵⁶. Since the preconditions guarantee that the outcome is
            // less than 2²⁵⁶, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @dev Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        return mulDiv(x, y, denominator) + SafeCast.toUint(unsignedRoundsUp(rounding) && mulmod(x, y, denominator) > 0);
    }

    /**
     * @dev Calculate the modular multiplicative inverse of a number in Z/nZ.
     *
     * If n is a prime, then Z/nZ is a field. In that case all elements are inversible, except 0.
     * If n is not a prime, then Z/nZ is not a field, and some elements might not be inversible.
     *
     * If the input value is not inversible, 0 is returned.
     *
     * NOTE: If you know for sure that n is (big) a prime, it may be cheaper to use Fermat's little theorem and get the
     * inverse using `Math.modExp(a, n - 2, n)`. See {invModPrime}.
     */
    function invMod(uint256 a, uint256 n) internal pure returns (uint256) {
        unchecked {
            if (n == 0) return 0;

            // The inverse modulo is calculated using the Extended Euclidean Algorithm (iterative version)
            // Used to compute integers x and y such that: ax + ny = gcd(a, n).
            // When the gcd is 1, then the inverse of a modulo n exists and it's x.
            // ax + ny = 1
            // ax = 1 + (-y)n
            // ax ≡ 1 (mod n) # x is the inverse of a modulo n

            // If the remainder is 0 the gcd is n right away.
            uint256 remainder = a % n;
            uint256 gcd = n;

            // Therefore the initial coefficients are:
            // ax + ny = gcd(a, n) = n
            // 0a + 1n = n
            int256 x = 0;
            int256 y = 1;

            while (remainder != 0) {
                uint256 quotient = gcd / remainder;

                (gcd, remainder) = (
                    // The old remainder is the next gcd to try.
                    remainder,
                    // Compute the next remainder.
                    // Can't overflow given that (a % gcd) * (gcd // (a % gcd)) <= gcd
                    // where gcd is at most n (capped to type(uint256).max)
                    gcd - remainder * quotient
                );

                (x, y) = (
                    // Increment the coefficient of a.
                    y,
                    // Decrement the coefficient of n.
                    // Can overflow, but the result is casted to uint256 so that the
                    // next value of y is "wrapped around" to a value between 0 and n - 1.
                    x - y * int256(quotient)
                );
            }

            if (gcd != 1) return 0; // No inverse exists.
            return ternary(x < 0, n - uint256(-x), uint256(x)); // Wrap the result if it's negative.
        }
    }

    /**
     * @dev Variant of {invMod}. More efficient, but only works if `p` is known to be a prime greater than `2`.
     *
     * From https://en.wikipedia.org/wiki/Fermat%27s_little_theorem[Fermat's little theorem], we know that if p is
     * prime, then `a**(p-1) ≡ 1 mod p`. As a consequence, we have `a * a**(p-2) ≡ 1 mod p`, which means that
     * `a**(p-2)` is the modular multiplicative inverse of a in Fp.
     *
     * NOTE: this function does NOT check that `p` is a prime greater than `2`.
     */
    function invModPrime(uint256 a, uint256 p) internal view returns (uint256) {
        unchecked {
            return Math.modExp(a, p - 2, p);
        }
    }

    /**
     * @dev Returns the modular exponentiation of the specified base, exponent and modulus (b ** e % m)
     *
     * Requirements:
     * - modulus can't be zero
     * - underlying staticcall to precompile must succeed
     *
     * IMPORTANT: The result is only valid if the underlying call succeeds. When using this function, make
     * sure the chain you're using it on supports the precompiled contract for modular exponentiation
     * at address 0x05 as specified in https://eips.ethereum.org/EIPS/eip-198[EIP-198]. Otherwise,
     * the underlying function will succeed given the lack of a revert, but the result may be incorrectly
     * interpreted as 0.
     */
    function modExp(uint256 b, uint256 e, uint256 m) internal view returns (uint256) {
        (bool success, uint256 result) = tryModExp(b, e, m);
        if (!success) {
            Panic.panic(Panic.DIVISION_BY_ZERO);
        }
        return result;
    }

    /**
     * @dev Returns the modular exponentiation of the specified base, exponent and modulus (b ** e % m).
     * It includes a success flag indicating if the operation succeeded. Operation will be marked as failed if trying
     * to operate modulo 0 or if the underlying precompile reverted.
     *
     * IMPORTANT: The result is only valid if the success flag is true. When using this function, make sure the chain
     * you're using it on supports the precompiled contract for modular exponentiation at address 0x05 as specified in
     * https://eips.ethereum.org/EIPS/eip-198[EIP-198]. Otherwise, the underlying function will succeed given the lack
     * of a revert, but the result may be incorrectly interpreted as 0.
     */
    function tryModExp(uint256 b, uint256 e, uint256 m) internal view returns (bool success, uint256 result) {
        if (m == 0) return (false, 0);
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            // | Offset    | Content    | Content (Hex)                                                      |
            // |-----------|------------|--------------------------------------------------------------------|
            // | 0x00:0x1f | size of b  | 0x0000000000000000000000000000000000000000000000000000000000000020 |
            // | 0x20:0x3f | size of e  | 0x0000000000000000000000000000000000000000000000000000000000000020 |
            // | 0x40:0x5f | size of m  | 0x0000000000000000000000000000000000000000000000000000000000000020 |
            // | 0x60:0x7f | value of b | 0x<.............................................................b> |
            // | 0x80:0x9f | value of e | 0x<.............................................................e> |
            // | 0xa0:0xbf | value of m | 0x<.............................................................m> |
            mstore(ptr, 0x20)
            mstore(add(ptr, 0x20), 0x20)
            mstore(add(ptr, 0x40), 0x20)
            mstore(add(ptr, 0x60), b)
            mstore(add(ptr, 0x80), e)
            mstore(add(ptr, 0xa0), m)

            // Given the result < m, it's guaranteed to fit in 32 bytes,
            // so we can use the memory scratch space located at offset 0.
            success := staticcall(gas(), 0x05, ptr, 0xc0, 0x00, 0x20)
            result := mload(0x00)
        }
    }

    /**
     * @dev Variant of {modExp} that supports inputs of arbitrary length.
     */
    function modExp(bytes memory b, bytes memory e, bytes memory m) internal view returns (bytes memory) {
        (bool success, bytes memory result) = tryModExp(b, e, m);
        if (!success) {
            Panic.panic(Panic.DIVISION_BY_ZERO);
        }
        return result;
    }

    /**
     * @dev Variant of {tryModExp} that supports inputs of arbitrary length.
     */
    function tryModExp(
        bytes memory b,
        bytes memory e,
        bytes memory m
    ) internal view returns (bool success, bytes memory result) {
        if (_zeroBytes(m)) return (false, new bytes(0));

        uint256 mLen = m.length;

        // Encode call args in result and move the free memory pointer
        result = abi.encodePacked(b.length, e.length, mLen, b, e, m);

        assembly ("memory-safe") {
            let dataPtr := add(result, 0x20)
            // Write result on top of args to avoid allocating extra memory.
            success := staticcall(gas(), 0x05, dataPtr, mload(result), dataPtr, mLen)
            // Overwrite the length.
            // result.length > returndatasize() is guaranteed because returndatasize() == m.length
            mstore(result, mLen)
            // Set the memory pointer after the returned data.
            mstore(0x40, add(dataPtr, mLen))
        }
    }

    /**
     * @dev Returns whether the provided byte array is zero.
     */
    function _zeroBytes(bytes memory byteArray) private pure returns (bool) {
        for (uint256 i = 0; i < byteArray.length; ++i) {
            if (byteArray[i] != 0) {
                return false;
            }
        }
        return true;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded
     * towards zero.
     *
     * This method is based on Newton's method for computing square roots; the algorithm is restricted to only
     * using integer operations.
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        unchecked {
            // Take care of easy edge cases when a == 0 or a == 1
            if (a <= 1) {
                return a;
            }

            // In this function, we use Newton's method to get a root of `f(x) := x² - a`. It involves building a
            // sequence x_n that converges toward sqrt(a). For each iteration x_n, we also define the error between
            // the current value as `ε_n = | x_n - sqrt(a) |`.
            //
            // For our first estimation, we consider `e` the smallest power of 2 which is bigger than the square root
            // of the target. (i.e. `2**(e-1) ≤ sqrt(a) < 2**e`). We know that `e ≤ 128` because `(2¹²⁸)² = 2²⁵⁶` is
            // bigger than any uint256.
            //
            // By noticing that
            // `2**(e-1) ≤ sqrt(a) < 2**e → (2**(e-1))² ≤ a < (2**e)² → 2**(2*e-2) ≤ a < 2**(2*e)`
            // we can deduce that `e - 1` is `log2(a) / 2`. We can thus compute `x_n = 2**(e-1)` using a method similar
            // to the msb function.
            uint256 aa = a;
            uint256 xn = 1;

            if (aa >= (1 << 128)) {
                aa >>= 128;
                xn <<= 64;
            }
            if (aa >= (1 << 64)) {
                aa >>= 64;
                xn <<= 32;
            }
            if (aa >= (1 << 32)) {
                aa >>= 32;
                xn <<= 16;
            }
            if (aa >= (1 << 16)) {
                aa >>= 16;
                xn <<= 8;
            }
            if (aa >= (1 << 8)) {
                aa >>= 8;
                xn <<= 4;
            }
            if (aa >= (1 << 4)) {
                aa >>= 4;
                xn <<= 2;
            }
            if (aa >= (1 << 2)) {
                xn <<= 1;
            }

            // We now have x_n such that `x_n = 2**(e-1) ≤ sqrt(a) < 2**e = 2 * x_n`. This implies ε_n ≤ 2**(e-1).
            //
            // We can refine our estimation by noticing that the middle of that interval minimizes the error.
            // If we move x_n to equal 2**(e-1) + 2**(e-2), then we reduce the error to ε_n ≤ 2**(e-2).
            // This is going to be our x_0 (and ε_0)
            xn = (3 * xn) >> 1; // ε_0 := | x_0 - sqrt(a) | ≤ 2**(e-2)

            // From here, Newton's method give us:
            // x_{n+1} = (x_n + a / x_n) / 2
            //
            // One should note that:
            // x_{n+1}² - a = ((x_n + a / x_n) / 2)² - a
            //              = ((x_n² + a) / (2 * x_n))² - a
            //              = (x_n⁴ + 2 * a * x_n² + a²) / (4 * x_n²) - a
            //              = (x_n⁴ + 2 * a * x_n² + a² - 4 * a * x_n²) / (4 * x_n²)
            //              = (x_n⁴ - 2 * a * x_n² + a²) / (4 * x_n²)
            //              = (x_n² - a)² / (2 * x_n)²
            //              = ((x_n² - a) / (2 * x_n))²
            //              ≥ 0
            // Which proves that for all n ≥ 1, sqrt(a) ≤ x_n
            //
            // This gives us the proof of quadratic convergence of the sequence:
            // ε_{n+1} = | x_{n+1} - sqrt(a) |
            //         = | (x_n + a / x_n) / 2 - sqrt(a) |
            //         = | (x_n² + a - 2*x_n*sqrt(a)) / (2 * x_n) |
            //         = | (x_n - sqrt(a))² / (2 * x_n) |
            //         = | ε_n² / (2 * x_n) |
            //         = ε_n² / | (2 * x_n) |
            //
            // For the first iteration, we have a special case where x_0 is known:
            // ε_1 = ε_0² / | (2 * x_0) |
            //     ≤ (2**(e-2))² / (2 * (2**(e-1) + 2**(e-2)))
            //     ≤ 2**(2*e-4) / (3 * 2**(e-1))
            //     ≤ 2**(e-3) / 3
            //     ≤ 2**(e-3-log2(3))
            //     ≤ 2**(e-4.5)
            //
            // For the following iterations, we use the fact that, 2**(e-1) ≤ sqrt(a) ≤ x_n:
            // ε_{n+1} = ε_n² / | (2 * x_n) |
            //         ≤ (2**(e-k))² / (2 * 2**(e-1))
            //         ≤ 2**(2*e-2*k) / 2**e
            //         ≤ 2**(e-2*k)
            xn = (xn + a / xn) >> 1; // ε_1 := | x_1 - sqrt(a) | ≤ 2**(e-4.5)  -- special case, see above
            xn = (xn + a / xn) >> 1; // ε_2 := | x_2 - sqrt(a) | ≤ 2**(e-9)    -- general case with k = 4.5
            xn = (xn + a / xn) >> 1; // ε_3 := | x_3 - sqrt(a) | ≤ 2**(e-18)   -- general case with k = 9
            xn = (xn + a / xn) >> 1; // ε_4 := | x_4 - sqrt(a) | ≤ 2**(e-36)   -- general case with k = 18
            xn = (xn + a / xn) >> 1; // ε_5 := | x_5 - sqrt(a) | ≤ 2**(e-72)   -- general case with k = 36
            xn = (xn + a / xn) >> 1; // ε_6 := | x_6 - sqrt(a) | ≤ 2**(e-144)  -- general case with k = 72

            // Because e ≤ 128 (as discussed during the first estimation phase), we know have reached a precision
            // ε_6 ≤ 2**(e-144) < 1. Given we're operating on integers, then we can ensure that xn is now either
            // sqrt(a) or sqrt(a) + 1.
            return xn - SafeCast.toUint(xn > a / xn);
        }
    }

    /**
     * @dev Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + SafeCast.toUint(unsignedRoundsUp(rounding) && result * result < a);
        }
    }

    /**
     * @dev Return the log in base 2 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        uint256 exp;
        unchecked {
            exp = 128 * SafeCast.toUint(value > (1 << 128) - 1);
            value >>= exp;
            result += exp;

            exp = 64 * SafeCast.toUint(value > (1 << 64) - 1);
            value >>= exp;
            result += exp;

            exp = 32 * SafeCast.toUint(value > (1 << 32) - 1);
            value >>= exp;
            result += exp;

            exp = 16 * SafeCast.toUint(value > (1 << 16) - 1);
            value >>= exp;
            result += exp;

            exp = 8 * SafeCast.toUint(value > (1 << 8) - 1);
            value >>= exp;
            result += exp;

            exp = 4 * SafeCast.toUint(value > (1 << 4) - 1);
            value >>= exp;
            result += exp;

            exp = 2 * SafeCast.toUint(value > (1 << 2) - 1);
            value >>= exp;
            result += exp;

            result += SafeCast.toUint(value > 1);
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + SafeCast.toUint(unsignedRoundsUp(rounding) && 1 << result < value);
        }
    }

    /**
     * @dev Return the log in base 10 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + SafeCast.toUint(unsignedRoundsUp(rounding) && 10 ** result < value);
        }
    }

    /**
     * @dev Return the log in base 256 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        uint256 isGt;
        unchecked {
            isGt = SafeCast.toUint(value > (1 << 128) - 1);
            value >>= isGt * 128;
            result += isGt * 16;

            isGt = SafeCast.toUint(value > (1 << 64) - 1);
            value >>= isGt * 64;
            result += isGt * 8;

            isGt = SafeCast.toUint(value > (1 << 32) - 1);
            value >>= isGt * 32;
            result += isGt * 4;

            isGt = SafeCast.toUint(value > (1 << 16) - 1);
            value >>= isGt * 16;
            result += isGt * 2;

            result += SafeCast.toUint(value > (1 << 8) - 1);
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + SafeCast.toUint(unsignedRoundsUp(rounding) && 1 << (result << 3) < value);
        }
    }

    /**
     * @dev Returns whether a provided rounding mode is considered rounding up for unsigned integers.
     */
    function unsignedRoundsUp(Rounding rounding) internal pure returns (bool) {
        return uint8(rounding) % 2 == 1;
    }
}

// File: lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.20;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```solidity
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 *
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Storage of the initializable contract.
     *
     * It's implemented on a custom ERC-7201 namespace to reduce the risk of storage collisions
     * when using with upgradeable contracts.
     *
     * @custom:storage-location erc7201:openzeppelin.storage.Initializable
     */
    struct InitializableStorage {
        /**
         * @dev Indicates that the contract has been initialized.
         */
        uint64 _initialized;
        /**
         * @dev Indicates that the contract is in the process of being initialized.
         */
        bool _initializing;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.Initializable")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant INITIALIZABLE_STORAGE = 0xf0c57e16840df040f15088dc2f81fe391c3923bec73e23a9662efc9c229c6a00;

    /**
     * @dev The contract is already initialized.
     */
    error InvalidInitialization();

    /**
     * @dev The contract is not initializing.
     */
    error NotInitializing();

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint64 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that in the context of a constructor an `initializer` may be invoked any
     * number of times. This behavior in the constructor can be useful during testing and is not expected to be used in
     * production.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        // Cache values to avoid duplicated sloads
        bool isTopLevelCall = !$._initializing;
        uint64 initialized = $._initialized;

        // Allowed calls:
        // - initialSetup: the contract is not in the initializing state and no previous version was
        //                 initialized
        // - construction: the contract is initialized at version 1 (no reininitialization) and the
        //                 current contract is just being deployed
        bool initialSetup = initialized == 0 && isTopLevelCall;
        bool construction = initialized == 1 && address(this).code.length == 0;

        if (!initialSetup && !construction) {
            revert InvalidInitialization();
        }
        $._initialized = 1;
        if (isTopLevelCall) {
            $._initializing = true;
        }
        _;
        if (isTopLevelCall) {
            $._initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: Setting the version to 2**64 - 1 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint64 version) {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        if ($._initializing || $._initialized >= version) {
            revert InvalidInitialization();
        }
        $._initialized = version;
        $._initializing = true;
        _;
        $._initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        _checkInitializing();
        _;
    }

    /**
     * @dev Reverts if the contract is not in an initializing state. See {onlyInitializing}.
     */
    function _checkInitializing() internal view virtual {
        if (!_isInitializing()) {
            revert NotInitializing();
        }
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        if ($._initializing) {
            revert InvalidInitialization();
        }
        if ($._initialized != type(uint64).max) {
            $._initialized = type(uint64).max;
            emit Initialized(type(uint64).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint64) {
        return _getInitializableStorage()._initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _getInitializableStorage()._initializing;
    }

    /**
     * @dev Returns a pointer to the storage namespace.
     */
    // solhint-disable-next-line var-name-mixedcase
    function _getInitializableStorage() private pure returns (InitializableStorage storage $) {
        assembly {
            $.slot := INITIALIZABLE_STORAGE
        }
    }
}

// File: lib/openzeppelin-contracts-upgradeable/contracts/utils/ReentrancyGuardUpgradeable.sol

// OpenZeppelin Contracts (last updated v5.1.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;


/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If EIP-1153 (transient storage) is available on the chain you're deploying at,
 * consider using {ReentrancyGuardTransient} instead.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    /// @custom:storage-location erc7201:openzeppelin.storage.ReentrancyGuard
    struct ReentrancyGuardStorage {
        uint256 _status;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.ReentrancyGuard")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ReentrancyGuardStorageLocation = 0x9b779b17422d0df92223018b32b4d1fa46e071723d6817e2486d003becc55f00;

    function _getReentrancyGuardStorage() private pure returns (ReentrancyGuardStorage storage $) {
        assembly {
            $.slot := ReentrancyGuardStorageLocation
        }
    }

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        ReentrancyGuardStorage storage $ = _getReentrancyGuardStorage();
        $._status = NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        ReentrancyGuardStorage storage $ = _getReentrancyGuardStorage();
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if ($._status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        $._status = ENTERED;
    }

    function _nonReentrantAfter() private {
        ReentrancyGuardStorage storage $ = _getReentrancyGuardStorage();
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        $._status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        ReentrancyGuardStorage storage $ = _getReentrancyGuardStorage();
        return $._status == ENTERED;
    }
}

// File: lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/utils/introspection/IERC165.sol

// OpenZeppelin Contracts (last updated v5.1.0) (utils/introspection/IERC165.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[ERC].
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
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[ERC section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/interfaces/IERC165.sol

// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC165.sol)

pragma solidity ^0.8.20;

// File: lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/interfaces/IERC1363.sol

// OpenZeppelin Contracts (last updated v5.1.0) (interfaces/IERC1363.sol)

pragma solidity ^0.8.20;




/**
 * @title IERC1363
 * @dev Interface of the ERC-1363 standard as defined in the https://eips.ethereum.org/EIPS/eip-1363[ERC-1363].
 *
 * Defines an extension interface for ERC-20 tokens that supports executing code on a recipient contract
 * after `transfer` or `transferFrom`, or code on a spender contract after `approve`, in a single transaction.
 */
interface IERC1363 is IERC20, IERC165 {
    /*
     * Note: the ERC-165 identifier for this interface is 0xb0202a11.
     * 0xb0202a11 ===
     *   bytes4(keccak256('transferAndCall(address,uint256)')) ^
     *   bytes4(keccak256('transferAndCall(address,uint256,bytes)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256,bytes)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256,bytes)'))
     */

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @param data Additional data with no specified format, sent in call to `spender`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value, bytes calldata data) external returns (bool);
}

// File: lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol

// OpenZeppelin Contracts (last updated v5.2.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.20;




/**
 * @title SafeERC20
 * @dev Wrappers around ERC-20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    /**
     * @dev An operation with an ERC-20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     *
     * NOTE: If the token implements ERC-7674, this function will not modify any temporary allowance. This function
     * only sets the "standard" allowance. Any temporary allowance will remain active, in addition to the value being
     * set here.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Performs an {ERC1363} transferAndCall, with a fallback to the simple {ERC20} transfer if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            safeTransfer(token, to, value);
        } else if (!token.transferAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} transferFromAndCall, with a fallback to the simple {ERC20} transferFrom if the target
     * has no code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferFromAndCallRelaxed(
        IERC1363 token,
        address from,
        address to,
        uint256 value,
        bytes memory data
    ) internal {
        if (to.code.length == 0) {
            safeTransferFrom(token, from, to, value);
        } else if (!token.transferFromAndCall(from, to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} approveAndCall, with a fallback to the simple {ERC20} approve if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * NOTE: When the recipient address (`to`) has no code (i.e. is an EOA), this function behaves as {forceApprove}.
     * Opposedly, when the recipient address (`to`) has code, this function only attempts to call {ERC1363-approveAndCall}
     * once without retrying, and relies on the returned value to be true.
     *
     * Reverts if the returned value is other than `true`.
     */
    function approveAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            forceApprove(token, to, value);
        } else if (!token.approveAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturnBool} that reverts if call fails to meet the requirements.
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            let success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            // bubble errors
            if iszero(success) {
                let ptr := mload(0x40)
                returndatacopy(ptr, 0, returndatasize())
                revert(ptr, returndatasize())
            }
            returnSize := returndatasize()
            returnValue := mload(0)
        }

        if (returnSize == 0 ? address(token).code.length == 0 : returnValue != 1) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silently catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        bool success;
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            returnSize := returndatasize()
            returnValue := mload(0)
        }
        return success && (returnSize == 0 ? address(token).code.length > 0 : returnValue == 1);
    }
}

// File: lib/wormhole-solidity-sdk/src/interfaces/IWormhole.sol

pragma solidity ^0.8.0;

interface IWormhole {
  struct GuardianSet {
    address[] keys;
    uint32 expirationTime;
  }

  struct Signature {
    bytes32 r;
    bytes32 s;
    uint8 v;
    uint8 guardianIndex;
  }

  struct VM {
    uint8 version;
    uint32 timestamp;
    uint32 nonce;
    uint16 emitterChainId;
    bytes32 emitterAddress;
    uint64 sequence;
    uint8 consistencyLevel;
    bytes payload;
    uint32 guardianSetIndex;
    Signature[] signatures;
    bytes32 hash;
  }

  struct ContractUpgrade {
    bytes32 module;
    uint8 action;
    uint16 chain;
    address newContract;
  }

  struct GuardianSetUpgrade {
    bytes32 module;
    uint8 action;
    uint16 chain;
    GuardianSet newGuardianSet;
    uint32 newGuardianSetIndex;
  }

  struct SetMessageFee {
    bytes32 module;
    uint8 action;
    uint16 chain;
    uint256 messageFee;
  }

  struct TransferFees {
    bytes32 module;
    uint8 action;
    uint16 chain;
    uint256 amount;
    bytes32 recipient;
  }

  struct RecoverChainId {
    bytes32 module;
    uint8 action;
    uint256 evmChainId;
    uint16 newChainId;
  }

  event LogMessagePublished(
    address indexed sender,
    uint64 sequence,
    uint32 nonce,
    bytes payload,
    uint8 consistencyLevel
  );

  event ContractUpgraded(address indexed oldContract, address indexed newContract);

  event GuardianSetAdded(uint32 indexed index);

  function publishMessage(uint32 nonce, bytes memory payload, uint8 consistencyLevel)
    external
    payable
    returns (uint64 sequence);

  function initialize() external;

  function parseAndVerifyVM(bytes calldata encodedVM)
    external
    view
    returns (VM memory vm, bool valid, string memory reason);

  function verifyVM(VM memory vm) external view returns (bool valid, string memory reason);

  function verifySignatures(
    bytes32 hash,
    Signature[] memory signatures,
    GuardianSet memory guardianSet
  ) external pure returns (bool valid, string memory reason);

  function parseVM(bytes memory encodedVM) external pure returns (VM memory vm);

  function quorum(
    uint256 numGuardians
  ) external pure returns (uint256 numSignaturesRequiredForQuorum);

  function getGuardianSet(uint32 index) external view returns (GuardianSet memory);

  function getCurrentGuardianSetIndex() external view returns (uint32);

  function getGuardianSetExpiry() external view returns (uint32);

  function governanceActionIsConsumed(bytes32 hash) external view returns (bool);

  function isInitialized(address impl) external view returns (bool);

  function chainId() external view returns (uint16);

  function isFork() external view returns (bool);

  function governanceChainId() external view returns (uint16);

  function governanceContract() external view returns (bytes32);

  function messageFee() external view returns (uint256);

  function evmChainId() external view returns (uint256);

  function nextSequence(address emitter) external view returns (uint64);

  function parseContractUpgrade(
    bytes memory encodedUpgrade
  ) external pure returns (ContractUpgrade memory cu);

  function parseGuardianSetUpgrade(
    bytes memory encodedUpgrade
  ) external pure returns (GuardianSetUpgrade memory gsu);

  function parseSetMessageFee(
    bytes memory encodedSetMessageFee
  ) external pure returns (SetMessageFee memory smf);

  function parseTransferFees(
    bytes memory encodedTransferFees
  ) external pure returns (TransferFees memory tf);

  function parseRecoverChainId(
    bytes memory encodedRecoverChainId
  ) external pure returns (RecoverChainId memory rci);

  function submitContractUpgrade(bytes memory _vm) external;

  function submitSetMessageFee(bytes memory _vm) external;

  function submitNewGuardianSet(bytes memory _vm) external;

  function submitTransferFees(bytes memory _vm) external;

  function submitRecoverChainId(bytes memory _vm) external;
}

// File: lib/wormhole-solidity-sdk/src/constants/Common.sol

pragma solidity ^0.8.4;

// ┌──────────────────────────────────────────────────────────────────────────────┐
// │ NOTE: We can't define e.g. WORD_SIZE_MINUS_ONE via WORD_SIZE - 1 because     │
// │       of solc restrictions on what constants can be used in inline assembly. │
// └──────────────────────────────────────────────────────────────────────────────┘

uint256 constant WORD_SIZE = 32;
uint256 constant WORD_SIZE_MINUS_ONE = 31; //=0x1f=0b00011111
//see section "prefer `< MAX + 1` over `<= MAX` for const comparison" in docs/Optimization.md
uint256 constant WORD_SIZE_PLUS_ONE = 33;

uint256 constant SCRATCH_SPACE_PTR = 0x00;
uint256 constant SCRATCH_SPACE_SIZE = 64;

uint256 constant FREE_MEMORY_PTR = 0x40;

// File: lib/wormhole-solidity-sdk/src/libraries/BytesParsing.sol

pragma solidity ^0.8.4;



//This file appears comically large, but all unused functions are removed by the compiler.
library BytesParsing {
  error OutOfBounds(uint256 offset, uint256 length);
  error LengthMismatch(uint256 encodedLength, uint256 expectedLength);
  error InvalidBoolVal(uint8 val);

  /**
   * Implements runtime check of logic that accesses memory.
   * @param pastTheEndOffset The offset past the end relative to the accessed memory fragment.
   * @param length The length of the memory fragment accessed.
   */
  function checkBound(uint pastTheEndOffset, uint length) internal pure {
    if (pastTheEndOffset > length)
      revert OutOfBounds(pastTheEndOffset, length);
  }

  function checkLength(uint encodedLength, uint expectedLength) internal pure {
    if (encodedLength != expectedLength)
      revert LengthMismatch(encodedLength, expectedLength);
  }

  //Summary of all remaining functions:
  //
  //Each function has 2*2=4 versions:
  //  1. unchecked - no bounds checking (uses suffix `Unchecked`)
  //  2. checked (no suffix)
  //and (since Solidity does not allow overloading based on data location)
  //  1. calldata input (uses tag `Cd` )
  //  2. memory input (uses tag `Mem`)
  //
  //The canoncial/recommended way of parsing data to be maximally gas efficient is to prefer the
  //  calldata variants over the memory variants and to use the unchecked variants with a manual
  //  length check at the end using `checkLength` to ensure that encoded data was consumed exactly.
  //
  //WARNING: Neither variant uses safe math! It is up to the dev to ensure that offset and length
  //  values are sensible. In other words, verify user inputs before passing them on. Preferably,
  //  the format that's being parsed does not allow for such overflows in the first place by e.g.
  //  encoding lengths using at most 4 bytes, etc.
  //
  //Functions:
  //  Unless stated otherwise, all functions take an `encoded` bytes calldata/memory and an `offset`
  //    as input and return the parsed value and the next offset (i.e. the offset pointing to the
  //    next, unparsed byte).
  //
  // * slice(encoded, offset, length)
  // * sliceUint<n>Prefixed - n in {8, 16, 32} - parses n bytes of length prefix followed by data
  // * asAddress
  // * asBool
  // * asUint<8*n> - n in {1, ..., 32}, i.e. asUint8, asUint16, ..., asUint256
  // * asBytes<n>  - n in {1, ..., 32}, i.e. asBytes1, asBytes2, ..., asBytes32

  function sliceCdUnchecked(
    bytes calldata encoded,
    uint offset,
    uint length
  ) internal pure returns (bytes calldata ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret.offset := add(encoded.offset, offset)
      ret.length := length
      nextOffset := add(offset, length)
    }
  }

  function sliceMemUnchecked(
    bytes memory encoded,
    uint offset,
    uint length
  ) internal pure returns (bytes memory ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, length)
      ret := mload(FREE_MEMORY_PTR)

      //Explanation on how we copy data here:
      //  The bytes type has the following layout in memory:
      //    [length: 32 bytes, data: length bytes]
      //  So if we allocate `bytes memory foo = new bytes(1);` then `foo` will be a pointer to 33
      //    bytes where the first 32 bytes contain the length and the last byte is the actual data.
      //  Since mload always loads 32 bytes of memory at once, we use our shift variable to align
      //    our reads so that our last read lines up exactly with the last 32 bytes of `encoded`.
      //  However this also means that if the length of `encoded` is not a multiple of 32 bytes, our
      //    first read will necessarily partly contain bytes from `encoded`'s 32 length bytes that
      //    will be written into the length part of our `ret` slice.
      //  We remedy this issue by writing the length of our `ret` slice at the end, thus
      //    overwritting those garbage bytes.

      //and(length, 31) is equivalent to `mod(length, 32)`, but 2 gas cheaper
      let shift := and(length, WORD_SIZE_MINUS_ONE)
      if iszero(shift) {
        shift := WORD_SIZE
      }

      let dest := add(ret, shift)
      let end := add(dest, length)
      for {
        let src := add(add(encoded, shift), offset)
      } lt(dest, end) {
        src := add(src, WORD_SIZE)
        dest := add(dest, WORD_SIZE)
      } {
        mstore(dest, mload(src))
      }

      mstore(ret, length)
      //When compiling with --via-ir then normally allocated memory (i.e. via new) will have 32 byte
      //  memory alignment and so we enforce the same memory alignment here.
      mstore(
        FREE_MEMORY_PTR,
        and(add(dest, WORD_SIZE_MINUS_ONE), not(WORD_SIZE_MINUS_ONE))
      )
    }
  }

/* -------------------------------------------------------------------------------------------------
Remaining library code below was auto-generated via the following js/node code:

const dlTag = dl => dl ? "Cd" : "Mem";
const dlType = dl =>dl ? "calldata" : "memory";

const funcs = [
  ...[8,16,32].map(n => [
    `sliceUint${n}Prefixed`,
    dl => [
      `uint${n} len;`,
      `(len, nextOffset) = asUint${n}${dlTag(dl)}Unchecked(encoded, offset);`,
      `(ret, nextOffset) = slice${dlTag(dl)}Unchecked(encoded, nextOffset, uint(len));`
    ],
    dl => `bytes ${dlType(dl)}`,
  ]), [
    `asAddress`,
    dl => [
      `uint160 tmp;`,
      `(tmp, nextOffset) = asUint160${dlTag(dl)}Unchecked(encoded, offset);`,
      `ret = address(tmp);`
    ],
    _ => `address`
  ], [
    `asBool`,
    dl => [
      `uint8 val;`,
      `(val, nextOffset) = asUint8${dlTag(dl)}Unchecked(encoded, offset);`,
      `if (val & 0xfe != 0)`,
      `  revert InvalidBoolVal(val);`,
      `uint cleanedVal = uint(val);`,
      `//skip 2x iszero opcode`,
      `/// @solidity memory-safe-assembly`,
      `assembly { ret := cleanedVal }`
    ],
    _ => `bool`
  ],
  ...Array.from({length: 32}, (_, i) => [
    `asUint${(i+1)*8}`,
    dl => [
      `/// @solidity memory-safe-assembly`,
      `assembly {`,
      `  nextOffset := add(offset, ${i+1})`,
      dl ? `  ret := shr(${256-(i+1)*8}, calldataload(add(encoded.offset, offset)))`
         : `  ret := mload(add(encoded, nextOffset))`,
      `}`
    ],
    _ => `uint${(i+1)*8}`
  ]),
  ...Array.from({length: 32}, (_, i) => [
    `asBytes${i+1}`,
    dl => [
      `/// @solidity memory-safe-assembly`,
      `assembly {`,
      `  ret := ${dl ? "calldataload" : "mload"}(add(encoded${dl ? ".offset" :""}, ${dl ? "offset" : "add(offset, WORD_SIZE)"}))`,
      `  nextOffset := add(offset, ${i+1})`,
      `}`
    ],
    _ => `bytes${i+1}`
  ]),
];

for (const dl of [true, false])
  console.log(
`function slice${dlTag(dl)}(
  bytes ${dlType(dl)} encoded,
  uint offset,
  uint length
) internal pure returns (bytes ${dlType(dl)} ret, uint nextOffset) {
  (ret, nextOffset) = slice${dlTag(dl)}Unchecked(encoded, offset, length);
  checkBound(nextOffset, encoded.length);
}
`);

for (const [name, code, ret] of funcs) {
  for (const dl of [true, false])
    console.log(
`function ${name}${dlTag(dl)}Unchecked(
  bytes ${dlType(dl)} encoded,
  uint offset
) internal pure returns (${ret(dl)} ret, uint nextOffset) {
  ${code(dl).join("\n  ")}
}

function ${name}${dlTag(dl)}(
  bytes ${dlType(dl)} encoded,
  uint offset
) internal pure returns (${ret(dl)} ret, uint nextOffset) {
  (ret, nextOffset) = ${name}${dlTag(dl)}Unchecked(encoded, offset);
  checkBound(nextOffset, encoded.length);
}
`);
}
------------------------------------------------------------------------------------------------- */

  function sliceCd(
    bytes calldata encoded,
    uint offset,
    uint length
  ) internal pure returns (bytes calldata ret, uint nextOffset) {
    (ret, nextOffset) = sliceCdUnchecked(encoded, offset, length);
    checkBound(nextOffset, encoded.length);
  }

  function sliceMem(
    bytes memory encoded,
    uint offset,
    uint length
  ) internal pure returns (bytes memory ret, uint nextOffset) {
    (ret, nextOffset) = sliceMemUnchecked(encoded, offset, length);
    checkBound(nextOffset, encoded.length);
  }

  function sliceUint8PrefixedCdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes calldata ret, uint nextOffset) {
    uint8 len;
    (len, nextOffset) = asUint8CdUnchecked(encoded, offset);
    (ret, nextOffset) = sliceCdUnchecked(encoded, nextOffset, uint(len));
  }

  function sliceUint8PrefixedCd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes calldata ret, uint nextOffset) {
    (ret, nextOffset) = sliceUint8PrefixedCdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function sliceUint8PrefixedMemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes memory ret, uint nextOffset) {
    uint8 len;
    (len, nextOffset) = asUint8MemUnchecked(encoded, offset);
    (ret, nextOffset) = sliceMemUnchecked(encoded, nextOffset, uint(len));
  }

  function sliceUint8PrefixedMem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes memory ret, uint nextOffset) {
    (ret, nextOffset) = sliceUint8PrefixedMemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function sliceUint16PrefixedCdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes calldata ret, uint nextOffset) {
    uint16 len;
    (len, nextOffset) = asUint16CdUnchecked(encoded, offset);
    (ret, nextOffset) = sliceCdUnchecked(encoded, nextOffset, uint(len));
  }

  function sliceUint16PrefixedCd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes calldata ret, uint nextOffset) {
    (ret, nextOffset) = sliceUint16PrefixedCdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function sliceUint16PrefixedMemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes memory ret, uint nextOffset) {
    uint16 len;
    (len, nextOffset) = asUint16MemUnchecked(encoded, offset);
    (ret, nextOffset) = sliceMemUnchecked(encoded, nextOffset, uint(len));
  }

  function sliceUint16PrefixedMem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes memory ret, uint nextOffset) {
    (ret, nextOffset) = sliceUint16PrefixedMemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function sliceUint32PrefixedCdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes calldata ret, uint nextOffset) {
    uint32 len;
    (len, nextOffset) = asUint32CdUnchecked(encoded, offset);
    (ret, nextOffset) = sliceCdUnchecked(encoded, nextOffset, uint(len));
  }

  function sliceUint32PrefixedCd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes calldata ret, uint nextOffset) {
    (ret, nextOffset) = sliceUint32PrefixedCdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function sliceUint32PrefixedMemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes memory ret, uint nextOffset) {
    uint32 len;
    (len, nextOffset) = asUint32MemUnchecked(encoded, offset);
    (ret, nextOffset) = sliceMemUnchecked(encoded, nextOffset, uint(len));
  }

  function sliceUint32PrefixedMem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes memory ret, uint nextOffset) {
    (ret, nextOffset) = sliceUint32PrefixedMemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asAddressCdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (address ret, uint nextOffset) {
    uint160 tmp;
    (tmp, nextOffset) = asUint160CdUnchecked(encoded, offset);
    ret = address(tmp);
  }

  function asAddressCd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (address ret, uint nextOffset) {
    (ret, nextOffset) = asAddressCdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asAddressMemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (address ret, uint nextOffset) {
    uint160 tmp;
    (tmp, nextOffset) = asUint160MemUnchecked(encoded, offset);
    ret = address(tmp);
  }

  function asAddressMem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (address ret, uint nextOffset) {
    (ret, nextOffset) = asAddressMemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBoolCdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bool ret, uint nextOffset) {
    uint8 val;
    (val, nextOffset) = asUint8CdUnchecked(encoded, offset);
    if (val & 0xfe != 0)
      revert InvalidBoolVal(val);
    uint cleanedVal = uint(val);
    //skip 2x iszero opcode
    /// @solidity memory-safe-assembly
    assembly { ret := cleanedVal }
  }

  function asBoolCd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bool ret, uint nextOffset) {
    (ret, nextOffset) = asBoolCdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBoolMemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bool ret, uint nextOffset) {
    uint8 val;
    (val, nextOffset) = asUint8MemUnchecked(encoded, offset);
    if (val & 0xfe != 0)
      revert InvalidBoolVal(val);
    uint cleanedVal = uint(val);
    //skip 2x iszero opcode
    /// @solidity memory-safe-assembly
    assembly { ret := cleanedVal }
  }

  function asBoolMem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bool ret, uint nextOffset) {
    (ret, nextOffset) = asBoolMemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint8CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint8 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 1)
      ret := shr(248, calldataload(add(encoded.offset, offset)))
    }
  }

  function asUint8Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint8 ret, uint nextOffset) {
    (ret, nextOffset) = asUint8CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint8MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint8 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 1)
      ret := mload(add(encoded, nextOffset))
    }
  }

  function asUint8Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint8 ret, uint nextOffset) {
    (ret, nextOffset) = asUint8MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint16CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint16 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 2)
      ret := shr(240, calldataload(add(encoded.offset, offset)))
    }
  }

  function asUint16Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint16 ret, uint nextOffset) {
    (ret, nextOffset) = asUint16CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint16MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint16 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 2)
      ret := mload(add(encoded, nextOffset))
    }
  }

  function asUint16Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint16 ret, uint nextOffset) {
    (ret, nextOffset) = asUint16MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint24CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint24 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 3)
      ret := shr(232, calldataload(add(encoded.offset, offset)))
    }
  }

  function asUint24Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint24 ret, uint nextOffset) {
    (ret, nextOffset) = asUint24CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint24MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint24 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 3)
      ret := mload(add(encoded, nextOffset))
    }
  }

  function asUint24Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint24 ret, uint nextOffset) {
    (ret, nextOffset) = asUint24MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint32CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint32 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 4)
      ret := shr(224, calldataload(add(encoded.offset, offset)))
    }
  }

  function asUint32Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint32 ret, uint nextOffset) {
    (ret, nextOffset) = asUint32CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint32MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint32 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 4)
      ret := mload(add(encoded, nextOffset))
    }
  }

  function asUint32Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint32 ret, uint nextOffset) {
    (ret, nextOffset) = asUint32MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint40CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint40 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 5)
      ret := shr(216, calldataload(add(encoded.offset, offset)))
    }
  }

  function asUint40Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint40 ret, uint nextOffset) {
    (ret, nextOffset) = asUint40CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint40MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint40 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 5)
      ret := mload(add(encoded, nextOffset))
    }
  }

  function asUint40Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint40 ret, uint nextOffset) {
    (ret, nextOffset) = asUint40MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint48CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint48 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 6)
      ret := shr(208, calldataload(add(encoded.offset, offset)))
    }
  }

  function asUint48Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint48 ret, uint nextOffset) {
    (ret, nextOffset) = asUint48CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint48MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint48 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 6)
      ret := mload(add(encoded, nextOffset))
    }
  }

  function asUint48Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint48 ret, uint nextOffset) {
    (ret, nextOffset) = asUint48MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint56CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint56 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 7)
      ret := shr(200, calldataload(add(encoded.offset, offset)))
    }
  }

  function asUint56Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint56 ret, uint nextOffset) {
    (ret, nextOffset) = asUint56CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint56MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint56 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 7)
      ret := mload(add(encoded, nextOffset))
    }
  }

  function asUint56Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint56 ret, uint nextOffset) {
    (ret, nextOffset) = asUint56MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint64CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint64 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 8)
      ret := shr(192, calldataload(add(encoded.offset, offset)))
    }
  }

  function asUint64Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint64 ret, uint nextOffset) {
    (ret, nextOffset) = asUint64CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint64MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint64 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 8)
      ret := mload(add(encoded, nextOffset))
    }
  }

  function asUint64Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint64 ret, uint nextOffset) {
    (ret, nextOffset) = asUint64MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint72CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint72 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 9)
      ret := shr(184, calldataload(add(encoded.offset, offset)))
    }
  }

  function asUint72Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint72 ret, uint nextOffset) {
    (ret, nextOffset) = asUint72CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint72MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint72 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 9)
      ret := mload(add(encoded, nextOffset))
    }
  }

  function asUint72Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint72 ret, uint nextOffset) {
    (ret, nextOffset) = asUint72MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint80CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint80 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 10)
      ret := shr(176, calldataload(add(encoded.offset, offset)))
    }
  }

  function asUint80Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint80 ret, uint nextOffset) {
    (ret, nextOffset) = asUint80CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint80MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint80 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 10)
      ret := mload(add(encoded, nextOffset))
    }
  }

  function asUint80Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint80 ret, uint nextOffset) {
    (ret, nextOffset) = asUint80MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint88CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint88 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 11)
      ret := shr(168, calldataload(add(encoded.offset, offset)))
    }
  }

  function asUint88Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint88 ret, uint nextOffset) {
    (ret, nextOffset) = asUint88CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint88MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint88 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 11)
      ret := mload(add(encoded, nextOffset))
    }
  }

  function asUint88Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint88 ret, uint nextOffset) {
    (ret, nextOffset) = asUint88MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint96CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint96 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 12)
      ret := shr(160, calldataload(add(encoded.offset, offset)))
    }
  }

  function asUint96Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint96 ret, uint nextOffset) {
    (ret, nextOffset) = asUint96CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint96MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint96 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 12)
      ret := mload(add(encoded, nextOffset))
    }
  }

  function asUint96Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint96 ret, uint nextOffset) {
    (ret, nextOffset) = asUint96MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint104CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint104 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 13)
      ret := shr(152, calldataload(add(encoded.offset, offset)))
    }
  }

  function asUint104Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint104 ret, uint nextOffset) {
    (ret, nextOffset) = asUint104CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint104MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint104 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 13)
      ret := mload(add(encoded, nextOffset))
    }
  }

  function asUint104Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint104 ret, uint nextOffset) {
    (ret, nextOffset) = asUint104MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint112CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint112 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 14)
      ret := shr(144, calldataload(add(encoded.offset, offset)))
    }
  }

  function asUint112Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint112 ret, uint nextOffset) {
    (ret, nextOffset) = asUint112CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint112MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint112 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 14)
      ret := mload(add(encoded, nextOffset))
    }
  }

  function asUint112Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint112 ret, uint nextOffset) {
    (ret, nextOffset) = asUint112MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint120CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint120 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 15)
      ret := shr(136, calldataload(add(encoded.offset, offset)))
    }
  }

  function asUint120Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint120 ret, uint nextOffset) {
    (ret, nextOffset) = asUint120CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint120MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint120 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 15)
      ret := mload(add(encoded, nextOffset))
    }
  }

  function asUint120Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint120 ret, uint nextOffset) {
    (ret, nextOffset) = asUint120MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint128CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint128 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 16)
      ret := shr(128, calldataload(add(encoded.offset, offset)))
    }
  }

  function asUint128Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint128 ret, uint nextOffset) {
    (ret, nextOffset) = asUint128CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint128MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint128 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 16)
      ret := mload(add(encoded, nextOffset))
    }
  }

  function asUint128Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint128 ret, uint nextOffset) {
    (ret, nextOffset) = asUint128MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint136CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint136 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 17)
      ret := shr(120, calldataload(add(encoded.offset, offset)))
    }
  }

  function asUint136Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint136 ret, uint nextOffset) {
    (ret, nextOffset) = asUint136CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint136MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint136 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 17)
      ret := mload(add(encoded, nextOffset))
    }
  }

  function asUint136Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint136 ret, uint nextOffset) {
    (ret, nextOffset) = asUint136MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint144CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint144 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 18)
      ret := shr(112, calldataload(add(encoded.offset, offset)))
    }
  }

  function asUint144Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint144 ret, uint nextOffset) {
    (ret, nextOffset) = asUint144CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint144MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint144 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 18)
      ret := mload(add(encoded, nextOffset))
    }
  }

  function asUint144Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint144 ret, uint nextOffset) {
    (ret, nextOffset) = asUint144MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint152CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint152 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 19)
      ret := shr(104, calldataload(add(encoded.offset, offset)))
    }
  }

  function asUint152Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint152 ret, uint nextOffset) {
    (ret, nextOffset) = asUint152CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint152MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint152 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 19)
      ret := mload(add(encoded, nextOffset))
    }
  }

  function asUint152Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint152 ret, uint nextOffset) {
    (ret, nextOffset) = asUint152MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint160CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint160 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 20)
      ret := shr(96, calldataload(add(encoded.offset, offset)))
    }
  }

  function asUint160Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint160 ret, uint nextOffset) {
    (ret, nextOffset) = asUint160CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint160MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint160 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 20)
      ret := mload(add(encoded, nextOffset))
    }
  }

  function asUint160Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint160 ret, uint nextOffset) {
    (ret, nextOffset) = asUint160MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint168CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint168 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 21)
      ret := shr(88, calldataload(add(encoded.offset, offset)))
    }
  }

  function asUint168Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint168 ret, uint nextOffset) {
    (ret, nextOffset) = asUint168CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint168MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint168 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 21)
      ret := mload(add(encoded, nextOffset))
    }
  }

  function asUint168Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint168 ret, uint nextOffset) {
    (ret, nextOffset) = asUint168MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint176CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint176 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 22)
      ret := shr(80, calldataload(add(encoded.offset, offset)))
    }
  }

  function asUint176Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint176 ret, uint nextOffset) {
    (ret, nextOffset) = asUint176CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint176MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint176 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 22)
      ret := mload(add(encoded, nextOffset))
    }
  }

  function asUint176Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint176 ret, uint nextOffset) {
    (ret, nextOffset) = asUint176MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint184CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint184 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 23)
      ret := shr(72, calldataload(add(encoded.offset, offset)))
    }
  }

  function asUint184Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint184 ret, uint nextOffset) {
    (ret, nextOffset) = asUint184CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint184MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint184 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 23)
      ret := mload(add(encoded, nextOffset))
    }
  }

  function asUint184Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint184 ret, uint nextOffset) {
    (ret, nextOffset) = asUint184MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint192CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint192 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 24)
      ret := shr(64, calldataload(add(encoded.offset, offset)))
    }
  }

  function asUint192Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint192 ret, uint nextOffset) {
    (ret, nextOffset) = asUint192CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint192MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint192 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 24)
      ret := mload(add(encoded, nextOffset))
    }
  }

  function asUint192Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint192 ret, uint nextOffset) {
    (ret, nextOffset) = asUint192MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint200CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint200 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 25)
      ret := shr(56, calldataload(add(encoded.offset, offset)))
    }
  }

  function asUint200Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint200 ret, uint nextOffset) {
    (ret, nextOffset) = asUint200CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint200MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint200 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 25)
      ret := mload(add(encoded, nextOffset))
    }
  }

  function asUint200Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint200 ret, uint nextOffset) {
    (ret, nextOffset) = asUint200MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint208CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint208 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 26)
      ret := shr(48, calldataload(add(encoded.offset, offset)))
    }
  }

  function asUint208Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint208 ret, uint nextOffset) {
    (ret, nextOffset) = asUint208CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint208MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint208 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 26)
      ret := mload(add(encoded, nextOffset))
    }
  }

  function asUint208Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint208 ret, uint nextOffset) {
    (ret, nextOffset) = asUint208MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint216CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint216 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 27)
      ret := shr(40, calldataload(add(encoded.offset, offset)))
    }
  }

  function asUint216Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint216 ret, uint nextOffset) {
    (ret, nextOffset) = asUint216CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint216MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint216 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 27)
      ret := mload(add(encoded, nextOffset))
    }
  }

  function asUint216Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint216 ret, uint nextOffset) {
    (ret, nextOffset) = asUint216MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint224CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint224 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 28)
      ret := shr(32, calldataload(add(encoded.offset, offset)))
    }
  }

  function asUint224Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint224 ret, uint nextOffset) {
    (ret, nextOffset) = asUint224CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint224MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint224 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 28)
      ret := mload(add(encoded, nextOffset))
    }
  }

  function asUint224Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint224 ret, uint nextOffset) {
    (ret, nextOffset) = asUint224MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint232CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint232 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 29)
      ret := shr(24, calldataload(add(encoded.offset, offset)))
    }
  }

  function asUint232Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint232 ret, uint nextOffset) {
    (ret, nextOffset) = asUint232CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint232MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint232 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 29)
      ret := mload(add(encoded, nextOffset))
    }
  }

  function asUint232Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint232 ret, uint nextOffset) {
    (ret, nextOffset) = asUint232MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint240CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint240 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 30)
      ret := shr(16, calldataload(add(encoded.offset, offset)))
    }
  }

  function asUint240Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint240 ret, uint nextOffset) {
    (ret, nextOffset) = asUint240CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint240MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint240 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 30)
      ret := mload(add(encoded, nextOffset))
    }
  }

  function asUint240Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint240 ret, uint nextOffset) {
    (ret, nextOffset) = asUint240MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint248CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint248 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 31)
      ret := shr(8, calldataload(add(encoded.offset, offset)))
    }
  }

  function asUint248Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint248 ret, uint nextOffset) {
    (ret, nextOffset) = asUint248CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint248MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint248 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 31)
      ret := mload(add(encoded, nextOffset))
    }
  }

  function asUint248Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint248 ret, uint nextOffset) {
    (ret, nextOffset) = asUint248MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint256CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint256 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 32)
      ret := shr(0, calldataload(add(encoded.offset, offset)))
    }
  }

  function asUint256Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (uint256 ret, uint nextOffset) {
    (ret, nextOffset) = asUint256CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asUint256MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint256 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      nextOffset := add(offset, 32)
      ret := mload(add(encoded, nextOffset))
    }
  }

  function asUint256Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint256 ret, uint nextOffset) {
    (ret, nextOffset) = asUint256MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes1CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes1 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := calldataload(add(encoded.offset, offset))
      nextOffset := add(offset, 1)
    }
  }

  function asBytes1Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes1 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes1CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes1MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes1 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := mload(add(encoded, add(offset, WORD_SIZE)))
      nextOffset := add(offset, 1)
    }
  }

  function asBytes1Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes1 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes1MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes2CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes2 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := calldataload(add(encoded.offset, offset))
      nextOffset := add(offset, 2)
    }
  }

  function asBytes2Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes2 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes2CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes2MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes2 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := mload(add(encoded, add(offset, WORD_SIZE)))
      nextOffset := add(offset, 2)
    }
  }

  function asBytes2Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes2 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes2MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes3CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes3 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := calldataload(add(encoded.offset, offset))
      nextOffset := add(offset, 3)
    }
  }

  function asBytes3Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes3 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes3CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes3MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes3 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := mload(add(encoded, add(offset, WORD_SIZE)))
      nextOffset := add(offset, 3)
    }
  }

  function asBytes3Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes3 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes3MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes4CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes4 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := calldataload(add(encoded.offset, offset))
      nextOffset := add(offset, 4)
    }
  }

  function asBytes4Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes4 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes4CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes4MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes4 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := mload(add(encoded, add(offset, WORD_SIZE)))
      nextOffset := add(offset, 4)
    }
  }

  function asBytes4Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes4 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes4MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes5CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes5 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := calldataload(add(encoded.offset, offset))
      nextOffset := add(offset, 5)
    }
  }

  function asBytes5Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes5 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes5CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes5MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes5 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := mload(add(encoded, add(offset, WORD_SIZE)))
      nextOffset := add(offset, 5)
    }
  }

  function asBytes5Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes5 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes5MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes6CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes6 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := calldataload(add(encoded.offset, offset))
      nextOffset := add(offset, 6)
    }
  }

  function asBytes6Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes6 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes6CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes6MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes6 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := mload(add(encoded, add(offset, WORD_SIZE)))
      nextOffset := add(offset, 6)
    }
  }

  function asBytes6Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes6 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes6MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes7CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes7 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := calldataload(add(encoded.offset, offset))
      nextOffset := add(offset, 7)
    }
  }

  function asBytes7Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes7 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes7CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes7MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes7 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := mload(add(encoded, add(offset, WORD_SIZE)))
      nextOffset := add(offset, 7)
    }
  }

  function asBytes7Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes7 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes7MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes8CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes8 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := calldataload(add(encoded.offset, offset))
      nextOffset := add(offset, 8)
    }
  }

  function asBytes8Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes8 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes8CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes8MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes8 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := mload(add(encoded, add(offset, WORD_SIZE)))
      nextOffset := add(offset, 8)
    }
  }

  function asBytes8Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes8 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes8MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes9CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes9 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := calldataload(add(encoded.offset, offset))
      nextOffset := add(offset, 9)
    }
  }

  function asBytes9Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes9 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes9CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes9MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes9 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := mload(add(encoded, add(offset, WORD_SIZE)))
      nextOffset := add(offset, 9)
    }
  }

  function asBytes9Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes9 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes9MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes10CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes10 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := calldataload(add(encoded.offset, offset))
      nextOffset := add(offset, 10)
    }
  }

  function asBytes10Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes10 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes10CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes10MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes10 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := mload(add(encoded, add(offset, WORD_SIZE)))
      nextOffset := add(offset, 10)
    }
  }

  function asBytes10Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes10 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes10MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes11CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes11 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := calldataload(add(encoded.offset, offset))
      nextOffset := add(offset, 11)
    }
  }

  function asBytes11Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes11 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes11CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes11MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes11 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := mload(add(encoded, add(offset, WORD_SIZE)))
      nextOffset := add(offset, 11)
    }
  }

  function asBytes11Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes11 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes11MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes12CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes12 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := calldataload(add(encoded.offset, offset))
      nextOffset := add(offset, 12)
    }
  }

  function asBytes12Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes12 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes12CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes12MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes12 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := mload(add(encoded, add(offset, WORD_SIZE)))
      nextOffset := add(offset, 12)
    }
  }

  function asBytes12Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes12 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes12MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes13CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes13 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := calldataload(add(encoded.offset, offset))
      nextOffset := add(offset, 13)
    }
  }

  function asBytes13Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes13 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes13CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes13MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes13 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := mload(add(encoded, add(offset, WORD_SIZE)))
      nextOffset := add(offset, 13)
    }
  }

  function asBytes13Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes13 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes13MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes14CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes14 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := calldataload(add(encoded.offset, offset))
      nextOffset := add(offset, 14)
    }
  }

  function asBytes14Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes14 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes14CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes14MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes14 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := mload(add(encoded, add(offset, WORD_SIZE)))
      nextOffset := add(offset, 14)
    }
  }

  function asBytes14Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes14 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes14MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes15CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes15 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := calldataload(add(encoded.offset, offset))
      nextOffset := add(offset, 15)
    }
  }

  function asBytes15Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes15 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes15CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes15MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes15 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := mload(add(encoded, add(offset, WORD_SIZE)))
      nextOffset := add(offset, 15)
    }
  }

  function asBytes15Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes15 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes15MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes16CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes16 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := calldataload(add(encoded.offset, offset))
      nextOffset := add(offset, 16)
    }
  }

  function asBytes16Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes16 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes16CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes16MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes16 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := mload(add(encoded, add(offset, WORD_SIZE)))
      nextOffset := add(offset, 16)
    }
  }

  function asBytes16Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes16 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes16MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes17CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes17 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := calldataload(add(encoded.offset, offset))
      nextOffset := add(offset, 17)
    }
  }

  function asBytes17Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes17 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes17CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes17MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes17 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := mload(add(encoded, add(offset, WORD_SIZE)))
      nextOffset := add(offset, 17)
    }
  }

  function asBytes17Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes17 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes17MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes18CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes18 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := calldataload(add(encoded.offset, offset))
      nextOffset := add(offset, 18)
    }
  }

  function asBytes18Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes18 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes18CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes18MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes18 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := mload(add(encoded, add(offset, WORD_SIZE)))
      nextOffset := add(offset, 18)
    }
  }

  function asBytes18Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes18 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes18MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes19CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes19 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := calldataload(add(encoded.offset, offset))
      nextOffset := add(offset, 19)
    }
  }

  function asBytes19Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes19 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes19CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes19MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes19 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := mload(add(encoded, add(offset, WORD_SIZE)))
      nextOffset := add(offset, 19)
    }
  }

  function asBytes19Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes19 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes19MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes20CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes20 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := calldataload(add(encoded.offset, offset))
      nextOffset := add(offset, 20)
    }
  }

  function asBytes20Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes20 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes20CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes20MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes20 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := mload(add(encoded, add(offset, WORD_SIZE)))
      nextOffset := add(offset, 20)
    }
  }

  function asBytes20Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes20 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes20MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes21CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes21 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := calldataload(add(encoded.offset, offset))
      nextOffset := add(offset, 21)
    }
  }

  function asBytes21Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes21 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes21CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes21MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes21 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := mload(add(encoded, add(offset, WORD_SIZE)))
      nextOffset := add(offset, 21)
    }
  }

  function asBytes21Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes21 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes21MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes22CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes22 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := calldataload(add(encoded.offset, offset))
      nextOffset := add(offset, 22)
    }
  }

  function asBytes22Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes22 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes22CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes22MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes22 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := mload(add(encoded, add(offset, WORD_SIZE)))
      nextOffset := add(offset, 22)
    }
  }

  function asBytes22Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes22 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes22MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes23CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes23 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := calldataload(add(encoded.offset, offset))
      nextOffset := add(offset, 23)
    }
  }

  function asBytes23Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes23 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes23CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes23MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes23 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := mload(add(encoded, add(offset, WORD_SIZE)))
      nextOffset := add(offset, 23)
    }
  }

  function asBytes23Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes23 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes23MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes24CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes24 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := calldataload(add(encoded.offset, offset))
      nextOffset := add(offset, 24)
    }
  }

  function asBytes24Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes24 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes24CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes24MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes24 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := mload(add(encoded, add(offset, WORD_SIZE)))
      nextOffset := add(offset, 24)
    }
  }

  function asBytes24Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes24 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes24MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes25CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes25 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := calldataload(add(encoded.offset, offset))
      nextOffset := add(offset, 25)
    }
  }

  function asBytes25Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes25 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes25CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes25MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes25 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := mload(add(encoded, add(offset, WORD_SIZE)))
      nextOffset := add(offset, 25)
    }
  }

  function asBytes25Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes25 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes25MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes26CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes26 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := calldataload(add(encoded.offset, offset))
      nextOffset := add(offset, 26)
    }
  }

  function asBytes26Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes26 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes26CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes26MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes26 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := mload(add(encoded, add(offset, WORD_SIZE)))
      nextOffset := add(offset, 26)
    }
  }

  function asBytes26Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes26 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes26MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes27CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes27 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := calldataload(add(encoded.offset, offset))
      nextOffset := add(offset, 27)
    }
  }

  function asBytes27Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes27 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes27CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes27MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes27 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := mload(add(encoded, add(offset, WORD_SIZE)))
      nextOffset := add(offset, 27)
    }
  }

  function asBytes27Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes27 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes27MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes28CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes28 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := calldataload(add(encoded.offset, offset))
      nextOffset := add(offset, 28)
    }
  }

  function asBytes28Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes28 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes28CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes28MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes28 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := mload(add(encoded, add(offset, WORD_SIZE)))
      nextOffset := add(offset, 28)
    }
  }

  function asBytes28Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes28 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes28MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes29CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes29 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := calldataload(add(encoded.offset, offset))
      nextOffset := add(offset, 29)
    }
  }

  function asBytes29Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes29 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes29CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes29MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes29 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := mload(add(encoded, add(offset, WORD_SIZE)))
      nextOffset := add(offset, 29)
    }
  }

  function asBytes29Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes29 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes29MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes30CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes30 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := calldataload(add(encoded.offset, offset))
      nextOffset := add(offset, 30)
    }
  }

  function asBytes30Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes30 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes30CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes30MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes30 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := mload(add(encoded, add(offset, WORD_SIZE)))
      nextOffset := add(offset, 30)
    }
  }

  function asBytes30Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes30 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes30MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes31CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes31 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := calldataload(add(encoded.offset, offset))
      nextOffset := add(offset, 31)
    }
  }

  function asBytes31Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes31 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes31CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes31MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes31 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := mload(add(encoded, add(offset, WORD_SIZE)))
      nextOffset := add(offset, 31)
    }
  }

  function asBytes31Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes31 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes31MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes32CdUnchecked(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes32 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := calldataload(add(encoded.offset, offset))
      nextOffset := add(offset, 32)
    }
  }

  function asBytes32Cd(
    bytes calldata encoded,
    uint offset
  ) internal pure returns (bytes32 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes32CdUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }

  function asBytes32MemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes32 ret, uint nextOffset) {
    /// @solidity memory-safe-assembly
    assembly {
      ret := mload(add(encoded, add(offset, WORD_SIZE)))
      nextOffset := add(offset, 32)
    }
  }

  function asBytes32Mem(
    bytes memory encoded,
    uint offset
  ) internal pure returns (bytes32 ret, uint nextOffset) {
    (ret, nextOffset) = asBytes32MemUnchecked(encoded, offset);
    checkBound(nextOffset, encoded.length);
  }
}

// File: lib/wormhole-solidity-sdk/src/interfaces/token/IERC20.sol

pragma solidity ^0.8.0;

//https://eips.ethereum.org/EIPS/eip-20
interface IERC20 {
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

  function totalSupply() external view returns (uint256);
  function balanceOf(address account) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);

  function transfer(address to, uint256 amount) external returns (bool);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

// File: lib/wormhole-solidity-sdk/src/libraries/SafeERC20.sol

pragma solidity ^0.8.4;




//Like OpenZeppelin's SafeERC20.sol, but slimmed down and more gas efficient.
//
//The main difference to OZ's implementation (besides the missing functions) is that we skip the
//  EXTCODESIZE check that OZ does upon successful calls to ensure that an actual contract was
//  called. The rationale for omitting this check is that ultimately the contract using the token
//  has to verify that it "makes sense" for its use case regardless. Otherwise, a random token, or
//  even just a contract that always returns true, could be passed, which makes this check
//  superfluous in the final analysis.
//
//We also save on code size by not duplicating the assembly code in two separate functions.
//  Otoh, we simply swallow revert reasons of failing token operations instead of bubbling them up.
//  This is less clean and makes debugging harder, but is likely still a worthwhile trade-off
//    given the cost in gas and code size.
library SafeERC20 {
  error SafeERC20FailedOperation(address token);

  function safeTransfer(IERC20 token, address to, uint256 value) internal {
    _revertOnFailure(token, abi.encodeCall(token.transfer, (to, value)));
  }

  function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
    _revertOnFailure(token, abi.encodeCall(token.transferFrom, (from, to, value)));
  }

  function forceApprove(IERC20 token, address spender, uint256 value) internal {
    bytes memory approveCall = abi.encodeCall(token.approve, (spender, value));

    if (!_callWithOptionalReturnCheck(token, approveCall)) {
      _revertOnFailure(token, abi.encodeCall(token.approve, (spender, 0)));
      _revertOnFailure(token, approveCall);
    }
  }

  function _callWithOptionalReturnCheck(
    IERC20 token,
    bytes memory encodedCall
  ) private returns (bool success) {
    /// @solidity memory-safe-assembly
    assembly {
      mstore(SCRATCH_SPACE_PTR, 0)
      success := call( //see https://www.evm.codes/?fork=cancun#f1
        gas(),                       //gas
        token,                       //callee
        0,                           //value
        add(encodedCall, WORD_SIZE), //input ptr
        mload(encodedCall),          //input size
        SCRATCH_SPACE_PTR,           //output ptr
        WORD_SIZE                    //output size
      )
      //calls to addresses without code are always successful
      if success {
        success := or(iszero(returndatasize()), mload(SCRATCH_SPACE_PTR))
      }
    }
  }

  function _revertOnFailure(IERC20 token, bytes memory encodedCall) private {
    if (!_callWithOptionalReturnCheck(token, encodedCall))
      revert SafeERC20FailedOperation(address(token));
  }
}

// File: lib/wormhole-solidity-sdk/src/utils/Transfer.sol

pragma solidity ^0.8.19;




error PaymentFailure(address target);

//Note: Always forwards all gas, so consider gas griefing attack opportunities by the recipient.
//Note: Don't use this method if you need events for 0 amount transfers.
function tokenOrNativeTransfer(address tokenOrZeroForNative, address to, uint256 amount) {
  if (amount == 0)
    return;

  if (tokenOrZeroForNative == address(0)) {
    (bool success, ) = to.call{value: amount}(new bytes(0));
    if (!success)
      revert PaymentFailure(to);
  }
  else
    SafeERC20.safeTransfer(IERC20(tokenOrZeroForNative), to, amount);
}

// File: lib/wormhole-solidity-sdk/src/utils/Revert.sol

pragma solidity ^0.8.19;



//bubble up errors from low level calls
function reRevert(bytes memory err) pure {
  assembly ("memory-safe") {
    revert(add(err, WORD_SIZE), mload(err))
  }
}

// File: lib/wormhole-solidity-sdk/src/utils/UniversalAddress.sol

pragma solidity ^0.8.19;

error NotAnEvmAddress(bytes32);

function toUniversalAddress(address addr) pure returns (bytes32 universalAddr) {
  universalAddr = bytes32(uint256(uint160(addr)));
}

function fromUniversalAddress(bytes32 universalAddr) pure returns (address addr) {
  if (bytes12(universalAddr) != 0)
    revert NotAnEvmAddress(universalAddr);

  assembly ("memory-safe") {
    addr := universalAddr
  }
}

// File: lib/wormhole-solidity-sdk/src/utils/Keccak.sol

pragma solidity ^0.8.4;



function keccak256Word(bytes32 word) pure returns (bytes32 hash) {
  /// @solidity memory-safe-assembly
  assembly {
    mstore(SCRATCH_SPACE_PTR, word)
    hash := keccak256(SCRATCH_SPACE_PTR, WORD_SIZE)
  }
}

function keccak256SliceUnchecked(
  bytes memory encoded,
  uint offset,
  uint length
) pure returns (bytes32 hash) {
  /// @solidity memory-safe-assembly
  assembly {
    // The length of the bytes type `length` field is that of a word in memory
    let ptr := add(add(encoded, offset), WORD_SIZE)
    hash := keccak256(ptr, length)
  }
}

function keccak256Cd(
  bytes calldata encoded
) pure returns (bytes32 hash) {
  /// @solidity memory-safe-assembly
  assembly {
    let freeMemory := mload(FREE_MEMORY_PTR)
    calldatacopy(freeMemory, encoded.offset, encoded.length)
    hash := keccak256(freeMemory, encoded.length)
  }
}

// File: lib/wormhole-solidity-sdk/src/utils/EagerOps.sol

pragma solidity ^0.8.4;

//see Optimization.md for rationale on avoiding short-circuiting
function eagerAnd(bool lhs, bool rhs) pure returns (bool ret) {
  /// @solidity memory-safe-assembly
  assembly {
    ret := and(lhs, rhs)
  }
}

//see Optimization.md for rationale on avoiding short-circuiting
function eagerOr(bool lhs, bool rhs) pure returns (bool ret) {
  /// @solidity memory-safe-assembly
  assembly {
    ret := or(lhs, rhs)
  }
}

// File: lib/wormhole-solidity-sdk/src/Utils.sol

pragma solidity ^0.8.4;

// File: lib/wormhole-solidity-sdk/src/libraries/VaaLib.sol

pragma solidity ^0.8.14; //for (bugfixed) support of `using ... global;` syntax for libraries





// ╭─────────────────────────────────────────────────╮
// │ Library for encoding and decoding Wormhole VAAs │
// ╰─────────────────────────────────────────────────╯

// # VAA Format
//
// see:
//  * ../interfaces/IWormhole.sol VM struct (VM = Verified Message)
//  * [CoreBridge](https://github.com/wormhole-foundation/wormhole/blob/c35940ae9689f6df9e983d51425763509b74a80f/ethereum/contracts/Messages.sol#L147)
//  * [Typescript SDK](https://github.com/wormhole-foundation/wormhole-sdk-ts/blob/3cd10030b5e924f0621c7231e24410b8a0946a07/core/definitions/src/vaa/vaa.ts#L32-L51)
//
// ╭──────────┬──────────────────────────────────────────────────────────────────────────────╮
// │ Section  │ Description                                                                  │
// ├──────────┼──────────────────────────────────────────────────────────────────────────────┤
// │ Header   │ version, guardian signature info required to verify the VAA                  │
// │ Envelope │ contains metadata of the emitted message, such as emitter or timestamp       │
// │ Payload  │ the emitted message, raw bytes, no length prefix, consumes remainder of data │
// ╰──────────┴──────────────────────────────────────────────────────────────────────────────╯
// Body = Envelope + Payload
// The VAA body is exactly the information that goes into a published message of the CoreBridge
//   and is what gets keccak256-hashed when calculating the VAA hash (i.e. the header is excluded).
//
// Note:
//   Guardians do _not_ sign the body directly, but rather the hash of the body, i.e. from the PoV
//     of a guardian, the message itself is already only a hash.
//   But [the first step of the ECDSA signature scheme](https://en.wikipedia.org/wiki/Elliptic_Curve_Digital_Signature_Algorithm#Signature_generation_algorithm)
//     is to hash the message, leading to the hash being hashed a second time when signing.
//   Likewise, ecrecover also operates on the hash of the message, rather than the message itself.
//   This means that when verifying guardian signatures of a VAA, the hash that must be passed to
//     ecrecover is the doubly-hashed body.
//
// ╭─────────────────────────────────────── WARNING ───────────────────────────────────────╮
// │ There is an unfortunate inconsistency between the implementation of the CoreBridge on │
// │   EVM, where IWormhole.VM.hash is the *doubly* hashed body [1], while everything else │
// │   only uses the singly-hashed body (see Solana CoreBridge [2] and Typescript SDK [3]) │
// ╰───────────────────────────────────────────────────────────────────────────────────────╯
// [1] https://github.com/wormhole-foundation/wormhole/blob/1dbe8459b96e182932d0dd5ae4b6bbce6f48cb09/ethereum/contracts/Messages.sol#L178-L186
// [2] https://github.com/wormhole-foundation/wormhole/blob/1dbe8459b96e182932d0dd5ae4b6bbce6f48cb09/solana/bridge/program/src/api/post_vaa.rs#L214C4-L244
// [3] https://github.com/wormhole-foundation/wormhole-sdk-ts/blob/3cd10030b5e924f0621c7231e24410b8a0946a07/core/definitions/src/vaa/functions.ts#L189
//
// ## Format in Detail
//
// ╭─────────────┬──────────────────┬──────────────────────────────────────────────────────────────╮
// │    Type     │       Name       │     Description                                              │
// ┝━━━━━━━━━━━━━┷━━━━━━━━━━━━━━━━━━┷━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┥
// │           Header                                                                              │
// ├─────────────┬──────────────────┬──────────────────────────────────────────────────────────────┤
// │    uint8    │ version          │ fixed value of 1 (see HEADER_VERSION below)                  │
// │    uint32   │ guardianSetIndex │ the guardian set that signed the VAA                         │
// │    uint8    │ signatureCount   │ must be greater than guardian set size * 2 / 3 for quorum    │
// │ Signature[] │ signatures       │ signatures of the guardians that signed the VAA              │
// ┝━━━━━━━━━━━━━┷━━━━━━━━━━━━━━━━━━┷━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┥
// │          Signature                                                                            │
// ├─────────────┬──────────────────┬──────────────────────────────────────────────────────────────┤
// │    uint8    │ guardianIndex    │ position of the signing guardian in the guardian set         │
// │   bytes32   │ r                │ ECDSA r value                                                │
// │   bytes32   │ s                │ ECDSA s value                                                │
// │    uint8    │ v                │ encoded: 0/1, decoded: 27/28, see SIGNATURE_RECOVERY_MAGIC   │
// ┝━━━━━━━━━━━━━┷━━━━━━━━━━━━━━━━━━┷━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┥
// │          Envelope                                                                             │
// ├─────────────┬──────────────────┬──────────────────────────────────────────────────────────────┤
// │    uint32   │ timestamp        │ unix timestamp of block containing the emitted message       │
// │    uint32   │ nonce            │ user-defined nonce                                           │
// │    uint16   │ emitterChainId   │ Wormhole (not EVM) chain id of the emitter                   │
// │   bytes32   │ emitterAddress   │ universal address of the emitter                             │
// │    uint64   │ sequence         │ sequence number of the message (counter per emitter)         │
// │    uint8    │ consistencyLevel │ https://wormhole.com/docs/build/reference/consistency-levels │
// ┝━━━━━━━━━━━━━┷━━━━━━━━━━━━━━━━━━┷━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┥
// │          Payload                                                                              │
// ├─────────────┬──────────────────┬──────────────────────────────────────────────────────────────┤
// │    bytes    │ payload          │ emitted message, consumes rest of VAA (no length prefix)     │
// ╰─────────────┴──────────────────┴──────────────────────────────────────────────────────────────╯
//
// # Library
//
// This library is built on top of BytesParsing which is a lot more gas efficient than BytesLib,
//   which is used in the CoreBridge.
//
// It also provides decoding functions for parsing the individual components of the VAA separately
//   and returning them on the stack, rather than as a struct which requires memory allocation.
//
// ## Library Functions & Naming Conventions
//
// All library functions come in 2 flavors:
//   1. Calldata (using the Cd tag)
//   2. Memory (using the Mem tag)
//
// Additionally, most functions also have an additional struct flavor that returns the decoded
//   values in the associated struct (in memory), rather than as individual values (on the stack).
//
// The parameter name `encodedVaa` is used for functions where the bytes are expected to contain
//   a single, full VAA. Otherwise, i.e. for partials or multiple VAAs, the name `encoded` is used.
//
// Like in BytesParsing, the Unchecked function name suffix does not refer to Solidity's `unchecked`
//   keyword, but rather to the fact that no bounds checking is performed. All math is done using
//   unchecked arithmetic because overflows are impossible due to the nature of the VAA format,
//   while we explicitly check for underflows where necessary.
//
// Function names, somewhat redundantly, contain the tag "Vaa" to add clarity and avoid potential
//   name collisions when using the library with a `using ... for bytes` directive.
//
//   Function Base Name  │     Description
//  ─────────────────────┼────────────────────────────────────────────────────────────────────────
//   decodeVmStruct      │ decodes a legacy VM struct (no non-struct flavor available)
//   decodeVaaEssentials │ decodes the emitter, sequence, and payload
//   decodeVaaBody       │ decodes the envelope and payload
//   checkVaaVersion     │
//   skipVaaHeader       │ returns the offset to the envelope
//   calcVaaSingleHash   │ see explanation/WARNING box at the top
//   calcVaaDoubleHash   │ see explanation/WARNING box at the top
//   decodeVaaEnvelope   │
//   decodeVaaPayload    │
//
// encode functions (for testing, converts back into serialized byte array format):
//   * encode (overloaded for each struct)
//   * encodeVaaHeader
//   * encodeVaaEnvelope
//   * encodeVaaBody
//   * encodeVaa
//
// other functions:
//   * asIWormholeSignatures (casting between GuardianSignature and IWormhole.Signature)
//   * asGuardianSignatures (casting between GuardianSignature and IWormhole.Signature)

//Annoyingly, Solidity only allows aliasing of types that are exported on the file level, but not
//  of nested types, see [language grammar](https://docs.soliditylang.org/en/v0.8.28/grammar.html#a4.SolidityParser.importDirective)
//So we (re)define GuardianSignature identically to IWormhole.Signature to avoid the explicit
//  dependency and to provide a better name and do the necessary casts manually using assembly.
//Without the alias, users who want to reference the GuardianSignature type would have to import
//  IWormhole themselves, which breaks the intended encapsulation of this library.
struct GuardianSignature {
  bytes32 r;
  bytes32 s;
  uint8 v;
  uint8 guardianIndex;
}

struct VaaHeader {
  //uint8 version;
  uint32 guardianSetIndex;
  GuardianSignature[] signatures;
}

struct VaaEnvelope {
  uint32 timestamp;
  uint32 nonce;
  uint16 emitterChainId;
  bytes32 emitterAddress;
  uint64 sequence;
  uint8 consistencyLevel;
}

struct VaaBody {
  VaaEnvelope envelope;
  bytes payload;
}

struct Vaa {
  VaaHeader header;
  VaaEnvelope envelope;
  bytes payload;
}

struct VaaEssentials {
  uint16 emitterChainId;
  bytes32 emitterAddress;
  uint64 sequence;
  bytes payload;
}

library VaaLib {
  using BytesParsing for bytes;
  using {BytesParsing.checkBound} for uint;

  error InvalidVersion(uint8 version);

  uint8 internal constant HEADER_VERSION = 1;
  //see https://github.com/wormhole-foundation/wormhole/blob/c35940ae9689f6df9e983d51425763509b74a80f/ethereum/contracts/Messages.sol#L174
  //origin: https://bitcoin.stackexchange.com/a/102382
  uint8 internal constant SIGNATURE_RECOVERY_MAGIC = 27;

  //the following offsets are provided for more eclectic, manual parsing
  uint internal constant HEADER_VERSION_OFFSET = 0;
  uint internal constant HEADER_VERSION_SIZE = 1;

  uint internal constant HEADER_GUARDIAN_SET_INDEX_OFFSET =
    HEADER_VERSION_OFFSET + HEADER_VERSION_SIZE;
  uint internal constant HEADER_GUARDIAN_SET_INDEX_SIZE = 4;

  uint internal constant HEADER_SIGNATURE_COUNT_OFFSET =
    HEADER_GUARDIAN_SET_INDEX_OFFSET + HEADER_GUARDIAN_SET_INDEX_SIZE;
  uint internal constant HEADER_SIGNATURE_COUNT_SIZE = 1;

  uint internal constant HEADER_SIGNATURE_ARRAY_OFFSET =
    HEADER_SIGNATURE_COUNT_OFFSET + HEADER_SIGNATURE_COUNT_SIZE;

  uint internal constant GUARDIAN_SIGNATURE_GUARDIAN_INDEX_OFFSET = 0;
  uint internal constant GUARDIAN_SIGNATURE_GUARDIAN_INDEX_SIZE = 1;

  uint internal constant GUARDIAN_SIGNATURE_R_OFFSET =
    GUARDIAN_SIGNATURE_GUARDIAN_INDEX_OFFSET + GUARDIAN_SIGNATURE_GUARDIAN_INDEX_SIZE;
  uint internal constant GUARDIAN_SIGNATURE_R_SIZE = 32;

  uint internal constant GUARDIAN_SIGNATURE_S_OFFSET =
    GUARDIAN_SIGNATURE_R_OFFSET + GUARDIAN_SIGNATURE_R_SIZE;
  uint internal constant GUARDIAN_SIGNATURE_S_SIZE = 32;

  uint internal constant GUARDIAN_SIGNATURE_V_OFFSET =
    GUARDIAN_SIGNATURE_S_OFFSET + GUARDIAN_SIGNATURE_S_SIZE;
  uint internal constant GUARDIAN_SIGNATURE_V_SIZE = 1;

  uint internal constant GUARDIAN_SIGNATURE_SIZE =
    GUARDIAN_SIGNATURE_V_OFFSET + GUARDIAN_SIGNATURE_V_SIZE;

  uint internal constant ENVELOPE_TIMESTAMP_OFFSET = 0;
  uint internal constant ENVELOPE_TIMESTAMP_SIZE = 4;

  uint internal constant ENVELOPE_NONCE_OFFSET =
    ENVELOPE_TIMESTAMP_OFFSET + ENVELOPE_TIMESTAMP_SIZE;
  uint internal constant ENVELOPE_NONCE_SIZE = 4;

  uint internal constant ENVELOPE_EMITTER_CHAIN_ID_OFFSET =
    ENVELOPE_NONCE_OFFSET + ENVELOPE_NONCE_SIZE;
  uint internal constant ENVELOPE_EMITTER_CHAIN_ID_SIZE = 2;

  uint internal constant ENVELOPE_EMITTER_ADDRESS_OFFSET =
    ENVELOPE_EMITTER_CHAIN_ID_OFFSET + ENVELOPE_EMITTER_CHAIN_ID_SIZE;
  uint internal constant ENVELOPE_EMITTER_ADDRESS_SIZE = 32;

  uint internal constant ENVELOPE_SEQUENCE_OFFSET =
    ENVELOPE_EMITTER_ADDRESS_OFFSET + ENVELOPE_EMITTER_ADDRESS_SIZE;
  uint internal constant ENVELOPE_SEQUENCE_SIZE = 8;

  uint internal constant ENVELOPE_CONSISTENCY_LEVEL_OFFSET =
    ENVELOPE_SEQUENCE_OFFSET + ENVELOPE_SEQUENCE_SIZE;
  uint internal constant ENVELOPE_CONSISTENCY_LEVEL_SIZE = 1;

  uint internal constant ENVELOPE_SIZE =
    ENVELOPE_CONSISTENCY_LEVEL_OFFSET + ENVELOPE_CONSISTENCY_LEVEL_SIZE;

  // ------------ Convenience Decoding Functions ------------

  //legacy decoder for IWormhole.VM
  function decodeVmStructCd(
    bytes calldata encodedVaa
  ) internal pure returns (IWormhole.VM memory vm) {
    vm.version = HEADER_VERSION;
    uint envelopeOffset;
    GuardianSignature[] memory signatures;
    (vm.guardianSetIndex, signatures, envelopeOffset) = decodeVaaHeaderCdUnchecked(encodedVaa);
    vm.signatures = asIWormholeSignatures(signatures);
    vm.hash = calcVaaDoubleHashCd(encodedVaa, envelopeOffset);
    ( vm.timestamp,
      vm.nonce,
      vm.emitterChainId,
      vm.emitterAddress,
      vm.sequence,
      vm.consistencyLevel,
      vm.payload
    ) = decodeVaaBodyCd(encodedVaa, envelopeOffset);
  }

  function decodeVmStructMem(
    bytes memory encodedVaa
  ) internal pure returns (IWormhole.VM memory vm) {
    (vm, ) = decodeVmStructMemUnchecked(encodedVaa, 0, encodedVaa.length);
  }

  function decodeVaaStructCd(
    bytes calldata encodedVaa
  ) internal pure returns (Vaa memory vaa) {
    uint envelopeOffset;
    (vaa.header, envelopeOffset) = decodeVaaHeaderStructCdUnchecked(encodedVaa);

    uint payloadOffset;
    (vaa.envelope, payloadOffset) = decodeVaaEnvelopeStructCdUnchecked(encodedVaa, envelopeOffset);
    vaa.payload = decodeVaaPayloadCd(encodedVaa, payloadOffset);
  }

  function decodeVaaStructMem(
    bytes memory encodedVaa
  ) internal pure returns (Vaa memory vaa) {
    (vaa, ) = decodeVaaStructMemUnchecked(encodedVaa, 0, encodedVaa.length);
  }

  function decodeVaaEssentialsCd(
    bytes calldata encodedVaa
  ) internal pure returns (
    uint16  emitterChainId,
    bytes32 emitterAddress,
    uint64  sequence,
    bytes calldata payload
  ) { unchecked {
    checkVaaVersionCd(encodedVaa);

    uint envelopeOffset = skipVaaHeaderCd(encodedVaa);
    uint offset = envelopeOffset + ENVELOPE_EMITTER_CHAIN_ID_OFFSET;
    (emitterChainId, offset) = encodedVaa.asUint16CdUnchecked(offset);
    (emitterAddress, offset) = encodedVaa.asBytes32CdUnchecked(offset);
    (sequence,             ) = encodedVaa.asUint64CdUnchecked(offset);

    uint payloadOffset = envelopeOffset + ENVELOPE_SIZE;
    payload = decodeVaaPayloadCd(encodedVaa, payloadOffset);
  }}

  function decodeVaaEssentialsStructCd(
    bytes calldata encodedVaa
  ) internal pure returns (VaaEssentials memory ret) {
    (ret.emitterChainId, ret.emitterAddress, ret.sequence, ret.payload) =
      decodeVaaEssentialsCd(encodedVaa);
  }

  //The returned values are considered the essentials because it's important to check the emitter
  //  to avoid spoofing. Also, VAAs that use finalized consistency levels should leverage the
  //  sequence number (on a per emitter basis!) and a bitmap for replay protection rather than the
  //  hashed body because it is more gas efficient (storage slot is likely already dirty).
  function decodeVaaEssentialsMem(
    bytes memory encodedVaa
  ) internal pure returns (
    uint16 emitterChainId,
    bytes32 emitterAddress,
    uint64 sequence,
    bytes memory payload
  ) {
    (emitterChainId, emitterAddress, sequence, payload, ) =
      decodeVaaEssentialsMem(encodedVaa, 0, encodedVaa.length);
  }

  function decodeVaaEssentialsStructMem(
    bytes memory encodedVaa
  ) internal pure returns (VaaEssentials memory ret) {
    (ret.emitterChainId, ret.emitterAddress, ret.sequence, ret.payload, ) =
      decodeVaaEssentialsMem(encodedVaa, 0, encodedVaa.length);
  }

  function decodeVaaEssentialsMem(
    bytes memory encoded,
    uint headerOffset,
    uint vaaLength
  ) internal pure returns (
    uint16  emitterChainId,
    bytes32 emitterAddress,
    uint64  sequence,
    bytes memory payload,
    uint    newOffset
  ) { unchecked {
    uint offset = checkVaaVersionMemUnchecked(encoded, headerOffset);

    uint envelopeOffset = skipVaaHeaderMemUnchecked(encoded, offset);
    offset = envelopeOffset + ENVELOPE_EMITTER_CHAIN_ID_OFFSET;
    (emitterChainId, offset) = encoded.asUint16MemUnchecked(offset);
    (emitterAddress, offset) = encoded.asBytes32MemUnchecked(offset);
    (sequence,             ) = encoded.asUint64MemUnchecked(offset);

    uint payloadOffset = envelopeOffset + ENVELOPE_SIZE;
    (payload, newOffset) = decodeVaaPayloadMemUnchecked(encoded, payloadOffset, vaaLength);
  }}

  function decodeVaaEssentialsStructMem(
    bytes memory encodedVaa,
    uint headerOffset,
    uint vaaLength
  ) internal pure returns (VaaEssentials memory ret, uint newOffset) {
    (ret.emitterChainId, ret.emitterAddress, ret.sequence, ret.payload, newOffset) =
      decodeVaaEssentialsMem(encodedVaa, headerOffset, vaaLength);
  }

  function decodeVaaBodyCd(
    bytes calldata encodedVaa
  ) internal pure returns (
    uint32  timestamp,
    uint32  nonce,
    uint16  emitterChainId,
    bytes32 emitterAddress,
    uint64  sequence,
    uint8   consistencyLevel,
    bytes calldata payload
  ) {
    checkVaaVersionCd(encodedVaa);
    (timestamp, nonce, emitterChainId, emitterAddress, sequence, consistencyLevel, payload) =
      decodeVaaBodyCd(encodedVaa, skipVaaHeaderCd(encodedVaa));
  }

  function decodeVaaBodyStructCd(
    bytes calldata encodedVaa
  ) internal pure returns (VaaBody memory body) {
    ( body.envelope.timestamp,
      body.envelope.nonce,
      body.envelope.emitterChainId,
      body.envelope.emitterAddress,
      body.envelope.sequence,
      body.envelope.consistencyLevel,
      body.payload
    ) = decodeVaaBodyCd(encodedVaa);
  }

  function decodeVaaBodyMem(
    bytes memory encodedVaa
  ) internal pure returns (
    uint32  timestamp,
    uint32  nonce,
    uint16  emitterChainId,
    bytes32 emitterAddress,
    uint64  sequence,
    uint8   consistencyLevel,
    bytes memory payload
  ) {
    checkVaaVersionMemUnchecked(encodedVaa, 0);
    uint envelopeOffset = skipVaaHeaderMemUnchecked(encodedVaa, 0);
    (timestamp, nonce, emitterChainId, emitterAddress, sequence, consistencyLevel, payload, ) =
      decodeVaaBodyMemUnchecked(encodedVaa, envelopeOffset, encodedVaa.length);
  }

  function decodeVaaBodyStructMem(
    bytes memory encodedVaa
  ) internal pure returns (VaaBody memory body) {
    ( body.envelope.timestamp,
      body.envelope.nonce,
      body.envelope.emitterChainId,
      body.envelope.emitterAddress,
      body.envelope.sequence,
      body.envelope.consistencyLevel,
      body.payload,
    ) = decodeVaaBodyMemUnchecked(encodedVaa, 0, encodedVaa.length);
  }

  // Convinience decoding function for token bridge Vaas
  function decodeEmitterChainAndPayloadCdUnchecked(
    bytes calldata encodedVaa
  ) internal pure returns (uint16 emitterChainId, bytes calldata payload) { unchecked {
    checkVaaVersionCd(encodedVaa);
    uint envelopeOffset = skipVaaHeaderCd(encodedVaa);
    uint offset = envelopeOffset + ENVELOPE_EMITTER_CHAIN_ID_OFFSET;
    (emitterChainId, offset) = encodedVaa.asUint16CdUnchecked(offset);
    offset += ENVELOPE_EMITTER_ADDRESS_SIZE + ENVELOPE_SEQUENCE_SIZE + ENVELOPE_CONSISTENCY_LEVEL_SIZE;
    payload = decodeVaaPayloadCd(encodedVaa, offset);
  }}

  function decodeEmitterChainAndPayloadMemUnchecked(
    bytes memory encodedVaa
  ) internal pure returns (uint16 emitterChainId, bytes memory payload) { unchecked {
    checkVaaVersionMemUnchecked(encodedVaa, 0);
    uint envelopeOffset = skipVaaHeaderMemUnchecked(encodedVaa, 0);
    uint offset = envelopeOffset + ENVELOPE_EMITTER_CHAIN_ID_OFFSET;
    (emitterChainId, offset) = encodedVaa.asUint16MemUnchecked(offset);
    offset += ENVELOPE_EMITTER_ADDRESS_SIZE + ENVELOPE_SEQUENCE_SIZE + ENVELOPE_CONSISTENCY_LEVEL_SIZE;
    (payload, ) = decodeVaaPayloadMemUnchecked(encodedVaa, offset, encodedVaa.length);
  }}

  // ------------ Advanced Decoding Functions ------------

  function asIWormholeSignatures(
    GuardianSignature[] memory signatures
  ) internal pure returns (IWormhole.Signature[] memory vmSignatures) {
    assembly ("memory-safe") {
      vmSignatures := signatures
    }
  }

  function asGuardianSignatures(
    IWormhole.Signature[] memory vmSignatures
  ) internal pure returns (GuardianSignature[] memory signatures) {
    assembly ("memory-safe") {
      signatures := vmSignatures
    }
  }

  function checkVaaVersionCd(bytes calldata encodedVaa) internal pure returns (uint newOffset) {
    uint8 version;
    (version, newOffset) = encodedVaa.asUint8CdUnchecked(0);
    checkVaaVersion(version);
  }

  function checkVaaVersionMemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (uint newOffset) {
    uint8 version;
    (version, newOffset) = encoded.asUint8MemUnchecked(offset);
    checkVaaVersion(version);
  }

  function checkVaaVersion(uint8 version) internal pure {
    if (version != HEADER_VERSION)
      revert InvalidVersion(version);
  }

  //return the offset to the start of the envelope/body
  function skipVaaHeaderCd(
    bytes calldata encodedVaa
  ) internal pure returns (uint envelopeOffset) { unchecked {
    (uint sigCount, uint offset) = encodedVaa.asUint8CdUnchecked(HEADER_SIGNATURE_COUNT_OFFSET);
    envelopeOffset = offset + sigCount * GUARDIAN_SIGNATURE_SIZE;
  }}

  function skipVaaHeaderMemUnchecked(
    bytes memory encoded,
    uint headerOffset
  ) internal pure returns (uint envelopeOffset) { unchecked {
    uint offset = headerOffset + HEADER_SIGNATURE_COUNT_OFFSET;
    uint sigCount;
    (sigCount, offset) = encoded.asUint8MemUnchecked(offset);
    envelopeOffset = offset + sigCount * GUARDIAN_SIGNATURE_SIZE;
  }}

  //see WARNING box at the top
  function calcVaaSingleHashCd(
    bytes calldata encodedVaa,
    uint envelopeOffset
  ) internal pure returns (bytes32) {
    return keccak256Cd(_decodeRemainderCd(encodedVaa, envelopeOffset));
  }

  //see WARNING box at the top
  function calcVaaSingleHashMem(
    bytes memory encoded,
    uint envelopeOffset,
    uint vaaLength
  ) internal pure returns (bytes32) { unchecked {
    envelopeOffset.checkBound(vaaLength);
    return keccak256SliceUnchecked(encoded, envelopeOffset, vaaLength - envelopeOffset);
  }}

  //see WARNING box at the top
  function calcSingleHash(Vaa memory vaa) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(encode(vaa.envelope), vaa.payload));
  }

  //see WARNING box at the top
  function calcSingleHash(VaaBody memory body) internal pure returns (bytes32) {
    return keccak256(encode(body));
  }

  //see WARNING box at the top
  //this function matches IWormhole.VM.hash and is what's been used for (legacy) replay protection
  function calcVaaDoubleHashCd(
    bytes calldata encodedVaa,
    uint envelopeOffset
  ) internal pure returns (bytes32) {
    return keccak256Word(calcVaaSingleHashCd(encodedVaa, envelopeOffset));
  }

  //see WARNING box at the top
  function calcVaaDoubleHashMem(
    bytes memory encoded,
    uint envelopeOffset,
    uint vaaLength
  ) internal pure returns (bytes32) {
    return keccak256Word(calcVaaSingleHashMem(encoded, envelopeOffset, vaaLength));
  }

  //see WARNING box at the top
  function calcDoubleHash(Vaa memory vaa) internal pure returns (bytes32) {
    return keccak256Word(calcSingleHash(vaa));
  }

  //see WARNING box at the top
  function calcDoubleHash(VaaBody memory body) internal pure returns (bytes32) {
    return keccak256Word(calcSingleHash(body));
  }

  function decodeVmStructMemUnchecked(
    bytes memory encoded,
    uint headerOffset,
    uint vaaLength
  ) internal pure returns (IWormhole.VM memory vm, uint newOffset) {
    vm.version = HEADER_VERSION;
    uint envelopeOffset;
    GuardianSignature[] memory signatures;
    (vm.guardianSetIndex, signatures, envelopeOffset) =
      decodeVaaHeaderMemUnchecked(encoded, headerOffset);
    vm.signatures = asIWormholeSignatures(signatures);
    vm.hash = calcVaaDoubleHashMem(encoded, envelopeOffset, vaaLength);
    ( vm.timestamp,
      vm.nonce,
      vm.emitterChainId,
      vm.emitterAddress,
      vm.sequence,
      vm.consistencyLevel,
      vm.payload,
      newOffset
    ) = decodeVaaBodyMemUnchecked(encoded, envelopeOffset, vaaLength);
  }

  function decodeVaaStructMemUnchecked(
    bytes memory encoded,
    uint headerOffset,
    uint vaaLength
  ) internal pure returns (Vaa memory vaa, uint newOffset) {
    uint envelopeOffset;
    (vaa.header.guardianSetIndex, vaa.header.signatures, envelopeOffset) =
      decodeVaaHeaderMemUnchecked(encoded, headerOffset);

    uint payloadOffset;
    (vaa.envelope, payloadOffset) = decodeVaaEnvelopeStructMemUnchecked(encoded, envelopeOffset);

    (vaa.payload, newOffset) = decodeVaaPayloadMemUnchecked(encoded, payloadOffset, vaaLength);
  }

  function decodeVaaBodyCd(
    bytes calldata encodedVaa,
    uint envelopeOffset
  ) internal pure returns (
    uint32  timestamp,
    uint32  nonce,
    uint16  emitterChainId,
    bytes32 emitterAddress,
    uint64  sequence,
    uint8   consistencyLevel,
    bytes calldata payload
  ) {
    uint payloadOffset;
    (timestamp, nonce, emitterChainId, emitterAddress, sequence, consistencyLevel, payloadOffset) =
      decodeVaaEnvelopeCdUnchecked(encodedVaa, envelopeOffset);
    payload = decodeVaaPayloadCd(encodedVaa, payloadOffset);
  }

  function decodeVaaBodyStructCd(
    bytes calldata encodedVaa,
    uint envelopeOffset
  ) internal pure returns (VaaBody memory body) {
    ( body.envelope.timestamp,
      body.envelope.nonce,
      body.envelope.emitterChainId,
      body.envelope.emitterAddress,
      body.envelope.sequence,
      body.envelope.consistencyLevel,
      body.payload
    ) = decodeVaaBodyCd(encodedVaa, envelopeOffset);
  }

  function decodeVaaBodyMemUnchecked(
    bytes memory encoded,
    uint envelopeOffset,
    uint vaaLength
  ) internal pure returns (
    uint32  timestamp,
    uint32  nonce,
    uint16  emitterChainId,
    bytes32 emitterAddress,
    uint64  sequence,
    uint8   consistencyLevel,
    bytes memory payload,
    uint    newOffset
  ) {
    uint payloadOffset;
    (timestamp, nonce, emitterChainId, emitterAddress, sequence, consistencyLevel, payloadOffset) =
      decodeVaaEnvelopeMemUnchecked(encoded, envelopeOffset);
    (payload, newOffset) = decodeVaaPayloadMemUnchecked(encoded, payloadOffset, vaaLength);
  }

  function decodeVaaBodyStructMemUnchecked(
    bytes memory encoded,
    uint envelopeOffset,
    uint vaaLength
  ) internal pure returns (VaaBody memory body, uint newOffset) {
    ( body.envelope.timestamp,
      body.envelope.nonce,
      body.envelope.emitterChainId,
      body.envelope.emitterAddress,
      body.envelope.sequence,
      body.envelope.consistencyLevel,
      body.payload,
      newOffset
    ) = decodeVaaBodyMemUnchecked(encoded, envelopeOffset, vaaLength);
  }

  function decodeVaaEnvelopeCdUnchecked(
    bytes calldata encodedVaa,
    uint envelopeOffset
  ) internal pure returns (
    uint32  timestamp,
    uint32  nonce,
    uint16  emitterChainId,
    bytes32 emitterAddress,
    uint64  sequence,
    uint8   consistencyLevel,
    uint    payloadOffset
  ) {
    uint offset = envelopeOffset;
    (timestamp,        offset) = encodedVaa.asUint32CdUnchecked(offset);
    (nonce,            offset) = encodedVaa.asUint32CdUnchecked(offset);
    (emitterChainId,   offset) = encodedVaa.asUint16CdUnchecked(offset);
    (emitterAddress,   offset) = encodedVaa.asBytes32CdUnchecked(offset);
    (sequence,         offset) = encodedVaa.asUint64CdUnchecked(offset);
    (consistencyLevel, offset) = encodedVaa.asUint8CdUnchecked(offset);
    payloadOffset = offset;
  }

  function decodeVaaEnvelopeStructCdUnchecked(
    bytes calldata encodedVaa,
    uint envelopeOffset
  ) internal pure returns (VaaEnvelope memory envelope, uint payloadOffset) {
    ( envelope.timestamp,
      envelope.nonce,
      envelope.emitterChainId,
      envelope.emitterAddress,
      envelope.sequence,
      envelope.consistencyLevel,
      payloadOffset
    ) = decodeVaaEnvelopeCdUnchecked(encodedVaa, envelopeOffset);
  }

  function decodeVaaEnvelopeMemUnchecked(
    bytes memory encoded,
    uint envelopeOffset
  ) internal pure returns (
    uint32  timestamp,
    uint32  nonce,
    uint16  emitterChainId,
    bytes32 emitterAddress,
    uint64  sequence,
    uint8   consistencyLevel,
    uint    payloadOffset
  ) {
    uint offset = envelopeOffset;
    (timestamp,        offset) = encoded.asUint32MemUnchecked(offset);
    (nonce,            offset) = encoded.asUint32MemUnchecked(offset);
    (emitterChainId,   offset) = encoded.asUint16MemUnchecked(offset);
    (emitterAddress,   offset) = encoded.asBytes32MemUnchecked(offset);
    (sequence,         offset) = encoded.asUint64MemUnchecked(offset);
    (consistencyLevel, offset) = encoded.asUint8MemUnchecked(offset);
    payloadOffset = offset;
  }

  function decodeVaaEnvelopeStructMemUnchecked(
    bytes memory encoded,
    uint envelopeOffset
  ) internal pure returns (VaaEnvelope memory envelope, uint payloadOffset) {
    ( envelope.timestamp,
      envelope.nonce,
      envelope.emitterChainId,
      envelope.emitterAddress,
      envelope.sequence,
      envelope.consistencyLevel,
      payloadOffset
    ) = decodeVaaEnvelopeMemUnchecked(encoded, envelopeOffset);
  }

  function decodeVaaHeaderCdUnchecked(
    bytes calldata encodedVaa
  ) internal pure returns (
    uint32 guardianSetIndex,
    GuardianSignature[] memory signatures,
    uint envelopeOffset
  ) { unchecked {
    checkVaaVersionCd(encodedVaa);
    uint offset = HEADER_GUARDIAN_SET_INDEX_OFFSET;
    (guardianSetIndex, offset) = encodedVaa.asUint32CdUnchecked(offset);

    uint signersLen;
    (signersLen, offset) = encodedVaa.asUint8CdUnchecked(offset);

    signatures = new GuardianSignature[](signersLen);
    for (uint i = 0; i < signersLen; ++i)
      (signatures[i], offset) = decodeGuardianSignatureStructCdUnchecked(encodedVaa, offset);

    envelopeOffset = offset;
  }}

  function decodeVaaHeaderStructCdUnchecked(
    bytes calldata encodedVaa
  ) internal pure returns (VaaHeader memory header, uint envelopeOffset) {
    ( header.guardianSetIndex,
      header.signatures,
      envelopeOffset
    ) = decodeVaaHeaderCdUnchecked(encodedVaa);
  }

  function decodeVaaHeaderMemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (
    uint32 guardianSetIndex,
    GuardianSignature[] memory signatures,
    uint envelopeOffset
  ) { unchecked {
    offset = checkVaaVersionMemUnchecked(encoded, offset);
    (guardianSetIndex, offset) = encoded.asUint32MemUnchecked(offset);

    uint signersLen;
    (signersLen, offset) = encoded.asUint8MemUnchecked(offset);

    signatures = new GuardianSignature[](signersLen);
    for (uint i = 0; i < signersLen; ++i)
      (signatures[i], offset) = decodeGuardianSignatureStructMemUnchecked(encoded, offset);

    envelopeOffset = offset;
  }}

  function decodeVaaHeaderStructMemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (VaaHeader memory header, uint envelopeOffset) {
    ( header.guardianSetIndex,
      header.signatures,
      envelopeOffset
    ) = decodeVaaHeaderMemUnchecked(encoded, offset);
  }

  function decodeGuardianSignatureCdUnchecked(
    bytes calldata encodedVaa,
    uint offset
  ) internal pure returns (
    uint8 guardianIndex,
    bytes32 r,
    bytes32 s,
    uint8 v,
    uint newOffset
  ) { unchecked {
    (guardianIndex, offset) = encodedVaa.asUint8CdUnchecked(offset);
    (r,             offset) = encodedVaa.asBytes32CdUnchecked(offset);
    (s,             offset) = encodedVaa.asBytes32CdUnchecked(offset);
    (v,             offset) = encodedVaa.asUint8CdUnchecked(offset);
    v += SIGNATURE_RECOVERY_MAGIC;
    newOffset = offset;
  }}

  function decodeGuardianSignatureStructCdUnchecked(
    bytes calldata encodedVaa,
    uint offset
  ) internal pure returns (GuardianSignature memory ret, uint newOffset) {
    (ret.guardianIndex, ret.r, ret.s, ret.v, newOffset) =
      decodeGuardianSignatureCdUnchecked(encodedVaa, offset);
  }

  function decodeGuardianSignatureMemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (
    uint8 guardianIndex,
    bytes32 r,
    bytes32 s,
    uint8 v,
    uint newOffset
  ) { unchecked {
    (guardianIndex, offset) = encoded.asUint8MemUnchecked(offset);
    (r,             offset) = encoded.asBytes32MemUnchecked(offset);
    (s,             offset) = encoded.asBytes32MemUnchecked(offset);
    (v,             offset) = encoded.asUint8MemUnchecked(offset);
    v += SIGNATURE_RECOVERY_MAGIC;
    newOffset = offset;
  }}

  function decodeGuardianSignatureStructMemUnchecked(
    bytes memory encoded,
    uint offset
  ) internal pure returns (GuardianSignature memory ret, uint newOffset) {
    (ret.guardianIndex, ret.r, ret.s, ret.v, newOffset) =
      decodeGuardianSignatureMemUnchecked(encoded, offset);
  }

  function decodeVaaPayloadCd(
    bytes calldata encodedVaa,
    uint payloadOffset
  ) internal pure returns (bytes calldata payload) {
    payload = _decodeRemainderCd(encodedVaa, payloadOffset);
  }

  function decodeVaaPayloadMemUnchecked(
    bytes memory encoded,
    uint payloadOffset,
    uint vaaLength
  ) internal pure returns (bytes memory payload, uint newOffset) { unchecked {
    //check to avoid underflow in following subtraction
    payloadOffset.checkBound(vaaLength);
    (payload, newOffset) = encoded.sliceMemUnchecked(payloadOffset, vaaLength - payloadOffset);
  }}

  // ------------ Encoding ------------

  function encode(IWormhole.VM memory vm) internal pure returns (bytes memory) { unchecked {
    require(vm.version == HEADER_VERSION, "Invalid version");
    return abi.encodePacked(
      encodeVaaHeader(vm.guardianSetIndex, asGuardianSignatures(vm.signatures)),
      vm.timestamp,
      vm.nonce,
      vm.emitterChainId,
      vm.emitterAddress,
      vm.sequence,
      vm.consistencyLevel,
      vm.payload
    );
  }}

  function encodeVaaHeader(
    uint32 guardianSetIndex,
    GuardianSignature[] memory signatures
  ) internal pure returns (bytes memory) {
    bytes memory sigs;
    for (uint i = 0; i < signatures.length; ++i) {
      GuardianSignature memory sig = signatures[i];
      uint8 v = sig.v - SIGNATURE_RECOVERY_MAGIC; //deliberately checked
      sigs = bytes.concat(sigs, abi.encodePacked(sig.guardianIndex, sig.r, sig.s, v));
    }

    return abi.encodePacked(
      HEADER_VERSION,
      guardianSetIndex,
      uint8(signatures.length),
      sigs
    );
  }

  function encode(VaaHeader memory header) internal pure returns (bytes memory) {
    return encodeVaaHeader(header.guardianSetIndex, header.signatures);
  }

  function encodeVaaEnvelope(
    uint32  timestamp,
    uint32  nonce,
    uint16  emitterChainId,
    bytes32 emitterAddress,
    uint64  sequence,
    uint8   consistencyLevel
  ) internal pure returns (bytes memory) {
    return abi.encodePacked(
      timestamp,
      nonce,
      emitterChainId,
      emitterAddress,
      sequence,
      consistencyLevel
    );
  }

  function encode(VaaEnvelope memory envelope) internal pure returns (bytes memory) {
    return encodeVaaEnvelope(
      envelope.timestamp,
      envelope.nonce,
      envelope.emitterChainId,
      envelope.emitterAddress,
      envelope.sequence,
      envelope.consistencyLevel
    );
  }

  function encodeVaaBody(
    uint32  timestamp,
    uint32  nonce,
    uint16  emitterChainId,
    bytes32 emitterAddress,
    uint64  sequence,
    uint8   consistencyLevel,
    bytes memory payload
  ) internal pure returns (bytes memory) {
    return abi.encodePacked(
      encodeVaaEnvelope(
        timestamp,
        nonce,
        emitterChainId,
        emitterAddress,
        sequence,
        consistencyLevel
      ),
      payload
    );
  }

  function encode(VaaBody memory body) internal pure returns (bytes memory) {
    return abi.encodePacked(encode(body.envelope), body.payload);
  }

  function encodeVaa(
    uint32 guardianSetIndex,
    GuardianSignature[] memory signatures,
    uint32  timestamp,
    uint32  nonce,
    uint16  emitterChainId,
    bytes32 emitterAddress,
    uint64  sequence,
    uint8   consistencyLevel,
    bytes memory payload
  ) internal pure returns (bytes memory) {
    return abi.encodePacked(
      encodeVaaHeader(guardianSetIndex, signatures),
      encodeVaaBody(
        timestamp,
        nonce,
        emitterChainId,
        emitterAddress,
        sequence,
        consistencyLevel,
        payload
      )
    );
  }

  function encode(Vaa memory vaa) internal pure returns (bytes memory) {
    return encodeVaa(
      vaa.header.guardianSetIndex,
      vaa.header.signatures,
      vaa.envelope.timestamp,
      vaa.envelope.nonce,
      vaa.envelope.emitterChainId,
      vaa.envelope.emitterAddress,
      vaa.envelope.sequence,
      vaa.envelope.consistencyLevel,
      vaa.payload
    );
  }

  // ------------ Private ------------

  //we use this function over encodedVaa[offset:] to consistently get BytesParsing errors
  function _decodeRemainderCd(
    bytes calldata encodedVaa,
    uint offset
  ) private pure returns (bytes calldata remainder) { unchecked {
    //check to avoid underflow in following subtraction
    offset.checkBound(encodedVaa.length);
    (remainder, ) = encodedVaa.sliceCdUnchecked(offset, encodedVaa.length - offset);
  }}
}

using VaaLib for VaaHeader global;
using VaaLib for VaaEnvelope global;
using VaaLib for VaaBody global;
using VaaLib for Vaa global;

// File: src/interfaces/IBridgeAdapter.sol

pragma solidity 0.8.28;

interface IBridgeAdapter {
    event InBridgeTransferAuthorized(bytes32 indexed messageHash);
    event OutBridgeTransferCancelled(uint256 indexed transferId);
    event InBridgeTransferClaimed(uint256 indexed transferId);
    event InBridgeTransferReceived(uint256 indexed transferId);
    event OutBridgeTransferSent(uint256 indexed transferId);
    event OutBridgeTransferScheduled(uint256 indexed transferId, bytes32 indexed messageHash);
    event PendingFundsWithdrawn(address indexed token, uint256 amount);

    struct OutBridgeTransfer {
        address recipient;
        uint256 destinationChainId;
        address inputToken;
        uint256 inputAmount;
        address outputToken;
        uint256 minOutputAmount;
        bytes encodedMessage;
    }

    struct InBridgeTransfer {
        address sender;
        uint256 originChainId;
        address inputToken;
        uint256 inputAmount;
        address outputToken;
        uint256 outputAmount;
    }

    struct BridgeMessage {
        uint256 outTransferId;
        address sender;
        address recipient;
        uint256 originChainId;
        uint256 destinationChainId;
        address inputToken;
        uint256 inputAmount;
        address outputToken;
        uint256 minOutputAmount;
    }

    /// @notice Initializer of the contract.
    /// @param controller The bridge controller contract.
    /// @param initData The optional initialization data.
    function initialize(address controller, bytes calldata initData) external;

    /// @notice Address of the bridge controller contract.
    function controller() external view returns (address);

    /// @notice ID of the adapted external bridge.
    function bridgeId() external view returns (uint16);

    /// @notice Address of the external bridge approval target contract.
    function approvalTarget() external view returns (address);

    /// @notice Address of the external bridge execution target contract.
    function executionTarget() external view returns (address);

    /// @notice Address of the external bridge contract responsible for sending output funds.
    function receiveSource() external view returns (address);

    /// @notice ID of the next outgoing transfer.
    function nextOutTransferId() external view returns (uint256);

    /// @notice ID of the next incoming transfer.
    function nextInTransferId() external view returns (uint256);

    /// @notice Schedules an outgoing bridge transfer and returns the message hash.
    /// @dev Emits an event containing the id of the transfer and the hash of the bridge transfer message.
    /// @param destinationChainId The ID of the destination chain.
    /// @param recipient The address of the recipient on the destination chain.
    /// @param inputToken The address of the input token.
    /// @param inputAmount The amount of the input token to transfer.
    /// @param outputToken The address of the output token on the destination chain.
    /// @param minOutputAmount The minimum amount of the output token to receive.
    function scheduleOutBridgeTransfer(
        uint256 destinationChainId,
        address recipient,
        address inputToken,
        uint256 inputAmount,
        address outputToken,
        uint256 minOutputAmount
    ) external;

    /// @notice Executes a scheduled outgoing bridge transfer.
    /// @param transferId The ID of the transfer to execute.
    /// @param data The optional data needed to execute the transfer.
    function sendOutBridgeTransfer(uint256 transferId, bytes calldata data) external;

    /// @notice Returns the default amount that must be transferred to the adapter to cancel an outgoing bridge transfer.
    /// @dev If the transfer has not yet been sent, or if the full amount was refunded to this contract by the external bridge, returns 0.
    /// @dev If the bridge retains a fee upon cancellation and only a partial refund was received, the returned value reflects that fee.
    /// @dev In all other cases (e.g. including pending refunds or successful bridge transfers), returns the full amount of the transfer.
    /// @param transferId The ID of the transfer to check.
    /// @return The amount required to cancel the transfer.
    function outBridgeTransferCancelDefault(uint256 transferId) external view returns (uint256);

    /// @notice Cancels an outgoing bridge transfer.
    /// @param transferId The ID of the transfer to cancel.
    function cancelOutBridgeTransfer(uint256 transferId) external;

    /// @notice Registers a message hash as authorized for an incoming bridge transfer.
    /// @param messageHash The hash of the message to authorize.
    function authorizeInBridgeTransfer(bytes32 messageHash) external;

    /// @notice Transfers a received bridge transfer out of the adapter.
    /// @param transferId The ID of the transfer to claim.
    function claimInBridgeTransfer(uint256 transferId) external;

    /// @notice Resets internal state for a given token address, and transfers token balance to associated controller.
    /// @dev This function is intended to be used by the DAO to unlock funds stuck in the adapter, typically
    /// in response to operator deviations or external bridge discrepancies.
    /// @param token The address of the token.
    function withdrawPendingFunds(address token) external;
}

// File: src/interfaces/IBridgeController.sol

pragma solidity 0.8.28;

interface IBridgeController {
    event BridgeAdapterCreated(uint16 indexed bridgeId, address indexed adapter);
    event MaxBridgeLossBpsChanged(
        uint16 indexed bridgeId, uint256 indexed oldMaxBridgeLossBps, uint256 indexed newMaxBridgeLossBps
    );
    event BridgingStateReset(address indexed token);
    event OutTransferEnabledSet(uint256 indexed bridgeId, bool enabled);

    /// @notice Bridge ID => Is bridge adapter deployed.
    function isBridgeSupported(uint16 bridgeId) external view returns (bool);

    /// @notice Bridge ID => Is outgoing transfer enabled.
    function isOutTransferEnabled(uint16 bridgeId) external view returns (bool);

    /// @notice Bridge ID => Address of the associated bridge adapter.
    function getBridgeAdapter(uint16 bridgeId) external view returns (address);

    /// @notice Bridge ID => Max allowed value loss in basis points for transfers via this bridge.
    function getMaxBridgeLossBps(uint16 bridgeId) external view returns (uint256);

    /// @notice Deploys a new BridgeAdapter instance.
    /// @param bridgeId The ID of the bridge.
    /// @param initialMaxBridgeLossBps The initial maximum allowed value loss in basis points for transfers via this bridge.
    /// @param initData The optional initialization data for the bridge adapter.
    /// @return The address of the deployed BridgeAdapter.
    function createBridgeAdapter(uint16 bridgeId, uint256 initialMaxBridgeLossBps, bytes calldata initData)
        external
        returns (address);

    /// @notice Sets the maximum allowed value loss in basis points for transfers via this bridge.
    /// @param bridgeId The ID of the bridge.
    /// @param maxBridgeLossBps The maximum allowed value loss in basis points.
    function setMaxBridgeLossBps(uint16 bridgeId, uint256 maxBridgeLossBps) external;

    /// @notice Sets the outgoing transfer enabled status for a bridge.
    /// @param bridgeId The ID of the bridge.
    /// @param enabled True to enable outgoing transfer for the given bridge ID, false to disable.
    function setOutTransferEnabled(uint16 bridgeId, bool enabled) external;

    /// @notice Executes a scheduled outgoing bridge transfer.
    /// @param bridgeId The ID of the bridge.
    /// @param transferId The ID of the transfer to execute.
    /// @param data The optional data needed to execute the transfer.
    function sendOutBridgeTransfer(uint16 bridgeId, uint256 transferId, bytes calldata data) external;

    /// @notice Registers a message hash as authorized for an incoming bridge transfer.
    /// @param bridgeId The ID of the bridge.
    /// @param messageHash The hash of the message to authorize.
    function authorizeInBridgeTransfer(uint16 bridgeId, bytes32 messageHash) external;

    /// @notice Transfers a received bridge transfer out of the adapter.
    /// @param bridgeId The ID of the bridge.
    /// @param transferId The ID of the transfer to claim.
    function claimInBridgeTransfer(uint16 bridgeId, uint256 transferId) external;

    /// @notice Cancels an outgoing bridge transfer.
    /// @param bridgeId The ID of the bridge.
    /// @param transferId The ID of the transfer to cancel.
    function cancelOutBridgeTransfer(uint16 bridgeId, uint256 transferId) external;

    /// @notice Resets internal bridge counters for a given token, and withdraw token balances held by all bridge adapters.
    /// @dev This function is intended to be used by the DAO to realign bridge accounting state and maintain protocol consistency,
    ///      typically in response to operator deviations, external bridge discrepancies, or unbounded counter growth.
    /// @param token The address of the token.
    function resetBridgingState(address token) external;
}

// File: src/interfaces/ISwapModule.sol

pragma solidity 0.8.28;

interface ISwapModule {
    event Swap(
        address indexed sender,
        uint16 swapperId,
        address indexed inputToken,
        address indexed outputToken,
        uint256 inputAmount,
        uint256 outputAmount
    );
    event SwapperTargetsSet(uint16 indexed swapper, address approvalTarget, address executionTarget);

    struct SwapperTargets {
        address approvalTarget;
        address executionTarget;
    }

    /// @notice Swap order object.
    /// @param swapperId The ID of the external swap protocol.
    /// @param data The swap calldata to pass to the swapper's execution target.
    /// @param inputToken The input token.
    /// @param outputToken The output token.
    /// @param inputAmount The input amount.
    /// @param minOutputAmount The minimum expected output amount.
    struct SwapOrder {
        uint16 swapperId;
        bytes data;
        address inputToken;
        address outputToken;
        uint256 inputAmount;
        uint256 minOutputAmount;
    }

    /// @notice Returns approval and execution targets for a given swapper ID.
    /// @param swapperId The swapper ID.
    /// @return approvalTarget The approval target.
    /// @return executionTarget The execution target.
    function getSwapperTargets(uint16 swapperId)
        external
        view
        returns (address approvalTarget, address executionTarget);

    /// @notice Swaps tokens using a given swapper.
    /// @param order The swap order object.
    function swap(SwapOrder calldata order) external returns (uint256);

    /// @notice Sets approval and execution targets for a given swapper ID.
    /// @param swapperId The swapper ID.
    /// @param approvalTarget The approval target.
    function setSwapperTargets(uint16 swapperId, address approvalTarget, address executionTarget) external;
}

// File: src/interfaces/ICaliber.sol

pragma solidity 0.8.28;



interface ICaliber {
    event BaseTokenAdded(address indexed token);
    event BaseTokenRemoved(address indexed token);
    event CooldownDurationChanged(uint256 indexed oldDuration, uint256 indexed newDuration);
    event IncomingTransfer(address indexed token, uint256 amount);
    event InstrRootGuardianAdded(address indexed newGuardian);
    event InstrRootGuardianRemoved(address indexed guardian);
    event MaxPositionDecreaseLossBpsChanged(
        uint256 indexed oldMaxPositionDecreaseLossBps, uint256 indexed newMaxPositionDecreaseLossBps
    );
    event MaxPositionIncreaseLossBpsChanged(
        uint256 indexed oldMaxPositionIncreaseLossBps, uint256 indexed newMaxPositionIncreaseLossBps
    );
    event MaxSwapLossBpsChanged(uint256 indexed oldMaxSwapLossBps, uint256 indexed newMaxSwapLossBps);
    event NewAllowedInstrRootCancelled(bytes32 indexed cancelledMerkleRoot);
    event NewAllowedInstrRootScheduled(bytes32 indexed newMerkleRoot, uint256 indexed effectiveTime);
    event PositionClosed(uint256 indexed id);
    event PositionCreated(uint256 indexed id, uint256 value);
    event PositionUpdated(uint256 indexed id, uint256 value);
    event PositionStaleThresholdChanged(uint256 indexed oldThreshold, uint256 indexed newThreshold);
    event TimelockDurationChanged(uint256 indexed oldDuration, uint256 indexed newDuration);
    event TransferToHubMachine(address indexed token, uint256 amount);

    enum InstructionType {
        MANAGEMENT,
        ACCOUNTING,
        HARVEST,
        FLASHLOAN_MANAGEMENT
    }

    /// @notice Initialization parameters.
    /// @param initialPositionStaleThreshold The position accounting staleness threshold in seconds.
    /// @param initialAllowedInstrRoot The root of the Merkle tree containing allowed instructions.
    /// @param initialTimelockDuration The duration of the allowedInstrRoot update timelock.
    /// @param initialMaxPositionIncreaseLossBps The max allowed value loss (in basis point) for position increases.
    /// @param initialMaxPositionDecreaseLossBps The max allowed value loss (in basis point) for position decreases.
    /// @param initialMaxSwapLossBps The max allowed value loss (in basis point) for base token swaps.
    /// @param initialCooldownDuration The duration of the cooldown period for swaps and position management.
    struct CaliberInitParams {
        uint256 initialPositionStaleThreshold;
        bytes32 initialAllowedInstrRoot;
        uint256 initialTimelockDuration;
        uint256 initialMaxPositionIncreaseLossBps;
        uint256 initialMaxPositionDecreaseLossBps;
        uint256 initialMaxSwapLossBps;
        uint256 initialCooldownDuration;
    }

    /// @notice Instruction parameters.
    /// @param positionId The ID of the involved position.
    /// @param isDebt Whether the position is a debt.
    /// @param groupId The ID of the position accounting group.
    ///        Set to 0 if the instruction is not of type ACCOUNTING, or if the involved position is ungrouped.
    /// @param instructionType The type of the instruction.
    /// @param affectedTokens The array of affected tokens.
    /// @param commands The array of commands.
    /// @param state The array of state.
    /// @param stateBitmap The state bitmap.
    /// @param merkleProof The array of Merkle proof elements.
    struct Instruction {
        uint256 positionId;
        bool isDebt;
        uint256 groupId;
        InstructionType instructionType;
        address[] affectedTokens;
        bytes32[] commands;
        bytes[] state;
        uint128 stateBitmap;
        bytes32[] merkleProof;
    }

    /// @notice Position data.
    /// @param lastAccountingTime The last block timestamp when the position was accounted for.
    /// @param value The value of the position expressed in accounting token.
    /// @param isDebt Whether the position is a debt.
    struct Position {
        uint256 lastAccountingTime;
        uint256 value;
        bool isDebt;
    }

    /// @notice Initializer of the contract.
    /// @param cParams The caliber initialization parameters.
    /// @param _accountingToken The address of the accounting token.
    /// @param _hubMachineEndpoint The address of the hub machine endpoints.
    function initialize(CaliberInitParams calldata cParams, address _accountingToken, address _hubMachineEndpoint)
        external;

    /// @notice Address of the Weiroll VM.
    function weirollVm() external view returns (address);

    /// @notice Address of the hub machine endpoint.
    function hubMachineEndpoint() external view returns (address);

    /// @notice Address of the accounting token.
    function accountingToken() external view returns (address);

    /// @notice Maximum duration a position can remain unaccounted for before it is considered stale.
    function positionStaleThreshold() external view returns (uint256);

    /// @notice Root of the Merkle tree containing allowed instructions.
    function allowedInstrRoot() external view returns (bytes32);

    /// @notice Duration of the allowedInstrRoot update timelock.
    function timelockDuration() external view returns (uint256);

    /// @notice Value of the pending allowedInstrRoot, if any.
    function pendingAllowedInstrRoot() external view returns (bytes32);

    /// @notice Effective time of the last scheduled allowedInstrRoot update.
    function pendingTimelockExpiry() external view returns (uint256);

    /// @notice Max allowed value loss (in basis point) when increasing a position.
    function maxPositionIncreaseLossBps() external view returns (uint256);

    /// @notice Max allowed value loss (in basis point) when decreasing a position.
    function maxPositionDecreaseLossBps() external view returns (uint256);

    /// @notice Max allowed value loss (in basis point) for base token swaps.
    function maxSwapLossBps() external view returns (uint256);

    /// @notice Duration of the cooldown period for swaps and position management.
    function cooldownDuration() external view returns (uint256);

    /// @notice Length of the position IDs list.
    function getPositionsLength() external view returns (uint256);

    /// @notice Position index => Position ID
    /// @dev There are no guarantees on the ordering of values inside the Position ID list,
    ///      and it may change when values are added or removed.
    function getPositionId(uint256 idx) external view returns (uint256);

    /// @notice Position ID => Position data
    function getPosition(uint256 id) external view returns (Position memory);

    /// @notice Token => Registered as base token in this caliber
    function isBaseToken(address token) external view returns (bool);

    /// @notice Length of the base tokens list.
    function getBaseTokensLength() external view returns (uint256);

    /// @notice Base token index => Base token address
    /// @dev There are no guarantees on the ordering of values inside the base tokens list,
    ///      and it may change when values are added or removed.
    function getBaseToken(uint256 idx) external view returns (address);

    /// @notice User => Whether the user is a root guardian
    ///      Guardians have veto power over updates of the Merkle root.
    function isInstrRootGuardian(address user) external view returns (bool);

    /// @notice Checks if the accounting age of each position is below the position staleness threshold.
    function isAccountingFresh() external view returns (bool);

    /// @notice Returns the caliber's net AUM along with detailed position and base token breakdowns.
    /// @return netAum The total value of all base token balances and positive positions, minus total debts.
    /// @return positions The array of encoded tuples of the form (positionId, value, isDebt).
    /// @return baseTokens The array of encoded tuples of the form (token, value).
    function getDetailedAum()
        external
        view
        returns (uint256 netAum, bytes[] memory positions, bytes[] memory baseTokens);

    /// @notice Adds a new base token.
    /// @param token The address of the base token.
    function addBaseToken(address token) external;

    /// @notice Removes a base token.
    /// @param token The address of the base token.
    function removeBaseToken(address token) external;

    /// @notice Accounts for a position.
    /// @dev If the position value goes to zero, it is closed.
    /// @param instruction The accounting instruction.
    /// @return value The new position value.
    /// @return change The change in the position value.
    function accountForPosition(Instruction calldata instruction) external returns (uint256 value, int256 change);

    /// @notice Accounts for a batch of positions.
    /// @param instructions The array of accounting instructions.
    /// @param groupIds The array of position group IDs.
    ///        An accounting instruction must be provided for every open position in each specified group.
    ///        If an instruction's groupId corresponds to a group of open positions of size greater than 1,
    ///        the group ID must be included in this array.
    /// @return values The new position values.
    /// @return changes The changes in the position values.
    function accountForPositionBatch(Instruction[] calldata instructions, uint256[] calldata groupIds)
        external
        returns (uint256[] memory values, int256[] memory changes);

    /// @notice Manages a position's state through paired management and accounting instructions
    /// @dev Performs accounting updates and modifies contract storage by:
    /// - Adding new positions to storage when created.
    /// - Removing positions from storage when value reaches zero.
    /// @dev Applies value preservation checks using a validation matrix to prevent
    /// economic inconsistencies between position changes and token flows.
    ///
    /// The matrix evaluates three factors to determine required validations:
    /// - Base Token Inflow - Whether the contract's base token balance increases during operation
    /// - Debt Position - Whether position represents protocol liability (true) vs asset (false)
    /// - Position Δ direction - Direction of position value change (increase/decrease)
    ///
    /// ┌───────────────────┬───────────────┬──────────────────────┬───────────────────────────┐
    /// │ Base Token Inflow │ Debt Position │ Position Δ direction │ Action                    │
    /// ├───────────────────┼───────────────┼──────────────────────┼───────────────────────────┤
    /// │ No                │ No            │ Decrease             │ Revert: Invalid direction │
    /// │ No                │ Yes           │ Increase             │ Revert: Invalid direction │
    /// │ No                │ No            │ Increase             │ Minimum Δ Check           │
    /// │ No                │ Yes           │ Decrease             │ Minimum Δ Check           │
    /// │ Yes               │ No            │ Decrease             │ Maximum Δ Check           │
    /// │ Yes               │ Yes           │ Increase             │ Maximum Δ Check           │
    /// │ Yes               │ No            │ Increase             │ No check (favorable move) │
    /// │ Yes               │ Yes           │ Decrease             │ No check (favorable move) │
    /// └───────────────────┴───────────────┴──────────────────────┴───────────────────────────┘
    /// @param mgmtInstruction The management instruction.
    /// @param acctInstruction The accounting instruction.
    /// @return value The new position value.
    /// @return change The signed position value delta.
    function managePosition(Instruction calldata mgmtInstruction, Instruction calldata acctInstruction)
        external
        returns (uint256 value, int256 change);

    /// @notice Manages a batch of positions.
    /// @dev Convenience function to manage multiple positions in a single transaction.
    /// @param mgmtInstructions The array of management instructions.
    /// @param acctInstructions The array of accounting instructions.
    /// @return values The new position values.
    /// @return changes The changes in the position values.
    function managePositionBatch(Instruction[] calldata mgmtInstructions, Instruction[] calldata acctInstructions)
        external
        returns (uint256[] memory values, int256[] memory changes);

    /// @notice Manages flashLoan funds.
    /// @param instruction The flashLoan management instruction.
    /// @param token The loan token.
    /// @param amount The loan amount.
    function manageFlashLoan(Instruction calldata instruction, address token, uint256 amount) external;

    /// @notice Harvests one or multiple positions.
    /// @param instruction The harvest instruction.
    /// @param swapOrders The array of swap orders to be executed after the harvest.
    function harvest(Instruction calldata instruction, ISwapModule.SwapOrder[] calldata swapOrders) external;

    /// @notice Performs a swap via the swapModule module.
    /// @param order The swap order parameters.
    function swap(ISwapModule.SwapOrder calldata order) external;

    /// @notice Initiates a token transfer to the hub machine.
    /// @param token The address of the token to transfer.
    /// @param amount The amount of tokens to transfer.
    /// @param data ABI-encoded parameters required for bridge-related transfers. Ignored when called from a hub caliber.
    function transferToHubMachine(address token, uint256 amount, bytes calldata data) external;

    /// @notice Instructs the Caliber to pull the specified token amount from the calling hub machine endpoint.
    /// @param token The address of the token being transferred.
    /// @param amount The amount of tokens being transferred.
    function notifyIncomingTransfer(address token, uint256 amount) external;

    /// @notice Sets the position accounting staleness threshold.
    /// @param newPositionStaleThreshold The new threshold in seconds.
    function setPositionStaleThreshold(uint256 newPositionStaleThreshold) external;

    /// @notice Sets the duration of the allowedInstrRoot update timelock.
    /// @param newTimelockDuration The new duration in seconds.
    function setTimelockDuration(uint256 newTimelockDuration) external;

    /// @notice Schedules an update of the root of the Merkle tree containing allowed instructions.
    /// @dev The update will take effect after the timelock duration stored in the contract
    /// at the time of the call.
    /// @param newMerkleRoot The new Merkle root.
    function scheduleAllowedInstrRootUpdate(bytes32 newMerkleRoot) external;

    /// @notice Cancels a scheduled update of the root of the Merkle tree containing allowed instructions.
    /// @dev Reverts if no pending update exists or if the timelock has expired.
    function cancelAllowedInstrRootUpdate() external;

    /// @notice Sets the max allowed value loss for position increases.
    /// @param newMaxPositionIncreaseLossBps The new max value loss in basis points.
    function setMaxPositionIncreaseLossBps(uint256 newMaxPositionIncreaseLossBps) external;

    /// @notice Sets the max allowed value loss for position decreases.
    /// @param newMaxPositionDecreaseLossBps The new max value loss in basis points.
    function setMaxPositionDecreaseLossBps(uint256 newMaxPositionDecreaseLossBps) external;

    /// @notice Sets the max allowed value loss for base token swaps.
    /// @param newMaxSwapLossBps The new max value loss in basis points.
    function setMaxSwapLossBps(uint256 newMaxSwapLossBps) external;

    /// @notice Sets the duration of the cooldown period for swaps and position management.
    /// @param newCooldownDuration The new duration in seconds.
    function setCooldownDuration(uint256 newCooldownDuration) external;

    /// @notice Adds a new guardian for the Merkle tree containing allowed instructions.
    /// @param newGuardian The address of the new guardian.
    function addInstrRootGuardian(address newGuardian) external;

    /// @notice Removes a guardian for the Merkle tree containing allowed instructions.
    /// @param guardian The address of the guardian to remove.
    function removeInstrRootGuardian(address guardian) external;
}

// File: src/interfaces/IChainRegistry.sol

pragma solidity 0.8.28;

/// @notice This interface is used to map EVM chain IDs to Wormhole chain IDs and vice versa.
interface IChainRegistry {
    event ChainIdsRegistered(uint256 indexed evmChainId, uint16 indexed whChainId);

    /// @notice EVM chain ID => Is the chain ID registered
    function isEvmChainIdRegistered(uint256 _evmChainId) external view returns (bool);

    /// @notice Wormhole chain ID => Is the chain ID registered
    function isWhChainIdRegistered(uint16 _whChainId) external view returns (bool);

    /// @notice EVM chain ID => Wormhole chain ID
    function evmToWhChainId(uint256 _evmChainId) external view returns (uint16);

    /// @notice Wormhole chain ID => EVM chain ID
    function whToEvmChainId(uint16 _whChainId) external view returns (uint256);

    /// @notice Associates an EVM chain ID with a Wormhole chain ID in the contract storage.
    /// @param _evmChainId The EVM chain ID.
    /// @param _whChainId The Wormhole chain ID.
    function setChainIds(uint256 _evmChainId, uint16 _whChainId) external;
}

// File: src/interfaces/ICoreRegistry.sol

pragma solidity 0.8.28;

interface ICoreRegistry {
    event BridgeAdapterBeaconChanged(
        uint256 indexed bridgeId, address indexed oldBridgeAdapterBeacon, address indexed newBridgeAdapterBeacon
    );
    event CaliberBeaconChanged(address indexed oldCaliberBeacon, address indexed newCaliberBeacon);
    event CoreFactoryChanged(address indexed oldCoreFactory, address indexed newCoreFactory);
    event FlashLoanModuleChanged(address indexed oldFlashLoanModule, address indexed newFlashLoanModule);
    event OracleRegistryChanged(address indexed oldOracleRegistry, address indexed newOracleRegistry);
    event SwapModuleChanged(address indexed oldSwapModule, address indexed newSwapModule);
    event TokenRegistryChanged(address indexed oldTokenRegistry, address indexed newTokenRegistry);

    /// @notice Address of the core factory.
    function coreFactory() external view returns (address);

    /// @notice Address of the oracle registry.
    function oracleRegistry() external view returns (address);

    /// @notice Address of the token registry.
    function tokenRegistry() external view returns (address);

    /// @notice Address of the swapModule module.
    function swapModule() external view returns (address);

    /// @notice Address of the flashLoan module.
    function flashLoanModule() external view returns (address);

    /// @notice Address of the caliber beacon contract.
    function caliberBeacon() external view returns (address);

    /// @notice Bridge ID => Address of the bridge adapter beacon contract.
    function bridgeAdapterBeacon(uint16 bridgeId) external view returns (address);

    /// @notice Sets the core factory address.
    /// @param _coreFactory The core factory address.
    function setCoreFactory(address _coreFactory) external;

    /// @notice Sets the oracle registry address.
    /// @param _oracleRegistry The oracle registry address.
    function setOracleRegistry(address _oracleRegistry) external;

    /// @notice Sets the token registry address.
    /// @param _tokenRegistry The token registry address.
    function setTokenRegistry(address _tokenRegistry) external;

    /// @notice Sets the swap module address.
    /// @param _swapModule The swapModule address.
    function setSwapModule(address _swapModule) external;

    /// @notice Sets the flashLoan module address.
    /// @param _flashLoanModule The flashLoan module address.
    function setFlashLoanModule(address _flashLoanModule) external;

    /// @notice Sets the caliber beacon address.
    /// @param _caliberBeacon The caliber beacon address.
    function setCaliberBeacon(address _caliberBeacon) external;

    /// @notice Sets the bridge adapter beacon address.
    /// @param bridgeId The bridge ID.
    /// @param _bridgeAdapter The bridge adapter beacon address.
    function setBridgeAdapterBeacon(uint16 bridgeId, address _bridgeAdapter) external;
}

// File: src/interfaces/IHubCoreRegistry.sol

pragma solidity 0.8.28;



interface IHubCoreRegistry is ICoreRegistry {
    event ChainRegistryChanged(address indexed oldChainRegistry, address indexed newChainRegistry);
    event MachineBeaconChanged(address indexed oldMachineBeacon, address indexed newMachineBeacon);
    event PreDepositVaultBeaconChanged(
        address indexed oldPreDepositVaultBeacon, address indexed newPreDepositVaultBeacon
    );

    /// @notice Address of the chain registry.
    function chainRegistry() external view returns (address);

    /// @notice Address of the machine beacon contract.
    function machineBeacon() external view returns (address);

    /// @notice Address of the pre-deposit vault beacon contract.
    function preDepositVaultBeacon() external view returns (address);

    /// @notice Sets the chain registry address.
    /// @param _chainRegistry The chain registry address.
    function setChainRegistry(address _chainRegistry) external;

    /// @notice Sets the machine beacon address.
    /// @param _machineBeacon The machine beacon address.
    function setMachineBeacon(address _machineBeacon) external;

    /// @notice Sets the pre-deposit vault beacon address.
    /// @param _preDepositVaultBeacon The pre-deposit vault beacon address.
    function setPreDepositVaultBeacon(address _preDepositVaultBeacon) external;
}

// File: src/interfaces/IMakinaGovernable.sol

pragma solidity 0.8.28;

interface IMakinaGovernable {
    event MechanicChanged(address indexed oldMechanic, address indexed newMechanic);
    event RecoveryModeChanged(bool recoveryMode);
    event RiskManagerChanged(address indexed oldRiskManager, address indexed newRiskManager);
    event RiskManagerTimelockChanged(address indexed oldRiskManagerTimelock, address indexed newRiskManagerTimelock);
    event SecurityCouncilChanged(address indexed oldSecurityCouncil, address indexed newSecurityCouncil);

    /// @notice Initialization parameters.
    /// @param initialMechanic The address of the initial mechanic.
    /// @param initialSecurityCouncil The address of the initial security council.
    /// @param initialRiskManager The address of the initial risk manager.
    /// @param initialRiskManagerTimelock The address of the initial risk manager timelock.
    /// @param initialAuthority The address of the initial authority.
    struct MakinaGovernableInitParams {
        address initialMechanic;
        address initialSecurityCouncil;
        address initialRiskManager;
        address initialRiskManagerTimelock;
        address initialAuthority;
    }

    /// @notice Address of the mechanic.
    function mechanic() external view returns (address);

    /// @notice Address of the security council.
    function securityCouncil() external view returns (address);

    /// @notice Address of the risk manager.
    function riskManager() external view returns (address);

    /// @notice Address of the risk manager timelock.
    function riskManagerTimelock() external view returns (address);

    /// @notice True if the contract is in recovery mode, false otherwise.
    function recoveryMode() external view returns (bool);

    /// @notice Sets a new mechanic.
    /// @param newMechanic The address of new mechanic.
    function setMechanic(address newMechanic) external;

    /// @notice Sets a new security council.
    /// @param newSecurityCouncil The address of the new security council.
    function setSecurityCouncil(address newSecurityCouncil) external;

    /// @notice Sets a new risk manager.
    /// @param newRiskManager The address of the new risk manager.
    function setRiskManager(address newRiskManager) external;

    /// @notice Sets a new risk manager timelock.
    /// @param newRiskManagerTimelock The address of the new risk manager timelock.
    function setRiskManagerTimelock(address newRiskManagerTimelock) external;

    /// @notice Sets the recovery mode.
    /// @param enabled True to enable recovery mode, false to disable it.
    function setRecoveryMode(bool enabled) external;
}

// File: src/interfaces/IMachineEndpoint.sol

pragma solidity 0.8.28;




interface IMachineEndpoint is IBridgeController, IMakinaGovernable {
    /// @notice Manages the transfer of tokens between a machine and a caliber. The transfer direction depends on the caller.
    /// @param token The address of the token.
    /// @param amount The amount of tokens to transfer.
    /// @param data ABI-encoded parameters required for bridge-related transfers. Ignored for transfers between a machine and its hub caliber.
    function manageTransfer(address token, uint256 amount, bytes calldata data) external;
}

// File: src/interfaces/IMachine.sol

pragma solidity 0.8.28;







interface IMachine is IMachineEndpoint {
    event CaliberStaleThresholdChanged(uint256 indexed oldThreshold, uint256 indexed newThreshold);
    event Deposit(address indexed sender, address indexed receiver, uint256 assets, uint256 shares);
    event DepositorChanged(address indexed oldDepositor, address indexed newDepositor);
    event FeeManagerChanged(address indexed oldFeeManager, address indexed newFeeManager);
    event FeeMintCooldownChanged(uint256 indexed oldFeeMintCooldown, uint256 indexed newFeeMintCooldown);
    event FeesMinted(uint256 shares);
    event MaxFixedFeeAccrualRateChanged(uint256 indexed oldMaxAccrualRate, uint256 indexed newMaxAccrualRate);
    event MaxPerfFeeAccrualRateChanged(uint256 indexed oldMaxAccrualRate, uint256 indexed newMaxAccrualRate);
    event Redeem(address indexed owner, address indexed receiver, uint256 assets, uint256 shares);
    event RedeemerChanged(address indexed oldRedeemer, address indexed newRedeemer);
    event ShareLimitChanged(uint256 indexed oldShareLimit, uint256 indexed newShareLimit);
    event SpokeBridgeAdapterSet(uint256 indexed chainId, uint256 indexed bridgeId, address indexed adapter);
    event SpokeCaliberMailboxSet(uint256 indexed chainId, address indexed caliberMailbox);
    event TotalAumUpdated(uint256 totalAum);
    event TransferToCaliber(uint256 indexed chainId, address indexed token, uint256 amount);

    /// @notice Initialization parameters.
    /// @param initialDepositor The address of the initial depositor.
    /// @param initialRedeemer The address of the initial redeemer.
    /// @param initialFeeManager The address of the initial fee manager.
    /// @param initialCaliberStaleThreshold The caliber accounting staleness threshold in seconds.
    /// @param initialMaxFixedFeeAccrualRate The maximum fixed fee accrual rate per second, 1e18 = 100%.
    /// @param initialMaxPerfFeeAccrualRate The maximum performance fee accrual rate per second, 1e18 = 100%.
    /// @param initialFeeMintCooldown The minimum time to be elapsed between two fee minting events in seconds.
    /// @param initialShareLimit The share cap value.
    struct MachineInitParams {
        address initialDepositor;
        address initialRedeemer;
        address initialFeeManager;
        uint256 initialCaliberStaleThreshold;
        uint256 initialMaxFixedFeeAccrualRate;
        uint256 initialMaxPerfFeeAccrualRate;
        uint256 initialFeeMintCooldown;
        uint256 initialShareLimit;
    }

    /// @dev Internal state structure for a spoke caliber data.
    /// @param mailbox The foreign address of the spoke caliber mailbox.
    /// @param bridgeAdapters The mapping of bridge IDs to their corresponding adapters.
    /// @param timestamp The timestamp of the last accounting.
    /// @param netAum The net AUM of the spoke caliber.
    /// @param positions The list of positions of the spoke caliber, each encoded as abi.encode(positionId, value).
    /// @param baseTokens The list of base tokens of the spoke caliber, each encoded as abi.encode(token, value).
    /// @param caliberBridgesIn The mapping of spoke caliber incoming bridge amounts.
    /// @param caliberBridgesOut The mapping of spoke caliber outgoing bridge amounts.
    /// @param machineBridgesIn The mapping of machine incoming bridge amounts.
    /// @param machineBridgesOut The mapping of machine outgoing bridge amounts.
    struct SpokeCaliberData {
        address mailbox;
        mapping(uint16 bridgeId => address adapter) bridgeAdapters;
        uint256 timestamp;
        uint256 netAum;
        bytes[] positions;
        bytes[] baseTokens;
        EnumerableMap.AddressToUintMap caliberBridgesIn;
        EnumerableMap.AddressToUintMap caliberBridgesOut;
        EnumerableMap.AddressToUintMap machineBridgesIn;
        EnumerableMap.AddressToUintMap machineBridgesOut;
    }

    /// @notice Initializer of the contract.
    /// @param mParams The machine initialization parameters.
    /// @param mgParams The makina governable initialization parameters.
    /// @param _preDepositVault The address of the pre-deposit vault.
    /// @param _shareToken The address of the share token.
    /// @param _accountingToken The address of the accounting token.
    /// @param _hubCaliber The address of the hub caliber.
    function initialize(
        MachineInitParams calldata mParams,
        MakinaGovernableInitParams calldata mgParams,
        address _preDepositVault,
        address _shareToken,
        address _accountingToken,
        address _hubCaliber
    ) external;

    /// @notice Address of the Wormhole Core Bridge.
    function wormhole() external view returns (address);

    /// @notice Address of the depositor.
    function depositor() external view returns (address);

    /// @notice Address of the redeemer.
    function redeemer() external view returns (address);

    /// @notice Address of the share token.
    function shareToken() external view returns (address);

    /// @notice Address of the accounting token.
    function accountingToken() external view returns (address);

    /// @notice Address of the hub caliber.
    function hubCaliber() external view returns (address);

    /// @notice Address of the fee manager.
    function feeManager() external view returns (address);

    /// @notice Maximum duration a caliber can remain unaccounted for before it is considered stale.
    function caliberStaleThreshold() external view returns (uint256);

    /// @notice Maximum fixed fee accrual rate per second used to compute an upper bound on shares to be minted, 1e18 = 100%.
    function maxFixedFeeAccrualRate() external view returns (uint256);

    /// @notice Maximum performance fee accrual rate per second used to compute an upper bound on shares to be minted, 1e18 = 100%.
    function maxPerfFeeAccrualRate() external view returns (uint256);

    /// @notice Minimum time to be elapsed between two fee minting events.
    function feeMintCooldown() external view returns (uint256);

    /// @notice Share token supply limit that cannot be exceeded by new deposits.
    function shareLimit() external view returns (uint256);

    /// @notice Maximum amount of shares that can currently be minted through asset deposits.
    function maxMint() external view returns (uint256);

    /// @notice Maximum amount of accounting tokens that can currently be withdrawn through share redemptions.
    function maxWithdraw() external view returns (uint256);

    /// @notice Last total machine AUM.
    function lastTotalAum() external view returns (uint256);

    /// @notice Timestamp of the last global machine accounting.
    function lastGlobalAccountingTime() external view returns (uint256);

    /// @notice Token => Is the token an idle token.
    function isIdleToken(address token) external view returns (bool);

    /// @notice Number of calibers associated with the machine.
    function getSpokeCalibersLength() external view returns (uint256);

    /// @notice Spoke caliber index => Spoke Chain ID.
    function getSpokeChainId(uint256 idx) external view returns (uint256);

    /// @notice Spoke Chain ID => Spoke caliber's AUM, individual positions values and accounting timestamp.
    function getSpokeCaliberDetailedAum(uint256 chainId)
        external
        view
        returns (uint256 aum, bytes[] memory positions, bytes[] memory baseTokens, uint256 timestamp);

    /// @notice Spoke Chain ID => Spoke Caliber Mailbox Address.
    function getSpokeCaliberMailbox(uint256 chainId) external view returns (address);

    /// @notice Spoke Chain ID => Spoke Bridge ID => Spoke Bridge Adapter.
    function getSpokeBridgeAdapter(uint256 chainId, uint16 bridgeId) external view returns (address);

    /// @notice Returns the amount of shares that the Machine would exchange for the amount of accounting tokens provided.
    /// @param assets The amount of accounting tokens.
    /// @return shares The amount of shares.
    function convertToShares(uint256 assets) external view returns (uint256);

    /// @notice Returns the amount of accounting tokens that the Machine would exchange for the amount of shares provided.
    /// @param shares The amount of shares.
    /// @return assets The amount of accounting tokens.
    function convertToAssets(uint256 shares) external view returns (uint256);

    /// @notice Initiates a token transfers to the hub caliber.
    /// @param token The address of the token to transfer.
    /// @param amount The amount of token to transfer.
    function transferToHubCaliber(address token, uint256 amount) external;

    /// @notice Initiates a token transfers to the spoke caliber.
    /// @param bridgeId The ID of the bridge to use for the transfer.
    /// @param chainId The foreign EVM chain ID of the spoke caliber.
    /// @param token The address of the token to transfer.
    /// @param amount The amount of token to transfer.
    /// @param minOutputAmount The minimum output amount expected from the transfer.
    function transferToSpokeCaliber(
        uint16 bridgeId,
        uint256 chainId,
        address token,
        uint256 amount,
        uint256 minOutputAmount
    ) external;

    /// @notice Updates the total AUM of the machine.
    /// @return totalAum The updated total AUM.
    function updateTotalAum() external returns (uint256);

    /// @notice Deposits accounting tokens into the machine and mints shares to the receiver.
    /// @param assets The amount of accounting tokens to deposit.
    /// @param receiver The receiver of minted shares.
    /// @param minShares The minimum amount of shares to be minted.
    /// @return shares The amount of shares minted.
    function deposit(uint256 assets, address receiver, uint256 minShares) external returns (uint256);

    /// @notice Redeems shares from the machine and transfers accounting tokens to the receiver.
    /// @param shares The amount of shares to redeem.
    /// @param receiver The receiver of the accounting tokens.
    /// @param minAssets The minimum amount of accounting tokens to be transferred.
    /// @return assets The amount of accounting tokens transferred.
    function redeem(uint256 shares, address receiver, uint256 minAssets) external returns (uint256);

    /// @notice Updates spoke caliber accounting data using Wormhole Cross-Chain Queries (CCQ).
    /// @dev Validates the Wormhole CCQ response and guardian signatures before updating state.
    /// @param response The Wormhole CCQ response payload containing the accounting data.
    /// @param signatures The array of Wormhole guardians signatures attesting to the validity of the response.
    function updateSpokeCaliberAccountingData(bytes memory response, GuardianSignature[] memory signatures) external;

    /// @notice Registers a spoke caliber mailbox and related bridge adapters.
    /// @param chainId The foreign EVM chain ID of the spoke caliber.
    /// @param spokeCaliberMailbox The address of the spoke caliber mailbox.
    /// @param bridges The list of bridges supported with the spoke caliber.
    /// @param adapters The list of corresponding adapters for each bridge. Must be the same length as `bridges`.
    function setSpokeCaliber(
        uint256 chainId,
        address spokeCaliberMailbox,
        uint16[] calldata bridges,
        address[] calldata adapters
    ) external;

    /// @notice Registers a spoke bridge adapter.
    /// @param chainId The foreign EVM chain ID of the adapter.
    /// @param bridgeId The ID of the bridge.
    /// @param adapter The foreign address of the bridge adapter.
    function setSpokeBridgeAdapter(uint256 chainId, uint16 bridgeId, address adapter) external;

    /// @notice Sets the depositor address.
    /// @param newDepositor The address of the new depositor.
    function setDepositor(address newDepositor) external;

    /// @notice Sets the redeemer address.
    /// @param newRedeemer The address of the new redeemer.
    function setRedeemer(address newRedeemer) external;

    /// @notice Sets the fee manager address.
    /// @param newFeeManager The address of the new fee manager.
    function setFeeManager(address newFeeManager) external;

    /// @notice Sets the caliber accounting staleness threshold.
    /// @param newCaliberStaleThreshold The new threshold in seconds.
    function setCaliberStaleThreshold(uint256 newCaliberStaleThreshold) external;

    /// @notice Sets the maximum fixed fee accrual rate.
    /// @param newMaxAccrualRate The new maximum fixed fee accrual rate per second, 1e18 = 100%.
    function setMaxFixedFeeAccrualRate(uint256 newMaxAccrualRate) external;

    /// @notice Sets the maximum performance fee accrual rate.
    /// @param newMaxAccrualRate The new maximum performance fee accrual rate per second, 1e18 = 100%.
    function setMaxPerfFeeAccrualRate(uint256 newMaxAccrualRate) external;

    /// @notice Sets the minimum time to be elapsed between two fee minting events.
    /// @param newFeeMintCooldown The new cooldown in seconds.
    function setFeeMintCooldown(uint256 newFeeMintCooldown) external;

    /// @notice Sets the new share token supply limit that cannot be exceeded by new deposits.
    /// @param newShareLimit The new share limit
    function setShareLimit(uint256 newShareLimit) external;
}

// File: lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol

// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.20;



/**
 * @dev Interface for the optional metadata functions from the ERC-20 standard.
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

// File: src/interfaces/IMachineShare.sol

pragma solidity 0.8.28;



interface IMachineShare is IERC20Metadata {
    /// @notice Address of the authorized minter and burner.
    function minter() external view returns (address);

    /// @notice Mints new shares to the specified address.
    /// @param to The recipient of the minted shares.
    /// @param amount The amount of shares to mint.
    function mint(address to, uint256 amount) external;

    /// @notice Burns shares from the specified address.
    /// @param from The owner of the shares to burn.
    /// @param amount The amount of shares to burn.
    function burn(address from, uint256 amount) external;
}

// File: src/interfaces/IOracleRegistry.sol

pragma solidity 0.8.28;

/// @notice An aggregator of Chainlink price feeds that prices tokens in a reference currency (e.g., USD) using up to two feeds.
/// If a direct feed between a base token and the reference currency does not exists, it combines two feeds to compute the price.
///
/// Example:
/// To price Token A in Token B:
/// - If a feed for Token A -> Reference Currency exists, the registry uses that feed.
/// - If Token B lacks a direct feed to the Reference Currency, but feeds for Token B -> Intermediate Token and
///   Intermediate Token -> Reference Currency exist, the registry combines these feeds to derive the price.
/// - Finally, the price Token A -> Token B is calculated using both tokens individual prices in the reference currency.
///
interface IOracleRegistry {
    event FeedRouteRegistered(address indexed token, address indexed feed1, address indexed feed2);
    event FeedStaleThresholdChanged(address indexed feed, uint256 oldThreshold, uint256 newThreshold);

    struct FeedRoute {
        address feed1;
        address feed2;
    }

    /// @notice Feed => Staleness threshold in seconds
    function getFeedStaleThreshold(address feed) external view returns (uint256);

    /// @notice Token => Is feed route registered for the token
    function isFeedRouteRegistered(address token) external view returns (bool);

    /// @notice Gets the price feed route for a given token.
    /// @param token The address of the token for which the price feed route is requested.
    /// @return feed1 The address of the first price feed.
    /// @return feed2 The address of the optional second price feed.
    function getFeedRoute(address token) external view returns (address, address);

    /// @notice Returns the price of one unit of baseToken in terms of quoteToken.
    /// @param baseToken The address of the token for which the price is requested.
    /// @param quoteToken The address of the token in which the price is quoted.
    /// @return price The price of baseToken denominated in quoteToken (expressed in quoteToken decimals).
    function getPrice(address baseToken, address quoteToken) external view returns (uint256);

    /// @notice Sets the price feed route for a given token.
    /// @dev Both feeds, if set, must be Chainlink-interface-compliant.
    /// The combination of feed1 and feed2 must be able to price the token in the reference currency.
    /// If feed2 is set to address(0), the token price in the reference currency is assumed to be returned by feed1.
    /// @param token The address of the token for which the price feed route is set.
    /// @param feed1 The address of the first price feed.
    /// @param stalenessThreshold1 The staleness threshold for the first price feed.
    /// @param feed2 The address of the second price feed. Can be set to address(0).
    /// @param stalenessThreshold2 The staleness threshold for the second price feed. Ignored if feed2 is address(0).
    function setFeedRoute(
        address token,
        address feed1,
        uint256 stalenessThreshold1,
        address feed2,
        uint256 stalenessThreshold2
    ) external;

    /// @notice Sets the price staleness threshold for a given feed.
    /// @param feed The address of the price feed.
    /// @param threshold The value of staleness threshold.
    function setFeedStaleThreshold(address feed, uint256 threshold) external;
}

// File: src/interfaces/IOwnable2Step.sol

pragma solidity 0.8.28;

interface IOwnable2Step {
    function owner() external view returns (address);
    function pendingOwner() external view returns (address);
    function transferOwnership(address newOwner) external;
    function acceptOwnership() external;
}

// File: src/interfaces/ITokenRegistry.sol

pragma solidity 0.8.28;

/// @notice This interface is used to map token addresses from one evm chain to another.
interface ITokenRegistry {
    event TokenRegistered(address indexed localToken, uint256 indexed evmChainId, address indexed foreignToken);

    /// @notice Local token address => Foreign EVM chain ID => Foreign Token address
    function getForeignToken(address _localToken, uint256 _foreignEvmChainId) external view returns (address);

    /// @notice Foreign token address => Foreign EVM chain ID => Local Token address
    function getLocalToken(address _foreignToken, uint256 _foreignEvmChainId) external view returns (address);

    /// @notice Associates a local and a foreign token addresse.
    /// @param _localToken The local token address.
    /// @param _foreignEvmChainId The foreign EVM chain ID.
    /// @param _foreignToken The foreign token address.
    function setToken(address _localToken, uint256 _foreignEvmChainId, address _foreignToken) external;
}

// File: lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/access/manager/IAuthority.sol

// OpenZeppelin Contracts (last updated v5.0.0) (access/manager/IAuthority.sol)

pragma solidity ^0.8.20;

/**
 * @dev Standard interface for permissioning originally defined in Dappsys.
 */
interface IAuthority {
    /**
     * @dev Returns true if the caller can invoke on a target the function identified by a function selector.
     */
    function canCall(address caller, address target, bytes4 selector) external view returns (bool allowed);
}

// File: lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/access/manager/AuthorityUtils.sol

// OpenZeppelin Contracts (last updated v5.0.0) (access/manager/AuthorityUtils.sol)

pragma solidity ^0.8.20;



library AuthorityUtils {
    /**
     * @dev Since `AccessManager` implements an extended IAuthority interface, invoking `canCall` with backwards compatibility
     * for the preexisting `IAuthority` interface requires special care to avoid reverting on insufficient return data.
     * This helper function takes care of invoking `canCall` in a backwards compatible way without reverting.
     */
    function canCallWithDelay(
        address authority,
        address caller,
        address target,
        bytes4 selector
    ) internal view returns (bool immediate, uint32 delay) {
        (bool success, bytes memory data) = authority.staticcall(
            abi.encodeCall(IAuthority.canCall, (caller, target, selector))
        );
        if (success) {
            if (data.length >= 0x40) {
                (immediate, delay) = abi.decode(data, (bool, uint32));
            } else if (data.length >= 0x20) {
                immediate = abi.decode(data, (bool));
            }
        }
        return (immediate, delay);
    }
}

// File: lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/utils/types/Time.sol

// OpenZeppelin Contracts (last updated v5.1.0) (utils/types/Time.sol)

pragma solidity ^0.8.20;




/**
 * @dev This library provides helpers for manipulating time-related objects.
 *
 * It uses the following types:
 * - `uint48` for timepoints
 * - `uint32` for durations
 *
 * While the library doesn't provide specific types for timepoints and duration, it does provide:
 * - a `Delay` type to represent duration that can be programmed to change value automatically at a given point
 * - additional helper functions
 */
library Time {
    using Time for *;

    /**
     * @dev Get the block timestamp as a Timepoint.
     */
    function timestamp() internal view returns (uint48) {
        return SafeCast.toUint48(block.timestamp);
    }

    /**
     * @dev Get the block number as a Timepoint.
     */
    function blockNumber() internal view returns (uint48) {
        return SafeCast.toUint48(block.number);
    }

    // ==================================================== Delay =====================================================
    /**
     * @dev A `Delay` is a uint32 duration that can be programmed to change value automatically at a given point in the
     * future. The "effect" timepoint describes when the transitions happens from the "old" value to the "new" value.
     * This allows updating the delay applied to some operation while keeping some guarantees.
     *
     * In particular, the {update} function guarantees that if the delay is reduced, the old delay still applies for
     * some time. For example if the delay is currently 7 days to do an upgrade, the admin should not be able to set
     * the delay to 0 and upgrade immediately. If the admin wants to reduce the delay, the old delay (7 days) should
     * still apply for some time.
     *
     *
     * The `Delay` type is 112 bits long, and packs the following:
     *
     * ```
     *   | [uint48]: effect date (timepoint)
     *   |           | [uint32]: value before (duration)
     *   ↓           ↓       ↓ [uint32]: value after (duration)
     * 0xAAAAAAAAAAAABBBBBBBBCCCCCCCC
     * ```
     *
     * NOTE: The {get} and {withUpdate} functions operate using timestamps. Block number based delays are not currently
     * supported.
     */
    type Delay is uint112;

    /**
     * @dev Wrap a duration into a Delay to add the one-step "update in the future" feature
     */
    function toDelay(uint32 duration) internal pure returns (Delay) {
        return Delay.wrap(duration);
    }

    /**
     * @dev Get the value at a given timepoint plus the pending value and effect timepoint if there is a scheduled
     * change after this timepoint. If the effect timepoint is 0, then the pending value should not be considered.
     */
    function _getFullAt(
        Delay self,
        uint48 timepoint
    ) private pure returns (uint32 valueBefore, uint32 valueAfter, uint48 effect) {
        (valueBefore, valueAfter, effect) = self.unpack();
        return effect <= timepoint ? (valueAfter, 0, 0) : (valueBefore, valueAfter, effect);
    }

    /**
     * @dev Get the current value plus the pending value and effect timepoint if there is a scheduled change. If the
     * effect timepoint is 0, then the pending value should not be considered.
     */
    function getFull(Delay self) internal view returns (uint32 valueBefore, uint32 valueAfter, uint48 effect) {
        return _getFullAt(self, timestamp());
    }

    /**
     * @dev Get the current value.
     */
    function get(Delay self) internal view returns (uint32) {
        (uint32 delay, , ) = self.getFull();
        return delay;
    }

    /**
     * @dev Update a Delay object so that it takes a new duration after a timepoint that is automatically computed to
     * enforce the old delay at the moment of the update. Returns the updated Delay object and the timestamp when the
     * new delay becomes effective.
     */
    function withUpdate(
        Delay self,
        uint32 newValue,
        uint32 minSetback
    ) internal view returns (Delay updatedDelay, uint48 effect) {
        uint32 value = self.get();
        uint32 setback = uint32(Math.max(minSetback, value > newValue ? value - newValue : 0));
        effect = timestamp() + setback;
        return (pack(value, newValue, effect), effect);
    }

    /**
     * @dev Split a delay into its components: valueBefore, valueAfter and effect (transition timepoint).
     */
    function unpack(Delay self) internal pure returns (uint32 valueBefore, uint32 valueAfter, uint48 effect) {
        uint112 raw = Delay.unwrap(self);

        valueAfter = uint32(raw);
        valueBefore = uint32(raw >> 32);
        effect = uint48(raw >> 64);

        return (valueBefore, valueAfter, effect);
    }

    /**
     * @dev pack the components into a Delay object.
     */
    function pack(uint32 valueBefore, uint32 valueAfter, uint48 effect) internal pure returns (Delay) {
        return Delay.wrap((uint112(effect) << 64) | (uint112(valueBefore) << 32) | uint112(valueAfter));
    }
}

// File: lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/access/manager/IAccessManager.sol

// OpenZeppelin Contracts (last updated v5.1.0) (access/manager/IAccessManager.sol)

pragma solidity ^0.8.20;



interface IAccessManager {
    /**
     * @dev A delayed operation was scheduled.
     */
    event OperationScheduled(
        bytes32 indexed operationId,
        uint32 indexed nonce,
        uint48 schedule,
        address caller,
        address target,
        bytes data
    );

    /**
     * @dev A scheduled operation was executed.
     */
    event OperationExecuted(bytes32 indexed operationId, uint32 indexed nonce);

    /**
     * @dev A scheduled operation was canceled.
     */
    event OperationCanceled(bytes32 indexed operationId, uint32 indexed nonce);

    /**
     * @dev Informational labelling for a roleId.
     */
    event RoleLabel(uint64 indexed roleId, string label);

    /**
     * @dev Emitted when `account` is granted `roleId`.
     *
     * NOTE: The meaning of the `since` argument depends on the `newMember` argument.
     * If the role is granted to a new member, the `since` argument indicates when the account becomes a member of the role,
     * otherwise it indicates the execution delay for this account and roleId is updated.
     */
    event RoleGranted(uint64 indexed roleId, address indexed account, uint32 delay, uint48 since, bool newMember);

    /**
     * @dev Emitted when `account` membership or `roleId` is revoked. Unlike granting, revoking is instantaneous.
     */
    event RoleRevoked(uint64 indexed roleId, address indexed account);

    /**
     * @dev Role acting as admin over a given `roleId` is updated.
     */
    event RoleAdminChanged(uint64 indexed roleId, uint64 indexed admin);

    /**
     * @dev Role acting as guardian over a given `roleId` is updated.
     */
    event RoleGuardianChanged(uint64 indexed roleId, uint64 indexed guardian);

    /**
     * @dev Grant delay for a given `roleId` will be updated to `delay` when `since` is reached.
     */
    event RoleGrantDelayChanged(uint64 indexed roleId, uint32 delay, uint48 since);

    /**
     * @dev Target mode is updated (true = closed, false = open).
     */
    event TargetClosed(address indexed target, bool closed);

    /**
     * @dev Role required to invoke `selector` on `target` is updated to `roleId`.
     */
    event TargetFunctionRoleUpdated(address indexed target, bytes4 selector, uint64 indexed roleId);

    /**
     * @dev Admin delay for a given `target` will be updated to `delay` when `since` is reached.
     */
    event TargetAdminDelayUpdated(address indexed target, uint32 delay, uint48 since);

    error AccessManagerAlreadyScheduled(bytes32 operationId);
    error AccessManagerNotScheduled(bytes32 operationId);
    error AccessManagerNotReady(bytes32 operationId);
    error AccessManagerExpired(bytes32 operationId);
    error AccessManagerLockedRole(uint64 roleId);
    error AccessManagerBadConfirmation();
    error AccessManagerUnauthorizedAccount(address msgsender, uint64 roleId);
    error AccessManagerUnauthorizedCall(address caller, address target, bytes4 selector);
    error AccessManagerUnauthorizedConsume(address target);
    error AccessManagerUnauthorizedCancel(address msgsender, address caller, address target, bytes4 selector);
    error AccessManagerInvalidInitialAdmin(address initialAdmin);

    /**
     * @dev Check if an address (`caller`) is authorised to call a given function on a given contract directly (with
     * no restriction). Additionally, it returns the delay needed to perform the call indirectly through the {schedule}
     * & {execute} workflow.
     *
     * This function is usually called by the targeted contract to control immediate execution of restricted functions.
     * Therefore we only return true if the call can be performed without any delay. If the call is subject to a
     * previously set delay (not zero), then the function should return false and the caller should schedule the operation
     * for future execution.
     *
     * If `immediate` is true, the delay can be disregarded and the operation can be immediately executed, otherwise
     * the operation can be executed if and only if delay is greater than 0.
     *
     * NOTE: The IAuthority interface does not include the `uint32` delay. This is an extension of that interface that
     * is backward compatible. Some contracts may thus ignore the second return argument. In that case they will fail
     * to identify the indirect workflow, and will consider calls that require a delay to be forbidden.
     *
     * NOTE: This function does not report the permissions of the admin functions in the manager itself. These are defined by the
     * {AccessManager} documentation.
     */
    function canCall(
        address caller,
        address target,
        bytes4 selector
    ) external view returns (bool allowed, uint32 delay);

    /**
     * @dev Expiration delay for scheduled proposals. Defaults to 1 week.
     *
     * IMPORTANT: Avoid overriding the expiration with 0. Otherwise every contract proposal will be expired immediately,
     * disabling any scheduling usage.
     */
    function expiration() external view returns (uint32);

    /**
     * @dev Minimum setback for all delay updates, with the exception of execution delays. It
     * can be increased without setback (and reset via {revokeRole} in the case event of an
     * accidental increase). Defaults to 5 days.
     */
    function minSetback() external view returns (uint32);

    /**
     * @dev Get whether the contract is closed disabling any access. Otherwise role permissions are applied.
     *
     * NOTE: When the manager itself is closed, admin functions are still accessible to avoid locking the contract.
     */
    function isTargetClosed(address target) external view returns (bool);

    /**
     * @dev Get the role required to call a function.
     */
    function getTargetFunctionRole(address target, bytes4 selector) external view returns (uint64);

    /**
     * @dev Get the admin delay for a target contract. Changes to contract configuration are subject to this delay.
     */
    function getTargetAdminDelay(address target) external view returns (uint32);

    /**
     * @dev Get the id of the role that acts as an admin for the given role.
     *
     * The admin permission is required to grant the role, revoke the role and update the execution delay to execute
     * an operation that is restricted to this role.
     */
    function getRoleAdmin(uint64 roleId) external view returns (uint64);

    /**
     * @dev Get the role that acts as a guardian for a given role.
     *
     * The guardian permission allows canceling operations that have been scheduled under the role.
     */
    function getRoleGuardian(uint64 roleId) external view returns (uint64);

    /**
     * @dev Get the role current grant delay.
     *
     * Its value may change at any point without an event emitted following a call to {setGrantDelay}.
     * Changes to this value, including effect timepoint are notified in advance by the {RoleGrantDelayChanged} event.
     */
    function getRoleGrantDelay(uint64 roleId) external view returns (uint32);

    /**
     * @dev Get the access details for a given account for a given role. These details include the timepoint at which
     * membership becomes active, and the delay applied to all operation by this user that requires this permission
     * level.
     *
     * Returns:
     * [0] Timestamp at which the account membership becomes valid. 0 means role is not granted.
     * [1] Current execution delay for the account.
     * [2] Pending execution delay for the account.
     * [3] Timestamp at which the pending execution delay will become active. 0 means no delay update is scheduled.
     */
    function getAccess(
        uint64 roleId,
        address account
    ) external view returns (uint48 since, uint32 currentDelay, uint32 pendingDelay, uint48 effect);

    /**
     * @dev Check if a given account currently has the permission level corresponding to a given role. Note that this
     * permission might be associated with an execution delay. {getAccess} can provide more details.
     */
    function hasRole(uint64 roleId, address account) external view returns (bool isMember, uint32 executionDelay);

    /**
     * @dev Give a label to a role, for improved role discoverability by UIs.
     *
     * Requirements:
     *
     * - the caller must be a global admin
     *
     * Emits a {RoleLabel} event.
     */
    function labelRole(uint64 roleId, string calldata label) external;

    /**
     * @dev Add `account` to `roleId`, or change its execution delay.
     *
     * This gives the account the authorization to call any function that is restricted to this role. An optional
     * execution delay (in seconds) can be set. If that delay is non 0, the user is required to schedule any operation
     * that is restricted to members of this role. The user will only be able to execute the operation after the delay has
     * passed, before it has expired. During this period, admin and guardians can cancel the operation (see {cancel}).
     *
     * If the account has already been granted this role, the execution delay will be updated. This update is not
     * immediate and follows the delay rules. For example, if a user currently has a delay of 3 hours, and this is
     * called to reduce that delay to 1 hour, the new delay will take some time to take effect, enforcing that any
     * operation executed in the 3 hours that follows this update was indeed scheduled before this update.
     *
     * Requirements:
     *
     * - the caller must be an admin for the role (see {getRoleAdmin})
     * - granted role must not be the `PUBLIC_ROLE`
     *
     * Emits a {RoleGranted} event.
     */
    function grantRole(uint64 roleId, address account, uint32 executionDelay) external;

    /**
     * @dev Remove an account from a role, with immediate effect. If the account does not have the role, this call has
     * no effect.
     *
     * Requirements:
     *
     * - the caller must be an admin for the role (see {getRoleAdmin})
     * - revoked role must not be the `PUBLIC_ROLE`
     *
     * Emits a {RoleRevoked} event if the account had the role.
     */
    function revokeRole(uint64 roleId, address account) external;

    /**
     * @dev Renounce role permissions for the calling account with immediate effect. If the sender is not in
     * the role this call has no effect.
     *
     * Requirements:
     *
     * - the caller must be `callerConfirmation`.
     *
     * Emits a {RoleRevoked} event if the account had the role.
     */
    function renounceRole(uint64 roleId, address callerConfirmation) external;

    /**
     * @dev Change admin role for a given role.
     *
     * Requirements:
     *
     * - the caller must be a global admin
     *
     * Emits a {RoleAdminChanged} event
     */
    function setRoleAdmin(uint64 roleId, uint64 admin) external;

    /**
     * @dev Change guardian role for a given role.
     *
     * Requirements:
     *
     * - the caller must be a global admin
     *
     * Emits a {RoleGuardianChanged} event
     */
    function setRoleGuardian(uint64 roleId, uint64 guardian) external;

    /**
     * @dev Update the delay for granting a `roleId`.
     *
     * Requirements:
     *
     * - the caller must be a global admin
     *
     * Emits a {RoleGrantDelayChanged} event.
     */
    function setGrantDelay(uint64 roleId, uint32 newDelay) external;

    /**
     * @dev Set the role required to call functions identified by the `selectors` in the `target` contract.
     *
     * Requirements:
     *
     * - the caller must be a global admin
     *
     * Emits a {TargetFunctionRoleUpdated} event per selector.
     */
    function setTargetFunctionRole(address target, bytes4[] calldata selectors, uint64 roleId) external;

    /**
     * @dev Set the delay for changing the configuration of a given target contract.
     *
     * Requirements:
     *
     * - the caller must be a global admin
     *
     * Emits a {TargetAdminDelayUpdated} event.
     */
    function setTargetAdminDelay(address target, uint32 newDelay) external;

    /**
     * @dev Set the closed flag for a contract.
     *
     * Closing the manager itself won't disable access to admin methods to avoid locking the contract.
     *
     * Requirements:
     *
     * - the caller must be a global admin
     *
     * Emits a {TargetClosed} event.
     */
    function setTargetClosed(address target, bool closed) external;

    /**
     * @dev Return the timepoint at which a scheduled operation will be ready for execution. This returns 0 if the
     * operation is not yet scheduled, has expired, was executed, or was canceled.
     */
    function getSchedule(bytes32 id) external view returns (uint48);

    /**
     * @dev Return the nonce for the latest scheduled operation with a given id. Returns 0 if the operation has never
     * been scheduled.
     */
    function getNonce(bytes32 id) external view returns (uint32);

    /**
     * @dev Schedule a delayed operation for future execution, and return the operation identifier. It is possible to
     * choose the timestamp at which the operation becomes executable as long as it satisfies the execution delays
     * required for the caller. The special value zero will automatically set the earliest possible time.
     *
     * Returns the `operationId` that was scheduled. Since this value is a hash of the parameters, it can reoccur when
     * the same parameters are used; if this is relevant, the returned `nonce` can be used to uniquely identify this
     * scheduled operation from other occurrences of the same `operationId` in invocations of {execute} and {cancel}.
     *
     * Emits a {OperationScheduled} event.
     *
     * NOTE: It is not possible to concurrently schedule more than one operation with the same `target` and `data`. If
     * this is necessary, a random byte can be appended to `data` to act as a salt that will be ignored by the target
     * contract if it is using standard Solidity ABI encoding.
     */
    function schedule(
        address target,
        bytes calldata data,
        uint48 when
    ) external returns (bytes32 operationId, uint32 nonce);

    /**
     * @dev Execute a function that is delay restricted, provided it was properly scheduled beforehand, or the
     * execution delay is 0.
     *
     * Returns the nonce that identifies the previously scheduled operation that is executed, or 0 if the
     * operation wasn't previously scheduled (if the caller doesn't have an execution delay).
     *
     * Emits an {OperationExecuted} event only if the call was scheduled and delayed.
     */
    function execute(address target, bytes calldata data) external payable returns (uint32);

    /**
     * @dev Cancel a scheduled (delayed) operation. Returns the nonce that identifies the previously scheduled
     * operation that is cancelled.
     *
     * Requirements:
     *
     * - the caller must be the proposer, a guardian of the targeted function, or a global admin
     *
     * Emits a {OperationCanceled} event.
     */
    function cancel(address caller, address target, bytes calldata data) external returns (uint32);

    /**
     * @dev Consume a scheduled operation targeting the caller. If such an operation exists, mark it as consumed
     * (emit an {OperationExecuted} event and clean the state). Otherwise, throw an error.
     *
     * This is useful for contract that want to enforce that calls targeting them were scheduled on the manager,
     * with all the verifications that it implies.
     *
     * Emit a {OperationExecuted} event.
     */
    function consumeScheduledOp(address caller, bytes calldata data) external;

    /**
     * @dev Hashing function for delayed operations.
     */
    function hashOperation(address caller, address target, bytes calldata data) external view returns (bytes32);

    /**
     * @dev Changes the authority of a target managed by this manager instance.
     *
     * Requirements:
     *
     * - the caller must be a global admin
     */
    function updateAuthority(address target, address newAuthority) external;
}

// File: lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/access/manager/IAccessManaged.sol

// OpenZeppelin Contracts (last updated v5.0.0) (access/manager/IAccessManaged.sol)

pragma solidity ^0.8.20;

interface IAccessManaged {
    /**
     * @dev Authority that manages this contract was updated.
     */
    event AuthorityUpdated(address authority);

    error AccessManagedUnauthorized(address caller);
    error AccessManagedRequiredDelay(address caller, uint32 delay);
    error AccessManagedInvalidAuthority(address authority);

    /**
     * @dev Returns the current authority.
     */
    function authority() external view returns (address);

    /**
     * @dev Transfers control to a new authority. The caller must be the current authority.
     */
    function setAuthority(address) external;

    /**
     * @dev Returns true only in the context of a delayed restricted call, at the moment that the scheduled operation is
     * being consumed. Prevents denial of service for delayed restricted calls in the case that the contract performs
     * attacker controlled calls.
     */
    function isConsumingScheduledOp() external view returns (bytes4);
}

// File: lib/openzeppelin-contracts-upgradeable/contracts/utils/ContextUpgradeable.sol

// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;


/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// File: lib/openzeppelin-contracts-upgradeable/contracts/access/manager/AccessManagedUpgradeable.sol

// OpenZeppelin Contracts (last updated v5.1.0) (access/manager/AccessManaged.sol)

pragma solidity ^0.8.20;








/**
 * @dev This contract module makes available a {restricted} modifier. Functions decorated with this modifier will be
 * permissioned according to an "authority": a contract like {AccessManager} that follows the {IAuthority} interface,
 * implementing a policy that allows certain callers to access certain functions.
 *
 * IMPORTANT: The `restricted` modifier should never be used on `internal` functions, judiciously used in `public`
 * functions, and ideally only used in `external` functions. See {restricted}.
 */
abstract contract AccessManagedUpgradeable is Initializable, ContextUpgradeable, IAccessManaged {
    /// @custom:storage-location erc7201:openzeppelin.storage.AccessManaged
    struct AccessManagedStorage {
        address _authority;

        bool _consumingSchedule;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.AccessManaged")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant AccessManagedStorageLocation = 0xf3177357ab46d8af007ab3fdb9af81da189e1068fefdc0073dca88a2cab40a00;

    function _getAccessManagedStorage() private pure returns (AccessManagedStorage storage $) {
        assembly {
            $.slot := AccessManagedStorageLocation
        }
    }

    /**
     * @dev Initializes the contract connected to an initial authority.
     */
    function __AccessManaged_init(address initialAuthority) internal onlyInitializing {
        __AccessManaged_init_unchained(initialAuthority);
    }

    function __AccessManaged_init_unchained(address initialAuthority) internal onlyInitializing {
        _setAuthority(initialAuthority);
    }

    /**
     * @dev Restricts access to a function as defined by the connected Authority for this contract and the
     * caller and selector of the function that entered the contract.
     *
     * [IMPORTANT]
     * ====
     * In general, this modifier should only be used on `external` functions. It is okay to use it on `public`
     * functions that are used as external entry points and are not called internally. Unless you know what you're
     * doing, it should never be used on `internal` functions. Failure to follow these rules can have critical security
     * implications! This is because the permissions are determined by the function that entered the contract, i.e. the
     * function at the bottom of the call stack, and not the function where the modifier is visible in the source code.
     * ====
     *
     * [WARNING]
     * ====
     * Avoid adding this modifier to the https://docs.soliditylang.org/en/v0.8.20/contracts.html#receive-ether-function[`receive()`]
     * function or the https://docs.soliditylang.org/en/v0.8.20/contracts.html#fallback-function[`fallback()`]. These
     * functions are the only execution paths where a function selector cannot be unambiguously determined from the calldata
     * since the selector defaults to `0x00000000` in the `receive()` function and similarly in the `fallback()` function
     * if no calldata is provided. (See {_checkCanCall}).
     *
     * The `receive()` function will always panic whereas the `fallback()` may panic depending on the calldata length.
     * ====
     */
    modifier restricted() {
        _checkCanCall(_msgSender(), _msgData());
        _;
    }

    /// @inheritdoc IAccessManaged
    function authority() public view virtual returns (address) {
        AccessManagedStorage storage $ = _getAccessManagedStorage();
        return $._authority;
    }

    /// @inheritdoc IAccessManaged
    function setAuthority(address newAuthority) public virtual {
        address caller = _msgSender();
        if (caller != authority()) {
            revert AccessManagedUnauthorized(caller);
        }
        if (newAuthority.code.length == 0) {
            revert AccessManagedInvalidAuthority(newAuthority);
        }
        _setAuthority(newAuthority);
    }

    /// @inheritdoc IAccessManaged
    function isConsumingScheduledOp() public view returns (bytes4) {
        AccessManagedStorage storage $ = _getAccessManagedStorage();
        return $._consumingSchedule ? this.isConsumingScheduledOp.selector : bytes4(0);
    }

    /**
     * @dev Transfers control to a new authority. Internal function with no access restriction. Allows bypassing the
     * permissions set by the current authority.
     */
    function _setAuthority(address newAuthority) internal virtual {
        AccessManagedStorage storage $ = _getAccessManagedStorage();
        $._authority = newAuthority;
        emit AuthorityUpdated(newAuthority);
    }

    /**
     * @dev Reverts if the caller is not allowed to call the function identified by a selector. Panics if the calldata
     * is less than 4 bytes long.
     */
    function _checkCanCall(address caller, bytes calldata data) internal virtual {
        AccessManagedStorage storage $ = _getAccessManagedStorage();
        (bool immediate, uint32 delay) = AuthorityUtils.canCallWithDelay(
            authority(),
            caller,
            address(this),
            bytes4(data[0:4])
        );
        if (!immediate) {
            if (delay > 0) {
                $._consumingSchedule = true;
                IAccessManager(authority()).consumeScheduledOp(caller, data);
                $._consumingSchedule = false;
            } else {
                revert AccessManagedUnauthorized(caller);
            }
        }
    }
}

// File: src/interfaces/IBridgeAdapterFactory.sol

pragma solidity 0.8.28;

interface IBridgeAdapterFactory {
    event BridgeAdapterCreated(address indexed controller, uint256 indexed bridgeId, address indexed adapter);

    /// @notice Address => Whether this is a BridgeAdapter instance deployed by this factory.
    function isBridgeAdapter(address adapter) external view returns (bool);

    /// @notice Deploys a bridge adapter instance.
    /// @param bridgeId The ID of the bridge for which the adapter is being created.
    /// @param initData The optional initialization data for the bridge adapter.
    /// @return adapter The address of the deployed bridge adapter.
    function createBridgeAdapter(uint16 bridgeId, bytes calldata initData) external returns (address adapter);
}

// File: src/libraries/Errors.sol

pragma solidity 0.8.28;

library Errors {
    error AccountingToken();
    error ActiveUpdatePending();
    error AlreadyBaseToken();
    error AlreadyRootGuardian();
    error AmountOutTooLow();
    error BridgeAdapterAlreadyExists();
    error BridgeAdapterDoesNotExist();
    error BridgeStateMismatch();
    error CaliberAccountingStale(uint256 caliberChainId);
    error CaliberAlreadySet();
    error Create3ContractDeploymentFailed();
    error DirectManageFlashLoanCall();
    error EvmChainIdNotRegistered(uint256 chainId);
    error ExceededMaxDeposit();
    error ExceededMaxMint(uint256 shares, uint256 max);
    error ExceededMaxWithdraw(uint256 assets, uint256 max);
    error ForeignTokenNotRegistered(address _token, uint256 _foreignEvmChainId);
    error HubBridgeAdapterAlreadySet();
    error HubBridgeAdapterNotSet();
    error GroupIdNotProvided();
    error InstructionsMismatch();
    error InsufficientBalance();
    error InvalidAccounting();
    error InvalidAffectedToken();
    error InvalidChainId();
    error InvalidDebtFlag();
    error InvalidDecimals();
    error InvalidFeedRoute();
    error InvalidInputAmount();
    error InvalidInstructionProof();
    error InvalidInstructionType();
    error InvalidOutputToken();
    error InvalidPositionChangeDirection();
    error InvalidRecipientChainId();
    error InvalidTransferStatus();
    error LocalTokenNotRegistered(address _token, uint256 _foreignEvmChainId);
    error ManageFlashLoanReentrantCall();
    error MaxValueLossExceeded();
    error MessageAlreadyAuthorized();
    error Migrated();
    error MinOutputAmountExceedsInputAmount();
    error MismatchedLength();
    error MismatchedLengths();
    error MissingInstructionForGroup(uint256 groupId);
    error NegativeTokenPrice(address priceFeed);
    error NoPendingUpdate();
    error NonZeroBalance();
    error NotBaseToken();
    error NotCaliber();
    error NotCaliberMailbox();
    error NotController();
    error NotFactory();
    error NotFlashLoanModule();
    error NotMachine();
    error NotMachineEndpoint();
    error NotMigrated();
    error NotPendingMachine();
    error NotPreDepositVault();
    error NotRootGuardian();
    error OngoingCooldown();
    error OutTransferDisabled();
    error PendingBridgeTransfer();
    error PositionAccountingStale(uint256 posId);
    error PositionDoesNotExist();
    error PositionIsGrouped();
    error PriceFeedRouteNotRegistered(address token);
    error PriceFeedStale(address priceFeed, uint256 updatedAt);
    error ProtectedRootGuardian();
    error Create3ProxyDeploymentFailed();
    error RecoveryMode();
    error SameRoot();
    error SlippageProtection();
    error SpokeBridgeAdapterAlreadySet();
    error SpokeBridgeAdapterNotSet();
    error SpokeCaliberAlreadySet();
    error StaleData();
    error SwapFailed();
    error SwapperTargetsNotSet();
    error TargetAlreadyExists();
    error UnauthorizedCaller();
    error UnauthorizedSource();
    error UnexpectedMessage();
    error UnexpectedResultLength();
    error InvalidBridgeId();
    error WhChainIdNotRegistered(uint16 chainId);
    error ZeroBridgeAdapterAddress();
    error ZeroChainId();
    error ZeroGroupId();
    error ZeroPositionId();
    error ZeroSalt();
    error ZeroTokenAddress();
}

// File: src/interfaces/IMakinaContext.sol

pragma solidity 0.8.28;

interface IMakinaContext {
    /// @notice Address of the registry.
    function registry() external view returns (address);
}

// File: src/utils/MakinaContext.sol

pragma solidity 0.8.28;



abstract contract MakinaContext is IMakinaContext {
    /// @inheritdoc IMakinaContext
    address public immutable override registry;

    constructor(address _registry) {
        registry = _registry;
    }
}

// File: src/bridge/controller/BridgeController.sol

pragma solidity 0.8.28;













abstract contract BridgeController is AccessManagedUpgradeable, MakinaContext, IBridgeController {
    using Math for uint256;
    using SafeERC20 for IERC20;

    /// @dev Full scale value in basis points
    uint256 private constant MAX_BPS = 10_000;

    /// @custom:storage-location erc7201:makina.storage.BridgeController
    struct BridgeControllerStorage {
        uint16[] _supportedBridges;
        mapping(uint16 bridgeId => address adapter) _bridgeAdapters;
        mapping(uint16 bridgeId => uint256 maxBridgeLossBps) _maxBridgeLossBps;
        mapping(uint16 bridgeId => bool isOutTransferEnabled) _isOutTransferEnabled;
        mapping(address addr => bool isAdapter) _isBridgeAdapter;
    }

    // keccak256(abi.encode(uint256(keccak256("makina.storage.BridgeController")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant BridgeControllerStorageLocation =
        0x7363d524082cdf545f1ac33985598b84d2470b8b4fbcc6cb47698cc1b2a03500;

    function _getBridgeControllerStorage() internal pure returns (BridgeControllerStorage storage $) {
        assembly {
            $.slot := BridgeControllerStorageLocation
        }
    }

    /// @inheritdoc IBridgeController
    function isBridgeSupported(uint16 bridgeId) external view override returns (bool) {
        return _getBridgeControllerStorage()._bridgeAdapters[bridgeId] != address(0);
    }

    /// @inheritdoc IBridgeController
    function isOutTransferEnabled(uint16 bridgeId) external view override returns (bool) {
        return _getBridgeControllerStorage()._isOutTransferEnabled[bridgeId];
    }

    /// @inheritdoc IBridgeController
    function getBridgeAdapter(uint16 bridgeId) public view override returns (address) {
        BridgeControllerStorage storage $ = _getBridgeControllerStorage();
        if ($._bridgeAdapters[bridgeId] == address(0)) {
            revert Errors.BridgeAdapterDoesNotExist();
        }
        return $._bridgeAdapters[bridgeId];
    }

    /// @inheritdoc IBridgeController
    function getMaxBridgeLossBps(uint16 bridgeId) external view returns (uint256) {
        BridgeControllerStorage storage $ = _getBridgeControllerStorage();
        if ($._bridgeAdapters[bridgeId] == address(0)) {
            revert Errors.BridgeAdapterDoesNotExist();
        }
        return $._maxBridgeLossBps[bridgeId];
    }

    /// @inheritdoc IBridgeController
    function createBridgeAdapter(uint16 bridgeId, uint256 initialMaxBridgeLossBps, bytes calldata initData)
        external
        restricted
        returns (address)
    {
        BridgeControllerStorage storage $ = _getBridgeControllerStorage();

        if ($._bridgeAdapters[bridgeId] != address(0)) {
            revert Errors.BridgeAdapterAlreadyExists();
        }

        address bridgeAdapter =
            IBridgeAdapterFactory(ICoreRegistry(registry).coreFactory()).createBridgeAdapter(bridgeId, initData);

        $._bridgeAdapters[bridgeId] = bridgeAdapter;
        $._maxBridgeLossBps[bridgeId] = initialMaxBridgeLossBps;
        $._isOutTransferEnabled[bridgeId] = true;
        $._isBridgeAdapter[bridgeAdapter] = true;
        $._supportedBridges.push(bridgeId);

        emit BridgeAdapterCreated(bridgeId, bridgeAdapter);

        return bridgeAdapter;
    }

    function _setOutTransferEnabled(uint16 bridgeId, bool enabled) internal {
        BridgeControllerStorage storage $ = _getBridgeControllerStorage();
        if ($._bridgeAdapters[bridgeId] == address(0)) {
            revert Errors.BridgeAdapterDoesNotExist();
        }
        emit OutTransferEnabledSet(uint256(bridgeId), enabled);
        $._isOutTransferEnabled[bridgeId] = enabled;
    }

    function _setMaxBridgeLossBps(uint16 bridgeId, uint256 maxBridgeLossBps) internal {
        BridgeControllerStorage storage $ = _getBridgeControllerStorage();
        if ($._bridgeAdapters[bridgeId] == address(0)) {
            revert Errors.BridgeAdapterDoesNotExist();
        }
        emit MaxBridgeLossBpsChanged(bridgeId, $._maxBridgeLossBps[bridgeId], maxBridgeLossBps);
        $._maxBridgeLossBps[bridgeId] = maxBridgeLossBps;
    }

    function _isBridgeAdapter(address adapter) internal view returns (bool) {
        return _getBridgeControllerStorage()._isBridgeAdapter[adapter];
    }

    function _scheduleOutBridgeTransfer(
        uint16 bridgeId,
        uint256 destinationChainId,
        address recipient,
        address inputToken,
        uint256 inputAmount,
        address outputToken,
        uint256 minOutputAmount
    ) internal {
        BridgeControllerStorage storage $ = _getBridgeControllerStorage();
        address adapter = getBridgeAdapter(bridgeId);
        if (!$._isOutTransferEnabled[bridgeId]) {
            revert Errors.OutTransferDisabled();
        }
        if (minOutputAmount < inputAmount.mulDiv(MAX_BPS - $._maxBridgeLossBps[bridgeId], MAX_BPS, Math.Rounding.Ceil))
        {
            revert Errors.MaxValueLossExceeded();
        }
        if (minOutputAmount > inputAmount) {
            revert Errors.MinOutputAmountExceedsInputAmount();
        }
        IERC20(inputToken).forceApprove(adapter, inputAmount);
        IBridgeAdapter(adapter).scheduleOutBridgeTransfer(
            destinationChainId, recipient, inputToken, inputAmount, outputToken, minOutputAmount
        );
    }

    function _sendOutBridgeTransfer(uint16 bridgeId, uint256 transferId, bytes calldata data) internal {
        address adapter = getBridgeAdapter(bridgeId);
        if (!_getBridgeControllerStorage()._isOutTransferEnabled[bridgeId]) {
            revert Errors.OutTransferDisabled();
        }
        IBridgeAdapter(adapter).sendOutBridgeTransfer(transferId, data);
    }

    function _authorizeInBridgeTransfer(uint16 bridgeId, bytes32 messageHash) internal {
        address adapter = getBridgeAdapter(bridgeId);
        IBridgeAdapter(adapter).authorizeInBridgeTransfer(messageHash);
    }

    function _claimInBridgeTransfer(uint16 bridgeId, uint256 transferId) internal {
        address adapter = getBridgeAdapter(bridgeId);
        IBridgeAdapter(adapter).claimInBridgeTransfer(transferId);
    }

    function _cancelOutBridgeTransfer(uint16 bridgeId, uint256 transferId) internal {
        address adapter = getBridgeAdapter(bridgeId);
        IBridgeAdapter(adapter).cancelOutBridgeTransfer(transferId);
    }
}

// File: src/libraries/DecimalsUtils.sol

pragma solidity 0.8.28;



library DecimalsUtils {
    uint8 internal constant DEFAULT_DECIMALS = 18;
    uint8 internal constant MIN_DECIMALS = 6;
    uint8 internal constant MAX_DECIMALS = DEFAULT_DECIMALS;
    uint8 internal constant SHARE_TOKEN_DECIMALS = DEFAULT_DECIMALS;
    uint256 internal constant SHARE_TOKEN_UNIT = 10 ** SHARE_TOKEN_DECIMALS;

    function _getDecimals(address asset) internal view returns (uint8) {
        (bool success, bytes memory encodedDecimals) = asset.staticcall(abi.encodeCall(IERC20Metadata.decimals, ()));
        if (success && encodedDecimals.length >= 32) {
            uint256 returnedDecimals = abi.decode(encodedDecimals, (uint256));
            if (returnedDecimals <= type(uint8).max) {
                return uint8(returnedDecimals);
            }
        }
        return DEFAULT_DECIMALS;
    }
}

// File: src/utils/MakinaGovernable.sol

pragma solidity 0.8.28;






abstract contract MakinaGovernable is AccessManagedUpgradeable, IMakinaGovernable {
    /// @custom:storage-location erc7201:makina.storage.MakinaGovernable
    struct MakinaGovernableStorage {
        address _mechanic;
        address _securityCouncil;
        address _riskManager;
        address _riskManagerTimelock;
        bool _recoveryMode;
    }

    // keccak256(abi.encode(uint256(keccak256("makina.storage.MakinaGovernable")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant MakinaGovernableStorageLocation =
        0x7e702089668346e906996be6de3dfc0cb2b0c125fc09b3c0391871825913e000;

    function _getMakinaGovernableStorage() internal pure returns (MakinaGovernableStorage storage $) {
        assembly {
            $.slot := MakinaGovernableStorageLocation
        }
    }

    constructor() {
        _disableInitializers();
    }

    function __MakinaGovernable_init(MakinaGovernableInitParams calldata params) internal onlyInitializing {
        MakinaGovernableStorage storage $ = _getMakinaGovernableStorage();
        $._mechanic = params.initialMechanic;
        $._securityCouncil = params.initialSecurityCouncil;
        $._riskManager = params.initialRiskManager;
        $._riskManagerTimelock = params.initialRiskManagerTimelock;
        __AccessManaged_init(params.initialAuthority);
    }

    modifier onlyOperator() {
        MakinaGovernableStorage storage $ = _getMakinaGovernableStorage();
        if (msg.sender != ($._recoveryMode ? $._securityCouncil : $._mechanic)) {
            revert Errors.UnauthorizedCaller();
        }
        _;
    }

    modifier onlyMechanic() {
        if (msg.sender != _getMakinaGovernableStorage()._mechanic) {
            revert Errors.UnauthorizedCaller();
        }
        _;
    }

    modifier onlySecurityCouncil() {
        if (msg.sender != _getMakinaGovernableStorage()._securityCouncil) {
            revert Errors.UnauthorizedCaller();
        }
        _;
    }

    modifier onlyRiskManager() {
        if (msg.sender != _getMakinaGovernableStorage()._riskManager) {
            revert Errors.UnauthorizedCaller();
        }
        _;
    }

    modifier onlyRiskManagerTimelock() {
        if (msg.sender != _getMakinaGovernableStorage()._riskManagerTimelock) {
            revert Errors.UnauthorizedCaller();
        }
        _;
    }

    modifier notRecoveryMode() {
        if (_getMakinaGovernableStorage()._recoveryMode) {
            revert Errors.RecoveryMode();
        }
        _;
    }

    /// @inheritdoc IMakinaGovernable
    function mechanic() public view override returns (address) {
        return _getMakinaGovernableStorage()._mechanic;
    }

    /// @inheritdoc IMakinaGovernable
    function securityCouncil() public view override returns (address) {
        return _getMakinaGovernableStorage()._securityCouncil;
    }

    /// @inheritdoc IMakinaGovernable
    function riskManager() public view override returns (address) {
        return _getMakinaGovernableStorage()._riskManager;
    }

    /// @inheritdoc IMakinaGovernable
    function riskManagerTimelock() public view override returns (address) {
        return _getMakinaGovernableStorage()._riskManagerTimelock;
    }

    /// @inheritdoc IMakinaGovernable
    function recoveryMode() public view returns (bool) {
        return _getMakinaGovernableStorage()._recoveryMode;
    }

    /// @inheritdoc IMakinaGovernable
    function setMechanic(address newMechanic) external override restricted {
        MakinaGovernableStorage storage $ = _getMakinaGovernableStorage();
        emit MechanicChanged($._mechanic, newMechanic);
        $._mechanic = newMechanic;
    }

    /// @inheritdoc IMakinaGovernable
    function setSecurityCouncil(address newSecurityCouncil) external override restricted {
        MakinaGovernableStorage storage $ = _getMakinaGovernableStorage();
        emit SecurityCouncilChanged($._securityCouncil, newSecurityCouncil);
        $._securityCouncil = newSecurityCouncil;
    }

    /// @inheritdoc IMakinaGovernable
    function setRiskManager(address newRiskManager) external override restricted {
        MakinaGovernableStorage storage $ = _getMakinaGovernableStorage();
        emit RiskManagerChanged($._riskManager, newRiskManager);
        $._riskManager = newRiskManager;
    }

    /// @inheritdoc IMakinaGovernable
    function setRiskManagerTimelock(address newRiskManagerTimelock) external override restricted {
        MakinaGovernableStorage storage $ = _getMakinaGovernableStorage();
        emit RiskManagerTimelockChanged($._riskManagerTimelock, newRiskManagerTimelock);
        $._riskManagerTimelock = newRiskManagerTimelock;
    }

    /// @inheritdoc IMakinaGovernable
    function setRecoveryMode(bool enabled) external onlySecurityCouncil {
        MakinaGovernableStorage storage $ = _getMakinaGovernableStorage();
        if ($._recoveryMode != enabled) {
            $._recoveryMode = enabled;
            emit RecoveryModeChanged(enabled);
        }
    }
}

// File: lib/wormhole-solidity-sdk/src/libraries/UncheckedIndexing.sol

pragma solidity ^0.8.14; //for (bugfixed) support of `using ... global;` syntax for libraries



// ╭──────────────────────────────────────────────────────────────────────╮
// │ Library for [reading from/writing to] memory without bounds checking │
// ╰──────────────────────────────────────────────────────────────────────╯

library UncheckedIndexing {
  function readUnchecked(bytes memory arr, uint index) internal pure returns (uint256 ret) {
    /// @solidity memory-safe-assembly
    assembly { ret := mload(add(add(arr, WORD_SIZE), index)) }
  }

  function writeUnchecked(bytes memory arr, uint index, uint256 value) internal pure {
    /// @solidity memory-safe-assembly
    assembly { mstore(add(add(arr, WORD_SIZE), index), value) }
  }

  function readUnchecked(address[] memory arr, uint index) internal pure returns (address ret) {
    bytes memory arrBytes;
    /// @solidity memory-safe-assembly
    assembly { arrBytes := arr }
    uint256 raw = readUnchecked(arrBytes, _mulWordSize(index));
    /// @solidity memory-safe-assembly
    assembly { ret := raw }
  }

  //it is assumed that value is never dirty here (it's hard to create a dirty address)
  //  see https://docs.soliditylang.org/en/latest/internals/variable_cleanup.html
  function writeUnchecked(address[] memory arr, uint index, address value) internal pure {
    bytes memory arrBytes;
    /// @solidity memory-safe-assembly
    assembly { arrBytes := arr }
    writeUnchecked(arrBytes, _mulWordSize(index), uint256(uint160(value)));
  }

  function readUnchecked(uint256[] memory arr, uint index) internal pure returns (uint256 ret) {
    bytes memory arrBytes;
    /// @solidity memory-safe-assembly
    assembly { arrBytes := arr }
    return readUnchecked(arrBytes, _mulWordSize(index));
  }

  function writeUnchecked(uint256[] memory arr, uint index, uint256 value) internal pure {
    bytes memory arrBytes;
    /// @solidity memory-safe-assembly
    assembly { arrBytes := arr }
    writeUnchecked(arrBytes, _mulWordSize(index), value);
  }

  function _mulWordSize(uint index) private pure returns (uint) { unchecked {
    return index * WORD_SIZE;
  }}
}

// File: lib/wormhole-solidity-sdk/src/libraries/CoreBridge.sol

pragma solidity ^0.8.14;








// ╭────────────────────────────────────────────────────────────────────────────────────────╮
// │ Library for "client-side" parsing and verification of VAAs / Guardian signed messages. │
// ╰────────────────────────────────────────────────────────────────────────────────────────╯
//
// Offers significant gas savings over calling the CoreBridge due to:
//  * its much more efficient implementation
//  * by avoiding external call encoding and decoding overheads
// Comes at the expense of larger contract bytecode.
//
// When verifying a single VAA, decodeAndVerifyVaaCd is maximally gas efficient.
// However, when verifying multiple VAAs/signed messages, the most gas efficient choice is to do
//   some manual parsing (e.g. by directly using VaaLib) and to explicitly fetch the guardian set
//   (which is very likely to be the same for all messages) via `getGuardiansOrEmpty` or
//   `getGuardiansOrLatest` and reuse it, rather than to look it up again and again, as a call
//   to decodeAndVerifyVaaCd would do.
//
// Function Overview:
//  * decodeAndVerifyVaa: Cd and Mem variants for verifying a VAA and decoding/returning its body
//  * isVerifiedByQuorum: 2x2=4 variants for verifying a hash (directly passed to ecrecover):
//    * Cd <> Mem
//    * guardianSetIndex:
//      - fetches the guardian set from the CoreBridge with a fallback to the latest guardian set
//          if the specified one is expired as an ad-hoc repair attempt
//    * guardianAddresses:
//      - only tries to verify against the provided guardian addresses, no fallback
//  * readUnchecked: Cd and Mem variants for unchecked index access into a GuardianSignature array
//  * minSigsForQuorum

library CoreBridgeLib {
  using UncheckedIndexing for address[];
  using BytesParsing for bytes;
  using VaaLib for bytes;

  //avoid solc error:
  //Only direct number constants and references to such constants are supported by inline assembly.
  uint internal constant GUARDIAN_SIGNATURE_STRUCT_SIZE = 128; //4 * WORD_SIZE;

  error VerificationFailed();

  function minSigsForQuorum(uint numGuardians) internal pure returns (uint) { unchecked {
    return numGuardians * 2 / 3 + 1;
  }}

  //skip out-of-bounds checks by using assembly
  function readUncheckedCd(
    GuardianSignature[] calldata arr,
    uint i
  ) internal pure returns (GuardianSignature calldata ret) {
    assembly ("memory-safe") {
      ret := add(arr.offset, mul(i, GUARDIAN_SIGNATURE_STRUCT_SIZE))
    }
  }

  function readUncheckedMem(
    GuardianSignature[] memory arr,
    uint i
  ) internal pure returns (GuardianSignature memory ret) {
    assembly ("memory-safe") {
      ret := mload(add(add(arr, WORD_SIZE), mul(i, WORD_SIZE)))
    }
  }

  //this function is the most efficient choice when verifying multiple messages because it allows
  //  library users to reuse the same guardian set for multiple messages (thus avoiding redundant
  //  external calls and the associated allocations and checks)
  function isVerifiedByQuorumCd(
    bytes32 hash,
    GuardianSignature[] calldata guardianSignatures,
    address[] memory guardians
  ) internal pure returns (bool) { unchecked {
    uint guardianCount = guardians.length;
    uint signatureCount = guardianSignatures.length; //optimization puts var on stack
    if (signatureCount < minSigsForQuorum(guardianCount))
      return false;

    bool isFirstSignature = true; //optimization instead of always checking i == 0
    uint prevGuardianIndex;
    for (uint i = 0; i < signatureCount; ++i) {
      GuardianSignature memory sig = readUncheckedCd(guardianSignatures, i);
      uint guardianIndex = sig.guardianIndex;
      if (_failsVerification(
        hash,
        guardianIndex,
        sig.r, sig.s, sig.v,
        guardians,
        guardianCount,
        prevGuardianIndex,
        isFirstSignature
      ))
        return false;

      prevGuardianIndex = guardianIndex;
      isFirstSignature = false;
    }
    return true;
  }}

  function isVerifiedByQuorumMem(
    bytes32 hash,
    GuardianSignature[] memory guardianSignatures,
    address[] memory guardians
  ) internal pure returns (bool) { unchecked {
    uint guardianCount = guardians.length;
    uint signatureCount = guardianSignatures.length; //optimization puts var on stack
    if (signatureCount < minSigsForQuorum(guardianCount))
      return false;

    bool isFirstSignature = true; //optimization instead of always checking i == 0
    uint prevGuardianIndex;
    for (uint i = 0; i < signatureCount; ++i) {
      GuardianSignature memory sig = readUncheckedMem(guardianSignatures, i);
      uint guardianIndex = sig.guardianIndex;
      if (_failsVerification(
        hash,
        guardianIndex,
        sig.r, sig.s, sig.v,
        guardians,
        guardianCount,
        prevGuardianIndex,
        isFirstSignature
      ))
        return false;

      prevGuardianIndex = guardianIndex;
      isFirstSignature = false;
    }
    return true;
  }}

  function decodeAndVerifyVaaCd(
    address wormhole,
    bytes calldata encodedVaa
  ) internal view returns (
    uint32  timestamp,
    uint32  nonce,
    uint16  emitterChainId,
    bytes32 emitterAddress,
    uint64  sequence,
    uint8   consistencyLevel,
    bytes calldata payload
  ) { unchecked {
    uint offset = VaaLib.checkVaaVersionCd(encodedVaa);
    uint32 guardianSetIndex;
    (guardianSetIndex, offset) = encodedVaa.asUint32CdUnchecked(offset);

    address[] memory guardians = getGuardiansOrLatest(wormhole, guardianSetIndex);
    uint guardianCount = guardians.length; //optimization puts var on stack thus avoids mload
    uint signatureCount;
    (signatureCount, offset) = encodedVaa.asUint8CdUnchecked(offset);
    //this check will also handle empty guardian sets, because minSigsForQuorum(0) is 1 and so
    //  subsequent signature verification will fail
    if (signatureCount < minSigsForQuorum(guardianCount))
      revert VerificationFailed();

    uint envelopeOffset = offset + signatureCount * VaaLib.GUARDIAN_SIGNATURE_SIZE;
    bytes32 vaaHash = encodedVaa.calcVaaDoubleHashCd(envelopeOffset);

    bool isFirstSignature = true; //optimization instead of always checking i == 0
    uint prevGuardianIndex;
    for (uint i = 0; i < signatureCount; ++i) {
      uint guardianIndex; bytes32 r; bytes32 s; uint8 v;
      (guardianIndex, r, s, v, offset) = encodedVaa.decodeGuardianSignatureCdUnchecked(offset);
      if (_failsVerification(
        vaaHash,
        guardianIndex,
        r, s, v,
        guardians,
        guardianCount,
        prevGuardianIndex,
        isFirstSignature
      ))
        revert VerificationFailed();

      prevGuardianIndex = guardianIndex;
      isFirstSignature = false;
    }

    return encodedVaa.decodeVaaBodyCd(envelopeOffset);
  }}

  function decodeAndVerifyVaaMem(
    address wormhole,
    bytes memory encodedVaa
  ) internal view returns (
    uint32  timestamp,
    uint32  nonce,
    uint16  emitterChainId,
    bytes32 emitterAddress,
    uint64  sequence,
    uint8   consistencyLevel,
    bytes memory payload
  ) {
    (timestamp, nonce, emitterChainId, emitterAddress, sequence, consistencyLevel, payload, ) =
      decodeAndVerifyVaaMem(wormhole, encodedVaa, 0, encodedVaa.length);
  }

  function decodeAndVerifyVaaMem(
    address wormhole,
    bytes memory encodedVaa,
    uint offset,
    uint vaaLength
  ) internal view returns (
    uint32  timestamp,
    uint32  nonce,
    uint16  emitterChainId,
    bytes32 emitterAddress,
    uint64  sequence,
    uint8   consistencyLevel,
    bytes memory payload,
    uint    newOffset
  ) { unchecked {
    offset = VaaLib.checkVaaVersionMemUnchecked(encodedVaa, offset);
    uint32 guardianSetIndex;
    (guardianSetIndex, offset) = encodedVaa.asUint32MemUnchecked(offset);

    address[] memory guardians = getGuardiansOrLatest(wormhole, guardianSetIndex);
    uint guardianCount = guardians.length;

    uint signatureCount;
    (signatureCount, offset) = encodedVaa.asUint8MemUnchecked(offset);
    //this check will also handle empty guardian sets, because minSigsForQuorum(0) is 1 and so
    //  subsequent signature verification will fail
    if (signatureCount < minSigsForQuorum(guardianCount))
      revert VerificationFailed();

    uint envelopeOffset = offset + signatureCount * VaaLib.GUARDIAN_SIGNATURE_SIZE;
    bytes32 vaaHash = encodedVaa.calcVaaDoubleHashMem(envelopeOffset, vaaLength);

    bool isFirstSignature = true; //optimization instead of always checking i == 0
    uint prevGuardianIndex;
    for (uint i = 0; i < signatureCount; ++i) {
      uint guardianIndex; bytes32 r; bytes32 s; uint8 v;
      (guardianIndex, r, s, v, offset) = encodedVaa.decodeGuardianSignatureMemUnchecked(offset);
      if (_failsVerification(
        vaaHash,
        guardianIndex,
        r, s, v,
        guardians,
        guardianCount,
        prevGuardianIndex,
        isFirstSignature
      ))
        revert VerificationFailed();

      prevGuardianIndex = guardianIndex;
      isFirstSignature = false;
    }

    ( timestamp,
      nonce,
      emitterChainId,
      emitterAddress,
      sequence,
      consistencyLevel,
      payload,
      newOffset
    ) = encodedVaa.decodeVaaBodyMemUnchecked(envelopeOffset, vaaLength);
  }}

  function isVerifiedByQuorumCd(
    address wormhole,
    bytes32 hash,
    GuardianSignature[] calldata guardianSignatures,
    uint32 guardianSetIndex
  ) internal view returns (bool) {
    address[] memory guardians = getGuardiansOrLatest(wormhole, guardianSetIndex);
    return isVerifiedByQuorumCd(hash, guardianSignatures, guardians);
  }

  function isVerifiedByQuorumMem(
    address wormhole,
    bytes32 hash,
    GuardianSignature[] memory guardianSignatures,
    uint32 guardianSetIndex
  ) internal view returns (bool) {
    address[] memory guardians = getGuardiansOrLatest(wormhole, guardianSetIndex);
    return isVerifiedByQuorumMem(hash, guardianSignatures, guardians);
  }

  //returns empty array if the guardian set is expired
  //has more predictable gas costs (guaranteed to only do one external call)
  function getGuardiansOrEmpty(
    address wormhole,
    uint32 guardianSetIndex
  ) internal view returns (address[] memory guardians) {
    IWormhole.GuardianSet memory guardianSet = IWormhole(wormhole).getGuardianSet(guardianSetIndex);
    if (!_isExpired(guardianSet))
      guardians = guardianSet.keys;
  }

  //returns associated guardian set or latest guardian set if the specified one is expired
  //has more variable gas costs but has a chance of doing an ad-hoc "repair" of the VAA in case
  //  the specified signatures are valid for the latest guardian set as well (about a 30 % chance
  //  for the typical guardian set rotation where one guardian address gets replaced).
  function getGuardiansOrLatest(
    address wormhole,
    uint32 guardianSetIndex
  ) internal view returns (address[] memory guardians) {
    IWormhole.GuardianSet memory guardianSet = IWormhole(wormhole).getGuardianSet(guardianSetIndex);
    if (_isExpired(guardianSet))
      //if the specified guardian set is expired, we try using the current guardian set as an adhoc
      //  repair attempt (there's almost certainly never more than 2 valid guardian sets at a time)
      guardianSet = IWormhole(wormhole).getGuardianSet(
        IWormhole(wormhole).getCurrentGuardianSetIndex()
      );

    guardians = guardianSet.keys;
  }

  //negated for optimization because we always want to act on incorrect signatures and so save a NOT
  function _failsVerification(
    bytes32 hash,
    uint guardianIndex,
    bytes32 r,
    bytes32 s,
    uint8 v,
    address[] memory guardians,
    uint guardianCount,
    uint prevGuardianIndex,
    bool isFirstSignature
  ) private pure returns (bool) {
    address signatory = ecrecover(hash, v, r, s);
    address guardian = guardians.readUnchecked(guardianIndex);
    //check that:
    // * the guardian indicies are in strictly ascending order (only after the first signature)
    //     this is itself an optimization to efficiently prevent having the same guardian signature
    //     included twice
    // * that the guardian index is not out of bounds
    // * that the signatory is the guardian
    //
    // the core bridge also includes a separate check that signatory is not the zero address
    //   but this is already covered by comparing that the signatory matches the guardian which
    //   [can never be the zero address](https://github.com/wormhole-foundation/wormhole/blob/1dbe8459b96e182932d0dd5ae4b6bbce6f48cb09/ethereum/contracts/Setters.sol#L20)
    return eagerOr(
      eagerOr(
        !eagerOr(isFirstSignature, guardianIndex > prevGuardianIndex),
        guardianIndex >= guardianCount
      ),
      signatory != guardian
    );
  }

  function _isExpired(IWormhole.GuardianSet memory guardianSet) private view returns (bool) {
    uint expirationTime = guardianSet.expirationTime;
    return eagerAnd(expirationTime != 0, expirationTime < block.timestamp);
  }
}

// File: lib/wormhole-solidity-sdk/src/libraries/QueryResponse.sol

pragma solidity ^0.8.4;






library QueryType {
  error UnsupportedQueryType(uint8 received);

  //Solidity enums don't permit custom values (i.e. can't start from 1)
  //Also invalid enum conversions result in panics and manual range checking requires assembly
  //  to avoid superfluous double checking.
  //So we're sticking with uint8 constants instead.
  uint8 internal constant ETH_CALL = 1;
  uint8 internal constant ETH_CALL_BY_TIMESTAMP = 2;
  uint8 internal constant ETH_CALL_WITH_FINALITY = 3;
  uint8 internal constant SOLANA_ACCOUNT = 4;
  uint8 internal constant SOLANA_PDA = 5;

  //emulate type(enum).min/max for external consumers (mainly tests)
  function min() internal pure returns (uint8) { return ETH_CALL; }
  function max() internal pure returns (uint8) { return SOLANA_PDA; }

  function checkValid(uint8 queryType) internal pure {
    //slightly more gas efficient than calling `isValid`
    if (eagerOr(queryType == 0, queryType > SOLANA_PDA))
      revert UnsupportedQueryType(queryType);
  }

  function isValid(uint8 queryType) internal pure returns (bool) {
    //see docs/Optimization.md why `< CONST + 1` rather than `<= CONST`
    //see docs/Optimization.md for rationale behind `eagerAnd`
    return eagerAnd(queryType > 0, queryType < SOLANA_PDA + 1);
  }
}

struct QueryResponse {
  uint8 version;
  uint16 senderChainId;
  uint32 nonce;
  bytes requestId; // 65 byte sig for off-chain, 32 byte vaaHash for on-chain
  PerChainQueryResponse[] responses;
}

struct PerChainQueryResponse {
  uint16 chainId;
  uint8 queryType;
  bytes request;
  bytes response;
}

struct EthCallQueryResponse {
  bytes requestBlockId;
  uint64 blockNum;
  uint64 blockTime;
  bytes32 blockHash;
  EthCallRecord[] results;
}

struct EthCallByTimestampQueryResponse {
  bytes requestTargetBlockIdHint;
  bytes requestFollowingBlockIdHint;
  uint64 requestTargetTimestamp;
  uint64 targetBlockNum;
  uint64 targetBlockTime;
  uint64 followingBlockNum;
  bytes32 targetBlockHash;
  bytes32 followingBlockHash;
  uint64 followingBlockTime;
  EthCallRecord[] results;
}

struct EthCallWithFinalityQueryResponse {
  bytes requestBlockId;
  bytes requestFinality;
  uint64 blockNum;
  uint64 blockTime;
  bytes32 blockHash;
  EthCallRecord[] results;
}

struct EthCallRecord {
  address contractAddress;
  bytes callData;
  bytes result;
}

struct SolanaAccountQueryResponse {
  bytes requestCommitment;
  uint64 requestMinContextSlot;
  uint64 requestDataSliceOffset;
  uint64 requestDataSliceLength;
  uint64 slotNumber;
  uint64 blockTime;
  bytes32 blockHash;
  SolanaAccountResult[] results;
}

struct SolanaAccountResult {
  bytes32 account;
  uint64 lamports;
  uint64 rentEpoch;
  bool executable;
  bytes32 owner;
  bytes data;
}

struct SolanaPdaQueryResponse {
  bytes requestCommitment;
  uint64 requestMinContextSlot;
  uint64 requestDataSliceOffset;
  uint64 requestDataSliceLength;
  uint64 slotNumber;
  uint64 blockTime;
  bytes32 blockHash;
  SolanaPdaResult[] results;
}

struct SolanaPdaResult {
  bytes32 programId;
  bytes[] seeds;
  bytes32 account;
  uint64 lamports;
  uint64 rentEpoch;
  bool executable;
  bytes32 owner;
  bytes data;
  uint8 bump;
}

//QueryResponse is a library that implements the decoding and verification of
//  Cross Chain Query (CCQ) responses.
//
//For a detailed discussion of these query responses, please see the white paper:
//  https://github.com/wormhole-foundation/wormhole/blob/main/whitepapers/0013_ccq.md
//
//We only implement Cd and Mem decoding variants for the QueryResponse struct itself because all
//  further decoding will have to operate on the memory bytes anyway since there's no way in plain
//  Solidity to have structs with mixed data location, i.e. a struct in memory that references bytes
//  in calldata.
//  This will at least help cut down the gas cost of decoding/slicing the outer most layer.
library QueryResponseLib {
  using BytesParsing for bytes;

  error WrongQueryType(uint8 received, uint8 expected);
  error InvalidResponseVersion();
  error VersionMismatch();
  error ZeroQueries();
  error NumberOfResponsesMismatch();
  error ChainIdMismatch();
  error RequestTypeMismatch();
  error UnexpectedNumberOfResults();
  error InvalidPayloadLength(uint256 received, uint256 expected);
  error InvalidContractAddress();
  error InvalidFunctionSignature();
  error InvalidChainId();
  error StaleBlockNum();
  error StaleBlockTime();
  error VerificationFailed();

  bytes internal constant RESPONSE_PREFIX = bytes("query_response_0000000000000000000|");
  uint8 internal constant VERSION = 1;
  uint64 internal constant MICROSECONDS_PER_SECOND = 1_000_000;

  function calcPrefixedResponseHashCd(bytes calldata response) internal pure returns (bytes32) {
    return calcPrefixedResponseHash(keccak256Cd(response));
  }

  function calcPrefixedResponseHashMem(bytes memory response) internal pure returns (bytes32) {
    return calcPrefixedResponseHash(keccak256(response));
  }

  function calcPrefixedResponseHash(bytes32 responseHash) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(RESPONSE_PREFIX, responseHash));
  }

  // -------- decodeAndVerifyQueryResponse --------

  // ---- guardian set index variants
  // will look up the guardian set internally and also try to verify against the latest
  //   guardian set, if the specified guardian set is expired.

  function decodeAndVerifyQueryResponseCd(
    address wormhole,
    bytes calldata response,
    GuardianSignature[] calldata guardianSignatures,
    uint32 guardianSetIndex
  ) internal view returns (QueryResponse memory ret) {
    verifyQueryResponseCd(wormhole, response, guardianSignatures, guardianSetIndex);
    return decodeQueryResponseCd(response);
  }

  function decodeAndVerifyQueryResponseMem(
    address wormhole,
    bytes memory response,
    GuardianSignature[] memory guardianSignatures,
    uint32 guardianSetIndex
  ) internal view returns (QueryResponse memory ret) {
    verifyQueryResponseMem(wormhole, response, guardianSignatures, guardianSetIndex);
    return decodeQueryResponseMem(response);
  }

  function verifyQueryResponseCd(
    address wormhole,
    bytes calldata response,
    GuardianSignature[] calldata guardianSignatures,
    uint32 guardianSetIndex
  ) internal view {
    if (!CoreBridgeLib.isVerifiedByQuorumCd(
      wormhole,
      calcPrefixedResponseHashCd(response),
      guardianSignatures,
      guardianSetIndex
    ))
      revert VerificationFailed();
  }

  function verifyQueryResponseMem(
    address wormhole,
    bytes memory response,
    GuardianSignature[] memory guardianSignatures,
    uint32 guardianSetIndex
  ) internal view {
    if (!CoreBridgeLib.isVerifiedByQuorumMem(
      wormhole,
      calcPrefixedResponseHashMem(response),
      guardianSignatures,
      guardianSetIndex
    ))
      revert VerificationFailed();
  }

  // ---- guardian address variants
  // will only try to verify against the specified guardian addresses only

  function decodeAndVerifyQueryResponseCd(
    bytes calldata response,
    GuardianSignature[] calldata guardianSignatures,
    address[] memory guardians
  ) internal pure returns (QueryResponse memory ret) {
    verifyQueryResponseCd(response, guardianSignatures, guardians);
    return decodeQueryResponseCd(response);
  }

  function decodeAndVerifyQueryResponseMem(
    bytes memory response,
    GuardianSignature[] memory guardianSignatures,
    address[] memory guardians
  ) internal pure returns (QueryResponse memory ret) {
    verifyQueryResponseMem(response, guardianSignatures, guardians);
    return decodeQueryResponseMem(response);
  }

  function verifyQueryResponseCd(
    bytes calldata response,
    GuardianSignature[] calldata guardianSignatures,
    address[] memory guardians
  ) internal pure {
    if (!CoreBridgeLib.isVerifiedByQuorumCd(
      calcPrefixedResponseHashCd(response),
      guardianSignatures,
      guardians
    ))
      revert VerificationFailed();
  }

  function verifyQueryResponseMem(
    bytes memory response,
    GuardianSignature[] memory guardianSignatures,
    address[] memory guardians
  ) internal pure {
    if (!CoreBridgeLib.isVerifiedByQuorumMem(
      calcPrefixedResponseHashMem(response),
      guardianSignatures,
      guardians
    ))
      revert VerificationFailed();
  }

  // -------- decode functions --------

  function decodeQueryResponseCd(
    bytes calldata response
  ) internal pure returns (QueryResponse memory ret) { unchecked {
    uint offset;

    (ret.version, offset) = response.asUint8CdUnchecked(offset);
    if (ret.version != VERSION)
      revert InvalidResponseVersion();

    (ret.senderChainId, offset) = response.asUint16CdUnchecked(offset);

    //for off-chain requests (chainID zero), the requestId is the 65 byte signature
    //for on-chain requests, it is the 32 byte VAA hash
    (ret.requestId, offset) = response.sliceCdUnchecked(offset, ret.senderChainId == 0 ? 65 : 32);

    uint32 queryReqLen;
    (queryReqLen, offset) = response.asUint32CdUnchecked(offset);
    uint reqOff = offset;

    {
      uint8 version;
      (version, reqOff) = response.asUint8CdUnchecked(reqOff);
      if (version != ret.version)
        revert VersionMismatch();
    }

    (ret.nonce, reqOff) = response.asUint32CdUnchecked(reqOff);

    uint8 numPerChainQueries;
    (numPerChainQueries, reqOff) = response.asUint8CdUnchecked(reqOff);

    //a valid query request must have at least one per-chain-query
    if (numPerChainQueries == 0)
      revert ZeroQueries();

    //The response starts after the request.
    uint respOff = offset + queryReqLen;
    uint startOfResponse = respOff;

    uint8 respNumPerChainQueries;
    (respNumPerChainQueries, respOff) = response.asUint8CdUnchecked(respOff);
    if (respNumPerChainQueries != numPerChainQueries)
      revert NumberOfResponsesMismatch();

    ret.responses = new PerChainQueryResponse[](numPerChainQueries);

    //walk through the requests and responses in lock step.
    for (uint i; i < numPerChainQueries; ++i) {
      (ret.responses[i].chainId, reqOff) = response.asUint16CdUnchecked(reqOff);
      uint16 respChainId;
      (respChainId, respOff) = response.asUint16CdUnchecked(respOff);
      if (respChainId != ret.responses[i].chainId)
        revert ChainIdMismatch();

      (ret.responses[i].queryType, reqOff) = response.asUint8CdUnchecked(reqOff);
      QueryType.checkValid(ret.responses[i].queryType);
      uint8 respQueryType;
      (respQueryType, respOff) = response.asUint8CdUnchecked(respOff);
      if (respQueryType != ret.responses[i].queryType)
        revert RequestTypeMismatch();

      (ret.responses[i].request, reqOff) = response.sliceUint32PrefixedCdUnchecked(reqOff);

      (ret.responses[i].response, respOff) = response.sliceUint32PrefixedCdUnchecked(respOff);
    }

    //end of request body should align with start of response body
    if (startOfResponse != reqOff)
      revert InvalidPayloadLength(startOfResponse, reqOff);

    _checkLength(response.length, respOff);
    return ret;
  }}

  function decodeQueryResponseMem(
    bytes memory response
  ) internal pure returns (QueryResponse memory ret) { unchecked {
    uint offset;

    (ret.version, offset) = response.asUint8MemUnchecked(offset);
    if (ret.version != VERSION)
      revert InvalidResponseVersion();

    (ret.senderChainId, offset) = response.asUint16MemUnchecked(offset);

    //for off-chain requests (chainID zero), the requestId is the 65 byte signature
    //for on-chain requests, it is the 32 byte VAA hash
    (ret.requestId, offset) = response.sliceMemUnchecked(offset, ret.senderChainId == 0 ? 65 : 32);

    uint32 queryReqLen;
    (queryReqLen, offset) = response.asUint32MemUnchecked(offset);
    uint reqOff = offset;

    {
      uint8 version;
      (version, reqOff) = response.asUint8MemUnchecked(reqOff);
      if (version != ret.version)
        revert VersionMismatch();
    }

    (ret.nonce, reqOff) = response.asUint32MemUnchecked(reqOff);

    uint8 numPerChainQueries;
    (numPerChainQueries, reqOff) = response.asUint8MemUnchecked(reqOff);

    //a valid query request must have at least one per-chain-query
    if (numPerChainQueries == 0)
      revert ZeroQueries();

    //The response starts after the request.
    uint respOff = offset + queryReqLen;
    uint startOfResponse = respOff;

    uint8 respNumPerChainQueries;
    (respNumPerChainQueries, respOff) = response.asUint8MemUnchecked(respOff);
    if (respNumPerChainQueries != numPerChainQueries)
      revert NumberOfResponsesMismatch();

    ret.responses = new PerChainQueryResponse[](numPerChainQueries);

    //walk through the requests and responses in lock step.
    for (uint i; i < numPerChainQueries; ++i) {
      (ret.responses[i].chainId, reqOff) = response.asUint16MemUnchecked(reqOff);
      uint16 respChainId;
      (respChainId, respOff) = response.asUint16MemUnchecked(respOff);
      if (respChainId != ret.responses[i].chainId)
        revert ChainIdMismatch();

      (ret.responses[i].queryType, reqOff) = response.asUint8MemUnchecked(reqOff);
      QueryType.checkValid(ret.responses[i].queryType);
      uint8 respQueryType;
      (respQueryType, respOff) = response.asUint8MemUnchecked(respOff);
      if (respQueryType != ret.responses[i].queryType)
        revert RequestTypeMismatch();

      (ret.responses[i].request, reqOff) = response.sliceUint32PrefixedMemUnchecked(reqOff);

      (ret.responses[i].response, respOff) = response.sliceUint32PrefixedMemUnchecked(respOff);
    }

    //end of request body should align with start of response body
    if (startOfResponse != reqOff)
      revert InvalidPayloadLength(startOfResponse, reqOff);

    _checkLength(response.length, respOff);
    return ret;
  }}

  function decodeEthCallQueryResponse(
    PerChainQueryResponse memory pcr
  ) internal pure returns (EthCallQueryResponse memory ret) { unchecked {
    if (pcr.queryType != QueryType.ETH_CALL)
      revert WrongQueryType(pcr.queryType, QueryType.ETH_CALL);

    uint reqOff;
    uint respOff;

    uint8 numBatchCallData;
    (ret.requestBlockId, reqOff) = pcr.request.sliceUint32PrefixedMemUnchecked(reqOff);
    (numBatchCallData,   reqOff) = pcr.request.asUint8MemUnchecked(reqOff);

    uint8 respNumResults;
    (ret.blockNum,   respOff) = pcr.response.asUint64MemUnchecked(respOff);
    (ret.blockHash,  respOff) = pcr.response.asBytes32MemUnchecked(respOff);
    (ret.blockTime,  respOff) = pcr.response.asUint64MemUnchecked(respOff);
    (respNumResults, respOff) = pcr.response.asUint8MemUnchecked(respOff);

    if (respNumResults != numBatchCallData)
      revert UnexpectedNumberOfResults();

    ret.results = new EthCallRecord[](numBatchCallData);

    //walk through the call inputs and outputs in lock step.
    for (uint i; i < numBatchCallData; ++i) {
      EthCallRecord memory ecr = ret.results[i];
      (ecr.contractAddress, reqOff) = pcr.request.asAddressMemUnchecked(reqOff);
      (ecr.callData,        reqOff) = pcr.request.sliceUint32PrefixedMemUnchecked(reqOff);

      (ecr.result, respOff) = pcr.response.sliceUint32PrefixedMemUnchecked(respOff);
    }

    _checkLength(pcr.request.length, reqOff);
    _checkLength(pcr.response.length, respOff);
    return ret;
  }}

  function decodeEthCallByTimestampQueryResponse(
    PerChainQueryResponse memory pcr
  ) internal pure returns (EthCallByTimestampQueryResponse memory ret) { unchecked {
    if (pcr.queryType != QueryType.ETH_CALL_BY_TIMESTAMP)
      revert WrongQueryType(pcr.queryType, QueryType.ETH_CALL_BY_TIMESTAMP);

    uint reqOff;
    uint respOff;

    uint8 numBatchCallData;
    (ret.requestTargetTimestamp,      reqOff) = pcr.request.asUint64MemUnchecked(reqOff);
    (ret.requestTargetBlockIdHint,    reqOff) = pcr.request.sliceUint32PrefixedMemUnchecked(reqOff);
    (ret.requestFollowingBlockIdHint, reqOff) = pcr.request.sliceUint32PrefixedMemUnchecked(reqOff);
    (numBatchCallData,                reqOff) = pcr.request.asUint8MemUnchecked(reqOff);

    uint8 respNumResults;
    (ret.targetBlockNum,     respOff) = pcr.response.asUint64MemUnchecked(respOff);
    (ret.targetBlockHash,    respOff) = pcr.response.asBytes32MemUnchecked(respOff);
    (ret.targetBlockTime,    respOff) = pcr.response.asUint64MemUnchecked(respOff);
    (ret.followingBlockNum,  respOff) = pcr.response.asUint64MemUnchecked(respOff);
    (ret.followingBlockHash, respOff) = pcr.response.asBytes32MemUnchecked(respOff);
    (ret.followingBlockTime, respOff) = pcr.response.asUint64MemUnchecked(respOff);
    (respNumResults,         respOff) = pcr.response.asUint8MemUnchecked(respOff);

    if (respNumResults != numBatchCallData)
      revert UnexpectedNumberOfResults();

    ret.results = new EthCallRecord[](numBatchCallData);

    //walk through the call inputs and outputs in lock step.
    for (uint i; i < numBatchCallData; ++i) {
      EthCallRecord memory ecr = ret.results[i];
      (ecr.contractAddress, reqOff) = pcr.request.asAddressMemUnchecked(reqOff);
      (ecr.callData,        reqOff) = pcr.request.sliceUint32PrefixedMemUnchecked(reqOff);

      (ecr.result, respOff) = pcr.response.sliceUint32PrefixedMemUnchecked(respOff);
    }

    _checkLength(pcr.request.length, reqOff);
    _checkLength(pcr.response.length, respOff);
  }}

  function decodeEthCallWithFinalityQueryResponse(
    PerChainQueryResponse memory pcr
  ) internal pure returns (EthCallWithFinalityQueryResponse memory ret) { unchecked {
    if (pcr.queryType != QueryType.ETH_CALL_WITH_FINALITY)
      revert WrongQueryType(pcr.queryType, QueryType.ETH_CALL_WITH_FINALITY);

    uint reqOff;
    uint respOff;

    uint8 numBatchCallData;
    (ret.requestBlockId,  reqOff) = pcr.request.sliceUint32PrefixedMemUnchecked(reqOff);
    (ret.requestFinality, reqOff) = pcr.request.sliceUint32PrefixedMemUnchecked(reqOff);
    (numBatchCallData,    reqOff) = pcr.request.asUint8MemUnchecked(reqOff);

    uint8 respNumResults;
    (ret.blockNum,   respOff) = pcr.response.asUint64MemUnchecked(respOff);
    (ret.blockHash,  respOff) = pcr.response.asBytes32MemUnchecked(respOff);
    (ret.blockTime,  respOff) = pcr.response.asUint64MemUnchecked(respOff);
    (respNumResults, respOff) = pcr.response.asUint8MemUnchecked(respOff);

    if (respNumResults != numBatchCallData)
      revert UnexpectedNumberOfResults();

    ret.results = new EthCallRecord[](numBatchCallData);

    //walk through the call inputs and outputs in lock step.
    for (uint i; i < numBatchCallData; ++i) {
      EthCallRecord memory ecr = ret.results[i];
      (ecr.contractAddress, reqOff) = pcr.request.asAddressMemUnchecked(reqOff);
      (ecr.callData,        reqOff) = pcr.request.sliceUint32PrefixedMemUnchecked(reqOff);

      (ecr.result, respOff) = pcr.response.sliceUint32PrefixedMemUnchecked(respOff);
    }

    _checkLength(pcr.request.length, reqOff);
    _checkLength(pcr.response.length, respOff);
  }}

  function decodeSolanaAccountQueryResponse(
    PerChainQueryResponse memory pcr
  ) internal pure returns (SolanaAccountQueryResponse memory ret) { unchecked {
    if (pcr.queryType != QueryType.SOLANA_ACCOUNT)
      revert WrongQueryType(pcr.queryType, QueryType.SOLANA_ACCOUNT);

    uint reqOff;
    uint respOff;

    uint8 numAccounts;
    (ret.requestCommitment,      reqOff) = pcr.request.sliceUint32PrefixedMemUnchecked(reqOff);
    (ret.requestMinContextSlot,  reqOff) = pcr.request.asUint64MemUnchecked(reqOff);
    (ret.requestDataSliceOffset, reqOff) = pcr.request.asUint64MemUnchecked(reqOff);
    (ret.requestDataSliceLength, reqOff) = pcr.request.asUint64MemUnchecked(reqOff);
    (numAccounts,                reqOff) = pcr.request.asUint8MemUnchecked(reqOff);

    uint8 respNumResults;
    (ret.slotNumber, respOff) = pcr.response.asUint64MemUnchecked(respOff);
    (ret.blockTime,  respOff) = pcr.response.asUint64MemUnchecked(respOff);
    (ret.blockHash,  respOff) = pcr.response.asBytes32MemUnchecked(respOff);
    (respNumResults, respOff) = pcr.response.asUint8MemUnchecked(respOff);

    if (respNumResults != numAccounts)
      revert UnexpectedNumberOfResults();

    ret.results = new SolanaAccountResult[](numAccounts);

    //walk through the call inputs and outputs in lock step.
    for (uint i; i < numAccounts; ++i) {
      (ret.results[i].account, reqOff) = pcr.request.asBytes32MemUnchecked(reqOff);

      (ret.results[i].lamports,   respOff) = pcr.response.asUint64MemUnchecked(respOff);
      (ret.results[i].rentEpoch,  respOff) = pcr.response.asUint64MemUnchecked(respOff);
      (ret.results[i].executable, respOff) = pcr.response.asBoolMemUnchecked(respOff);
      (ret.results[i].owner,      respOff) = pcr.response.asBytes32MemUnchecked(respOff);
      (ret.results[i].data,       respOff) = pcr.response.sliceUint32PrefixedMemUnchecked(respOff);
    }

    _checkLength(pcr.request.length, reqOff);
    _checkLength(pcr.response.length, respOff);
  }}

  function decodeSolanaPdaQueryResponse(
    PerChainQueryResponse memory pcr
  ) internal pure returns (SolanaPdaQueryResponse memory ret) { unchecked {
    if (pcr.queryType != QueryType.SOLANA_PDA)
      revert WrongQueryType(pcr.queryType, QueryType.SOLANA_PDA);

    uint reqOff;
    uint respOff;

    (ret.requestCommitment,      reqOff) = pcr.request.sliceUint32PrefixedMemUnchecked(reqOff);
    (ret.requestMinContextSlot,  reqOff) = pcr.request.asUint64MemUnchecked(reqOff);
    (ret.requestDataSliceOffset, reqOff) = pcr.request.asUint64MemUnchecked(reqOff);
    (ret.requestDataSliceLength, reqOff) = pcr.request.asUint64MemUnchecked(reqOff);

    uint8 numPdas;
    (numPdas, reqOff) = pcr.request.asUint8MemUnchecked(reqOff);

    (ret.slotNumber, respOff) = pcr.response.asUint64MemUnchecked(respOff);
    (ret.blockTime,  respOff) = pcr.response.asUint64MemUnchecked(respOff);
    (ret.blockHash,  respOff) = pcr.response.asBytes32MemUnchecked(respOff);

    uint8 respNumResults;
    (respNumResults, respOff) = pcr.response.asUint8MemUnchecked(respOff);
    if (respNumResults != numPdas)
      revert UnexpectedNumberOfResults();

    ret.results = new SolanaPdaResult[](numPdas);

    //walk through the call inputs and outputs in lock step.
    for (uint i; i < numPdas; ++i) {
      (ret.results[i].programId, reqOff) = pcr.request.asBytes32MemUnchecked(reqOff);

      uint8 reqNumSeeds;
      (reqNumSeeds, reqOff) = pcr.request.asUint8MemUnchecked(reqOff);
      ret.results[i].seeds = new bytes[](reqNumSeeds);
      for (uint s; s < reqNumSeeds; ++s)
        (ret.results[i].seeds[s], reqOff) = pcr.request.sliceUint32PrefixedMemUnchecked(reqOff);

      (ret.results[i].account,    respOff) = pcr.response.asBytes32MemUnchecked(respOff);
      (ret.results[i].bump,       respOff) = pcr.response.asUint8MemUnchecked(respOff);
      (ret.results[i].lamports,   respOff) = pcr.response.asUint64MemUnchecked(respOff);
      (ret.results[i].rentEpoch,  respOff) = pcr.response.asUint64MemUnchecked(respOff);
      (ret.results[i].executable, respOff) = pcr.response.asBoolMemUnchecked(respOff);
      (ret.results[i].owner,      respOff) = pcr.response.asBytes32MemUnchecked(respOff);
      (ret.results[i].data,       respOff) = pcr.response.sliceUint32PrefixedMemUnchecked(respOff);
    }

    _checkLength(pcr.request.length, reqOff);
    _checkLength(pcr.response.length, respOff);
  }}

  function validateBlockTime(
    uint64 blockTimeInMicroSeconds,
    uint256 minBlockTimeInSeconds
  ) internal pure {
    uint256 blockTimeInSeconds = blockTimeInMicroSeconds / MICROSECONDS_PER_SECOND; // Rounds down

    if (blockTimeInSeconds < minBlockTimeInSeconds)
      revert StaleBlockTime();
  }

  function validateBlockNum(uint64 blockNum, uint256 minBlockNum) internal pure {
    if (blockNum < minBlockNum)
      revert StaleBlockNum();
  }

  function validateChainId(
    uint16 chainId,
    uint16[] memory validChainIds
  ) internal pure { unchecked {
    uint len = validChainIds.length;
    for (uint i; i < len; ++i)
      if (chainId == validChainIds[i])
        return;

    revert InvalidChainId();
  }}

  function validateEthCallRecord(
    EthCallRecord[] memory ecrs,
    address[] memory validContractAddresses,
    bytes4[] memory validFunctionSignatures
  ) internal pure { unchecked {
    uint len = ecrs.length;
    for (uint i; i < len; ++i)
      validateEthCallRecord(ecrs[i], validContractAddresses, validFunctionSignatures);
  }}

  //validates that EthCallRecord a valid function signature and contract address
  //An empty array means we accept all addresses/function signatures
  //  Example 1: To accept signatures 0xaaaaaaaa and 0xbbbbbbbb from `address(abcd)`
  //    you'd pass in [0xaaaaaaaa, 0xbbbbbbbb], [address(abcd)]
  //  Example 2: To accept any function signatures from `address(abcd)` or `address(efab)`
  //    you'd pass in [], [address(abcd), address(efab)]
  //  Example 3: To accept function signature 0xaaaaaaaa from any address
  //    you'd pass in [0xaaaaaaaa], []
  //
  // WARNING Example 4: If you want to accept signature 0xaaaaaaaa from `address(abcd)`
  //    and signature 0xbbbbbbbb from `address(efab)` the following input would be incorrect:
  //    [0xaaaaaaaa, 0xbbbbbbbb], [address(abcd), address(efab)]
  //    This would accept both 0xaaaaaaaa and 0xbbbbbbbb from `address(abcd)` AND `address(efab)`.
  //    Instead you should make 2 calls to this method using the pattern in Example 1.
  //    [0xaaaaaaaa], [address(abcd)] OR [0xbbbbbbbb], [address(efab)]
  function validateEthCallRecord(
    EthCallRecord memory ecd,
    address[] memory validContractAddresses, //empty array means accept all
    bytes4[] memory validFunctionSignatures  //empty array means accept all
  ) internal pure {
    if (validContractAddresses.length > 0)
      _validateContractAddress(ecd.contractAddress, validContractAddresses);

    if (validFunctionSignatures.length > 0) {
      if (ecd.callData.length < 4)
        revert InvalidFunctionSignature();

      (bytes4 funcSig, ) = ecd.callData.asBytes4MemUnchecked(0);
      _validateFunctionSignature(funcSig, validFunctionSignatures);
    }
  }

  function _validateContractAddress(
    address contractAddress,
    address[] memory validContractAddresses
  ) private pure { unchecked {
    uint len = validContractAddresses.length;
    for (uint i; i < len; ++i)
      if (contractAddress == validContractAddresses[i])
        return;

    revert InvalidContractAddress();
  }}

  function _validateFunctionSignature(
    bytes4 functionSignature,
    bytes4[] memory validFunctionSignatures
  ) private pure { unchecked {
    uint len = validFunctionSignatures.length;
    for (uint i; i < len; ++i)
      if (functionSignature == validFunctionSignatures[i])
        return;

    revert InvalidFunctionSignature();
  }}

  //we use this over BytesParsing.checkLength to return our custom errors in all error cases
  function _checkLength(uint256 length, uint256 expected) private pure {
    if (length != expected)
      revert InvalidPayloadLength(length, expected);
  }
}

// File: src/interfaces/ICaliberMailbox.sol

pragma solidity 0.8.28;




interface ICaliberMailbox is IMachineEndpoint {
    event CaliberSet(address indexed caliber);
    event HubBridgeAdapterSet(uint256 indexed bridgeId, address indexed adapter);

    /// @notice Accounting data of the caliber.
    /// @param netAum The net AUM expresses in caliber's accounting token.
    /// @param positions The list of positions of the caliber, each encoded as abi.encode(positionId, value, isDebt).
    /// @param baseTokens The list of base tokens of the caliber, each encoded as abi.encode(token, value).
    /// @param bridgesIn The list of incoming bridge amounts, each encoded as abi.encode(token, amount).
    /// @param bridgesOut The list of outgoing bridge amounts, each encoded as abi.encode(token, amount).
    struct SpokeCaliberAccountingData {
        uint256 netAum;
        bytes[] positions;
        bytes[] baseTokens;
        bytes[] bridgesIn;
        bytes[] bridgesOut;
    }

    /// @notice Initializer of the contract.
    /// @param mgParams The makina governable initialization parameters.
    /// @param hubMachine The foreign address of the hub machine.
    function initialize(IMakinaGovernable.MakinaGovernableInitParams calldata mgParams, address hubMachine) external;

    /// @notice Address of the associated caliber.
    function caliber() external view returns (address);

    /// @notice Returns the foreign address of the Hub bridge adapter for a given bridge ID.
    /// @param bridgeId The ID of the bridge.
    function getHubBridgeAdapter(uint16 bridgeId) external view returns (address);

    /// @notice Chain ID of the hub.
    function hubChainId() external view returns (uint256);

    /// @notice Returns the accounting data of the associated caliber.
    /// @return data The accounting data.
    function getSpokeCaliberAccountingData() external view returns (SpokeCaliberAccountingData memory);

    /// @notice Sets the associated caliber address.
    /// @param caliber The address of the associated caliber.
    function setCaliber(address caliber) external;

    /// @notice Registers a hub bridge adapter.
    /// @param bridgeId The ID of the bridge.
    /// @param adapter The foreign address of the bridge adapter.
    function setHubBridgeAdapter(uint16 bridgeId, address adapter) external;
}

// File: src/interfaces/IFeeManager.sol

pragma solidity 0.8.28;

interface IFeeManager {
    /// @notice Calculates the fixed fee for a given share supply and elapsed time.
    /// @dev May update internal state related to fee accrual or realization.
    /// @param shareSupply The total supply of shares.
    /// @param elapsedTime The elapsed time since the last fee realization.
    /// @return fee The calculated fixed fee.
    function calculateFixedFee(uint256 shareSupply, uint256 elapsedTime) external returns (uint256);

    /// @notice Calculates the performance fee based on the share supply, share price performance and elapsed time.
    /// @dev May update internal state related to fee accrual or realization.
    /// @param currentShareSupply The current total supply of shares.
    /// @param oldSharePrice The previous share price of reference.
    /// @param newSharePrice The new share price of reference.
    /// @param elapsedTime The elapsed time since the last fee realization.
    /// @return fee The calculated performance fee.
    function calculatePerformanceFee(
        uint256 currentShareSupply,
        uint256 oldSharePrice,
        uint256 newSharePrice,
        uint256 elapsedTime
    ) external returns (uint256);

    /// @notice Distributes the fees to relevant recipients.
    /// @param fixedFee The fixed fee amount to be distributed.
    /// @param perfFee The performance fee amount to be distributed.
    function distributeFees(uint256 fixedFee, uint256 perfFee) external;
}

// File: src/interfaces/IPreDepositVault.sol

pragma solidity 0.8.28;

interface IPreDepositVault {
    event Deposit(address indexed sender, address indexed receiver, uint256 assets, uint256 shares);
    event MigrateToMachine(address indexed machine);
    event Redeem(address indexed owner, address indexed receiver, uint256 assets, uint256 shares);
    event RiskManagerChanged(address indexed oldRiskManager, address indexed newRiskManager);
    event ShareLimitChanged(uint256 indexed oldShareLimit, uint256 indexed newShareLimit);
    event UserWhitelistingChanged(address indexed user, bool indexed whitelisted);
    event WhitelistModeChanged(bool indexed enabled);

    struct PreDepositVaultInitParams {
        uint256 initialShareLimit;
        bool initialWhitelistMode;
        address initialRiskManager;
        address initialAuthority;
    }

    /// @notice Initializer of the contract.
    /// @param params The initialization parameters.
    /// @param shareToken The address of the share token.
    /// @param depositToken The address of the deposit token.
    /// @param accountingToken The address of the accounting token.
    function initialize(
        PreDepositVaultInitParams calldata params,
        address shareToken,
        address depositToken,
        address accountingToken
    ) external;

    /// @notice True if the vault has migrated to a machine instance, false otherwise.
    function migrated() external view returns (bool);

    /// @notice Address of the machine, set during migration.
    function machine() external view returns (address);

    /// @notice Address of the risk manager.
    function riskManager() external view returns (address);

    /// @notice True if the vault is in whitelist mode, false otherwise.
    function whitelistMode() external view returns (bool);

    /// @notice User => Whitelisting status.
    function isWhitelistedUser(address user) external view returns (bool);

    /// @notice Address of the deposit token.
    function depositToken() external view returns (address);

    /// @notice Address of the accounting token.
    function accountingToken() external view returns (address);

    /// @notice Address of the share token.
    function shareToken() external view returns (address);

    /// @notice Share token supply limit that cannot be exceeded by new deposits.
    function shareLimit() external view returns (uint256);

    /// @notice Maximum amount of deposit tokens that can currently be deposited in the vault.
    function maxDeposit() external view returns (uint256);

    /// @notice Total amount of deposit tokens managed by the vault.
    function totalAssets() external view returns (uint256);

    /// @notice Amount of shares minted against a given amount of deposit tokens.
    /// @param assets The amount of deposit tokens to be deposited.
    function previewDeposit(uint256 assets) external view returns (uint256);

    /// @notice Amount of deposit tokens that can be withdrawn against a given amount of shares.
    /// @param assets The amount of shares to be redeemed.
    function previewRedeem(uint256 assets) external view returns (uint256);

    /// @notice Deposits a given amount of deposit tokens and mints shares to the receiver.
    /// @param assets The amount of deposit tokens to be deposited.
    /// @param receiver The receiver of the shares.
    /// @param minShares The minimum amount of shares to be minted.
    /// @return shares The amount of shares minted.
    function deposit(uint256 assets, address receiver, uint256 minShares) external returns (uint256);

    /// @notice Burns exactly shares from caller and transfers the corresponding amount of deposit tokens to the receiver.
    /// @param shares The amount of shares to be redeemed.
    /// @param receiver The receiver of withdrawn deposit tokens.
    /// @param minAssets The minimum amount of deposit tokens to be transferred.
    /// @return assets The amount of deposit tokens transferred.
    function redeem(uint256 shares, address receiver, uint256 minAssets) external returns (uint256);

    /// @notice Migrates the pre-deposit vault to the machine.
    function migrateToMachine() external;

    /// @notice Sets the machine address to migrate to.
    /// @param machine The address of the machine.
    function setPendingMachine(address machine) external;

    /// @notice Sets the risk manager address.
    /// @param newRiskManager The address of the new risk manager.
    function setRiskManager(address newRiskManager) external;

    /// @notice Sets the new share token supply limit that cannot be exceeded by new deposits.
    /// @param newShareLimit The new share limit
    function setShareLimit(uint256 newShareLimit) external;

    /// @notice Whitelist or unwhitelist a list of users.
    /// @param users The addresses of the users to update.
    /// @param whitelisted True to whitelist the users, false to unwhitelist.
    function setWhitelistedUsers(address[] calldata users, bool whitelisted) external;

    /// @notice Sets the whitelist mode for the vault.
    /// @dev In whitelist mode, only whitelisted users can deposit.
    /// @param enabled True to enable whitelist mode, false to disable.
    function setWhitelistMode(bool enabled) external;
}

// File: src/libraries/CaliberAccountingCCQ.sol

pragma solidity 0.8.28;








library CaliberAccountingCCQ {
    function decodeAndVerifyQueryResponse(
        address wormhole,
        bytes calldata response,
        GuardianSignature[] calldata signatures
    ) external view returns (QueryResponse memory ret) {
        return QueryResponseLib.decodeAndVerifyQueryResponseCd(
            wormhole, response, signatures, IWormhole(wormhole).getCurrentGuardianSetIndex()
        );
    }

    /// @dev Parses the PerChainQueryResponse and retrieves the accounting data for the given caliber mailbox.
    /// @param pcr The PerChainQueryResponse containing the query results.
    /// @param caliberMailbox The address of the queried caliber mailbox.
    /// @return data The accounting data for the given caliber mailbox
    /// @return responseTimestamp The timestamp of the response.
    function getAccountingData(PerChainQueryResponse memory pcr, address caliberMailbox)
        external
        pure
        returns (ICaliberMailbox.SpokeCaliberAccountingData memory, uint256)
    {
        EthCallQueryResponse memory eqr = QueryResponseLib.decodeEthCallQueryResponse(pcr);

        // Validate that only one result is returned.
        if (eqr.results.length != 1) {
            revert Errors.UnexpectedResultLength();
        }

        // Validate addresses and function signatures.
        address[] memory validAddresses = new address[](1);
        bytes4[] memory validFunctionSignatures = new bytes4[](1);
        validAddresses[0] = caliberMailbox;
        validFunctionSignatures[0] = ICaliberMailbox.getSpokeCaliberAccountingData.selector;
        QueryResponseLib.validateEthCallRecord(eqr.results[0], validAddresses, validFunctionSignatures);

        return (
            abi.decode(eqr.results[0].result, (ICaliberMailbox.SpokeCaliberAccountingData)),
            eqr.blockTime / QueryResponseLib.MICROSECONDS_PER_SECOND
        );
    }
}

// File: src/libraries/MachineUtils.sol

pragma solidity 0.8.28;























library MachineUtils {
    using Math for uint256;
    using EnumerableMap for EnumerableMap.AddressToUintMap;
    using EnumerableSet for EnumerableSet.AddressSet;

    uint256 private constant FEE_ACCRUAL_RATE_DIVISOR = 1e18;

    function updateTotalAum(Machine.MachineStorage storage $, address oracleRegistry) external returns (uint256) {
        $._lastTotalAum = _getTotalAum($, oracleRegistry);
        $._lastGlobalAccountingTime = block.timestamp;
        return $._lastTotalAum;
    }

    function manageFees(Machine.MachineStorage storage $) external returns (uint256) {
        uint256 currentTimestamp = block.timestamp;
        uint256 elapsedTime = currentTimestamp - $._lastMintedFeesTime;

        if (elapsedTime >= $._feeMintCooldown) {
            address _feeManager = $._feeManager;
            address _shareToken = $._shareToken;
            uint256 currentShareSupply = IERC20(_shareToken).totalSupply();

            uint256 fixedFee = Math.min(
                IFeeManager(_feeManager).calculateFixedFee(currentShareSupply, elapsedTime),
                (currentShareSupply * elapsedTime).mulDiv($._maxFixedFeeAccrualRate, FEE_ACCRUAL_RATE_DIVISOR)
            );

            // offset fixed fee from the share price performance on which the performance fee is calculated.
            uint256 netSharePrice =
                getSharePrice($._lastTotalAum, currentShareSupply + fixedFee, $._shareTokenDecimalsOffset);
            uint256 perfFee = Math.min(
                IFeeManager(_feeManager).calculatePerformanceFee(
                    currentShareSupply, $._lastMintedFeesSharePrice, netSharePrice, elapsedTime
                ),
                (currentShareSupply * elapsedTime).mulDiv($._maxPerfFeeAccrualRate, FEE_ACCRUAL_RATE_DIVISOR)
            );

            uint256 totalFee = fixedFee + perfFee;
            if (totalFee != 0) {
                uint256 balBefore = IMachineShare(_shareToken).balanceOf(address(this));

                IMachineShare(_shareToken).mint(address(this), totalFee);
                IMachineShare(_shareToken).approve(_feeManager, totalFee);

                IFeeManager(_feeManager).distributeFees(fixedFee, perfFee);

                IMachineShare(_shareToken).approve(_feeManager, 0);

                uint256 balAfter = IMachineShare(_shareToken).balanceOf(address(this));
                if (balAfter > balBefore) {
                    uint256 dust = balAfter - balBefore;
                    IMachineShare(_shareToken).burn(address(this), dust);
                    totalFee -= dust;
                }
            }

            $._lastMintedFeesTime = currentTimestamp;
            $._lastMintedFeesSharePrice =
                getSharePrice($._lastTotalAum, IERC20(_shareToken).totalSupply(), $._shareTokenDecimalsOffset);

            return totalFee;
        }
        return 0;
    }

    /// @dev Updates the spoke caliber accounting data in the machine storage.
    /// @param $ The machine storage struct.
    /// @param tokenRegistry The address of the token registry.
    /// @param chainRegistry The address of the chain registry.
    /// @param wormhole The address of the Core Wormhole contract.
    /// @param response The Wormhole CCQ response payload containing the accounting data.
    /// @param signatures The array of Wormhole guardians signatures attesting to the validity of the response.
    function updateSpokeCaliberAccountingData(
        Machine.MachineStorage storage $,
        address tokenRegistry,
        address chainRegistry,
        address wormhole,
        bytes calldata response,
        GuardianSignature[] calldata signatures
    ) external {
        PerChainQueryResponse[] memory responses =
            CaliberAccountingCCQ.decodeAndVerifyQueryResponse(wormhole, response, signatures).responses;

        uint256 len = responses.length;
        for (uint256 i; i < len; ++i) {
            _handlePerChainQueryResponse($, tokenRegistry, chainRegistry, responses[i]);
        }
    }

    /// @dev Manages the migration from a pre-deposit vault to a machine, and initializes the machine's accounting state.
    /// @param $ The machine storage struct.
    /// @param preDepositVault The address of the pre-deposit vault.
    /// @param oracleRegistry The address of the oracle registry.
    function migrateFromPreDeposit(Machine.MachineStorage storage $, address preDepositVault, address oracleRegistry)
        external
    {
        IPreDepositVault(preDepositVault).migrateToMachine();

        address preDepositToken = IPreDepositVault(preDepositVault).depositToken();
        $._idleTokens.add(preDepositToken);

        $._lastTotalAum = _accountingValueOf(
            oracleRegistry, $._accountingToken, preDepositToken, IERC20(preDepositToken).balanceOf(address(this))
        );
        $._lastGlobalAccountingTime = block.timestamp;
    }

    /// @dev Calculates the share price based on given AUM, share supply and share token decimals offset.
    /// @param aum The AUM of the machine.
    /// @param supply The supply of the share token.
    /// @param shareTokenDecimalsOffset The decimals offset between share token and accounting token.
    /// @return The calculated share price.
    function getSharePrice(uint256 aum, uint256 supply, uint256 shareTokenDecimalsOffset)
        public
        pure
        returns (uint256)
    {
        return DecimalsUtils.SHARE_TOKEN_UNIT.mulDiv(aum + 1, supply + 10 ** shareTokenDecimalsOffset);
    }

    /// @dev Handles a received Wormhole CCQ PerChainQueryResponse object and updates the corresponding caliber accounting data in the machine storage.
    /// @param $ The machine storage struct.
    /// @param tokenRegistry The address of the token registry.
    /// @param chainRegistry The address of the chain registry.
    /// @param pcr The PerChainQueryResponse object containing the accounting data.
    function _handlePerChainQueryResponse(
        Machine.MachineStorage storage $,
        address tokenRegistry,
        address chainRegistry,
        PerChainQueryResponse memory pcr
    ) private {
        uint256 _evmChainId = IChainRegistry(chainRegistry).whToEvmChainId(pcr.chainId);

        IMachine.SpokeCaliberData storage caliberData = $._spokeCalibersData[_evmChainId];

        if (caliberData.mailbox == address(0)) {
            revert Errors.InvalidChainId();
        }

        // Decode and validate accounting data.
        (ICaliberMailbox.SpokeCaliberAccountingData memory accountingData, uint256 responseTimestamp) =
            CaliberAccountingCCQ.getAccountingData(pcr, caliberData.mailbox);

        // Validate that update is not older than current chain last update, nor stale.
        if (
            responseTimestamp <= caliberData.timestamp
                || (block.timestamp > responseTimestamp && block.timestamp - responseTimestamp >= $._caliberStaleThreshold)
        ) {
            revert Errors.StaleData();
        }

        // Update the spoke caliber data in the machine storage.
        caliberData.netAum = accountingData.netAum;
        caliberData.positions = accountingData.positions;
        caliberData.baseTokens = accountingData.baseTokens;
        caliberData.timestamp = responseTimestamp;
        _decodeAndMapBridgeAmounts(_evmChainId, accountingData.bridgesIn, caliberData.caliberBridgesIn, tokenRegistry);
        _decodeAndMapBridgeAmounts(_evmChainId, accountingData.bridgesOut, caliberData.caliberBridgesOut, tokenRegistry);
    }

    /// @dev Decodes (foreignToken, amount) pairs, resolves local tokens, and stores amounts in the map.
    function _decodeAndMapBridgeAmounts(
        uint256 chainId,
        bytes[] memory data,
        EnumerableMap.AddressToUintMap storage map,
        address tokenRegistry
    ) private {
        uint256 len = data.length;
        for (uint256 i; i < len; ++i) {
            (address foreignToken, uint256 amount) = abi.decode(data[i], (address, uint256));
            address localToken = ITokenRegistry(tokenRegistry).getLocalToken(foreignToken, chainId);
            map.set(localToken, amount);
        }
    }

    /// @dev Computes the total AUM of the machine.
    /// @param $ The machine storage struct.
    /// @param oracleRegistry The address of the oracle registry.
    function _getTotalAum(Machine.MachineStorage storage $, address oracleRegistry) private view returns (uint256) {
        uint256 totalAum;

        // spoke calibers net AUM
        uint256 currentTimestamp = block.timestamp;
        uint256 len = $._foreignChainIds.length;
        for (uint256 i; i < len; ++i) {
            uint256 chainId = $._foreignChainIds[i];
            IMachine.SpokeCaliberData storage spokeCaliberData = $._spokeCalibersData[chainId];
            if (
                currentTimestamp > spokeCaliberData.timestamp
                    && currentTimestamp - spokeCaliberData.timestamp >= $._caliberStaleThreshold
            ) {
                revert Errors.CaliberAccountingStale(chainId);
            }
            totalAum += spokeCaliberData.netAum;

            // check for funds received by machine but not declared by spoke caliber
            _checkBridgeState(spokeCaliberData.machineBridgesIn, spokeCaliberData.caliberBridgesOut);

            // check for funds received by spoke caliber but not declared by machine
            _checkBridgeState(spokeCaliberData.caliberBridgesIn, spokeCaliberData.machineBridgesOut);

            // check for funds sent by machine but not yet received by spoke caliber
            uint256 len2 = spokeCaliberData.machineBridgesOut.length();
            for (uint256 j; j < len2; ++j) {
                (address token, uint256 mOut) = spokeCaliberData.machineBridgesOut.at(j);
                (, uint256 cIn) = spokeCaliberData.caliberBridgesIn.tryGet(token);
                if (mOut > cIn) {
                    totalAum += _accountingValueOf(oracleRegistry, $._accountingToken, token, mOut - cIn);
                }
            }

            // check for funds sent by spoke caliber but not yet received by machine
            len2 = spokeCaliberData.caliberBridgesOut.length();
            for (uint256 j; j < len2; ++j) {
                (address token, uint256 cOut) = spokeCaliberData.caliberBridgesOut.at(j);
                (, uint256 mIn) = spokeCaliberData.machineBridgesIn.tryGet(token);
                if (cOut > mIn) {
                    totalAum += _accountingValueOf(oracleRegistry, $._accountingToken, token, cOut - mIn);
                }
            }
        }

        // hub caliber net AUM
        (uint256 hcAum,,) = ICaliber($._hubCaliber).getDetailedAum();
        totalAum += hcAum;

        // idle tokens
        len = $._idleTokens.length();
        for (uint256 i; i < len; ++i) {
            address token = $._idleTokens.at(i);
            totalAum +=
                _accountingValueOf(oracleRegistry, $._accountingToken, token, IERC20(token).balanceOf(address(this)));
        }

        return totalAum;
    }

    /// @dev Checks if the bridge state is consistent between the machine and spoke caliber.
    function _checkBridgeState(
        EnumerableMap.AddressToUintMap storage insMap,
        EnumerableMap.AddressToUintMap storage outsMap
    ) private view {
        uint256 len = insMap.length();
        for (uint256 i; i < len; ++i) {
            (address token, uint256 amountIn) = insMap.at(i);
            (, uint256 amountOut) = outsMap.tryGet(token);
            if (amountIn > amountOut) {
                revert Errors.BridgeStateMismatch();
            }
        }
    }

    /// @dev Computes the accounting value of a given token amount.
    function _accountingValueOf(address oracleRegistry, address accountingToken, address token, uint256 amount)
        private
        view
        returns (uint256)
    {
        if (token == accountingToken) {
            return amount;
        }
        uint256 price = IOracleRegistry(oracleRegistry).getPrice(token, accountingToken);
        return amount.mulDiv(price, 10 ** DecimalsUtils._getDecimals(token));
    }
}

// File: src/machine/Machine.sol

pragma solidity 0.8.28;




























contract Machine is MakinaGovernable, BridgeController, ReentrancyGuardUpgradeable, IMachine {
    using Math for uint256;
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableMap for EnumerableMap.AddressToUintMap;

    /// @inheritdoc IMachine
    address public immutable wormhole;

    /// @custom:storage-location erc7201:makina.storage.Machine
    struct MachineStorage {
        address _shareToken;
        address _accountingToken;
        address _depositor;
        address _redeemer;
        address _feeManager;
        uint256 _caliberStaleThreshold;
        uint256 _lastTotalAum;
        uint256 _lastGlobalAccountingTime;
        uint256 _lastMintedFeesTime;
        uint256 _lastMintedFeesSharePrice;
        uint256 _maxFixedFeeAccrualRate;
        uint256 _maxPerfFeeAccrualRate;
        uint256 _feeMintCooldown;
        uint256 _shareTokenDecimalsOffset;
        uint256 _shareLimit;
        uint256 _hubChainId;
        address _hubCaliber;
        uint256[] _foreignChainIds;
        mapping(uint256 foreignChainId => SpokeCaliberData data) _spokeCalibersData;
        EnumerableSet.AddressSet _idleTokens;
    }

    // keccak256(abi.encode(uint256(keccak256("makina.storage.Machine")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant MachineStorageLocation = 0x55fe2a17e400bcd0e2125123a7fc955478e727b29a4c522f4f2bd95d961bd900;

    function _getMachineStorage() private pure returns (MachineStorage storage $) {
        assembly {
            $.slot := MachineStorageLocation
        }
    }

    constructor(address _registry, address _wormhole) MakinaContext(_registry) {
        wormhole = _wormhole;
        _disableInitializers();
    }

    /// @inheritdoc IMachine
    function initialize(
        MachineInitParams calldata mParams,
        MakinaGovernableInitParams calldata mgParams,
        address _preDepositVault,
        address _shareToken,
        address _accountingToken,
        address _hubCaliber
    ) external override initializer {
        MachineStorage storage $ = _getMachineStorage();

        $._hubChainId = block.chainid;
        $._hubCaliber = _hubCaliber;

        address oracleRegistry = IHubCoreRegistry(registry).oracleRegistry();
        if (!IOracleRegistry(oracleRegistry).isFeedRouteRegistered(_accountingToken)) {
            revert Errors.PriceFeedRouteNotRegistered(_accountingToken);
        }

        uint256 atDecimals = DecimalsUtils._getDecimals(_accountingToken);

        $._shareToken = _shareToken;
        $._accountingToken = _accountingToken;
        $._idleTokens.add(_accountingToken);
        $._shareTokenDecimalsOffset = DecimalsUtils.SHARE_TOKEN_DECIMALS - atDecimals;

        if (_preDepositVault != address(0)) {
            MachineUtils.migrateFromPreDeposit($, _preDepositVault, oracleRegistry);
            uint256 currentShareSupply = IERC20($._shareToken).totalSupply();
            $._lastMintedFeesSharePrice =
                MachineUtils.getSharePrice($._lastTotalAum, currentShareSupply, $._shareTokenDecimalsOffset);
        } else {
            $._lastMintedFeesSharePrice = 10 ** atDecimals;
        }

        IOwnable2Step(_shareToken).acceptOwnership();

        $._lastMintedFeesTime = block.timestamp;
        $._depositor = mParams.initialDepositor;
        $._redeemer = mParams.initialRedeemer;
        $._feeManager = mParams.initialFeeManager;
        $._caliberStaleThreshold = mParams.initialCaliberStaleThreshold;
        $._maxFixedFeeAccrualRate = mParams.initialMaxFixedFeeAccrualRate;
        $._maxPerfFeeAccrualRate = mParams.initialMaxPerfFeeAccrualRate;
        $._feeMintCooldown = mParams.initialFeeMintCooldown;
        $._shareLimit = mParams.initialShareLimit;
        __MakinaGovernable_init(mgParams);
    }

    /// @inheritdoc IMachine
    function depositor() external view override returns (address) {
        return _getMachineStorage()._depositor;
    }

    /// @inheritdoc IMachine
    function redeemer() external view override returns (address) {
        return _getMachineStorage()._redeemer;
    }

    /// @inheritdoc IMachine
    function shareToken() external view override returns (address) {
        return _getMachineStorage()._shareToken;
    }

    /// @inheritdoc IMachine
    function accountingToken() external view override returns (address) {
        return _getMachineStorage()._accountingToken;
    }

    /// @inheritdoc IMachine
    function hubCaliber() external view returns (address) {
        return _getMachineStorage()._hubCaliber;
    }

    /// @inheritdoc IMachine
    function feeManager() external view override returns (address) {
        return _getMachineStorage()._feeManager;
    }

    /// @inheritdoc IMachine
    function caliberStaleThreshold() external view override returns (uint256) {
        return _getMachineStorage()._caliberStaleThreshold;
    }

    /// @inheritdoc IMachine
    function maxFixedFeeAccrualRate() external view override returns (uint256) {
        return _getMachineStorage()._maxFixedFeeAccrualRate;
    }

    /// @inheritdoc IMachine
    function maxPerfFeeAccrualRate() external view override returns (uint256) {
        return _getMachineStorage()._maxPerfFeeAccrualRate;
    }

    /// @inheritdoc IMachine
    function feeMintCooldown() external view override returns (uint256) {
        return _getMachineStorage()._feeMintCooldown;
    }

    /// @inheritdoc IMachine
    function shareLimit() external view override returns (uint256) {
        return _getMachineStorage()._shareLimit;
    }

    /// @inheritdoc IMachine
    function maxMint() public view override returns (uint256) {
        MachineStorage storage $ = _getMachineStorage();
        if ($._shareLimit == type(uint256).max) {
            return type(uint256).max;
        }
        uint256 totalSupply = IERC20($._shareToken).totalSupply();
        return totalSupply < $._shareLimit ? $._shareLimit - totalSupply : 0;
    }

    /// @inheritdoc IMachine
    function maxWithdraw() public view override returns (uint256) {
        MachineStorage storage $ = _getMachineStorage();
        return IERC20($._accountingToken).balanceOf(address(this));
    }

    /// @inheritdoc IMachine
    function lastTotalAum() external view override returns (uint256) {
        return _getMachineStorage()._lastTotalAum;
    }

    /// @inheritdoc IMachine
    function lastGlobalAccountingTime() external view override returns (uint256) {
        return _getMachineStorage()._lastGlobalAccountingTime;
    }

    /// @inheritdoc IMachine
    function getSpokeCalibersLength() external view override returns (uint256) {
        return _getMachineStorage()._foreignChainIds.length;
    }

    /// @inheritdoc IMachine
    function getSpokeChainId(uint256 idx) external view override returns (uint256) {
        return _getMachineStorage()._foreignChainIds[idx];
    }

    /// @inheritdoc IMachine
    function getSpokeCaliberDetailedAum(uint256 chainId)
        external
        view
        override
        returns (uint256, bytes[] memory, bytes[] memory, uint256)
    {
        SpokeCaliberData storage scData = _getMachineStorage()._spokeCalibersData[chainId];
        if (scData.mailbox == address(0)) {
            revert Errors.InvalidChainId();
        }
        return (scData.netAum, scData.positions, scData.baseTokens, scData.timestamp);
    }

    /// @inheritdoc IMachine
    function getSpokeCaliberMailbox(uint256 chainId) external view returns (address) {
        SpokeCaliberData storage scData = _getMachineStorage()._spokeCalibersData[chainId];
        if (scData.mailbox == address(0)) {
            revert Errors.InvalidChainId();
        }
        return scData.mailbox;
    }

    /// @inheritdoc IMachine
    function getSpokeBridgeAdapter(uint256 chainId, uint16 bridgeId) external view returns (address) {
        SpokeCaliberData storage scData = _getMachineStorage()._spokeCalibersData[chainId];
        if (scData.mailbox == address(0)) {
            revert Errors.InvalidChainId();
        }
        address adapter = scData.bridgeAdapters[bridgeId];
        if (adapter == address(0)) {
            revert Errors.SpokeBridgeAdapterNotSet();
        }
        return adapter;
    }

    /// @inheritdoc IMachine
    function isIdleToken(address token) external view override returns (bool) {
        return _getMachineStorage()._idleTokens.contains(token);
    }

    /// @inheritdoc IMachine
    function convertToShares(uint256 assets) public view override returns (uint256) {
        MachineStorage storage $ = _getMachineStorage();
        return
            assets.mulDiv(IERC20($._shareToken).totalSupply() + 10 ** $._shareTokenDecimalsOffset, $._lastTotalAum + 1);
    }

    /// @inheritdoc IMachine
    function convertToAssets(uint256 shares) public view override returns (uint256) {
        MachineStorage storage $ = _getMachineStorage();
        return
            shares.mulDiv($._lastTotalAum + 1, IERC20($._shareToken).totalSupply() + 10 ** $._shareTokenDecimalsOffset);
    }

    /// @inheritdoc IMachineEndpoint
    function manageTransfer(address token, uint256 amount, bytes calldata data) external override nonReentrant {
        MachineStorage storage $ = _getMachineStorage();

        if (_isBridgeAdapter(msg.sender)) {
            (uint256 chainId, uint256 inputAmount, bool refund) = abi.decode(data, (uint256, uint256, bool));

            SpokeCaliberData storage caliberData = $._spokeCalibersData[chainId];

            if (caliberData.mailbox == address(0)) {
                revert Errors.InvalidChainId();
            }

            if (refund) {
                uint256 mOut = caliberData.machineBridgesOut.get(token);
                uint256 newMOut = mOut - inputAmount;
                (, uint256 cIn) = caliberData.caliberBridgesIn.tryGet(token);
                if (cIn > newMOut) {
                    revert Errors.BridgeStateMismatch();
                }
                caliberData.machineBridgesOut.set(token, newMOut);
            } else {
                (, uint256 mIn) = caliberData.machineBridgesIn.tryGet(token);
                uint256 newMIn = mIn + inputAmount;
                (, uint256 cOut) = caliberData.caliberBridgesOut.tryGet(token);
                if (newMIn > cOut) {
                    revert Errors.BridgeStateMismatch();
                }
                caliberData.machineBridgesIn.set(token, newMIn);
            }
        } else if (msg.sender != $._hubCaliber) {
            revert Errors.UnauthorizedCaller();
        }

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        _notifyIdleToken(token);
    }

    /// @inheritdoc IMachine
    function transferToHubCaliber(address token, uint256 amount) external override notRecoveryMode onlyMechanic {
        MachineStorage storage $ = _getMachineStorage();

        IERC20(token).forceApprove($._hubCaliber, amount);
        ICaliber($._hubCaliber).notifyIncomingTransfer(token, amount);

        emit TransferToCaliber($._hubChainId, token, amount);

        if (IERC20(token).balanceOf(address(this)) == 0 && token != $._accountingToken) {
            $._idleTokens.remove(token);
        }
    }

    /// @inheritdoc IMachine
    function transferToSpokeCaliber(
        uint16 bridgeId,
        uint256 chainId,
        address token,
        uint256 amount,
        uint256 minOutputAmount
    ) external override nonReentrant notRecoveryMode onlyMechanic {
        MachineStorage storage $ = _getMachineStorage();

        address outputToken = ITokenRegistry(IHubCoreRegistry(registry).tokenRegistry()).getForeignToken(token, chainId);

        SpokeCaliberData storage caliberData = $._spokeCalibersData[chainId];

        if (caliberData.mailbox == address(0)) {
            revert Errors.InvalidChainId();
        }

        address recipient = caliberData.bridgeAdapters[bridgeId];
        if (recipient == address(0)) {
            revert Errors.SpokeBridgeAdapterNotSet();
        }

        (bool exists, uint256 mOut) = caliberData.machineBridgesOut.tryGet(token);
        (, uint256 cIn) = caliberData.caliberBridgesIn.tryGet(token);
        if (mOut > cIn) {
            revert Errors.PendingBridgeTransfer();
        } else if (mOut < cIn) {
            revert Errors.BridgeStateMismatch();
        }
        caliberData.machineBridgesOut.set(token, exists ? mOut + amount : amount);

        _scheduleOutBridgeTransfer(bridgeId, chainId, recipient, token, amount, outputToken, minOutputAmount);

        emit TransferToCaliber(chainId, token, amount);

        if (IERC20(token).balanceOf(address(this)) == 0 && token != $._accountingToken) {
            $._idleTokens.remove(token);
        }
    }

    /// @inheritdoc IBridgeController
    function sendOutBridgeTransfer(uint16 bridgeId, uint256 transferId, bytes calldata data)
        external
        override
        notRecoveryMode
        onlyMechanic
    {
        _sendOutBridgeTransfer(bridgeId, transferId, data);
    }

    /// @inheritdoc IBridgeController
    function authorizeInBridgeTransfer(uint16 bridgeId, bytes32 messageHash) external override onlyOperator {
        _authorizeInBridgeTransfer(bridgeId, messageHash);
    }

    /// @inheritdoc IBridgeController
    function claimInBridgeTransfer(uint16 bridgeId, uint256 transferId) external override onlyOperator {
        _claimInBridgeTransfer(bridgeId, transferId);
    }

    /// @inheritdoc IBridgeController
    function cancelOutBridgeTransfer(uint16 bridgeId, uint256 transferId) external override onlyOperator {
        _cancelOutBridgeTransfer(bridgeId, transferId);
    }

    /// @inheritdoc IMachine
    function updateTotalAum() external override nonReentrant notRecoveryMode returns (uint256) {
        MachineStorage storage $ = _getMachineStorage();

        uint256 _lastTotalAum = MachineUtils.updateTotalAum($, IHubCoreRegistry(registry).oracleRegistry());
        emit TotalAumUpdated(_lastTotalAum);

        uint256 _mintedFees = MachineUtils.manageFees($);
        if (_mintedFees != 0) {
            emit FeesMinted(_mintedFees);
        }

        return _lastTotalAum;
    }

    /// @inheritdoc IMachine
    function deposit(uint256 assets, address receiver, uint256 minShares)
        external
        nonReentrant
        notRecoveryMode
        returns (uint256)
    {
        MachineStorage storage $ = _getMachineStorage();

        if (msg.sender != $._depositor) {
            revert Errors.UnauthorizedCaller();
        }

        uint256 shares = convertToShares(assets);
        uint256 _maxMint = maxMint();
        if (shares > _maxMint) {
            revert Errors.ExceededMaxMint(shares, _maxMint);
        }
        if (shares < minShares) {
            revert Errors.SlippageProtection();
        }

        IERC20($._accountingToken).safeTransferFrom(msg.sender, address(this), assets);
        IMachineShare($._shareToken).mint(receiver, shares);
        $._lastTotalAum += assets;
        emit Deposit(msg.sender, receiver, assets, shares);

        return shares;
    }

    /// @inheritdoc IMachine
    function redeem(uint256 shares, address receiver, uint256 minAssets)
        external
        override
        nonReentrant
        notRecoveryMode
        returns (uint256)
    {
        MachineStorage storage $ = _getMachineStorage();

        if (msg.sender != $._redeemer) {
            revert Errors.UnauthorizedCaller();
        }

        uint256 assets = convertToAssets(shares);

        uint256 _maxWithdraw = maxWithdraw();
        if (assets > _maxWithdraw) {
            revert Errors.ExceededMaxWithdraw(assets, _maxWithdraw);
        }
        if (assets < minAssets) {
            revert Errors.SlippageProtection();
        }

        IERC20($._accountingToken).safeTransfer(receiver, assets);
        IMachineShare($._shareToken).burn(msg.sender, shares);
        $._lastTotalAum -= assets;
        emit Redeem(msg.sender, receiver, assets, shares);

        return assets;
    }

    /// @inheritdoc IMachine
    function updateSpokeCaliberAccountingData(bytes calldata response, GuardianSignature[] calldata signatures)
        external
        override
        nonReentrant
    {
        MachineUtils.updateSpokeCaliberAccountingData(
            _getMachineStorage(),
            IHubCoreRegistry(registry).tokenRegistry(),
            IHubCoreRegistry(registry).chainRegistry(),
            wormhole,
            response,
            signatures
        );
    }

    /// @inheritdoc IMachine
    function setSpokeCaliber(
        uint256 foreignChainId,
        address spokeCaliberMailbox,
        uint16[] calldata bridges,
        address[] calldata adapters
    ) external restricted {
        if (!IChainRegistry(IHubCoreRegistry(registry).chainRegistry()).isEvmChainIdRegistered(foreignChainId)) {
            revert Errors.EvmChainIdNotRegistered(foreignChainId);
        }

        MachineStorage storage $ = _getMachineStorage();
        SpokeCaliberData storage caliberData = $._spokeCalibersData[foreignChainId];

        if (caliberData.mailbox != address(0)) {
            revert Errors.SpokeCaliberAlreadySet();
        }
        $._foreignChainIds.push(foreignChainId);
        caliberData.mailbox = spokeCaliberMailbox;

        emit SpokeCaliberMailboxSet(foreignChainId, spokeCaliberMailbox);

        uint256 len = bridges.length;
        if (len != adapters.length) {
            revert Errors.MismatchedLength();
        }
        for (uint256 i; i < len; ++i) {
            _setSpokeBridgeAdapter(foreignChainId, bridges[i], adapters[i]);
        }
    }

    /// @inheritdoc IMachine
    function setSpokeBridgeAdapter(uint256 foreignChainId, uint16 bridgeId, address adapter)
        external
        override
        restricted
    {
        SpokeCaliberData storage caliberData = _getMachineStorage()._spokeCalibersData[foreignChainId];

        if (caliberData.mailbox == address(0)) {
            revert Errors.InvalidChainId();
        }
        _setSpokeBridgeAdapter(foreignChainId, bridgeId, adapter);
    }

    /// @inheritdoc IMachine
    function setDepositor(address newDepositor) external override restricted {
        MachineStorage storage $ = _getMachineStorage();
        emit DepositorChanged($._depositor, newDepositor);
        $._depositor = newDepositor;
    }

    /// @inheritdoc IMachine
    function setRedeemer(address newRedeemer) external override restricted {
        MachineStorage storage $ = _getMachineStorage();
        emit RedeemerChanged($._redeemer, newRedeemer);
        $._redeemer = newRedeemer;
    }

    /// @inheritdoc IMachine
    function setFeeManager(address newFeeManager) external override restricted {
        MachineStorage storage $ = _getMachineStorage();
        emit FeeManagerChanged($._feeManager, newFeeManager);
        $._feeManager = newFeeManager;
    }

    /// @inheritdoc IMachine
    function setCaliberStaleThreshold(uint256 newCaliberStaleThreshold) external override onlyRiskManagerTimelock {
        MachineStorage storage $ = _getMachineStorage();
        emit CaliberStaleThresholdChanged($._caliberStaleThreshold, newCaliberStaleThreshold);
        $._caliberStaleThreshold = newCaliberStaleThreshold;
    }

    /// @inheritdoc IMachine
    function setMaxFixedFeeAccrualRate(uint256 newMaxAccrualRate) external override onlyRiskManagerTimelock {
        MachineStorage storage $ = _getMachineStorage();
        emit MaxFixedFeeAccrualRateChanged($._maxFixedFeeAccrualRate, newMaxAccrualRate);
        $._maxFixedFeeAccrualRate = newMaxAccrualRate;
    }

    /// @inheritdoc IMachine
    function setMaxPerfFeeAccrualRate(uint256 newMaxAccrualRate) external override onlyRiskManagerTimelock {
        MachineStorage storage $ = _getMachineStorage();
        emit MaxPerfFeeAccrualRateChanged($._maxPerfFeeAccrualRate, newMaxAccrualRate);
        $._maxPerfFeeAccrualRate = newMaxAccrualRate;
    }

    /// @inheritdoc IMachine
    function setFeeMintCooldown(uint256 newFeeMintCooldown) external override onlyRiskManagerTimelock {
        MachineStorage storage $ = _getMachineStorage();
        emit FeeMintCooldownChanged($._feeMintCooldown, newFeeMintCooldown);
        $._feeMintCooldown = newFeeMintCooldown;
    }

    /// @inheritdoc IMachine
    function setShareLimit(uint256 newShareLimit) external override onlyRiskManager {
        MachineStorage storage $ = _getMachineStorage();
        emit ShareLimitChanged($._shareLimit, newShareLimit);
        $._shareLimit = newShareLimit;
    }

    /// @inheritdoc IBridgeController
    function setOutTransferEnabled(uint16 bridgeId, bool enabled) external override onlyRiskManagerTimelock {
        _setOutTransferEnabled(bridgeId, enabled);
    }

    /// @inheritdoc IBridgeController
    function setMaxBridgeLossBps(uint16 bridgeId, uint256 maxBridgeLossBps) external override onlyRiskManagerTimelock {
        _setMaxBridgeLossBps(bridgeId, maxBridgeLossBps);
    }

    /// @inheritdoc IBridgeController
    function resetBridgingState(address token) external override onlySecurityCouncil {
        MachineStorage storage $ = _getMachineStorage();
        uint256 len = $._foreignChainIds.length;
        for (uint256 i; i < len; ++i) {
            SpokeCaliberData storage caliberData = $._spokeCalibersData[$._foreignChainIds[i]];

            caliberData.caliberBridgesIn.remove(token);
            caliberData.caliberBridgesOut.remove(token);
            caliberData.machineBridgesIn.remove(token);
            caliberData.machineBridgesOut.remove(token);
        }

        BridgeControllerStorage storage $bc = _getBridgeControllerStorage();
        len = $bc._supportedBridges.length;
        for (uint256 i; i < len; ++i) {
            address bridgeAdapter = $bc._bridgeAdapters[$bc._supportedBridges[i]];
            IBridgeAdapter(bridgeAdapter).withdrawPendingFunds(token);
        }

        _notifyIdleToken(token);

        emit BridgingStateReset(token);
    }

    /// @dev Sets the spoke bridge adapter for a given foreign chain ID and bridge ID.
    function _setSpokeBridgeAdapter(uint256 foreignChainId, uint16 bridgeId, address adapter) internal {
        SpokeCaliberData storage caliberData = _getMachineStorage()._spokeCalibersData[foreignChainId];

        if (caliberData.bridgeAdapters[bridgeId] != address(0)) {
            revert Errors.SpokeBridgeAdapterAlreadySet();
        }
        if (adapter == address(0)) {
            revert Errors.ZeroBridgeAdapterAddress();
        }
        caliberData.bridgeAdapters[bridgeId] = adapter;

        emit SpokeBridgeAdapterSet(foreignChainId, uint256(bridgeId), adapter);
    }

    /// @dev Checks token balance, and registers token if needed.
    function _notifyIdleToken(address token) internal {
        if (IERC20(token).balanceOf(address(this)) > 0) {
            bool newlyAdded = _getMachineStorage()._idleTokens.add(token);
            if (
                newlyAdded && !IOracleRegistry(IHubCoreRegistry(registry).oracleRegistry()).isFeedRouteRegistered(token)
            ) {
                revert Errors.PriceFeedRouteNotRegistered(token);
            }
        }
    }
}
