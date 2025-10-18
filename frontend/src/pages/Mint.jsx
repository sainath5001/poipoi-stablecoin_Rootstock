import React, { useState, useEffect } from 'react';
import { useWallet } from '../context/WalletContext';
import { getContract, formatTokenAmount, formatUSD, parseTokenAmount } from '../utils/contractConfig';
import { Coins, DollarSign, ArrowRight, Loader2 } from 'lucide-react';
import toast from 'react-hot-toast';

const Mint = () => {
  const { account, signer, isConnected } = useWallet();
  const [usdAmount, setUsdAmount] = useState('');
  const [poiAmount, setPoiAmount] = useState('0');
  const [goldPrice, setGoldPrice] = useState('0');
  const [loading, setLoading] = useState(false);
  const [calculating, setCalculating] = useState(false);
  const [txHash, setTxHash] = useState('');

  useEffect(() => {
    if (isConnected && signer) {
      fetchGoldPrice();
    }
  }, [isConnected, signer]);

  const fetchGoldPrice = async () => {
    try {
      const managerContract = getContract('POIPOI_MANAGER', signer);
      const price = await managerContract.getGoldPrice();
      setGoldPrice(formatTokenAmount(price, 8));
    } catch (error) {
      console.error('Error fetching gold price:', error);
      toast.error('Failed to fetch gold price');
    }
  };

  const calculatePOIAmount = async (usdValue) => {
    if (!usdValue || !signer) return;
    
    setCalculating(true);
    try {
      const managerContract = getContract('POIPOI_MANAGER', signer);
      const usdAmountWei = parseTokenAmount(usdValue, 18);
      const poiAmountWei = await managerContract.calculatePOIAmount(usdAmountWei);
      setPoiAmount(formatTokenAmount(poiAmountWei));
    } catch (error) {
      console.error('Error calculating POI amount:', error);
      toast.error('Failed to calculate POI amount');
    } finally {
      setCalculating(false);
    }
  };

  const handleUsdAmountChange = (e) => {
    const value = e.target.value;
    setUsdAmount(value);
    
    if (value) {
      calculatePOIAmount(value);
    } else {
      setPoiAmount('0');
    }
  };

  const handleMint = async () => {
    if (!usdAmount || !signer) {
      toast.error('Please enter a valid amount and connect your wallet');
      return;
    }

    setLoading(true);
    setTxHash('');

    try {
      const managerContract = getContract('POIPOI_MANAGER', signer);
      const usdAmountWei = parseTokenAmount(usdAmount, 18);
      
      // Estimate gas
      const gasEstimate = await managerContract.mint.estimateGas(usdAmountWei);
      
      // Execute mint transaction
      const tx = await managerContract.mint(usdAmountWei, {
        gasLimit: gasEstimate * 120n / 100n, // Add 20% buffer
      });

      setTxHash(tx.hash);
      toast.success('Transaction submitted! Waiting for confirmation...');

      // Wait for transaction confirmation
      const receipt = await tx.wait();
      
      if (receipt.status === 1) {
        toast.success('POI tokens minted successfully!');
        setUsdAmount('');
        setPoiAmount('0');
        setTxHash('');
      } else {
        throw new Error('Transaction failed');
      }
    } catch (error) {
      console.error('Error minting POI tokens:', error);
      toast.error(`Failed to mint POI tokens: ${error.message}`);
    } finally {
      setLoading(false);
    }
  };

  if (!isConnected) {
    return (
      <div className="min-h-screen bg-rootstock-bg flex items-center justify-center">
        <div className="text-center">
          <div className="bg-rootstock-card border border-rootstock-border rounded-xl p-8 max-w-md mx-auto">
            <Coins className="h-16 w-16 text-rootstock-primary mx-auto mb-4" />
            <h2 className="text-2xl font-bold text-rootstock-text mb-2">
              Connect Your Wallet
            </h2>
            <p className="text-gray-400 mb-6">
              Connect your wallet to mint POI tokens.
            </p>
            <button
              onClick={() => window.location.href = '/'}
              className="btn-primary"
            >
              Go to Home
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-rootstock-bg py-8">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Header */}
        <div className="text-center mb-8">
          <h1 className="text-3xl font-bold text-rootstock-text mb-2">
            Mint POI Tokens
          </h1>
          <p className="text-gray-400">
            Convert USD to POI tokens backed by gold
          </p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          {/* Mint Form */}
          <div className="card">
            <h2 className="text-xl font-semibold text-rootstock-text mb-6">
              Mint Tokens
            </h2>
            
            <div className="space-y-6">
              <div>
                <label className="block text-sm font-medium text-gray-300 mb-2">
                  USD Amount
                </label>
                <div className="relative">
                  <DollarSign className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
                  <input
                    type="number"
                    value={usdAmount}
                    onChange={handleUsdAmountChange}
                    placeholder="Enter USD amount"
                    className="input-field pl-10"
                    step="0.01"
                    min="0"
                  />
                </div>
              </div>

              <div className="flex items-center justify-center">
                <ArrowRight className="h-6 w-6 text-rootstock-primary" />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-300 mb-2">
                  POI Tokens to Receive
                </label>
                <div className="relative">
                  <Coins className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
                  <input
                    type="text"
                    value={calculating ? 'Calculating...' : poiAmount}
                    readOnly
                    className="input-field pl-10 bg-gray-800"
                  />
                </div>
                {calculating && (
                  <div className="flex items-center justify-center mt-2">
                    <Loader2 className="h-4 w-4 animate-spin text-rootstock-primary" />
                  </div>
                )}
              </div>

              <button
                onClick={handleMint}
                disabled={loading || !usdAmount || calculating}
                className="w-full btn-primary disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center space-x-2"
              >
                {loading ? (
                  <>
                    <Loader2 className="h-4 w-4 animate-spin" />
                    <span>Minting...</span>
                  </>
                ) : (
                  <span>Mint POI Tokens</span>
                )}
              </button>

              {txHash && (
                <div className="mt-4 p-4 bg-rootstock-primary/10 border border-rootstock-primary/20 rounded-lg">
                  <p className="text-sm text-rootstock-primary font-medium">
                    Transaction Hash:
                  </p>
                  <p className="text-xs text-gray-400 font-mono break-all">
                    {txHash}
                  </p>
                </div>
              )}
            </div>
          </div>

          {/* Information Panel */}
          <div className="space-y-6">
            <div className="card">
              <h3 className="text-lg font-semibold text-rootstock-text mb-4">
                Current Gold Price
              </h3>
              <div className="text-3xl font-bold text-yellow-400 mb-2">
                {formatUSD(goldPrice)}
              </div>
              <p className="text-sm text-gray-400">
                Per gram (USD)
              </p>
            </div>

            <div className="card">
              <h3 className="text-lg font-semibold text-rootstock-text mb-4">
                How Minting Works
              </h3>
              <div className="space-y-3 text-sm text-gray-400">
                <div className="flex items-start space-x-3">
                  <div className="w-6 h-6 bg-rootstock-primary/20 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5">
                    <span className="text-xs font-bold text-rootstock-primary">1</span>
                  </div>
                  <p>Enter the USD amount you want to convert to POI tokens</p>
                </div>
                <div className="flex items-start space-x-3">
                  <div className="w-6 h-6 bg-rootstock-primary/20 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5">
                    <span className="text-xs font-bold text-rootstock-primary">2</span>
                  </div>
                  <p>The system calculates equivalent POI tokens based on current gold price</p>
                </div>
                <div className="flex items-start space-x-3">
                  <div className="w-6 h-6 bg-rootstock-primary/20 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5">
                    <span className="text-xs font-bold text-rootstock-primary">3</span>
                  </div>
                  <p>Confirm the transaction in your wallet to mint the tokens</p>
                </div>
              </div>
            </div>

            <div className="card">
              <h3 className="text-lg font-semibold text-rootstock-text mb-4">
                Important Notes
              </h3>
              <ul className="space-y-2 text-sm text-gray-400">
                <li>• Each POI token represents 1 gram of gold</li>
                <li>• Minimum mint amount: $1 USD</li>
                <li>• Transaction fees apply</li>
                <li>• Gold price updates in real-time</li>
                <li>• Tokens are immediately available after confirmation</li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Mint;

