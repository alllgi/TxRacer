// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

import './pool/IShibaswapV2PoolImmutables.sol';
import './pool/IShibaswapV2PoolState.sol';
import './pool/IShibaswapV2PoolDerivedState.sol';
import './pool/IShibaswapV2PoolActions.sol';
import './pool/IShibaswapV2PoolOwnerActions.sol';
import './pool/IShibaswapV2PoolEvents.sol';

/// @title The interface for a Shibaswap V2 Pool
/// @notice A Shibaswap pool facilitates swapping and automated market making between any two assets that strictly conform
/// to the ERC20 specification
/// @dev The pool interface is broken up into many smaller pieces
interface IShibaswapV2Pool is
    IShibaswapV2PoolImmutables,
    IShibaswapV2PoolState,
    IShibaswapV2PoolDerivedState,
    IShibaswapV2PoolActions,
    IShibaswapV2PoolOwnerActions,
    IShibaswapV2PoolEvents
{

}
