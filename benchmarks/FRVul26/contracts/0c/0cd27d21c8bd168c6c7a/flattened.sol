// Sources retrieved from Sourcify API v2.
// Deterministic best-effort flattening; original files are preserved under src/.

// File: IERC20.sol

pragma solidity ^0.5.8;

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: ERC20Detailed.sol

pragma solidity ^0.5.8;



/**
 * @title ERC20Detailed token
 * @dev The decimals are only for visualization purposes.
 * All the operations are done using the smallest and indivisible token unit,
 * just as on Ethereum all the operations are done in wei.
 */
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @return the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @return the symbol of the token.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @return the number of decimals of the token.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

// File: SafeMath.sol

pragma solidity ^0.5.8;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

// File: ERC20.sol

pragma solidity ^0.5.8;




/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood:
 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 *
 * This implementation emits additional Approval events, allowing applications to reconstruct the allowance status for
 * all accounts just by listening to said events. Note that this isn't required by the specification, and other
 * compliant implementations may not do it.
 */
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowed;

    uint256 private _totalSupply;

    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param owner The address to query the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    /**
    * @dev Transfer token for a specified address
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another.
     * Note that while this function emits an Approval event, this is not required as per the specification,
     * and other compliant implementations may not emit the event.
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _transfer(from, to, value);
        _approve(from, msg.sender, _allowed[from][msg.sender].sub(value));
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    /**
    * @dev Transfer token for a specified addresses
    * @param from The address to transfer from.
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    /**
     * @dev Internal function that mints an amount of the token and assigns it to
     * an account. This encapsulates the modification of balances such that the
     * proper events are emitted.
     * @param account The account that will receive the created tokens.
     * @param value The amount that will be created.
     */
    function _mint(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account.
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Approve an address to spend another addresses' tokens.
     * @param owner The address that owns the tokens.
     * @param spender The address that will spend the tokens.
     * @param value The number of tokens that can be spent.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        require(spender != address(0));
        require(owner != address(0));

        _allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account, deducting from the sender's allowance for said account. Uses the
     * internal burn function.
     * Emits an Approval event (reflecting the reduced allowance).
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burnFrom(address account, uint256 value) internal {
        _burn(account, value);
        _approve(account, msg.sender, _allowed[account][msg.sender].sub(value));
    }
}

// File: ERC20Burnable.sol

pragma solidity ^0.5.8;



/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract ERC20Burnable is ERC20 {
    /**
     * @dev Burns a specific amount of tokens.
     * @param value The amount of token to be burned.
     */
    function burn(uint256 value) public {
        _burn(msg.sender, value);
    }

    /**
     * @dev Burns a specific amount of tokens from the target address and decrements allowance
     * @param from address The address which you want to send tokens from
     * @param value uint256 The amount of token to be burned
     */
    function burnFrom(address from, uint256 value) public {
        _burnFrom(from, value);
    }
}

// File: Ownable.sol

pragma solidity ^0.5.8;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: SoraToken.sol

pragma solidity ^0.5.8;





contract SoraToken is ERC20Burnable, ERC20Detailed, Ownable {

    uint256 public constant INITIAL_SUPPLY = 0;

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor() public ERC20Detailed("Sora Token", "XOR", 18) {
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    function mintTokens(address beneficiary, uint256 amount) public onlyOwner {
        _mint(beneficiary, amount);
    }

}

// File: BasicToken.sol

//! The basic-coin ECR20-compliant token contract.
//!
//! Copyright 2016 Gavin Wood, Parity Technologies Ltd.
//!
//! Licensed under the Apache License, Version 2.0 (the "License");
//! you may not use this file except in compliance with the License.
//! You may obtain a copy of the License at
//!
//!     http://www.apache.org/licenses/LICENSE-2.0
//!
//! Unless required by applicable law or agreed to in writing, software
//! distributed under the License is distributed on an "AS IS" BASIS,
//! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//! See the License for the specific language governing permissions and
//! limitations under the License.

pragma solidity ^0.5.8;

contract Owned {
	modifier only_owner { require(msg.sender == owner); _; }

	event NewOwner(address indexed old, address indexed current);

    function setOwner(address _new) only_owner public { emit NewOwner(owner, _new); owner = _new; }

	address public owner = msg.sender;
}

interface Token {
	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);

	function balanceOf(address _owner) view external returns (uint256 balance);
	function transfer(address _to, uint256 _value) external returns (bool success);
	function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
	function approve(address _spender, uint256 _value) external returns (bool success);
	function allowance(address _owner, address _spender) view external returns (uint256 remaining);
}

