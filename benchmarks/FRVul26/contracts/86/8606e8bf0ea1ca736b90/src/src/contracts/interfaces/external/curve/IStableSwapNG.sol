// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/* solhint-disable func-name-mixedcase, var-name-mixedcase */
interface IStableSwapNG {
    function token() external returns (address);

    // slither-disable-start naming-convention
    function add_liquidity(uint256[] memory amounts, uint256 min_mint_amount) external payable returns (uint256);

    function remove_liquidity(uint256 amount, uint256[] memory min_amounts) external returns (uint256[] memory);
    // slither-disable-end naming-convention
}
