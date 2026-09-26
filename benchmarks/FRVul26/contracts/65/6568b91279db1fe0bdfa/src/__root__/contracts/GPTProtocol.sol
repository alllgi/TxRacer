// SPDX-License-Identifier: MIT

//** GPT Protocol Token */
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract GPTProtocol is ERC20Burnable {
    constructor() ERC20("GPT Protocol", "GPT") {
        _mint(msg.sender, 1_000_000_000 * 10 ** decimals());
    }
}