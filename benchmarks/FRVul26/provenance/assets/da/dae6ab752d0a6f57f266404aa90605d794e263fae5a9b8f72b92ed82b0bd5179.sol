// Sources retrieved from Blockscout Ethereum API v2.

// ===== src/Facets/FraxFacet.sol =====
// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.17;

import { ILiFi } from "../Interfaces/ILiFi.sol";
import { IFraxHopV2, IFraxOFT, ITipFeeManager } from "../Interfaces/IFraxHopV2.sol";
import { LibAsset, IERC20 } from "../Libraries/LibAsset.sol";
import { LibBytes } from "../Libraries/LibBytes.sol";
import { LibDiamond } from "../Libraries/LibDiamond.sol";
import { LibSwap } from "../Libraries/LibSwap.sol";
import { LiFiData } from "../Helpers/LiFiData.sol";
import { ReentrancyGuard } from "../Helpers/ReentrancyGuard.sol";
import { SwapperV2 } from "../Helpers/SwapperV2.sol";
import { Validatable } from "../Helpers/Validatable.sol";
import { InformationMismatch, InvalidCallData, InvalidConfig, InvalidNonEVMReceiver, InvalidReceiver, NotInitialized, TokenNotSupported, UnsupportedChainId } from "../Errors/GenericErrors.sol";

/// @title FraxFacet
/// @author LI.FI (https://li.fi)
/// @notice Provides functionality for bridging through Frax HopV2, a LayerZero V2
///         OFT hub-and-spoke bridge (hub on Fraxtal, spokes on every other chain).
/// @dev This facet is not intended to custody user funds. Tokens are pulled, floored to
///      the OFT's dust granularity, forwarded to the HopV2 contract in the same call, and
///      any dust remainder plus excess native fee are returned to the refundRecipient within
///      the same transaction; no balance is meant to persist between calls.
/// @dev Supports both EVM and non-EVM destinations. HopV2's recipient is a bytes32, so a
///      non-EVM destination (Solana, reached via the Fraxtal hub) carries its pubkey in
///      FraxData.nonEVMReceiver and emits BridgeToNonEVMChainBytes32; EVM destinations use
///      the left-padded bridgeData.receiver. The NON_EVM_ADDRESS sentinel and the
///      destination kind are cross-checked in both directions (see docs/FraxFacet.md).
/// @dev Trust assumption: the facet grants HopV2 — an upgradeable proxy — a standing
///      unlimited ERC20 allowance via LibAsset.maxApproveERC20 (see docs/FraxFacet.md).
/// @custom:version 1.0.0
contract FraxFacet is
    ILiFi,
    LiFiData,
    ReentrancyGuard,
    SwapperV2,
    Validatable
{
    /// Constants ///

    /// @dev Diamond storage namespace for the chainId -> LayerZero EID mapping.
    bytes32 internal constant NAMESPACE = keccak256("com.lifi.facets.frax");

    /// Storage ///

    /// @notice The Frax HopV2 contract on this chain (hub on Fraxtal, spoke elsewhere).
    ///         This is also the token approval target ("approvalAddress").
    IFraxHopV2 public immutable FRAX_HOP;

    /// @notice The Tempo TIP20 fee manager. Non-zero ONLY on Tempo, whose LayerZero
    ///         EndpointV2Alt rejects native msg.value and charges the messaging fee in an
    ///         ERC20 gas token instead. Zero on every standard chain, which selects the
    ///         native-fee path. This single immutable is what lets one FraxFacet source
    ///         serve every chain (see docs/FraxFacet.md).
    address public immutable FRAX_TIP_FEE_MANAGER;

    /// @notice The default Tempo gas token (PATH_USD) used when the diamond has not opted
    ///         into a specific TIP20 gas token. Set only on Tempo; zero elsewhere.
    address public immutable FRAX_PATH_USD;

    /// Types ///

    /// @dev Entry used to seed or update the chainId -> LayerZero EID mapping.
    /// @param chainId LI.FI chain ID (e.g. 252 for Fraxtal).
    /// @param lzEid LayerZero endpoint ID for the same chain (e.g. 30255 for Fraxtal).
    struct ChainIdConfig {
        uint256 chainId;
        uint32 lzEid;
    }

    /// @dev Diamond storage layout. `lzEids[chainId] == 0` means "unset" — safe because
    ///      LayerZero does not assign EID 0 (v1 starts at 101, v2 at 30000).
    struct Storage {
        mapping(uint256 => uint32) lzEids;
        bool chainMappingsInitialized;
    }

    /// @param oft The OFT messenger for the token on the source chain (its token() is the
    ///        ERC20 that HopV2 pulls and that must equal bridgeData.sendingAssetId)
    /// @param dstEid The LayerZero endpoint ID of the destination chain. Cross-checked
    ///        against the EID configured for bridgeData.destinationChainId.
    /// @param nativeFee The native LayerZero fee forwarded to HopV2 as msg.value on standard
    ///        chains; ignored on Tempo (fee is paid in the TIP20 gas token)
    /// @param refundRecipient Address that receives pre-bridge swap leftovers, the dust
    ///        remainder that HopV2 does not bridge, and any excess native that HopV2 refunds
    ///        to the diamond mid-call. Must accept plain native transfers.
    /// @param nonEVMReceiver The bytes32 recipient on a non-EVM destination (e.g. a Solana
    ///        pubkey). Required (non-zero) when bridgeData.receiver is NON_EVM_ADDRESS, and
    ///        MUST be bytes32(0) for EVM destinations so the two receiver fields can never
    ///        disagree about where the funds go.
    struct FraxData {
        address oft;
        uint32 dstEid;
        uint256 nativeFee;
        address refundRecipient;
        bytes32 nonEVMReceiver;
    }

    /// Events ///

    /// @notice Emitted when the chainId -> LayerZero EID mapping is initialized.
    event FraxChainMappingsInitialized(ChainIdConfig[] chainIdConfigs);

    /// @notice Emitted when a chainId -> LayerZero EID entry is set or updated.
    event FraxChainIdToEidSet(uint256 indexed chainId, uint32 lzEid);

    /// @notice Emitted when a chainId -> LayerZero EID entry is removed.
    event FraxChainIdToEidUnset(uint256 indexed chainId);

    /// Constructor ///

    /// @notice Initializes the FraxFacet
    /// @param _hop The Frax HopV2 contract on this chain
    /// @param _tipFeeManager The Tempo TIP20 fee manager (address(0) on non-Tempo chains)
    /// @param _pathUsd The default Tempo gas token PATH_USD (address(0) on non-Tempo chains)
    constructor(IFraxHopV2 _hop, address _tipFeeManager, address _pathUsd) {
        // The Tempo fee-token path needs both the fee manager and a default gas token; they
        // are either both set (Tempo) or both zero (every standard chain). A half-configured
        // deployment would revert deep inside the Tempo branch at bridge time.
        if (
            address(_hop) == address(0) ||
            ((_tipFeeManager == address(0)) != (_pathUsd == address(0)))
        ) {
            revert InvalidConfig();
        }
        FRAX_HOP = _hop;
        FRAX_TIP_FEE_MANAGER = _tipFeeManager;
        FRAX_PATH_USD = _pathUsd;
    }

    /// Admin Methods ///

    /// @notice Seeds the chainId -> LayerZero EID mapping (owner-only).
    /// @param _chainIdConfigs Batch of `{chainId, lzEid}` entries.
    /// @dev Overwrites any existing entries for the supplied chain IDs.
    function initFrax(ChainIdConfig[] calldata _chainIdConfigs) external {
        if (_chainIdConfigs.length == 0) revert InvalidConfig();
        LibDiamond.enforceIsContractOwner();

        Storage storage s = _getStorage();

        for (uint256 i = 0; i < _chainIdConfigs.length; ++i) {
            uint256 chainId = _chainIdConfigs[i].chainId;
            uint32 lzEid = _chainIdConfigs[i].lzEid;

            // `lzEid == 0` collides with the "unset" sentinel, so it would emit a
            // successful event yet leave the chain unusable; `chainId == 0` can never
            // match a real destination.
            if (chainId == 0 || lzEid == 0) revert InvalidConfig();

            s.lzEids[chainId] = lzEid;
            emit FraxChainIdToEidSet(chainId, lzEid);
        }

        s.chainMappingsInitialized = true;

        emit FraxChainMappingsInitialized(_chainIdConfigs);
    }

    /// @notice Adds or updates chainId -> LayerZero EID entries (owner-only).
    /// @param _chainIdConfigs Batch of `{chainId, lzEid}` entries.
    function setFraxChainIdToEid(
        ChainIdConfig[] calldata _chainIdConfigs
    ) external {
        if (_chainIdConfigs.length == 0) revert InvalidConfig();
        LibDiamond.enforceIsContractOwner();

        Storage storage s = _getStorage();
        if (!s.chainMappingsInitialized) revert NotInitialized();

        for (uint256 i = 0; i < _chainIdConfigs.length; ++i) {
            uint256 chainId = _chainIdConfigs[i].chainId;
            uint32 lzEid = _chainIdConfigs[i].lzEid;

            if (chainId == 0 || lzEid == 0) revert InvalidConfig();

            s.lzEids[chainId] = lzEid;
            emit FraxChainIdToEidSet(chainId, lzEid);
        }
    }

    /// @notice Removes chainId -> LayerZero EID entries, disabling those destinations
    ///         (owner-only).
    /// @param _chainIds Batch of LI.FI chain IDs to remove.
    /// @dev Deleting a config entry is not enough on its own: `initFrax` writes the mapping
    ///      into diamond storage, so a destination stays routable on every diamond already
    ///      seeded with it until it is removed here. Needed to retire a spoke Frax
    ///      deprecates from the hop mesh. Reverts `UnsupportedChainId` on an entry that is
    ///      not set, so a mistyped chain ID fails loudly instead of silently doing nothing.
    function unsetFraxChainIdToEid(uint256[] calldata _chainIds) external {
        if (_chainIds.length == 0) revert InvalidConfig();
        LibDiamond.enforceIsContractOwner();

        Storage storage s = _getStorage();
        if (!s.chainMappingsInitialized) revert NotInitialized();

        for (uint256 i = 0; i < _chainIds.length; ++i) {
            uint256 chainId = _chainIds[i];

            if (s.lzEids[chainId] == 0) revert UnsupportedChainId(chainId);

            delete s.lzEids[chainId];
            emit FraxChainIdToEidUnset(chainId);
        }
    }

    /// @notice Returns the LayerZero EID configured for `_chainId`.
    /// @param _chainId LI.FI chain ID to look up.
    /// @return lzEid LayerZero endpoint ID.
    function getFraxChainIdToEid(
        uint256 _chainId
    ) public view returns (uint32 lzEid) {
        lzEid = _getStorage().lzEids[_chainId];
        if (lzEid == 0) revert UnsupportedChainId(_chainId);
    }

    /// External Methods ///

    /// @notice Bridges tokens via Frax HopV2
    /// @param _bridgeData The core information needed for bridging
    /// @param _fraxData Data specific to Frax HopV2
    function startBridgeTokensViaFrax(
        ILiFi.BridgeData calldata _bridgeData,
        FraxData calldata _fraxData
    )
        external
        payable
        nonReentrant
        refundExcessNative(payable(_fraxData.refundRecipient))
        validateBridgeData(_bridgeData)
        doesNotContainSourceSwaps(_bridgeData)
        doesNotContainDestinationCalls(_bridgeData)
        noNativeAsset(_bridgeData)
    {
        _validateFraxData(
            _bridgeData.destinationChainId,
            _bridgeData.sendingAssetId,
            _bridgeData.receiver,
            _fraxData
        );

        // On standard chains the LayerZero fee is the only native outflow and must come from
        // msg.value, never from stray diamond balance. On Tempo the fee is an ERC20, so no
        // native should be sent at all (EndpointV2Alt would revert on non-zero msg.value).
        if (FRAX_TIP_FEE_MANAGER == address(0)) {
            if (_fraxData.nativeFee > msg.value) {
                revert InvalidCallData();
            }
        } else if (msg.value != 0) {
            revert InvalidCallData();
        }

        LibAsset.depositAsset(
            _bridgeData.sendingAssetId,
            _bridgeData.minAmount
        );
        _startBridge(_bridgeData, _fraxData);
    }

    /// @notice Performs a swap before bridging via Frax HopV2
    /// @param _bridgeData The core information needed for bridging
    /// @param _swapData An array of swap related data for performing swaps before bridging
    /// @param _fraxData Data specific to Frax HopV2
    function swapAndStartBridgeTokensViaFrax(
        ILiFi.BridgeData memory _bridgeData,
        LibSwap.SwapData[] calldata _swapData,
        FraxData calldata _fraxData
    )
        external
        payable
        nonReentrant
        refundExcessNative(payable(_fraxData.refundRecipient))
        validateBridgeData(_bridgeData)
        containsSourceSwaps(_bridgeData)
        doesNotContainDestinationCalls(_bridgeData)
        noNativeAsset(_bridgeData)
    {
        _validateFraxData(
            _bridgeData.destinationChainId,
            _bridgeData.sendingAssetId,
            _bridgeData.receiver,
            _fraxData
        );

        // On Tempo the fee is an ERC20 and no native is ever consumed; reject stray msg.value
        // here too (symmetric with the non-swap path) so it fails fast instead of being
        // silently refunded late.
        if (FRAX_TIP_FEE_MANAGER != address(0) && msg.value != 0) {
            revert InvalidCallData();
        }

        // The final swap output must be the bridged asset: _depositAndSwap measures the
        // slippage floor in the last swap's receivingAssetId, while _startBridge floors,
        // approves and bridges _bridgeData.sendingAssetId. A mismatch would validate one token
        // and bridge another. An empty array is left to _depositAndSwap (reverts NoSwapData).
        if (
            _swapData.length != 0 &&
            _swapData[_swapData.length - 1].receivingAssetId !=
            _bridgeData.sendingAssetId
        ) {
            revert InformationMismatch();
        }

        // NOTE: nativeFee is intentionally NOT checked against msg.value here (unlike the
        // non-swap path): on standard chains the fee may be funded by an ERC20->native
        // pre-swap whose output the nativeReserve below keeps in the diamond. On Tempo the
        // fee is an ERC20 and there is no native reserve.
        _bridgeData.minAmount = _depositAndSwap(
            _bridgeData.transactionId,
            _bridgeData.minAmount,
            _swapData,
            payable(_fraxData.refundRecipient),
            FRAX_TIP_FEE_MANAGER == address(0) ? _fraxData.nativeFee : 0
        );

        _startBridge(_bridgeData, _fraxData);
    }

    /// Internal Methods ///

    /// @dev Validates FraxData and the bridgeData fields it must agree with. Every check here
    ///      is a pure calldata/config check, so both entry points run it BEFORE depositing or
    ///      swapping: a bad route then costs only the validation gas instead of the full
    ///      deposit + swap + sendOFT path before reverting (the whole tx reverts either way,
    ///      so no funds are at risk — this is a gas and error-clarity guarantee).
    /// @param _destinationChainId The LI.FI destination chain ID from bridgeData
    /// @param _sendingAssetId The ERC20 to be bridged (bridgeData.sendingAssetId)
    /// @param _receiver The destination recipient from bridgeData
    /// @param _fraxData Data specific to Frax HopV2
    function _validateFraxData(
        uint256 _destinationChainId,
        address _sendingAssetId,
        address _receiver,
        FraxData calldata _fraxData
    ) internal view {
        // refundExcessNative forwards excess native to refundRecipient; a zero address would
        // only revert late, when fee drift happens to leave an excess. Fail fast instead.
        // dstEid == 0 is never a valid LayerZero endpoint and would strand the transfer.
        if (
            _fraxData.refundRecipient == address(0) ||
            _fraxData.oft == address(0) ||
            _fraxData.dstEid == 0
        ) {
            revert InvalidCallData();
        }

        // The recipient encoding depends on the destination's address format, so the sentinel
        // and the destination kind must agree in BOTH directions:
        //  - sentinel + non-EVM destination -> the real recipient travels in nonEVMReceiver,
        //  - plain address + EVM destination -> the recipient is the 20-byte receiver.
        // A non-EVM destination reached with a 20-byte receiver would left-pad an EVM address
        // into a 32-byte Solana pubkey and strand the funds at an unspendable account, and the
        // sentinel on an EVM destination would deliver them to NON_EVM_ADDRESS itself.
        if (_isNonEVMDestination(_destinationChainId)) {
            if (_receiver != NON_EVM_ADDRESS) revert InvalidReceiver();
            // The pubkey cannot be validated any further on-chain; reject only the zero value.
            if (_fraxData.nonEVMReceiver == bytes32(0)) {
                revert InvalidNonEVMReceiver();
            }
        } else {
            if (_receiver == NON_EVM_ADDRESS) revert InvalidReceiver();
            // An EVM route ignores nonEVMReceiver, so a populated one means the caller
            // disagrees with itself about the recipient. Reject rather than silently pick one.
            if (_fraxData.nonEVMReceiver != bytes32(0)) {
                revert InvalidCallData();
            }
        }

        // dstEid is the actual LayerZero routing target and is trusted from backend calldata;
        // bridgeData.destinationChainId is what analytics/accounting index on. Bind them so a
        // caller cannot route funds to one chain while the transfer is recorded as another.
        // getFraxChainIdToEid reverts UnsupportedChainId when the destination is not configured.
        if (getFraxChainIdToEid(_destinationChainId) != _fraxData.dstEid) {
            revert InformationMismatch();
        }

        // HopV2 only routes OFTs it has been configured with; an unapproved one reverts inside
        // sendOFT. Checked BEFORE oft.token() below so the only external call this facet makes
        // to the caller-supplied oft address is to one the hop itself already allowlists.
        if (!FRAX_HOP.approvedOft(_fraxData.oft)) {
            revert TokenNotSupported();
        }

        // The OFT's underlying token must be exactly what we bridge; otherwise HopV2 would
        // pull a different asset than the one deposited/validated here.
        if (IFraxOFT(_fraxData.oft).token() != _sendingAssetId) {
            revert InformationMismatch();
        }
    }

    /// @dev Whether `_destinationChainId` is a non-EVM chain whose recipient is a raw bytes32
    ///      rather than a 20-byte address. Frax's only non-EVM spoke today is Solana (reached
    ///      via the Fraxtal hub); add further LI.FI non-EVM chain IDs here as Frax adds them.
    /// @param _destinationChainId The LI.FI destination chain ID from bridgeData
    /// @return isNonEVM True when the destination uses bytes32 recipients
    function _isNonEVMDestination(
        uint256 _destinationChainId
    ) internal pure returns (bool isNonEVM) {
        isNonEVM = _destinationChainId == LIFI_CHAIN_ID_SOLANA;
    }

    /// @dev Contains the business logic for bridging via Frax HopV2
    /// @param _bridgeData The core information needed for bridging
    /// @param _fraxData Data specific to Frax HopV2
    function _startBridge(
        ILiFi.BridgeData memory _bridgeData,
        FraxData calldata _fraxData
    ) internal {
        // NOTE: oft.token() == sendingAssetId and FRAX_HOP.approvedOft(oft) are enforced in
        // _validateFraxData, before any deposit or swap.

        // HopV2 floors the amount to the OFT's dust granularity and only pulls the floored
        // amount. Compute it up front so we approve and bridge exactly that, and can return
        // the un-bridged dust to the user instead of leaving it stranded in the diamond.
        uint256 flooredAmount = FRAX_HOP.removeDust(
            _fraxData.oft,
            _bridgeData.minAmount
        );
        if (flooredAmount == 0) {
            revert InvalidCallData();
        }

        LibAsset.maxApproveERC20(
            IERC20(_bridgeData.sendingAssetId),
            address(FRAX_HOP),
            flooredAmount
        );

        // On a non-EVM destination the recipient is the raw bytes32 pubkey; on EVM it is the
        // left-padded 20-byte receiver. _validateFraxData has already bound the sentinel and
        // the destination kind together, so exactly one of these is populated.
        bool isNonEVM = _bridgeData.receiver == NON_EVM_ADDRESS;
        bytes32 recipient = isNonEVM
            ? _fraxData.nonEVMReceiver
            : LibBytes.toBytes32(_bridgeData.receiver);

        if (isNonEVM) {
            emit BridgeToNonEVMChainBytes32(
                _bridgeData.transactionId,
                _bridgeData.destinationChainId,
                _fraxData.nonEVMReceiver
            );
        }

        if (FRAX_TIP_FEE_MANAGER == address(0)) {
            FRAX_HOP.sendOFT{ value: _fraxData.nativeFee }(
                _fraxData.oft,
                _fraxData.dstEid,
                recipient,
                flooredAmount,
                0,
                ""
            );
        } else {
            _sendViaTempo(
                _fraxData,
                _bridgeData.sendingAssetId,
                recipient,
                flooredAmount
            );
        }

        // Return the dust that HopV2 did not bridge to the user (never leave it in the diamond)
        uint256 dust = _bridgeData.minAmount - flooredAmount;
        if (dust != 0) {
            LibAsset.transferAsset(
                _bridgeData.sendingAssetId,
                payable(_fraxData.refundRecipient),
                dust
            );
        }

        // Emit the amount actually bridged so downstream accounting matches what arrives on dst
        _bridgeData.minAmount = flooredAmount;

        emit LiFiTransferStarted(_bridgeData);
    }

    /// @dev Tempo (EndpointV2Alt) send path: the LayerZero fee is a TIP20 ERC20, not native.
    ///      The facet pulls _fraxData.nativeFee of the fee token from the caller, approves HopV2,
    ///      and HopV2 requotes and pulls its actual fee on sendOFT (msg.value is 0); any unpulled
    ///      remainder is swept to refundRecipient. The fee token is
    ///      FRAX_TIP_FEE_MANAGER.userTokens(diamond), else FRAX_PATH_USD, and must differ from
    ///      the bridged asset (reverts InformationMismatch on collision).
    /// @param _fraxData Data specific to Frax HopV2
    /// @param _sendingAssetId The bridged ERC20 (bridgeData.sendingAssetId)
    /// @param _recipient bytes32-encoded destination recipient
    /// @param _amount The dust-floored amount to bridge
    function _sendViaTempo(
        FraxData calldata _fraxData,
        address _sendingAssetId,
        bytes32 _recipient,
        uint256 _amount
    ) internal {
        address feeToken = ITipFeeManager(FRAX_TIP_FEE_MANAGER).userTokens(
            address(this)
        );
        if (feeToken == address(0)) {
            feeToken = FRAX_PATH_USD;
        }

        // The unused-fee sweep below tracks the fee token by a balance delta taken after the
        // bridged token has already been deposited. If the fee token were the same ERC20 we
        // are bridging, that delta would conflate the two flows and could strand the bridged
        // amount in the diamond. A Frax gas token is never the bridged OFT, so reject the
        // collision rather than mis-account for it.
        if (feeToken == _sendingAssetId) {
            revert InformationMismatch();
        }

        // Snapshot before the deposit so any fee token HopV2 does not pull can be returned to
        // the caller without touching a pre-existing diamond balance. HopV2 requotes and pulls
        // in the same tx; the diamond holds only the just-deposited nativeFee, so HopV2 can pull
        // at most that - a higher fee reverts on HopV2's transferFrom.
        uint256 feeTokenBalanceBefore = IERC20(feeToken).balanceOf(
            address(this)
        );

        if (_fraxData.nativeFee != 0) {
            LibAsset.depositAsset(feeToken, _fraxData.nativeFee);
            LibAsset.maxApproveERC20(
                IERC20(feeToken),
                address(FRAX_HOP),
                _fraxData.nativeFee
            );
        }

        FRAX_HOP.sendOFT(
            _fraxData.oft,
            _fraxData.dstEid,
            _recipient,
            _amount,
            0,
            ""
        );

        // Sweep the fee token HopV2 did not pull back to the caller. Guard the subtraction: if
        // the diamond held an incidental pre-existing feeToken balance an over-pull could push
        // the post-send balance below the baseline; degrade to "no refund" rather than revert an
        // otherwise-valid bridge with an arithmetic panic.
        uint256 feeTokenBalanceAfter = IERC20(feeToken).balanceOf(
            address(this)
        );
        uint256 unusedFee = feeTokenBalanceAfter > feeTokenBalanceBefore
            ? feeTokenBalanceAfter - feeTokenBalanceBefore
            : 0;
        if (unusedFee != 0) {
            LibAsset.transferAsset(
                feeToken,
                payable(_fraxData.refundRecipient),
                unusedFee
            );
        }
    }

    /// @dev Fetches diamond storage.
    function _getStorage() private pure returns (Storage storage s) {
        bytes32 namespace = NAMESPACE;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            s.slot := namespace
        }
    }
}


