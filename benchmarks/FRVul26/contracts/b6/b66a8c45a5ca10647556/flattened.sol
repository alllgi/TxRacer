// Sources retrieved from Sourcify API v2.
// Deterministic best-effort flattening; original files are preserved under src/.

// File: IERC20.sol

pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: IERC20Metadata.sol

pragma solidity ^0.8.0;



interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

// File: Ownable.sol

pragma solidity ^0.8.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: TokenTimelock.sol

pragma solidity ^0.8.0;



contract TokenTimelock {
    IERC20 private _token;
    address private _beneficiary;
    uint256 private _nextReleaseTime;
    uint256 private _releaseAmount;
    uint256 private _releasePeriod;

    TimelockFactory private _factory;

    event Released(address indexed beneficiary, uint256 amount);
    event BeneficiaryTransferred(address indexed previousBeneficiary, address indexed newBeneficiary);

	constructor(){
		_token = IERC20(address(1));
	}

	function init(IERC20 token_, address beneficiary_, uint256 releaseStart_, uint256 releaseAmount_, uint256 releasePeriod_) external {
		require(_token == IERC20(address(0)), "TokenTimelock: already initialized");
		require(token_ != IERC20(address(0)), "TokenTimelock: erc20 token address is zero");
        require(beneficiary_ != address(0), "TokenTimelock: beneficiary address is zero");
        require(releasePeriod_ == 0 || releaseAmount_ != 0, "TokenTimelock: release amount is zero");

        emit BeneficiaryTransferred(address(0), beneficiary_);

        _token = token_;
        _beneficiary = beneficiary_;
        _nextReleaseTime = releaseStart_;
        _releaseAmount = releaseAmount_;
        _releasePeriod = releasePeriod_;

        _factory = TimelockFactory(msg.sender);
	}

    function token() public view virtual returns (IERC20) {
        return _token;
    }

    function beneficiary() public view virtual returns (address) {
        return _beneficiary;
    }

    function nextReleaseTime() public view virtual returns (uint256) {
        return _nextReleaseTime;
    }

    function releaseAmount() public view virtual returns (uint256) {
        return _releaseAmount;
    }

    function balance() public view virtual returns (uint256) {
        return token().balanceOf(address(this));
    }

    function releasableAmount() public view virtual returns (uint256) {
        if (block.timestamp < _nextReleaseTime) return 0;

        uint256 amount = balance();
        if (amount == 0) return 0;
        if (_releasePeriod == 0) return amount;

        uint256 passedPeriods = (block.timestamp - _nextReleaseTime) / _releasePeriod;
        uint256 maxReleasableAmount = (passedPeriods + 1) * _releaseAmount;
        
        if (amount <= maxReleasableAmount) return amount;
        return maxReleasableAmount;
    }

    function releasePeriod() public view virtual returns (uint256) {
        return _releasePeriod;
    }

    function release() public virtual returns (bool) {
        // solhint-disable-next-line not-rely-on-time
        require(block.timestamp >= nextReleaseTime(), "TokenTimelock: current time is before release time");

        uint256 _releasableAmount = releasableAmount();
        require(_releasableAmount > 0, "TokenTimelock: no releasable tokens");

        emit Released(beneficiary(), _releasableAmount);
        require(token().transfer(beneficiary(), _releasableAmount));

        if (_releasePeriod != 0) {
            uint256 passedPeriods = (block.timestamp - _nextReleaseTime) / _releasePeriod;
            _nextReleaseTime += (passedPeriods + 1) * _releasePeriod;
        }

        return true;
    }

    function transferBeneficiary(address newBeneficiary) public virtual returns (bool) {
		require(msg.sender == beneficiary(), "TokenTimelock: caller is not the beneficiary");
		require(newBeneficiary != address(0), "TokenTimelock: the new beneficiary is zero address");
		
        emit BeneficiaryTransferred(beneficiary(), newBeneficiary);
		_beneficiary = newBeneficiary;
		return true;
	}

    function split(address splitBeneficiary, uint256 splitAmount) public virtual returns (bool) {
        uint256 _amount = balance();
		require(msg.sender == beneficiary(), "TokenTimelock: caller is not the beneficiary");
		require(splitBeneficiary != address(0), "TokenTimelock: beneficiary address is zero");
        require(splitAmount > 0, "TokenTimelock: amount is zero");
        require(splitAmount <= _amount, "TokenTimelock: amount exceeds balance");

        uint256 splitReleaseAmount;
        if (_releasePeriod > 0) {
            splitReleaseAmount = _releaseAmount * splitAmount / _amount;
        }

        address newTimelock = _factory.createTimelock(token(), splitBeneficiary, _nextReleaseTime, splitReleaseAmount, _releasePeriod);

        require(token().transfer(newTimelock, splitAmount));
        _releaseAmount -= splitReleaseAmount;
		return true;
	}
}

