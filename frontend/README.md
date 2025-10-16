# POIPOI Stablecoin Frontend

A complete React + Vite + TailwindCSS frontend for the POIPOI decentralized, commodity-backed stablecoin dApp built on Rootstock.

## Features

- 🏦 **Wallet Integration**: Connect with MetaMask on Rootstock network
- 💰 **Mint Tokens**: Convert USD to POI tokens backed by gold
- 🔄 **Redeem Tokens**: Convert POI tokens back to USD
- 📊 **Live Dashboard**: Real-time gold price and balance tracking
- 🎨 **Rootstock Theme**: Dark background with orange highlights
- 📱 **Responsive Design**: Works on desktop and mobile devices

## Tech Stack

- **React 18** - UI framework
- **Vite** - Build tool and dev server
- **TailwindCSS** - Styling framework
- **Ethers.js** - Ethereum/Rootstock interaction
- **React Router** - Client-side routing
- **React Hot Toast** - Notifications
- **Lucide React** - Icons

## Prerequisites

- Node.js 16+ 
- npm or yarn
- MetaMask wallet
- Rootstock network access

## Installation

1. Clone the repository and navigate to the frontend directory:
```bash
cd frontend
```

2. Install dependencies:
```bash
npm install
```

3. Create environment file:
```bash
cp env.example .env
```

4. Update the `.env` file with your contract addresses and RPC URLs:
```env
# Rootstock Network Configuration
VITE_ROOTSTOCK_RPC_URL=https://public-node.rsk.co
VITE_ROOTSTOCK_TESTNET_RPC_URL=https://public-node.testnet.rsk.co

# Contract Addresses (Replace with actual deployed addresses)
VITE_POIPOI_TOKEN_ADDRESS=0xYourPOITokenAddress
VITE_GOLD_PRICE_ORACLE_ADDRESS=0xYourOracleAddress
VITE_POIPOI_MANAGER_ADDRESS=0xYourManagerAddress

# Chain ID
VITE_CHAIN_ID=30
VITE_TESTNET_CHAIN_ID=31

# App Configuration
VITE_APP_NAME=POIPOI Stablecoin
VITE_APP_DESCRIPTION=Decentralized Gold-Backed Stablecoin on Rootstock
```

5. Start the development server:
```bash
npm run dev
```

6. Open your browser and navigate to `http://localhost:5173`

## Project Structure

```
src/
├── components/
│   ├── Navbar.jsx          # Navigation component
│   └── DashboardCard.jsx   # Reusable dashboard card
├── pages/
│   ├── Home.jsx           # Landing page
│   ├── Dashboard.jsx      # User dashboard
│   ├── Mint.jsx          # Mint POI tokens
│   └── Redeem.jsx        # Redeem POI tokens
├── context/
│   └── WalletContext.jsx  # Wallet connection context
├── utils/
│   └── contractConfig.js  # Contract configuration
├── abis/
│   ├── POIPOI.json       # POI token ABI
│   ├── GoldPriceOracle.json # Oracle ABI
│   └── POIPOIManager.json   # Manager contract ABI
├── App.jsx               # Main app component
├── main.jsx             # Entry point
└── index.css            # Global styles
```

## Smart Contract Integration

The frontend integrates with three main smart contracts:

### POIPOI Token Contract
- `balanceOf(address)` - Get user's POI balance
- `totalSupply()` - Get total POI supply
- `transfer(to, amount)` - Transfer POI tokens

### Gold Price Oracle Contract
- `getGoldPrice()` - Get current gold price per gram
- `getLatestPrice()` - Get latest price update

### POIPOI Manager Contract
- `mint(usdAmount)` - Mint POI tokens for USD
- `redeem(poiAmount)` - Redeem POI tokens for USD
- `calculatePOIAmount(usdAmount)` - Calculate POI amount for USD
- `calculateCollateralAmount(poiAmount)` - Calculate USD amount for POI

## Usage

### Connecting Wallet
1. Click "Connect Wallet" button
2. Select MetaMask when prompted
3. Approve the connection request
4. Ensure you're on Rootstock network

### Minting POI Tokens
1. Navigate to the Mint page
2. Enter USD amount you want to convert
3. Review the calculated POI amount
4. Click "Mint POI Tokens"
5. Confirm transaction in MetaMask

### Redeeming POI Tokens
1. Navigate to the Redeem page
2. Enter POI amount to redeem
3. Review the calculated USD amount
4. Click "Redeem POI Tokens"
5. Confirm transaction in MetaMask

### Dashboard
- View your POI balance
- Monitor current gold price
- Check total POI supply
- Quick access to mint/redeem functions

## Styling

The app uses a custom Rootstock-inspired theme:
- **Background**: `#0D0D0D` (Dark)
- **Primary**: `#F7931A` (Orange)
- **Text**: `#FFFFFF` (White)
- **Cards**: `#1A1A1A` (Dark Gray)
- **Borders**: `#333333` (Gray)

## Building for Production

```bash
npm run build
```

The built files will be in the `dist` directory.

## Deployment

The app can be deployed to any static hosting service:
- Vercel
- Netlify
- GitHub Pages
- AWS S3 + CloudFront

## Troubleshooting

### Common Issues

1. **Wallet not connecting**: Ensure MetaMask is installed and unlocked
2. **Wrong network**: Switch to Rootstock network in MetaMask
3. **Transaction fails**: Check gas fees and network congestion
4. **Contract errors**: Verify contract addresses in `.env` file

### Network Configuration

Add Rootstock network to MetaMask:
- **Network Name**: Rootstock
- **RPC URL**: https://public-node.rsk.co
- **Chain ID**: 30
- **Currency Symbol**: RBTC
- **Block Explorer**: https://explorer.rsk.co

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

For support and questions:
- Create an issue on GitHub
- Join our community Discord
- Check the documentation

---

Built with ❤️ for the Rootstock ecosystem