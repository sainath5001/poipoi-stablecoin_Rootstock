# POIPOI Gold-Backed Stablecoin

A decentralized, commodity-backed stablecoin pegged to the real-time price of gold. 1 POI = 1 gram of gold.

## Overview

POIPOI is a gold-backed stablecoin system built on Rootstock (RSK) that automatically adjusts based on the latest gold price using Chainlink oracles. The system allows users to mint POI tokens by depositing collateral and redeem POI tokens for equivalent collateral value.

## Features

- **Gold-Backed**: Each POI token represents 1 gram of gold
- **Real-Time Pricing**: Uses Chainlink oracle for live gold price feeds
- **Decentralized**: Built on Rootstock blockchain
- **Secure**: Uses OpenZeppelin contracts with comprehensive security features
- **Transparent**: All operations are recorded on-chain with events

## Architecture

### Smart Contracts

1. **POIPOI.sol**: ERC20 token contract with minting/burning capabilities
2. **GoldPriceOracle.sol**: Oracle contract for fetching gold price data
3. **POIPOIManager.sol**: Main contract handling minting and redemption logic
4. **MockCollateralToken.sol**: Mock ERC20 token for testing purposes

### Key Components

- **Minting**: Users deposit collateral tokens to mint POI tokens
- **Redemption**: Users burn POI tokens to receive equivalent collateral
- **Price Oracle**: Provides real-time gold price in USD per gram
- **Access Control**: Owner and manager-based permissions
- **Emergency Controls**: Pause/unpause and emergency stop functionality

## Installation

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- Git
- Node.js (for frontend integration)

### Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd poipoi-stablecoin
```

2. Install dependencies:
```bash
forge install OpenZeppelin/openzeppelin-contracts
```

3. Build the project:
```bash
forge build
```

## Testing

Run the comprehensive test suite:

```bash
forge test
```

Run tests with verbose output:

```bash
forge test -vvv
```

Run specific test:

```bash
forge test --match-test testMintPoi
```

## Deployment

### Local Testing

Test deployment locally:

```bash
forge script script/Deploy.s.sol:DeployPOIPOI --sig "testDeployment()" -vvv
```

### Rootstock Testnet

1. Set up your environment variables:
```bash
export PRIVATE_KEY="your-private-key"
export RPC_URL="https://public-node.testnet.rsk.co"
```

2. Deploy to Rootstock testnet:
```bash
forge script script/Deploy.s.sol:DeployPOIPOI --rpc-url $RPC_URL --broadcast --verify
```

### Rootstock Mainnet

1. Set up your environment variables:
```bash
export PRIVATE_KEY="your-private-key"
export RPC_URL="https://public-node.rsk.co"
```

2. Deploy to Rootstock mainnet:
```bash
forge script script/Deploy.s.sol:DeployPOIPOI --rpc-url $RPC_URL --broadcast --verify
```

## Usage

### Minting POI Tokens

1. Approve the manager contract to spend your collateral tokens
2. Call `mintPoi(collateralAmount)` on the POIPOIManager contract
3. Receive POI tokens based on current gold price

### Redeeming POI Tokens

1. Call `redeemPoi(poiAmount)` on the POIPOIManager contract
2. POI tokens are burned and equivalent collateral is returned

### Price Calculations

- Gold price is fetched from Chainlink oracle (8 decimals)
- POI tokens use 18 decimals (standard ERC20)
- Conversion: `POI Amount = USD Amount / Gold Price per Gram`

## Configuration

### Gold Price Oracle

The oracle can be configured to use:
- Real Chainlink price feeds (when available on Rootstock)
- Mock price feeds (for testing)
- Manual price updates (emergency fallback)

### Collateral Tokens

Currently supports:
- Mock Collateral Token (for testing)
- Can be updated to use real tokens like rBTC, USDC, etc.

## Security Features

- **Access Control**: Owner and manager-based permissions
- **Reentrancy Protection**: Uses OpenZeppelin's ReentrancyGuard
- **Pausable**: Contracts can be paused in emergencies
- **Emergency Stop**: Additional emergency stop functionality
- **Input Validation**: Comprehensive input validation
- **Price Limits**: Maximum price change limits to prevent manipulation

## Events

The system emits the following events:

- `TokensMinted`: When POI tokens are minted
- `TokensBurned`: When POI tokens are burned
- `PriceUpdated`: When gold price is updated
- `EmergencyStop`: When emergency stop is triggered

## Gas Optimization

- Uses Solidity 0.8.20 with optimizer enabled
- Optimized for 200 runs
- Efficient storage patterns
- Minimal external calls

## Network Configuration

### Rootstock Testnet
- Chain ID: 31
- RPC URL: https://public-node.testnet.rsk.co
- Block Explorer: https://explorer.testnet.rsk.co

### Rootstock Mainnet
- Chain ID: 30
- RPC URL: https://public-node.rsk.co
- Block Explorer: https://explorer.rsk.co

## Development

### Adding New Features

1. Create feature branch
2. Implement changes
3. Add comprehensive tests
4. Update documentation
5. Submit pull request

### Code Style

- Follow Solidity style guide
- Use NatSpec documentation
- Include comprehensive comments
- Write descriptive variable names

## License

MIT License - see LICENSE file for details

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## Support

For questions and support:
- Create an issue on GitHub
- Join our community Discord
- Check the documentation

## Roadmap

- [ ] Real Chainlink oracle integration
- [ ] Multiple collateral token support
- [ ] Governance token
- [ ] Frontend interface
- [ ] Mobile app
- [ ] Cross-chain bridge
- [ ] Insurance fund
- [ ] Liquidity mining

## Disclaimer

This is experimental software. Use at your own risk. Always conduct thorough testing before using in production.