// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Multicall.sol";
import "./interface/IUniswapFactory.sol";
import "./interface/IUniswapV2Factory.sol";
import "./interface/IHandlerReserve.sol";
import "./interface/IEthHandler.sol";
import "./IDexSpan.sol";
import "./UniversalERC20.sol";
import "./interface/IWETH.sol";
import "./libraries/TransferHelper.sol";
// import "./libraries/Multicall.sol";
import "./interface/IAugustusSwapper.sol";
import "../interfaces/IAssetForwarder.sol";
import "./interface/IEthHandler.sol";
import "./DexSpanRoot.sol";
import { IDexSpanView } from "./DexSpanView.sol";
import "../interfaces/IMessageHandler.sol";

contract DexSpan is DexSpanFlags, DexSpanRoot, AccessControl, Multicall {
    using UniversalERC20 for IERC20Upgradeable;
    using SafeMath for uint256;
    using DisableFlags for uint256;
    using UniswapV2ExchangeLib for IUniswapV2Exchange;
    IAssetForwarder public assetForwarder;
    address public assetBridge;
    address public univ2SkimAddress;
    address public newOwner;

    // IWETH public wnativeAddress;

    mapping(uint256 => address) public flagToAddress;

    event Swap(
        string indexed funcName,
        IERC20Upgradeable[] tokenPath,
        uint256 amount,
        address indexed sender,
        address indexed receiver,
        uint256 finalAmt,
        uint256[] flags,
        uint256 widgetID
    );
    event SwapWithRecipient(
        string indexed funcName,
        IERC20Upgradeable[] tokenPath,
        uint256 amount,
        address indexed sender,
        address indexed receiver,
        uint256 finalAmt,
        uint256[] flags,
        uint256 widgetID
    );
    event SwapOnSameChain(
        IERC20Upgradeable fromToken,
        IERC20Upgradeable destToken,
        uint amount,
        bytes _data,
        uint256 flags
    );
    event SetAssetForwarder(address assetForwarder, address admin);
    event SetAssetBridge(address assetBridge, address admin);
    event SetFlagToFactory(uint flag, address factoryAddress);
    event SetFactorySetter(address factorySetter);
    event SetWNativeAddresses(address wrappedNative);
    event TransferOwnership(address newOwner);
    event ClaimOwnership(address newOwner);

    error InvalidPool();
    error InvalidCaller();
    error ZeroAddress();
    error ZeroFlag();
    error RestrictNativeToken();
    error WrongTokenSent();
    error WrongDataLength();
    error AmountTooLow();
    error ExcecutionFailed();
    error AlreadyFactorySetter();
    error InvalidDepositType();
    struct DexesArgs {
        IERC20Upgradeable factoryAddress;
        uint256 _exchangeCode;
    }

    struct SwapParams {
        IERC20Upgradeable[] tokens;
        uint256 amount;
        uint256 minReturn;
        uint256 destAmount;
        uint256[] flags;
        bytes[] dataTx;
        bool isWrapper;
        address recipient;
        bytes destToken;
    }

    bytes32 public constant FACTORY_SETTER_ROLE =
        keccak256("FACTORY_SETTER_ROLE");
    bytes4 internal constant SWAP_MULTI_WITH_RECEPIENT_SELECTOR = 0xe738aa8d;

    receive() external payable {}

    constructor(
        address _assetForwarderAddress,
        address _native,
        address _wrappedNative,
        address _univ2SkimAddress
    ) {
        if (_assetForwarderAddress == address(0)) revert ZeroAddress();
        if (_native == address(0)) revert ZeroAddress();
        if (_wrappedNative == address(0)) revert ZeroAddress();
        if (_univ2SkimAddress == address(0)) revert ZeroAddress();
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        assetForwarder = IAssetForwarder(_assetForwarderAddress);
        nativeAddress = IERC20Upgradeable(_native);
        wnativeAddress = IWETH(_wrappedNative);
        univ2SkimAddress = _univ2SkimAddress;
    }

    function transferOwnership(
        address _newOwner
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (_newOwner == address(0)) revert ZeroAddress();
        newOwner = _newOwner;
        emit TransferOwnership(_newOwner);
    }

    function claimOwnership() external {
        if (newOwner != msg.sender) {
            revert InvalidCaller();
        }
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        emit ClaimOwnership(msg.sender);
    }

    function setAssetForwarder(
        address _forwarder
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (_forwarder == address(0)) revert ZeroAddress();
        assetForwarder = IAssetForwarder(_forwarder);
        emit SetAssetForwarder(_forwarder, msg.sender);
    }

    function setAssetBridge(
        address _assetBridge
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (_assetBridge == address(0)) revert ZeroAddress();
        assetBridge = _assetBridge;
        emit SetAssetBridge(_assetBridge, msg.sender);
    }

    function setFlagToFactoryAddress(
        uint256 _flagCode,
        address _factoryAddress
    ) external onlyRole(FACTORY_SETTER_ROLE) {
        if (_flagCode == 0) revert ZeroFlag();
        if (_factoryAddress == address(0)) revert ZeroAddress();
        flagToAddress[_flagCode] = address(_factoryAddress);
        emit SetFlagToFactory(_flagCode, _factoryAddress);
    }

    function setFactorySetter(
        address _factorySetter
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (_factorySetter == address(0)) revert ZeroAddress();
        if (hasRole(FACTORY_SETTER_ROLE, _factorySetter))
            revert AlreadyFactorySetter();
        _setupRole(FACTORY_SETTER_ROLE, _factorySetter);
        emit SetFactorySetter(_factorySetter);
    }

    function setWNativeAddresses(
        address _native,
        address _wrappedNative
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (_native == address(0)) revert ZeroAddress();
        if (_wrappedNative == address(0)) revert ZeroAddress();
        nativeAddress = IERC20Upgradeable(_native);
        wnativeAddress = IWETH(_wrappedNative);
        emit SetWNativeAddresses(_wrappedNative);
    }

    function handleMessage(
        address _tokenSent,
        uint256 _amount,
        bytes memory message
    ) external {
        if (
            msg.sender != address(assetForwarder) &&
            msg.sender != address(assetBridge)
        ) revert InvalidCaller();
        messageHandler(_tokenSent, _amount, message);
    }

    function swapInSameChain(
        IERC20Upgradeable[] memory tokens,
        uint256 amount,
        uint256 minReturn,
        uint256[] memory flags,
        bytes[] memory dataTx,
        bool isWrapper,
        address recipient,
        uint256 widgetID
    ) public payable returns (uint256 returnAmount) {
        returnAmount = swapMultiWithRecipient(
            tokens,
            amount,
            minReturn,
            flags,
            dataTx,
            isWrapper,
            recipient
        );
        emit Swap(
            "swapInSameChain",
            tokens,
            amount,
            msg.sender,
            recipient,
            returnAmount,
            flags,
            widgetID
        );
    }

    function swapMultiWithRecipient(
        IERC20Upgradeable[] memory tokens,
        uint256 amount,
        uint256 minReturn,
        uint256[] memory flags,
        bytes[] memory dataTx,
        bool isWrapper,
        address recipient
    ) public payable returns (uint256 returnAmount) {
        returnAmount = _swapMultiInternal(
            tokens,
            amount,
            minReturn,
            flags,
            dataTx,
            isWrapper,
            recipient
        );
        emit SwapWithRecipient(
            "swapMultiWithRecipient",
            tokens,
            amount,
            msg.sender,
            recipient,
            returnAmount,
            flags,
            0
        );
    }

    function swapAndDeposit(
        uint256 partnerId,
        bytes32 destChainIdBytes,
        bytes calldata recipient,
        uint8 depositType,
        uint256 feeAmount,
        bytes memory message,
        SwapParams memory swapData,
        address refundRecipient
    ) public payable {
        _swapMultiInternal(
            swapData.tokens,
            swapData.amount,
            swapData.minReturn,
            swapData.flags,
            swapData.dataTx,
            swapData.isWrapper,
            address(this)
        );
        IERC20Upgradeable reserveToken = swapData.tokens[
            swapData.tokens.length - 1
        ];

        // swapAndDeposit
        if (depositType == 0) {
            uint256 amount = reserveToken.universalBalanceOf(address(this));
            reserveToken.universalApprove(address(assetForwarder), amount);
            assetForwarder.iDeposit{value: reserveToken.isETH() ? amount : 0}(
                IAssetForwarder.DepositData(
                    partnerId,
                    amount,
                    amount - feeAmount,
                    address(reserveToken),
                    refundRecipient,
                    destChainIdBytes
                ),
                swapData.destToken,
                recipient
            );
            return;
        }

        // swapAndDepositWithMessage
        if (depositType == 1) {
            uint256 amount = reserveToken.universalBalanceOf(address(this));
            reserveToken.universalApprove(
                address(assetForwarder),
                swapData.minReturn
            );
            assetForwarder.iDepositMessage{
                value: reserveToken.isETH() ? amount : 0
            }(
                IAssetForwarder.DepositData(
                    partnerId,
                    swapData.minReturn,
                    swapData.destAmount,
                    address(reserveToken),
                    refundRecipient,
                    destChainIdBytes
                ),
                swapData.destToken,
                recipient,
                message
            );
            if (amount > swapData.minReturn) {
                reserveToken.universalTransfer(
                    refundRecipient,
                    amount - swapData.minReturn
                );
            }
            return;
        }
        if (depositType == 2) {
            uint256 amount = reserveToken.universalBalanceOf(address(this));
            reserveToken.universalApprove(address(assetForwarder), amount);
            assetForwarder.iDeposit{value: reserveToken.isETH() ? amount : 0}(
                IAssetForwarder.DepositData(
                    partnerId,
                    amount,
                    swapData.destAmount,
                    address(reserveToken),
                    refundRecipient,
                    destChainIdBytes
                ),
                swapData.destToken,
                recipient
            );
            return;
        }
        revert InvalidDepositType();
    }

    function messageHandler(
        address _tokenSent,
        uint256 _amount,
        bytes memory message
    ) internal {
        (
            IERC20Upgradeable[] memory tokens,
            uint256 minReturn,
            bytes[] memory dataTx,
            uint256[] memory flags,
            address recipient,
            bool isInstruction,
            bytes memory instruction
        ) = abi.decode(
                message,
                (
                    IERC20Upgradeable[],
                    uint256,
                    bytes[],
                    uint256[],
                    address,
                    bool,
                    bytes
                )
            );
        if (_tokenSent != address(tokens[0])) revert WrongTokenSent();
        bytes memory execData;
        bool execFlag;
        (execFlag, execData) = address(this).call(
            abi.encodeWithSelector(
                SWAP_MULTI_WITH_RECEPIENT_SELECTOR,
                tokens,
                _amount,
                minReturn,
                flags,
                dataTx,
                true,
                recipient
            )
        );

        if (!execFlag) {
            tokens[0].universalTransfer(recipient, _amount);
        }

        if (isInstruction) {
            uint256 finalAmount = execFlag
                ? uint256(bytes32(execData))
                : _amount;
            address finalToken = execFlag
                ? address(tokens[tokens.length - 1])
                : _tokenSent;
            (execFlag, execData) = recipient.call(
                abi.encodeWithSelector(
                    IMessageHandler.handleMessage.selector,
                    finalToken,
                    finalAmount,
                    instruction
                )
            );
        }
    }

    function _swapMultiInternal(
        IERC20Upgradeable[] memory tokens,
        uint256 amount,
        uint256 minReturn,
        uint256[] memory flags,
        bytes[] memory dataTx,
        bool isWrapper,
        address recipient
    ) internal returns (uint256 returnAmount) {
        if (recipient == address(0)) revert ZeroAddress();
        if (tokens.length - 1 != flags.length) {
            revert WrongDataLength();
        }
        if (!isWrapper) {
            if (!tokens[0].isETH() && msg.value != 0) {
                revert RestrictNativeToken();
            }
            tokens[0].universalTransferFrom(msg.sender, address(this), amount);
        }
        returnAmount = tokens[0].universalBalanceOf(address(this));
        IERC20Upgradeable destinationToken = tokens[tokens.length - 1];
        for (uint256 i = 1; i < tokens.length; i++) {
            if (tokens[i - 1] == tokens[i]) {
                continue;
            }
            returnAmount = _swapFloor(
                tokens[i - 1],
                tokens[i],
                returnAmount,
                0,
                flags[i - 1],
                dataTx[i - 1]
            );
        }

        if (destinationToken.isETH()) {
            returnAmount = wnativeAddress.balanceOf(address(this));
            wnativeAddress.withdraw(returnAmount);
        }

        if (recipient != address(this)) {
            uint256 userBalanceOld = destinationToken.universalBalanceOf(
                recipient
            );
            destinationToken.universalTransfer(recipient, returnAmount);
            uint256 userBalanceNew = destinationToken.universalBalanceOf(
                recipient
            );

            uint receivedTokens = userBalanceNew - userBalanceOld;
            if (receivedTokens <= minReturn) {
                revert AmountTooLow();
            }
            returnAmount = receivedTokens;
        }
    }

    function _swapFloor(
        IERC20Upgradeable fromToken,
        IERC20Upgradeable destToken,
        uint256 amount,
        uint256 minReturn,
        uint256 flags,
        bytes memory _data
    ) internal returns (uint returnAmount) {
        returnAmount = _swap(
            fromToken,
            destToken,
            amount,
            minReturn,
            flags,
            _data
        );
    }

    function _swap(
        IERC20Upgradeable fromToken,
        IERC20Upgradeable destToken,
        uint256 amount,
        uint256 minReturn,
        uint256 flags,
        bytes memory _data
    ) internal returns (uint256 returnAmount) {
        if (fromToken == destToken) {
            return amount;
        }
        function(
            IERC20Upgradeable,
            IERC20Upgradeable,
            uint256,
            bytes memory,
            uint256
        ) reserve = _getReserveExchange(flags);

        uint256 remainingAmount = fromToken.universalBalanceOf(address(this));
        reserve(fromToken, destToken, remainingAmount, _data, flags);
        returnAmount = destToken.universalBalanceOf(address(this));
    }

    function _getReserveExchange(
        uint256 flag
    )
        internal
        pure
        returns (
            function(
                IERC20Upgradeable,
                IERC20Upgradeable,
                uint256,
                bytes memory,
                uint256
            )
        )
    {
        if (flag < 0x03E9 && flag >= 0x0001) {
            // 1 - 1000
            return _swapOnUniswapV2;
        } else if (flag == 0x07D2) {
            return _swapOnParaswap; // 2002
        } else {
            return _swapOnGenericAggregator;
        }
        revert("RA: Exchange not found");
    }

    function _swapOnUniswapV2(
        IERC20Upgradeable fromToken,
        IERC20Upgradeable destToken,
        uint256 amount,
        bytes memory _data,
        uint256 flags
    ) internal {
        _swapOnExchangeInternal(fromToken, destToken, amount, flags);
    }

    function _swapOnGenericAggregator(
        IERC20Upgradeable fromToken,
        IERC20Upgradeable destToken,
        uint256 amount,
        bytes memory _data,
        uint256 flagCode
    ) internal {
        if (_data.length < 0) {
            revert WrongDataLength();
        }
        address aggregatorFactoryAddress = flagToAddress[flagCode];
        if (aggregatorFactoryAddress == address(0)) {
            revert ZeroAddress();
        }
        if (fromToken.isETH()) {
            wnativeAddress.deposit{value: amount}();
        }

        IERC20Upgradeable fromTokenReal = fromToken.isETH()
            ? wnativeAddress
            : fromToken;

        fromTokenReal.universalApprove(address(aggregatorFactoryAddress), amount);
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, ) = address(aggregatorFactoryAddress).call(_data);
        if (!success) revert ExcecutionFailed();
    }

    function _swapOnParaswap(
        IERC20Upgradeable fromToken,
        IERC20Upgradeable destToken,
        uint256 amount,
        bytes memory _data,
        uint256 flagCode
    ) internal {
        if (_data.length < 0) {
            revert WrongDataLength();
        }
        address paraswap = flagToAddress[flagCode];
        if (paraswap == address(0)) {
            revert ZeroAddress();
        }

        if (fromToken.isETH()) {
            wnativeAddress.deposit{value: amount}();
        }
        IERC20Upgradeable fromTokenReal = fromToken.isETH()
            ? wnativeAddress
            : fromToken;

        fromTokenReal.universalApprove(
            IAugustusSwapper(paraswap).getTokenTransferProxy(),
            amount
        );
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, ) = address(paraswap).call(_data);
        if (!success) {
            revert ExcecutionFailed();
        }
    }

    function _swapOnExchangeInternal(
        IERC20Upgradeable fromToken,
        IERC20Upgradeable destToken,
        uint256 amount,
        uint256 flagCode
    ) internal returns (uint256 returnAmount) {
        if (fromToken.isETH()) {
            wnativeAddress.deposit{value: amount}();
        }

        address dexAddress = flagToAddress[flagCode];
        require(dexAddress != address(0), "RA: Exchange not found");
        IUniswapV2Factory factory = IUniswapV2Factory(address(dexAddress));

        IERC20Upgradeable fromTokenReal = fromToken.isETH()
            ? wnativeAddress
            : fromToken;
        IERC20Upgradeable toTokenReal = destToken.isETH()
            ? wnativeAddress
            : destToken;

        if (fromTokenReal == toTokenReal) {
            return amount;
        }
        IUniswapV2Exchange pool = factory.getPair(fromTokenReal, toTokenReal);
        if (address(pool) == address(0)) revert InvalidPool();
        bool needSync;
        bool needSkim;
        (returnAmount, needSync, needSkim) = pool.getReturn(
            fromTokenReal,
            toTokenReal,
            amount
        );
        if (needSync) {
            pool.sync();
        } else if (needSkim) {
            pool.skim(univ2SkimAddress);
        }

        fromTokenReal.universalTransfer(address(pool), amount);
        if (
            uint256(uint160(address(fromTokenReal))) <
            uint256(uint160(address(toTokenReal)))
        ) {
            pool.swap(0, returnAmount, address(this), "");
        } else {
            pool.swap(returnAmount, 0, address(this), "");
        }
    }
}
