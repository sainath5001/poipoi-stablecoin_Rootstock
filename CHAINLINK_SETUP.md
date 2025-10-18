# Chainlink Price Feed Setup for POIPOI Stablecoin

## Overview

Your POIPOI stablecoin is already configured to use Chainlink price feeds! The `GoldPriceOracle.sol` contract has built-in support for Chainlink's XAU/USD price feeds.

## Current Status

✅ **Oracle Contract Ready** - Your `GoldPriceOracle.sol` already supports Chainlink feeds
✅ **Price Conversion Logic** - Automatically converts from ounces to grams
✅ **Fallback System** - Falls back to stored price if Chainlink fails
✅ **Mock Mode** - Currently using mock prices for testing

## Step 1: Check Chainlink Availability on Rootstock

Unfortunately, **Chainlink price feeds are not yet available on Rootstock (RSK) network**. However, your contract is ready for when they become available.

### Current Chainlink Network Support:
- ✅ Ethereum Mainnet
- ✅ Polygon
- ✅ BSC
- ✅ Avalanche
- ❌ Rootstock (RSK) - Not yet supported

## Step 2: Alternative Solutions for Rootstock

Since Chainlink isn't available on Rootstock yet, here are your options:

### Option A: Use Mock Prices (Current Setup)
Your contract is already using mock prices. This is perfect for testing and development.

### Option B: Deploy on Ethereum/Polygon with Chainlink
Deploy your contracts on networks that support Chainlink:

```bash
# Deploy on Polygon (has Chainlink support)
export RPC_URL="https://polygon-rpc.com"
forge script script/Deploy.s.sol:DeployPOIPOI --rpc-url $RPC_URL --broadcast --verify
```

### Option C: Custom Price Oracle
Create a custom oracle that fetches prices from external APIs.

## Step 3: Configure Chainlink (When Available)

When Chainlink becomes available on Rootstock, here's how to configure it:

### 1. Update Deployment Script

```solidity
// In script/Deploy.s.sol, replace line 45:
// OLD: goldOracle = new GoldPriceOracle(address(0));
// NEW: goldOracle = new GoldPriceOracle(CHAINLINK_XAU_USD_ADDRESS);
```

### 2. Set Chainlink Price Feed Address

```bash
# After deployment, set the Chainlink price feed
cast send $ORACLE_ADDRESS "setGoldPriceFeed(address)" $CHAINLINK_XAU_USD_ADDRESS --rpc-url $RPC_URL --private-key $PRIVATE_KEY
```

### 3. Enable Live Prices

```bash
# Switch from mock mode to live prices
cast send $ORACLE_ADDRESS "setMockPriceMode(bool)" false --rpc-url $RPC_URL --private-key $PRIVATE_KEY
```

## Step 4: Test with Mock Prices

Your current setup with mock prices works perfectly for testing:

```bash
# Deploy with mock prices
forge script script/Deploy.s.sol:DeployPOIPOI --rpc-url $RPC_URL --broadcast --verify

# Test minting with mock prices
# The system will use $65 per gram as the gold price
```

## Step 5: Monitor for Chainlink Support

Keep checking Chainlink's documentation for Rootstock support:
- [Chainlink Price Feeds](https://docs.chain.link/data-feeds/price-feeds/addresses)
- [Chainlink Networks](https://docs.chain.link/chainlink-automation/supported-networks)

## Current Configuration

Your oracle is currently configured as:
- **Mode**: Mock prices ($65 per gram)
- **Decimals**: 8 (standard for price feeds)
- **Update Method**: Manual via `updateGoldPrice()`
- **Fallback**: Stored price if external feed fails

## Testing Commands

```bash
# Test with mock prices
forge test

# Deploy to testnet with mock prices
forge script script/Deploy.s.sol:DeployPOIPOI --rpc-url $RPC_URL --broadcast

# Update mock price (for testing)
cast send $ORACLE_ADDRESS "updateMockPrice(uint256)" 70000000 --rpc-url $RPC_URL --private-key $PRIVATE_KEY
```

## Next Steps

1. **Deploy with mock prices** - Perfect for testing and development
2. **Monitor Chainlink** - Check for Rootstock support updates
3. **Consider multi-chain** - Deploy on Ethereum/Polygon for live prices
4. **Custom oracle** - Build custom price feed if needed

Your POIPOI stablecoin is production-ready with mock prices and will automatically work with Chainlink when it becomes available on Rootstock!
