// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title MockCollateralToken
 * @dev Mock ERC20 token for testing POIPOI system
 * @notice This represents a stablecoin like USDC or rBTC for testing
 * @author POIPOI Team
 */
contract MockCollateralToken is ERC20, Ownable {
    // Events
    event TokensMinted(address indexed to, uint256 amount);

    // Constants
    uint256 public constant INITIAL_SUPPLY = 1000000 * 10 ** 18; // 1M tokens

    /**
     * @dev Constructor mints initial supply to owner
     */
    constructor() ERC20("Mock Collateral Token", "MCT") Ownable(msg.sender) {
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    /**
     * @dev Mint tokens to any address (for testing)
     * @param to Address to mint tokens to
     * @param amount Amount of tokens to mint
     */
    function mint(address to, uint256 amount) external onlyOwner {
        require(to != address(0), "MockCollateralToken: Cannot mint to zero address");
        require(amount > 0, "MockCollateralToken: Amount must be greater than zero");

        _mint(to, amount);
        emit TokensMinted(to, amount);
    }

    /**
     * @dev Mint tokens to caller (for testing convenience)
     * @param amount Amount of tokens to mint
     */
    function mintToSelf(uint256 amount) external {
        require(amount > 0, "MockCollateralToken: Amount must be greater than zero");

        _mint(msg.sender, amount);
        emit TokensMinted(msg.sender, amount);
    }

    /**
     * @dev Get decimals (18)
     */
    function decimals() public pure override returns (uint8) {
        return 18;
    }
}
