// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./lib/DN404/DN404.sol";
import "./lib/DN404/DN404Mirror.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import {Ownable} from "solady/src/auth/Ownable.sol";
import {LibString} from "solady/src/utils/LibString.sol";
import {SafeTransferLib} from "solady/src/utils/SafeTransferLib.sol";
import {MerkleProofLib} from "solady/src/utils/MerkleProofLib.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

contract Sheboshi is
    Initializable,
    Ownable,
    UUPSUpgradeable,
    ReentrancyGuardUpgradeable,
    DN404
{
    event NameChanged(uint256 indexed tokenId, string name);
    event ContractURIUpdated();

    string private _name;
    string private _symbol;
    string private _baseURI;
    uint256 public numMinted;
    bytes32 private allowlistRoot;
    uint256 public saleStartTime;
    IERC20 public tokenLEASH;
    bool public contractsApproval;
    bool public reveal;
    uint256 public maxSupply;
    uint256 public mintPrice;
    mapping(address => bool) claims;
    uint8 public LEASHHolderMintLimit;
    mapping(address => uint8) LEASHHoldermints;

    error InvalidMint();
    error InvalidPrice();
    error TotalSupplyReached();
    error SaleNotStarted();
    error InvalidProof();

    modifier isValidMint(uint256 amount) {
        if (saleStartTime == 0) {
            revert SaleNotStarted();
        }
        if (mintPrice * amount != msg.value) {
            revert InvalidPrice();
        }
        if ((totalSupply() / _unit()) + amount > maxSupply) {
            revert TotalSupplyReached();
        }
        _;
    }

    function initialize(
        string memory name_,
        string memory symbol_,
        uint96 initialTokenSupply,
        bytes32 _allowlistRoot,
        uint256 _maxSupply,
        uint256 _mintPrice,
        uint8 _LEASHHolderMintLimit,
        uint96 _earnings
    ) public initializer {
        _initializeOwner(msg.sender);
        __ReentrancyGuard_init();
        __UUPSUpgradeable_init();
        _name = name_;
        _symbol = symbol_;
        allowlistRoot = _allowlistRoot;
        maxSupply = _maxSupply;
        mintPrice = _mintPrice;
        LEASHHolderMintLimit = _LEASHHolderMintLimit;
        contractsApproval = true;
        address mirror = address(new DN404Mirror(msg.sender));
        _initializeDN404(0, msg.sender, mirror);
        _mint(msg.sender, initialTokenSupply * _unit());
    }

    function _authorizeUpgrade(
        address _newImplementation
    ) internal override onlyOwner {}

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function setBaseURI(string calldata baseURI_) public onlyOwner {
        _baseURI = baseURI_;
    }

    function setReveal() public onlyOwner {
        reveal = true;
    }

    function setLEASH(address addr) public onlyOwner {
        tokenLEASH = IERC20(addr);
    }

    function startSale() public onlyOwner {
        saleStartTime = block.timestamp;
    }

    function setAllowlistRoot(bytes32 _allowlistRoot) public onlyOwner {
        allowlistRoot = _allowlistRoot;
    }

    function setMaxSupply(uint256 _maxSupply) public onlyOwner {
        maxSupply = _maxSupply;
    }

    function setMintPrice(uint256 _mintPrice) public onlyOwner {
        mintPrice = _mintPrice;
    }

    function setLEASHHolderMintLimit(uint8 _LEASHHolderMintLimit) public onlyOwner {
        LEASHHolderMintLimit = _LEASHHolderMintLimit;
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory result) {
        if (_ownerAt(tokenId) == address(0)) revert TokenDoesNotExist();
        return !reveal ? _baseURI : string.concat(_baseURI, LibString.toString(tokenId));
    }

    function changeName(uint256 tokenId, string memory newName) public {
        require(
            _ownerOf(tokenId) == msg.sender,
            "You are not the owner of this NFT"
        );
        emit NameChanged(tokenId, newName);
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function claim(
        uint256 amount,
        bytes32[] calldata proof
    ) external nonReentrant {
        require(
            block.timestamp < saleStartTime + 2 days,
            "Sale is not in the SHIBOSHIS phase"
        );
        require(!claims[msg.sender], "Already claimed");
        bytes32 fullRewardBytes = bytes32(amount);
        bytes12 rewardBytes = bytes12(fullRewardBytes << 160);
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, rewardBytes));

        if (!MerkleProofLib.verifyCalldata(proof, allowlistRoot, leaf)) {
            revert InvalidProof();
        }
        _mint(msg.sender, amount * _unit());
        claims[msg.sender] = true;
    }

    function approvalToContracts(bool _value) public onlyOwner {
        contractsApproval = _value;
    }

    function mint(
        uint256 amount
    ) public payable isValidMint(amount) nonReentrant {
        if (
            block.timestamp >= saleStartTime + 2 days &&
            block.timestamp <= saleStartTime + 3 days
        ) {
            bool istokenLEASHHolder = tokenLEASH.balanceOf(msg.sender) > 0;
            require(istokenLEASHHolder, "Only LEASH holders can mint now");
            require(LEASHHoldermints[msg.sender] + amount <= LEASHHolderMintLimit, "Mint limit exceeded");
            LEASHHoldermints[msg.sender] += uint8(amount);
            _mint(msg.sender, amount * _unit());
        }
        if (block.timestamp >= saleStartTime + 3 days) {
            _mint(msg.sender, amount * _unit());
        }
    }

    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
        if (contractsApproval) {
            require(
                !isContract(spender),
                "Approvals to contracts blocked for now"
            );
        }
        return super.approve(spender, amount);
    }

    function withdraw() public onlyOwner {
        SafeTransferLib.safeTransferAllETH(msg.sender);
    }
}
