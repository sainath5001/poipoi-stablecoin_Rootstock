import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { Toaster } from 'react-hot-toast';
import { WalletProvider } from './context/WalletContext';
import Navbar from './components/Navbar';
import Home from './pages/Home';
import Dashboard from './pages/Dashboard';
import Mint from './pages/Mint';
import Redeem from './pages/Redeem';

function App() {
    return (
        <WalletProvider>
            <Router>
                <div className="min-h-screen bg-rootstock-bg">
                    <Navbar />
                    <main>
                        <Routes>
                            <Route path="/" element={<Home />} />
                            <Route path="/dashboard" element={<Dashboard />} />
                            <Route path="/mint" element={<Mint />} />
                            <Route path="/redeem" element={<Redeem />} />
                        </Routes>
                    </main>
                    <Toaster
                        position="top-right"
                        toastOptions={{
                            duration: 4000,
                            style: {
                                background: '#1A1A1A',
                                color: '#FFFFFF',
                                border: '1px solid #F7931A',
                            },
                            success: {
                                iconTheme: {
                                    primary: '#F7931A',
                                    secondary: '#1A1A1A',
                                },
                            },
                            error: {
                                iconTheme: {
                                    primary: '#EF4444',
                                    secondary: '#1A1A1A',
                                },
                            },
                        }}
                    />
                </div>
            </Router>
        </WalletProvider>
    );
}

export default App;
