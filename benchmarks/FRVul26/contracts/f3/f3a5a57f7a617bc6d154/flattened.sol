// Sources retrieved from Sourcify API v2.
// Deterministic best-effort flattening; original files are preserved under src/.

// File: contracts/mainnet/common/interfaces.sol

pragma solidity ^0.8.2;

interface TokenInterface {
    function approve(address, uint256) external;
    function transfer(address, uint) external;
    function transferFrom(address, address, uint) external;
    function deposit() external payable;
    function withdraw(uint) external;
    function balanceOf(address) external view returns (uint);
    function decimals() external view returns (uint);
    function totalSupply() external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint256);
}

interface MemoryInterface {
    function getUint(uint id) external returns (uint num);
    function setUint(uint id, uint val) external;
}

interface InstaMapping {
    function cTokenMapping(address) external view returns (address);
    function gemJoinMapping(bytes32) external view returns (address);
}

interface AccountInterface {
    function enable(address) external;
    function disable(address) external;
    function isAuth(address) external view returns (bool);
    function cast(
        string[] calldata _targetNames,
        bytes[] calldata _datas,
        address _origin
    ) external payable returns (bytes32[] memory responses);
}

interface ListInterface {
    function accountID(address) external returns (uint64);
}

interface InstaConnectors {
    function isConnectors(string[] calldata) external returns (bool, address[] memory);
}

// File: contracts/mainnet/common/stores.sol

pragma solidity ^0.8.2;




abstract contract Stores {

  /**
   * @dev Return ethereum address
   */
  address constant internal ethAddr = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

  /**
   * @dev Return Wrapped ETH address
   */
  address constant internal wethAddr = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

  /**
   * @dev Return memory variable address
   */
  MemoryInterface constant internal instaMemory = MemoryInterface(0x8a5419CfC711B2343c17a6ABf4B2bAFaBb06957F);

  /**
   * @dev Return InstaDApp Mapping Addresses
   */
  InstaMapping constant internal instaMapping = InstaMapping(0xe81F70Cc7C0D46e12d70efc60607F16bbD617E88);

  /**
   * @dev Return InstaList Address
   */
  ListInterface internal constant instaList = ListInterface(0x4c8a1BEb8a87765788946D6B19C6C6355194AbEb);

  /**
	 * @dev Return connectors registry address
	 */
	InstaConnectors internal constant instaConnectors = InstaConnectors(0x97b0B3A8bDeFE8cB9563a3c610019Ad10DB8aD11);

  /**
   * @dev Get Uint value from InstaMemory Contract.
   */
  function getUint(uint getId, uint val) internal returns (uint returnVal) {
    returnVal = getId == 0 ? val : instaMemory.getUint(getId);
  }

  /**
  * @dev Set Uint value in InstaMemory Contract.
  */
  function setUint(uint setId, uint val) virtual internal {
    if (setId != 0) instaMemory.setUint(setId, val);
  }

}

// File: @openzeppelin/contracts/utils/math/SafeMath.sol

// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// File: contracts/mainnet/common/math.sol

pragma solidity ^0.8.2;



contract DSMath {
  uint constant WAD = 10 ** 18;
  uint constant RAY = 10 ** 27;

  function add(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.add(x, y);
  }

  function sub(uint x, uint y) internal virtual pure returns (uint z) {
    z = SafeMath.sub(x, y);
  }

  function mul(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.mul(x, y);
  }

  function div(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.div(x, y);
  }

  function wmul(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.add(SafeMath.mul(x, y), WAD / 2) / WAD;
  }

  function wdiv(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.add(SafeMath.mul(x, WAD), y / 2) / y;
  }

  function rdiv(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.add(SafeMath.mul(x, RAY), y / 2) / y;
  }

  function rmul(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.add(SafeMath.mul(x, y), RAY / 2) / RAY;
  }

  function toInt(uint x) internal pure returns (int y) {
    y = int(x);
    require(y >= 0, "int-overflow");
  }

  function toUint(int256 x) internal pure returns (uint256) {
      require(x >= 0, "int-overflow");
      return uint256(x);
  }

  function toRad(uint wad) internal pure returns (uint rad) {
    rad = mul(wad, 10 ** 27);
  }

}

// File: contracts/mainnet/common/basic.sol

pragma solidity ^0.8.2;





