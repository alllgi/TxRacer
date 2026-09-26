// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.4;

import {MergedPriceFeedAdapterWithRoundsPrimaryProd} from "@redstone-finance/on-chain-relayer/contracts/price-feeds/data-services/MergedPriceFeedAdapterWithRoundsPrimaryProd.sol";
import {OldGelatoAddress, GelatoAddress} from "../__addresses/Addresses.sol";

contract MergedAdapterWithRoundsApxethethV1 is MergedPriceFeedAdapterWithRoundsPrimaryProd {

  address internal constant MAIN_UPDATER_ADDRESS = 0x483373994cc2fA8412D520709B56916A6ce056D5;
  address internal constant FALLBACK_UPDATER_ADDRESS = 0x6dbF248d1c44303834c9559aAAeb27fc8595c40C;
  address internal constant MANUAL_UPDATER_ADDRESS = 0x7ADA18c677A3Dd23f1204E651D5151F7D854E3E0;

  error UpdaterNotAuthorised(address signer);

  function getDataFeedId() public pure virtual override returns (bytes32) {
    return bytes32("apxETH/ETH");
  }

  function requireAuthorisedUpdater(address updater) public view override virtual {
    if (
      updater != MAIN_UPDATER_ADDRESS &&
      updater != FALLBACK_UPDATER_ADDRESS &&
      updater != MANUAL_UPDATER_ADDRESS &&
      updater != GelatoAddress.ADDR &&
      updater != OldGelatoAddress.ADDR
    ) {
      revert UpdaterNotAuthorised(updater);
    }
  }
}