// TokenReg interface
contract TokenReg {
	function register(address _addr, string memory _tla, uint _base, string memory _name) public payable returns (bool);
	function registerAs(address _addr, string memory _tla, uint _base, string memory _name, address _owner) public payable returns (bool);
	function unregister(uint _id) public;
	function setFee(uint _fee) public;
	function tokenCount() public view returns (uint);
	function token(uint _id) public view returns (address addr, string memory tla, uint base, string memory name, address owner);
	function fromAddress(address _addr) public view returns (uint id, string memory tla, uint base, string memory name, address owner);
	function fromTLA(string memory _tla) public view returns (uint id, address addr, uint base, string memory name, address owner);
	function meta(uint _id, bytes32 _key) public view returns (bytes32);
	function setMeta(uint _id, bytes32 _key, bytes32 _value) public;
	function drain() public;
	uint public fee;
}

// BasicCoin, ECR20 tokens that all belong to the owner for sending around
contract BasicCoin is Owned, Token {
	// this is as basic as can be, only the associated balance & allowances
	struct Account {
		uint balance;
		mapping (address => uint) allowanceOf;
	}

	// the balance should be available
	modifier when_owns(address _owner, uint _amount) {
		if (accounts[_owner].balance < _amount) revert();
		_;
	}

	// an allowance should be available
	modifier when_has_allowance(address _owner, address _spender, uint _amount) {
		if (accounts[_owner].allowanceOf[_spender] < _amount) revert();
		_;
	}



	// a value should be > 0
	modifier when_non_zero(uint _value) {
		if (_value == 0) revert();
		_;
	}

	bool public called = false;

	// the base, tokens denoted in micros
	uint constant public base = 1000000;

	// available token supply
	uint public totalSupply;

	// storage and mapping of all balances & allowances
	mapping (address => Account) accounts;

	// constructor sets the parameters of execution, _totalSupply is all units
	constructor(uint _totalSupply, address _owner) public   when_non_zero(_totalSupply) {
		totalSupply = _totalSupply;
		owner = _owner;
		accounts[_owner].balance = totalSupply;
	}

	// balance of a specific address
	function balanceOf(address _who) public view returns (uint256) {
		return accounts[_who].balance;
	}

	// transfer
	function transfer(address _to, uint256 _value) public   when_owns(msg.sender, _value) returns (bool) {
		emit Transfer(msg.sender, _to, _value);
		accounts[msg.sender].balance -= _value;
		accounts[_to].balance += _value;

		return true;
	}

	// transfer via allowance
	function transferFrom(address _from, address _to, uint256 _value) public   when_owns(_from, _value) when_has_allowance(_from, msg.sender, _value) returns (bool) {
		called = true;
		emit Transfer(_from, _to, _value);
		accounts[_from].allowanceOf[msg.sender] -= _value;
		accounts[_from].balance -= _value;
		accounts[_to].balance += _value;

		return true;
	}

	// approve allowances
	function approve(address _spender, uint256 _value) public   returns (bool) {
		emit Approval(msg.sender, _spender, _value);
		accounts[msg.sender].allowanceOf[_spender] += _value;

		return true;
	}

	// available allowance
	function allowance(address _owner, address _spender) public view returns (uint256) {
		return accounts[_owner].allowanceOf[_spender];
	}

	// no default function, simple contract only, entry-level users
	function() external {
		revert();
	}
}

// Manages BasicCoin instances, including the deployment & registration
contract BasicCoinManager is Owned {
	// a structure wrapping a deployed BasicCoin
	struct Coin {
		address coin;
		address owner;
		address tokenreg;
	}

	// a new BasicCoin has been deployed
	event Created(address indexed owner, address indexed tokenreg, address indexed coin);

	// a list of all the deployed BasicCoins
	Coin[] coins;

	// all BasicCoins for a specific owner
	mapping (address => uint[]) ownedCoins;

	// the base, tokens denoted in micros (matches up with BasicCoin interface above)
	uint constant public base = 1000000;

	// return the number of deployed
	function count() public view returns (uint) {
		return coins.length;
	}

	// get a specific deployment
	function get(uint _index) public view returns (address coin, address owner, address tokenreg) {
		Coin memory c = coins[_index];

		coin = c.coin;
		owner = c.owner;
		tokenreg = c.tokenreg;
	}

	// returns the number of coins for a specific owner
	function countByOwner(address _owner) public view returns (uint) {
		return ownedCoins[_owner].length;
	}

	// returns a specific index by owner
	function getByOwner(address _owner, uint _index) public view returns (address coin, address owner, address tokenreg) {
		return get(ownedCoins[_owner][_index]);
	}

	// deploy a new BasicCoin on the blockchain
	function deploy(uint _totalSupply, string memory _tla, string memory _name, address _tokenreg) public payable returns (bool) {
		TokenReg tokenreg = TokenReg(_tokenreg);
		BasicCoin coin = new BasicCoin(_totalSupply, msg.sender);

		uint ownerCount = countByOwner(msg.sender);
		uint fee = tokenreg.fee();

		ownedCoins[msg.sender].length = ownerCount + 1;
		ownedCoins[msg.sender][ownerCount] = coins.length;
		coins.push(Coin(address(coin), msg.sender, address(tokenreg)));
		tokenreg.registerAs.value(fee)(address(coin), _tla, base, _name, msg.sender);

		emit Created(msg.sender, address(tokenreg), address(coin));

		return true;
	}

	// owner can withdraw all collected funds
	function drain() public only_owner {
		if (!msg.sender.send(address(this).balance)) {
			revert();
		}
	}
}