abstract contract Basic is DSMath, Stores {

    function convert18ToDec(uint _dec, uint256 _amt) internal pure returns (uint256 amt) {
        amt = (_amt / 10 ** (18 - _dec));
    }

    function convertTo18(uint _dec, uint256 _amt) internal pure returns (uint256 amt) {
        amt = mul(_amt, 10 ** (18 - _dec));
    }

    function getTokenBal(TokenInterface token) internal view returns(uint _amt) {
        _amt = address(token) == ethAddr ? address(this).balance : token.balanceOf(address(this));
    }

    function getTokensDec(TokenInterface buyAddr, TokenInterface sellAddr) internal view returns(uint buyDec, uint sellDec) {
        buyDec = address(buyAddr) == ethAddr ?  18 : buyAddr.decimals();
        sellDec = address(sellAddr) == ethAddr ?  18 : sellAddr.decimals();
    }

    function encodeEvent(string memory eventName, bytes memory eventParam) internal pure returns (bytes memory) {
        return abi.encode(eventName, eventParam);
    }

    function approve(TokenInterface token, address spender, uint256 amount) internal {
        try token.approve(spender, amount) {

        } catch {
            token.approve(spender, 0);
            token.approve(spender, amount);
        }
    }

    function changeEthAddress(address buy, address sell) internal pure returns(TokenInterface _buy, TokenInterface _sell){
        _buy = buy == ethAddr ? TokenInterface(wethAddr) : TokenInterface(buy);
        _sell = sell == ethAddr ? TokenInterface(wethAddr) : TokenInterface(sell);
    }

    function changeEthAddrToWethAddr(address token) internal pure returns(address tokenAddr){
        tokenAddr = token == ethAddr ? wethAddr : token;
    }

    function convertEthToWeth(bool isEth, TokenInterface token, uint amount) internal {
        if(isEth) token.deposit{value: amount}();
    }

    function convertWethToEth(bool isEth, TokenInterface token, uint amount) internal {
       if(isEth) {
            approve(token, address(token), amount);
            token.withdraw(amount);
        }
    }
}

// File: contracts/mainnet/connectors/fluid/events.sol

pragma solidity ^0.8.2;

contract Events {
    event LogOperate(
        address vaultAddress,
        uint256 nftId,
        int256 newCol,
        int256 newDebt
    );

    event LogOperateWithIds(
        address vaultAddress,
        uint256 nftId,
        int256 newCol,
        int256 newDebt,
        uint256[] getIds,
        uint256[] setIds
    );
}

// File: contracts/mainnet/connectors/fluid/interface.sol

pragma solidity ^0.8.2;

interface IVault {
    /// @dev Single function which handles supply, withdraw, borrow & payback
    /// @param nftId_ NFT ID for interaction. If 0 then create new NFT/position.
    /// @param newCol_ new collateral. If positive then deposit, if negative then withdraw, if 0 then do nohing
    /// @param newDebt_ new debt. If positive then borrow, if negative then payback, if 0 then do nohing
    /// @param to_ address where withdraw or borrow should go. If address(0) then msg.sender
    /// @return nftId_ if 0 then this returns the newly created NFT Id else returns the same NFT ID
    /// @return final supply amount. Mainly if max withdraw using type(int).min then this is useful to get perfect amount else remain same as newCol_
    /// @return final borrow amount. Mainly if max payback using type(int).min then this is useful to get perfect amount else remain same as newDebt_
    function operate(
        uint256 nftId_, // if 0 then new position
        int256 newCol_, // if negative then withdraw
        int256 newDebt_, // if negative then payback
        address to_ // address at which the borrow & withdraw amount should go to. If address(0) then it'll go to msg.sender
    )
        external
        payable
        returns (
            uint256, // nftId_
            int256, // final supply amount if - then withdraw
            int256 // final borrow amount if - then payback
        );

    struct ConstantViews {
        address liquidity;
        address factory;
        address adminImplementation;
        address secondaryImplementation;
        address supplyToken;
        address borrowToken;
        uint8 supplyDecimals;
        uint8 borrowDecimals;
        uint vaultId;
        bytes32 liquiditySupplyExchangePriceSlot;
        bytes32 liquidityBorrowExchangePriceSlot;
        bytes32 liquidityUserSupplySlot;
        bytes32 liquidityUserBorrowSlot;
    }

    function constantsView()
        external
        view
        returns (ConstantViews memory constantsView_);
}

// File: contracts/mainnet/connectors/fluid/main.sol

pragma solidity ^0.8.2;

/**
 * @title Fluid.
 * @dev Lending & Borrowing.
 */







