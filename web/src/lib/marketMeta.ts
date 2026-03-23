export type MarketAsset = {
  symbol: "BTC" | "ETH" | "SOL" | "BNB";
  pair: string;
  iconUrl: string;
};

export const SUPPORTED_MARKET_ASSETS: MarketAsset[] = [
  {
    symbol: "BTC",
    pair: "BTC_USDT",
    iconUrl: "https://cryptoicons.org/api/icon/btc/32",
  },
  {
    symbol: "ETH",
    pair: "ETH_USDT",
    iconUrl: "https://cryptoicons.org/api/icon/eth/32",
  },
  {
    symbol: "SOL",
    pair: "SOL_USDT",
    iconUrl: "https://cryptoicons.org/api/icon/sol/32",
  },
  {
    symbol: "BNB",
    pair: "BNB_USDT",
    iconUrl: "https://cryptoicons.org/api/icon/bnb/32",
  },
];

export const SUPPORTED_PAIRS = SUPPORTED_MARKET_ASSETS.map((asset) => asset.pair);
export const SUPPORTED_ASSET_SYMBOLS = SUPPORTED_MARKET_ASSETS.map((asset) => asset.symbol);
