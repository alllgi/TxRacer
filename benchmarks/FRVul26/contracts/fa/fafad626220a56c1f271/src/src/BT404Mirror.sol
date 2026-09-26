// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

/// @title BT404Mirror
/// @notice BT404Mirror provides an interface for interacting with the
/// NFT tokens in a BT404 implementation.
///
/// @author FlooringLab
/// @author Modified from DN404(https://github.com/Vectorized/dn404/src/DN404Mirror.sol)
///
/// @dev Note:
/// - The ERC721 data is stored in the base BT404 contract.
contract BT404Mirror {
    /*«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-*/
    /*                           EVENTS                           */
    /*-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»*/

    /// @dev Emitted when token `id` is transferred from `from` to `to`.
    event Transfer(address indexed from, address indexed to, uint256 indexed id);

    /// @dev Emitted when `owner` enables `account` to manage the `id` token.
    event Approval(address indexed owner, address indexed account, uint256 indexed id);

    /// @dev Emitted when `owner` enables or disables `operator` to manage all of their tokens.
    event ApprovalForAll(address indexed owner, address indexed operator, bool isApproved);

    /// @dev The ownership is transferred from `oldOwner` to `newOwner`.
    /// This is for marketplace signaling purposes. This contract has a `pullOwner()`
    /// function that will sync the owner from the base contract.
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

    /// @dev Emitted when `owner` lock or unlock token `id`.
    event UpdateLockState(address indexed owner, uint256 indexed id, bool lockStatus);

    /// @dev Emitted when token `idX` and `idY` exchanged.
    event Exchange(uint256 indexed idX, uint256 indexed idY, uint256 exchangeFee);

    /// @dev Emitted when token `id` offered for sale.
    event Offer(uint256 indexed id, address indexed to, uint256 minPrice, address offerToken);

    /// @dev Emitted when token `id` offered for sale.
    event CancelOffer(uint256 indexed id, address indexed owner);

    /// @dev Emitted when token `id` offered for sale.
    event Bid(uint256 indexed id, address indexed from, uint256 price, address bidToken);

    /// @dev Emitted when token `id` offered for sale.
    event CancelBid(uint256 indexed id, address indexed from);

    /// @dev Emitted when token `id` bought.
    event Bought(
        uint256 indexed id,
        address indexed from,
        address indexed to,
        uint256 price,
        address token,
        address maker
    );

    /// @dev `keccak256(bytes("Transfer(address,address,uint256)"))`.
    uint256 internal constant _TRANSFER_EVENT_SIGNATURE =
        0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef;

    /// @dev `keccak256(bytes("Approval(address,address,uint256)"))`.
    uint256 internal constant _APPROVAL_EVENT_SIGNATURE =
        0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925;

    /// @dev `keccak256(bytes("ApprovalForAll(address,address,bool)"))`.
    uint256 internal constant _APPROVAL_FOR_ALL_EVENT_SIGNATURE =
        0x17307eab39ab6107e8899845ad3d59bd9653f200f220920489ca2b5937696c31;

    /// @dev `keccak256(bytes("UpdateLockState(address,uint256,bool)"))`.
    uint256 internal constant _UPDATE_LOCK_STATE_EVENT_SIGNATURE =
        0xcc3a1bd7e528af8582cd3578d82ae22e309de7c3663c9d0fa5b5ce79c1a346ac;

    /// @dev `keccak256(bytes("Exchange(uint256,uint256,uint256)"))`
    uint256 internal constant _EXCHANGE_EVENT_SIGNATURE =
        0xbc43d7c0945f5a13a7bfa8ca7309e55f903f01d66c38c6d1353fe7ff9335d776;

    /// @dev `keccak256(bytes("Offer(uint256,address,uint256,address)"))`
    uint256 private constant _OFFER_EVENT_SIGNATURE =
        0xc56f8610599b5a39311e36563ef3386394748f787ef5efc116d960d77def8050;

    /// @dev `keccak256(bytes("CancelOffer(uint256,address)"))`
    uint256 private constant _CANCEL_OFFER_EVENT_SIGNATURE =
        0xc4caef7e3533865382e608c341581a5e2a1b0d1ac37b0aaf58023ccd4eedfd8e;

    /// @dev `keccak256(bytes("Bid(uint256,address,uint256,address)"))`
    uint256 private constant _BID_EVENT_SIGNATURE =
        0xec85e6e86fabc4c703529b570fb5eb567dad69ddbf7901bc0fd28b38b93de7f3;

    /// @dev `keccak256(bytes("CancelBid(uint256,address)"))`
    uint256 private constant _CANCEL_BID_EVENT_SIGNATURE =
        0x874afcdd5e90b2329b3c1601e613dcdc6abb6deb62ce61339a8337b48c053e51;

    /// @dev `keccak256(bytes("Bought(uint256,address,address,uint256,address,address)"))`
    uint256 private constant _BOUGHT_EVENT_SIGNATURE =
        0xd9882bc1ac8e78c918b907fa0ff79cc9d866091c5eb450ebed79e9d147541d5b;

    /*«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-*/
    /*                        CUSTOM ERRORS                       */
    /*-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»*/

    /// @dev Thrown when a call for an NFT function did not originate
    /// from the base BT404 contract.
    error SenderNotBase();

    /// @dev Thrown when a call for an NFT function did not originate from the deployer.
    error SenderNotDeployer();

    /// @dev Thrown when transferring an NFT to a contract address that
    /// does not implement ERC721Receiver.
    error TransferToNonERC721ReceiverImplementer();

    /// @dev Thrown when linking to the BT404 base contract and the
    /// BT404 supportsInterface check fails or the call reverts.
    error CannotLink();

    /// @dev Thrown when a linkMirrorContract call is received and the
    /// NFT mirror contract has already been linked to a BT404 base contract.
    error AlreadyLinked();

    /// @dev Thrown when retrieving the base BT404 address when a link has not
    /// been established.
    error NotLinked();

    /// @dev The caller is not authorized to call the function.
    error Unauthorized();

    /// @dev Unauthorized reentrant call.
    error Reentrancy();

    /*«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-*/
    /*                          STORAGE                           */
    /*-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»*/

    /// @dev Struct contain the NFT mirror contract storage.
    struct BT404NFTStorage {
        address baseERC20;
        bool locked;
        address deployer;
        address owner;
    }

    /// @dev Returns a storage pointer for BT404NFTStorage.
    function _getBT404NFTStorage() internal pure virtual returns (BT404NFTStorage storage $) {
        /// @solidity memory-safe-assembly
        assembly {
            // `uint72(bytes9(keccak256("DN404_MIRROR_STORAGE")))`.
            $.slot := 0x3602298b8c10b01230 // Truncate to 9 bytes to reduce bytecode size.
        }
    }

    /*«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-*/
    /*                       REENTRANCY GUARD                     */
    /*-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»*/
    /// @dev Guards a function from reentrancy.
    modifier nonReentrant() virtual {
        BT404NFTStorage storage $ = _getBT404NFTStorage();
        if ($.locked) revert Reentrancy();
        $.locked = true;
        _;
        $.locked = false;
    }

    /*«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-*/
    /*                        CONSTRUCTOR                         */
    /*-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»*/

    constructor(address deployer) {
        // For non-proxies, we will store the deployer so that only the deployer can
        // link the base contract.
        _getBT404NFTStorage().deployer = deployer;
    }

    function _initializeBT404Mirror(address deployer) internal {
        // For non-proxies, we will store the deployer so that only the deployer can
        // link the base contract.
        _getBT404NFTStorage().deployer = deployer;
    }

    /*«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-*/
    /*                     ERC721 OPERATIONS                      */
    /*-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»*/

    /// @dev Returns the token collection name from the base BT404 contract.
    function name() public view virtual returns (string memory result) {
        return _readString(0x06fdde03, 0); // `name()`.
    }

    /// @dev Returns the token collection symbol from the base BT404 contract.
    function symbol() public view virtual returns (string memory result) {
        return _readString(0x95d89b41, 0); // `symbol()`.
    }

    /// @dev Returns the Uniform Resource Identifier (URI) for token `id` from
    /// the base BT404 contract.
    function tokenURI(uint256 id) public view virtual returns (string memory result) {
        return _readString(0xc87b56dd, id); // `tokenURI()`.
    }

    /// @dev Returns the total NFT supply from the base BT404 contract.
    function totalSupply() public view virtual returns (uint256 result) {
        return _readWord(0xe2c79281, 0, 0); // `totalNFTSupply()`.
    }

    /// @dev Returns the number of NFT tokens owned by `nftOwner` from the base BT404 contract.
    ///
    /// Requirements:
    /// - `nftOwner` must not be the zero address.
    function balanceOf(address nftOwner) public view virtual returns (uint256 result) {
        return _readWord(0xf5b100ea, uint160(nftOwner), 0); // `balanceOfNFT(address)`.
    }

    /// @dev Returns the owner of token `id` from the base BT404 contract.
    ///
    /// Requirements:
    /// - Token `id` must exist.
    function ownerOf(uint256 id) public view virtual returns (address result) {
        return address(uint160(_readWord(0x6352211e, id, 0))); // `ownerOf(uint256)`.
    }

    /// @dev Returns the owner of token `id` from the base BT404 contract.
    /// Returns `address(0)` instead of reverting if the token does not exist.
    function ownerAt(uint256 id) public view virtual returns (address result) {
        return address(uint160(_readWord(0x24359879, id, 0))); // `ownerAt(uint256)`.
    }

    /// @dev Sets `spender` as the approved account to manage token `id` in
    /// the base BT404 contract.
    ///
    /// Requirements:
    /// - Token `id` must exist.
    /// - The caller must be the owner of the token,
    ///   or an approved operator for the token owner.
    ///
    /// Emits an {Approval} event.
    function approve(address spender, uint256 id) public virtual {
        address base = baseERC20();
        /// @solidity memory-safe-assembly
        assembly {
            spender := shr(96, shl(96, spender))
            let m := mload(0x40)
            mstore(0x00, 0xd10b6e0c) // `approveNFT(address,uint256,address)`.
            mstore(0x20, spender)
            mstore(0x40, id)
            mstore(0x60, caller())
            if iszero(
                and(
                    gt(returndatasize(), 0x1f),
                    call(gas(), base, callvalue(), 0x1c, 0x64, 0x00, 0x20)
                )
            ) {
                returndatacopy(m, 0x00, returndatasize())
                revert(m, returndatasize())
            }
            mstore(0x40, m) // Restore the free memory pointer.
            mstore(0x60, 0) // Restore the zero pointer.
            // Emit the {Approval} event.
            log4(codesize(), 0x00, _APPROVAL_EVENT_SIGNATURE, shr(96, mload(0x0c)), spender, id)
        }
    }

    /// @dev Returns the account approved to manage token `id` from
    /// the base BT404 contract.
    ///
    /// Requirements:
    /// - Token `id` must exist.
    function getApproved(uint256 id) public view virtual returns (address) {
        return address(uint160(_readWord(0x081812fc, id, 0))); // `getApproved(uint256)`.
    }

    /// @dev Sets whether `operator` is approved to manage the tokens of the caller in
    /// the base BT404 contract.
    ///
    /// Emits an {ApprovalForAll} event.
    function setApprovalForAll(address operator, bool approved) public virtual {
        address base = baseERC20();
        /// @solidity memory-safe-assembly
        assembly {
            operator := shr(96, shl(96, operator))
            let m := mload(0x40)
            mstore(0x00, 0x813500fc) // `setApprovalForAll(address,bool,address)`.
            mstore(0x20, operator)
            mstore(0x40, iszero(iszero(approved)))
            mstore(0x60, caller())
            if iszero(
                and(eq(mload(0x00), 1), call(gas(), base, callvalue(), 0x1c, 0x64, 0x00, 0x20))
            ) {
                returndatacopy(m, 0x00, returndatasize())
                revert(m, returndatasize())
            }
            // Emit the {ApprovalForAll} event.
            // The `approved` value is already at 0x40.
            log3(0x40, 0x20, _APPROVAL_FOR_ALL_EVENT_SIGNATURE, caller(), operator)
            mstore(0x40, m) // Restore the free memory pointer.
            mstore(0x60, 0) // Restore the zero pointer.
        }
    }

    /// @dev Returns whether `operator` is approved to manage the tokens of `nftOwner` from
    /// the base BT404 contract.
    function isApprovedForAll(address nftOwner, address operator)
        public
        view
        virtual
        returns (bool result)
    {
        // `isApprovedForAll(address,address)`.
        return _readWord(0xe985e9c5, uint160(nftOwner), uint160(operator)) != 0;
    }

    /// @dev Returns the owned token ids of `account` from the base BT404 contract.
    function ownedIds(address account, uint256 begin, uint256 end)
        public
        view
        virtual
        returns (uint256[] memory)
    {
        return _ownedIds(account, begin, end, false);
    }

    /// @dev Returns the locked token ids of `account` from the base BT404 contract.
    function lockedIds(address account, uint256 begin, uint256 end)
        public
        view
        virtual
        returns (uint256[] memory)
    {
        return _ownedIds(account, begin, end, true);
    }

    /// @dev Transfers token `id` from `from` to `to`.
    ///
    /// Requirements:
    ///
    /// - Token `id` must exist.
    /// - `from` must be the owner of the token.
    /// - `to` cannot be the zero address.
    /// - The caller must be the owner of the token, or be approved to manage the token.
    ///
    /// Emits a {Transfer} event.
    function transferFrom(address from, address to, uint256 id) public virtual {
        address base = baseERC20();
        /// @solidity memory-safe-assembly
        assembly {
            from := shr(96, shl(96, from))
            to := shr(96, shl(96, to))
            let m := mload(0x40)
            mstore(m, 0xe5eb36c8) // `transferFromNFT(address,address,uint256,address)`.
            mstore(add(m, 0x20), from)
            mstore(add(m, 0x40), to)
            mstore(add(m, 0x60), id)
            mstore(add(m, 0x80), caller())
            if iszero(
                and(eq(mload(m), 1), call(gas(), base, callvalue(), add(m, 0x1c), 0x84, m, 0x20))
            ) {
                returndatacopy(m, 0x00, returndatasize())
                revert(m, returndatasize())
            }
            // Emit the `from` unlock event.
            mstore(m, 0x00)
            log3(m, 0x20, _UPDATE_LOCK_STATE_EVENT_SIGNATURE, from, id)
            // Emit the {Transfer} event.
            log4(codesize(), 0x00, _TRANSFER_EVENT_SIGNATURE, from, to, id)
            // Emit the `to` lock event
            mstore(m, 0x01)
            log3(m, 0x20, _UPDATE_LOCK_STATE_EVENT_SIGNATURE, to, id)
        }
    }

    /// @dev Equivalent to `safeTransferFrom(from, to, id, "")`.
    function safeTransferFrom(address from, address to, uint256 id) public virtual {
        transferFrom(from, to, id);

        if (_hasCode(to)) _checkOnERC721Received(from, to, id, "");
    }

    /// @dev Transfers token `id` from `from` to `to`.
    ///
    /// Requirements:
    ///
    /// - Token `id` must exist.
    /// - `from` must be the owner of the token.
    /// - `to` cannot be the zero address.
    /// - The caller must be the owner of the token, or be approved to manage the token.
    /// - If `to` refers to a smart contract, it must implement
    ///   {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
    ///
    /// Emits a {Transfer} event.
    function safeTransferFrom(address from, address to, uint256 id, bytes calldata data)
        public
        virtual
    {
        transferFrom(from, to, id);

        if (_hasCode(to)) _checkOnERC721Received(from, to, id, data);
    }

    function updateLockState(uint256[] memory ids, bool lock) public virtual {
        address base = baseERC20();

        (bool success, bytes memory result) = base.call(
            abi.encodeWithSignature(
                "setNFTLockState(uint256,uint256[])",
                uint256(uint160(msg.sender)) << 96 | (lock ? 1 : 0),
                ids
            )
        );

        // @solidity memory-safe-assembly
        assembly {
            if iszero(and(eq(mload(add(result, 0x20)), 1), success)) {
                revert(add(result, 0x20), mload(result))
            }
            let idLen := mload(ids)

            mstore(0x00, lock)
            for {
                let s := add(ids, 0x20)
                let end := add(s, shl(5, idLen))
            } iszero(eq(s, end)) { s := add(s, 0x20) } {
                log3(0x00, 0x20, _UPDATE_LOCK_STATE_EVENT_SIGNATURE, caller(), mload(s))
            }
        }
    }

    function exchange(uint256 idX, uint256 idY) public virtual returns (uint256 exchangeFee) {
        address base = baseERC20();
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            mstore(0x00, 0x2c5966af) // `exchangeNFT(uint256,uint256,address)`.
            mstore(0x20, idX)
            mstore(0x40, idY)
            mstore(0x60, caller())
            if iszero(
                and(
                    gt(returndatasize(), 0x5F),
                    call(gas(), base, callvalue(), 0x1c, 0x64, 0x00, 0x60)
                )
            ) {
                returndatacopy(m, 0x00, returndatasize())
                revert(m, returndatasize())
            }
            // store return value
            let x := mload(0x00)
            let y := mload(0x20)
            exchangeFee := mload(0x40)

            // Emit the {Transfer} event.
            log4(codesize(), 0x00, _TRANSFER_EVENT_SIGNATURE, x, y, idX)
            log4(codesize(), 0x00, _TRANSFER_EVENT_SIGNATURE, y, caller(), idY)
            // Emit the {Exchange} event.
            log3(0x40, 0x20, _EXCHANGE_EVENT_SIGNATURE, idX, idY)
            // Emit the `caller` lock event.
            mstore(0x40, 0x01)
            log3(0x40, 0x20, _UPDATE_LOCK_STATE_EVENT_SIGNATURE, caller(), idY)

            mstore(0x40, m) // Restore the free memory pointer.
            mstore(0x60, 0) // Restore the zero pointer.
        }
    }

    struct NFTOrder {
        uint256 id;
        uint256 price;
        address token;
        address trader;
    }

    function offerForSale(NFTOrder[] memory orders) public virtual nonReentrant {
        _callBaseRetWord(
            abi.encodeWithSignature(
                "offerForSale(address,(uint256,uint256,address,address)[])", msg.sender, orders
            )
        );

        /// @solidity memory-safe-assembly
        assembly {
            for {
                let s := add(orders, add(0x20, shl(5, mload(orders))))
                let end := add(s, mul(0x80, mload(orders)))
            } iszero(eq(s, end)) { s := add(s, 0x80) } {
                log3(add(s, 0x20), 0x40, _OFFER_EVENT_SIGNATURE, mload(s), mload(add(s, 0x60)))
            }
        }
    }

    function acceptOffer(NFTOrder[] memory orders) public payable virtual nonReentrant {
        _callBaseRetWord(
            abi.encodeWithSignature(
                "acceptOffer(address,(uint256,uint256,address,address)[])", msg.sender, orders
            )
        );
        /// @solidity memory-safe-assembly
        assembly {
            for {
                let s := add(orders, add(0x20, shl(5, mload(orders))))
                let end := add(s, mul(0x80, mload(orders)))
            } iszero(eq(s, end)) { s := add(s, 0x80) } {
                let from := mload(add(s, 0x60))
                mstore(0x00, 0x01)
                log4(codesize(), 0x00, _TRANSFER_EVENT_SIGNATURE, from, caller(), mload(s))
                log3(0x00, 0x20, _UPDATE_LOCK_STATE_EVENT_SIGNATURE, caller(), mload(s))
                log4(add(s, 0x20), 0x60, _BOUGHT_EVENT_SIGNATURE, mload(s), from, caller())
            }
        }
    }

    function cancelOffer(uint256[] memory ids) public virtual nonReentrant {
        _callBaseRetWord(abi.encodeWithSignature("cancelOffer(address,uint256[])", msg.sender, ids));

        /// @solidity memory-safe-assembly
        assembly {
            for {
                let s := add(ids, 0x20)
                let end := add(s, shl(5, mload(ids)))
            } iszero(eq(s, end)) { s := add(s, 0x20) } {
                log3(codesize(), 0x00, _CANCEL_OFFER_EVENT_SIGNATURE, mload(s), caller())
            }
        }
    }

    function bidForBuy(NFTOrder[] memory orders) public payable virtual nonReentrant {
        _callBaseRetWord(
            abi.encodeWithSignature(
                "bidForBuy(address,(uint256,uint256,address,address)[])", msg.sender, orders
            )
        );

        /// @solidity memory-safe-assembly
        assembly {
            for {
                let s := add(orders, add(0x20, shl(5, mload(orders))))
                let end := add(s, mul(0x80, mload(orders)))
            } iszero(eq(s, end)) { s := add(s, 0x80) } {
                log3(add(s, 0x20), 0x40, _BID_EVENT_SIGNATURE, mload(s), caller())
            }
        }
    }

    function acceptBid(NFTOrder[] memory orders) public virtual nonReentrant {
        _callBaseRetWord(
            abi.encodeWithSignature(
                "acceptBid(address,(uint256,uint256,address,address)[])", msg.sender, orders
            )
        );
        /// @solidity memory-safe-assembly
        assembly {
            for {
                let s := add(orders, add(0x20, shl(5, mload(orders))))
                let end := add(s, mul(0x80, mload(orders)))
            } iszero(eq(s, end)) { s := add(s, 0x80) } {
                let to := mload(add(s, 0x60))
                mstore(0x00, 0x01)
                log4(codesize(), 0x00, _TRANSFER_EVENT_SIGNATURE, caller(), to, mload(s))
                log3(0x00, 0x20, _UPDATE_LOCK_STATE_EVENT_SIGNATURE, to, mload(s))
                log4(add(s, 0x20), 0x60, _BOUGHT_EVENT_SIGNATURE, mload(s), caller(), to)
            }
        }
    }

    function cancelBid(uint256[] memory ids) public virtual nonReentrant {
        _callBaseRetWord(abi.encodeWithSignature("cancelBid(address,uint256[])", msg.sender, ids));

        /// @solidity memory-safe-assembly
        assembly {
            for {
                let s := add(ids, 0x20)
                let end := add(s, shl(5, mload(ids)))
            } iszero(eq(s, end)) { s := add(s, 0x20) } {
                log3(codesize(), 0x00, _CANCEL_BID_EVENT_SIGNATURE, mload(s), caller())
            }
        }
    }

    /// @dev Returns true if this contract implements the interface defined by `interfaceId`.
    /// See: https://eips.ethereum.org/EIPS/eip-165
    /// This function call must use less than 30000 gas.
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool result) {
        /// @solidity memory-safe-assembly
        assembly {
            let s := shr(224, interfaceId)
            // ERC165: 0x01ffc9a7, ERC721: 0x80ac58cd, ERC721Metadata: 0x5b5e139f.
            result := or(or(eq(s, 0x01ffc9a7), eq(s, 0x80ac58cd)), eq(s, 0x5b5e139f))
        }
    }

    /*«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-*/
    /*                  OWNER SYNCING OPERATIONS                  */
    /*-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»*/

    /// @dev Returns the `owner` of the contract, for marketplace signaling purposes.
    function owner() public view virtual returns (address) {
        return _getBT404NFTStorage().owner;
    }

    /// @dev Permissionless function to pull the owner from the base BT404 contract
    /// if it implements ownable, for marketplace signaling purposes.
    function pullOwner() public virtual {
        address newOwner;
        address base = baseERC20();
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, 0x8da5cb5b) // `owner()`.
            if and(gt(returndatasize(), 0x1f), staticcall(gas(), base, 0x1c, 0x04, 0x00, 0x20)) {
                newOwner := shr(96, mload(0x0c))
            }
        }
        BT404NFTStorage storage $ = _getBT404NFTStorage();
        address oldOwner = $.owner;
        if (oldOwner != newOwner) {
            $.owner = newOwner;
            emit OwnershipTransferred(oldOwner, newOwner);
        }
    }

    /*«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-*/
    /*                     MIRROR OPERATIONS                      */
    /*-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»*/

    /// @dev Returns the address of the base BT404 contract.
    function baseERC20() public view virtual returns (address base) {
        base = _getBT404NFTStorage().baseERC20;
        if (base == address(0)) revert NotLinked();
    }

    /// @dev Fallback modifier to execute calls from the base BT404 contract.
    modifier bt404NFTFallback() virtual {
        BT404NFTStorage storage $ = _getBT404NFTStorage();

        uint256 fnSelector = _calldataload(0x00) >> 224;

        // `logTransfer(uint256[])`.
        if (fnSelector == 0x263c69d6) {
            if (msg.sender != $.baseERC20) revert SenderNotBase();
            /// @solidity memory-safe-assembly
            assembly {
                // When returndatacopy copies 1 or more out-of-bounds bytes, it reverts.
                returndatacopy(0x00, returndatasize(), lt(calldatasize(), 0x20))
                let o := add(0x24, calldataload(0x04)) // Packed logs offset.
                returndatacopy(0x00, returndatasize(), lt(calldatasize(), o))
                let end := add(o, shl(5, calldataload(sub(o, 0x20))))
                returndatacopy(0x00, returndatasize(), lt(calldatasize(), end))

                for {} iszero(eq(o, end)) { o := add(0x20, o) } {
                    let d := calldataload(o) // Entry in the packed logs.
                    let a := shr(96, d) // The address.
                    let b := and(1, d) // Whether it is a burn.
                    log4(
                        codesize(),
                        0x00,
                        _TRANSFER_EVENT_SIGNATURE,
                        mul(a, b), // `from`.
                        mul(a, iszero(b)), // `to`.
                        shr(168, shl(160, d)) // `id`.
                    )
                }
                mstore(0x00, 0x01)
                return(0x00, 0x20)
            }
        }
        // `logDirectTransfer(address,address,uint256[])`.
        if (fnSelector == 0x144027d3) {
            if (msg.sender != $.baseERC20) revert SenderNotBase();
            /// @solidity memory-safe-assembly
            assembly {
                let from := calldataload(0x04)
                let to := calldataload(0x24)
                let o := add(0x24, calldataload(0x44)) // Direct logs offset.
                let end := add(o, shl(5, calldataload(sub(o, 0x20))))

                for {} iszero(eq(o, end)) { o := add(0x20, o) } {
                    log4(codesize(), 0x00, _TRANSFER_EVENT_SIGNATURE, from, to, calldataload(o))
                }
                mstore(0x00, 0x01)
                return(0x00, 0x20)
            }
        }
        // `linkMirrorContract(address)`.
        if (fnSelector == 0x0f4599e5) {
            if ($.deployer != address(0)) {
                if (address(uint160(_calldataload(0x04))) != $.deployer) {
                    revert SenderNotDeployer();
                }
            }
            if ($.baseERC20 != address(0)) revert AlreadyLinked();
            $.baseERC20 = msg.sender;
            /// @solidity memory-safe-assembly
            assembly {
                mstore(0x00, 0x01)
                return(0x00, 0x20)
            }
        }
        _;
    }

    /// @dev Fallback function for calls from base BT404 contract.
    fallback() external payable virtual bt404NFTFallback {}

    receive() external payable virtual {}

    /*«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-*/
    /*                      PRIVATE HELPERS                       */
    /*-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»*/

    /// @dev Helper to read owned ids of a account from the base BT404 contract
    function _ownedIds(address account, uint256 begin, uint256 end, bool locked)
        private
        view
        returns (uint256[] memory result)
    {
        address base = baseERC20();
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(0x40)
            mstore(0x00, 0xf9b4b328) // `ownedIds(uint256,uint256,uint256)`.
            mstore(0x20, or(shl(96, account), iszero(iszero(locked))))
            mstore(0x40, begin)
            mstore(0x60, end)
            if iszero(staticcall(gas(), base, 0x1c, 0x64, 0x00, 0x00)) {
                returndatacopy(result, 0x00, returndatasize())
                revert(result, returndatasize())
            }
            returndatacopy(0x00, 0x00, 0x20) // Copy the offset of the array in returndata.
            returndatacopy(result, mload(0x00), 0x20) // Copy the length of the array.
            returndatacopy(add(result, 0x20), add(mload(0x00), 0x20), shl(5, mload(result))) // Copy the array elements.
            mstore(0x40, add(add(result, 0x20), shl(5, mload(result)))) // Allocate memory.
            mstore(0x60, 0) // Restore the zero pointer.
        }
    }

    /// @dev Helper to read a string from the base BT404 contract.
    function _readString(uint256 fnSelector, uint256 arg0)
        private
        view
        returns (string memory result)
    {
        address base = baseERC20();
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(0x40)
            mstore(0x00, fnSelector)
            mstore(0x20, arg0)
            if iszero(staticcall(gas(), base, 0x1c, 0x24, 0x00, 0x00)) {
                returndatacopy(result, 0x00, returndatasize())
                revert(result, returndatasize())
            }
            returndatacopy(0x00, 0x00, 0x20) // Copy the offset of the string in returndata.
            returndatacopy(result, mload(0x00), 0x20) // Copy the length of the string.
            returndatacopy(add(result, 0x20), add(mload(0x00), 0x20), mload(result)) // Copy the string.
            mstore(0x40, add(add(result, 0x20), mload(result))) // Allocate memory.
        }
    }

    /// @dev Helper to read a word from the base BT404 contract.
    function _readWord(uint256 fnSelector, uint256 arg0, uint256 arg1)
        private
        view
        returns (uint256 result)
    {
        address base = baseERC20();
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            mstore(0x00, fnSelector)
            mstore(0x20, arg0)
            mstore(0x40, arg1)
            if iszero(
                and(gt(returndatasize(), 0x1f), staticcall(gas(), base, 0x1c, 0x44, 0x00, 0x20))
            ) {
                returndatacopy(m, 0x00, returndatasize())
                revert(m, returndatasize())
            }
            mstore(0x40, m) // Restore the free memory pointer.
            result := mload(0x00)
        }
    }

    /// @dev Helper to call a function and return a word value.
    function _callBaseRetWord(bytes memory _calldata) private returns (uint256 result) {
        address base = baseERC20();
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            if iszero(
                and(
                    gt(returndatasize(), 0x1f),
                    call(
                        gas(), base, callvalue(), add(_calldata, 0x20), mload(_calldata), 0x00, 0x20
                    )
                )
            ) {
                returndatacopy(m, 0x00, returndatasize())
                revert(m, returndatasize())
            }
            mstore(0x40, m) // Restore the free memory pointer.
            mstore(0x60, 0) // Restore the zero pointer.
            result := mload(0x00)
        }
    }

    /// @dev Returns the calldata value at `offset`.
    function _calldataload(uint256 offset) private pure returns (uint256 value) {
        /// @solidity memory-safe-assembly
        assembly {
            value := calldataload(offset)
        }
    }

    /// @dev Returns if `a` has bytecode of non-zero length.
    function _hasCode(address a) private view returns (bool result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := extcodesize(a) // Can handle dirty upper bits.
        }
    }

    /// @dev Perform a call to invoke {IERC721Receiver-onERC721Received} on `to`.
    /// Reverts if the target does not support the function correctly.
    function _checkOnERC721Received(address from, address to, uint256 id, bytes memory data)
        private
    {
        /// @solidity memory-safe-assembly
        assembly {
            // Prepare the calldata.
            let m := mload(0x40)
            let onERC721ReceivedSelector := 0x150b7a02
            mstore(m, onERC721ReceivedSelector)
            mstore(add(m, 0x20), caller()) // The `operator`, which is always `msg.sender`.
            mstore(add(m, 0x40), shr(96, shl(96, from)))
            mstore(add(m, 0x60), id)
            mstore(add(m, 0x80), 0x80)
            let n := mload(data)
            mstore(add(m, 0xa0), n)
            if n { pop(staticcall(gas(), 4, add(data, 0x20), n, add(m, 0xc0), n)) }
            // Revert if the call reverts.
            if iszero(call(gas(), to, 0, add(m, 0x1c), add(n, 0xa4), m, 0x20)) {
                if returndatasize() {
                    // Bubble up the revert if the call reverts.
                    returndatacopy(m, 0x00, returndatasize())
                    revert(m, returndatasize())
                }
            }
            // Load the returndata and compare it.
            if iszero(eq(mload(m), shl(224, onERC721ReceivedSelector))) {
                mstore(0x00, 0xd1a57ed6) // `TransferToNonERC721ReceiverImplementer()`.
                revert(0x1c, 0x04)
            }
        }
    }
}
