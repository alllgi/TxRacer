// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

/* === OZ === */
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

import {IUniswapV2Factory} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";

/* == CORE ==  */
import {AlienXMinting} from "./Minting.sol";

/* == UTILS == */
import {sqrt, wmul} from "@utils/Math.sol";

/* == CONST == */
import "./const/Constants.sol";

/**
 * @title AlienX
 * @dev ERC20 token contract for AlienX tokens.
 * @notice It can be minted by AlienXMinting during cycles
 */
contract AlienX is ERC20Burnable, Ownable {
    AlienXMinting public minting;

    address public titanXAlienXPool;
    address public infAlienXPool;
    address public immutable v2Factory;

    uint256 public lpCreationBlock;
    uint256 totalTaxesBurnt;

    uint256 constant DEAD_BLOCKS = 3;

    error OnlyMinting();
    error DeadBlocksNotPassed();

    modifier onlyMinting() {
        _onlyMinting();
        _;
    }

    /* ==== CONSTRUCTOR ==== */

    constructor(address _v2Factory) ERC20("ALIENX", "ALIENX") Ownable(msg.sender) {
        v2Factory = _v2Factory;
    }

    /* == EXTERNAL == */

    function setMinting(address _minting) external onlyOwner {
        minting = AlienXMinting(_minting);
    }

    /**
     * @notice Mints ALIENX tokens to a specified address.
     * @notice This is only callable by the Minting contract
     * @param _to The address to mint the tokens to.
     * @param _amount The amount of tokens to mint.
     */
    function mint(address _to, uint256 _amount) external onlyMinting {
        _mint(_to, _amount);
    }

    function setLp(address _infAlienXPool, address _titanXAlienXPool) external onlyMinting {
        lpCreationBlock = block.number;
        infAlienXPool = _infAlienXPool;
        titanXAlienXPool = _titanXAlienXPool;
    }

    function _onlyMinting() internal view {
        require(msg.sender == address(minting), OnlyMinting());
    }

    function _update(address from, address to, uint256 value) internal override {
        if (lpCreationBlock != 0 && (from != address(0) && to != address(0))) {
            require(block.number > lpCreationBlock + DEAD_BLOCKS, DeadBlocksNotPassed());
            uint256 toBurn = wmul(value, BUY_SELL_TAX);
            uint256 toLP = wmul(value, BUY_SELL_TAX);

            value -= (toBurn + toLP);

            totalTaxesBurnt += toBurn;

            _burn(from, toLP + toBurn);
            _mint(ALIENX_LP, toLP);
        }

        super._update(from, to, value);
    }
}
