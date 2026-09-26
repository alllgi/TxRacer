// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


/**

⠀⠀⠀⠀⠀⢀⡀⠀⠀⠀⠀⠀⡄⠀⠀⠀⠀⢀⠀⠀
⠀⠀⠀⠀⠀⠀⣏⠓⠒⠤⣰⠋⠹⡄⠀⣠⠞⣿⠀⠀
⠀⠀⠀⢀⠄⠂⠙⢦⡀⠐⠨⣆⠁⣷⣮⠖⠋⠉⠁⠀
⠀⠀⡰⠁⠀⠮⠇⠀⣩⠶⠒⠾⣿⡯⡋⠩⡓⢦⣀⡀
⠀⡰⢰⡹⠀⠀⠲⣾⣁⣀⣤⠞⢧⡈⢊⢲⠶⠶⠛⠁
⢀⠃⠀⠀⠀⣌⡅⠀⢀⡀⠀⠀⣈⠻⠦⣤⣿⡀⠀⠀
⠸⣎⠇⠀⠀⡠⡄⠀⠷⠎⠀⠐⡶⠁⠀⠀⣟⡇⠀⠀
⡇⠀⡠⣄⠀⠷⠃⠀⠀⡤⠄⠀⠀⣔⡰⠀⢩⠇⠀⠀
⡇⠀⠻⠋⠀⢀⠤⠀⠈⠛⠁⠀⢀⠉⠁⣠⠏⠀⠀⠀
⣷⢰⢢⠀⠀⠘⠚⠀⢰⣂⠆⠰⢥⡡⠞⠁⠀⠀⠀⠀
⠸⣎⠋⢠⢢⠀⢠⢀⠀⠀⣠⠴⠋⠀⠀⠀⠀⠀⠀⠀
⠀⠘⠷⣬⣅⣀⣬⡷⠖⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠈⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀

https://usestrawberry.ai

*/

contract Strawberry is ERC20, Ownable {
    uint256 public constant MAX_SUPPLY = 100_000_000 * 1e18;
    uint256 public maxWallet = MAX_SUPPLY / 200; // 0.5% of MAX_SUPPLY

    error ERC20MaxWallet();

    function _isWhitelisted(address account) internal view returns (bool) {
        return whitelist[account];
    }

    function _isEOA(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function toggleWhitelist(address account) public onlyOwner {
        whitelist[account] = !whitelist[account];
    }

    function setMaxWallet(uint256 _maxWallet) public onlyOwner {
        require(_maxWallet >= MAX_SUPPLY / 1000, "max-wallet-too-small");
        maxWallet = _maxWallet;
    }

    mapping(address => bool) public whitelist;

    constructor() ERC20("Strawberry AI", "BERRY") Ownable(msg.sender) {
        _mint(msg.sender, MAX_SUPPLY);
        toggleWhitelist(msg.sender);
    }

    function transfer(
        address to,
        uint256 value
    ) public override returns (bool) {
        address owner = _msgSender();

        uint256 balance = balanceOf(to);

        if (!_isWhitelisted(to) && !_isEOA(to) && balance + value > maxWallet) {
            revert ERC20MaxWallet();
        }

        _transfer(owner, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public override returns (bool) {
        address spender = _msgSender();

        if (
            !_isWhitelisted(to) &&
            !_isEOA(to) &&
            balanceOf(to) + value > maxWallet
        ) {
            revert ERC20MaxWallet();
        }

        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }
}
