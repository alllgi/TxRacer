// Sources retrieved from Sourcify API v2.
// Deterministic best-effort flattening; original files are preserved under src/.

// File: lib/euler-vault-kit/src/InterestRateModels/IIRM.sol

pragma solidity >=0.8.0;

/// @title IIRM
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice Interface of the interest rate model contracts used by EVault
interface IIRM {
    error E_IRMUpdateUnauthorized();

    /// @notice Perform potentially state mutating computation of the new interest rate
    /// @param vault Address of the vault to compute the new interest rate for
    /// @param cash Amount of assets held directly by the vault
    /// @param borrows Amount of assets lent out to borrowers by the vault
    /// @return Then new interest rate in second percent yield (SPY), scaled by 1e27
    function computeInterestRate(address vault, uint256 cash, uint256 borrows) external returns (uint256);

    /// @notice Perform computation of the new interest rate without mutating state
    /// @param vault Address of the vault to compute the new interest rate for
    /// @param cash Amount of assets held directly by the vault
    /// @param borrows Amount of assets lent out to borrowers by the vault
    /// @return Then new interest rate in second percent yield (SPY), scaled by 1e27
    function computeInterestRateView(address vault, uint256 cash, uint256 borrows) external view returns (uint256);
}

// File: lib/euler-vault-kit/src/InterestRateModels/IRMLinearKink.sol

pragma solidity ^0.8.0;



/// @title IRMLinearKink
/// @custom:security-contact security@euler.xyz
/// @author Euler Labs (https://www.eulerlabs.com/)
/// @notice Implementation of an interest rate model, where interest rate grows linearly with utilization, and spikes
/// after reaching kink
contract IRMLinearKink is IIRM {
    /// @notice Base interest rate applied when utilization is equal zero
    uint256 public immutable baseRate;
    /// @notice Slope of the function before the kink
    uint256 public immutable slope1;
    /// @notice Slope of the function after the kink
    uint256 public immutable slope2;
    /// @notice Utilization at which the slope of the interest rate function changes. In type(uint32).max scale.
    uint256 public immutable kink;

    constructor(uint256 baseRate_, uint256 slope1_, uint256 slope2_, uint32 kink_) {
        baseRate = baseRate_;
        slope1 = slope1_;
        slope2 = slope2_;
        kink = kink_;
    }

    /// @inheritdoc IIRM
    function computeInterestRate(address vault, uint256 cash, uint256 borrows)
        external
        view
        override
        returns (uint256)
    {
        if (msg.sender != vault) revert E_IRMUpdateUnauthorized();

        return computeInterestRateInternal(vault, cash, borrows);
    }

    /// @inheritdoc IIRM
    function computeInterestRateView(address vault, uint256 cash, uint256 borrows)
        external
        view
        override
        returns (uint256)
    {
        return computeInterestRateInternal(vault, cash, borrows);
    }

    function computeInterestRateInternal(address, uint256 cash, uint256 borrows) internal view returns (uint256) {
        uint256 totalAssets = cash + borrows;

        uint32 utilization = totalAssets == 0
            ? 0 // empty pool arbitrarily given utilization of 0
            : uint32(borrows * type(uint32).max / totalAssets);

        uint256 ir = baseRate;

        if (utilization <= kink) {
            ir += utilization * slope1;
        } else {
            ir += kink * slope1;

            uint256 utilizationOverKink;
            unchecked {
                utilizationOverKink = utilization - kink;
            }
            ir += slope2 * utilizationOverKink;
        }

        return ir;
    }
}
