// Sources retrieved from Sourcify API v2.
// Deterministic best-effort flattening; original files are preserved under src/.

// File: src/strategy/StructuredLinkedList.sol

pragma solidity =0.8.17;

/**
 * @title StructuredLinkedList
 * @author Vittorio Minacori (https://github.com/vittominacori)
 * @dev An utility library for using sorted linked list data structures in your Solidity project.
 * @notice Adapted from
 * https://github.com/Layr-Labs/eigenlayer-contracts/blob/master/src/contracts/libraries/StructuredLinkedList.sol
 */
library StructuredLinkedList {
    uint256 private constant _NULL = 0;
    uint256 private constant _HEAD = 0;

    bool private constant _PREV = false;
    bool private constant _NEXT = true;

    struct List {
        uint256 size;
        mapping(uint256 => mapping(bool => uint256)) list;
    }

    /**
     * @dev Checks if the list exists
     * @param self stored linked list from contract
     * @return bool true if list exists, false otherwise
     */
    function listExists(List storage self) public view returns (bool) {
        // if the head nodes previous or next pointers both point to itself, then there are no items in the list
        if (self.list[_HEAD][_PREV] != _HEAD || self.list[_HEAD][_NEXT] != _HEAD) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Checks if the node exists
     * @param self stored linked list from contract
     * @param _node a node to search for
     * @return bool true if node exists, false otherwise
     */
    function nodeExists(List storage self, uint256 _node) public view returns (bool) {
        if (self.list[_node][_PREV] == _HEAD && self.list[_node][_NEXT] == _HEAD) {
            if (self.list[_HEAD][_NEXT] == _node) {
                return true;
            } else {
                return false;
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Returns the number of elements in the list
     * @param self stored linked list from contract
     * @return uint256
     */
    // slither-disable-next-line dead-code
    function sizeOf(List storage self) public view returns (uint256) {
        return self.size;
    }

    /**
     * @dev Gets the head of the list
     * @param self stored linked list from contract
     * @return uint256 the head of the list
     */
    function getHead(List storage self) public view returns (uint256) {
        return self.list[_HEAD][_NEXT];
    }

    /**
     * @dev Gets the head of the list
     * @param self stored linked list from contract
     * @return uint256 the head of the list
     */
    function getTail(List storage self) public view returns (uint256) {
        return self.list[_HEAD][_PREV];
    }

    /**
     * @dev Returns the links of a node as a tuple
     * @param self stored linked list from contract
     * @param _node id of the node to get
     * @return bool, uint256, uint256 true if node exists or false otherwise, previous node, next node
     */
    // slither-disable-next-line dead-code
    function getNode(List storage self, uint256 _node) public view returns (bool, uint256, uint256) {
        if (!nodeExists(self, _node)) {
            return (false, 0, 0);
        } else {
            return (true, self.list[_node][_PREV], self.list[_node][_NEXT]);
        }
    }

    /**
     * @dev Returns the link of a node `_node` in direction `_direction`.
     * @param self stored linked list from contract
     * @param _node id of the node to step from
     * @param _direction direction to step in
     * @return bool, uint256 true if node exists or false otherwise, node in _direction
     */
    // slither-disable-next-line dead-code
    function getAdjacent(List storage self, uint256 _node, bool _direction) public view returns (bool, uint256) {
        if (!nodeExists(self, _node)) {
            return (false, 0);
        } else {
            uint256 adjacent = self.list[_node][_direction];
            return (adjacent != _HEAD, adjacent);
        }
    }

    /**
     * @dev Returns the link of a node `_node` in direction `_NEXT`.
     * @param self stored linked list from contract
     * @param _node id of the node to step from
     * @return bool, uint256 true if node exists or false otherwise, next node
     */
    // slither-disable-next-line dead-code
    function getNextNode(List storage self, uint256 _node) public view returns (bool, uint256) {
        return getAdjacent(self, _node, _NEXT);
    }

    /**
     * @dev Returns the link of a node `_node` in direction `_PREV`.
     * @param self stored linked list from contract
     * @param _node id of the node to step from
     * @return bool, uint256 true if node exists or false otherwise, previous node
     */
    // slither-disable-next-line dead-code
    function getPreviousNode(List storage self, uint256 _node) public view returns (bool, uint256) {
        return getAdjacent(self, _node, _PREV);
    }

    /**
     * @dev Insert node `_new` beside existing node `_node` in direction `_NEXT`.
     * @param self stored linked list from contract
     * @param _node existing node
     * @param _new  new node to insert
     * @return bool true if success, false otherwise
     */
    // slither-disable-next-line dead-code
    function insertAfter(List storage self, uint256 _node, uint256 _new) public returns (bool) {
        return _insert(self, _node, _new, _NEXT);
    }

    /**
     * @dev Insert node `_new` beside existing node `_node` in direction `_PREV`.
     * @param self stored linked list from contract
     * @param _node existing node
     * @param _new  new node to insert
     * @return bool true if success, false otherwise
     */
    // slither-disable-next-line dead-code
    function insertBefore(List storage self, uint256 _node, uint256 _new) public returns (bool) {
        return _insert(self, _node, _new, _PREV);
    }

    /**
     * @dev Removes an entry from the linked list
     * @param self stored linked list from contract
     * @param _node node to remove from the list
     * @return uint256 the removed node
     */
    function remove(List storage self, uint256 _node) public returns (uint256) {
        if ((_node == _NULL) || (!nodeExists(self, _node))) {
            return 0;
        }
        _createLink(self, self.list[_node][_PREV], self.list[_node][_NEXT], _NEXT);
        delete self.list[_node][_PREV];
        delete self.list[_node][_NEXT];

        self.size -= 1;

        return _node;
    }

    /**
     * @dev Pushes an entry to the head of the linked list
     * @param self stored linked list from contract
     * @param _node new entry to push to the head
     * @return bool true if success, false otherwise
     */
    function pushFront(List storage self, uint256 _node) public returns (bool) {
        return _push(self, _node, _NEXT);
    }

    /**
     * @dev Pushes an entry to the tail of the linked list
     * @param self stored linked list from contract
     * @param _node new entry to push to the tail
     * @return bool true if success, false otherwise
     */
    function pushBack(List storage self, uint256 _node) public returns (bool) {
        return _push(self, _node, _PREV);
    }

    /**
     * @dev Pops the first entry from the head of the linked list
     * @param self stored linked list from contract
     * @return uint256 the removed node
     */
    // slither-disable-next-line dead-code
    function popFront(List storage self) public returns (uint256) {
        return _pop(self, _NEXT);
    }

    /**
     * @dev Pops the first entry from the tail of the linked list
     * @param self stored linked list from contract
     * @return uint256 the removed node
     */
    // slither-disable-next-line dead-code
    function popBack(List storage self) public returns (uint256) {
        return _pop(self, _PREV);
    }

    /**
     * @dev Pushes an entry to the head of the linked list
     * @param self stored linked list from contract
     * @param _node new entry to push to the head
     * @param _direction push to the head (_NEXT) or tail (_PREV)
     * @return bool true if success, false otherwise
     */
    function _push(List storage self, uint256 _node, bool _direction) private returns (bool) {
        return _insert(self, _HEAD, _node, _direction);
    }

    /**
     * @dev Pops the first entry from the linked list
     * @param self stored linked list from contract
     * @param _direction pop from the head (_NEXT) or the tail (_PREV)
     * @return uint256 the removed node
     */
    // slither-disable-next-line dead-code
    function _pop(List storage self, bool _direction) private returns (uint256) {
        uint256 adj;
        (, adj) = getAdjacent(self, _HEAD, _direction);
        return remove(self, adj);
    }

    /**
     * @dev Insert node `_new` beside existing node `_node` in direction `_direction`.
     * @param self stored linked list from contract
     * @param _node existing node
     * @param _new  new node to insert
     * @param _direction direction to insert node in
     * @return bool true if success, false otherwise
     */
    function _insert(List storage self, uint256 _node, uint256 _new, bool _direction) private returns (bool) {
        if (!nodeExists(self, _new) && nodeExists(self, _node)) {
            uint256 c = self.list[_node][_direction];
            _createLink(self, _node, _new, _direction);
            _createLink(self, _new, c, _direction);

            self.size += 1;

            return true;
        }

        return false;
    }

    /**
     * @dev Creates a bidirectional link between two nodes on direction `_direction`
     * @param self stored linked list from contract
     * @param _node existing node
     * @param _link node to link to in the _direction
     * @param _direction direction to insert node in
     */
    function _createLink(List storage self, uint256 _node, uint256 _link, bool _direction) private {
        self.list[_link][!_direction] = _node;
        self.list[_node][_direction] = _link;
    }
}

// File: src/strategy/WithdrawalQueue.sol

// Copyright (c) 2023 Tokemak Foundation. All rights reserved.
pragma solidity 0.8.17; // their version was using 8.12?



// https://github.com/Layr-Labs/eigenlayer-contracts/blob/master/src/contracts/libraries/StructuredLinkedList.sol
library WithdrawalQueue {
    using StructuredLinkedList for StructuredLinkedList.List;

    error CannotInsertZeroAddress();
    error UnexpectedNodeRemoved();
    error AddToHeadFailed();
    error AddToTailFailed();
    error NodeDoesNotExist();

    /// @notice Returns true if the address is in the queue.
    function addressExists(StructuredLinkedList.List storage queue, address addr) public view returns (bool) {
        return StructuredLinkedList.nodeExists(queue, _addressToUint(addr));
    }

    /// @notice Returns the current head.
    function peekHead(StructuredLinkedList.List storage queue) public view returns (address) {
        return _uintToAddress(StructuredLinkedList.getHead(queue));
    }

    /// @notice Returns the current tail.
    function peekTail(StructuredLinkedList.List storage queue) public view returns (address) {
        return _uintToAddress(StructuredLinkedList.getTail(queue));
    }

    /// @notice Returns the number of items in the queue
    function sizeOf(StructuredLinkedList.List storage queue) public view returns (uint256) {
        return StructuredLinkedList.sizeOf(queue);
    }

    /// @notice Return all items in the queue
    /// @dev Enumerates from head to tail
    function getList(StructuredLinkedList.List storage self) public view returns (address[] memory list) {
        uint256 size = self.sizeOf();
        list = new address[](size);

        if (size > 0) {
            uint256 lastNode = self.getHead();
            list[0] = _uintToAddress(lastNode);
            for (uint256 i = 1; i < size; ++i) {
                (bool exists, uint256 node) = self.getAdjacent(lastNode, true);

                if (!exists) {
                    revert NodeDoesNotExist();
                }

                list[i] = _uintToAddress(node);
                lastNode = node;
            }
        }
    }

    /// @notice Returns the current tail.
    function popHead(StructuredLinkedList.List storage queue) public returns (address) {
        return _uintToAddress(StructuredLinkedList.popFront(queue));
    }

    /// @notice remove address toRemove from queue if it exists.
    function popAddress(StructuredLinkedList.List storage queue, address toRemove) public {
        uint256 addrAsUint = _addressToUint(toRemove);
        uint256 _removedNode = StructuredLinkedList.remove(queue, addrAsUint);
        if (!((_removedNode == addrAsUint) || (_removedNode == 0))) {
            revert UnexpectedNodeRemoved();
        }
    }

    /// @notice returns true if there are no addresses in queue.
    function isEmpty(StructuredLinkedList.List storage queue) public view returns (bool) {
        return !StructuredLinkedList.listExists(queue);
    }

    /// @notice if addr in queue, move it to the top
    // if addr not in queue, add it to the top of the queue.
    // if queue is empty, make a new queue with addr as the only node
    function addToHead(StructuredLinkedList.List storage queue, address addr) public {
        if (addr == address(0)) {
            revert CannotInsertZeroAddress();
        }
        popAddress(queue, addr);
        bool success = StructuredLinkedList.pushFront(queue, _addressToUint(addr));
        if (!success) {
            revert AddToHeadFailed();
        }
    }

    function getAdjacent(
        StructuredLinkedList.List storage queue,
        address addr,
        bool direction
    ) public view returns (address) {
        (bool exists, uint256 addrNum) = queue.getAdjacent(_addressToUint(addr), direction);
        if (!exists) {
            return address(0);
        }
        return _uintToAddress(addrNum);
    }

    /// @notice if addr in queue, move it to the end
    // if addr not in queue, add it to the end of the queue.
    // if queue is empty, make a new queue with addr as the only node
    function addToTail(StructuredLinkedList.List storage queue, address addr) public {
        if (addr == address(0)) {
            revert CannotInsertZeroAddress();
        }

        popAddress(queue, addr);
        bool success = StructuredLinkedList.pushBack(queue, _addressToUint(addr));
        if (!success) {
            revert AddToTailFailed();
        }
    }

    function _addressToUint(address addr) private pure returns (uint256) {
        return uint256(uint160(addr));
    }

    function _uintToAddress(uint256 x) private pure returns (address) {
        return address(uint160(x));
    }
}