// ===== lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol =====
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}


// ===== lib/solady/src/utils/SafeTransferLib.sol =====
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/SafeTransferLib.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SafeTransferLib.sol)
/// @author Permit2 operations from (https://github.com/Uniswap/permit2/blob/main/src/libraries/Permit2Lib.sol)
///
/// @dev Note:
/// - For ETH transfers, please use `forceSafeTransferETH` for DoS protection.
/// - For ERC20s, this implementation won't check that a token has code,
///   responsibility is delegated to the caller.
library SafeTransferLib {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       CUSTOM ERRORS                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The ETH transfer has failed.
    error ETHTransferFailed();

    /// @dev The ERC20 `transferFrom` has failed.
    error TransferFromFailed();

    /// @dev The ERC20 `transfer` has failed.
    error TransferFailed();

    /// @dev The ERC20 `approve` has failed.
    error ApproveFailed();

    /// @dev The Permit2 operation has failed.
    error Permit2Failed();

    /// @dev The Permit2 amount must be less than `2**160 - 1`.
    error Permit2AmountOverflow();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         CONSTANTS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Suggested gas stipend for contract receiving ETH that disallows any storage writes.
    uint256 internal constant GAS_STIPEND_NO_STORAGE_WRITES = 2300;

    /// @dev Suggested gas stipend for contract receiving ETH to perform a few
    /// storage reads and writes, but low enough to prevent griefing.
    uint256 internal constant GAS_STIPEND_NO_GRIEF = 100000;

    /// @dev The unique EIP-712 domain domain separator for the DAI token contract.
    bytes32 internal constant DAI_DOMAIN_SEPARATOR =
        0xdbb8cf42e1ecb028be3f3dbc922e1d878b963f411dc388ced501601c60f7c6f7;

    /// @dev The address for the WETH9 contract on Ethereum mainnet.
    address internal constant WETH9 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    /// @dev The canonical Permit2 address.
    /// [Github](https://github.com/Uniswap/permit2)
    /// [Etherscan](https://etherscan.io/address/0x000000000022D473030F116dDEE9F6B43aC78BA3)
    address internal constant PERMIT2 = 0x000000000022D473030F116dDEE9F6B43aC78BA3;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       ETH OPERATIONS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // If the ETH transfer MUST succeed with a reasonable gas budget, use the force variants.
    //
    // The regular variants:
    // - Forwards all remaining gas to the target.
    // - Reverts if the target reverts.
    // - Reverts if the current contract has insufficient balance.
    //
    // The force variants:
    // - Forwards with an optional gas stipend
    //   (defaults to `GAS_STIPEND_NO_GRIEF`, which is sufficient for most cases).
    // - If the target reverts, or if the gas stipend is exhausted,
    //   creates a temporary contract to force send the ETH via `SELFDESTRUCT`.
    //   Future compatible with `SENDALL`: https://eips.ethereum.org/EIPS/eip-4758.
    // - Reverts if the current contract has insufficient balance.
    //
    // The try variants:
    // - Forwards with a mandatory gas stipend.
    // - Instead of reverting, returns whether the transfer succeeded.

    /// @dev Sends `amount` (in wei) ETH to `to`.
    function safeTransferETH(address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(call(gas(), to, amount, codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Sends all the ETH in the current contract to `to`.
    function safeTransferAllETH(address to) internal {
        /// @solidity memory-safe-assembly
        assembly {
            // Transfer all the ETH and check if it succeeded or not.
            if iszero(call(gas(), to, selfbalance(), codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Force sends `amount` (in wei) ETH to `to`, with a `gasStipend`.
    function forceSafeTransferETH(address to, uint256 amount, uint256 gasStipend) internal {
        /// @solidity memory-safe-assembly
        assembly {
            if lt(selfbalance(), amount) {
                mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                revert(0x1c, 0x04)
            }
            if iszero(call(gasStipend, to, amount, codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                if iszero(create(amount, 0x0b, 0x16)) { revert(codesize(), codesize()) } // For gas estimation.
            }
        }
    }

    /// @dev Force sends all the ETH in the current contract to `to`, with a `gasStipend`.
    function forceSafeTransferAllETH(address to, uint256 gasStipend) internal {
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(call(gasStipend, to, selfbalance(), codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                if iszero(create(selfbalance(), 0x0b, 0x16)) { revert(codesize(), codesize()) } // For gas estimation.
            }
        }
    }

    /// @dev Force sends `amount` (in wei) ETH to `to`, with `GAS_STIPEND_NO_GRIEF`.
    function forceSafeTransferETH(address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            if lt(selfbalance(), amount) {
                mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                revert(0x1c, 0x04)
            }
            if iszero(call(GAS_STIPEND_NO_GRIEF, to, amount, codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                if iszero(create(amount, 0x0b, 0x16)) { revert(codesize(), codesize()) } // For gas estimation.
            }
        }
    }

    /// @dev Force sends all the ETH in the current contract to `to`, with `GAS_STIPEND_NO_GRIEF`.
    function forceSafeTransferAllETH(address to) internal {
        /// @solidity memory-safe-assembly
        assembly {
            // forgefmt: disable-next-item
            if iszero(call(GAS_STIPEND_NO_GRIEF, to, selfbalance(), codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                if iszero(create(selfbalance(), 0x0b, 0x16)) { revert(codesize(), codesize()) } // For gas estimation.
            }
        }
    }

    /// @dev Sends `amount` (in wei) ETH to `to`, with a `gasStipend`.
    function trySafeTransferETH(address to, uint256 amount, uint256 gasStipend)
        internal
        returns (bool success)
    {
        /// @solidity memory-safe-assembly
        assembly {
            success := call(gasStipend, to, amount, codesize(), 0x00, codesize(), 0x00)
        }
    }

    /// @dev Sends all the ETH in the current contract to `to`, with a `gasStipend`.
    function trySafeTransferAllETH(address to, uint256 gasStipend)
        internal
        returns (bool success)
    {
        /// @solidity memory-safe-assembly
        assembly {
            success := call(gasStipend, to, selfbalance(), codesize(), 0x00, codesize(), 0x00)
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      ERC20 OPERATIONS                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Sends `amount` of ERC20 `token` from `from` to `to`.
    /// Reverts upon failure.
    ///
    /// The `from` account must have at least `amount` approved for
    /// the current contract to manage.
    function safeTransferFrom(address token, address from, address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x60, amount) // Store the `amount` argument.
            mstore(0x40, to) // Store the `to` argument.
            mstore(0x2c, shl(96, from)) // Store the `from` argument.
            mstore(0x0c, 0x23b872dd000000000000000000000000) // `transferFrom(address,address,uint256)`.
            // Perform the transfer, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                    call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x7939f424) // `TransferFromFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x60, 0) // Restore the zero slot to zero.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Sends `amount` of ERC20 `token` from `from` to `to`.
    ///
    /// The `from` account must have at least `amount` approved for the current contract to manage.
    function trySafeTransferFrom(address token, address from, address to, uint256 amount)
        internal
        returns (bool success)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x60, amount) // Store the `amount` argument.
            mstore(0x40, to) // Store the `to` argument.
            mstore(0x2c, shl(96, from)) // Store the `from` argument.
            mstore(0x0c, 0x23b872dd000000000000000000000000) // `transferFrom(address,address,uint256)`.
            success :=
                and( // The arguments of `and` are evaluated from right to left.
                    or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                    call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
                )
            mstore(0x60, 0) // Restore the zero slot to zero.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Sends all of ERC20 `token` from `from` to `to`.
    /// Reverts upon failure.
    ///
    /// The `from` account must have their entire balance approved for the current contract to manage.
    function safeTransferAllFrom(address token, address from, address to)
        internal
        returns (uint256 amount)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x40, to) // Store the `to` argument.
            mstore(0x2c, shl(96, from)) // Store the `from` argument.
            mstore(0x0c, 0x70a08231000000000000000000000000) // `balanceOf(address)`.
            // Read the balance, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    gt(returndatasize(), 0x1f), // At least 32 bytes returned.
                    staticcall(gas(), token, 0x1c, 0x24, 0x60, 0x20)
                )
            ) {
                mstore(0x00, 0x7939f424) // `TransferFromFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x00, 0x23b872dd) // `transferFrom(address,address,uint256)`.
            amount := mload(0x60) // The `amount` is already at 0x60. We'll need to return it.
            // Perform the transfer, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                    call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x7939f424) // `TransferFromFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x60, 0) // Restore the zero slot to zero.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Sends `amount` of ERC20 `token` from the current contract to `to`.
    /// Reverts upon failure.
    function safeTransfer(address token, address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x14, to) // Store the `to` argument.
            mstore(0x34, amount) // Store the `amount` argument.
            mstore(0x00, 0xa9059cbb000000000000000000000000) // `transfer(address,uint256)`.
            // Perform the transfer, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x90b8ec18) // `TransferFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x34, 0) // Restore the part of the free memory pointer that was overwritten.
        }
    }

    /// @dev Sends all of ERC20 `token` from the current contract to `to`.
    /// Reverts upon failure.
    function safeTransferAll(address token, address to) internal returns (uint256 amount) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, 0x70a08231) // Store the function selector of `balanceOf(address)`.
            mstore(0x20, address()) // Store the address of the current contract.
            // Read the balance, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    gt(returndatasize(), 0x1f), // At least 32 bytes returned.
                    staticcall(gas(), token, 0x1c, 0x24, 0x34, 0x20)
                )
            ) {
                mstore(0x00, 0x90b8ec18) // `TransferFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x14, to) // Store the `to` argument.
            amount := mload(0x34) // The `amount` is already at 0x34. We'll need to return it.
            mstore(0x00, 0xa9059cbb000000000000000000000000) // `transfer(address,uint256)`.
            // Perform the transfer, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x90b8ec18) // `TransferFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x34, 0) // Restore the part of the free memory pointer that was overwritten.
        }
    }

    /// @dev Sets `amount` of ERC20 `token` for `to` to manage on behalf of the current contract.
    /// Reverts upon failure.
    function safeApprove(address token, address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x14, to) // Store the `to` argument.
            mstore(0x34, amount) // Store the `amount` argument.
            mstore(0x00, 0x095ea7b3000000000000000000000000) // `approve(address,uint256)`.
            // Perform the approval, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x3e3f8f73) // `ApproveFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x34, 0) // Restore the part of the free memory pointer that was overwritten.
        }
    }

    /// @dev Sets `amount` of ERC20 `token` for `to` to manage on behalf of the current contract.
    /// If the initial attempt to approve fails, attempts to reset the approved amount to zero,
    /// then retries the approval again (some tokens, e.g. USDT, requires this).
    /// Reverts upon failure.
    function safeApproveWithRetry(address token, address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x14, to) // Store the `to` argument.
            mstore(0x34, amount) // Store the `amount` argument.
            mstore(0x00, 0x095ea7b3000000000000000000000000) // `approve(address,uint256)`.
            // Perform the approval, retrying upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                mstore(0x34, 0) // Store 0 for the `amount`.
                mstore(0x00, 0x095ea7b3000000000000000000000000) // `approve(address,uint256)`.
                pop(call(gas(), token, 0, 0x10, 0x44, codesize(), 0x00)) // Reset the approval.
                mstore(0x34, amount) // Store back the original `amount`.
                // Retry the approval, reverting upon failure.
                if iszero(
                    and(
                        or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                        call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                    )
                ) {
                    mstore(0x00, 0x3e3f8f73) // `ApproveFailed()`.
                    revert(0x1c, 0x04)
                }
            }
            mstore(0x34, 0) // Restore the part of the free memory pointer that was overwritten.
        }
    }

    /// @dev Returns the amount of ERC20 `token` owned by `account`.
    /// Returns zero if the `token` does not exist.
    function balanceOf(address token, address account) internal view returns (uint256 amount) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x14, account) // Store the `account` argument.
            mstore(0x00, 0x70a08231000000000000000000000000) // `balanceOf(address)`.
            amount :=
                mul( // The arguments of `mul` are evaluated from right to left.
                    mload(0x20),
                    and( // The arguments of `and` are evaluated from right to left.
                        gt(returndatasize(), 0x1f), // At least 32 bytes returned.
                        staticcall(gas(), token, 0x10, 0x24, 0x20, 0x20)
                    )
                )
        }
    }

    /// @dev Sends `amount` of ERC20 `token` from `from` to `to`.
    /// If the initial attempt fails, try to use Permit2 to transfer the token.
    /// Reverts upon failure.
    ///
    /// The `from` account must have at least `amount` approved for the current contract to manage.
    function safeTransferFrom2(address token, address from, address to, uint256 amount) internal {
        if (!trySafeTransferFrom(token, from, to, amount)) {
            permit2TransferFrom(token, from, to, amount);
        }
    }

    /// @dev Sends `amount` of ERC20 `token` from `from` to `to` via Permit2.
    /// Reverts upon failure.
    function permit2TransferFrom(address token, address from, address to, uint256 amount)
        internal
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            mstore(add(m, 0x74), shr(96, shl(96, token)))
            mstore(add(m, 0x54), amount)
            mstore(add(m, 0x34), to)
            mstore(add(m, 0x20), shl(96, from))
            // `transferFrom(address,address,uint160,address)`.
            mstore(m, 0x36c78516000000000000000000000000)
            let p := PERMIT2
            let exists := eq(chainid(), 1)
            if iszero(exists) { exists := iszero(iszero(extcodesize(p))) }
            if iszero(and(call(gas(), p, 0, add(m, 0x10), 0x84, codesize(), 0x00), exists)) {
                mstore(0x00, 0x7939f4248757f0fd) // `TransferFromFailed()` or `Permit2AmountOverflow()`.
                revert(add(0x18, shl(2, iszero(iszero(shr(160, amount))))), 0x04)
            }
        }
    }

    /// @dev Permit a user to spend a given amount of
    /// another user's tokens via native EIP-2612 permit if possible, falling
    /// back to Permit2 if native permit fails or is not implemented on the token.
    function permit2(
        address token,
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        bool success;
        /// @solidity memory-safe-assembly
        assembly {
            for {} shl(96, xor(token, WETH9)) {} {
                mstore(0x00, 0x3644e515) // `DOMAIN_SEPARATOR()`.
                if iszero(
                    and( // The arguments of `and` are evaluated from right to left.
                        lt(iszero(mload(0x00)), eq(returndatasize(), 0x20)), // Returns 1 non-zero word.
                        // Gas stipend to limit gas burn for tokens that don't refund gas when
                        // an non-existing function is called. 5K should be enough for a SLOAD.
                        staticcall(5000, token, 0x1c, 0x04, 0x00, 0x20)
                    )
                ) { break }
                // After here, we can be sure that token is a contract.
                let m := mload(0x40)
                mstore(add(m, 0x34), spender)
                mstore(add(m, 0x20), shl(96, owner))
                mstore(add(m, 0x74), deadline)
                if eq(mload(0x00), DAI_DOMAIN_SEPARATOR) {
                    mstore(0x14, owner)
                    mstore(0x00, 0x7ecebe00000000000000000000000000) // `nonces(address)`.
                    mstore(add(m, 0x94), staticcall(gas(), token, 0x10, 0x24, add(m, 0x54), 0x20))
                    mstore(m, 0x8fcbaf0c000000000000000000000000) // `IDAIPermit.permit`.
                    // `nonces` is already at `add(m, 0x54)`.
                    // `1` is already stored at `add(m, 0x94)`.
                    mstore(add(m, 0xb4), and(0xff, v))
                    mstore(add(m, 0xd4), r)
                    mstore(add(m, 0xf4), s)
                    success := call(gas(), token, 0, add(m, 0x10), 0x104, codesize(), 0x00)
                    break
                }
                mstore(m, 0xd505accf000000000000000000000000) // `IERC20Permit.permit`.
                mstore(add(m, 0x54), amount)
                mstore(add(m, 0x94), and(0xff, v))
                mstore(add(m, 0xb4), r)
                mstore(add(m, 0xd4), s)
                success := call(gas(), token, 0, add(m, 0x10), 0xe4, codesize(), 0x00)
                break
            }
        }
        if (!success) simplePermit2(token, owner, spender, amount, deadline, v, r, s);
    }

    /// @dev Simple permit on the Permit2 contract.
    function simplePermit2(
        address token,
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40)
            mstore(m, 0x927da105) // `allowance(address,address,address)`.
            {
                let addressMask := shr(96, not(0))
                mstore(add(m, 0x20), and(addressMask, owner))
                mstore(add(m, 0x40), and(addressMask, token))
                mstore(add(m, 0x60), and(addressMask, spender))
                mstore(add(m, 0xc0), and(addressMask, spender))
            }
            let p := mul(PERMIT2, iszero(shr(160, amount)))
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    gt(returndatasize(), 0x5f), // Returns 3 words: `amount`, `expiration`, `nonce`.
                    staticcall(gas(), p, add(m, 0x1c), 0x64, add(m, 0x60), 0x60)
                )
            ) {
                mstore(0x00, 0x6b836e6b8757f0fd) // `Permit2Failed()` or `Permit2AmountOverflow()`.
                revert(add(0x18, shl(2, iszero(p))), 0x04)
            }
            mstore(m, 0x2b67b570) // `Permit2.permit` (PermitSingle variant).
            // `owner` is already `add(m, 0x20)`.
            // `token` is already at `add(m, 0x40)`.
            mstore(add(m, 0x60), amount)
            mstore(add(m, 0x80), 0xffffffffffff) // `expiration = type(uint48).max`.
            // `nonce` is already at `add(m, 0xa0)`.
            // `spender` is already at `add(m, 0xc0)`.
            mstore(add(m, 0xe0), deadline)
            mstore(add(m, 0x100), 0x100) // `signature` offset.
            mstore(add(m, 0x120), 0x41) // `signature` length.
            mstore(add(m, 0x140), r)
            mstore(add(m, 0x160), s)
            mstore(add(m, 0x180), shl(248, v))
            if iszero(call(gas(), p, 0, add(m, 0x1c), 0x184, codesize(), 0x00)) {
                mstore(0x00, 0x6b836e6b) // `Permit2Failed()`.
                revert(0x1c, 0x04)
            }
        }
    }
}


