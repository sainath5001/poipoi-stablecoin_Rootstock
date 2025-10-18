// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/POIPOI.sol";
import "../src/GoldPriceOracle.sol";
import "../src/POIPOIManager.sol";
import "../src/MockCollateralToken.sol";

/**
 * @title DeployPOIPOI
 * @dev Deployment script for POIPOI stablecoin system on Rootstock
 * @author POIPOI Team
 */
contract DeployPOIPOI is Script {
    // Contracts to deploy
    MockCollateralToken public collateralToken;
    GoldPriceOracle public goldOracle;
    POIPOI public poiToken;
    POIPOIManager public manager;

    // Deployment parameters
    uint256 public constant INITIAL_GOLD_PRICE = 65000000; // $65 per gram (8 decimals)
    uint256 public constant INITIAL_COLLATERAL_SUPPLY = 1000000 * 10 ** 18; // 1M tokens

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console.log("Deploying POIPOI system...");
        console.log("Deployer address:", deployer);
        console.log("Deployer balance:", deployer.balance);

        vm.startBroadcast(deployerPrivateKey);

        // Step 1: Deploy Mock Collateral Token
        console.log("\n1. Deploying Mock Collateral Token...");
        collateralToken = new MockCollateralToken();
        console.log("MockCollateralToken deployed at:", address(collateralToken));

        // Step 2: Deploy Gold Price Oracle
        console.log("\n2. Deploying Gold Price Oracle...");
        // For now, deploy with mock price (address(0) = mock mode)
        // To use live prices, replace address(0) with Chainlink price feed address
        goldOracle = new GoldPriceOracle(address(0));
        console.log("GoldPriceOracle deployed at:", address(goldOracle));
        console.log("Using mock price mode. To enable live prices, call setGoldPriceFeed()");

        // Step 3: Deploy POIPOI Token (with temporary manager address)
        console.log("\n3. Deploying POIPOI Token...");
        poiToken = new POIPOI(deployer); // Use deployer as temporary manager
        console.log("POIPOI token deployed at:", address(poiToken));

        // Step 4: Deploy POIPOI Manager
        console.log("\n4. Deploying POIPOI Manager...");
        manager = new POIPOIManager(address(poiToken), address(goldOracle), address(collateralToken));
        console.log("POIPOIManager deployed at:", address(manager));

        // Step 5: Update POI token with manager address
        console.log("\n5. Updating POI token manager...");
        poiToken.updateManager(address(manager));
        console.log("POI token manager updated to:", address(manager));

        // Step 6: Configure oracle with initial price
        console.log("\n6. Setting initial gold price...");
        goldOracle.updateGoldPrice(INITIAL_GOLD_PRICE);
        console.log("Initial gold price set to:", INITIAL_GOLD_PRICE, "($65 per gram)");

        // Step 7: Mint initial collateral tokens to deployer
        console.log("\n7. Minting initial collateral tokens...");
        collateralToken.mint(deployer, INITIAL_COLLATERAL_SUPPLY);
        console.log("Minted", INITIAL_COLLATERAL_SUPPLY / 10 ** 18, "collateral tokens to deployer");

        vm.stopBroadcast();

        // Display deployment summary
        console.log("\n=== DEPLOYMENT SUMMARY ===");
        console.log("Network: Rootstock");
        console.log("Deployer:", deployer);
        console.log("MockCollateralToken:", address(collateralToken));
        console.log("GoldPriceOracle:", address(goldOracle));
        console.log("POIPOI Token:", address(poiToken));
        console.log("POIPOIManager:", address(manager));
        console.log("Initial Gold Price: $65 per gram");
        console.log("Initial Collateral Supply: 1,000,000 tokens");

        // Verify contracts
        console.log("\n=== VERIFICATION ===");
        console.log("POI Token Name:", poiToken.name());
        console.log("POI Token Symbol:", poiToken.symbol());
        console.log("POI Token Decimals:", poiToken.decimals());
        console.log("POI Token Manager:", poiToken.getManager());
        console.log("Current Gold Price:", goldOracle.getGoldPricePerGram());
        console.log("Collateral Token Balance:", collateralToken.balanceOf(deployer) / 10 ** 18);
    }

    /**
     * @dev Test deployment locally without broadcasting
     */
    function testDeployment() external {
        console.log("Testing deployment locally...");

        // Deploy contracts locally
        collateralToken = new MockCollateralToken();
        goldOracle = new GoldPriceOracle(address(0)); // Mock mode for testing

        // Create a temporary manager address for testing
        address tempManager = address(0x1234567890123456789012345678901234567890);
        poiToken = new POIPOI(tempManager);
        manager = new POIPOIManager(address(poiToken), address(goldOracle), address(collateralToken));

        // Update manager
        poiToken.updateManager(address(manager));

        // Set initial price
        goldOracle.updateGoldPrice(INITIAL_GOLD_PRICE);

        // Mint collateral to test account
        address testAccount = address(0x123);
        collateralToken.mint(testAccount, INITIAL_COLLATERAL_SUPPLY);

        console.log("Local deployment test completed successfully!");
        console.log("All contracts deployed and configured correctly.");
    }
}
