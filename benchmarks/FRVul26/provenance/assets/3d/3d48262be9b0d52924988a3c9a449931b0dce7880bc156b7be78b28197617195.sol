// SPDX-License-Identifier: UNLICENSED
// © Copyright XSwap.link. All Rights Reserved
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./interfaces/IFeeOracle.sol";
import "./interfaces/IFeeCollector.sol";
import "./structs/XSwapFee.sol";

abstract contract CollectFeesUpgradeable is OwnableUpgradeable {
    address public feeOracleAddress;
    address public feeCollectorAddress;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[48] private __gap;

    event SetFeeCollectorAddress(address newFeeCollectorAddress);
    event SetFeeOracleAddress(address newFeeOracleAddress);

    function __CollectFees_init(
        address _feeOracleAddress,
        address _feeCollectorAddress
    ) internal virtual onlyInitializing {
        feeOracleAddress = _feeOracleAddress;
        feeCollectorAddress = _feeCollectorAddress;
        __Ownable_init();
    }

    function setFeeCollectorAddress(
        address _feeCollectorAddress
    ) public onlyOwner {
        feeCollectorAddress = _feeCollectorAddress;
        emit SetFeeCollectorAddress(_feeCollectorAddress);
    }

    function setFeeOracleAddress(address _feeOracleAddress) public onlyOwner {
        feeOracleAddress = _feeOracleAddress;
        emit SetFeeOracleAddress(_feeOracleAddress);
    }

    // Transfer native + token fee to fee collector. Assumes correct current balances.
    function _collectFees(
        uint256 amount,
        address feeToken,
        address spender,
        bytes calldata additionalData
    ) internal {
        XSwapFee memory fee = IFeeOracle(feeOracleAddress).getFee(
            amount,
            feeToken,
            spender,
            additionalData
        );

        if (fee.tokenFee > 0) {
            IERC20(feeToken).approve(feeCollectorAddress, fee.tokenFee);
            IFeeCollector(feeCollectorAddress).receiveToken(
                feeToken,
                fee.tokenFee
            );
        }
        if (fee.nativeFee > 0) {
            IFeeCollector(feeCollectorAddress).receiveNative{
                value: fee.nativeFee
            }();
        }
    }
}
