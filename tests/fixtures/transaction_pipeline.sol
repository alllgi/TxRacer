pragma solidity ^0.4.26;

contract TransactionPipeline {
    uint public reserve;
    constructor() public payable { reserve = 7; }
    function prepare(uint amount) public { reserve = amount; }
    function consume(uint amount) public returns (uint) {
        require(reserve >= amount);
        reserve -= amount;
        return reserve;
    }
    function joint(uint amount) public payable returns (uint) {
        require(amount == 100 && msg.value == 5 && block.number == 42);
        reserve = amount;
        return reserve;
    }
    function payout(uint amount) public {
        require(amount <= reserve);
        msg.sender.transfer(reserve);
    }
}
