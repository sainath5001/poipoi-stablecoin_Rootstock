import React, { useState, useEffect } from 'react';
import { useWallet } from '../context/WalletContext';
import { getContract, formatTokenAmount, formatUSD, formatPOI } from '../utils/contractConfig';
import { fetchGoldPrice } from '../utils/goldPriceUtils';
import DashboardCard from '../components/DashboardCard';
import { TrendingUp, Coins, DollarSign, Activity, RefreshCw, Wifi, WifiOff } from 'lucide-react';
import toast from 'react-hot-toast';

const Dashboard = () => {
  const { account, provider, isConnected } = useWallet();
  const [data, setData] = useState({
    poiBalance: '0',
    goldPrice: '0',
    goldPriceSource: 'GoldPriceOracle',
    totalSupply: '0',
    networkStatus: 'Connected',
    isPriceLive: false,
  });
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);

  const fetchData = async () => {
    if (!provider || !isConnected) {
      setLoading(false);
      return;
    }

    try {
      setRefreshing(true);

      // Get contract instances
      const poiTokenContract = getContract('POIPOI', provider);
      const goldOracleContract = getContract('GOLD_PRICE_ORACLE', provider);
      const managerContract = getContract('POIPOI_MANAGER', provider);

      // Fetch data in parallel - use new fetchGoldPrice utility with fallback
      const [balance, goldPriceData, totalSupply] = await Promise.all([
        poiTokenContract.balanceOf(account).catch(() => 0n), // Return 0 if fails
        fetchGoldPrice(provider, account).catch(() => ({ price: '0', source: 'Error', isStale: false })), // Return default if fails
        poiTokenContract.totalSupply().catch(() => 0n), // Return 0 if fails
      ]);

      setData({
        poiBalance: formatTokenAmount(balance || 0n),
        goldPrice: formatUSD(goldPriceData.price || '0'),
        goldPriceSource: goldPriceData.source || 'Error',
        totalSupply: formatPOI(formatTokenAmount(totalSupply || 0n)),
        networkStatus: 'Connected',
        isPriceLive: !goldPriceData.isStale && goldPriceData.source && goldPriceData.source.includes('Live'),
      });
    } catch (error) {
      console.error('Error fetching dashboard data:', error);
      toast.error('Failed to fetch data');
      setData(prev => ({
        ...prev,
        networkStatus: 'Error',
      }));
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  useEffect(() => {
    fetchData();

    // Set up polling for live updates
    const interval = setInterval(fetchData, 30000); // Update every 30 seconds

    return () => clearInterval(interval);
  }, [account, provider, isConnected]);

  const handleRefresh = () => {
    fetchData();
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
              Connect your wallet to view your POI balance and interact with the POIPOI stablecoin.
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
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Header */}
        <div className="flex justify-between items-center mb-8">
          <div>
            <h1 className="text-3xl font-bold text-rootstock-text mb-2">
              Dashboard
            </h1>
            <p className="text-gray-400">
              Monitor your POI tokens and gold price in real-time
            </p>
          </div>
          <button
            onClick={handleRefresh}
            disabled={refreshing}
            className="btn-secondary flex items-center space-x-2 disabled:opacity-50"
          >
            <RefreshCw className={`h-4 w-4 ${refreshing ? 'animate-spin' : ''}`} />
            <span>Refresh</span>
          </button>
        </div>

        {/* Stats Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <DashboardCard
            title="POI Balance"
            value={data.poiBalance}
            subtitle="Your current balance"
            icon={Coins}
            loading={loading}
          />
          <DashboardCard
            title="Gold Price"
            value={data.goldPrice}
            subtitle={
              <div className="flex items-center gap-2">
                <span>Per gram (USD)</span>
                {data.isPriceLive ? (
                  <Wifi className="h-3 w-3 text-green-400" title="Live via LayerZero" />
                ) : (
                  <WifiOff className="h-3 w-3 text-gray-500" title={data.goldPriceSource} />
                )}
              </div>
            }
            icon={DollarSign}
            loading={loading}
          />
          <DashboardCard
            title="Total Supply"
            value={data.totalSupply}
            subtitle="POI tokens in circulation"
            icon={TrendingUp}
            loading={loading}
          />
          <DashboardCard
            title="Network Status"
            value={data.networkStatus}
            subtitle="Rootstock Network"
            icon={Activity}
            loading={loading}
          />
        </div>

        {/* Quick Actions */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div className="card">
            <h3 className="text-lg font-semibold text-rootstock-text mb-4">
              Quick Actions
            </h3>
            <div className="space-y-3">
              <a
                href="/mint"
                className="block w-full btn-primary text-center"
              >
                Mint POI Tokens
              </a>
              <a
                href="/redeem"
                className="block w-full btn-secondary text-center"
              >
                Redeem POI Tokens
              </a>
            </div>
          </div>

          <div className="card">
            <h3 className="text-lg font-semibold text-rootstock-text mb-4">
              About POIPOI
            </h3>
            <div className="space-y-3 text-sm text-gray-400">
              <p>
                POIPOI is a decentralized, commodity-backed stablecoin pegged to gold.
                Each POI token represents 1 gram of gold, providing stability and value preservation.
              </p>
              <p>
                Built on Rootstock, POIPOI leverages the security of Bitcoin while enabling
                smart contract functionality for decentralized finance applications.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;

