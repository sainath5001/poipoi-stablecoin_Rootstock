import { ethers } from 'ethers';
import POIPOI_ABI from '../abis/POIPOI.json';
import GoldPriceOracle_ABI from '../abis/GoldPriceOracle.json';
import POIPOIManager_ABI from '../abis/POIPOIManager.json';
import GoldReader_ABI from '../abis/GoldReader.json';

// Contract addresses from environment variables
export const CONTRACT_ADDRESSES = {
  POIPOI_TOKEN: import.meta.env.VITE_POIPOI_TOKEN_ADDRESS || '0x0000000000000000000000000000000000000000',
  GOLD_PRICE_ORACLE: import.meta.env.VITE_GOLD_PRICE_ORACLE_ADDRESS || '0x0000000000000000000000000000000000000000',
  POIPOI_MANAGER: import.meta.env.VITE_POIPOI_MANAGER_ADDRESS || '0x0000000000000000000000000000000000000000',
  GOLD_READER: import.meta.env.VITE_GOLD_READER_ADDRESS || '0x0000000000000000000000000000000000000000',
};

// RPC URLs
export const RPC_URLS = {
  ROOTSTOCK: import.meta.env.VITE_ROOTSTOCK_RPC_URL || 'https://public-node.rsk.co',
  ROOTSTOCK_TESTNET: import.meta.env.VITE_ROOTSTOCK_TESTNET_RPC_URL || 'https://public-node.testnet.rsk.co',
};

// Chain IDs
export const CHAIN_IDS = {
  ROOTSTOCK: parseInt(import.meta.env.VITE_CHAIN_ID || '30'),
  ROOTSTOCK_TESTNET: parseInt(import.meta.env.VITE_TESTNET_CHAIN_ID || '31'),
};

// Contract ABIs
export const CONTRACT_ABIS = {
  POIPOI: POIPOI_ABI,
  GOLD_PRICE_ORACLE: GoldPriceOracle_ABI,
  POIPOI_MANAGER: POIPOIManager_ABI,
  GOLD_READER: GoldReader_ABI,
};

// Helper function to get provider
export const getProvider = (chainId = CHAIN_IDS.ROOTSTOCK) => {
  const rpcUrl = chainId === CHAIN_IDS.ROOTSTOCK ? RPC_URLS.ROOTSTOCK : RPC_URLS.ROOTSTOCK_TESTNET;
  return new ethers.JsonRpcProvider(rpcUrl);
};

// Helper function to get contract instance
export const getContract = (contractName, provider, address = null) => {
  const abi = CONTRACT_ABIS[contractName];
  const contractAddress = address || CONTRACT_ADDRESSES[contractName];

  if (!abi || !contractAddress) {
    throw new Error(`Contract configuration not found for ${contractName}`);
  }

  return new ethers.Contract(contractAddress, abi, provider);
};

// Helper function to format token amounts
export const formatTokenAmount = (amount, decimals = 18) => {
  return ethers.formatUnits(amount, decimals);
};

// Helper function to parse token amounts
export const parseTokenAmount = (amount, decimals = 18) => {
  return ethers.parseUnits(amount, decimals);
};

// Helper function to format USD amounts
export const formatUSD = (amount) => {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  }).format(amount);
};

// Helper function to format POI amounts
export const formatPOI = (amount) => {
  return `${parseFloat(amount).toFixed(4)} POI`;
};