// ===== src/Errors/GenericErrors.sol =====
// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.17;

/// @custom:version 1.0.4
error AlreadyInitialized();
error CannotAuthoriseSelf();
error CannotBridgeToSameNetwork();
error ContractCallNotAllowed();
error CumulativeSlippageTooHigh(uint256 minAmount, uint256 receivedAmount);
// TODO: migrate EcoFacet/UnitFacet/NEARIntentsFacet deadline reverts to use this.
error DeadlineExpired();
error DiamondIsPaused();
error ETHTransferFailed();
error ExternalCallFailed();
error FunctionDoesNotExist();
error InformationMismatch();
error InsufficientBalance(uint256 required, uint256 balance);
error InvalidAmount();
error InvalidCallData();
error InvalidConfig();
error InvalidContract();
error InvalidDestinationChain();
error InvalidFallbackAddress();
error InvalidNonEVMReceiver();
error InvalidReceiver();
error InvalidSendingToken();
error InvalidSignature();
error NativeAssetNotSupported();
error NativeAssetTransferFailed();
error NoSwapDataProvided();
error NoSwapFromZeroBalance();
error NotAContract();
error NotInitialized();
error NoTransferToNullAddress();
error NullAddrIsNotAnERC20Token();
error NullAddrIsNotAValidSpender();
error OnlyContractOwner();
error RecoveryAddressCannotBeZero();
error ReentrancyError();
error TokenNotSupported();
error TransferFromFailed();
error UnAuthorized();
error UnsupportedChainId(uint256 chainId);
error WithdrawFailed();
error ZeroAmount();


