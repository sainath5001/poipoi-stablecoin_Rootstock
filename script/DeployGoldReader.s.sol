// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/GoldReader.sol";

/**
 * @title DeployGoldReader
 * @dev Deployment script for GoldReader contract
 * @author POIPOI Team
 */
contract DeployGoldReader is Script {
    // Contracts to deploy
    GoldReader public goldReader;

    // Deployment addresses based on LayerZero documentation
    // https://docs.layerzero.network/v2/deployments/chains/rootstock
    address public constant LZ_ENDPOINT_RSK_TESTNET = address(0x88fA785e4B93a6Cb98Ccf7c76cF77118Ae24fdbF); // LayerZero Endpoint V2 for Rootstock Testnet
    address public constant LZ_ENDPOINT_RSK_MAINNET = address(0); // Replace with actual endpoint

    // Chainlink XAU/USD feed on Ethereum mainnet
    // https://data.chain.link/feeds/ethereum/mainnet/xau-usd
    address public constant CHAINLINK_XAU_USD_ETHEREUM = 0x214ed9DA11D2fBe465a6Fc601A91E62EBD1A1c40;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console.log("Deploying GoldReader...");
        console.log("Deployer address:", deployer);
        console.log("Deployer balance:", deployer.balance);

        vm.startBroadcast(deployerPrivateKey);

        // Deploy GoldReader with address(0) as fallback oracle (no fallback needed)
        console.log("\nDeploying GoldReader...");
        console.log("LayerZero Endpoint:", LZ_ENDPOINT_RSK_TESTNET);
        console.log("Chainlink Feed:", CHAINLINK_XAU_USD_ETHEREUM);

        goldReader = new GoldReader(LZ_ENDPOINT_RSK_TESTNET, CHAINLINK_XAU_USD_ETHEREUM, address(0));
        console.log("GoldReader deployed at:", address(goldReader));

        vm.stopBroadcast();

        // Display deployment summary
        console.log("\n=== DEPLOYMENT SUMMARY ===");
        console.log("Network: Rootstock");
        console.log("Deployer:", deployer);
        console.log("GoldReader:", address(goldReader));
        console.log("LayerZero Endpoint:", LZ_ENDPOINT_RSK_TESTNET);
        console.log("Chainlink Feed (Ethereum):", CHAINLINK_XAU_USD_ETHEREUM);
        console.log("\nNote: Update LZ_ENDPOINT_RSK_TESTNET with actual LayerZero endpoint address");
    }

    /**
     * @dev Test deployment locally without broadcasting
     */
    function testDeployment() external {
        console.log("Testing deployment locally...");

        address mockLzEndpoint = address(0x1111111111111111111111111111111111111111);
        address mockChainlinkFeed = address(0x2222222222222222222222222222222222222222);

        // Deploy contract locally
        goldReader = new GoldReader(mockLzEndpoint, mockChainlinkFeed, address(0));

        console.log("Local deployment test completed successfully!");
        console.log("GoldReader:", address(goldReader));
    }

    /**
     * @dev Helper function to update LayerZero endpoint address if not set
     */
    function updateEndpointAddress(address _newEndpoint) external {
        require(_newEndpoint != address(0), "Invalid endpoint address");
        console.log("Updating GoldReader endpoint to:", _newEndpoint);
        goldReader.setEndpoint(_newEndpoint);
    }

    /**
     * @dev Helper function to test price fetching
     */
    function testFetchPrice() external view {
        console.log("Testing price fetch from GoldReader...");
        console.log("Current stored price:", uint256(goldReader.lastPrice()));
        console.log("Last updated:", goldReader.lastUpdated());

        try this.fetchAndLogPrice() {
            console.log("Price fetch test completed");
        } catch {
            console.log("Price fetch failed (expected in test environment)");
        }
    }

    function fetchAndLogPrice() external view {
        int256 price = goldReader.getGoldPrice();
        console.log("Fetched price:", uint256(price));
    }
}
