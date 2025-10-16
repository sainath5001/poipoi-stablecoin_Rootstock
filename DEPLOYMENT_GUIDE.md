# POIPOI Stablecoin Deployment Guide

## Quick Start

### 1. Prerequisites
- Foundry installed
- Private key for deployment
- Rootstock testnet/mainnet RPC access

### 2. Environment Setup
```bash
export PRIVATE_KEY="your-private-key-here"
export RPC_URL="https://public-node.testnet.rsk.co"  # For testnet
# or
export RPC_URL="https://public-node.rsk.co"  # For mainnet
```

### 3. Deploy to Rootstock Testnet
```bash
forge script script/Deploy.s.sol:DeployPOIPOI --rpc-url $RPC_URL --broadcast --verify
```

### 4. Deploy to Rootstock Mainnet
```bash
forge script script/Deploy.s.sol:DeployPOIPOI --rpc-url $RPC_URL --broadcast --verify
```

## Contract Addresses

After deployment, you'll get:
- **MockCollateralToken**: `0x...`
- **GoldPriceOracle**: `0x...`
- **POIPOI Token**: `0x...`
- **POIPOIManager**: `0x...`

## Usage Examples

### Minting POI Tokens
```solidity
// 1. Approve manager to spend collateral
collateralToken.approve(managerAddress, amount);

// 2. Mint POI tokens
uint256 poiAmount = manager.mintPoi(collateralAmount);
```

### Redeeming POI Tokens
```solidity
// Redeem POI tokens for collateral
uint256 collateralAmount = manager.redeemPoi(poiAmount);
```

### Checking Gold Price
```solidity
uint256 goldPrice = oracle.getGoldPricePerGram();
```

## Testing Commands

```bash
# Run all tests
forge test

# Run specific test
forge test --match-test testMintPoi

# Run with verbose output
forge test -vvv

# Test deployment locally
forge script script/Deploy.s.sol:DeployPOIPOI --sig "testDeployment()" -vvv
```

## Network Configuration

### Rootstock Testnet
- Chain ID: 31
- RPC: https://public-node.testnet.rsk.co
- Explorer: https://explorer.testnet.rsk.co

### Rootstock Mainnet
- Chain ID: 30
- RPC: https://public-node.rsk.co
- Explorer: https://explorer.rsk.co

## Security Notes

- Always test on testnet first
- Verify contract addresses after deployment
- Keep private keys secure
- Monitor contract interactions
- Set up proper access controls

## Troubleshooting

### Common Issues
1. **Stack too deep**: Already fixed with `via_ir = true`
2. **Import errors**: Make sure OpenZeppelin is installed
3. **Gas issues**: Adjust gas limits in foundry.toml
4. **Network issues**: Check RPC URL and network connectivity

### Getting Help
- Check the README.md for detailed documentation
- Review test files for usage examples
- Check contract events for debugging
- Use Foundry's built-in debugging tools
