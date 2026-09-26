// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "./interfaces/IDEXVault.sol";

contract DEXSpotVault is
    ReentrancyGuardUpgradeable,
    UUPSUpgradeable,
    OwnableUpgradeable,
    PausableUpgradeable
{
    using SafeERC20 for IERC20;

  // Public fields
    address public AGGREGATION_ROUTER_ADDRESS; //1inch AggregationRouterV6 address
    address public VAULT_ADDRESS; //   dex vault address

    event Withdraw(
        address indexed owner,
        address sender,
        address indexed token,
        uint256 amount
    );

    event Swap(
        address indexed owner,
        uint256 requestId,
        address indexed tokenIn,
        uint256 amountIn,
        address indexed tokenOut,
        uint256 amountOut
    );

    mapping(uint256 => bool) private usedRequestIds;


    modifier onlyVault() {
        require(msg.sender == VAULT_ADDRESS, "Caller is not the vault");
        _;
    }

     modifier validSigner() {
        require(isSigner(msg.sender), "Caller is not a valid signer");
        _;
    }

    function initialize(
         address _vaultAddress,
         address _aggregationRouterV6,
        address  _owner
    ) public initializer {
        __Ownable_init(_owner);
        __UUPSUpgradeable_init();
        __Pausable_init();
        AGGREGATION_ROUTER_ADDRESS = _aggregationRouterV6;
        VAULT_ADDRESS = _vaultAddress;
    }

// spot swap , weth return   todo authority

 function spotSwap(
        address owner,
        uint256 requestId,
        address tokenIn,
        uint256 amountIn,
        address tokenOut,
        uint256 minReturnAmount,
        bytes calldata exchangeData
    ) public  nonReentrant  validSigner {


        //check requestId
        require(checkRequestId(requestId), "invalid request id");

        require(IERC20(tokenIn).balanceOf(address(this)) >= amountIn, "vault has not enough token");

        uint256 amountOut = swap(
            tokenIn,
            amountIn,
            tokenOut,
            minReturnAmount,
            exchangeData
        );
       
        emit Swap(
            owner,
            requestId,
            tokenIn,
            amountIn,
            tokenOut,
            amountOut
        );
    }


    function swap(
        address tokenIn,
        uint256 amountIn,
        address tokenOut,
        uint256 minReturnAmount,
        bytes calldata exchangeData
    ) internal returns (uint256 returnAmount) {
     
        uint256 beforeSwapBalance = IERC20(tokenOut).balanceOf(
            address(this)
        );
        
        IERC20(tokenIn).safeIncreaseAllowance(
                AGGREGATION_ROUTER_ADDRESS,
                amountIn
            );

        // Swap token
        (bool success, ) = AGGREGATION_ROUTER_ADDRESS
            .call(exchangeData);

        require(success, "exchange failed");

        uint256 afterSwapBalance = IERC20(tokenOut).balanceOf(
            address(this)
        );
    
        require(
            afterSwapBalance > beforeSwapBalance,
            "received  token less than 0"
        );

        returnAmount = afterSwapBalance - beforeSwapBalance;

        require(
            returnAmount >= minReturnAmount,
            "received token less than minReturnAmount"
        );
        return returnAmount;
    }


   

    /**
     * Withdraw ERC20 from this wallet 
     *
     * @param  to         the destination address to send an outgoing transaction
     * @param  amount     the amount in Wei to be sent
     * @param  token      the address of the erc20 token contract
     */
    function withdrawERC20(
        address owner,
        address to,
        uint256 amount,
        address token
    )
        public onlyVault nonReentrant
      
    {
        // Success, send ERC20 token
        IERC20(token).safeTransfer(to, amount);
        emit Withdraw(owner, to, token, amount );
    }



//-------------------------------governence
    /**
     * For emergency exit ,owner must be gnosis safe wallet
     * @param  token      the address of the erc20 token contract
     * @param  to         the destination address to send an outgoing transaction
     * @param  amount     the amount
     */
    function withdrawERC20TokenByOwner(
        address token,
        address to,
        uint256 amount
    ) external onlyOwner nonReentrant returns (bool) {
        uint256 balance = IERC20(token).balanceOf(address(this));
        require(balance >= amount, "NOT_ENOUGH_BALANCE");
        IERC20(token).safeTransfer(to, amount);
        return true;
    }

    /**
     * For emergency exit ,owner must be gnosis safe wallet
     *
     * @param  to         the destination address to send an outgoing transaction
     * @param  amount     the amount  in wei
     */
    function withdrawETHByOwner(
        address to,
        uint256 amount
    ) external onlyOwner nonReentrant returns (bool) {
        uint256 balance = address(this).balance;
        require(balance >= amount, "NOT_ENOUGH_BALANCE");
        payable(to).transfer(address(this).balance);
        return true;
    }


    function setVault(address _dexVault) external onlyOwner {
        require(_dexVault != address(0), "Invalid vault address");
        VAULT_ADDRESS = _dexVault;
    }

    // Allows Default Admin to pause the contract
    function pause() public onlyOwner {
        _pause();
    }

    // Allows Default Admin to unpause the contract
    function unpause() public onlyOwner {
        _unpause();
    }

  
   
    // override _authorizeUpgrade , uups
    function _authorizeUpgrade(address) internal override onlyOwner {}

    function checkRequestId(uint256 requestId) internal returns (bool) {
        if (usedRequestIds[requestId]) {
            return false; // Request ID has already been used
        }
        usedRequestIds[requestId] = true; // Mark this request ID as used
        return true;
    }

    function isSigner(address account) internal view returns (bool) {
        address[] memory signers = IDEXVault(VAULT_ADDRESS).getSigners();
        for (uint256 i = 0; i < signers.length; i++) {
            if (signers[i] == account) {
                return true;
            }
        }
        return false;
    }
}
