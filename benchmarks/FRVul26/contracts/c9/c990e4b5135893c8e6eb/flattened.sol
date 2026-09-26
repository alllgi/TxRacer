// Sources retrieved from Sourcify API v2.
// Deterministic best-effort flattening; original files are preserved under src/.

// File: IDogecoin.sol

pragma solidity ^0.8.0;

struct JoinPartyInstruction
{
    uint256 amount;
    uint256 instructionId;
    address to;
    uint8 v;
    bytes32 r;
    bytes32 s;
}

interface IDogecoin
{
    event DogeCrossingBridge(address indexed controller, uint256 amount);
    event DogeJoinedTheParty(uint256 indexed instructionId, address indexed recipient, uint256 amount);
    event Minter(address indexed minter, bool canMint);

    function instructionFulfilled(uint256 _instructionId) external view returns (bool);
    function minters(address _minter) external view returns (bool);

    function joinParty(address _to, uint256 _amount, uint256 _instructionId, uint8 _v, bytes32 _r, bytes32 _s) external;
    function multiJoinParty(JoinPartyInstruction[] calldata _instructions) external;
    function crossBridge(address _controller, uint256 _amount) external;
}

// File: Dogecoin.sol

pragma solidity ^0.8.0;





contract Dogecoin is ERC20("Dogecoin", "DOGE", 8), SafelyOwned, IDogecoin
{
    string public constant url = "https://doge.gay";

    mapping (uint256 => bool) public override instructionFulfilled;
    mapping (address => bool) public override minters;

    bytes32 private constant joinPartyTypeHash = keccak256("JoinParty(address to,uint256 amount,uint256 instructionId)");

    function setMinter(address _minter, bool _canMint) public ownerOnly()
    {
        minters[_minter] = _canMint;
        emit Minter(_minter, _canMint);
    }
    
    function joinParty(address _to, uint256 _amount, uint256 _instructionId, uint8 _v, bytes32 _r, bytes32 _s) public override
    {
        require (!instructionFulfilled[_instructionId], "Instruction already fulfilled");
        bytes32 hash = getSigningHash(keccak256(abi.encode(joinPartyTypeHash, _to, _amount, _instructionId)));
        address signer = ecrecover(hash, _v, _r, _s);
        require(minters[signer], "Not signed by a minter");

        mintCore(_to, _amount);
        
        instructionFulfilled[_instructionId] = true;
        emit DogeJoinedTheParty(_instructionId, _to, _amount);
    }

    function multiJoinParty(JoinPartyInstruction[] calldata _instructions) public override
    {
        uint256 len = _instructions.length;
        bool anySuccess = false;

        for (uint256 x=0; x<len; ++x) {
            uint256 instructionId = _instructions[x].instructionId;
            if (instructionFulfilled[instructionId]) { continue; }

            address to = _instructions[x].to;
            uint256 amount = _instructions[x].amount;
            bytes32 hash = getSigningHash(keccak256(abi.encode(joinPartyTypeHash, to, amount, instructionId)));
            address signer = ecrecover(hash, _instructions[x].v, _instructions[x].r, _instructions[x].s);
            if (!minters[signer]) { continue; }

            mintCore(to, amount);

            instructionFulfilled[instructionId] = true;
            anySuccess = true;
            emit DogeJoinedTheParty(instructionId, to, amount);
        }
        require (anySuccess, "No success");
    }

    function crossBridge(address _controller, uint256 _amount) public override
    {
        burnCore(msg.sender, _amount);
        emit DogeCrossingBridge(_controller, _amount);
    }

    function transfer(address _to, uint256 _amount) public override returns (bool)
    {
        if (_to == address(this)) {
            crossBridge(msg.sender, _amount);
            return true;
        }
        return super.transfer(_to, _amount);
    }

    function transferFrom(address _from, address _to, uint256 _amount) public override returns (bool)
    {
        require(_to != address(this), "Use crossBridge() or transfer() to transfer DOGE back to the bridge");
        return super.transferFrom(_from, _to, _amount);
    }
}

// File: Address.sol

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address 
{
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.3._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.3._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// File: IERC20.sol

pragma solidity ^0.8.0;

interface IERC20
{
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function totalSupply() external view returns (uint256);
    function balanceOf(address _account) external view returns (uint256);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function nonces(address _owner) external view returns (uint256);

    function approve(address _spender, uint256 _amount) external returns (bool);
    function transfer(address _to, uint256 _amount) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);
    function increaseAllowance(address _spender, uint256 _toAdd) external returns (bool);
    function decreaseAllowance(address _spender, uint256 _toRemove) external returns (bool);
    function burn(uint256 _amount) external;
    function permit(address _owner, address _spender, uint256 _amount, uint256 _deadline, uint8 _v, bytes32 _r, bytes32 _s) external;
}

// File: ERC20.sol

pragma solidity ^0.8.0;