// ===== src/Helpers/LiFiData.sol =====
// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.17;

/// @title LiFiData
/// @author LI.FI (https://li.fi)
/// @notice A storage for LI.FI-internal config data (addresses, chainIDs, etc.)
/// @custom:version 1.0.2
contract LiFiData {
    address internal constant NON_EVM_ADDRESS =
        0x11f111f111f111F111f111f111F111f111f111F1;

    // LI.FI non-EVM Custom Chain IDs (IDs are made up by the LI.FI team)
    uint256 internal constant LIFI_CHAIN_ID_APTOS = 9271000000000010;
    uint256 internal constant LIFI_CHAIN_ID_BCH = 20000000000002;
    uint256 internal constant LIFI_CHAIN_ID_BTC = 20000000000001;
    uint256 internal constant LIFI_CHAIN_ID_DGE = 20000000000004;
    uint256 internal constant LIFI_CHAIN_ID_LTC = 20000000000003;
    uint256 internal constant LIFI_CHAIN_ID_SOLANA = 1151111081099710;
    uint256 internal constant LIFI_CHAIN_ID_STELLAR = 1201081091099710;
    uint256 internal constant LIFI_CHAIN_ID_SUI = 9270000000000000;
    uint256 internal constant LIFI_CHAIN_ID_TRON = 1885080386571452;
    uint256 internal constant LIFI_CHAIN_ID_HYPERCORE = 1337;
}


// ===== src/Helpers/ReentrancyGuard.sol =====
// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.17;

/// @title Reentrancy Guard
/// @author LI.FI (https://li.fi)
/// @notice Abstract contract to provide protection against reentrancy
/// @custom:version 1.0.0
abstract contract ReentrancyGuard {
    /// Storage ///

    bytes32 private constant NAMESPACE = keccak256("com.lifi.reentrancyguard");

    /// Types ///

    struct ReentrancyStorage {
        uint256 status;
    }

    /// Errors ///

    error ReentrancyError();

    /// Constants ///

    uint256 private constant _NOT_ENTERED = 0;
    uint256 private constant _ENTERED = 1;

    /// Modifiers ///

    modifier nonReentrant() {
        ReentrancyStorage storage s = reentrancyStorage();
        if (s.status == _ENTERED) revert ReentrancyError();
        s.status = _ENTERED;
        _;
        s.status = _NOT_ENTERED;
    }

    /// Private Methods ///

    /// @dev fetch local storage
    function reentrancyStorage()
        private
        pure
        returns (ReentrancyStorage storage data)
    {
        bytes32 position = NAMESPACE;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            data.slot := position
        }
    }
}


// ===== src/Helpers/SwapperV2.sol =====
// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.17;

import { ILiFi } from "../Interfaces/ILiFi.sol";
import { LibSwap } from "../Libraries/LibSwap.sol";
import { LibAsset } from "../Libraries/LibAsset.sol";
import { LibAllowList } from "../Libraries/LibAllowList.sol";
import { ContractCallNotAllowed, NoSwapDataProvided, CumulativeSlippageTooHigh } from "../Errors/GenericErrors.sol";

/// @title SwapperV2
/// @author LI.FI (https://li.fi)
/// @notice Abstract contract to provide swap functionality with leftover token handling
/// @custom:version 1.2.0
contract SwapperV2 is ILiFi {
    /// Types ///

    /// @dev only used to get around "Stack Too Deep" errors
    struct ReserveData {
        bytes32 transactionId;
        address payable leftoverReceiver;
        uint256 nativeReserve;
    }

    /// Constants ///
    bytes4 internal constant APPROVE_TO_ONLY_SELECTOR = 0xffffffff;

    /// Modifiers ///

    /// @dev Sends any leftover balances back to the user
    /// @notice Sends any leftover balances to the user
    /// @param _swaps Swap data array
    /// @param _leftoverReceiver Address to send leftover tokens to
    /// @param _initialBalances Array of initial token balances
    modifier noLeftovers(
        LibSwap.SwapData[] calldata _swaps,
        address payable _leftoverReceiver,
        uint256[] memory _initialBalances
    ) {
        _;
        _refundLeftovers(_swaps, _leftoverReceiver, _initialBalances, 0);
    }

    /// @dev Sends any leftover balances back to the user reserving native tokens
    /// @notice Sends any leftover balances to the user
    /// @param _swaps Swap data array
    /// @param _leftoverReceiver Address to send leftover tokens to
    /// @param _initialBalances Array of initial token balances
    /// @param _nativeReserve Amount of native token to prevent from being swept
    modifier noLeftoversReserve(
        LibSwap.SwapData[] calldata _swaps,
        address payable _leftoverReceiver,
        uint256[] memory _initialBalances,
        uint256 _nativeReserve
    ) {
        _;
        _refundLeftovers(
            _swaps,
            _leftoverReceiver,
            _initialBalances,
            _nativeReserve
        );
    }

    /// @dev Refunds any excess native asset sent to the contract after the main function
    /// @notice Refunds any excess native asset sent to the contract after the main function
    /// @param _refundReceiver Address to send refunds to
    modifier refundExcessNative(address payable _refundReceiver) {
        uint256 initialBalance = address(this).balance - msg.value;
        _;
        uint256 finalBalance = address(this).balance;

        if (finalBalance > initialBalance) {
            LibAsset.transferAsset(
                LibAsset.NULL_ADDRESS,
                _refundReceiver,
                finalBalance - initialBalance
            );
        }
    }

    /// Internal Methods ///

    /// @dev Deposits value, executes swaps, and performs minimum amount check
    /// @param _transactionId the transaction id associated with the operation
    /// @param _minAmount the minimum amount of the final asset to receive
    /// @param _swaps Array of data used to execute swaps
    /// @param _leftoverReceiver The address to send leftover funds to
    /// @return uint256 result of the swap
    function _depositAndSwap(
        bytes32 _transactionId,
        uint256 _minAmount,
        LibSwap.SwapData[] calldata _swaps,
        address payable _leftoverReceiver
    ) internal returns (uint256) {
        uint256 numSwaps = _swaps.length;

        if (numSwaps == 0) {
            revert NoSwapDataProvided();
        }

        address finalTokenId = _swaps[numSwaps - 1].receivingAssetId;
        uint256 initialBalance = LibAsset.getOwnBalance(finalTokenId);

        if (LibAsset.isNativeAsset(finalTokenId)) {
            initialBalance -= msg.value;
        }

        uint256[] memory initialBalances = _fetchBalances(_swaps);

        LibAsset.depositAssets(_swaps);

        _executeSwaps(
            _transactionId,
            _swaps,
            _leftoverReceiver,
            initialBalances
        );

        uint256 newBalance = LibAsset.getOwnBalance(finalTokenId) -
            initialBalance;

        if (newBalance < _minAmount) {
            revert CumulativeSlippageTooHigh(_minAmount, newBalance);
        }

        return newBalance;
    }

    /// @dev Deposits value, executes swaps, and performs minimum amount check and reserves native token for fees
    /// @param _transactionId the transaction id associated with the operation
    /// @param _minAmount the minimum amount of the final asset to receive
    /// @param _swaps Array of data used to execute swaps
    /// @param _leftoverReceiver The address to send leftover funds to
    /// @param _nativeReserve Amount of native token to prevent from being swept back to the caller
    function _depositAndSwap(
        bytes32 _transactionId,
        uint256 _minAmount,
        LibSwap.SwapData[] calldata _swaps,
        address payable _leftoverReceiver,
        uint256 _nativeReserve
    ) internal returns (uint256) {
        uint256 numSwaps = _swaps.length;

        if (numSwaps == 0) {
            revert NoSwapDataProvided();
        }

        address finalTokenId = _swaps[numSwaps - 1].receivingAssetId;
        uint256 initialBalance = LibAsset.getOwnBalance(finalTokenId);

        if (LibAsset.isNativeAsset(finalTokenId)) {
            initialBalance -= msg.value;
        }

        uint256[] memory initialBalances = _fetchBalances(_swaps);

        LibAsset.depositAssets(_swaps);

        ReserveData memory reserveData = ReserveData({
            transactionId: _transactionId,
            leftoverReceiver: _leftoverReceiver,
            nativeReserve: _nativeReserve
        });

        _executeSwaps(reserveData, _swaps, initialBalances);

        uint256 newBalance = LibAsset.getOwnBalance(finalTokenId) -
            initialBalance;

        if (LibAsset.isNativeAsset(finalTokenId)) {
            newBalance -= _nativeReserve;
        }

        if (newBalance < _minAmount) {
            revert CumulativeSlippageTooHigh(_minAmount, newBalance);
        }

        return newBalance;
    }

    /// Private Methods ///

    /// @dev Executes swaps and checks that DEXs used are whitelisted via granular contract-selector pairs.
    /// @notice For non-native assets, if approveTo != callTo, approveTo must be whitelisted with
    ///         APPROVE_TO_ONLY_SELECTOR (0xffffffff) to prevent allowance leaks.
    /// @param _transactionId the transaction id associated with the operation
    /// @param _swaps Array of data used to execute swaps
    /// @param _leftoverReceiver Address to send leftover tokens to
    /// @param _initialBalances Array of initial balances
    function _executeSwaps(
        bytes32 _transactionId,
        LibSwap.SwapData[] calldata _swaps,
        address payable _leftoverReceiver,
        uint256[] memory _initialBalances
    ) internal noLeftovers(_swaps, _leftoverReceiver, _initialBalances) {
        uint256 numSwaps = _swaps.length;
        address callTo;
        address approveTo;
        for (uint256 i; i < numSwaps; ) {
            LibSwap.SwapData calldata currentSwap = _swaps[i];
            callTo = currentSwap.callTo;
            approveTo = currentSwap.approveTo;

            if (
                !LibAllowList.contractSelectorIsAllowed(
                    callTo,
                    bytes4(currentSwap.callData[:4])
                ) ||
                (!LibAsset.isNativeAsset(currentSwap.sendingAssetId) &&
                    approveTo != callTo &&
                    !LibAllowList.contractSelectorIsAllowed(
                        approveTo,
                        APPROVE_TO_ONLY_SELECTOR
                    ))
            ) revert ContractCallNotAllowed();

            LibSwap.swap(_transactionId, currentSwap);
            unchecked {
                ++i;
            }
        }
    }

    /// @dev Executes swaps and checks that DEXs used are whitelisted via granular contract-selector pairs.
    /// @notice For non-native assets, if approveTo != callTo, approveTo must be whitelisted with
    ///         APPROVE_TO_ONLY_SELECTOR (0xffffffff) to prevent allowance leaks.
    /// @param _reserveData Data passed used to reserve native tokens
    /// @param _swaps Array of data used to execute swaps
    /// @param _initialBalances Array of initial balances
    function _executeSwaps(
        ReserveData memory _reserveData,
        LibSwap.SwapData[] calldata _swaps,
        uint256[] memory _initialBalances
    )
        internal
        noLeftoversReserve(
            _swaps,
            _reserveData.leftoverReceiver,
            _initialBalances,
            _reserveData.nativeReserve
        )
    {
        uint256 numSwaps = _swaps.length;
        address callTo;
        address approveTo;
        for (uint256 i; i < numSwaps; ) {
            LibSwap.SwapData calldata currentSwap = _swaps[i];
            callTo = currentSwap.callTo;
            approveTo = currentSwap.approveTo;

            if (
                !LibAllowList.contractSelectorIsAllowed(
                    callTo,
                    bytes4(currentSwap.callData[:4])
                ) ||
                (!LibAsset.isNativeAsset(currentSwap.sendingAssetId) &&
                    approveTo != callTo &&
                    !LibAllowList.contractSelectorIsAllowed(
                        approveTo,
                        APPROVE_TO_ONLY_SELECTOR
                    ))
            ) revert ContractCallNotAllowed();

            LibSwap.swap(_reserveData.transactionId, currentSwap);
            unchecked {
                ++i;
            }
        }
    }

    /// @dev Fetches balances of tokens to be swapped before swapping.
    /// @param _swaps Array of data used to execute swaps
    /// @return uint256[] Array of token balances.
    function _fetchBalances(
        LibSwap.SwapData[] calldata _swaps
    ) internal view returns (uint256[] memory) {
        uint256 numSwaps = _swaps.length;
        uint256[] memory balances = new uint256[](numSwaps);
        address asset;
        for (uint256 i; i < numSwaps; ++i) {
            asset = _swaps[i].receivingAssetId;
            balances[i] = LibAsset.getOwnBalance(asset);

            if (LibAsset.isNativeAsset(asset)) {
                balances[i] -= msg.value;
            }
        }

        return balances;
    }

    /// @dev Refunds leftover tokens to a specified receiver after swaps complete
    /// @param _swaps Swap data array
    /// @param _leftoverReceiver Address to send leftover tokens to
    /// @param _initialBalances Array of initial token balances
    /// @param _nativeReserve Amount of native token to prevent from being swept (0 for no reserve)
    function _refundLeftovers(
        LibSwap.SwapData[] calldata _swaps,
        address payable _leftoverReceiver,
        uint256[] memory _initialBalances,
        uint256 _nativeReserve
    ) private {
        uint256 numSwaps = _swaps.length;
        address finalAsset = _swaps[numSwaps - 1].receivingAssetId;

        // Handle both intermediate receiving assets and leftover input tokens in a single loop
        uint256 leftoverAmount;
        address curAsset;
        address inputAsset;
        uint256 curAssetReserve;
        uint256 currentInputBalance;
        uint256 inputAssetReserve;

        for (uint256 i; i < numSwaps; ++i) {
            // Handle intermediate receiving assets (only for non-final swaps when numSwaps > 1)
            if (i < numSwaps - 1 && numSwaps != 1) {
                curAsset = _swaps[i].receivingAssetId;
                // Handle multiple swap steps
                if (curAsset != finalAsset) {
                    leftoverAmount =
                        LibAsset.getOwnBalance(curAsset) -
                        _initialBalances[i];
                    curAssetReserve = LibAsset.isNativeAsset(curAsset)
                        ? _nativeReserve
                        : 0;
                    if (leftoverAmount > curAssetReserve) {
                        LibAsset.transferAsset(
                            curAsset,
                            _leftoverReceiver,
                            leftoverAmount - curAssetReserve
                        );
                    }
                }
            }

            // Handle leftover input tokens (but never sweep the final receiving asset)
            inputAsset = _swaps[i].sendingAssetId;
            currentInputBalance = LibAsset.getOwnBalance(inputAsset);
            inputAssetReserve = LibAsset.isNativeAsset(inputAsset)
                ? _nativeReserve
                : 0;

            // Only transfer leftovers if there's actually a balance remaining after reserve
            // and if it's not the final receiving asset (which should be kept for bridging)
            if (
                currentInputBalance > inputAssetReserve &&
                inputAsset != finalAsset
            ) {
                LibAsset.transferAsset(
                    inputAsset,
                    _leftoverReceiver,
                    currentInputBalance - inputAssetReserve
                );
            }
        }
    }
}


