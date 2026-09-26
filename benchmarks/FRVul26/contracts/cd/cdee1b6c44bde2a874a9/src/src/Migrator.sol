// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Eden} from "@core/Eden.sol";
import {Errors} from "@utils/Errors.sol";
import {EdenStaking} from "@core/Staking.sol";
import {ILotusStaking} from "@interfaces/ILotusStaking.sol";
import {Ownable2Step, Ownable} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

contract EdenMigrator is Ownable2Step, Pausable, Errors {
    ILotusStaking public immutable lotusStaking;
    EdenStaking immutable edenStaking;

    Eden immutable eden;
    IERC20 public immutable lotus;
    IERC20 immutable titanX;

    uint96[] public stakePositions;
    uint256 public totalShares;

    constructor(
        address _lotus,
        address _eden,
        address _titanX,
        address _lotusStaking,
        address _edenStaking,
        address _owner
    )
        notAddress0(_owner)
        notAddress0(_eden)
        notAddress0(_titanX)
        notAddress0(_lotus)
        notAddress0(_lotusStaking)
        notAddress0(_edenStaking)
        Ownable(_owner)
    {
        lotus = IERC20(_lotus);
        titanX = IERC20(_titanX);
        edenStaking = EdenStaking(_edenStaking);
        eden = Eden(_eden);
        lotusStaking = ILotusStaking(_lotusStaking);
        _pause();
    }

    function exchange(uint256 _amount) external notAmount0(_amount) whenNotPaused {
        lotus.transferFrom(msg.sender, address(this), _amount);
        eden.migrate(msg.sender, _amount);
    }

    function stakeLotus() external onlyOwner {
        lotus.approve(address(lotusStaking), lotus.balanceOf(address(this)));
        (uint96 _id, uint160 _shares) =
            lotusStaking.stake(lotusStaking.MAX_DURATION(), uint160(lotus.balanceOf(address(this))));

        totalShares += _shares;
        stakePositions.push(_id);
    }

    function claimRewards(uint160[] memory _ids) external returns (uint256 claimed) {
        lotusStaking.batchClaim(_ids, address(this));

        claimed = titanX.balanceOf(address(this));

        titanX.approve(address(edenStaking), claimed);
        edenStaking.distribute(claimed);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}
