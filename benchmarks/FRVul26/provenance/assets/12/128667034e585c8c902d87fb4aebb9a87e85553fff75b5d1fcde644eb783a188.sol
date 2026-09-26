pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

library ERC20Utils {
    using SafeERC20 for IERC20;
    error NotEnoughSrcFundsIn(uint256 amount);

    function safePull(IERC20 token_, uint256 amount_) internal {
        uint256 balanceBefore = token_.balanceOf(address(this));

        token_.safeTransferFrom(msg.sender, address(this), amount_);

        uint256 transferred = (token_.balanceOf(address(this)) - balanceBefore);

        if (transferred < amount_) revert NotEnoughSrcFundsIn(amount_);
    }

    function lazyApprove(
        IERC20 token_,
        address spender_,
        uint256 amount_
    ) internal {
        uint256 currentAllowance = token_.allowance(address(this), spender_);

        if (currentAllowance < amount_) {
            // if an approval was issued before
            token_.safeApprove(spender_, 0);
            // create permanent approve
            token_.safeApprove(spender_, type(uint256).max);
        }
    }
}
