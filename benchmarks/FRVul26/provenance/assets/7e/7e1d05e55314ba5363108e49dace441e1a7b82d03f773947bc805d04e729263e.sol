// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

interface INonStandardToken {
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external;

    function transfer(address to, uint256 value) external;
    function transferFrom(address from, address to, uint256 value) external;
}

contract NonStandardToken is INonStandardToken {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    function mint(address account, uint256 amount) external {
        _mint(account, amount);
    }

    function _mint(address account, uint256 amount) private {
        totalSupply += amount;
        balances[account] += amount;
    }

    function balanceOf(address owner) external view override returns (uint256) {
        return balances[owner];
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return allowances[owner][spender];
    }

    function approve(address spender, uint256 value) external override {
        allowances[msg.sender][spender] = value;
    }

    function transfer(address to, uint256 value) external override {
        balances[msg.sender] -= value;
        balances[to] += value;
    }

    function transferFrom(address from, address to, uint256 value) external override {
        allowances[from][msg.sender] -= value;
        balances[from] -= value;
        balances[to] += value;
    }
}