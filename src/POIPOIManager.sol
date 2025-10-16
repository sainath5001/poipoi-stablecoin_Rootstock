// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./POIPOI.sol";
import "./GoldPriceOracle.sol";

/**
 * @title POIPOIManager
 * @dev Manages minting and redemption of POIPOI tokens based on gold price
 * @notice Handles collateral deposits and POI token minting/burning
 * @author POIPOI Team
 */
contract POIPOIManager is Ownable, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // Events
    event TokensMinted(address indexed user, uint256 poiAmount, uint256 collateralAmount, uint256 goldPrice);
    event TokensRedeemed(address indexed user, uint256 poiAmount, uint256 collateralAmount, uint256 goldPrice);
    event CollateralTokenUpdated(address indexed oldToken, address indexed newToken);
    event OracleUpdated(address indexed oldOracle, address indexed newOracle);
    event POITokenUpdated(address indexed oldToken, address indexed newToken);
    event EmergencyStop(bool stopped);

    // State variables
    POIPOI public poiToken;
    GoldPriceOracle public goldOracle;
    IERC20 public collateralToken; // Token used as collateral (e.g., rBTC, USDC)

    // Emergency controls
    bool public emergencyStopped = false;

    // Modifiers
    modifier notEmergencyStopped() {
        require(!emergencyStopped, "POIPOIManager: Contract is emergency stopped");
        _;
    }

    modifier validAmount(uint256 amount) {
        require(amount > 0, "POIPOIManager: Amount must be greater than zero");
        _;
    }

    /**
     * @dev Constructor initializes the manager with required contracts
     * @param _poiToken Address of POIPOI token contract
     * @param _goldOracle Address of gold price oracle contract
     * @param _collateralToken Address of collateral token contract
     */
    constructor(address _poiToken, address _goldOracle, address _collateralToken) Ownable(msg.sender) {
        require(_poiToken != address(0), "POIPOIManager: POI token address cannot be zero");
        require(_goldOracle != address(0), "POIPOIManager: Oracle address cannot be zero");
        require(_collateralToken != address(0), "POIPOIManager: Collateral token address cannot be zero");

        poiToken = POIPOI(_poiToken);
        goldOracle = GoldPriceOracle(_goldOracle);
        collateralToken = IERC20(_collateralToken);
    }

    /**
     * @dev Mint POI tokens by depositing collateral
     * @param collateralAmount Amount of collateral tokens to deposit (18 decimals)
     * @return poiAmount Amount of POI tokens minted
     */
    function mintPoi(uint256 collateralAmount)
        external
        notEmergencyStopped
        whenNotPaused
        nonReentrant
        validAmount(collateralAmount)
        returns (uint256 poiAmount)
    {
        // Get current gold price
        uint256 goldPrice = goldOracle.getGoldPricePerGram();
        require(goldPrice > 0, "POIPOIManager: Invalid gold price");

        // Calculate POI amount based on collateral and gold price
        poiAmount = goldOracle.convertUsdToPoi(collateralAmount);
        require(poiAmount > 0, "POIPOIManager: Calculated POI amount is zero");

        // Transfer collateral from user to this contract
        collateralToken.safeTransferFrom(msg.sender, address(this), collateralAmount);

        // Mint POI tokens to user
        poiToken.mint(msg.sender, poiAmount, goldPrice);

        emit TokensMinted(msg.sender, poiAmount, collateralAmount, goldPrice);

        return poiAmount;
    }

    /**
     * @dev Redeem POI tokens for collateral
     * @param poiAmount Amount of POI tokens to redeem (18 decimals)
     * @return collateralAmount Amount of collateral tokens returned
     */
    function redeemPoi(uint256 poiAmount)
        external
        notEmergencyStopped
        whenNotPaused
        nonReentrant
        validAmount(poiAmount)
        returns (uint256 collateralAmount)
    {
        // Check user has enough POI tokens
        require(poiToken.balanceOf(msg.sender) >= poiAmount, "POIPOIManager: Insufficient POI balance");

        // Get current gold price
        uint256 goldPrice = goldOracle.getGoldPricePerGram();
        require(goldPrice > 0, "POIPOIManager: Invalid gold price");

        // Calculate collateral amount based on POI amount and gold price
        collateralAmount = goldOracle.convertPoiToUsd(poiAmount);
        require(collateralAmount > 0, "POIPOIManager: Calculated collateral amount is zero");

        // Check contract has enough collateral
        require(
            collateralToken.balanceOf(address(this)) >= collateralAmount,
            "POIPOIManager: Insufficient collateral reserves"
        );

        // Burn POI tokens from user
        poiToken.burn(msg.sender, poiAmount, goldPrice);

        // Transfer collateral to user
        collateralToken.safeTransfer(msg.sender, collateralAmount);

        emit TokensRedeemed(msg.sender, poiAmount, collateralAmount, goldPrice);

        return collateralAmount;
    }

    /**
     * @dev Calculate POI amount for given collateral amount
     * @param collateralAmount Amount of collateral tokens
     * @return poiAmount Amount of POI tokens that would be minted
     */
    function calculatePoiAmount(uint256 collateralAmount) external view returns (uint256 poiAmount) {
        require(collateralAmount > 0, "POIPOIManager: Amount must be greater than zero");

        uint256 goldPrice = goldOracle.getGoldPricePerGram();
        require(goldPrice > 0, "POIPOIManager: Invalid gold price");

        return goldOracle.convertUsdToPoi(collateralAmount);
    }

    /**
     * @dev Calculate collateral amount for given POI amount
     * @param poiAmount Amount of POI tokens
     * @return collateralAmount Amount of collateral tokens that would be returned
     */
    function calculateCollateralAmount(uint256 poiAmount) external view returns (uint256 collateralAmount) {
        require(poiAmount > 0, "POIPOIManager: Amount must be greater than zero");

        uint256 goldPrice = goldOracle.getGoldPricePerGram();
        require(goldPrice > 0, "POIPOIManager: Invalid gold price");

        return goldOracle.convertPoiToUsd(poiAmount);
    }

    /**
     * @dev Update POI token contract address
     * @param _poiToken New POI token contract address
     */
    function updatePOIToken(address _poiToken) external onlyOwner {
        require(_poiToken != address(0), "POIPOIManager: POI token address cannot be zero");

        address oldToken = address(poiToken);
        poiToken = POIPOI(_poiToken);

        emit POITokenUpdated(oldToken, _poiToken);
    }

    /**
     * @dev Update gold oracle contract address
     * @param _goldOracle New gold oracle contract address
     */
    function updateGoldOracle(address _goldOracle) external onlyOwner {
        require(_goldOracle != address(0), "POIPOIManager: Oracle address cannot be zero");

        address oldOracle = address(goldOracle);
        goldOracle = GoldPriceOracle(_goldOracle);

        emit OracleUpdated(oldOracle, _goldOracle);
    }

    /**
     * @dev Update collateral token contract address
     * @param _collateralToken New collateral token contract address
     */
    function updateCollateralToken(address _collateralToken) external onlyOwner {
        require(_collateralToken != address(0), "POIPOIManager: Collateral token address cannot be zero");

        address oldToken = address(collateralToken);
        collateralToken = IERC20(_collateralToken);

        emit CollateralTokenUpdated(oldToken, _collateralToken);
    }

    /**
     * @dev Emergency stop function
     * @param stopped True to stop, false to resume
     */
    function setEmergencyStop(bool stopped) external onlyOwner {
        emergencyStopped = stopped;
        emit EmergencyStop(stopped);
    }

    /**
     * @dev Pause the contract
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev Unpause the contract
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @dev Get current gold price from oracle
     * @return price Current gold price per gram
     */
    function getCurrentGoldPrice() external view returns (uint256) {
        return goldOracle.getGoldPricePerGram();
    }

    /**
     * @dev Get collateral reserves
     * @return balance Current collateral token balance in this contract
     */
    function getCollateralReserves() external view returns (uint256) {
        return collateralToken.balanceOf(address(this));
    }

    /**
     * @dev Get POI token total supply
     * @return supply Current POI token total supply
     */
    function getPOITotalSupply() external view returns (uint256) {
        return poiToken.totalSupply();
    }

    /**
     * @dev Emergency withdrawal of collateral (only owner)
     * @param amount Amount of collateral to withdraw
     */
    function emergencyWithdrawCollateral(uint256 amount) external onlyOwner {
        require(amount > 0, "POIPOIManager: Amount must be greater than zero");
        require(collateralToken.balanceOf(address(this)) >= amount, "POIPOIManager: Insufficient balance");

        collateralToken.safeTransfer(owner(), amount);
    }

    /**
     * @dev Check if price is stale
     * @return isStale True if oracle price is stale
     */
    function isPriceStale() external view returns (bool) {
        return goldOracle.isPriceStale();
    }
}