// File: Failer.sol

pragma solidity ^0.5.8;

/**
 * Contract for revert cases testing
 */
contract Failer {
    /**
     * A special function-like stub to allow ether accepting. Always fails.
     */
    function() external payable {
        revert("eth transfer revert");
    }

    /**
     * Fake ERC-20 transfer function. Always fails.
     */
    function transfer(address, uint256) external pure {
        revert("ERC-20 transfer revert");
    }
}

// File: IMaster.sol

pragma solidity ^0.5.8;

/**
 * Subset of master contract interface
 */
contract IMaster {
    function withdraw(
        address tokenAddress,
        uint256 amount,
        address to,
        bytes32 txHash,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s,
        address from
    )
    public;

    function mintTokensByPeers(
        address tokenAddress,
        uint256 amount,
        address beneficiary,
        bytes32 txHash,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s,
        address from
    )
    public;

    function checkTokenAddress(address token) public view returns (bool);
}

// File: IRelayRegistry.sol

pragma solidity ^0.5.8;

/**
 * @title Relay registry interface
 */
interface IRelayRegistry {

    /**
     * Store relay address and appropriate whitelist of addresses
     * @param relay contract address
     * @param whiteList with allowed addresses
     * @return true if data was stored
     */
    function addNewRelayAddress(address relay, address[] calldata whiteList) external;

    /**
     * Check if some address is in the whitelist
     * @param relay contract address
     * @param who address in whitelist
     * @return true if address in the whitelist
     */
    function isWhiteListed(address relay, address who) external view returns (bool);

    /**
     * Get entire whitelist by relay address
     * @param relay contract address
     * @return array of the whitelist
     */
    function getWhiteListByRelay(address relay) external view returns (address[] memory);

    event AddNewRelay (
        address indexed relayAddress,
        address[] indexed whiteList
    );
}

// File: Master.sol

pragma solidity ^0.5.8;




/**
 * Provides functionality of master contract
 */
