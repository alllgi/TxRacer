pragma solidity ^0.4.26;


contract SyntheticToken {
    mapping(address => uint) public balanceOf;
    event Transfer(address indexed from, address indexed to, uint amount);
    function mint(address recipient, uint amount) public {
        balanceOf[recipient] += amount;
        emit Transfer(address(0), recipient, amount);
    }
    function move(address sender, address recipient, uint amount) public {
        require(balanceOf[sender] >= amount);
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }
}

contract SyntheticExchange {
    SyntheticToken public tokenA;
    SyntheticToken public tokenB;
    uint public rate;
    constructor(address a, address b) public payable { tokenA = SyntheticToken(a); tokenB = SyntheticToken(b); rate = 2; }
    function prepare(uint amount) public { rate = amount; }
    function forward(uint amount) public {
        tokenA.move(msg.sender, address(this), amount);
        tokenB.move(address(this), msg.sender, rate);


        msg.sender.transfer(rate);
    }
    function reverse(uint amount) public {
        tokenB.move(msg.sender, address(this), amount);
        tokenA.move(address(this), msg.sender, rate);
    }
    function joint(uint amount) public payable {
        require(amount == 100 && msg.value == 5);
        rate = amount;
    }
}
