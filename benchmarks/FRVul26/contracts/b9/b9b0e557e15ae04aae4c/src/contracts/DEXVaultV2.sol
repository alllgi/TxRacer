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
import "./interfaces/IDEXSpotVault.sol";

contract DEXVaultV2 is
    ReentrancyGuardUpgradeable,
    UUPSUpgradeable,
    OwnableUpgradeable,
    PausableUpgradeable
{
    using SafeERC20 for IERC20;

    // Events

    event Deposit(
        address indexed owner,
        address indexed receiver,
        address indexed token,
        uint256 amount
    );

    event Withdraw(
        address indexed owner,
        address sender,
        address indexed receiver,
        address indexed token,
        uint256 amount,
        uint256 requestId
    );

    event WithdrawLimitUpdate(
        address indexed token,
        uint256 oldLimit,
        uint256 newLimit
    );

    event DailyWithdrawLimitUpdate(
        address indexed token,
        uint256 oldLimit,
        uint256 newLimit
    );

    event SignersUpdate(address[] oldSigners, address[] newSigners);

    event TransferToSpotVault(
        address indexed token,
        uint256 amount,
        uint256 requestId
    );

    event WithdrawSpot(
        address indexed owner,
        address sender,
        address indexed receiver,
        address indexed token,
        uint256 amount,
        uint256 requestId
    );

    // Public fields
    address public USDT_ADDRESS; // USDT contract address
    address[] public signers; // The addresses that can co-sign transactions on the wallet

    // Mapping of request IDs to requests
    mapping(uint256 => request) requests;

    IERC20 private constant ZERO_ADDRESS = IERC20(address(0));

    // Mapping of token addresses to withdraw limits
    mapping(address => uint256) public tokenWithdrawLimit;

    // Mapping of token addresses to daily withdraw limits
    mapping(address => uint256) public dailyWithdrawLimit;

    // Mapping of token addresses to daily withdrawals
    mapping(address => uint256) public dailyWithdrawals;

    // Mapping of token addresses to last withdrawal timestamps
    mapping(address => uint256) public lastWithdrawalTimestamp;

    // version 2 
    address public spotVault;

    struct request {
        uint256 chainId; // The chain ID of the network the transaction was sent on
        address to; // The address the transaction was sent to
        uint256 amount; // Amount of Wei sent to the address
        address token; // The address of the ERC20 token contract, 0 means ETH
        bool executed; // If the request was executed
    }

    //  check if token is allowed
    modifier tokenWhitelist(address token) {
        require(tokenWithdrawLimit[token] > 0, "Token not allowed");
        _;
    }

    //  check if daily limit is exceeded
    modifier dailyLimitNotExceeded(address token, uint256 amount) {
        uint256 currentTimestamp = block.timestamp;
        if (currentTimestamp > lastWithdrawalTimestamp[token] + 1 days) {
            dailyWithdrawals[token] = 0;
            lastWithdrawalTimestamp[token] = currentTimestamp;
        }
        require(
            dailyWithdrawals[token] + amount <= dailyWithdrawLimit[token],
            "Daily withdrawal limit exceeded"
        );
        _;
    }
    /**
     * Set up a simple 2-3 multi-sig wallet by specifying the signers allowed to be used on this wallet.
     * 2 signers will be require to send a transaction from this wallet.
     * Note: The sender is NOT automatically added to the list of signers.
     *
     * @param allowedSigners      An array of signers on the wallet
     * @param usdt                The USDT contract address
     * @param _withdrawUSDTLimit   The maximum amount of USDT that can be withdrawn in a single transaction
     * @param _withdrawETHLimit   The maximum amount of ETH that can be withdrawn in a single transaction
     */
    function initialize(
        address[] memory allowedSigners,
        address usdt,
        uint256 _withdrawUSDTLimit,
        uint256 _withdrawETHLimit
    ) public initializer {
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        __Pausable_init();

        require(allowedSigners.length == 3, "invalid allSigners length");
        require(
            allowedSigners[0] != allowedSigners[1],
            "must be different signers"
        );
        require(
            allowedSigners[0] != allowedSigners[2],
            "must be different signers"
        );
        require(
            allowedSigners[1] != allowedSigners[2],
            "must be different signers"
        );
        require(usdt != address(0), "invalid usdt address");

        signers = allowedSigners;
        tokenWithdrawLimit[usdt] = _withdrawUSDTLimit;
        tokenWithdrawLimit[address(0)] = _withdrawETHLimit;
    }

    /**
     * @notice Make a eth deposit.
     *  Funds will be transferred from the sender and ETH will be deposited into this vault, and
     *  generate a deposit event.
     * @param  receiver       The receiver address to receive the funds.
     */

    function depositETH(
        address receiver
    ) public payable whenNotPaused nonReentrant {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        emit Deposit(msg.sender, receiver, address(0), msg.value);
    }

    /**
     * @notice Make a USDT deposit.
     *  Funds will be transferred from the sender and USDT will be deposited into this vault, and
     *  generate a deposit event.
     * @param  token         The token address .
     * @param  amount        The token amount.
     * @param  receiver      The receiver address to receive the funds.
     */

    function depositERC20(
        IERC20 token,
        uint256 amount,
        address receiver
    ) public tokenWhitelist(address(token)) whenNotPaused nonReentrant {
        require(amount > 0, "Deposit amount must be greater than zero");
        token.safeTransferFrom(msg.sender, address(this), amount);
        emit Deposit(msg.sender, receiver, address(token), amount);
    }

    /**
     * Withdraw ETHER from this wallet using 2 signers.
     *
     * @param  to         the destination address to send an outgoing transaction
     * @param  amount     the amount in Wei to be sent
     * @param  expireTime the number of seconds since 1970 for which this transaction is valid
     * @param  requestId  the unique request id
     * @param  allSigners all signers who sign the tx
     * @param  signatures the signatures of tx
     */
    function withdrawETH(
        address owner,
        address payable to,
        uint256 amount,
        uint256 expireTime,
        uint256 requestId,
        address[] memory allSigners,
        bytes[] memory signatures
    )
        public
        whenNotPaused
        nonReentrant
        dailyLimitNotExceeded(address(0), amount)
    {
      
        require(
            amount <= tokenWithdrawLimit[address(0)],
            "exceed withdraw  eth limit"
        );

        bytes32 operationHash = keccak256(
            abi.encodePacked(
                "ETHER",
                block.chainid,
                to,
                amount,
                expireTime,
                requestId,
                address(this)
            )
        );
        operationHash = MessageHashUtils.toEthSignedMessageHash(operationHash);

        checkSignaturesAndExpireTime(operationHash,expireTime, allSigners, signatures);

        // Try to insert the request ID. Will revert if the request id was invalid
        tryInsertRequestId(block.chainid, requestId, to, amount, address(0));

        // send ETHER
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        dailyWithdrawals[address(0)] += amount;

        (bool success, ) = to.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );

        emit Withdraw(owner, msg.sender, to, address(0), amount, requestId);
    }

    /**
     * Withdraw ERC20 from this wallet using 2 signers.
     *
     * @param  to         the destination address to send an outgoing transaction
     * @param  amount     the amount in Wei to be sent
     * @param  token      the address of the erc20 token contract
     * @param  expireTime the number of seconds since 1970 for which this transaction is valid
     * @param  requestId    the unique request id
     * @param  allSigners all signer who sign the tx
     * @param  signatures the signatures of tx
     */
    function withdrawERC20(
        address owner,
        address to,
        uint256 amount,
        address token,
        uint256 expireTime,
        uint256 requestId,
        address[] memory allSigners,
        bytes[] memory signatures
    )
        public
        whenNotPaused
        nonReentrant
        dailyLimitNotExceeded(address(token), amount)
    {
     
        require(tokenWithdrawLimit[token] > 0, "Token not allowed");

        require(amount <= tokenWithdrawLimit[token], "exceed withdraw  limit");

        bytes32 operationHash = keccak256(
            abi.encodePacked(
                "ERC20",
                block.chainid,
                to,
                amount,
                token,
                expireTime,
                requestId,
                address(this)
            )
        );
        operationHash = MessageHashUtils.toEthSignedMessageHash(operationHash);

        checkSignaturesAndExpireTime(operationHash,expireTime, allSigners, signatures);


        // Try to insert the request ID. Will revert if the request id was invalid
        tryInsertRequestId(block.chainid, requestId, to, amount, token);

        dailyWithdrawals[token] += amount;
        // Success, send ERC20 token
        IERC20(token).safeTransfer(to, amount);
        emit Withdraw(owner, msg.sender, to, token, amount, requestId);
    }

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

    // Allows Default Admin to pause the contract
    function pause() public onlyOwner {
        _pause();
    }

    // Allows Default Admin to unpause the contract
    function unpause() public onlyOwner {
        _unpause();
    }

    /**
     * Gets called when a transaction is received  without calling a method
     */
    receive() external payable {
        if (msg.value > 0) {
            depositETH(msg.sender);
        }
    }

    /**
     * Set token withdraw limit by owner
     * @param  token          the token address
     * @param  withdrawLimit   the amount withdraw limit , 0 means not allowed token
     */
    function setWithdrawLimit(
        address token,
        uint256 withdrawLimit
    ) external onlyOwner {
        uint256 oldLimit = tokenWithdrawLimit[token];

        tokenWithdrawLimit[token] = withdrawLimit;

        emit WithdrawLimitUpdate(token, oldLimit, withdrawLimit);
    }

    function setDailyWithdrawLimit(
        address token,
        uint256 _dailyWithdrawLimit
    ) external onlyOwner {
        uint256 oldLimit = dailyWithdrawLimit[token];

        dailyWithdrawLimit[token] = _dailyWithdrawLimit;

        emit DailyWithdrawLimitUpdate(token, oldLimit, _dailyWithdrawLimit);
    }

    // change signers by owner, update batch
    function changeSigners(address[] memory allowedSigners) external onlyOwner {
        address[] memory oldSigners = signers;

        require(allowedSigners.length == 3, "invalid allSigners length");
        require(
            allowedSigners[0] != allowedSigners[1],
            "must be different signers"
        );
        require(
            allowedSigners[0] != allowedSigners[2],
            "must be different signers"
        );
        require(
            allowedSigners[1] != allowedSigners[2],
            "must be different signers"
        );

        signers = allowedSigners;

        emit SignersUpdate(oldSigners, signers);
    }

    // override _authorizeUpgrade , uups
    function _authorizeUpgrade(address) internal override onlyOwner {}

    /**
     * Determine if an address is a signer on this wallet
     *
     * @param signer address to check
     */
    function isAllowedSigner(address signer) public view returns (bool) {
        // Iterate through all signers on the wallet and
        for (uint i = 0; i < signers.length; i++) {
            if (signers[i] == signer) {
                return true;
            }
        }
        return false;
    }
    /**
     * Get the signers of this vault
     */
    function getSigners() public view returns (address[] memory) {
        return signers;
    }

    /**
     * Verify that the request id has not been used before and inserts it. Throws if the request ID was not accepted.
     *
     * @param requestId   the unique request id
     * @param to        the destination address to send an outgoing transaction
     * @param amount     the amount in Wei to be sent
     * @param token     the address of the ERC20 contract
     */
    function tryInsertRequestId(
        uint256 chainId,
        uint256 requestId,
        address to,
        uint256 amount,
        address token
    ) internal {
        if (requests[requestId].executed) {
            // This request ID has been excuted before. Disallow!
            revert("repeated request");
        }
        requests[requestId].chainId = chainId;
        requests[requestId].executed = true;
        requests[requestId].to = to;
        requests[requestId].amount = amount;
        requests[requestId].token = token;
    }

    /**
     * calcSigHash is a helper function that to help you generate the sighash needed for withdrawal.
     *
     * @param to          the destination address
     * @param amount       the amount in Wei to be sent
     * @param token       the address of the ERC20 contract
     * @param expireTime  the number of seconds since 1970 for which this transaction is valid
     * @param requestId     the unique request id
     */

    function calcSigHash(
        address to,
        uint256 amount,
        address token,
        uint256 expireTime,
        uint256 requestId
    ) public view returns (bytes32) {
        bytes32 operationHash;

        if (token == address(0)) {
            operationHash = keccak256(
                abi.encodePacked(
                    "ETHER",
                    block.chainid,
                    to,
                    amount,
                    expireTime,
                    requestId,
                    address(this)
                )
            );
        } else {
            operationHash = keccak256(
                abi.encodePacked(
                    "ERC20",
                    block.chainid,
                    to,
                    amount,
                    token,
                    expireTime,
                    requestId,
                    address(this)
                )
            );
        }
        return operationHash;
    }

    function getTokenWithdrawLimit(
        address token
    ) public view returns (uint256) {
        return tokenWithdrawLimit[token];
    }

    function getRequestInfo(
        uint256 requestId
    ) public view returns (request memory) {
        return requests[requestId];
    }

    function depositWithPermit(
        address owner,
        address token,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public tokenWhitelist(address(token)) whenNotPaused nonReentrant {
        require(amount > 0, "Deposit amount must be greater than zero");

        IERC20Permit(token).permit(
            owner,
            address(this),
            amount,
            deadline,
            v,
            r,
            s
        );

        IERC20(token).safeTransferFrom(owner, address(this), amount);

        emit Deposit(owner, owner, token, amount);
    }





    // version 2 function -------------------------------------------

     function withdrawERC20FromSpot( 
        address owner,
        address to,
        uint256 amount,
        address token,
        uint256 expireTime,
        uint256 requestId,
        address[] memory allSigners,
        bytes[] memory signatures)  public
        whenNotPaused
        nonReentrant {

        checkWithdrawSignatures(owner, to , amount , token , expireTime, requestId, allSigners, signatures); 

        ISpotVault(spotVault).withdrawERC20(owner, to, amount, token);

        emit WithdrawSpot(owner, msg.sender, to, token, amount, requestId);    
     }


     function checkWithdrawSignatures(  
        address owner,
        address to,
        uint256 amount,
        address token,
        uint256 expireTime,
        uint256 requestId,
        address[] memory allSigners,
        bytes[] memory signatures) internal  {

       
        bytes32 operationHash = keccak256(
            abi.encodePacked(
                "ERC20",
                block.chainid,
                owner,
                to,
                amount,
                token,
                expireTime,
                requestId,
                address(this)
            )
        );
        operationHash = MessageHashUtils.toEthSignedMessageHash(operationHash);

        checkSignaturesAndExpireTime(operationHash, expireTime, allSigners, signatures);   
        // Try to insert the request ID. Will revert if the request id was invalid
        tryInsertRequestId(block.chainid, requestId, to, amount, token);

     }




     function checkSignaturesAndExpireTime(
        bytes32 operationHash,
        uint256 expireTime,
        address[] memory allSigners,
        bytes[] memory signatures) internal view {

        require(allSigners.length >= 2, "invalid allSigners length");
        require(
            allSigners.length == signatures.length,
            "invalid signatures length"
        );
        require(allSigners[0] != allSigners[1], "can not be same signer"); // must be different signer
        require(expireTime >= block.timestamp, "expired transaction");

       
        for (uint8 index = 0; index < allSigners.length; index++) {
            address signer = ECDSA.recover(operationHash, signatures[index]);
            require(signer == allSigners[index], "invalid signer");
            require(isAllowedSigner(signer), "not allowed signer");
        }
        
     }
    


    /**
     * Set the address of the spot vault
     *
     * @param _spotVault The address of the new spot vault
     */
    function setSpotVault(address _spotVault) external onlyOwner {
        require(_spotVault != address(0), "Invalid spot vault address");
        spotVault = _spotVault;
    }
 

}