contract Master {
    bool internal initialized_;
    address public owner_;
    mapping(address => bool) public isPeer;
    uint public peersCount;
    /** Iroha tx hashes used */
    mapping(bytes32 => bool) public used;
    mapping(address => bool) public uniqueAddresses;

    /** registered client addresses */
    mapping(address => bytes) public registeredClients;

    SoraToken public xorTokenInstance;

    mapping(address => bool) public isToken;

    /**
     * Emit event on new registration with iroha acountId
     */
     event IrohaAccountRegistration(address ethereumAddress, bytes accountId);

    /**
     * Emit event when master contract does not have enough assets to proceed withdraw
     */
    event InsufficientFundsForWithdrawal(address asset, address recipient);

    /**
     * Constructor. Sets contract owner to contract creator.
     */
    constructor(address[] memory initialPeers) public {
        initialize(msg.sender, initialPeers);
    }

    /**
     * Initialization of smart contract.
     */
    function initialize(address owner, address[] memory initialPeers) public {
        require(!initialized_);

        owner_ = owner;
        for (uint8 i = 0; i < initialPeers.length; i++) {
            addPeer(initialPeers[i]);
        }

        // 0 means ether which is definitely in whitelist
        isToken[address(0)] = true;

        // Create new instance of Sora token
        xorTokenInstance = new SoraToken();
        isToken[address(xorTokenInstance)] = true;

        initialized_ = true;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns(bool) {
        return msg.sender == owner_;
    }

    /**
     * A special function-like stub to allow ether accepting
     */
    function() external payable {
        require(msg.data.length == 0);
    }

    /**
     * Adds new peer to list of signature verifiers. Can be called only by contract owner.
     * @param newAddress address of new peer
     */
    function addPeer(address newAddress) private returns (uint) {
        require(isPeer[newAddress] == false);
        isPeer[newAddress] = true;
        ++peersCount;
        return peersCount;
    }

    function removePeer(address peerAddress) private {
        require(isPeer[peerAddress] == true);
        isPeer[peerAddress] = false;
        --peersCount;
    }

    function addPeerByPeer(
        address newPeerAddress,
        bytes32 txHash,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s
    )
    public returns (bool)
    {
        require(used[txHash] == false);
        require(checkSignatures(keccak256(abi.encodePacked(newPeerAddress, txHash)),
            v,
            r,
            s)
        );

        addPeer(newPeerAddress);
        used[txHash] = true;
        return true;
    }

    function removePeerByPeer(
        address peerAddress,
        bytes32 txHash,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s
    )
    public returns (bool)
    {
        require(used[txHash] == false);
        require(checkSignatures(
            keccak256(abi.encodePacked(peerAddress, txHash)),
            v,
            r,
            s)
        );

        removePeer(peerAddress);
        used[txHash] = true;
        return true;
    }

    /**
     * Adds new token to whitelist. Token should not been already added.
     * @param newToken token to add
     */
    function addToken(address newToken) public onlyOwner {
        require(isToken[newToken] == false);
        isToken[newToken] = true;
    }

    /**
     * Checks is given token inside a whitelist or not
     * @param tokenAddress address of token to check
     * @return true if token inside whitelist or false otherwise
     */
    function checkTokenAddress(address tokenAddress) public view returns (bool) {
        return isToken[tokenAddress];
    }

    /**
     * Register a clientIrohaAccountId for the caller clientEthereumAddress
     * @param clientEthereumAddress - ethereum address to register
     * @param clientIrohaAccountId - iroha account id
     * @param txHash - iroha tx hash of registration
     * @param v array of signatures of tx_hash (v-component)
     * @param r array of signatures of tx_hash (r-component)
     * @param s array of signatures of tx_hash (s-component)
     */
    function register(
        address clientEthereumAddress,
        bytes memory clientIrohaAccountId,
        bytes32 txHash,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s
    )
    public
    {
        require(used[txHash] == false);
        require(checkSignatures(
                    keccak256(abi.encodePacked(clientEthereumAddress, clientIrohaAccountId, txHash)),
                    v,
                    r,
                    s)
                );
        require(clientEthereumAddress == msg.sender);
        require(registeredClients[clientEthereumAddress].length == 0);

        registeredClients[clientEthereumAddress] = clientIrohaAccountId;

        emit IrohaAccountRegistration(clientEthereumAddress, clientIrohaAccountId);
    }

    /**
     * Withdraws specified amount of ether or one of ERC-20 tokens to provided address
     * @param tokenAddress address of token to withdraw (0 for ether)
     * @param amount amount of tokens or ether to withdraw
     * @param to target account address
     * @param txHash hash of transaction from Iroha
     * @param v array of signatures of tx_hash (v-component)
     * @param r array of signatures of tx_hash (r-component)
     * @param s array of signatures of tx_hash (s-component)
     * @param from relay contract address
     */
    function withdraw(
        address tokenAddress,
        uint256 amount,
        address payable to,
        bytes32 txHash,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s,
        address from
    )
    public
    {
        require(checkTokenAddress(tokenAddress));
        require(used[txHash] == false);
        require(checkSignatures(
            keccak256(abi.encodePacked(tokenAddress, amount, to, txHash, from)),
            v,
            r,
            s)
        );

        if (tokenAddress == address (0)) {
            if (address(this).balance < amount) {
                emit InsufficientFundsForWithdrawal(tokenAddress, to);
            } else {
                used[txHash] = true;
                // untrusted transfer, relies on provided cryptographic proof
                to.transfer(amount);
            }
        } else {
            IERC20 coin = IERC20(tokenAddress);
            if (coin.balanceOf(address (this)) < amount) {
                emit InsufficientFundsForWithdrawal(tokenAddress, to);
            } else {
                used[txHash] = true;
                // untrusted call, relies on provided cryptographic proof
                coin.transfer(to, amount);
            }
        }
    }

    /**
     * Checks given addresses for duplicates and if they are peers signatures
     * @param hash unsigned data
     * @param v v-component of signature from hash
     * @param r r-component of signature from hash
     * @param s s-component of signature from hash
     * @return true if all given addresses are correct or false otherwise
     */
    function checkSignatures(bytes32 hash,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s
    ) private returns (bool) {
        require(peersCount >= 1);
        require(v.length == r.length);
        require(r.length == s.length);
        uint needSigs = peersCount - (peersCount - 1) / 3;
        require(s.length >= needSigs);

        uint count = 0;
        address[] memory recoveredAddresses = new address[](s.length);
        for (uint i = 0; i < s.length; ++i) {
            address recoveredAddress = recoverAddress(
                hash,
                v[i],
                r[i],
                s[i]
            );

            // not a peer address or not unique
            if (isPeer[recoveredAddress] != true || uniqueAddresses[recoveredAddress] == true) {
                continue;
            }
            recoveredAddresses[count] = recoveredAddress;
            count = count + 1;
            uniqueAddresses[recoveredAddress] = true;
        }

        // restore state for future usages
        for (uint i = 0; i < count; ++i) {
            uniqueAddresses[recoveredAddresses[i]] = false;
        }

        return count >= needSigs;
    }

    /**
     * Recovers address from a given single signature
     * @param hash unsigned data
     * @param v v-component of signature from hash
     * @param r r-component of signature from hash
     * @param s s-component of signature from hash
     * @return address recovered from signature
     */
    function recoverAddress(bytes32 hash, uint8 v, bytes32 r, bytes32 s) private pure returns (address) {
        bytes32 simple_hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
        address res = ecrecover(simple_hash, v, r, s);
        return res;
    }

    /**
     * Mint new XORToken
     * @param tokenAddress address to mint
     * @param amount how much to mint
     * @param beneficiary destination address
     * @param txHash hash of transaction from Iroha
     * @param v array of signatures of tx_hash (v-component)
     * @param r array of signatures of tx_hash (r-component)
     * @param s array of signatures of tx_hash (s-component)
     */
    function mintTokensByPeers(
        address tokenAddress,
        uint256 amount,
        address beneficiary,
        bytes32 txHash,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s,
        address from
    )
    public
    {
        require(address(xorTokenInstance) == tokenAddress);
        require(used[txHash] == false);
        require(checkSignatures(
            keccak256(abi.encodePacked(tokenAddress, amount, beneficiary, txHash, from)),
            v,
            r,
            s)
        );

        xorTokenInstance.mintTokens(beneficiary, amount);
        used[txHash] = true;
    }
}

// File: MasterRelayed.sol

pragma solidity ^0.5.8;





/**
 * Provides functionality of master contract with relays
 */
contract MasterRelayed {
    bool internal initialized_;
    address public owner_;
    mapping(address => bool) public isPeer;
    /** Iroha tx hashes used */
    uint public peersCount;
    mapping(bytes32 => bool) public used;
    mapping(address => bool) public uniqueAddresses;

    /** registered client addresses */
    address public relayRegistryAddress;
    IRelayRegistry public relayRegistryInstance;

    SoraToken public xorTokenInstance;

    mapping(address => bool) public isToken;

    /**
     * Emit event when master contract does not have enough assets to proceed withdraw
     */
    event InsufficientFundsForWithdrawal(address asset, address recipient);

    /**
     * Constructor. Sets contract owner to contract creator.
     */
    constructor(address relayRegistry, address[] memory initialPeers) public {
        initialize(msg.sender, relayRegistry, initialPeers);
    }

    /**
     * Initialization of smart contract.
     */
    function initialize(address owner, address relayRegistry, address[] memory initialPeers) public {
        require(!initialized_);

        owner_ = owner;
        relayRegistryAddress = relayRegistry;
        relayRegistryInstance = IRelayRegistry(relayRegistryAddress);
        for (uint8 i = 0; i < initialPeers.length; i++) {
            addPeer(initialPeers[i]);
        }

        // 0 means ether which is definitely in whitelist
        isToken[address(0)] = true;

        // Create new instance of Sora token
        xorTokenInstance = new SoraToken();
        isToken[address(xorTokenInstance)] = true;

        initialized_ = true;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns(bool) {
        return msg.sender == owner_;
    }

    /**
     * A special function-like stub to allow ether accepting
     */
    function() external payable {
        require(msg.data.length == 0);
    }

    /**
     * Adds new peer to list of signature verifiers. Can be called only by contract owner.
     * @param newAddress address of new peer
     */
    function addPeer(address newAddress) private returns (uint) {
        require(isPeer[newAddress] == false);
        isPeer[newAddress] = true;
        ++peersCount;
        return peersCount;
    }

    function removePeer(address peerAddress) private {
        require(isPeer[peerAddress] == true);
        isPeer[peerAddress] = false;
        --peersCount;
    }

    function addPeerByPeer(
        address newPeerAddress,
        bytes32 txHash,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s
    )
    public returns (bool)
    {
        require(used[txHash] == false);
        require(checkSignatures(keccak256(abi.encodePacked(newPeerAddress, txHash)),
            v,
            r,
            s)
        );

        addPeer(newPeerAddress);
        used[txHash] = true;
        return true;
    }

    function removePeerByPeer(
        address peerAddress,
        bytes32 txHash,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s
    )
    public returns (bool)
    {
        require(used[txHash] == false);
        require(checkSignatures(
            keccak256(abi.encodePacked(peerAddress, txHash)),
            v,
            r,
            s)
        );

        removePeer(peerAddress);
        used[txHash] = true;
        return true;
    }

    /**
     * Adds new token to whitelist. Token should not been already added.
     * @param newToken token to add
     */
    function addToken(address newToken) public onlyOwner {
        require(isToken[newToken] == false);
        isToken[newToken] = true;
    }

    /**
     * Checks is given token inside a whitelist or not
     * @param tokenAddress address of token to check
     * @return true if token inside whitelist or false otherwise
     */
    function checkTokenAddress(address tokenAddress) public view returns (bool) {
        return isToken[tokenAddress];
    }

    /**
     * Withdraws specified amount of ether or one of ERC-20 tokens to provided address
     * @param tokenAddress address of token to withdraw (0 for ether)
     * @param amount amount of tokens or ether to withdraw
     * @param to target account address
     * @param txHash hash of transaction from Iroha
     * @param v array of signatures of tx_hash (v-component)
     * @param r array of signatures of tx_hash (r-component)
     * @param s array of signatures of tx_hash (s-component)
     * @param from relay contract address
     */
    function withdraw(
        address tokenAddress,
        uint256 amount,
        address payable to,
        bytes32 txHash,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s,
        address from
    )
    public
    {
        require(checkTokenAddress(tokenAddress));
        require(relayRegistryInstance.isWhiteListed(from, to));
        require(used[txHash] == false);
        require(checkSignatures(
            keccak256(abi.encodePacked(tokenAddress, amount, to, txHash, from)),
            v,
            r,
            s)
        );

        if (tokenAddress == address (0)) {
            if (address(this).balance < amount) {
                emit InsufficientFundsForWithdrawal(tokenAddress, to);
            } else {
                used[txHash] = true;
                // untrusted transfer, relies on provided cryptographic proof
                to.transfer(amount);
            }
        } else {
            IERC20 coin = IERC20(tokenAddress);
            if (coin.balanceOf(address (this)) < amount) {
                emit InsufficientFundsForWithdrawal(tokenAddress, to);
            } else {
                used[txHash] = true;
                // untrusted call, relies on provided cryptographic proof
                coin.transfer(to, amount);
            }
        }
    }

    /**
     * Checks given addresses for duplicates and if they are peers signatures
     * @param hash unsigned data
     * @param v v-component of signature from hash
     * @param r r-component of signature from hash
     * @param s s-component of signature from hash
     * @return true if all given addresses are correct or false otherwise
     */
    function checkSignatures(bytes32 hash,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s
    ) private returns (bool) {
        require(peersCount >= 1);
        require(v.length == r.length);
        require(r.length == s.length);
        uint needSigs = peersCount - (peersCount - 1) / 3;
        require(s.length >= needSigs);

        uint count = 0;
        address[] memory recoveredAddresses = new address[](s.length);
        for (uint i = 0; i < s.length; ++i) {
            address recoveredAddress = recoverAddress(
                hash,
                v[i],
                r[i],
                s[i]
            );

            // not a peer address or not unique
            if (isPeer[recoveredAddress] != true || uniqueAddresses[recoveredAddress] == true) {
                continue;
            }
            recoveredAddresses[count] = recoveredAddress;
            count = count + 1;
            uniqueAddresses[recoveredAddress] = true;
        }

        // restore state for future usages
        for (uint i = 0; i < count; ++i) {
            uniqueAddresses[recoveredAddresses[i]] = false;
        }

        return count >= needSigs;
    }

    /**
     * Recovers address from a given single signature
     * @param hash unsigned data
     * @param v v-component of signature from hash
     * @param r r-component of signature from hash
     * @param s s-component of signature from hash
     * @return address recovered from signature
     */
    function recoverAddress(bytes32 hash, uint8 v, bytes32 r, bytes32 s) private pure returns (address) {
        bytes32 simple_hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
        address res = ecrecover(simple_hash, v, r, s);
        return res;
    }

    /**
     * Mint new XORToken
     * @param tokenAddress address to mint
     * @param amount how much to mint
     * @param beneficiary destination address
     * @param txHash hash of transaction from Iroha
     * @param v array of signatures of tx_hash (v-component)
     * @param r array of signatures of tx_hash (r-component)
     * @param s array of signatures of tx_hash (s-component)
     */
    function mintTokensByPeers(
        address tokenAddress,
        uint256 amount,
        address beneficiary,
        bytes32 txHash,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s,
        address from
    )
    public
    {
        require(address(xorTokenInstance) == tokenAddress);
        require(relayRegistryInstance.isWhiteListed(from, beneficiary));
        require(used[txHash] == false);
        require(checkSignatures(
            keccak256(abi.encodePacked(tokenAddress, amount, beneficiary, txHash, from)),
            v,
            r,
            s)
        );

        xorTokenInstance.mintTokens(beneficiary, amount);
        used[txHash] = true;
    }
}

// File: Proxy.sol

pragma solidity ^0.5.8;

/**
 * @title Proxy
 * @dev Gives the possibility to delegate any call to a foreign implementation.
 */
contract Proxy {
  /**
  * @dev Tells the address of the implementation where every call will be delegated.
  * @return address of the implementation to which it will be delegated
  */
  function implementation() public view returns (address);

  /**
  * @dev Fallback function allowing to perform a delegatecall to the given implementation.
  * This function will return whatever the implementation call returns
  */
  function () payable external {
    address _impl = implementation();
    require(_impl != address(0));

    assembly {
      let ptr := mload(0x40)
      calldatacopy(ptr, 0, calldatasize)
      let result := delegatecall(gas, _impl, ptr, calldatasize, 0, 0)
      let size := returndatasize
      returndatacopy(ptr, 0, size)

      switch result
      case 0 { revert(ptr, size) }
      default { return(ptr, size) }
    }
  }
}

// File: UpgradeabilityProxy.sol

pragma solidity ^0.5.8;



/**
 * @title UpgradeabilityProxy
 * @dev This contract represents a proxy where the implementation address to which it will delegate can be upgraded
 */
contract UpgradeabilityProxy is Proxy {
  /**
   * @dev This event will be emitted every time the implementation gets upgraded
   * @param implementation representing the address of the upgraded implementation
   */
  event Upgraded(address indexed implementation);

  // Storage position of the address of the current implementation
  bytes32 private constant implementationPosition = keccak256("com.d3ledger.proxy.implementation");

  /**
   * @dev Constructor function
   */
  constructor() public {}

  /**
   * @dev Tells the address of the current implementation
   * @return address of the current implementation
   */
  function implementation() public view returns (address impl) {
    bytes32 position = implementationPosition;
    assembly {
      impl := sload(position)
    }
  }

  /**
   * @dev Sets the address of the current implementation
   * @param newImplementation address representing the new implementation to be set
   */
  function setImplementation(address newImplementation) internal {
    bytes32 position = implementationPosition;
    assembly {
      sstore(position, newImplementation)
    }
  }

  /**
   * @dev Upgrades the implementation address
   * @param newImplementation representing the address of the new implementation to be set
   */
  function _upgradeTo(address newImplementation) internal {
    address currentImplementation = implementation();
    require(currentImplementation != newImplementation);
    setImplementation(newImplementation);
    emit Upgraded(newImplementation);
  }
}

// File: OwnedUpgradeabilityProxy.sol

pragma solidity ^0.5.8;



/**
 * @title OwnedUpgradeabilityProxy
 * @dev This contract combines an upgradeability proxy with basic authorization control functionalities
 */
contract OwnedUpgradeabilityProxy is UpgradeabilityProxy {
  /**
  * @dev Event to show ownership has been transferred
  * @param previousOwner representing the address of the previous owner
  * @param newOwner representing the address of the new owner
  */
  event ProxyOwnershipTransferred(address previousOwner, address newOwner);

  // Storage position of the owner of the contract
  bytes32 private constant proxyOwnerPosition = keccak256("com.d3ledger.proxy.owner");

  /**
  * @dev the constructor sets the original owner of the contract to the sender account.
  */
  constructor() public {
    setUpgradeabilityOwner(msg.sender);
  }

  /**
  * @dev Throws if called by any account other than the owner.
  */
  modifier onlyProxyOwner() {
    require(msg.sender == proxyOwner());
    _;
  }

  /**
   * @dev Tells the address of the owner
   * @return the address of the owner
   */
  function proxyOwner() public view returns (address owner) {
    bytes32 position = proxyOwnerPosition;
    assembly {
      owner := sload(position)
    }
  }

  /**
   * @dev Sets the address of the owner
   */
  function setUpgradeabilityOwner(address newProxyOwner) internal {
    bytes32 position = proxyOwnerPosition;
    assembly {
      sstore(position, newProxyOwner)
    }
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferProxyOwnership(address newOwner) public onlyProxyOwner {
    require(newOwner != address(0));
    emit ProxyOwnershipTransferred(proxyOwner(), newOwner);
    setUpgradeabilityOwner(newOwner);
  }

  /**
   * @dev Allows the proxy owner to upgrade the current version of the proxy.
   * @param implementation representing the address of the new implementation to be set.
   */
  function upgradeTo(address implementation) public onlyProxyOwner {
    _upgradeTo(implementation);
  }

  /**
   * @dev Allows the proxy owner to upgrade the current version of the proxy and call the new implementation
   * to initialize whatever is needed through a low level call.
   * @param implementation representing the address of the new implementation to be set.
   * @param data represents the msg.data to bet sent in the low level call. This parameter may include the function
   * signature of the implementation to be called with the needed payload
   */
  function upgradeToAndCall(address implementation, bytes memory data) payable public onlyProxyOwner {
    upgradeTo(implementation);
    (bool success,) = address(this).call.value(msg.value)(data);
    require(success);
  }
}

// File: Relay.sol

pragma solidity ^0.5.8;




/**
 * Provides functionality of relay contract
 */
contract Relay {
    bool internal initialized_;
    address payable private masterAddress;
    IMaster private masterInstance;

    event AddressEvent(address input);
    event StringEvent(string input);
    event BytesEvent(bytes32 input);
    event NumberEvent(uint256 input);

    /**
     * Relay constructor
     * @param master address of master contract
     */
    constructor(address payable master) public {
        initialize(master);
    }

    /**
     * Initialization of smart contract.
     */
    function initialize(address payable master) public {
        require(!initialized_);
        masterAddress = master;
        masterInstance = IMaster(masterAddress);
        initialized_ = true;
    }

    /**
     * A special function-like stub to allow ether accepting
     */
    function() external payable {
        require(msg.data.length == 0);
        emit AddressEvent(msg.sender);
    }

    /**
     * Sends ether and all tokens from this contract to master
     * @param tokenAddress address of sending token (0 for Ether)
     */
    function sendToMaster(address tokenAddress) public {
        // trusted call
        require(masterInstance.checkTokenAddress(tokenAddress));
        if (tokenAddress == address(0)) {
            // trusted transfer
            masterAddress.transfer(address(this).balance);
        } else {
            IERC20 ic = IERC20(tokenAddress);
            // untrusted call in general but coin addresses are received from trusted master contract
            // which contains and manages whitelist of them
            ic.transfer(masterAddress, ic.balanceOf(address(this)));
        }
    }

    /**
     * Withdraws specified amount of ether or one of ERC-20 tokens to provided address
     * @param tokenAddress address of token to withdraw (0 for ether)
     * @param amount amount of tokens or ether to withdraw
     * @param to target account address
     * @param tx_hash hash of transaction from Iroha
     * @param v array of signatures of tx_hash (v-component)
     * @param r array of signatures of tx_hash (r-component)
     * @param s array of signatures of tx_hash (s-component)
     * @param from relay contract address
     */
    function withdraw(
        address tokenAddress,
        uint256 amount,
        address payable to,
        bytes32 tx_hash,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s,
        address from
    )
    public
    {
        emit AddressEvent(masterAddress);
        // trusted call
        masterInstance.withdraw(tokenAddress, amount, to, tx_hash, v, r, s, from);
    }

    /**
     * Mint specified amount of ether or one of ERC-20 tokens to provided address
     * @param tokenAddress address to mint
     * @param amount how much to mint
     * @param beneficiary destination address
     * @param txHash hash of transaction from Iroha
     * @param v array of signatures of tx_hash (v-component)
     * @param r array of signatures of tx_hash (r-component)
     * @param s array of signatures of tx_hash (s-component)
     * @param from relay contract address
     */
    function mintTokensByPeers(
        address tokenAddress,
        uint256 amount,
        address beneficiary,
        bytes32 txHash,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s,
        address from
    )
    public
    {
        emit AddressEvent(masterAddress);
        // trusted call
        masterInstance.mintTokensByPeers(tokenAddress, amount, beneficiary, txHash, v, r, s, from);
    }
}

// File: RelayRegistry.sol

pragma solidity ^0.5.8;



/**
 * @title Relay registry store data about white list and provide interface for master
 */
contract RelayRegistry is IRelayRegistry {
    bool internal initialized_;
    address private owner_;

    mapping(address => address[]) private _relayWhiteList;

    constructor () public {
        initialize(msg.sender);
    }

    /**
     * Initialization of smart contract.
     */
    function initialize(address owner) public {
        require(!initialized_);
        owner_ = owner;
        initialized_ = true;
    }

    /**
     * Store relay address and appropriate whitelist of addresses
     * @param relay contract address
     * @param whiteList white list
     */
    function addNewRelayAddress(address relay, address[] calldata whiteList) external {
        require(msg.sender == owner_);
        require(_relayWhiteList[relay].length == 0);
        _relayWhiteList[relay] = whiteList;
        emit AddNewRelay(relay, whiteList);
    }

    /**
     * Check if some address is in the whitelist
     * @param relay contract address
     * @param who address in whitelist
     * @return true if address in the whitelist
     */
    function isWhiteListed(address relay, address who) external view returns (bool) {
        if (_relayWhiteList[relay].length == 0) {
            return true;
        }
        if (_relayWhiteList[relay].length > 0) {
            for (uint i = 0; i < _relayWhiteList[relay].length; i++) {
                if (who == _relayWhiteList[relay][i]) {
                    return true;
                }
            }
        }
        return false;
    }

    /**
     * Get entire whitelist by relay address
     * @param relay contract address
     * @return array of the whitelist
     */
    function getWhiteListByRelay(address relay) external view returns (address[] memory ) {
        require(relay != address(0));
        require(_relayWhiteList[relay].length != 0);
        return _relayWhiteList[relay];
    }
}

// File: TestGreeter_v0.sol

pragma solidity ^0.5.8;

contract TestGreeter_v0 {
    bool ininialized_;

    string greeting_;

    constructor(string memory greeting) public {
        initialize(greeting);
    }

    function initialize(string memory greeting) public {
        require(!ininialized_);
        greeting_ = greeting;
        ininialized_ = true;
    }

    function greet() view public returns (string memory) {
        return greeting_;
    }

    function set(string memory greeting) public {
        greeting_ = greeting;
    }
}

// File: TestGreeter_v1.sol

pragma solidity ^0.5.8;



contract TestGreeter_v1 is TestGreeter_v0("Hi, World!") {

    function farewell() public view returns (string memory) {
        return "Good bye!";
    }
}

// File: TransferEthereum.sol

pragma solidity ^0.5.8;

/**
 * Contract that sends Ether with internal transaction for testing purposes.
 */
contract TransferEthereum {


    /**
     * A special function-like stub to allow ether accepting
     */
    function() external payable {
        require(msg.data.length == 0);
    }

    function transfer(address payable to, uint256 amount) public {
        to.call.value(amount)("");
    }

}
