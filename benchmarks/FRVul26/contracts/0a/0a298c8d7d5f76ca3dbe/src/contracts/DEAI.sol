//SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

import "./extensions/TokensRescuer.sol";

contract DEAI is ERC20Upgradeable, TokensRescuer, AccessControlUpgradeable {

    uint256 public constant MAX_TOTAL_SUPPLY = 1_000_000_000 * 1e18;

    bool private isMinted;

    bytes32 public constant BURNER_ROLE = bytes32("BURNER_ROLE");

    /**
     *  @notice Initializes the contract.
     */
    function __DEAI_init() external initializer {
        __ERC20_init_unchained("Zero1 Token", "DEAI");
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function mint(address to) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if(!isMinted){
            _mint(to, MAX_TOTAL_SUPPLY);
            isMinted = true;
        }
    }

    function burn(uint256 amount) external onlyRole(BURNER_ROLE) {
        _burn(msg.sender, amount);
    }

    /// @inheritdoc ITokensRescuer
    function rescueERC20Token(
        address token,
        uint256 amount,
        address receiver
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _rescueERC20Token(token, amount, receiver);
    }

    /// @inheritdoc ITokensRescuer
    function rescueNativeToken(
        uint256 amount,
        address receiver
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _rescueNativeToken(amount, receiver);
    }


}
