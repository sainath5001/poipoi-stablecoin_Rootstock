import React, { useState, useEffect } from 'react';
import { useWallet } from '../context/WalletContext';
import { getContract, formatTokenAmount, formatUSD, parseTokenAmount } from '../utils/contractConfig';
import { Coins, DollarSign, ArrowLeft, Loader2 } from 'lucide-react';
import toast from 'react-hot-toast';

const Redeem = () => {
  const { account, signer, isConnected } = useWallet();
  const [poiAmount, setPoiAmount] = useState('');
  const [usdAmount, setUsdAmount] = useState('0');
  const [goldPrice, setGoldPrice] = useState('0');
  const [poiBalance, setPoiBalance] = useState('0');
  const [loading, setLoading] = useState(false);
  const [calculating, setCalculating] = useState(false);
  const [txHash, setTxHash] = useState('');

  useEffect(() => {
    if (isConnected && signer) {
      fetchData();
    }
  }, [isConnected, signer]);

  const fetchData = async () => {
    try {
      const managerContract = getContract('POIPOI_MANAGER', signer);
      const poiTokenContract = getContract('POIPOI', signer);
      
      const [price, balance] = await Promise.all([
        managerContract.getGoldPrice(),
        poiTokenContract.balanceOf(account),
      ]);
      
      setGoldPrice(formatTokenAmount(price, 8));
      setPoiBalance(formatTokenAmount(balance));
    } catch (error) {
      console.error('Error fetching data:', error);
      toast.error('Failed to fetch data');
    }
  };

  const calculateUsdAmount = async (poiValue) => {
    if (!poiValue || !signer) return;
    
    setCalculating(true);
    try {
      const managerContract = getContract('POIPOI_MANAGER', signer);
      const poiAmountWei = parseTokenAmount(poiValue);
      const usdAmountWei = await managerContract.calculateCollateralAmount(poiAmountWei);
      setUsdAmount(formatUSD(formatTokenAmount(usdAmountWei, 18)));
    } catch (error) {
      console.error('Error calculating USD amount:', error);
      toast.error('Failed to calculate USD amount');
    } finally {
      setCalculating(false);
    }
  };

  const handlePoiAmountChange = (e) => {
    const value = e.target.value;
    setPoiAmount(value);
    
    if (value) {
      calculateUsdAmount(value);
    } else {
      setUsdAmount('0');
    }
  };

  const handleMaxAmount = () => {
    setPoiAmount(poiBalance);
    calculateUsdAmount(poiBalance);
  };

  const handleRedeem = async () => {
    if (!poiAmount || !signer) {
      toast.error('Please enter a valid amount and connect your wallet');
      return;
    }

    if (parseFloat(poiAmount) > parseFloat(poiBalance)) {
      toast.error('Insufficient POI balance');
      return;
    }

    setLoading(true);
    setTxHash('');

    try {
      const managerContract = getContract('POIPOI_MANAGER', signer);
      const poiAmountWei = parseTokenAmount(poiAmount);
      
      // Estimate gas
      const gasEstimate = await managerContract.redeem.estimateGas(poiAmountWei);
      
      // Execute redeem transaction
      const tx = await managerContract.redeem(poiAmountWei, {
        gasLimit: gasEstimate * 120n / 100n, // Add 20% buffer
      });

      setTxHash(tx.hash);
      toast.success('Transaction submitted! Waiting for confirmation...');

      // Wait for transaction confirmation
      const receipt = await tx.wait();
      
      if (receipt.status === 1) {
        toast.success('POI tokens redeemed successfully!');
        setPoiAmount('');
        setUsdAmount('0');
        setTxHash('');
        // Refresh balance
        fetchData();
      } else {
        throw new Error('Transaction failed');
      }
    } catch (error) {
      console.error('Error redeeming POI tokens:', error);
      toast.error(`Failed to redeem POI tokens: ${error.message}`);
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
              Connect your wallet to redeem POI tokens.
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
            Redeem POI Tokens
          </h1>
          <p className="text-gray-400">
            Convert POI tokens back to USD based on current gold price
          </p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          {/* Redeem Form */}
          <div className="card">
            <h2 className="text-xl font-semibold text-rootstock-text mb-6">
              Redeem Tokens
            </h2>
            
            <div className="space-y-6">
              <div>
                <label className="block text-sm font-medium text-gray-300 mb-2">
                  POI Amount
                </label>
                <div className="relative">
                  <Coins className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
                  <input
                    type="number"
                    value={poiAmount}
                    onChange={handlePoiAmountChange}
                    placeholder="Enter POI amount"
                    className="input-field pl-10 pr-20"
                    step="0.0001"
                    min="0"
                    max={poiBalance}
                  />
                  <button
                    onClick={handleMaxAmount}
                    className="absolute right-2 top-1/2 transform -translate-y-1/2 text-xs bg-rootstock-primary/20 text-rootstock-primary px-2 py-1 rounded hover:bg-rootstock-primary/30 transition-colors"
                  >
                    MAX
                  </button>
                </div>
                <p className="text-xs text-gray-400 mt-1">
                  Balance: {poiBalance} POI
                </p>
              </div>

              <div className="flex items-center justify-center">
                <ArrowLeft className="h-6 w-6 text-rootstock-primary" />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-300 mb-2">
                  USD Amount to Receive
                </label>
                <div className="relative">
                  <DollarSign className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
                  <input
                    type="text"
                    value={calculating ? 'Calculating...' : usdAmount}
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
                onClick={handleRedeem}
                disabled={loading || !poiAmount || calculating || parseFloat(poiAmount) > parseFloat(poiBalance)}
                className="w-full btn-primary disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center space-x-2"
              >
                {loading ? (
                  <>
                    <Loader2 className="h-4 w-4 animate-spin" />
                    <span>Redeeming...</span>
                  </>
                ) : (
                  <span>Redeem POI Tokens</span>
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
                Your POI Balance
              </h3>
              <div className="text-2xl font-bold text-rootstock-primary mb-2">
                {poiBalance} POI
              </div>
              <p className="text-sm text-gray-400">
                Available for redemption
              </p>
            </div>

            <div className="card">
              <h3 className="text-lg font-semibold text-rootstock-text mb-4">
                How Redemption Works
              </h3>
              <div className="space-y-3 text-sm text-gray-400">
                <div className="flex items-start space-x-3">
                  <div className="w-6 h-6 bg-rootstock-primary/20 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5">
                    <span className="text-xs font-bold text-rootstock-primary">1</span>
                  </div>
                  <p>Enter the amount of POI tokens you want to redeem</p>
                </div>
                <div className="flex items-start space-x-3">
                  <div className="w-6 h-6 bg-rootstock-primary/20 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5">
                    <span className="text-xs font-bold text-rootstock-primary">2</span>
                  </div>
                  <p>The system calculates equivalent USD based on current gold price</p>
                </div>
                <div className="flex items-start space-x-3">
                  <div className="w-6 h-6 bg-rootstock-primary/20 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5">
                    <span className="text-xs font-bold text-rootstock-primary">3</span>
                  </div>
                  <p>Confirm the transaction to receive USD in your wallet</p>
                </div>
              </div>
            </div>

            <div className="card">
              <h3 className="text-lg font-semibold text-rootstock-text mb-4">
                Important Notes
              </h3>
              <ul className="space-y-2 text-sm text-gray-400">
                <li>• Minimum redeem amount: 0.0001 POI</li>
                <li>• Redemption is based on current gold price</li>
                <li>• Transaction fees apply</li>
                <li>• USD is sent directly to your wallet</li>
                <li>• Redemption is processed immediately</li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Redeem;
