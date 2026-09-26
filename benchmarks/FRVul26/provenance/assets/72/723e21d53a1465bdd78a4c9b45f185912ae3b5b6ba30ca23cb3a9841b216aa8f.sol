// SPDX-License-Identifier: MIT
/**
 * Vendored on October 12, 2023 from:
 * https://github.com/mudgen/diamond-3-hardhat/blob/main/contracts/facets/OwnershipFacet.sol
 */
pragma solidity ^0.8.0;

import { LibDiamond } from "../libraries/LibDiamond.sol";
import { IERC173 } from "../interfaces/IERC173.sol";

contract OwnershipFacet is IERC173 {
    function transferOwnership(address _newOwner) external override {
        LibDiamond.enforceIsContractOwner();
        LibDiamond.setContractOwner(_newOwner);
    }

    function owner() external view override returns (address owner_) {
        owner_ = LibDiamond.contractOwner();
    }
}
