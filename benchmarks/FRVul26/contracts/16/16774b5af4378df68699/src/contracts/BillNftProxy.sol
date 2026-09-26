// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

/*
  ______                       _______                             __ 
 /      \                     |       \                           |  \
|  ▓▓▓▓▓▓\  ______    ______  | ▓▓▓▓▓▓▓\  ______   _______    ____| ▓▓
| ▓▓__| ▓▓ /      \  /      \ | ▓▓__/ ▓▓ /      \ |       \  /      ▓▓
| ▓▓    ▓▓|  ▓▓▓▓▓▓\|  ▓▓▓▓▓▓\| ▓▓    ▓▓|  ▓▓▓▓▓▓\| ▓▓▓▓▓▓▓\|  ▓▓▓▓▓▓▓
| ▓▓▓▓▓▓▓▓| ▓▓  | ▓▓| ▓▓    ▓▓| ▓▓▓▓▓▓▓\| ▓▓  | ▓▓| ▓▓  | ▓▓| ▓▓  | ▓▓
| ▓▓  | ▓▓| ▓▓__/ ▓▓| ▓▓▓▓▓▓▓▓| ▓▓__/ ▓▓| ▓▓__/ ▓▓| ▓▓  | ▓▓| ▓▓__| ▓▓
| ▓▓  | ▓▓| ▓▓    ▓▓ \▓▓     \| ▓▓    ▓▓ \▓▓    ▓▓| ▓▓  | ▓▓ \▓▓    ▓▓
 \▓▓   \▓▓| ▓▓▓▓▓▓▓   \▓▓▓▓▓▓▓ \▓▓▓▓▓▓▓   \▓▓▓▓▓▓  \▓▓   \▓▓  \▓▓▓▓▓▓▓
          | ▓▓                                                        
          | ▓▓                                                        
           \▓▓                                                         
 * App:             https://Ape.Bond
 * Medium:          https://ApeBond.medium.com
 * Twitter:         https://twitter.com/ApeBond
 * Telegram:        https://t.me/ape_bond
 * Announcements:   https://t.me/ApeBond_news
 * Discord:         https://ApeBond.click/discord
 * Reddit:          https://ApeBond.click/reddit
 * Instagram:       https://instagram.com/ape.bond
 * GitHub:          https://github.com/ApeSwapFinance
 */

import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

/**
 * @title BillNftProxy 
 * @author ApeSwap
 * @notice With EIP-5725 still in review, we wanted the capabilities to update the interface of the BillNft
 *  if needed. Once EIP-5725 is finalized, we intend on renouncing proxy admin rights.
 */
contract BillNftProxy is TransparentUpgradeableProxy {
    constructor(address logic, address admin, bytes memory data) TransparentUpgradeableProxy(logic, admin, data) {}
}