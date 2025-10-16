// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title GoldPriceOracle
 * @dev Oracle contract for fetching gold price in USD per gram
 * @notice Provides gold price data for POIPOI stablecoin operations
 * @author POIPOI Team
 */
contract GoldPriceOracle is Ownable, Pausable, ReentrancyGuard {
    // Events
    event PriceUpdated(uint256 indexed price, uint256 timestamp);
    event OracleUpdated(address indexed newOracle);
    event PriceFeedUpdated(address indexed newPriceFeed);
    event EmergencyStop(bool stopped);

    // State variables
    uint256 public goldPricePerGram; // Price in USD per gram (with 8 decimals)
    uint256 public lastUpdated;
    uint256 public constant PRICE_DECIMALS = 8; // Chainlink price feeds use 8 decimals
    uint256 public constant UPDATE_THRESHOLD = 300; // 5 minutes in seconds
    uint256 public constant MAX_PRICE_CHANGE = 1000; // 10% max change per update (1000 = 10%)

    // Mock/fallback variables for testing
    bool public useMockPrice = true; // Set to false when real Chainlink feed is available
    uint256 public mockPricePerGram = 65000000; // $65 per gram (mock price with 8 decimals)

    // Emergency controls
    bool public emergencyStopped = false;

    // Modifiers
    modifier notEmergencyStopped() {
        require(!emergencyStopped, "GoldPriceOracle: Contract is emergency stopped");
        _;
    }

    modifier validPrice(uint256 price) {
        require(price > 0, "GoldPriceOracle: Price must be greater than zero");
        require(price <= 1000000000000, "GoldPriceOracle: Price too high"); // Max $10,000 per gram
        _;
    }

    /**
     * @dev Constructor initializes with mock price
     */
    constructor() Ownable(msg.sender) {
        goldPricePerGram = mockPricePerGram;
        lastUpdated = block.timestamp;
        emit PriceUpdated(goldPricePerGram, block.timestamp);
    }

    /**
     * @dev Get current gold price per gram in USD
     * @return price Current gold price with 8 decimals
     */
    function getGoldPricePerGram() external view returns (uint256) {
        return goldPricePerGram;
    }

    /**
     * @dev Get gold price per gram with timestamp
     * @return price Current gold price with 8 decimals
     * @return timestamp Last update timestamp
     */
    function getGoldPriceWithTimestamp() external view returns (uint256 price, uint256 timestamp) {
        return (goldPricePerGram, lastUpdated);
    }

    /**
     * @dev Update gold price (for testing or manual updates)
     * @param newPrice New gold price per gram in USD (8 decimals)
     */
    function updateGoldPrice(uint256 newPrice)
        external
        onlyOwner
        notEmergencyStopped
        whenNotPaused
        nonReentrant
        validPrice(newPrice)
    {
        uint256 oldPrice = goldPricePerGram;

        // Check if price change is within acceptable limits
        uint256 priceChange = _calculatePriceChange(oldPrice, newPrice);
        require(priceChange <= MAX_PRICE_CHANGE, "GoldPriceOracle: Price change too large");

        goldPricePerGram = newPrice;
        lastUpdated = block.timestamp;

        emit PriceUpdated(newPrice, block.timestamp);
    }

    /**
     * @dev Calculate price change percentage
     * @param oldPrice Previous price
     * @param newPrice New price
     * @return changePercentage Change percentage (1000 = 10%)
     */
    function _calculatePriceChange(uint256 oldPrice, uint256 newPrice) internal pure returns (uint256) {
        if (oldPrice == 0) return 0;

        uint256 difference = newPrice > oldPrice ? newPrice - oldPrice : oldPrice - newPrice;
        return (difference * 10000) / oldPrice; // Return basis points (10000 = 100%)
    }

    /**
     * @dev Set mock price mode (for testing)
     * @param useMock True to use mock price, false for real oracle
     */
    function setMockPriceMode(bool useMock) external onlyOwner {
        useMockPrice = useMock;
    }

    /**
     * @dev Update mock price (for testing)
     * @param mockPrice New mock price per gram in USD (8 decimals)
     */
    function updateMockPrice(uint256 mockPrice) external onlyOwner validPrice(mockPrice) {
        mockPricePerGram = mockPrice;
        if (useMockPrice) {
            goldPricePerGram = mockPrice;
            lastUpdated = block.timestamp;
            emit PriceUpdated(mockPrice, block.timestamp);
        }
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
     * @dev Check if price is stale (older than threshold)
     * @return isStale True if price is stale
     */
    function isPriceStale() external view returns (bool) {
        return block.timestamp - lastUpdated > UPDATE_THRESHOLD;
    }

    /**
     * @dev Get time since last update
     * @return secondsElapsed Seconds since last price update
     */
    function getTimeSinceLastUpdate() external view returns (uint256) {
        return block.timestamp - lastUpdated;
    }

    /**
     * @dev Convert USD amount to POI tokens based on current gold price
     * @param usdAmount USD amount (18 decimals)
     * @return poiAmount Equivalent POI tokens (18 decimals)
     */
    function convertUsdToPoi(uint256 usdAmount) external view returns (uint256) {
        require(usdAmount > 0, "GoldPriceOracle: USD amount must be greater than zero");

        // Convert gold price from 8 decimals to 18 decimals for calculation
        uint256 goldPrice18Decimals = goldPricePerGram * 10 ** 10; // Add 10 more decimals

        // POI amount = USD amount / gold price per gram
        return (usdAmount * 10 ** 18) / goldPrice18Decimals;
    }

    /**
     * @dev Convert POI tokens to USD amount based on current gold price
     * @param poiAmount POI token amount (18 decimals)
     * @return usdAmount Equivalent USD amount (18 decimals)
     */
    function convertPoiToUsd(uint256 poiAmount) external view returns (uint256) {
        require(poiAmount > 0, "GoldPriceOracle: POI amount must be greater than zero");

        // Convert gold price from 8 decimals to 18 decimals for calculation
        uint256 goldPrice18Decimals = goldPricePerGram * 10 ** 10; // Add 10 more decimals

        // USD amount = POI amount * gold price per gram
        return (poiAmount * goldPrice18Decimals) / 10 ** 18;
    }
}