contract CloneFactory {
  function createClone(address target) internal returns (address result) {
    bytes20 targetBytes = bytes20(target);
    assembly {
      let clone := mload(0x40)
      mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
      mstore(add(clone, 0x14), targetBytes)
      mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
      result := create(0, clone, 0x37)
    }
  }
}

contract TimelockFactory is CloneFactory {
	address private _tokenTimelockImpl;
	event Timelock(address timelockContract);
	constructor() {
		_tokenTimelockImpl = address(new TokenTimelock());
	}
	function createTimelock(IERC20 token, address to, uint256 releaseTime, uint256 releaseAmount, uint256 period) public returns (address) {
		address clone = createClone(_tokenTimelockImpl);
		TokenTimelock(clone).init(token, to, releaseTime, releaseAmount, period);

		emit Timelock(clone);
		return clone;
	}
}

// File: AIOZToken.sol

pragma solidity ^0.8.0;






contract ERC20 is IERC20, IERC20Metadata {
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, msg.sender, currentAllowance - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(msg.sender, spender, currentAllowance - subtractedValue);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}

contract AIOZToken is ERC20, Ownable {
    uint256 private _maxTotalSupply;
    
    constructor() ERC20("AIOZ Network", "AIOZ") {
        _maxTotalSupply = 1000000000e18;
        
        // init timelock factory
        TimelockFactory timelockFactory = new TimelockFactory();

        // ERC20
        // public sales
        mint(0x076592ad72b79bBaBDD05aDd7d367f44f2CFf658, 10333333e18); // for Paid Ignition
        // private sales
        mint(0xF8477220f8375968E38a3B79ECA4343822b53af2, 73000000e18*25/100);
        address privateSalesLock = timelockFactory.createTimelock(this, 0xF8477220f8375968E38a3B79ECA4343822b53af2, block.timestamp + 30 days, 73000000e18*25/100, 30 days);
        mint(privateSalesLock, 73000000e18*75/100);
        // team
        address teamLock = timelockFactory.createTimelock(this, 0x82E83054CC631C0Da85Ca67087E45ca31b93F29b, block.timestamp + 180 days, 250000000e18*8/100, 30 days);
        mint(teamLock, 250000000e18);
        // advisors
        address advisorsLock = timelockFactory.createTimelock(this, 0xBbf78c2Ee1794229e31af81c83F4d5125F08FE0F, block.timestamp + 90 days, 50000000e18*8/100, 30 days);
        mint(advisorsLock, 50000000e18);
        // marketing
        mint(0x9E2F8e278585CAfD3308E894d2E09ffEc520b1E9, 30000000e18*10/100);
        address marketingERC20Lock = timelockFactory.createTimelock(this, 0x9E2F8e278585CAfD3308E894d2E09ffEc520b1E9, block.timestamp + 30 days, 30000000e18*5/100, 30 days);
        mint(marketingERC20Lock, 30000000e18*90/100);
        // exchange liquidity provision
        mint(0x6c3D8872002B66C808aE462Db314B87962DCC7aF, 23333333e18);
        // ecosystem growth
        address growthLock = timelockFactory.createTimelock(this, 0xCFd6736a11e76c0e3418FEEbb788822211d92F1e, block.timestamp + 90 days, 0, 0);
        mint(growthLock, 530000000e18);

        // BEP20
        // // public sales
        // mint(0xc9Fc843DBAA8ccCcf37E09b67DeEa5f963E3919E, 6666667e18); // for BSCPad
        // // marketing
        // mint(0x7e318e80EB8e401451334cAa2278E39Da7F6C49B, 20000000e18*10/100);
        // address marketingBEP20Lock = timelockFactory.createTimelock(this, 0x7e318e80EB8e401451334cAa2278E39Da7F6C49B, block.timestamp + 30 days, 20000000e18*5/100, 30 days);
        // mint(marketingBEP20Lock, 20000000e18*90/100);
        // // exchange liquidity provision
        // mint(0x0a515Ac284E3c741575A4fd71C27e377a19D5E6D, 6666667e18);
    }

    function mint(address account, uint256 amount) public onlyOwner returns (bool) {
        require(totalSupply() + amount <= _maxTotalSupply, "AIOZ Token: mint more than the max total supply");
        _mint(account, amount);
        return true;
    }

    function burn(uint256 amount) public onlyOwner returns (bool) {
        _burn(msg.sender, amount);
        return true;
    }
}