// ===== src/Helpers/Validatable.sol =====
// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.17;

import { LibAsset } from "../Libraries/LibAsset.sol";
import { LibUtil } from "../Libraries/LibUtil.sol";
// solhint-disable-next-line max-line-length
import { InvalidReceiver, InformationMismatch, InvalidSendingToken, InvalidAmount, NativeAssetNotSupported, InvalidDestinationChain, CannotBridgeToSameNetwork } from "../Errors/GenericErrors.sol";
import { ILiFi } from "../Interfaces/ILiFi.sol";
// solhint-disable-next-line no-unused-import
import { LibSwap } from "../Libraries/LibSwap.sol";

/// @custom:version 1.0.0
contract Validatable {
    modifier validateBridgeData(ILiFi.BridgeData memory _bridgeData) {
        if (LibUtil.isZeroAddress(_bridgeData.receiver)) {
            revert InvalidReceiver();
        }
        if (_bridgeData.minAmount == 0) {
            revert InvalidAmount();
        }
        if (_bridgeData.destinationChainId == block.chainid) {
            revert CannotBridgeToSameNetwork();
        }
        _;
    }

    modifier noNativeAsset(ILiFi.BridgeData memory _bridgeData) {
        if (LibAsset.isNativeAsset(_bridgeData.sendingAssetId)) {
            revert NativeAssetNotSupported();
        }
        _;
    }

    modifier onlyAllowSourceToken(
        ILiFi.BridgeData memory _bridgeData,
        address _token
    ) {
        if (_bridgeData.sendingAssetId != _token) {
            revert InvalidSendingToken();
        }
        _;
    }

    modifier onlyAllowDestinationChain(
        ILiFi.BridgeData memory _bridgeData,
        uint256 _chainId
    ) {
        if (_bridgeData.destinationChainId != _chainId) {
            revert InvalidDestinationChain();
        }
        _;
    }

    modifier containsSourceSwaps(ILiFi.BridgeData memory _bridgeData) {
        if (!_bridgeData.hasSourceSwaps) {
            revert InformationMismatch();
        }
        _;
    }

    modifier doesNotContainSourceSwaps(ILiFi.BridgeData memory _bridgeData) {
        if (_bridgeData.hasSourceSwaps) {
            revert InformationMismatch();
        }
        _;
    }

    modifier doesNotContainDestinationCalls(
        ILiFi.BridgeData memory _bridgeData
    ) {
        if (_bridgeData.hasDestinationCall) {
            revert InformationMismatch();
        }
        _;
    }
}


// ===== src/Interfaces/IFraxHopV2.sol =====
// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.17;

/// @title IFraxHopV2
/// @notice Minimal interface for Frax's HopV2 bridge (LayerZero V2 OFT hub-and-spoke)
/// @author LI.FI (https://li.fi)
/// @custom:version 1.0.0
/// @dev Shadows FraxFinance HopV2/RemoteHopV2 (src/contracts/hop/HopV2.sol)
interface IFraxHopV2 {
    /// @notice Bridges an OFT to a destination chain (plain transfer, no compose)
    /// @param oft Address of the OFT messenger on the source chain
    /// @param dstEid LayerZero endpoint ID of the destination chain
    /// @param recipient bytes32-encoded recipient on the destination chain
    /// @param amountLD Amount to send in local decimals (floored to dust internally)
    /// @param dstGas Gas forwarded to the destination compose (0 for standard transfers)
    /// @param data Extra compose payload (empty for standard transfers)
    function sendOFT(
        address oft,
        uint32 dstEid,
        bytes32 recipient,
        uint256 amountLD,
        uint128 dstGas,
        bytes calldata data
    ) external payable;

    /// @notice Quotes the messaging fee for a hop (native on standard chains, TIP20 on Tempo)
    /// @param oft Address of the OFT messenger on the source chain
    /// @param dstEid LayerZero endpoint ID of the destination chain
    /// @param recipient bytes32-encoded recipient on the destination chain
    /// @param amount Amount to send in local decimals (dust removed internally)
    /// @param dstGas Gas forwarded to the destination compose
    /// @param data Extra compose payload
    /// @return fee The total fee required for the send
    function quote(
        address oft,
        uint32 dstEid,
        bytes32 recipient,
        uint256 amount,
        uint128 dstGas,
        bytes calldata data
    ) external view returns (uint256 fee);

    /// @notice Quotes the fee in a specific ERC20 gas token (Tempo EndpointV2Alt only)
    /// @param oft Address of the OFT messenger on the source chain
    /// @param dstEid LayerZero endpoint ID of the destination chain
    /// @param recipient bytes32-encoded recipient on the destination chain
    /// @param amount Amount to send in local decimals (dust removed internally)
    /// @param dstGas Gas forwarded to the destination compose
    /// @param data Extra compose payload
    /// @param userToken The ERC20 gas token the fee will be paid in
    /// @return fee The fee denominated in userToken
    function quoteStatic(
        address oft,
        uint32 dstEid,
        bytes32 recipient,
        uint256 amount,
        uint128 dstGas,
        bytes calldata data,
        address userToken
    ) external view returns (uint256 fee);

    /// @notice Whether the hop is configured to route this OFT
    /// @param oft Address of the OFT messenger on the source chain
    /// @return approved True if the hop accepts sends for this OFT
    function approvedOft(address oft) external view returns (bool approved);

    /// @notice Floors an amount to the OFT's dust-free granularity
    /// @param oft Address of the OFT messenger
    /// @param amountLD Amount in local decimals
    /// @return flooredAmountLD The amount floored to a decimalConversionRate multiple
    function removeDust(
        address oft,
        uint256 amountLD
    ) external view returns (uint256 flooredAmountLD);
}

/// @title ITipFeeManager
/// @notice Tempo TIP20 fee-manager precompile: resolves a caller's preferred gas token
/// @author LI.FI (https://li.fi)
/// @custom:version 1.0.0
/// @dev Tempo precompile at 0xfeEC000000000000000000000000000000000000
interface ITipFeeManager {
    /// @notice The gas token a user has opted into (address(0) if unset → PATH_USD default)
    /// @param user The account whose preferred gas token to read
    /// @return token The preferred TIP20 gas token, or address(0) if none set
    function userTokens(address user) external view returns (address token);
}

/// @title IFraxOFT
/// @notice Minimal OFT surface used by FraxFacet to resolve the underlying ERC20
/// @author LI.FI (https://li.fi)
/// @custom:version 1.0.0
interface IFraxOFT {
    /// @notice The ERC20 token that the OFT transfers on the local chain
    /// @return The underlying ERC20 token address
    function token() external view returns (address);
}


// ===== src/Interfaces/ILiFi.sol =====
// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.17;

/// @title ILiFi
/// @author LI.FI (https://li.fi)
/// @custom:version 1.0.1
interface ILiFi {
    /// Structs ///

    struct BridgeData {
        bytes32 transactionId;
        string bridge;
        string integrator;
        address referrer;
        address sendingAssetId;
        address receiver;
        uint256 minAmount;
        uint256 destinationChainId;
        bool hasSourceSwaps;
        bool hasDestinationCall;
    }

    /// Events ///

    event LiFiTransferStarted(ILiFi.BridgeData bridgeData);

    event LiFiTransferCompleted(
        bytes32 indexed transactionId,
        address receivingAssetId,
        address receiver,
        uint256 amount,
        uint256 timestamp
    );

    event LiFiTransferRecovered(
        bytes32 indexed transactionId,
        address receivingAssetId,
        address receiver,
        uint256 amount,
        uint256 timestamp
    );

    event LiFiGenericSwapCompleted(
        bytes32 indexed transactionId,
        string integrator,
        string referrer,
        address receiver,
        address fromAssetId,
        address toAssetId,
        uint256 fromAmount,
        uint256 toAmount
    );

    // this event is emitted when a bridge transction is initiated to a non-EVM chain
    event BridgeToNonEVMChain(
        bytes32 indexed transactionId,
        uint256 indexed destinationChainId,
        bytes receiver
    );
    event BridgeToNonEVMChainBytes32(
        bytes32 indexed transactionId,
        uint256 indexed destinationChainId,
        bytes32 receiver
    );

    // Deprecated but kept here to include in ABI to parse historic events
    event LiFiSwappedGeneric(
        bytes32 indexed transactionId,
        string integrator,
        string referrer,
        address fromAssetId,
        address toAssetId,
        uint256 fromAmount,
        uint256 toAmount
    );
}


// ===== src/Libraries/LibAllowList.sol =====
// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.17;

import { InvalidContract, InvalidCallData } from "../Errors/GenericErrors.sol";
import { LibAsset } from "./LibAsset.sol";

