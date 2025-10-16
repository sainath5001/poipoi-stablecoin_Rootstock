// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/POIPOI.sol";
import "../src/GoldPriceOracle.sol";
import "../src/POIPOIManager.sol";
import "../src/MockCollateralToken.sol";

/**
 * @title POIPOITest
 * @dev Comprehensive test suite for POIPOI stablecoin system
 * @author POIPOI Team
 */
contract POIPOITest is Test {
    // Contracts
    POIPOI public poiToken;
    GoldPriceOracle public goldOracle;
    POIPOIManager public manager;
    MockCollateralToken public collateralToken;

    // Test accounts
    address public owner;
    address public user1;
    address public user2;
    address public user3;

    // Test constants
    uint256 public constant INITIAL_GOLD_PRICE = 65000000; // $65 per gram (8 decimals)
    uint256 public constant COLLATERAL_AMOUNT = 1000 * 10 ** 18; // 1000 tokens
    uint256 public constant POI_DECIMALS = 18;
    uint256 public constant GOLD_PRICE_DECIMALS = 8;

    // Events to test
    event TokensMinted(address indexed to, uint256 amount, uint256 goldPrice);
    event TokensBurned(address indexed from, uint256 amount, uint256 goldPrice);
    event PriceUpdated(uint256 indexed price, uint256 timestamp);

    function setUp() public {
        // Set up test accounts
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        user3 = makeAddr("user3");

        // Deploy contracts
        collateralToken = new MockCollateralToken();
        goldOracle = new GoldPriceOracle();

        // Deploy POI token with temporary address first
        poiToken = new POIPOI(address(this)); // Use this as temporary manager

        // Deploy manager
        manager = new POIPOIManager(address(poiToken), address(goldOracle), address(collateralToken));

        // Update POI token with actual manager address
        poiToken.updateManager(address(manager));

        // Give users some collateral tokens
        collateralToken.mint(user1, 10000 * 10 ** 18);
        collateralToken.mint(user2, 10000 * 10 ** 18);
        collateralToken.mint(user3, 10000 * 10 ** 18);

        // Approve manager to spend collateral tokens
        vm.prank(user1);
        collateralToken.approve(address(manager), type(uint256).max);

        vm.prank(user2);
        collateralToken.approve(address(manager), type(uint256).max);

        vm.prank(user3);
        collateralToken.approve(address(manager), type(uint256).max);
    }

    // ============ Constructor Tests ============

    function testConstructor() public view {
        assertEq(poiToken.name(), "POIPOI");
        assertEq(poiToken.symbol(), "POI");
        assertEq(poiToken.decimals(), 18);
        assertEq(poiToken.totalSupply(), 0);
        assertEq(poiToken.getManager(), address(manager));
    }

    function testOracleConstructor() public view {
        assertEq(goldOracle.getGoldPricePerGram(), INITIAL_GOLD_PRICE);
        assertTrue(goldOracle.isPriceStale() == false);
    }

    function testManagerConstructor() public view {
        assertEq(address(manager.poiToken()), address(poiToken));
        assertEq(address(manager.goldOracle()), address(goldOracle));
        assertEq(address(manager.collateralToken()), address(collateralToken));
    }

    // ============ Minting Tests ============

    function testMintPoi() public {
        uint256 collateralAmount = COLLATERAL_AMOUNT;
        uint256 expectedPoiAmount = goldOracle.convertUsdToPoi(collateralAmount);

        vm.prank(user1);
        uint256 actualPoiAmount = manager.mintPoi(collateralAmount);

        assertEq(actualPoiAmount, expectedPoiAmount);
        assertEq(poiToken.balanceOf(user1), expectedPoiAmount);
        assertEq(collateralToken.balanceOf(address(manager)), collateralAmount);
        assertEq(collateralToken.balanceOf(user1), 10000 * 10 ** 18 - collateralAmount);
    }

    function testMintPoiMultipleUsers() public {
        uint256 collateralAmount = COLLATERAL_AMOUNT;

        vm.prank(user1);
        uint256 poiAmount1 = manager.mintPoi(collateralAmount);

        vm.prank(user2);
        uint256 poiAmount2 = manager.mintPoi(collateralAmount);

        assertEq(poiAmount1, poiAmount2); // Same collateral should give same POI
        assertEq(poiToken.balanceOf(user1), poiAmount1);
        assertEq(poiToken.balanceOf(user2), poiAmount2);
        assertEq(poiToken.totalSupply(), poiAmount1 + poiAmount2);
    }

    function testMintPoiWithDifferentAmounts() public {
        uint256 amount1 = 500 * 10 ** 18;
        uint256 amount2 = 2000 * 10 ** 18;

        vm.prank(user1);
        uint256 poiAmount1 = manager.mintPoi(amount1);

        vm.prank(user2);
        uint256 poiAmount2 = manager.mintPoi(amount2);

        assertTrue(poiAmount2 > poiAmount1); // More collateral should give more POI
        assertEq(poiAmount2 / poiAmount1, 4); // Should be exactly 4x
    }

    function testMintPoiReverts() public {
        // Test zero amount
        vm.prank(user1);
        vm.expectRevert("POIPOIManager: Amount must be greater than zero");
        manager.mintPoi(0);

        // Test insufficient collateral balance
        vm.prank(user1);
        vm.expectRevert();
        manager.mintPoi(20000 * 10 ** 18); // More than user has

        // Test insufficient allowance
        vm.prank(user1);
        collateralToken.approve(address(manager), 0);

        vm.prank(user1);
        vm.expectRevert();
        manager.mintPoi(COLLATERAL_AMOUNT);
    }

    // ============ Redemption Tests ============

    function testRedeemPoi() public {
        // First mint some POI tokens
        uint256 collateralAmount = COLLATERAL_AMOUNT;

        vm.prank(user1);
        uint256 poiAmount = manager.mintPoi(collateralAmount);

        uint256 initialCollateralBalance = collateralToken.balanceOf(user1);

        // Now redeem the POI tokens
        vm.prank(user1);
        uint256 returnedCollateral = manager.redeemPoi(poiAmount);

        // Allow for small rounding differences
        assertTrue(returnedCollateral >= collateralAmount * 999 / 1000); // Within 0.1%
        assertTrue(returnedCollateral <= collateralAmount * 1001 / 1000); // Within 0.1%
        assertEq(poiToken.balanceOf(user1), 0);
        assertTrue(collateralToken.balanceOf(user1) >= initialCollateralBalance * 999 / 1000);
        assertEq(poiToken.totalSupply(), 0);
    }

    function testRedeemPoiPartial() public {
        // Mint POI tokens
        uint256 collateralAmount = COLLATERAL_AMOUNT;

        vm.prank(user1);
        uint256 poiAmount = manager.mintPoi(collateralAmount);

        // Redeem half
        uint256 redeemAmount = poiAmount / 2;

        vm.prank(user1);
        uint256 returnedCollateral = manager.redeemPoi(redeemAmount);

        assertEq(poiToken.balanceOf(user1), poiAmount - redeemAmount);
        assertEq(poiToken.totalSupply(), poiAmount - redeemAmount);
        // Allow for small rounding differences
        assertTrue(returnedCollateral >= (collateralAmount / 2) - 1);
        assertTrue(returnedCollateral <= (collateralAmount / 2) + 1);
    }

    function testRedeemPoiReverts() public {
        // Test zero amount
        vm.prank(user1);
        vm.expectRevert("POIPOIManager: Amount must be greater than zero");
        manager.redeemPoi(0);

        // Test insufficient POI balance
        vm.prank(user1);
        vm.expectRevert("POIPOIManager: Insufficient POI balance");
        manager.redeemPoi(1000 * 10 ** 18);

        // Test insufficient collateral reserves
        vm.prank(user1);
        uint256 poiAmount = manager.mintPoi(COLLATERAL_AMOUNT);

        // Drain collateral from manager
        vm.prank(owner);
        manager.emergencyWithdrawCollateral(collateralToken.balanceOf(address(manager)));

        vm.prank(user1);
        vm.expectRevert("POIPOIManager: Insufficient collateral reserves");
        manager.redeemPoi(poiAmount);
    }

    // ============ Price Oracle Tests ============

    function testUpdateGoldPrice() public {
        uint256 newPrice = 70000000; // $70 per gram

        goldOracle.updateGoldPrice(newPrice);

        assertEq(goldOracle.getGoldPricePerGram(), newPrice);
        assertTrue(goldOracle.getTimeSinceLastUpdate() < 10); // Should be recent
    }

    function testPriceChangeLimit() public {
        uint256 newPrice = 100000000; // $100 per gram (too high change)

        vm.expectRevert("GoldPriceOracle: Price change too large");
        goldOracle.updateGoldPrice(newPrice);
    }

    function testConvertUsdToPoi() public view {
        uint256 usdAmount = 1000 * 10 ** 18; // $1000
        uint256 expectedPoi = goldOracle.convertUsdToPoi(usdAmount);

        // Should be exactly 1000 / 65 = 15.38461538461538461538 POI tokens
        assertEq(expectedPoi, 1538461538461538461538);
    }

    function testConvertPoiToUsd() public view {
        uint256 poiAmount = 10 * 10 ** 18; // 10 POI tokens
        uint256 expectedUsd = goldOracle.convertPoiToUsd(poiAmount);

        // Should be exactly 10 * 65 = $650 (6.5e18)
        assertEq(expectedUsd, 65 * 10 ** 17);
    }

    // ============ Access Control Tests ============

    function testOnlyManagerCanMint() public {
        vm.prank(user1);
        vm.expectRevert("POIPOI: Only manager can call this function");
        poiToken.mint(user1, 1000 * 10 ** 18, INITIAL_GOLD_PRICE);
    }

    function testOnlyManagerCanBurn() public {
        vm.prank(user1);
        vm.expectRevert("POIPOI: Only manager can call this function");
        poiToken.burn(user1, 1000 * 10 ** 18, INITIAL_GOLD_PRICE);
    }

    function testOnlyOwnerCanUpdateManager() public {
        vm.prank(user1);
        vm.expectRevert();
        poiToken.updateManager(user1);
    }

    function testOnlyOwnerCanUpdateOracle() public {
        vm.prank(user1);
        vm.expectRevert();
        manager.updateGoldOracle(user1);
    }

    // ============ Emergency Controls Tests ============

    function testEmergencyStop() public {
        poiToken.setEmergencyStop(true);

        vm.prank(user1);
        vm.expectRevert("POIPOI: Contract is emergency stopped");
        manager.mintPoi(COLLATERAL_AMOUNT);
    }

    function testPauseUnpause() public {
        poiToken.pause();

        vm.prank(user1);
        vm.expectRevert();
        manager.mintPoi(COLLATERAL_AMOUNT);

        poiToken.unpause();

        vm.prank(user1);
        manager.mintPoi(COLLATERAL_AMOUNT); // Should work now
    }

    // ============ Integration Tests ============

    function testFullCycle() public {
        uint256 collateralAmount = COLLATERAL_AMOUNT;

        // Mint POI tokens
        vm.prank(user1);
        uint256 poiAmount = manager.mintPoi(collateralAmount);

        // Transfer POI tokens to another user
        vm.prank(user1);
        poiToken.transfer(user2, poiAmount);

        // User2 redeems POI tokens
        vm.prank(user2);
        uint256 returnedCollateral = manager.redeemPoi(poiAmount);

        // Allow for small rounding differences
        assertTrue(returnedCollateral >= collateralAmount * 999 / 1000); // Within 0.1%
        assertTrue(returnedCollateral <= collateralAmount * 1001 / 1000); // Within 0.1%
        assertEq(poiToken.balanceOf(user2), 0);
        assertTrue(collateralToken.balanceOf(user2) >= (10000 * 10 ** 18 + collateralAmount) * 999 / 1000);
    }

    function testPriceUpdateAffectsMinting() public {
        uint256 collateralAmount = COLLATERAL_AMOUNT;

        // Mint at initial price
        vm.prank(user1);
        uint256 poiAmount1 = manager.mintPoi(collateralAmount);

        // Update price
        goldOracle.updateGoldPrice(70000000); // $70 per gram

        // Mint same collateral amount at new price
        vm.prank(user2);
        uint256 poiAmount2 = manager.mintPoi(collateralAmount);

        // Should get fewer POI tokens at higher gold price
        assertTrue(poiAmount2 < poiAmount1);
    }

    // ============ Edge Cases ============

    function testVerySmallAmounts() public {
        uint256 smallAmount = 1; // 1 wei

        vm.prank(user1);
        uint256 poiAmount = manager.mintPoi(smallAmount);

        assertTrue(poiAmount > 0);
        assertEq(poiToken.balanceOf(user1), poiAmount);
    }

    function testLargeAmounts() public {
        uint256 largeAmount = 5000 * 10 ** 18; // 5000 tokens

        vm.prank(user1);
        uint256 poiAmount = manager.mintPoi(largeAmount);

        assertTrue(poiAmount > 0);
        assertEq(poiToken.balanceOf(user1), poiAmount);
    }
}
