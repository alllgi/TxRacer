// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "../../SYBaseUpg.sol";
import "../../StEthHelper.sol";
import "../../../../interfaces/IPTokenWithSupplyCap.sol";
import "../../../../interfaces/Mellow/IMellowVaultConfigurator.sol";
import "../../../../interfaces/IPPriceFeed.sol";
import "../../../../interfaces/IERC4626.sol";
import "../PendleERC4626UpgSYV2.sol";

/// @dev This SY implementation intends to ignore native interest from Mellow Vault's underlying
contract PendleMellowVaultSYBaseV2Upg is PendleERC4626UpgSYV2, IPTokenWithSupplyCap {
    event SetPricingHelper(address newPricingHelper);

    // solhint-disable immutable-vars-naming
    address public immutable vault;
    address public pricingHelper; // Old storage layout ...

    constructor(address _vault) PendleERC4626UpgSYV2(_vault) {
        vault = _vault;
        _disableInitializers();
    }

    function getTokensOut() public view override returns (address[] memory res) {
        res = new address[](1);
        res[0] = yieldToken;
    }

    function isValidTokenOut(address token) public view override returns (bool) {
        return token == yieldToken;
    }

    function getAbsoluteSupplyCap() external view virtual returns (uint256) {
        return IERC4626(vault).maxMint(address(this));
    }

    function getAbsoluteTotalSupply() external view virtual returns (uint256) {
        return IERC20(vault).totalSupply();
    }
}