abstract contract ERC20 is IERC20
{
    string public override name;
    string public override symbol;
    uint8 public immutable override decimals;

    uint256 public override totalSupply;
    mapping (address => uint256) public override balanceOf;
    mapping (address => mapping(address => uint256)) public override allowance;
    mapping (address => uint256) public override nonces;

    bytes32 private immutable cachedDomainSeparator;
    uint256 private immutable cachedChainId = block.chainid;
    bytes32 private constant permitTypeHash = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 private constant eip712DomainHash = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    bytes32 private constant versionDomainHash = keccak256(bytes("1"));
    bytes32 private immutable nameDomainHash;

    constructor(string memory _name, string memory _symbol, uint8 _decimals)
    {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        bytes32 _nameDomainHash = keccak256(bytes(_name));
        nameDomainHash = _nameDomainHash;
        cachedDomainSeparator = keccak256(abi.encode(
            eip712DomainHash,
            _nameDomainHash,
            versionDomainHash,
            block.chainid,
            address(this)));
    }

    function approveCore(address _owner, address _spender, uint256 _amount) internal virtual returns (bool)
    {
        allowance[_owner][_spender] = _amount;
        emit Approval(_owner, _spender, _amount);
        return true;
    }

    function approve(address _spender, uint256 _amount) public virtual override returns (bool)
    {
        return approveCore(msg.sender, _spender, _amount);
    }

    function increaseAllowance(address _spender, uint256 _toAdd) public virtual override returns (bool)
    {
        return approve(_spender, allowance[msg.sender][_spender] + _toAdd);
    }
    
    function decreaseAllowance(address _spender, uint256 _toRemove) public virtual override returns (bool)
    {
        return approve(_spender, allowance[msg.sender][_spender] - _toRemove);
    }

    function transfer(address _to, uint256 _amount) public virtual override returns (bool)
    {
        return transferCore(msg.sender, _to, _amount);
    }

    function transferFrom(address _from, address _to, uint256 _amount) public virtual override returns (bool)
    {
        uint256 oldAllowance = allowance[_from][msg.sender];
        require (oldAllowance >= _amount, "Insufficient allowance");
        if (oldAllowance != type(uint256).max) {
            allowance[_from][msg.sender] = oldAllowance - _amount;
        }
        return transferCore(_from, _to, _amount);
    }

    function transferCore(address _from, address _to, uint256 _amount) internal virtual returns (bool)
    {
        require (_from != address(0));
        if (_to == address(0)) {
            burnCore(_from, _amount);
            return true;
        }
        uint256 oldBalance = balanceOf[_from];
        require (oldBalance >= _amount, "Insufficient balance");
        balanceOf[_from] = oldBalance - _amount;
        balanceOf[_to] += _amount;
        emit Transfer(_from, _to, _amount);
        return true;
    }

    function mintCore(address _to, uint256 _amount) internal virtual
    {
        require (_to != address(0));

        totalSupply += _amount;
        balanceOf[_to] += _amount;
        emit Transfer(address(0), _to, _amount);
    }

    function burnCore(address _from, uint256 _amount) internal virtual
    {
        uint256 oldBalance = balanceOf[_from];
        require (oldBalance >= _amount, "Insufficient balance");
        balanceOf[_from] = oldBalance - _amount;
        totalSupply -= _amount;
        emit Transfer(_from, address(0), _amount);
    }

    function burn(uint256 _amount) public override
    {
        burnCore(msg.sender, _amount);
    }

    function DOMAIN_SEPARATOR() public override view returns (bytes32) 
    {
        if (block.chainid == cachedChainId) {
            return cachedDomainSeparator;
        }
        return keccak256(abi.encode(
            eip712DomainHash,
            nameDomainHash,
            versionDomainHash,
            block.chainid,
            address(this)));
    }

    function getSigningHash(bytes32 _dataHash) internal view returns (bytes32) 
    {
        return keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR(), _dataHash));
    }

    function permit(address _owner, address _spender, uint256 _amount, uint256 _deadline, uint8 _v, bytes32 _r, bytes32 _s) public virtual override
    {
        require (block.timestamp <= _deadline, "Deadline expired");

        uint256 nonce = nonces[_owner];
        bytes32 hash = getSigningHash(keccak256(abi.encode(permitTypeHash, _owner, _spender, _amount, nonce, _deadline)));
        address signer = ecrecover(hash, _v, _r, _s);
        require (signer == _owner, "Invalid signature");
        nonces[_owner] = nonce + 1;
        approveCore(_owner, _spender, _amount);
    }
}

// File: ISafelyOwned.sol

pragma solidity ^0.8.0;



interface ISafelyOwned
{
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() external view returns (address);

    function transferOwnership(address _newOwner) external;
    function claimOwnership() external;
    function recoverTokens(IERC20 _token) external;
    function recoverETH() external;
}

// File: SafeERC20.sol

pragma solidity ^0.8.0;




/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 
{
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {        
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: SafelyOwned.sol

pragma solidity ^0.8.0;




abstract contract SafelyOwned is ISafelyOwned
{
    using SafeERC20 for IERC20;
    
    address public override owner = msg.sender;
    address internal pendingOwner;

    modifier ownerOnly()
    {
        require (msg.sender == owner, "Owner only");
        _;
    }

    function transferOwnership(address _newOwner) public override ownerOnly()
    {
        pendingOwner = _newOwner;
    }

    function claimOwnership() public override
    {
        require (pendingOwner == msg.sender);
        pendingOwner = address(0);
        emit OwnershipTransferred(owner, msg.sender);
        owner = msg.sender;
    }

    function recoverTokens(IERC20 _token) public override ownerOnly() 
    {
        require (canRecoverTokens(_token));
        _token.safeTransfer(msg.sender, _token.balanceOf(address(this)));
    }

    function canRecoverTokens(IERC20 _token) internal virtual view returns (bool) 
    { 
        return address(_token) != address(this); 
    }

    function recoverETH() public override ownerOnly()
    {
        require (canRecoverETH());
        (bool success,) = msg.sender.call{ value: address(this).balance }("");
        require (success, "Transfer fail");
    }

    function canRecoverETH() internal virtual view returns (bool) 
    {
        return true;
    }
}