/// @title LibAllowList
/// @author LI.FI (https://li.fi)
/// @notice Manages a dual-model allow list to support a secure, granular permissions system
/// while maintaining backward compatibility with a non-granular, global system.
/// @dev This library is the single source of truth for all whitelist state changes.
/// It ensures that both the new granular mapping and the global arrays used by older
/// contracts are kept perfectly synchronized. The long-term goal is to migrate all usage
/// to the new granular system. New development should exclusively use the "Primary Interface" functions.
///
/// Special ApproveTo-Only Selector:
/// - Use 0xffffffff to whitelist contracts that are used only as approveTo in
///   LibSwap.SwapData, without allowing function calls to them.
/// - Some DEXs have specific contracts that need to be approved to while another
///   (router) contract must be called to initiate the swap.
/// - This selector makes contractIsAllowed(_contract) return true for backward
///   compatibility, but does not authorize any granular calls. In the granular
///   system, real function selectors must be explicitly whitelisted to be callable.
/// @custom:version 2.0.0
library LibAllowList {
    /// Storage ///

    bytes32 internal constant NAMESPACE =
        keccak256("com.lifi.library.allow.list");

    struct AllowListStorage {
        // --- STORAGE FOR OLDER VERSIONS ---
        /// @dev [BACKWARD COMPATIBILITY] [V1 DATA] Boolean mapping actively maintained
        /// by functions to support older, deployed contracts that read from it.
        /// Also kept for storage layout compatibility.
        mapping(address => bool) contractAllowList;
        /// @dev [BACKWARD COMPATIBILITY] [V1 DATA] Boolean mapping actively maintained
        /// by functions to support older, deployed contracts that read from it.
        /// Also kept for storage layout compatibility.
        mapping(bytes4 => bool) selectorAllowList;
        /// @dev [BACKWARD COMPATIBILITY] The global list of all unique whitelisted contracts for older facets.
        address[] contracts;
        // --- NEW GRANULAR STORAGE & SYNCHRONIZATION ---
        // These variables form the new, secure, and preferred whitelist system.

        /// @dev [BACKWARD COMPATIBILITY] 1-based index for `contracts` array for efficient removal.
        mapping(address => uint256) contractToIndex;
        /// @dev [BACKWARD COMPATIBILITY] 1-based index for `selectors` array for efficient removal.
        mapping(bytes4 => uint256) selectorToIndex;
        /// @dev [BACKWARD COMPATIBILITY] The global list of all unique whitelisted selectors for older facets.
        bytes4[] selectors;
        /// @dev The SOURCE OF TRUTH for the new granular system.
        mapping(address => mapping(bytes4 => bool)) contractSelectorAllowList;
        /// @dev A global reference count for each selector to manage the `selectors` array for backward compatibility.
        mapping(bytes4 => uint256) selectorReferenceCount;
        /// @dev Iterable list of selectors for each contract, used by the backend getter.
        /// The length of this array also serves as the IMPLICIT contract reference count.
        mapping(address => bytes4[]) whitelistedSelectorsByContract;
        /// @dev 1-based index for `whitelistedSelectorsByContract` array for efficient removal.
        mapping(address => mapping(bytes4 => uint256)) selectorIndices;
        /// @dev Flag to indicate completion of a one-time data migration.
        bool migrated;
    }

    /// @notice Adds a specific contract-selector pair to the allow list.
    /// @dev This is the primary entry point for whitelisting. It updates the granular
    /// mapping and synchronizes the global arrays (for backward compatibility) via reference counting.
    /// @param _contract The contract address.
    /// @param _selector The function selector.
    function addAllowedContractSelector(
        address _contract,
        bytes4 _selector
    ) internal {
        if (_contract == address(0) || _selector == bytes4(0))
            revert InvalidCallData();
        AllowListStorage storage als = _getStorage();

        // Skip if the pair is already allowed.
        if (als.contractSelectorAllowList[_contract][_selector]) return;

        // 1. Update the source of truth for the new system.
        als.contractSelectorAllowList[_contract][_selector] = true;

        // 2. Update the `contracts` variables if this is the first selector for this contract.
        // We use the length of the iterable array as an implicit reference count.
        if (als.whitelistedSelectorsByContract[_contract].length == 0) {
            _addAllowedContract(_contract);
        }

        // 3. Update the `selectors` variables if this is the first time this selector is used globally.
        if (++als.selectorReferenceCount[_selector] == 1) {
            _addAllowedSelector(_selector);
        }

        // 4. Update the iterable list used by the on-chain getter.
        als.whitelistedSelectorsByContract[_contract].push(_selector);
        // Store 1-based index for efficient removal later.
        als.selectorIndices[_contract][_selector] = als
            .whitelistedSelectorsByContract[_contract]
            .length;
    }

    /// @notice Removes a specific contract-selector pair from the allow list.
    /// @dev This is the primary entry point for removal. It updates the granular
    /// mapping and synchronizes the global arrays (for backward compatibility) via reference counting.
    /// @param _contract The contract address.
    /// @param _selector The function selector.
    function removeAllowedContractSelector(
        address _contract,
        bytes4 _selector
    ) internal {
        AllowListStorage storage als = _getStorage();
        // Skip if the pair is not currently allowed.
        if (!als.contractSelectorAllowList[_contract][_selector]) return;

        // 1. Update the source of truth.
        delete als.contractSelectorAllowList[_contract][_selector];

        // 2. Update the iterable list FIRST to get the new length.
        _removeSelectorFromIterableList(_contract, _selector);

        // 3. If the iterable list's new length is 0, it was the last selector,
        // so remove the contract from the global list.
        if (als.whitelistedSelectorsByContract[_contract].length == 0) {
            _removeAllowedContract(_contract);
        }

        // 4. If the global reference count is now 0, it was the last usage of this
        // selector, so remove it from the global list.
        if (--als.selectorReferenceCount[_selector] == 0) {
            _removeAllowedSelector(_selector);
        }
    }

    /// @notice Checks if a specific contract-selector pair is allowed.
    /// @dev Preferred runtime check for all new contracts/facets.
    /// @param _contract The contract address.
    /// @param _selector The function selector.
    /// @return isAllowed True if the contract-selector pair is allowed, false otherwise.
    function contractSelectorIsAllowed(
        address _contract,
        bytes4 _selector
    ) internal view returns (bool) {
        return _getStorage().contractSelectorAllowList[_contract][_selector];
    }

    /// @notice Gets all approved selectors for a specific contract.
    /// @dev Used by the on-chain getter in the facet for backend synchronization.
    /// @param _contract The contract address.
    /// @return selectors The whitelisted selectors for the contract.
    function getWhitelistedSelectorsForContract(
        address _contract
    ) internal view returns (bytes4[] memory) {
        return _getStorage().whitelistedSelectorsByContract[_contract];
    }

    /// Backward Compatibility Interface (V1) ///

    // These functions read from the global arrays. They are required for existing,
    // deployed facets to continue functioning. They should be considered part of a
    // transitional phase and MUST NOT be used in new development.

    /// @notice [Backward Compatibility] Checks if a contract is on the global allow list.
    /// @dev This function reads from the global list and is NOT granular. It is required for
    /// older, deployed facets to function correctly. Avoid use in new code.
    /// @param _contract The contract address.
    /// @return isAllowed True if the contract is allowed, false otherwise.
    function contractIsAllowed(
        address _contract
    ) internal view returns (bool) {
        return _getStorage().contractAllowList[_contract];
    }

    /// @notice [Backward Compatibility] Checks if a selector is on the global allow list.
    /// @dev This function reads from the global list and is NOT granular. It is required for
    /// older, deployed facets to function correctly. Avoid use in new code.
    /// @param _selector The function selector.
    /// @return isAllowed True if the selector is allowed, false otherwise.
    function selectorIsAllowed(bytes4 _selector) internal view returns (bool) {
        return _getStorage().selectorAllowList[_selector];
    }

    /// @notice [Backward Compatibility] Gets the entire global list of whitelisted contracts.
    /// @dev Returns the `contracts` array, which is synchronized with the new granular system.
    /// @return contracts The global list of whitelisted contracts.
    function getAllowedContracts() internal view returns (address[] memory) {
        return _getStorage().contracts;
    }

    /// @notice [Backward Compatibility] Gets the entire global list of whitelisted selectors.
    /// @dev Returns the `selectors` array, which is synchronized with the new granular system.
    function getAllowedSelectors() internal view returns (bytes4[] memory) {
        return _getStorage().selectors;
    }

    /// Private Helpers (Internal Use Only) ///

    /// @dev Internal helper to add a contract to the `contracts` array.
    /// @param _contract The contract address.
    function _addAllowedContract(address _contract) private {
        // Ensure address is actually a contract.
        if (!LibAsset.isContract(_contract)) revert InvalidContract();
        AllowListStorage storage als = _getStorage();

        // Add contract to the old allow list for backward compatibility
        als.contractAllowList[_contract] = true;

        // Skip if contract is already in allow list (1-based index).
        if (als.contractToIndex[_contract] > 0) return;

        // Add contract to allow list array.
        als.contracts.push(_contract);
        // Store 1-based index for efficient removal later.
        als.contractToIndex[_contract] = als.contracts.length;
    }

    /// @dev Internal helper to remove a contract from the `contracts` array.
    /// @param _contract The contract address.
    function _removeAllowedContract(address _contract) private {
        AllowListStorage storage als = _getStorage();

        // The V1 boolean mapping must be cleared before any checks.
        // This delete operation is placed at the top to ensure V1/V2 sync
        // and primarily solves two issues of stale item where
        // V1 data - als.selectorAllowList[_selector]=true,
        // V2 data - als.selectorToIndex[_selector]=0.
        // This scenario is different from selectors; it's an unlikely
        // edge case for contracts because the migration iterates the
        // full on-chain `contracts` array for a "perfect" cleanup.
        // However, this defensive delete ensures the function is robust
        //against any state corruption.
        delete als.contractAllowList[_contract];

        // Get the 1-based index; return if not found.
        uint256 oneBasedIndex = als.contractToIndex[_contract];
        if (oneBasedIndex == 0) {
            return;
        }
        // Convert to 0-based index for array operations.
        uint256 index = oneBasedIndex - 1;
        uint256 lastIndex = als.contracts.length - 1;

        // If the contract to remove isn't the last one,
        // move the last contract to the removed contract's position.
        if (index != lastIndex) {
            address lastContract = als.contracts[lastIndex];
            als.contracts[index] = lastContract;
            als.contractToIndex[lastContract] = oneBasedIndex;
        }

        // Remove the last element and clean up mappings.
        als.contracts.pop();
        delete als.contractToIndex[_contract];
    }

    /// @dev Internal helper to add a selector to the `selectors` array.
    /// @param _selector The function selector.
    function _addAllowedSelector(bytes4 _selector) private {
        AllowListStorage storage als = _getStorage();

        // Add selector to the old allow list for backward compatibility
        als.selectorAllowList[_selector] = true;

        // Skip if selector is already in allow list (1-based index).
        if (als.selectorToIndex[_selector] > 0) return;

        // Add selector to the array.
        als.selectors.push(_selector);

        // Store 1-based index for efficient removal later.
        als.selectorToIndex[_selector] = als.selectors.length;
    }

    /// @dev Internal helper to remove a selector from the `selectors` array.
    /// @param _selector The function selector.
    function _removeAllowedSelector(bytes4 _selector) private {
        AllowListStorage storage als = _getStorage();

        // The V1 boolean mapping must be cleared before any checks.
        // The migration's selector cleanup is "imperfect" as it relies on an
        // off-chain list. A "stale selector" ( V1 data - als.selectorAllowList[_selector]=true, V2 data - als.selectorToIndex[_selector]=0) is possible.
        // Placing `delete` here allows an admin to fix this by
        // add-then-remove, as this line will clean the V1 bool even if
        // the V2 `oneBasedIndex` is 0.
        delete als.selectorAllowList[_selector];

        // Get the 1-based index; return if not found.
        uint256 oneBasedIndex = als.selectorToIndex[_selector];
        if (oneBasedIndex == 0) {
            return;
        }

        // Convert to 0-based index for array operations.
        uint256 index = oneBasedIndex - 1;
        uint256 lastIndex = als.selectors.length - 1;

        // If the selector to remove isn't the last one,
        // move the last selector to the removed selector's position.
        if (index != lastIndex) {
            bytes4 lastSelector = als.selectors[lastIndex];
            als.selectors[index] = lastSelector;
            als.selectorToIndex[lastSelector] = oneBasedIndex;
        }

        // Remove the last element and clean up mappings.
        als.selectors.pop();
        delete als.selectorToIndex[_selector];
    }

    /// @dev Internal helper to manage the iterable array for the getter function.
    /// @param _contract The contract address.
    /// @param _selector The function selector.
    function _removeSelectorFromIterableList(
        address _contract,
        bytes4 _selector
    ) private {
        AllowListStorage storage als = _getStorage();

        // Get the 1-based index; return if not found.
        uint256 oneBasedIndex = als.selectorIndices[_contract][_selector];
        if (oneBasedIndex == 0) return;

        // Convert to 0-based index for array operations.
        uint256 index = oneBasedIndex - 1;
        bytes4[] storage selectorsArray = als.whitelistedSelectorsByContract[
            _contract
        ];
        uint256 lastIndex = selectorsArray.length - 1;

        // If the selector to remove isn't the last one,
        // move the last selector to the removed selector's position.
        if (index != lastIndex) {
            bytes4 lastSelector = selectorsArray[lastIndex];
            selectorsArray[index] = lastSelector;
            als.selectorIndices[_contract][lastSelector] = oneBasedIndex;
        }

        // Remove the last element and clean up mappings.
        selectorsArray.pop();
        delete als.selectorIndices[_contract][_selector];
    }

    /// @dev Fetches the storage pointer for this library.
    /// @return als The storage pointer.
    function _getStorage()
        internal
        pure
        returns (AllowListStorage storage als)
    {
        bytes32 position = NAMESPACE;
        assembly {
            als.slot := position
        }
    }
}


