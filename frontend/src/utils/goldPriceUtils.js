import { getContract, formatTokenAmount } from './contractConfig';

/**
 * Fetch gold price with automatic fallback
 * Tries GoldReader first (LayerZero), then falls back to GoldPriceOracle
 * 
 * @param {Object} provider - Ethers provider
 * @param {string} userAccount - User account address (optional)
 * @returns {Promise<Object>} - { price: string, source: string, timestamp: number }
 */
export const fetchGoldPrice = async (provider, userAccount = null) => {
    try {
        // Try GoldReader first (LayerZero integration)
        const goldReaderAddress = import.meta.env.VITE_GOLD_READER_ADDRESS;

        if (goldReaderAddress && goldReaderAddress !== '0x0000000000000000000000000000000000000000') {
            try {
                const goldReader = getContract('GOLD_READER', provider, goldReaderAddress);
                const [lastUpdated, isStale] = await Promise.all([
                    goldReader.lastUpdated(),
                    goldReader.isPriceStale(),
                ]);

                // If price has never been set (lastUpdated = 0), fall back to Oracle
                if (Number(lastUpdated) === 0) {
                    console.warn('GoldReader has no price set, falling back to GoldPriceOracle');
                    throw new Error('No price set in GoldReader');
                }

                // Try to get price
                const pricePerGram = await goldReader.getGoldPricePerGram();

                return {
                    price: formatTokenAmount(pricePerGram, 8),
                    source: isStale ? 'GoldReader (stale)' : 'GoldReader (Live)',
                    timestamp: Number(lastUpdated) * 1000, // Convert to milliseconds
                    isStale,
                };
            } catch (error) {
                console.warn('GoldReader failed, falling back to GoldPriceOracle:', error);
            }
        }

        // Fallback to GoldPriceOracle
        const goldOracle = getContract('GOLD_PRICE_ORACLE', provider);
        const pricePerGram = await goldOracle.getGoldPricePerGram();

        return {
            price: formatTokenAmount(pricePerGram, 8),
            source: 'GoldPriceOracle',
            timestamp: Date.now(),
            isStale: false,
        };

    } catch (error) {
        console.error('Error fetching gold price:', error);
        throw new Error('Failed to fetch gold price');
    }
};

/**
 * Update gold price (only works with GoldReader)
 * 
 * @param {Object} signer - Ethers signer
 * @returns {Promise<boolean>} - Success status
 */
export const updateGoldPrice = async (signer) => {
    const goldReaderAddress = import.meta.env.VITE_GOLD_READER_ADDRESS;

    if (!goldReaderAddress || goldReaderAddress === '0x0000000000000000000000000000000000000000') {
        throw new Error('GoldReader not configured');
    }

    try {
        const goldReader = getContract('GOLD_READER', signer, goldReaderAddress);
        const tx = await goldReader.updatePrice();
        await tx.wait();
        return true;
    } catch (error) {
        console.error('Error updating gold price:', error);
        throw error;
    }
};

