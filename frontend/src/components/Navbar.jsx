import React, { useState } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { Wallet, Menu, X, Coins } from 'lucide-react';
import { useWallet } from '../context/WalletContext';

const Navbar = () => {
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const location = useLocation();
  const { account, isConnected, isConnecting, connectWallet, disconnectWallet, getShortAddress } = useWallet();

  const navItems = [
    { name: 'Home', path: '/' },
    { name: 'Dashboard', path: '/dashboard' },
    { name: 'Mint', path: '/mint' },
    { name: 'Redeem', path: '/redeem' },
  ];

  const isActive = (path) => location.pathname === path;

  return (
    <nav className="bg-rootstock-card border-b border-rootstock-border sticky top-0 z-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center h-16">
          {/* Logo */}
          <Link to="/" className="flex items-center space-x-2">
            <div className="bg-gradient-to-r from-rootstock-primary to-yellow-400 p-2 rounded-lg">
              <Coins className="h-6 w-6 text-rootstock-bg" />
            </div>
            <span className="text-xl font-bold gradient-text">POIPOI</span>
            <span className="text-sm text-gray-400">Stablecoin</span>
          </Link>

          {/* Desktop Navigation */}
          <div className="hidden md:flex items-center space-x-8">
            {navItems.map((item) => (
              <Link
                key={item.name}
                to={item.path}
                className={`px-3 py-2 rounded-md text-sm font-medium transition-colors duration-200 ${
                  isActive(item.path)
                    ? 'text-rootstock-primary bg-rootstock-primary/10'
                    : 'text-gray-300 hover:text-rootstock-primary hover:bg-rootstock-primary/5'
                }`}
              >
                {item.name}
              </Link>
            ))}
          </div>

          {/* Wallet Connection */}
          <div className="flex items-center space-x-4">
            {isConnected ? (
              <div className="flex items-center space-x-3">
                <div className="flex items-center space-x-2 bg-rootstock-primary/10 px-3 py-2 rounded-lg">
                  <Wallet className="h-4 w-4 text-rootstock-primary" />
                  <span className="text-sm font-medium text-rootstock-primary">
                    {getShortAddress(account)}
                  </span>
                </div>
                <button
                  onClick={disconnectWallet}
                  className="text-sm text-gray-400 hover:text-rootstock-primary transition-colors duration-200"
                >
                  Disconnect
                </button>
              </div>
            ) : (
              <button
                onClick={connectWallet}
                disabled={isConnecting}
                className="btn-primary flex items-center space-x-2 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <Wallet className="h-4 w-4" />
                <span>{isConnecting ? 'Connecting...' : 'Connect Wallet'}</span>
              </button>
            )}

            {/* Mobile menu button */}
            <button
              onClick={() => setIsMenuOpen(!isMenuOpen)}
              className="md:hidden p-2 rounded-md text-gray-400 hover:text-rootstock-primary hover:bg-rootstock-primary/10"
            >
              {isMenuOpen ? <X className="h-6 w-6" /> : <Menu className="h-6 w-6" />}
            </button>
          </div>
        </div>

        {/* Mobile Navigation */}
        {isMenuOpen && (
          <div className="md:hidden">
            <div className="px-2 pt-2 pb-3 space-y-1 sm:px-3 border-t border-rootstock-border">
              {navItems.map((item) => (
                <Link
                  key={item.name}
                  to={item.path}
                  onClick={() => setIsMenuOpen(false)}
                  className={`block px-3 py-2 rounded-md text-base font-medium transition-colors duration-200 ${
                    isActive(item.path)
                      ? 'text-rootstock-primary bg-rootstock-primary/10'
                      : 'text-gray-300 hover:text-rootstock-primary hover:bg-rootstock-primary/5'
                  }`}
                >
                  {item.name}
                </Link>
              ))}
            </div>
          </div>
        )}
      </div>
    </nav>
  );
};

export default Navbar;