// ===== src/Libraries/LibAsset.sol =====
// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.17;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { LibSwap } from "./LibSwap.sol";
import { SafeTransferLib } from "solady/utils/SafeTransferLib.sol";

// solhint-disable-next-line max-line-length
import { InvalidReceiver, NullAddrIsNotAValidSpender, InvalidAmount, NullAddrIsNotAnERC20Token } from "../Errors/GenericErrors.sol";

/// @title LibAsset
/// @author LI.FI (https://li.fi)
/// @custom:version 2.1.3
/// @notice This library contains helpers for dealing with onchain transfers
///         of assets, including accounting for the native asset `assetId`
///         conventions and any noncompliant ERC20 transfers
library LibAsset {
    using SafeTransferLib for address;
    using SafeTransferLib for address payable;

    /// @dev All native assets use the empty address for their asset id
    ///      by convention
    address internal constant NULL_ADDRESS = address(0);

    /// @dev EIP-7702 delegation designator prefix for Account Abstraction
    bytes3 internal constant DELEGATION_DESIGNATOR = 0xef0100;

    /// @notice Gets the balance of the inheriting contract for the given asset
    /// @param assetId The asset identifier to get the balance of
    /// @return Balance held by contracts using this library (returns 0 if assetId does not exist)
    function getOwnBalance(address assetId) internal view returns (uint256) {
        return
            isNativeAsset(assetId)
                ? address(this).balance
                : assetId.balanceOf(address(this));
    }

    /// @notice Wrapper function to transfer a given asset (native or erc20) to
    ///         some recipient. Should handle all non-compliant return value
    ///         tokens as well by using the SafeERC20 contract by open zeppelin.
    /// @param assetId Asset id for transfer (address(0) for native asset,
    ///                token address for erc20s)
    /// @param recipient Address to send asset to
    /// @param amount Amount to send to given recipient
    function transferAsset(
        address assetId,
        address payable recipient,
        uint256 amount
    ) internal {
        if (isNativeAsset(assetId)) {
            transferNativeAsset(recipient, amount);
        } else {
            transferERC20(assetId, recipient, amount);
        }
    }

    /// @notice Transfers ether from the inheriting contract to a given
    ///         recipient
    /// @param recipient Address to send ether to
    /// @param amount Amount to send to given recipient
    function transferNativeAsset(
        address payable recipient,
        uint256 amount
    ) internal {
        // make sure a meaningful receiver address was provided
        if (recipient == NULL_ADDRESS) revert InvalidReceiver();

        // transfer native asset (will revert if target reverts or contract has insufficient balance)
        recipient.safeTransferETH(amount);
    }

    /// @notice Transfers tokens from the inheriting contract to a given recipient
    /// @param assetId Token address to transfer
    /// @param recipient Address to send tokens to
    /// @param amount Amount to send to given recipient
    function transferERC20(
        address assetId,
        address recipient,
        uint256 amount
    ) internal {
        // make sure a meaningful receiver address was provided
        if (recipient == NULL_ADDRESS) {
            revert InvalidReceiver();
        }

        // transfer ERC20 assets (will revert if target reverts or contract has insufficient balance)
        assetId.safeTransfer(recipient, amount);
    }

    /// @notice Transfers tokens from a sender to a given recipient
    /// @param assetId Token address to transfer
    /// @param from Address of sender/owner
    /// @param recipient Address of recipient/spender
    /// @param amount Amount to transfer from owner to spender
    function transferFromERC20(
        address assetId,
        address from,
        address recipient,
        uint256 amount
    ) internal {
        // check if native asset
        if (isNativeAsset(assetId)) {
            revert NullAddrIsNotAnERC20Token();
        }

        // make sure a meaningful receiver address was provided
        if (recipient == NULL_ADDRESS) {
            revert InvalidReceiver();
        }

        // transfer ERC20 assets (will revert if target reverts or contract has insufficient balance)
        assetId.safeTransferFrom(from, recipient, amount);
    }

    /// @notice Pulls tokens from msg.sender
    /// @param assetId Token address to transfer
    /// @param amount Amount to transfer from owner
    function depositAsset(address assetId, uint256 amount) internal {
        // make sure a meaningful amount was provided
        if (amount == 0) revert InvalidAmount();

        // check if native asset
        if (isNativeAsset(assetId)) {
            // ensure msg.value is equal or greater than amount
            if (msg.value < amount) revert InvalidAmount();
        } else {
            // transfer ERC20 assets (will revert if target reverts or contract has insufficient balance)
            assetId.safeTransferFrom(msg.sender, address(this), amount);
        }
    }

    function depositAssets(LibSwap.SwapData[] calldata swaps) internal {
        for (uint256 i = 0; i < swaps.length; ) {
            LibSwap.SwapData calldata swap = swaps[i];
            if (swap.requiresDeposit) {
                depositAsset(swap.sendingAssetId, swap.fromAmount);
            }
            unchecked {
                i++;
            }
        }
    }

    /// @notice If the current allowance is insufficient, the allowance for a given spender
    ///         is set to MAX_UINT.
    /// @param assetId Token address to transfer
    /// @param spender Address to give spend approval to
    /// @param amount allowance amount required for current transaction
    function maxApproveERC20(
        IERC20 assetId,
        address spender,
        uint256 amount
    ) internal {
        approveERC20(assetId, spender, amount, type(uint256).max);
    }

    /// @notice If the current allowance is insufficient, the allowance for a given spender
    ///         is set to the amount provided
    /// @param assetId Token address to transfer
    /// @param spender Address to give spend approval to
    /// @param requiredAllowance Allowance required for current transaction
    /// @param setAllowanceTo The amount the allowance should be set to if current allowance is insufficient
    function approveERC20(
        IERC20 assetId,
        address spender,
        uint256 requiredAllowance,
        uint256 setAllowanceTo
    ) internal {
        if (isNativeAsset(address(assetId))) {
            return;
        }

        // make sure a meaningful spender address was provided
        if (spender == NULL_ADDRESS) {
            revert NullAddrIsNotAValidSpender();
        }

        // check if allowance is sufficient, otherwise set allowance to provided amount
        // If the initial attempt to approve fails, attempts to reset the approved amount to zero,
        // then retries the approval again (some tokens, e.g. USDT, requires this).
        // Reverts upon failure
        if (assetId.allowance(address(this), spender) < requiredAllowance) {
            address(assetId).safeApproveWithRetry(spender, setAllowanceTo);
        }
    }

    /// @notice Determines whether the given assetId is the native asset
    /// @param assetId The asset identifier to evaluate
    /// @return Boolean indicating if the asset is the native asset
    function isNativeAsset(address assetId) internal pure returns (bool) {
        return assetId == NULL_ADDRESS;
    }

    /// @notice Checks if the given address is a contract
    ///         Returns true for any account with runtime code (excluding EIP-7702 accounts).
    ///         For EIP-7702 accounts, checks if code size is exactly 23 bytes (delegation format).
    ///         Limitations:
    ///         - Cannot distinguish between EOA and self-destructed contract
    /// @param account The address to be checked
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }

        // Return true only for regular contracts (size > 23)
        // EIP-7702 delegated accounts (size == 23) are still EOAs, not contracts
        return size > 23;
    }
}


// ===== src/Libraries/LibBytes.sol =====
// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.17;

/// @custom:version 1.1.0
library LibBytes {
    // solhint-disable no-inline-assembly

    // LibBytes specific errors
    error SliceOverflow();
    error SliceOutOfBounds();
    error AddressOutOfBounds();
    error HexLengthInsufficient();
    error NotAnAddress(bytes32 value);

    bytes16 private constant _SYMBOLS = "0123456789abcdef";

    // -------------------------

    function slice(
        bytes memory _bytes,
        uint256 _start,
        uint256 _length
    ) internal pure returns (bytes memory) {
        if (_length + 31 < _length) revert SliceOverflow();
        if (_bytes.length < _start + _length) revert SliceOutOfBounds();

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
                // Get a location of some free memory and store it in tempBytes as
                // Solidity does for memory variables.
                tempBytes := mload(0x40)

                // The first word of the slice result is potentially a partial
                // word read from the original array. To read it, we calculate
                // the length of that partial word and start copying that many
                // bytes into the array. The first word we copy will start with
                // data we don't care about, but the last `lengthmod` bytes will
                // land at the beginning of the contents of the new array. When
                // we're done copying, we overwrite the full first word with
                // the actual length of the slice.
                let lengthmod := and(_length, 31)

                // The multiplication in the next line is necessary
                // because when slicing multiples of 32 bytes (lengthmod == 0)
                // the following copy loop was copying the origin's length
                // and then ending prematurely not copying everything it should.
                let mc := add(
                    add(tempBytes, lengthmod),
                    mul(0x20, iszero(lengthmod))
                )
                let end := add(mc, _length)

                for {
                    // The multiplication in the next line has the same exact purpose
                    // as the one above.
                    let cc := add(
                        add(
                            add(_bytes, lengthmod),
                            mul(0x20, iszero(lengthmod))
                        ),
                        _start
                    )
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, _length)

                //update free-memory pointer
                //allocating the array padded to 32 bytes like the compiler does now
                mstore(0x40, and(add(mc, 31), not(31)))
            }
            //if we want a zero-length slice let's just return a zero-length array
            default {
                tempBytes := mload(0x40)
                //zero out the 32 bytes slice we are about to return
                //we need to do it because Solidity does not garbage collect
                mstore(tempBytes, 0)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }

    function toAddress(
        bytes memory _bytes,
        uint256 _start
    ) internal pure returns (address) {
        if (_bytes.length < _start + 20) {
            revert AddressOutOfBounds();
        }
        address tempAddress;

        assembly {
            tempAddress := div(
                mload(add(add(_bytes, 0x20), _start)),
                0x1000000000000000000000000
            )
        }

        return tempAddress;
    }

    /// Copied from OpenZeppelin's `Strings.sol` utility library.
    /// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8335676b0e99944eef6a742e16dcd9ff6e68e609
    /// /contracts/utils/Strings.sol
    function toHexString(
        uint256 value,
        uint256 length
    ) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        if (value != 0) revert HexLengthInsufficient();
        return string(buffer);
    }

    /// @notice Left-zero-pads an address into bytes32. Widening — always lossless.
    /// @param _addr The address to convert.
    /// @return The bytes32 representation of the address.
    function toBytes32(address _addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_addr)));
    }

    /// @notice Narrows a left-zero-padded bytes32 to an address, reverting if the
    ///         top 96 bits are set (checked downcast).
    /// @param _value The bytes32 value to convert.
    /// @return The address representation of the bytes32.
    function toAddress(bytes32 _value) internal pure returns (address) {
        if (uint256(_value) >> 160 != 0) revert NotAnAddress(_value);
        return address(uint160(uint256(_value)));
    }

    /// @notice Narrows a bytes32 to an address by truncation, keeping only the low
    ///         160 bits. Use ONLY where dropping the high bits is intentional.
    /// @param _value The bytes32 value to convert.
    /// @return The address representation of the low 160 bits.
    function toAddressUnchecked(
        bytes32 _value
    ) internal pure returns (address) {
        return address(uint160(uint256(_value)));
    }
}


// ===== src/Libraries/LibDiamond.sol =====
// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.17;

import { LibDiamond } from "../Libraries/LibDiamond.sol";
import { LibUtil } from "../Libraries/LibUtil.sol";
import { OnlyContractOwner } from "../Errors/GenericErrors.sol";

