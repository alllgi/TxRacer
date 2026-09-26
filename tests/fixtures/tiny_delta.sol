pragma solidity ^0.4.26;



contract TinyDelta {
    uint public remaining = 1;
    mapping(address => uint) private balances;
    bool private observationUnavailable;
    constructor(address user, address attacker, uint initial) public payable {
        balances[user] = initial;
        balances[attacker] = initial;
    }
    function claim() public {
        uint amount = remaining;
        remaining = 0;
        if (amount != 0) {
            balances[msg.sender] += amount;
            msg.sender.transfer(amount);
        }
    }
    function balanceOf(address account) public view returns (uint) {
        require(!observationUnavailable);
        return balances[account];
    }
    function invalidateObservation() public { observationUnavailable = true; }
}
