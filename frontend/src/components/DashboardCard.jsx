import React from 'react';
import { TrendingUp, Coins, DollarSign, Activity } from 'lucide-react';

const DashboardCard = ({ title, value, subtitle, icon: Icon, trend, loading = false }) => {
  const getIconColor = () => {
    switch (title) {
      case 'POI Balance':
        return 'text-rootstock-primary';
      case 'Gold Price':
        return 'text-yellow-400';
      case 'Total Supply':
        return 'text-blue-400';
      case 'Network Status':
        return 'text-green-400';
      default:
        return 'text-gray-400';
    }
  };

  const getTrendColor = () => {
    if (!trend) return '';
    return trend > 0 ? 'text-green-400' : trend < 0 ? 'text-red-400' : 'text-gray-400';
  };

  const getTrendIcon = () => {
    if (!trend) return null;
    return trend > 0 ? '↗' : trend < 0 ? '↘' : '→';
  };

  return (
    <div className="card hover:shadow-xl hover:shadow-rootstock-primary/10 transition-all duration-300 group">
      <div className="flex items-center justify-between mb-4">
        <div className={`p-3 rounded-lg bg-rootstock-primary/10 group-hover:bg-rootstock-primary/20 transition-colors duration-300`}>
          <Icon className={`h-6 w-6 ${getIconColor()}`} />
        </div>
        {trend !== undefined && (
          <div className={`flex items-center space-x-1 text-sm font-medium ${getTrendColor()}`}>
            <span>{getTrendIcon()}</span>
            <span>{Math.abs(trend).toFixed(2)}%</span>
          </div>
        )}
      </div>
      
      <div className="space-y-2">
        <h3 className="text-sm font-medium text-gray-400 uppercase tracking-wide">
          {title}
        </h3>
        
        {loading ? (
          <div className="animate-pulse">
            <div className="h-8 bg-gray-700 rounded w-3/4 mb-2"></div>
            <div className="h-4 bg-gray-700 rounded w-1/2"></div>
          </div>
        ) : (
          <>
            <div className="text-2xl font-bold text-rootstock-text">
              {value}
            </div>
            {subtitle && (
              <div className="text-sm text-gray-400">
                {subtitle}
              </div>
            )}
          </>
        )}
      </div>
    </div>
  );
};

export default DashboardCard;



