// SPDX-License-Identifier: LicenseRef-VPL WITH AGPL-3.0-only
pragma solidity ^0.8.25;

import {
  ERC20
} from "solady/tokens/ERC20.sol";
import {
  Ownable
} from "solady/auth/Ownable.sol";
import {
  FixedPointMathLib
} from "solady/utils/FixedPointMathLib.sol";
import {
  SafeTransferLib
} from "solady/utils/SafeTransferLib.sol";
import {
  ReentrancyGuard
} from "soledge/utils/ReentrancyGuard.sol";

/**
  @custom:benediction DEVS BENEDICAT ET PROTEGAT CONTRACTVM MEVM
  @title The Remilia ERC-20 token.
  @author Tim Clancy <tim-clancy.eth>
  @custom:terry "God is just. Work is rewarded with blessing if not money. Luck
    is the most important thing, but really it's God."

  -----------------------------------------------------------------------------
  The Remilia ERC-20 token.

  No seed raise, no investors,
  no burdens, no promises,
  just conviction.

  I love you.
  -----------------------------------------------------------------------------

  A note from the author: Milady, you will always have within you a beautiful
  kernel of our collective net history. No matter what happens, no matter who
  fails, no matter who succeeds, no matter what success does to you, no matter
  where your network spirits go: behind those neochibi eyes is a memory of the
  old ways. A memory of whitepilled anticorporate post-authorship. A flag for
  unapologetic radicals on a holy mission.
  
  I long for network spirituality.

  @custom:date July 22nd, 2024.
*/
contract Cult is ERC20, Ownable, ReentrancyGuard {
  bytes32 constant MESSAGE =
    0xe07fc590053cce006bcf1908510532bf0bddbb779b1b5e78855f2229ef4e5de9;

  /**
    An error emitted if trying to use `transferToken` on the Cult token. The
    only way to remove the Cult token from its own contract is using the vest
    mechanic. See notes on its fallibility later.
  */
  error MustVest ();

  /// An error emitted if trying to push a concluded or invalid vest amount.
  error InvalidVest ();

  /**
    This struct records details about existing token vests. All vests using
    this contract for distribution will be concluded well before 2106. No
    single vest will exceed 10B tokens in `amount`.

    @param recipient The address that receives the vested tokens.
    @param amount The amount of tokens to vest to the `recipient`.
    @param amountClaimed The amount of tokens already claimed by `recipient`.
    @param start The time when the vest starts.
    @param end The time when the vest ends.
    @param lastClaimTime The time when `recipient` last claimed.
  */
  struct Vest {
    address recipient;
    uint96 amount;
    uint96 amountClaimed;
    uint32 start;
    uint32 end;
    uint32 lastClaimTime;
  }

  /**
    A mapping of addresses to their `vestId`-identified `Vest`s.

    @custom:param recipient The recipient of the `Vest`.
    @custom:param id The ID of some specific `Vest` details.
  */
  mapping (
    address recipient => mapping ( uint96 id => Vest )
  ) public vests;

  /**
    This struct encodes the input for creating or modifying a token vest.
    
    @param recipient The address that receives the vested tokens. This is
      really only here for nice padding. :)
    @param amount The amount of tokens to vest to the `recipient`.
    @param start The time when the vest starts.
    @param end The time when the vest ends.
    @param id Different `id` values may create multiple vests to the same
      `recipient`.
  */
  struct SetVest {
    address recipient;
    uint96 amount;
    uint32 start;
    uint32 end;
    uint96 id;
  }

  /**
    This event is emitted whenever a token vest is created or modified.

    @param recipient The beneficiary of the token vest.
    @param id The specific ID of the `Vest` being set.
  */
  event VestSet (
    address indexed recipient,
    uint96 indexed id
  );

  /**
    Our very simple constructor mints the entire token supply to the owner
    from whence it is distributed to claims and vests and vaults.

    @param _owner The initial owner.
  */
  constructor (
    address _owner
  ) {
    _initializeOwner(_owner);
    _mint(_owner, 100_000000000_000000000000000000);
  }

  /**
    Returns the name of the token.

    @return _ The name of the token.
  */
  function name () override public pure returns (string memory) {
    return "Milady Cult Coin";
  }

  /**
    Returns the symbol of the token.

    @return _ The symbol used as the token ticker.
  */
  function symbol () override public pure returns (string memory) {
    return "CULT";
  }

  /**
    Allow the owner to transfer Ether out of this contract.
    We only need this to rescue anyone dumb.

    @param _to The address to transfer Ether to.
    @param _amount The amount of Ether to transfer.
  */
  function transferEther (
    address _to,
    uint256 _amount
  ) external payable onlyOwner {
    bool success = SafeTransferLib.trySafeTransferETH(
      _to,
      _amount,
      SafeTransferLib.GAS_STIPEND_NO_STORAGE_WRITES
    );
    if (!success) {
      SafeTransferLib.forceSafeTransferETH(_to, _amount);
    }
  }

  /**
    Allow the owner to transfer ERC-20 tokens out of this contract.
    We only need this to rescue anyone dumb.

    @param _token The address of the ERC-20 token to transfer.
    @param _to The address to transfer the ERC-20 `_token` to.
    @param _amount The amount of `_token` to transfer.
  */
  function transferToken (
    address _token,
    address _to,
    uint256 _amount
  ) external payable onlyOwner {
    if (_token == address(this)) {
      revert MustVest();
    }
    SafeTransferLib.safeTransfer(_token, _to, _amount);
  }

  /**
    Allow the owner to set vests for this token. The owner must take care not
    to create invalid vests.

    @param _vests An array of `CreateVest` inputs to create vests with.
  */
  function setVest (
    SetVest[] memory _vests
  ) external onlyOwner {
    for (uint i = 0; i < _vests.length; i++) {
      address recipient = _vests[i].recipient;
      uint96 id = _vests[i].id;
      Vest memory vest = Vest({
        recipient: _vests[i].recipient,
        amount: _vests[i].amount,
        amountClaimed: 0,
        start: _vests[i].start,
        end: _vests[i].end,
        lastClaimTime: _vests[i].start
      });
      vests[recipient][id] = vest;
      emit VestSet(recipient, id);
    }
  }

  /**
    A function allowing vested tokens to be pushed to the `msg.sender`.

    @param _id The ID of the specific `msg.sender` `Vest` to push.
    @param _amount The amount of the vest to push.
  */
  function pushVest (
    uint96 _id,
    uint256 _amount
  ) external nonReentrant {
    Vest memory vest = vests[msg.sender][_id];

    // Verify that the vest is active.
    if (vest.amount < 1) {
      revert InvalidVest();
    }

    // Calculate the current releasable token amount.
    uint96 vestedAmount = uint96(FixedPointMathLib.lerp(
      0, vest.amount, block.timestamp, vest.start, vest.end
    ));

    // Reduce the unclaimed amount by the amount already claimed.
    uint256 unclaimedAmount = vestedAmount - vest.amountClaimed;

    // Prevent overclaiming a vest.
    if (_amount > unclaimedAmount) {
      revert InvalidVest();
    }

    // Update the vest being tracked.
    vest.amountClaimed = vest.amountClaimed + uint96(_amount);
    vest.lastClaimTime = uint32(block.timestamp);
    vests[msg.sender][_id] = vest;

    // Transfer the unclaimed tokens to the beneficiary.
    SafeTransferLib.safeTransfer(address(this), msg.sender, _amount);
  }
}

