// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {LibBitmap} from "solady/utils/LibBitmap.sol";
import "./BT404.sol";

/// @title BT404NFTMinter
/// @notice BT404NFTMinter provides interfaces to `mint` and `burn` the specified NFTs.
abstract contract BT404NFTMinter is BT404 {
    function _initializeBT404(uint256, address, address mirror) internal virtual override {
        // Initial supply should be zero in Wrapper Context.
        BT404._initializeBT404(0, address(0), mirror);

        BT404Storage storage $ = _getBT404Storage();
        // Prevent minting during transfer.
        $.nextTokenId = type(uint32).max;
    }

    function _mintNFT(address to, uint256[] memory ids, bool lock) internal virtual override {
        if (to == address(0)) {
            revert TransferToZeroAddress();
        }

        BT404Storage storage $ = _getBT404Storage();
        // refresh fee for `to`
        _pullFeeForTwo($, to, to);

        Uint32Map storage oo = $.oo;
        LibBitmap.Bitmap storage tokenLocks = $.tokenLocks;

        AddressData storage toAddressData = _addressData(to);
        uint32 toAlias = _registerAndResolveAlias(toAddressData, to);
        (uint32 n, Uint32Map storage ownedMap) = lock
            ? (toAddressData.lockedLength, $.locked[to])
            : (toAddressData.ownedLength, $.owned[to]);

        uint256 numToMints = ids.length;
        for (uint256 i; i < numToMints;) {
            uint256 id = ids[i];

            if (id > type(uint32).max) revert TotalSupplyOverflow();

            address from = $.aliasToAddress[_get(oo, _ownershipIndex(id))];
            if (from != address(0)) {
                revert TransferFromIncorrectOwner();
            }

            _set(ownedMap, n, uint32(id));
            _setOwnerAliasAndOwnedIndex(oo, id, toAlias, n++);

            if (lock != LibBitmap.get(tokenLocks, id)) LibBitmap.setTo(tokenLocks, id, lock);

            unchecked {
                ++i;
            }
        }

        $.totalNFTSupply += uint32(numToMints);
        if (lock) {
            toAddressData.lockedLength = n;
            $.numLockedNFT += uint32(numToMints);
        } else {
            toAddressData.ownedLength = n;
        }

        // update market shares
        if ($.operatorApprovals[address(this)][to].value > 0 && !lock) {
            $.numExchangableNFT += uint32(numToMints);
        }

        uint256 units = _unit() * numToMints;
        {
            uint256 totalSupply_ = units + $.totalSupply;
            uint256 overflows = _toUint(_totalSupplyOverflows(totalSupply_));
            if (
                overflows | _toUint(totalSupply_ < units)
                    | _toUint(totalSupply_ > _unit() * type(uint32).max) != 0
            ) {
                revert TotalSupplyOverflow();
            }

            $.totalSupply = uint96(totalSupply_);
            toAddressData.balance += uint96(units);
        }

        /// @solidity memory-safe-assembly
        assembly {
            // Emit the {Transfer} event.
            mstore(0x00, units)
            log3(0x00, 0x20, _TRANSFER_EVENT_SIGNATURE, 0, shr(96, shl(96, to)))
        }
    }

    function _burnNFT(address from, uint256[] memory ids) internal virtual override {
        if (from == address(0)) {
            revert TransferFromIncorrectOwner();
        }

        BT404Storage storage $ = _getBT404Storage();
        // refresh fee for `from`
        _pullFeeForTwo($, from, from);

        AddressData storage fromAddressData = _addressData(from);
        (uint32 lockedLength, uint32 ownedLength) =
            (fromAddressData.lockedLength, fromAddressData.ownedLength);
        uint256 ownedBurned = 0;
        uint256 numToBurns = ids.length;
        {
            Uint32Map storage oo = $.oo;
            LibBitmap.Bitmap storage tokenLocks = $.tokenLocks;
            (Uint32Map storage locked, Uint32Map storage owned) = ($.locked[from], $.owned[from]);

            for (uint256 i; i < numToBurns;) {
                uint256 id = ids[i];

                address owner = $.aliasToAddress[_get(oo, _ownershipIndex(id))];
                if (from != owner) {
                    revert TransferCallerNotOwnerNorApproved();
                }

                uint32 toBurnIdx = _get(oo, _ownedIndex(id));
                if (LibBitmap.get(tokenLocks, id)) {
                    LibBitmap.setTo(tokenLocks, id, false);
                    _delNFTAt(locked, oo, toBurnIdx, --lockedLength);
                    _clearNFTOffer($, id);
                } else {
                    _delNFTAt(owned, oo, toBurnIdx, --ownedLength);
                    ++ownedBurned;
                }
                _removeNFTApproval($, id);

                _setOwnerAliasAndOwnedIndex(oo, id, 0, 0);

                unchecked {
                    ++i;
                }
            }
        }

        unchecked {
            uint256 lockedBurned = numToBurns - ownedBurned;
            if (lockedBurned > 0) {
                fromAddressData.lockedLength = lockedLength;
                $.numLockedNFT -= uint32(lockedBurned);
            }
            if (ownedBurned > 0) {
                fromAddressData.ownedLength = ownedLength;
            }

            // update market shares
            if ($.operatorApprovals[address(this)][from].value > 0 && ownedBurned > 0) {
                $.numExchangableNFT -= uint32(ownedBurned);
            }
        }

        uint256 units = _unit() * numToBurns;
        unchecked {
            $.totalNFTSupply -= uint32(numToBurns);
            $.totalSupply -= uint96(units);
            fromAddressData.balance -= uint96(units);
        }

        /// @solidity memory-safe-assembly
        assembly {
            // Emit the {Transfer} event.
            mstore(0x00, units)
            log3(0x00, 0x20, _TRANSFER_EVENT_SIGNATURE, shr(96, shl(96, from)), 0)
        }
    }
}
