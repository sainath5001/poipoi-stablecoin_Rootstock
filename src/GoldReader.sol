// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

// LayerZero Endpoint V2 interface
import "@layerzero/interfaces/ILayerZeroEndpointV2.sol";

// Chainlink Aggregator interface for reading XAU/USD price
interface IAggregatorV3Interface {
    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}

/**
 * @title GoldReader
 * @dev Contract that fetches real-time gold price (XAU/USD) from Ethereum Chainlink using LayerZero
 * @notice This contract uses LayerZero's lzRead to pull Chainlink price data from Ethereum mainnet
 * @author POIPOI Team
 */
contract GoldReader is Ownable {
    // Events
    event PriceFetched(int256 price, uint256 timestamp);
    event EndpointUpdated(address indexed newEndpoint);
    event ChainlinkFeedUpdated(address indexed newFeed);
    event FallbackOracleUpdated(address indexed newOracle);

    // Constants
    uint32 public constant ETHEREUM_EID = 1; // LayerZero endpoint ID for Ethereum mainnet
    uint32 public constant ROOTSTOCK_EID = 607; // LayerZero endpoint ID for Rootstock testnet
    uint256 public constant OUNCE_TO_GRAM = 3110347680; // 31.1034768 * 100 (for precision with 8 decimals)

    // State variables
    ILayerZeroEndpointV2 public lzEndpoint; // LayerZero endpoint on Rootstock
    IAggregatorV3Interface public chainlinkFeed; // Chainlink XAU/USD feed on Ethereum
    address public fallbackOracle; // Fallback oracle address (optional)

    // Price storage
    int256 public lastPrice; // Last fetched price (per ounce, in USD with 8 decimals)
    uint256 public lastUpdated; // Timestamp of last update
    uint256 public constant STALE_THRESHOLD = 3600; // 1 hour stale threshold

    /**
     * @dev Constructor to initialize LayerZero endpoint and Chainlink feed addresses
     * @param _lzEndpoint Address of LayerZero Endpoint V2 on Rootstock
     * @param _chainlinkFeed Address of Chainlink XAU/USD aggregator on Ethereum
     * @param _fallbackOracle Optional fallback oracle address (address(0) to disable)
     */
    constructor(address _lzEndpoint, address _chainlinkFeed, address _fallbackOracle) Ownable(msg.sender) {
        require(_chainlinkFeed != address(0), "GoldReader: Invalid chainlink feed address");

        lzEndpoint = ILayerZeroEndpointV2(_lzEndpoint);
        chainlinkFeed = IAggregatorV3Interface(_chainlinkFeed);
        fallbackOracle = _fallbackOracle;
    }

    /**
     * @dev Fetch the latest gold price from Chainlink on Ethereum using LayerZero lzRead
     * @return price The price of gold per ounce in USD (8 decimals)
     * @notice This is the preferred method - pulls data from Ethereum Chainlink feed
     *
     * How lzRead works:
     * 1. We construct the function call to latestRoundData() using ABI encoding
     * 2. lzRead sends this to Ethereum via LayerZero
     * 3. Returns the encoded response which we decode
     * 4. The response contains (roundId, answer, startedAt, updatedAt, answeredInRound)
     */
    function getGoldPrice() public view returns (int256 price) {
        try this.fetchPriceFromChainlink() returns (int256 fetchedPrice) {
            return fetchedPrice;
        } catch {
            // If LayerZero fetch fails, return last known price
            require(lastUpdated > 0, "GoldReader: No price available");
            return lastPrice;
        }
    }

    /**
     * @dev Internal function to fetch price from Chainlink using lzRead
     * @return price Gold price per ounce in USD (8 decimals)
     *
     * ABI Encoding Explanation:
     * - We need to call latestRoundData() which has signature: 0xfeaf968c
     * - The function has no parameters, so payload is just the function selector
     * - Response is a tuple: (uint80, int256, uint256, uint256, uint80)
     * - We decode this tuple to extract the 'answer' field (index 1)
     */
    function fetchPriceFromChainlink() external view returns (int256 price) {
        // Step 1: Encode the function call to latestRoundData()
        // Function signature: latestRoundData() -> bytes4(keccak256("latestRoundData()")) = 0xfeaf968c
        bytes memory payload = abi.encodeWithSignature("latestRoundData()");

        // Step 2: Use lzRead to query Ethereum Chainlink feed
        bytes memory result = lzEndpoint.lzRead(ETHEREUM_EID, address(chainlinkFeed), payload);

        // Step 3: Decode the response
        // Response is: (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
        (, int256 answer,,,) = abi.decode(result, (uint80, int256, uint256, uint256, uint80));

        return answer;
    }

    /**
     * @dev Update and store the latest gold price
     * @return success Whether the price was successfully updated
     * @notice This function should be called periodically by a keeper/oracle
     */
    function updatePrice() external returns (bool success) {
        int256 newPrice = getGoldPrice();
        require(newPrice > 0, "GoldReader: Invalid price received");

        lastPrice = newPrice;
        lastUpdated = block.timestamp;

        emit PriceFetched(newPrice, block.timestamp);
        return true;
    }

    /**
     * @dev Get gold price per gram (converted from per ounce)
     * @return price Price per gram in USD (8 decimals)
     * @notice Chainlink returns price per ounce, we convert to per gram
     * Formula: price_per_gram = price_per_ounce / 31.1034768
     */
    function getGoldPricePerGram() external view returns (uint256 price) {
        int256 pricePerOunce = getGoldPrice();
        require(pricePerOunce > 0, "GoldReader: Invalid price");

        // Convert from price per ounce to price per gram
        // Formula: price_per_gram = price_per_ounce / 31.1034768
        return (uint256(pricePerOunce) * 10 ** 8) / OUNCE_TO_GRAM;
    }

    /**
     * @dev Check if the price is stale (older than threshold)
     * @return isStale True if price is stale
     */
    function isPriceStale() external view returns (bool isStale) {
        if (lastUpdated == 0) return true;
        return block.timestamp - lastUpdated > STALE_THRESHOLD;
    }

    /**
     * @dev Set LayerZero endpoint address
     * @param _newEndpoint New endpoint address
     */
    function setEndpoint(address _newEndpoint) external onlyOwner {
        require(_newEndpoint != address(0), "GoldReader: Invalid endpoint address");
        lzEndpoint = ILayerZeroEndpointV2(_newEndpoint);
        emit EndpointUpdated(_newEndpoint);
    }

    /**
     * @dev Set Chainlink feed address
     * @param _newFeed New nu feed address
     */
    function setChainlinkFeed(address _newFeed) external onlyOwner {
        require(_newFeed != address(0), "GoldReader: Invalid feed address");
        chainlinkFeed = IAggregatorV3Interface(_newFeed);
        emit ChainlinkFeedUpdated(_newFeed);
    }

    /**
     * @dev Set fallback oracle address
     * @param _newOracle New fallback oracle address
     */
    function setFallbackOracle(address _newOracle) external onlyOwner {
        fallbackOracle = _newOracle;
        emit FallbackOracleUpdated(_newOracle);
    }

    /**
     * @dev Get price with timestamp
     * @return price Gold price per ounce
     * @return timestamp Last update timestamp
     */
    function getPriceWithTimestamp() external view returns (int256 price, uint256 timestamp) {
        return (lastPrice, lastUpdated);
    }

    /**
     * @dev Emergency function to set price manually (fallback only)
     * @param _price Manual price to set
     * @notice Only use this if LayerZero fetch is not working
     */
    function setManualPrice(int256 _price) external onlyOwner {
        require(_price > 0, "GoldReader: Invalid price");
        lastPrice = _price;
        lastUpdated = block.timestamp;
        emit PriceFetched(_price, block.timestamp);
    }
}
