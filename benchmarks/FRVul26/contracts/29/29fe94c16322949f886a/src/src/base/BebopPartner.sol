// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Errors.sol";

abstract contract BebopPartner {

    struct PartnerInfo {
        uint16 fee;
        address beneficiary;
        bool registered;
    }
    mapping(uint64 => PartnerInfo) public partners;
    uint16 internal constant HUNDRED_PERCENT = 10000;

    constructor(){
        partners[0].registered = true;
    }


    /// @notice Register new partner
    /// @param partnerId the unique identifier for this partner
    /// @param fee the additional fee to add to each swap from this partner
    /// @param beneficiary the address to send the partner's share of fees to
    function registerPartner(uint64 partnerId, uint16 fee, address beneficiary) external {
        if(partners[partnerId].registered) revert PartnerAlreadyRegistered();
        if(fee > HUNDRED_PERCENT) revert PartnerFeeTooHigh();
        if (beneficiary == address(0)) revert NullBeneficiary();
        partners[partnerId] = PartnerInfo(fee, beneficiary, true);
    }


}
