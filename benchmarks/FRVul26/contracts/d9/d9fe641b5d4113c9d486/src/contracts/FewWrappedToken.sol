// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.6.6;

import '@uniswap/lib/contracts/libraries/TransferHelper.sol';

import './interfaces/IFewWrappedToken.sol';
import './libraries/SafeMath.sol';
import './refs/ICoreRef.sol';
import './interfaces/IFewFactory.sol';

/// @title Few Wrapped Token
contract FewWrappedToken is IFewWrappedToken {
    using SafeMath for uint;

    string public override name;
    string public override symbol;
    uint8 public override decimals;
    uint  public override totalSupply;
    mapping(address => uint) public override balanceOf;
    mapping(address => mapping(address => uint)) public override allowance;

    bytes32 public override DOMAIN_SEPARATOR;
    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public override constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    mapping(address => uint) public override nonces;

    address public override factory;
    address public override token;

    modifier onlyMinter() {
        require(ICoreRef(factory).core().isMinter(msg.sender), "CoreRef: Caller is not a minter");
        _;
    }

    modifier onlyBurner() {
        require(ICoreRef(factory).core().isBurner(msg.sender), "CoreRef: Caller is not a burner");
        _;
    }

    modifier whenNotPaused() {
        require(!IFewFactory(factory).paused(), "CoreRef: Caller is paused");
        _;
    }

    event Mint(address indexed minter, uint256 amount, address indexed to);
    event Burn(address indexed burner, uint256 amount, address indexed to);
    event Wrap(address indexed sender, uint256 amount, address indexed to);
    event Unwrap(address indexed sender, uint256 amount, address indexed to);

    /// @notice Few wrapped token constructor
    constructor() public {
        uint chainId;
        assembly {
            chainId := chainid()
        }

        factory = msg.sender;
        token = IFewFactory(msg.sender).parameter();
        name = string(abi.encodePacked("Few Wrapped ", IERC20(token).name()));
        symbol = string(abi.encodePacked("fw", IERC20(token).symbol()));
        decimals = IERC20(token).decimals();

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'),
                keccak256(bytes(name)),
                keccak256(bytes('1')),
                chainId,
                address(this)
            )
        );
    }

    function _mint(address to, uint value) internal {
        totalSupply = totalSupply.add(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint value) internal {
        balanceOf[from] = balanceOf[from].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Transfer(from, address(0), value);
    }

    function _approve(address owner, address spender, uint value) internal {
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(address from, address to, uint value) private {
        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(from, to, value);
    }

    function approve(address spender, uint value) external override returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint value) external override returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) external override returns (bool) {
        if (allowance[from][msg.sender] != uint(-1)) {
            allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
        }
        _transfer(from, to, value);
        return true;
    }

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external override {
        require(deadline >= block.timestamp, 'Few: EXPIRED');
        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline))
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == owner, 'Few: INVALID_SIGNATURE');
        _approve(owner, spender, value);
    }

    /// @notice mint Few wrapped tokens
    /// @param account the account to mint to
    /// @param amount the amount to mint
    function mint(address account, uint256 amount)
        external
        override
        onlyMinter
        whenNotPaused
    {
        _mint(account, amount);
        emit Mint(msg.sender, amount, account);
    }

    /// @notice burn Few wrapped tokens from caller
    /// @param amount the amount to burn
    function burn(uint256 amount) public override {
        _burn(msg.sender, amount);
        emit Burn(msg.sender, amount, msg.sender);
    }

    /// @notice burn Few wrapped tokens from specified account
    /// @param account the account to burn from
    /// @param amount the amount to burn
    function burnFrom(address account, uint256 amount)
        public
        override
        onlyBurner
        whenNotPaused
    {
        _burn(account, amount);
        emit Burn(msg.sender, amount, account);
    }

    /// @notice exchanges token to Few wrapped token
    /// @param amount the amount to wrap
    /// @param to wrapped token reciver address
    function wrapTo(uint256 amount, address to) public override returns (uint256) {
        require(amount > 0, "Few: can't wrap zero token");
        TransferHelper.safeTransferFrom(token, msg.sender, address(this), amount);
        _mint(to, amount);
        emit Wrap(msg.sender, amount, to);
        return amount;
    }

    function wrap(uint256 amount) external override returns (uint256) {
        return wrapTo(amount, msg.sender);
    }

    /// @notice exchange Few wrapped token to token
    /// @param amount the amount to unwrap
    /// @param to token receiver address
    function unwrapTo(uint256 amount, address to) public override returns (uint256) {
        require(amount > 0, "Few: zero amount unwrap not allowed");
        _burn(msg.sender, amount);
        TransferHelper.safeTransfer(address(token), to, amount);
        emit Unwrap(msg.sender, amount, to);
        return amount;
    }

    function unwrap(uint256 amount) external override returns (uint256) {
        return unwrapTo(amount, msg.sender);
    }
}
