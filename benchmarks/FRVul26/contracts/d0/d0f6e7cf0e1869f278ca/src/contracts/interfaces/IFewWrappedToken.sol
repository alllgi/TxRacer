// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

import "../interfaces/IFewERC20.sol";

interface IFewWrappedToken is IFewERC20 {
    event Mint(address indexed minter, uint256 amount, address indexed to);
    event Burn(address indexed burner, uint256 amount, address indexed to);
    event Wrap(address indexed sender, uint256 amount, address indexed to);
    event Unwrap(address indexed sender, uint256 amount, address indexed to);

    function factory() external view returns (address);
    function token() external view returns (address);

    function burn(uint256 amount) external;
    function burnFrom(address account, uint256 amount) external;
    function mint(address account, uint256 amount) external;
    function wrap(uint256 amount) external returns (uint256);
    function wrapTo(uint256 amount, address to) external returns (uint256);
    function unwrap(uint256 amount) external returns (uint256);
    function unwrapTo(uint256 amount, address to) external returns (uint256);
}
