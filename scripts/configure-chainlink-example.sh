#!/bin/bash

# Example: How to Configure Chainlink Price Feeds for POIPOI
# This script shows the exact commands to use when Chainlink becomes available on Rootstock

echo "🔗 POIPOI Chainlink Configuration Example"
echo "========================================"

# Example contract addresses (replace with your actual deployed addresses)
ORACLE_ADDRESS="0x1234567890123456789012345678901234567890"
CHAINLINK_XAU_USD_ADDRESS="0x214eD9Da11D2fbe465a6fc601a91E62EbD1A1C4"  # Example address

echo "📋 Step-by-Step Chainlink Configuration:"
echo ""

echo "1️⃣ Deploy POIPOI contracts with mock prices:"
echo "   forge script script/Deploy.s.sol:DeployPOIPOI --rpc-url \$RPC_URL --broadcast --verify"
echo ""

echo "2️⃣ Set Chainlink price feed address:"
echo "   cast send $ORACLE_ADDRESS \"setGoldPriceFeed(address)\" $CHAINLINK_XAU_USD_ADDRESS --rpc-url \$RPC_URL --private-key \$PRIVATE_KEY"
echo ""

echo "3️⃣ Switch from mock mode to live Chainlink prices:"
echo "   cast send $ORACLE_ADDRESS \"setMockPriceMode(bool)\" false --rpc-url \$RPC_URL --private-key \$PRIVATE_KEY"
echo ""

echo "4️⃣ Update price from Chainlink:"
echo "   cast send $ORACLE_ADDRESS \"updatePriceFromChainlink()\" --rpc-url \$RPC_URL --private-key \$PRIVATE_KEY"
echo ""

echo "5️⃣ Verify the configuration:"
echo "   cast call $ORACLE_ADDRESS \"getGoldPricePerGram()\" --rpc-url \$RPC_URL"
echo "   cast call $ORACLE_ADDRESS \"getGoldPriceWithTimestamp()\" --rpc-url \$RPC_URL"
echo ""

echo "🔍 Check if price is from Chainlink:"
echo "   cast call $ORACLE_ADDRESS \"useMockPrice()\" --rpc-url \$RPC_URL"
echo "   # Should return 'false' when using Chainlink"
echo ""

echo "📊 Monitor price updates:"
echo "   # Watch for PriceUpdated events"
echo "   cast logs --from-block latest --address $ORACLE_ADDRESS --topic 0x..."
echo ""

echo "⚠️  Important Notes:"
echo "   - Chainlink is not yet available on Rootstock"
echo "   - Your contracts are already configured for Chainlink"
echo "   - Mock prices work perfectly for testing and development"
echo "   - When Chainlink becomes available, just run the commands above"
echo ""

echo "✅ Your POIPOI system is Chainlink-ready!"
