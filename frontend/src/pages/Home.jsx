import React from 'react';
import { Link } from 'react-router-dom';
import { useWallet } from '../context/WalletContext';
import { Coins, Shield, Zap, Globe, ArrowRight, CheckCircle } from 'lucide-react';

const Home = () => {
    const { isConnected } = useWallet();

    const features = [
        {
            icon: Shield,
            title: 'Gold-Backed Stability',
            description: 'Each POI token is backed by 1 gram of gold, providing intrinsic value and stability.',
        },
        {
            icon: Zap,
            title: 'Instant Transactions',
            description: 'Fast and secure transactions on the Rootstock network with Bitcoin-level security.',
        },
        {
            icon: Globe,
            title: 'Decentralized',
            description: 'No central authority controls your tokens. You maintain full ownership and control.',
        },
    ];

    const steps = [
        {
            number: '01',
            title: 'Connect Wallet',
            description: 'Connect your MetaMask wallet to the Rootstock network',
        },
        {
            number: '02',
            title: 'Mint POI Tokens',
            description: 'Convert USD to POI tokens backed by real gold',
        },
        {
            number: '03',
            title: 'Trade & Redeem',
            description: 'Use POI tokens or redeem them back to USD anytime',
        },
    ];

    return (
        <div className="min-h-screen bg-rootstock-bg">
            {/* Hero Section */}
            <section className="relative overflow-hidden">
                <div className="absolute inset-0 bg-gradient-to-br from-rootstock-primary/5 to-transparent"></div>
                <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20">
                    <div className="text-center">
                        <div className="flex justify-center mb-8">
                            <div className="bg-gradient-to-r from-rootstock-primary to-yellow-400 p-4 rounded-2xl">
                                <Coins className="h-16 w-16 text-rootstock-bg" />
                            </div>
                        </div>

                        <h1 className="text-5xl md:text-6xl font-bold text-rootstock-text mb-6">
                            POIPOI
                            <span className="block gradient-text">Stablecoin</span>
                        </h1>

                        <p className="text-xl text-gray-400 mb-8 max-w-3xl mx-auto">
                            The first decentralized, gold-backed stablecoin on Rootstock.
                            Each POI token represents 1 gram of gold, providing stability and value preservation.
                        </p>

                        <div className="flex flex-col sm:flex-row gap-4 justify-center">
                            {isConnected ? (
                                <Link to="/dashboard" className="btn-primary text-lg px-8 py-4">
                                    Go to Dashboard
                                </Link>
                            ) : (
                                <button className="btn-primary text-lg px-8 py-4">
                                    Connect Wallet
                                </button>
                            )}
                            <Link to="/mint" className="btn-secondary text-lg px-8 py-4">
                                Start Minting
                            </Link>
                        </div>
                    </div>
                </div>
            </section>

            {/* Features Section */}
            <section className="py-20">
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                    <div className="text-center mb-16">
                        <h2 className="text-3xl md:text-4xl font-bold text-rootstock-text mb-4">
                            Why Choose POIPOI?
                        </h2>
                        <p className="text-xl text-gray-400 max-w-2xl mx-auto">
                            Built on Rootstock for maximum security and efficiency
                        </p>
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
                        {features.map((feature, index) => (
                            <div key={index} className="card text-center group hover:shadow-xl hover:shadow-rootstock-primary/10 transition-all duration-300">
                                <div className="bg-rootstock-primary/10 p-4 rounded-xl w-fit mx-auto mb-6 group-hover:bg-rootstock-primary/20 transition-colors duration-300">
                                    <feature.icon className="h-8 w-8 text-rootstock-primary" />
                                </div>
                                <h3 className="text-xl font-semibold text-rootstock-text mb-4">
                                    {feature.title}
                                </h3>
                                <p className="text-gray-400">
                                    {feature.description}
                                </p>
                            </div>
                        ))}
                    </div>
                </div>
            </section>

            {/* How It Works Section */}
            <section className="py-20 bg-rootstock-card/50">
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                    <div className="text-center mb-16">
                        <h2 className="text-3xl md:text-4xl font-bold text-rootstock-text mb-4">
                            How It Works
                        </h2>
                        <p className="text-xl text-gray-400 max-w-2xl mx-auto">
                            Get started with POIPOI in three simple steps
                        </p>
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
                        {steps.map((step, index) => (
                            <div key={index} className="relative">
                                <div className="card text-center group hover:shadow-xl hover:shadow-rootstock-primary/10 transition-all duration-300">
                                    <div className="absolute -top-4 left-1/2 transform -translate-x-1/2">
                                        <div className="w-8 h-8 bg-rootstock-primary rounded-full flex items-center justify-center">
                                            <span className="text-sm font-bold text-rootstock-bg">
                                                {step.number}
                                            </span>
                                        </div>
                                    </div>

                                    <div className="pt-4">
                                        <h3 className="text-xl font-semibold text-rootstock-text mb-4">
                                            {step.title}
                                        </h3>
                                        <p className="text-gray-400">
                                            {step.description}
                                        </p>
                                    </div>
                                </div>

                                {index < steps.length - 1 && (
                                    <div className="hidden md:block absolute top-1/2 -right-4 transform -translate-y-1/2">
                                        <ArrowRight className="h-6 w-6 text-rootstock-primary/50" />
                                    </div>
                                )}
                            </div>
                        ))}
                    </div>
                </div>
            </section>

            {/* Stats Section */}
            <section className="py-20">
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                    <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
                        <div className="text-center">
                            <div className="text-4xl font-bold text-rootstock-primary mb-2">
                                1:1
                            </div>
                            <div className="text-gray-400">
                                Gold Ratio
                            </div>
                        </div>
                        <div className="text-center">
                            <div className="text-4xl font-bold text-rootstock-primary mb-2">
                                100%
                            </div>
                            <div className="text-gray-400">
                                Decentralized
                            </div>
                        </div>
                        <div className="text-center">
                            <div className="text-4xl font-bold text-rootstock-primary mb-2">
                                &lt; 1s
                            </div>
                            <div className="text-gray-400">
                                Transaction Time
                            </div>
                        </div>
                        <div className="text-center">
                            <div className="text-4xl font-bold text-rootstock-primary mb-2">
                                24/7
                            </div>
                            <div className="text-gray-400">
                                Available
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            {/* CTA Section */}
            <section className="py-20 bg-gradient-to-r from-rootstock-primary/10 to-yellow-400/10">
                <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
                    <h2 className="text-3xl md:text-4xl font-bold text-rootstock-text mb-4">
                        Ready to Get Started?
                    </h2>
                    <p className="text-xl text-gray-400 mb-8">
                        Join the future of stable digital currency backed by gold
                    </p>

                    <div className="flex flex-col sm:flex-row gap-4 justify-center">
                        <Link to="/mint" className="btn-primary text-lg px-8 py-4">
                            Mint POI Tokens
                        </Link>
                        <Link to="/dashboard" className="btn-secondary text-lg px-8 py-4">
                            View Dashboard
                        </Link>
                    </div>
                </div>
            </section>

            {/* Footer */}
            <footer className="bg-rootstock-card border-t border-rootstock-border py-12">
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                    <div className="text-center">
                        <div className="flex items-center justify-center space-x-2 mb-4">
                            <div className="bg-gradient-to-r from-rootstock-primary to-yellow-400 p-2 rounded-lg">
                                <Coins className="h-6 w-6 text-rootstock-bg" />
                            </div>
                            <span className="text-xl font-bold gradient-text">POIPOI</span>
                        </div>
                        <p className="text-gray-400 mb-4">
                            Decentralized Gold-Backed Stablecoin on Rootstock
                        </p>
                        <p className="text-sm text-gray-500">
                            © 2024 POIPOI. All rights reserved.
                        </p>
                    </div>
                </div>
            </footer>
        </div>
    );
};

export default Home;
