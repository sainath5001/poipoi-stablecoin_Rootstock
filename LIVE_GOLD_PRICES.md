# Live Gold Prices Integration Guide

## Current Setup

✅ **POIPOI Stablecoin is now ready for live gold prices!**

- **1 POI = 1 gram of gold** (exactly as you wanted)
- **Live price fetching** from Chainlink oracles
- **Automatic price conversion** from ounces to grams
- **Fallback to mock prices** for testing

## How to Enable Live Gold Prices

### Option 1: Chainlink Price Feeds (Recommended)

Chainlink provides gold price feeds on many networks. Here's how to set it up:

#### 1. Find Chainlink Gold Price Feed Address

For different networks, you can find gold price feeds at:
- **Ethereum Mainnet**: `0x214eD9Da11D2fbe465a6fc601a91E62EbD1A1C4` (XAU/USD)
- **Polygon**: `0x0C166F37A0d4b331bd2bBf3eF19c3a7c75aA62f5` (XAU/USD)
- **Rootstock**: Check Chainlink docs for RSK feeds

#### 2. Deploy with Live Prices

```bash
# Deploy with Chainlink price feed
forge script script/Deploy.s.sol:DeployPOIPOI --rpc-url $RPC_URL --broadcast --verify

# After deployment, set the price feed
cast send $ORACLE_ADDRESS "setGoldPriceFeed(address)" $CHAINLINK_FEED_ADDRESS --rpc-url $RPC_URL --private-key $PRIVATE_KEY
```

#### 3. Update Price from Chainlink

```bash
# Manually update price from Chainlink
cast send $ORACLE_ADDRESS "updatePriceFromChainlink()" --rpc-url $RPC_URL --private-key $PRIVATE_KEY
```

### Option 2: Custom Price API Integration

If Chainlink isn't available on Rootstock, you can integrate with other price APIs:

#### 1. Create a Price Updater Contract

```solidity
// PriceUpdater.sol
contract PriceUpdater {
    GoldPriceOracle public oracle;
    
    function updateGoldPrice() external {
        // Fetch price from API (using Chainlink Functions or custom oracle)
        uint256 newPrice = fetchGoldPriceFromAPI();
        oracle.updateGoldPrice(newPrice);
    }
}
```

#### 2. Set up Automated Updates

- Use Chainlink Automation (Keepers) to update prices every 5 minutes
- Or use a custom off-chain service to call `updateGoldPrice()`

## Price Conversion Details

The oracle automatically converts gold prices:

- **Chainlink provides**: Gold price per ounce (XAU/USD)
- **POIPOI uses**: Gold price per gram
- **Conversion**: 1 ounce = 31.1034768 grams
- **Formula**: Price per gram = Price per ounce ÷ 31.1034768

## Example: Current Gold Price

If gold is $2,000 per ounce:
- Price per gram = $2,000 ÷ 31.1034768 = $64.30 per gram
- 1 POI token = 1 gram = $64.30 worth of gold

## Testing Live Prices

### 1. Deploy with Mock Prices (Current)
```bash
forge script script/Deploy.s.sol:DeployPOIPOI --rpc-url $RPC_URL --broadcast
```

### 2. Switch to Live Prices
```bash
# Set Chainlink price feed
cast send $ORACLE_ADDRESS "setGoldPriceFeed(address)" $CHAINLINK_FEED --rpc-url $RPC_URL --private-key $PRIVATE_KEY

# Update price from Chainlink
cast send $ORACLE_ADDRESS "updatePriceFromChainlink()" --rpc-url $RPC_URL --private-key $PRIVATE_KEY
```

### 3. Check Current Price
```bash
# Get current gold price per gram
cast call $ORACLE_ADDRESS "getGoldPricePerGram()" --rpc-url $RPC_URL
```

## Security Features

✅ **Price Change Limits**: Maximum 10% price change per update
✅ **Staleness Checks**: Prices older than 5 minutes are considered stale
✅ **Fallback Protection**: Falls back to stored price if Chainlink fails
✅ **Emergency Controls**: Can pause or stop price updates
✅ **Access Control**: Only owner can update price feeds

## Monitoring

### Events to Watch
- `PriceUpdated(uint256 price, uint256 timestamp)`: When price is updated
- `OracleUpdated(address oldOracle, address newOracle)`: When price feed changes

### Key Functions
- `getGoldPricePerGram()`: Get current price per gram
- `isPriceStale()`: Check if price is stale
- `getTimeSinceLastUpdate()`: Time since last update

## Next Steps

1. **Deploy to Rootstock Testnet** with mock prices
2. **Test minting/redeeming** with mock prices
3. **Find Chainlink gold price feed** for Rootstock
4. **Switch to live prices** using `setGoldPriceFeed()`
5. **Set up automated updates** using Chainlink Automation
6. **Deploy to mainnet** with live prices

## Example Usage

```solidity
// Check current gold price
uint256 goldPrice = oracle.getGoldPricePerGram(); // Returns price in USD per gram (8 decimals)

// Mint POI tokens (1 POI = 1 gram of gold)
uint256 collateralAmount = 1000 * 10**18; // $1000
uint256 poiAmount = manager.mintPoi(collateralAmount); // Gets POI tokens based on current gold price

// Redeem POI tokens
uint256 returnedCollateral = manager.redeemPoi(poiAmount); // Returns equivalent USD collateral
```

Your POIPOI stablecoin is now ready for live gold prices! 🚀