abstract contract FluidConnector is Events, Basic {
    /**
     * @dev Returns Eth address
     */
    function getEthAddr() internal pure returns (address) {
        return 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    }

    /**
     * @dev Deposit, borrow, payback and withdraw asset from the vault.
     * @notice Single function which handles supply, withdraw, borrow & payback
     * @param vaultAddress_ Vault address.
     * @param nftId_ NFT ID for interaction. If 0 then create new NFT/position.
     * @param newCol_ New collateral. If positive then deposit, if negative then withdraw, if 0 then do nothing.
     * For max deposit use type(uint25).max, for max withdraw use type(uint25).min.
     * @param newDebt_ New debt. If positive then borrow, if negative then payback, if 0 then do nothing
     * For max payback use type(uint25).min.
     * @param repayApproveAmt_ In case of max amount for payback, this amount will be approved for spending.
     * Should always be positive.
     * @param getIds_ Array of 5 elements to retrieve IDs:
     * Nft Id, Supply amount, Withdraw amount, Borrow Amount, Payback Amount
     * @param setIds_ Array of 5 elements to store IDs generated:
     * Nft Id, Supply amount, Withdraw amount, Borrow Amount, Payback Amount
     */
    function operateWithIds(
        address vaultAddress_,
        uint256 nftId_,
        int256 newCol_,
        int256 newDebt_,
        uint256 repayApproveAmt_,
        uint256[] memory getIds_,
        uint256[] memory setIds_
    )
        external
        payable
        returns (string memory _eventName, bytes memory _eventParam)
    {
        if (getIds_[1] > 0 && getIds_[2] > 0) {
            revert("Supply and withdraw get IDs cannot both be > 0.");
        }

        if (getIds_[3] > 0 && getIds_[4] > 0) {
            revert("Borrow and payback get IDs cannot both be > 0.");
        }

        if (setIds_[1] > 0 && setIds_[2] > 0) {
            revert("Supply and withdraw set IDs cannot both be > 0.");
        }

        if (setIds_[3] > 0 && setIds_[4] > 0) {
            revert("Borrow and payback set IDs cannot both be > 0.");
        }

        nftId_ = getUint(getIds_[0], nftId_);

        newCol_ = getIds_[1] > 0
            ? int256(getUint(getIds_[1], uint256(newCol_)))
            : getIds_[2] > 0
                ? -int256(getUint(getIds_[2], uint256(newCol_)))
                : newCol_;

        newDebt_ = getIds_[3] > 0
            ? int256(getUint(getIds_[3], uint256(newDebt_)))
            : getIds_[4] > 0
                ? -int256(getUint(getIds_[4], uint256(newDebt_)))
                : newDebt_;

        IVault vault_ = IVault(vaultAddress_);

        IVault.ConstantViews memory vaultDetails_ = vault_.constantsView();

        uint256 ethAmount_;

        bool isColMax_ = newCol_ == type(int256).max;

        // Deposit
        if (newCol_ > 0) {
            if (vaultDetails_.supplyToken == getEthAddr()) {
                ethAmount_ = isColMax_
                    ? address(this).balance
                    : uint256(newCol_);

                newCol_ = int256(ethAmount_);
            } else {
                if (isColMax_) {
                    newCol_ = int256(
                        TokenInterface(vaultDetails_.supplyToken).balanceOf(
                            address(this)
                        )
                    );
                }

                approve(
                    TokenInterface(vaultDetails_.supplyToken), 
                    vaultAddress_, 
                    uint256(newCol_)
                );
            }
        }

        bool isPaybackMin_ = newDebt_ == type(int256).min;

        // Payback
        if (newDebt_ < 0) {
            if (vaultDetails_.borrowToken == getEthAddr()) {
                // Needs to be positive as it will be send in msg.value
                ethAmount_ = isPaybackMin_
                    ? repayApproveAmt_
                    : uint256(-newDebt_);
            } else {
                isPaybackMin_
                    ? approve(
                        TokenInterface(vaultDetails_.borrowToken), 
                        vaultAddress_, 
                        repayApproveAmt_
                    )
                    : approve(
                        TokenInterface(vaultDetails_.borrowToken), 
                        vaultAddress_, 
                        uint256(-newDebt_)
                    );
            }
        }

        // Note max withdraw will be handled by Fluid contract
        (nftId_, newCol_, newDebt_) = vault_.operate{value: ethAmount_}(
            nftId_,
            newCol_,
            newDebt_,
            address(this)
        );

        setUint(setIds_[0], nftId_);

        setIds_[1] > 0
            ? setUint(setIds_[1], uint256(newCol_))
            : setUint(setIds_[2], uint256(newCol_)); // If setIds_[2] != 0, it will set the ID.
        setIds_[3] > 0
            ? setUint(setIds_[3], uint256(newDebt_))
            : setUint(setIds_[4], uint256(newDebt_)); // If setIds_[4] != 0, it will set the ID.

        // Revoke supply approvals in case of deposit
        if (newCol_ > 0 && vaultDetails_.supplyToken != getEthAddr()) {
            approve(
                TokenInterface(vaultDetails_.supplyToken),
                vaultAddress_,
                0
            );
        }

        // Revoke borrow approvals in case of payback
        if (newDebt_ < 0 && vaultDetails_.borrowToken != getEthAddr()) {
            approve(
                TokenInterface(vaultDetails_.borrowToken),
                vaultAddress_,
                0
            );
        }

        _eventName = "LogOperateWithIds(address,uint256,int256,int256,uint256[],uint256[])";
        _eventParam = abi.encode(
            vaultAddress_,
            nftId_,
            newCol_,
            newDebt_,
            getIds_,
            setIds_
        );
    }

    /**
     * @dev Deposit, borrow, payback and withdraw asset from the vault.
     * @notice Single function which handles supply, withdraw, borrow & payback
     * @param vaultAddress_ Vault address.
     * @param nftId_ NFT ID for interaction. If 0 then create new NFT/position.
     * @param newCol_ New collateral. If positive then deposit, if negative then withdraw, if 0 then do nothing.
     * For max deposit use type(uint25).max, for max withdraw use type(uint25).min.
     * @param newDebt_ New debt. If positive then borrow, if negative then payback, if 0 then do nothing
     * For max payback use type(uint25).min.
     * @param repayApproveAmt_ In case of max amount for payback, this amount will be approved for spending.
     * Should always be positive.
     */
    function operate(
        address vaultAddress_,
        uint256 nftId_,
        int256 newCol_,
        int256 newDebt_,
        uint256 repayApproveAmt_
    )
        external
        payable
        returns (string memory _eventName, bytes memory _eventParam)
    {
        IVault vault_ = IVault(vaultAddress_);

        IVault.ConstantViews memory vaultDetails_ = vault_.constantsView();

        uint256 ethAmount_;

        bool isColMax_ = newCol_ == type(int256).max;

        // Deposit
        if (newCol_ > 0) {
            if (vaultDetails_.supplyToken == getEthAddr()) {
                ethAmount_ = isColMax_
                    ? address(this).balance
                    : uint256(newCol_);

                newCol_ = int256(ethAmount_);
            } else {
                if (isColMax_) {
                    newCol_ = int256(
                        TokenInterface(vaultDetails_.supplyToken).balanceOf(
                            address(this)
                        )
                    );
                }

                approve(
                    TokenInterface(vaultDetails_.supplyToken), 
                    vaultAddress_, 
                    uint256(newCol_)
                );
            }
        }

        bool isPaybackMin_ = newDebt_ == type(int256).min;

        // Payback
        if (newDebt_ < 0) {
            if (vaultDetails_.borrowToken == getEthAddr()) {
                // Needs to be positive as it will be send in msg.value
                ethAmount_ = isPaybackMin_
                    ? repayApproveAmt_
                    : uint256(-newDebt_);
            } else {
                isPaybackMin_
                    ? approve(
                        TokenInterface(vaultDetails_.borrowToken), 
                        vaultAddress_, 
                        repayApproveAmt_
                    )
                    : approve(
                        TokenInterface(vaultDetails_.borrowToken), 
                        vaultAddress_, 
                        uint256(-newDebt_)
                    );
            }
        }

        // Note max withdraw will be handled by Fluid contract
        (nftId_, newCol_, newDebt_) = vault_.operate{value: ethAmount_}(
            nftId_,
            newCol_,
            newDebt_,
            address(this)
        );

        // Revoke supply approvals in case of deposit
        if (newCol_ > 0 && vaultDetails_.supplyToken != getEthAddr()) {
            approve(
                TokenInterface(vaultDetails_.supplyToken),
                vaultAddress_,
                0
            );
        }

        // Revoke borrow approvals in case of payback
        if (newDebt_ < 0 && vaultDetails_.borrowToken != getEthAddr()) {
            approve(
                TokenInterface(vaultDetails_.borrowToken),
                vaultAddress_,
                0
            );
        }

        _eventName = "LogOperate(address,uint256,int256,int256)";
        _eventParam = abi.encode(
            vaultAddress_,
            nftId_,
            newCol_,
            newDebt_
        );
    }
}

contract ConnectV2Fluid is FluidConnector {
    string public constant name = "Fluid-v1.3";
}
