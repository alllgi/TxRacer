// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

import './pool/IBagelV3PoolImmutables.sol';
import './pool/IBagelV3PoolState.sol';
import './pool/IBagelV3PoolDerivedState.sol';
import './pool/IBagelV3PoolActions.sol';
import './pool/IBagelV3PoolOwnerActions.sol';
import './pool/IBagelV3PoolEvents.sol';

/// @title The interface for a BagelSwap V3 Pool
/// @notice A BagelSwap pool facilitates swapping and automated market making between any two assets that strictly conform
/// to the ERC20 specification
/// @dev The pool interface is broken up into many smaller pieces
interface IBagelV3Pool is
    IBagelV3PoolImmutables,
    IBagelV3PoolState,
    IBagelV3PoolDerivedState,
    IBagelV3PoolActions,
    IBagelV3PoolOwnerActions,
    IBagelV3PoolEvents
{

}
