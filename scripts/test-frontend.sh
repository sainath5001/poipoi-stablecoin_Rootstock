#!/bin/bash

# Quick Frontend Test Script
# This script deploys contracts locally and tests the frontend

echo "🧪 Testing Frontend Gold Price Fetching"
echo "====================================="

# Set up environment for local testing
export PRIVATE_KEY="0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80" # Hardhat test key
export RPC_URL="http://localhost:8545"

echo "📋 Testing Steps:"
echo "1. Deploy contracts locally"
echo "2. Update frontend .env with contract addresses"
echo "3. Test frontend gold price fetching"
echo ""

# Step 1: Deploy contracts locally
echo "🔨 Step 1: Deploying contracts locally..."
forge script script/Deploy.s.sol:DeployPOIPOI --sig "testDeployment()" -vvv

if [ $? -eq 0 ]; then
    echo "✅ Contracts deployed successfully!"
    echo ""
    echo "📝 Next Steps:"
    echo "1. Copy the contract addresses from the deployment output"
    echo "2. Update frontend/.env with the addresses:"
    echo "   VITE_POIPOI_TOKEN_ADDRESS=0x..."
    echo "   VITE_GOLD_PRICE_ORACLE_ADDRESS=0x..."
    echo "   VITE_POIPOI_MANAGER_ADDRESS=0x..."
    echo ""
    echo "3. Start the frontend:"
    echo "   cd frontend && npm run dev"
    echo ""
    echo "4. Test the gold price display on the dashboard"
else
    echo "❌ Contract deployment failed!"
    exit 1
fi