/// @title LibDiamond
/// @custom:version 1.0.0
/// @notice This library implements the EIP-2535 Diamond Standard
library LibDiamond {
    bytes32 internal constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.diamond.storage");

    // Diamond specific errors
    error IncorrectFacetCutAction();
    error NoSelectorsInFace();
    error FunctionAlreadyExists();
    error FacetAddressIsZero();
    error FacetAddressIsNotZero();
    error FacetContainsNoCode();
    error FunctionDoesNotExist();
    error FunctionIsImmutable();
    error InitZeroButCalldataNotEmpty();
    error CalldataEmptyButInitNotZero();
    error InitReverted();
    // ----------------

    struct FacetAddressAndPosition {
        address facetAddress;
        uint96 functionSelectorPosition; // position in facetFunctionSelectors.functionSelectors array
    }

    struct FacetFunctionSelectors {
        bytes4[] functionSelectors;
        uint256 facetAddressPosition; // position of facetAddress in facetAddresses array
    }

    struct DiamondStorage {
        // maps function selector to the facet address and
        // the position of the selector in the facetFunctionSelectors.selectors array
        mapping(bytes4 => FacetAddressAndPosition) selectorToFacetAndPosition;
        // maps facet addresses to function selectors
        mapping(address => FacetFunctionSelectors) facetFunctionSelectors;
        // facet addresses
        address[] facetAddresses;
        // Used to query if a contract implements an interface.
        // Used to implement ERC-165.
        mapping(bytes4 => bool) supportedInterfaces;
        // owner of the contract
        address contractOwner;
    }

    enum FacetCutAction {
        Add,
        Replace,
        Remove
    }
    // Add=0, Replace=1, Remove=2

    struct FacetCut {
        address facetAddress;
        FacetCutAction action;
        bytes4[] functionSelectors;
    }

    function diamondStorage()
        internal
        pure
        returns (DiamondStorage storage ds)
    {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            ds.slot := position
        }
    }

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    event DiamondCut(FacetCut[] _diamondCut, address _init, bytes _calldata);

    function setContractOwner(address _newOwner) internal {
        DiamondStorage storage ds = diamondStorage();
        address previousOwner = ds.contractOwner;
        ds.contractOwner = _newOwner;
        emit OwnershipTransferred(previousOwner, _newOwner);
    }

    function contractOwner() internal view returns (address contractOwner_) {
        contractOwner_ = diamondStorage().contractOwner;
    }

    function enforceIsContractOwner() internal view {
        if (msg.sender != diamondStorage().contractOwner)
            revert OnlyContractOwner();
    }

    // Internal function version of diamondCut
    function diamondCut(
        FacetCut[] memory _diamondCut,
        address _init,
        bytes memory _calldata
    ) internal {
        for (uint256 facetIndex; facetIndex < _diamondCut.length; ) {
            LibDiamond.FacetCutAction action = _diamondCut[facetIndex].action;
            if (action == LibDiamond.FacetCutAction.Add) {
                addFunctions(
                    _diamondCut[facetIndex].facetAddress,
                    _diamondCut[facetIndex].functionSelectors
                );
            } else if (action == LibDiamond.FacetCutAction.Replace) {
                replaceFunctions(
                    _diamondCut[facetIndex].facetAddress,
                    _diamondCut[facetIndex].functionSelectors
                );
            } else if (action == LibDiamond.FacetCutAction.Remove) {
                removeFunctions(
                    _diamondCut[facetIndex].facetAddress,
                    _diamondCut[facetIndex].functionSelectors
                );
            } else {
                revert IncorrectFacetCutAction();
            }
            unchecked {
                ++facetIndex;
            }
        }
        emit DiamondCut(_diamondCut, _init, _calldata);
        initializeDiamondCut(_init, _calldata);
    }

    function addFunctions(
        address _facetAddress,
        bytes4[] memory _functionSelectors
    ) internal {
        if (_functionSelectors.length == 0) {
            revert NoSelectorsInFace();
        }
        DiamondStorage storage ds = diamondStorage();
        if (LibUtil.isZeroAddress(_facetAddress)) {
            revert FacetAddressIsZero();
        }
        uint96 selectorPosition = uint96(
            ds.facetFunctionSelectors[_facetAddress].functionSelectors.length
        );
        // add new facet address if it does not exist
        if (selectorPosition == 0) {
            addFacet(ds, _facetAddress);
        }
        for (
            uint256 selectorIndex;
            selectorIndex < _functionSelectors.length;

        ) {
            bytes4 selector = _functionSelectors[selectorIndex];
            address oldFacetAddress = ds
                .selectorToFacetAndPosition[selector]
                .facetAddress;
            if (!LibUtil.isZeroAddress(oldFacetAddress)) {
                revert FunctionAlreadyExists();
            }
            addFunction(ds, selector, selectorPosition, _facetAddress);
            unchecked {
                ++selectorPosition;
                ++selectorIndex;
            }
        }
    }

    function replaceFunctions(
        address _facetAddress,
        bytes4[] memory _functionSelectors
    ) internal {
        if (_functionSelectors.length == 0) {
            revert NoSelectorsInFace();
        }
        DiamondStorage storage ds = diamondStorage();
        if (LibUtil.isZeroAddress(_facetAddress)) {
            revert FacetAddressIsZero();
        }
        uint96 selectorPosition = uint96(
            ds.facetFunctionSelectors[_facetAddress].functionSelectors.length
        );
        // add new facet address if it does not exist
        if (selectorPosition == 0) {
            addFacet(ds, _facetAddress);
        }
        for (
            uint256 selectorIndex;
            selectorIndex < _functionSelectors.length;

        ) {
            bytes4 selector = _functionSelectors[selectorIndex];
            address oldFacetAddress = ds
                .selectorToFacetAndPosition[selector]
                .facetAddress;
            if (oldFacetAddress == _facetAddress) {
                revert FunctionAlreadyExists();
            }
            removeFunction(ds, oldFacetAddress, selector);
            addFunction(ds, selector, selectorPosition, _facetAddress);
            unchecked {
                ++selectorPosition;
                ++selectorIndex;
            }
        }
    }

    function removeFunctions(
        address _facetAddress,
        bytes4[] memory _functionSelectors
    ) internal {
        if (_functionSelectors.length == 0) {
            revert NoSelectorsInFace();
        }
        DiamondStorage storage ds = diamondStorage();
        // if function does not exist then do nothing and return
        if (!LibUtil.isZeroAddress(_facetAddress)) {
            revert FacetAddressIsNotZero();
        }
        for (
            uint256 selectorIndex;
            selectorIndex < _functionSelectors.length;

        ) {
            bytes4 selector = _functionSelectors[selectorIndex];
            address oldFacetAddress = ds
                .selectorToFacetAndPosition[selector]
                .facetAddress;
            removeFunction(ds, oldFacetAddress, selector);
            unchecked {
                ++selectorIndex;
            }
        }
    }

    function addFacet(
        DiamondStorage storage ds,
        address _facetAddress
    ) internal {
        enforceHasContractCode(_facetAddress);
        ds.facetFunctionSelectors[_facetAddress].facetAddressPosition = ds
            .facetAddresses
            .length;
        ds.facetAddresses.push(_facetAddress);
    }

    function addFunction(
        DiamondStorage storage ds,
        bytes4 _selector,
        uint96 _selectorPosition,
        address _facetAddress
    ) internal {
        ds
            .selectorToFacetAndPosition[_selector]
            .functionSelectorPosition = _selectorPosition;
        ds.facetFunctionSelectors[_facetAddress].functionSelectors.push(
            _selector
        );
        ds.selectorToFacetAndPosition[_selector].facetAddress = _facetAddress;
    }

    function removeFunction(
        DiamondStorage storage ds,
        address _facetAddress,
        bytes4 _selector
    ) internal {
        if (LibUtil.isZeroAddress(_facetAddress)) {
            revert FunctionDoesNotExist();
        }
        // an immutable function is a function defined directly in a diamond
        if (_facetAddress == address(this)) {
            revert FunctionIsImmutable();
        }
        // replace selector with last selector, then delete last selector
        uint256 selectorPosition = ds
            .selectorToFacetAndPosition[_selector]
            .functionSelectorPosition;
        uint256 lastSelectorPosition = ds
            .facetFunctionSelectors[_facetAddress]
            .functionSelectors
            .length - 1;
        // if not the same then replace _selector with lastSelector
        if (selectorPosition != lastSelectorPosition) {
            bytes4 lastSelector = ds
                .facetFunctionSelectors[_facetAddress]
                .functionSelectors[lastSelectorPosition];
            ds.facetFunctionSelectors[_facetAddress].functionSelectors[
                selectorPosition
            ] = lastSelector;
            ds
                .selectorToFacetAndPosition[lastSelector]
                .functionSelectorPosition = uint96(selectorPosition);
        }
        // delete the last selector
        ds.facetFunctionSelectors[_facetAddress].functionSelectors.pop();
        delete ds.selectorToFacetAndPosition[_selector];

        // if no more selectors for facet address then delete the facet address
        if (lastSelectorPosition == 0) {
            // replace facet address with last facet address and delete last facet address
            uint256 lastFacetAddressPosition = ds.facetAddresses.length - 1;
            uint256 facetAddressPosition = ds
                .facetFunctionSelectors[_facetAddress]
                .facetAddressPosition;
            if (facetAddressPosition != lastFacetAddressPosition) {
                address lastFacetAddress = ds.facetAddresses[
                    lastFacetAddressPosition
                ];
                ds.facetAddresses[facetAddressPosition] = lastFacetAddress;
                ds
                    .facetFunctionSelectors[lastFacetAddress]
                    .facetAddressPosition = facetAddressPosition;
            }
            ds.facetAddresses.pop();
            delete ds
                .facetFunctionSelectors[_facetAddress]
                .facetAddressPosition;
        }
    }

    function initializeDiamondCut(
        address _init,
        bytes memory _calldata
    ) internal {
        if (LibUtil.isZeroAddress(_init)) {
            if (_calldata.length != 0) {
                revert InitZeroButCalldataNotEmpty();
            }
        } else {
            if (_calldata.length == 0) {
                revert CalldataEmptyButInitNotZero();
            }
            if (_init != address(this)) {
                enforceHasContractCode(_init);
            }
            // solhint-disable-next-line avoid-low-level-calls
            (bool success, bytes memory error) = _init.delegatecall(_calldata);
            if (!success) {
                if (error.length > 0) {
                    // bubble up the error
                    revert(string(error));
                } else {
                    revert InitReverted();
                }
            }
        }
    }

    function enforceHasContractCode(address _contract) internal view {
        uint256 contractSize;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            contractSize := extcodesize(_contract)
        }
        if (contractSize == 0) {
            revert FacetContainsNoCode();
        }
    }
}


// ===== src/Libraries/LibSwap.sol =====
// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.17;

import { LibAsset } from "./LibAsset.sol";
import { LibUtil } from "./LibUtil.sol";
import { InvalidContract, NoSwapFromZeroBalance } from "../Errors/GenericErrors.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title LibSwap
/// @custom:version 1.1.0
/// @notice This library contains functionality to execute mostly swaps but also
///         other calls such as fee collection, token wrapping/unwrapping or
///         sending gas to destination chain
library LibSwap {
    /// @notice Struct containing all necessary data to execute a swap or generic call
    /// @param callTo The address of the contract to call for executing the swap
    /// @param approveTo The address that will receive token approval (can be different than callTo for some DEXs)
    /// @param sendingAssetId The address of the token being sent
    /// @param receivingAssetId The address of the token expected to be received
    /// @param fromAmount The exact amount of the sending asset to be used in the call
    /// @param callData Encoded function call data to be sent to the `callTo` contract
    /// @param requiresDeposit A flag indicating whether the tokens must be deposited (pulled) before the call
    struct SwapData {
        address callTo;
        address approveTo;
        address sendingAssetId;
        address receivingAssetId;
        uint256 fromAmount;
        bytes callData;
        bool requiresDeposit;
    }

    /// @notice Emitted after a successful asset swap or related operation
    /// @param transactionId    The unique identifier associated with the swap operation
    /// @param dex              The address of the DEX or contract that handled the swap
    /// @param fromAssetId      The address of the token that was sent
    /// @param toAssetId        The address of the token that was received
    /// @param fromAmount       The amount of `fromAssetId` sent
    /// @param toAmount         The amount of `toAssetId` received
    /// @param timestamp        The timestamp when the swap was executed
    event AssetSwapped(
        bytes32 transactionId,
        address dex,
        address fromAssetId,
        address toAssetId,
        uint256 fromAmount,
        uint256 toAmount,
        uint256 timestamp
    );

    function swap(bytes32 transactionId, SwapData calldata _swap) internal {
        // make sure callTo is a contract
        if (!LibAsset.isContract(_swap.callTo)) revert InvalidContract();

        // make sure that fromAmount is not 0
        uint256 fromAmount = _swap.fromAmount;
        if (fromAmount == 0) revert NoSwapFromZeroBalance();

        // determine how much native value to send with the swap call
        uint256 nativeValue = LibAsset.isNativeAsset(_swap.sendingAssetId)
            ? _swap.fromAmount
            : 0;

        // store initial balance (required for event emission)
        uint256 initialReceivingAssetBalance = LibAsset.getOwnBalance(
            _swap.receivingAssetId
        );

        // max approve (if ERC20)
        if (nativeValue == 0) {
            LibAsset.maxApproveERC20(
                IERC20(_swap.sendingAssetId),
                _swap.approveTo,
                _swap.fromAmount
            );
        }

        // we used to have a sending asset balance check here (initialSendingAssetBalance >= _swap.fromAmount)
        // this check was removed to allow for more flexibility with rebasing/fee-taking tokens
        // the general assumption is that if not enough tokens are available to execute the calldata,
        // the transaction will fail anyway
        // the error message might not be as explicit though

        // execute the swap
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory res) = _swap.callTo.call{
            value: nativeValue
        }(_swap.callData);
        if (!success) {
            LibUtil.revertWith(res);
        }

        // get post-swap balance
        uint256 newBalance = LibAsset.getOwnBalance(_swap.receivingAssetId);

        // emit event
        emit AssetSwapped(
            transactionId,
            _swap.callTo,
            _swap.sendingAssetId,
            _swap.receivingAssetId,
            _swap.fromAmount,
            newBalance > initialReceivingAssetBalance
                ? newBalance - initialReceivingAssetBalance
                : newBalance,
            block.timestamp
        );
    }
}


// ===== src/Libraries/LibUtil.sol =====
// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.17;

// solhint-disable-next-line no-global-import
import "./LibBytes.sol";

/// @custom:version 1.0.0
library LibUtil {
    using LibBytes for bytes;

    function getRevertMsg(
        bytes memory _res
    ) internal pure returns (string memory) {
        // If the _res length is less than 68, then the transaction failed silently (without a revert message)
        if (_res.length < 68) return "Transaction reverted silently";
        bytes memory revertData = _res.slice(4, _res.length - 4); // Remove the selector which is the first 4 bytes
        return abi.decode(revertData, (string)); // All that remains is the revert string
    }

    /// @notice Determines whether the given address is the zero address
    /// @param addr The address to verify
    /// @return Boolean indicating if the address is the zero address
    function isZeroAddress(address addr) internal pure returns (bool) {
        return addr == address(0);
    }

    function revertWith(bytes memory data) internal pure {
        assembly {
            let dataSize := mload(data) // Load the size of the data
            let dataPtr := add(data, 0x20) // Advance data pointer to the next word
            revert(dataPtr, dataSize) // Revert with the given data
        }
    }
}

