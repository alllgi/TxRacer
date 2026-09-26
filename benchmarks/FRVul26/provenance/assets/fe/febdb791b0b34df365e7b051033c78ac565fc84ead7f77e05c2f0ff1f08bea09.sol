// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

// Interfaces
import { IMakerPSM } from "../interfaces/IMakerPSM.sol";

/// @title MakerPSMUtils
abstract contract MakerPSMUtils {
    /*//////////////////////////////////////////////////////////////
                               CONSTANTS
    //////////////////////////////////////////////////////////////*/

    /// @dev DAI Address
    address public immutable DAI_MAKER; // solhint-disable-line var-name-mixedcase
    /// @dev WAD amount
    uint256 private constant WAD = 10 ** 18;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _daiMaker) {
        DAI_MAKER = _daiMaker;
    }
    /*//////////////////////////////////////////////////////////////
                                 INTERNAL
    //////////////////////////////////////////////////////////////*/

    /// @dev Execute a swapExactAmountIn on Maker PSM transfering the recieved tokens to the beneficiary
    function _executeSwapExactAmountInOnMakerPSM(
        address exchange,
        uint256 swapType,
        uint256 toll,
        uint256 to18ConversionFactor,
        uint256 fromAmount,
        address beneficiary
    )
        internal
        returns (uint256 spentAmount, uint256 receivedAmount)
    {
        // If swapType is 0, then we are calling buyGem
        if (swapType == 0) {
            // Calculate the amount to buy
            uint256 gemAmt = (fromAmount * WAD) / ((WAD + toll) * to18ConversionFactor);
            // Call buyGem on exchange
            IMakerPSM(exchange).buyGem(beneficiary, gemAmt);
            return (fromAmount, gemAmt);
        }
        // If swapType is 1, then we are calling sellGem
        else {
            // Call sellGem on exchange
            IMakerPSM(exchange).sellGem(beneficiary, fromAmount);
            // Calculate the amount received
            uint256 gemAmt = fromAmount * to18ConversionFactor;
            uint256 fee = (gemAmt * toll) / WAD;
            receivedAmount = gemAmt - fee;
            return (fromAmount, receivedAmount);
        }
    }

    /// @dev Execute a swapExactAmountOut on Maker PSM transfering the recieved tokens to the beneficiary
    function _executeSwapExactAmountOutOnMakerPSM(
        address exchange,
        uint256 swapType,
        uint256 toll,
        uint256 to18ConversionFactor,
        uint256 toAmount,
        address beneficiary
    )
        internal
    {
        // If swapType is 0, then we are calling buyGem
        if (swapType == 0) {
            IMakerPSM(exchange).buyGem(beneficiary, toAmount);
        }
        // If swapType is 1, then we are calling sellGem
        else {
            // Calculate the amount to sell
            uint256 a = toAmount * WAD;
            uint256 b = (WAD - toll) * to18ConversionFactor;
            uint256 gemAmt = (a + b - 1) / b;
            // Call sellGem
            IMakerPSM(exchange).sellGem(beneficiary, gemAmt);
        }
    }
}
