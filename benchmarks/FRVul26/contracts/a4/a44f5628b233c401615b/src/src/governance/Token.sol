// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.27;

/// @notice Simple ERC20 token.
/// @author nani.eth (Nani DAO)
contract Token {
    event Approval(address indexed from, address indexed to, uint amount);
    event Transfer(address indexed from, address indexed to, uint amount);
    event OwnershipTransferred(address indexed from, address indexed to);

    error Unauthorized();

    modifier onlyOwner {
        if (msg.sender != owner) revert Unauthorized();
        _;
    }

    string public constant name = "NANI";
    string public constant symbol = unicode"⌘";
    uint public constant decimals = 18;
    
    uint public totalSupply;
    address public owner = tx.origin;
    
    mapping(address owner => uint) public balanceOf;
    mapping(address owner => mapping(address spender => uint)) public allowance;

    constructor() payable {}

    function approve(address to, uint amount) public returns (bool) {
        allowance[msg.sender][to] = amount;
        emit Approval(msg.sender, to, amount);
        return true;
    }

    function transfer(address to, uint amount) public returns (bool) {
        balanceOf[msg.sender] -= amount;
        unchecked { balanceOf[to] += amount; }
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint amount) public returns (bool) {
        if (allowance[from][msg.sender] != type(uint).max) 
            allowance[from][msg.sender] -= amount;
        balanceOf[from] -= amount;
        unchecked { balanceOf[to] += amount; }
        emit Transfer(from, to, amount);
        return true;
    }

    // GOVERNANCE

    function transferOwnership(address to) public onlyOwner {
        emit OwnershipTransferred(msg.sender, owner = to);
    }

    function mint(address to, uint amount) public onlyOwner {
        totalSupply += amount;
        unchecked { balanceOf[to] += amount; }
        emit Transfer(address(0), to, amount);
    }

    function burn(uint amount) public {
        balanceOf[msg.sender] -= amount;
        unchecked { totalSupply -= amount; }
        emit Transfer(msg.sender, address(0), amount);
    }
}