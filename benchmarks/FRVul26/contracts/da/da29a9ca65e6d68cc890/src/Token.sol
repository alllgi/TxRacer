/*

#####################################
Token generated with ❤️ on 20lab.app
#####################################

*/


// SPDX-License-Identifier: No License
pragma solidity 0.8.25;

import {IERC20, ERC20} from "./ERC20.sol";
import {ERC20Burnable} from "./ERC20Burnable.sol";
import {Ownable, Ownable2Step} from "./Ownable2Step.sol";

contract TROPPY is ERC20, ERC20Burnable, Ownable2Step {
     
    mapping (address => bool) public isExcludedFromLimits;

    uint256 public maxWalletAmount;
 
    error MaxWalletAmountTooLow(uint256 maxWalletAmount, uint256 limit);
    error CannotExceedMaxWalletAmount(uint256 maxWalletAmount);
 
    event ExcludeFromLimits(address indexed account, bool isExcluded);

    event MaxWalletAmountUpdated(uint256 maxWalletAmount);
 
    constructor()
        ERC20(unicode"TROPPY", unicode"TROPPY")
        Ownable(msg.sender)
    {
        assembly { if iszero(extcodesize(caller())) { revert(0, 0) } }
        address supplyRecipient = 0x04B4e2EEe1dFd279dc77C455CB8599860229A4C1;
        
        _excludeFromLimits(supplyRecipient, true);
        _excludeFromLimits(address(this), true);
        _excludeFromLimits(address(0), true); 

        updateMaxWalletAmount(126700000000 * (10 ** decimals()) / 10);

        _mint(supplyRecipient, 4206900000000 * (10 ** decimals()) / 10);
        _transferOwnership(0x04B4e2EEe1dFd279dc77C455CB8599860229A4C1);
    }
    
    function decimals() public pure override returns (uint8) {
        return 11;
    }
    
    function excludeFromLimits(address account, bool isExcluded) external onlyOwner {
        _excludeFromLimits(account, isExcluded);
    }

    function _excludeFromLimits(address account, bool isExcluded) internal {
        isExcludedFromLimits[account] = isExcluded;

        emit ExcludeFromLimits(account, isExcluded);
    }

    function updateMaxWalletAmount(uint256 _maxWalletAmount) public onlyOwner {
        if (_maxWalletAmount < _maxWalletSafeLimit()) revert MaxWalletAmountTooLow(_maxWalletAmount, _maxWalletSafeLimit());

        maxWalletAmount = _maxWalletAmount;
        
        emit MaxWalletAmountUpdated(_maxWalletAmount);
    }

    function _maxWalletSafeLimit() private view returns (uint256) {
        return totalSupply() / 1000;
    }


    function _update(address from, address to, uint256 amount)
        internal
        override
    {
        _beforeTokenUpdate(from, to, amount);
        
        super._update(from, to, amount);
        
        _afterTokenUpdate(from, to, amount);
        
    }

    function _beforeTokenUpdate(address from, address to, uint256 amount)
        internal
        view
    {
    }

    function _afterTokenUpdate(address from, address to, uint256 amount)
        internal
    {
        if (!isExcludedFromLimits[to] && balanceOf(to) > maxWalletAmount) {
            revert CannotExceedMaxWalletAmount(maxWalletAmount);
        }

    }
}
