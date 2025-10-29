// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/GoldReader.sol";
import "../lib/layerzero-contracts/interfaces/ILayerZeroEndpointV2.sol";

/**
 * @title GoldReaderTest
 * @dev Comprehensive test suite for GoldReader contract
 * @notice Tests LayerZero integration and fallback mechanisms
 * @author POIPOI Team
 */
contract GoldReaderTest is Test {
    // Contracts
    GoldReader public goldReader;
    MockLayerZeroEndpoint public mockLzEndpoint;

    // Test accounts
    address public owner;
    address public user1;

    // Test constants
    address public constant MOCK_CHAINLINK_FEED = address(0x1234567890123456789012345678901234567890);
    uint256 public constant MOCK_GOLD_PRICE = 200000000000; // $2000 per ounce (8 decimals)

    // Events
    event PriceFetched(int256 price, uint256 timestamp);
    event EndpointUpdated(address indexed newEndpoint);

    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");

        // Deploy mock LayerZero endpoint
        mockLzEndpoint = new MockLayerZeroEndpoint();

        // Deploy GoldReader
        goldReader = new GoldReader(address(mockLzEndpoint), MOCK_CHAINLINK_FEED, address(0));
    }

    // ============ Constructor Tests ============

    function testConstructor() public view {
        assertEq(address(goldReader.lzEndpoint()), address(mockLzEndpoint));
        assertEq(address(goldReader.chainlinkFeed()), MOCK_CHAINLINK_FEED);
        assertEq(goldReader.fallbackOracle(), address(0));
        assertEq(goldReader.owner(), owner);
    }

    // Note: Constructor now allows zero endpoint address for deployment flexibility
    // The endpoint can be set later using setEndpoint()
    function testConstructorWithZeroEndpoint() public {
        GoldReader reader = new GoldReader(address(0), MOCK_CHAINLINK_FEED, address(0));
        assertEq(address(reader.lzEndpoint()), address(0));
    }

    function testConstructorRevertsWithZeroChainlinkFeed() public {
        vm.expectRevert("GoldReader: Invalid chainlink feed address");
        new GoldReader(address(mockLzEndpoint), address(0), address(0));
    }

    // ============ Price Fetching Tests ============

    function testFetchPriceFromChainlink() public {
        // Set mock price in LayerZero endpoint
        mockLzEndpoint.setMockPrice(MOCK_GOLD_PRICE);

        // Fetch price
        int256 price = goldReader.fetchPriceFromChainlink();

        assertEq(price, int256(MOCK_GOLD_PRICE));
    }

    function testGetGoldPriceSuccess() public {
        // Set mock price
        mockLzEndpoint.setMockPrice(MOCK_GOLD_PRICE);

        // Update price to store it
        goldReader.updatePrice();

        // Get stored price
        int256 price = goldReader.getGoldPrice();

        assertEq(price, int256(MOCK_GOLD_PRICE));
    }

    function testGetGoldPriceReturnsLastPriceOnFailure() public {
        // First set a price
        mockLzEndpoint.setMockPrice(MOCK_GOLD_PRICE);
        goldReader.updatePrice();

        // Make lzRead fail by reverting
        mockLzEndpoint.setShouldRevert(true);

        // Should return last stored price
        int256 price = goldReader.getGoldPrice();
        assertEq(price, int256(MOCK_GOLD_PRICE));
    }

    function testGetGoldPriceRevertsWhenNoPriceAvailable() public {
        // Make lzRead fail and ensure no price was ever set
        mockLzEndpoint.setShouldRevert(true);

        vm.expectRevert("GoldReader: No price available");
        goldReader.getGoldPrice();
    }

    // ============ Price Conversion Tests ============

    function testGetGoldPricePerGram() public {
        // Set mock price: $2000 per ounce
        mockLzEndpoint.setMockPrice(200000000000); // $2000 with 8 decimals
        goldReader.updatePrice();

        // Get price per gram
        uint256 pricePerGram = goldReader.getGoldPricePerGram();

        // $2000 / 31.1034768 = ~$64.30 per gram
        // With 8 decimals, this should be approximately 6430000000
        // Let's verify it's close (within reasonable rounding)
        assertTrue(pricePerGram > 6000000000 && pricePerGram < 6500000000);
    }

    function testGetGoldPricePerGramRevertsOnInvalidPrice() public {
        vm.expectRevert("GoldReader: Invalid price");
        goldReader.getGoldPricePerGram();
    }

    // ============ Update Price Tests ============

    function testUpdatePrice() public {
        mockLzEndpoint.setMockPrice(MOCK_GOLD_PRICE);

        vm.expectEmit(true, false, false, true);
        emit PriceFetched(int256(MOCK_GOLD_PRICE), block.timestamp);

        bool success = goldReader.updatePrice();

        assertTrue(success);
        assertEq(goldReader.lastPrice(), int256(MOCK_GOLD_PRICE));
        assertEq(goldReader.lastUpdated(), block.timestamp);
    }

    function testUpdatePriceRevertsOnInvalidPrice() public {
        // Set negative price in mock
        mockLzEndpoint.setMockPrice(0);

        vm.expectRevert("GoldReader: Invalid price received");
        goldReader.updatePrice();
    }

    // ============ Manual Price Setting Tests ============

    function testSetManualPrice() public {
        int256 manualPrice = 210000000000; // $2100 per ounce

        vm.expectEmit(true, false, false, true);
        emit PriceFetched(manualPrice, block.timestamp);

        goldReader.setManualPrice(manualPrice);

        assertEq(goldReader.lastPrice(), manualPrice);
        assertEq(goldReader.lastUpdated(), block.timestamp);
    }

    function testSetManualPriceRevertsOnInvalidPrice() public {
        vm.expectRevert("GoldReader: Invalid price");
        goldReader.setManualPrice(0);

        vm.expectRevert("GoldReader: Invalid price");
        goldReader.setManualPrice(-100000000000);
    }

    function testSetManualPriceOnlyOwner() public {
        vm.prank(user1);
        vm.expectRevert();
        goldReader.setManualPrice(int256(MOCK_GOLD_PRICE));
    }

    // ============ Configuration Tests ============

    function testSetEndpoint() public {
        address newEndpoint = address(0x9999999999999999999999999999999999999999);

        vm.expectEmit(true, false, false, false);
        emit EndpointUpdated(newEndpoint);

        goldReader.setEndpoint(newEndpoint);

        assertEq(address(goldReader.lzEndpoint()), newEndpoint);
    }

    function testSetEndpointRevertsOnZeroAddress() public {
        vm.expectRevert("GoldReader: Invalid endpoint address");
        goldReader.setEndpoint(address(0));
    }

    function testSetEndpointOnlyOwner() public {
        vm.prank(user1);
        vm.expectRevert();
        goldReader.setEndpoint(address(0x123));
    }

    function testSetChainlinkFeed() public {
        address newFeed = address(0x8888888888888888888888888888888888888888);

        goldReader.setChainlinkFeed(newFeed);

        assertEq(address(goldReader.chainlinkFeed()), newFeed);
    }

    function testSetChainlinkFeedRevertsOnZeroAddress() public {
        vm.expectRevert("GoldReader: Invalid feed address");
        goldReader.setChainlinkFeed(address(0));
    }

    function testSetFallbackOracle() public {
        address newOracle = address(0x7777777777777777777777777777777777777777);

        goldReader.setFallbackOracle(newOracle);

        assertEq(goldReader.fallbackOracle(), newOracle);
    }

    // ============ Price Staleness Tests ============

    function testIsPriceStale() public {
        // Initially stale (no price set)
        assertTrue(goldReader.isPriceStale());

        // Set price
        mockLzEndpoint.setMockPrice(MOCK_GOLD_PRICE);
        goldReader.updatePrice();

        // Should not be stale
        assertFalse(goldReader.isPriceStale());

        // Warp time forward
        vm.warp(block.timestamp + 3601); // 1 hour + 1 second

        // Should now be stale
        assertTrue(goldReader.isPriceStale());
    }

    function testGetPriceWithTimestamp() public {
        mockLzEndpoint.setMockPrice(MOCK_GOLD_PRICE);
        goldReader.updatePrice();

        (int256 price, uint256 timestamp) = goldReader.getPriceWithTimestamp();

        assertEq(price, int256(MOCK_GOLD_PRICE));
        assertEq(timestamp, block.timestamp);
    }

    // ============ Mock LayerZero Endpoint ============
}

/**
 * @title MockLayerZeroEndpoint
 * @dev Mock LayerZero endpoint for testing purposes
 */
contract MockLayerZeroEndpoint is ILayerZeroEndpointV2 {
    int256 public mockPrice;
    bool public shouldRevert;

    function setMockPrice(uint256 _price) external {
        mockPrice = int256(_price);
        shouldRevert = false;
    }

    function setShouldRevert(bool _shouldRevert) external {
        shouldRevert = _shouldRevert;
    }

    function lzRead(uint32, /* _dstEid */ address, /* _target */ bytes calldata /* _payload */ )
        external
        view
        override
        returns (bytes memory)
    {
        if (shouldRevert) {
            revert("MockLayerZeroEndpoint: Simulated failure");
        }

        // Return mock latestRoundData response
        // (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
        return abi.encode(uint80(123), mockPrice, block.timestamp, block.timestamp, uint80(123));
    }

    function lzReceive(
        uint32, /* _srcEid */
        address, /* _caller */
        bytes calldata, /* _oappOptions */
        bytes calldata /* _payload */
    ) external override returns (bytes memory) {
        return "";
    }
}
