// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract Errors {
    error Address0();
    error Amount0();
    error Expired();

    modifier notAmount0(uint256 a) {
        _notAmount0(a);
        _;
    }

    modifier notExpired(uint32 _deadline) {
        if (block.timestamp > _deadline) revert Expired();
        _;
    }

    modifier notAddress0(address a) {
        _notAddress0(a);
        _;
    }

    function _notAddress0(address a) internal pure {
        if (a == address(0)) revert Address0();
    }

    function _notAmount0(uint256 a) internal pure {
        if (a == 0) revert Amount0();
    }
}
