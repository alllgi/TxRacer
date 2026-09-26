// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

contract OnChainAllowList is Ownable {

    mapping(address => bool) public allowlist;

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyInAllowlist(address _addresses) {
        _checkAllowlist(_addresses);
        _;
    }

    /**
     * @notice Add to allowlist
     */
    function addToAllowlist(address address_) external onlyOwner
    {
        allowlist[address_] = true;
    }

    /**
     * @notice Add to allowlist in batch
     */
    function addToAllowlistBatch(address[] calldata addresses) external onlyOwner
    {
        for (uint i = 0; i < addresses.length; i++) {
            allowlist[addresses[i]] = true;
        }
    }

    /**
     * @notice Remove from allowlist
     */
    function removeFromAllowlist(address address_) external onlyOwner
    {
        delete allowlist[address_];
    }

    /**
     * @notice Remove from allowlist in batch
     */
    function removeFromAllowlistBatch(address[] calldata addresses) external onlyOwner
    {
        for (uint i = 0; i < addresses.length; i++) {
            delete allowlist[addresses[i]];
        }
    }

    /**
     * @notice Function with allowlist 
     */
    function addressInAllowlist(address address_) external view returns(bool)
    {
        return allowlist[address_];
    }

    /**
     * @dev Throws if address is not in allowlist
     */
    function _checkAllowlist(address address_) internal view virtual {
        require(allowlist[address_], "Address is not in allowlist");
    }

}
