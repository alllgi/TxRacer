// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "./BT404Mirror.sol";
import {IERC721} from "./external/IERC721.sol";

/// @title BT404MirrorWrapper
/// @notice BT404MirrorWrapper provides an interface for wrapping legacy ERC721
/// NFT tokens in a BT404 implementation.
contract BT404MirrorWrapper is BT404Mirror {
    /// @dev Thrown when the nft ids is empty.
    error EmptyNFTIds();

    /// @dev Thrown when the nft id is out of the range.
    error InvalidIdInRange();

    /// @dev Struct contain the wrapped ERC721 contract.
    struct BT404WNFTStorage {
        address baseERC721;
        // Indicates the start of the range (inclusive).
        uint256 startBaseId;
        // Indicates the end of the range (inclusive).
        uint256 endBaseId;
    }

    /// @dev Returns a storage pointer for BT404WNFTStorage.
    function _getBT404WNFTStorage() internal pure virtual returns (BT404WNFTStorage storage $) {
        /// @solidity memory-safe-assembly
        assembly {
            // `uint72(bytes9(keccak256("BT404_MIRROR_WRAPPER_STORAGE")))`.
            $.slot := 0x2ab3f28a60db472ee6 // Truncate to 9 bytes to reduce bytecode size.
        }
    }

    /*«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-*/
    /*                        CONSTRUCTOR                         */
    /*-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»*/

    /// @dev Prefer to use the proxy and initialization process.
    constructor() payable BT404Mirror(msg.sender) {}

    function _initializeBT404MirrorWrapper(
        address deployer,
        address baseERC721_,
        uint256 startBaseId_,
        uint256 endBaseId_
    ) internal {
        _initializeBT404Mirror(deployer);
        BT404WNFTStorage storage $ = _getBT404WNFTStorage();

        $.baseERC721 = baseERC721_;
        $.startBaseId = startBaseId_;
        $.endBaseId = endBaseId_;
    }

    /*«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-«-*/
    /*                 ERC721 Wrapper OPERATIONS                  */
    /*-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»-»*/

    /// @dev Wrap the original NFTs.
    ///      `msg.sender` receives the wrapped BT404 NFTs and the corresponding amount of ERC20 tokens.
    function wrapBatch(uint256[] memory ids) public virtual {
        wrapBatch(ids, false);
    }

    /// @dev Wrap the original NFTs.
    ///      `msg.sender` receives the wrapped BT404 NFTs along with the corresponding amount of ERC20 tokens.
    ///      Lock the BT404 NFTs to prevent transfer via `ERC20.transfer`.
    function wrapBatch(uint256[] memory ids, bool lock) public virtual {
        if (ids.length == 0) revert EmptyNFTIds();

        BT404WNFTStorage storage $ = _getBT404WNFTStorage();
        IERC721 base721 = IERC721($.baseERC721);
        (uint256 startBaseId, uint256 endBaseId) = ($.startBaseId, $.endBaseId);

        for (uint256 i; i < ids.length;) {
            uint256 id = ids[i];
            _checkInvalidIdInRange(startBaseId, endBaseId, id);
            base721.transferFrom(msg.sender, address(this), id);
            unchecked {
                ++i;
            }
        }

        address base = baseERC20();
        (bool success, bytes memory result) = base.call(
            abi.encodeWithSignature(
                "mintNFT(uint256,uint256[])",
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
                // Emit the {Transfer} event.
                log4(codesize(), 0x00, _TRANSFER_EVENT_SIGNATURE, 0, caller(), mload(s))
                // Emit the {UpdateLockState} event.
                if lock { log3(0x00, 0x20, _UPDATE_LOCK_STATE_EVENT_SIGNATURE, caller(), mload(s)) }
            }
        }
    }

    /// @dev Unwrap the original NFTs. `msg.sender` receives the original ERC721 NFTs.
    ///      Burn the BT404 NFTs and corresponding ERC20 Tokens.
    function unwrapBatch(uint256[] memory ids) public virtual {
        if (ids.length == 0) revert EmptyNFTIds();

        address base = baseERC20();
        (bool success, bytes memory result) =
            base.call(abi.encodeWithSignature("burnNFT(address,uint256[])", msg.sender, ids));
        // @solidity memory-safe-assembly
        assembly {
            if iszero(and(eq(mload(add(result, 0x20)), 1), success)) {
                revert(add(result, 0x20), mload(result))
            }

            let idLen := mload(ids)
            for {
                let s := add(ids, 0x20)
                let end := add(s, shl(5, idLen))
            } iszero(eq(s, end)) { s := add(s, 0x20) } {
                // Don't emit the {UpdateLockState} event, as the NFTs already are burned.
                // Emit the {Transfer} event.
                log4(codesize(), 0x00, _TRANSFER_EVENT_SIGNATURE, caller(), 0, mload(s))
            }
        }

        IERC721 base721 = IERC721(baseERC721());
        for (uint256 i; i < ids.length;) {
            base721.safeTransferFrom(address(this), msg.sender, ids[i]);
            unchecked {
                ++i;
            }
        }
    }

    function baseERC721() public view virtual returns (address) {
        return _getBT404WNFTStorage().baseERC721;
    }

    /**
     * @dev Always returns `this.onERC721Received.selector`.
     */
    function onERC721Received(address, address, uint256, bytes memory)
        public
        pure
        virtual
        returns (bytes4)
    {
        return this.onERC721Received.selector;
    }

    function _checkInvalidIdInRange(uint256 startBaseId, uint256 endBaseId, uint256 id)
        internal
        pure
    {
        if ((startBaseId | endBaseId) > 0) {
            if (id < startBaseId || endBaseId < id) {
                revert InvalidIdInRange();
            }
        }
    }
}
