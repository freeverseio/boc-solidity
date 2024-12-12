import { HardhatUserConfig } from 'hardhat/config';
import '@nomicfoundation/hardhat-toolbox';
import "@nomicfoundation/hardhat-verify";
import "@nomicfoundation/hardhat-ignition-ethers";
import * as dotenv from 'dotenv';
dotenv.config();

const privateKey =
  process.env.PRIVATE_KEY !== undefined
    ? process.env.PRIVATE_KEY
    : '123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0';

const POLYGONSCAN_KEY = process.env.POLYGONSCAN_KEY;
const ETHERSCAN_KEY = process.env.ETHERSCAN_KEY;
const ARBITRUMSCAN_KEY = process.env.ARBITRUMSCAN_KEY;

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.28",
    settings: {
      evmVersion: "paris",
      optimizer: {
        enabled: true,
        runs: 200
      },
    },
  },
  networks: {
    hardhat: {
      chainId: 1337, // Hardhat Network's chain ID
    },

    ethMainnet: {
      url: 'https://eth.llamarpc.com/',
      chainId: 1,
      gas: 'auto',
      gasPrice: 'auto',
      accounts: [`0x${privateKey}`],
    },

    arbitrum: {
      url: 'https://arbitrum.llamarpc.com',
      chainId: 42161,
      gas: 'auto',
      gasPrice: 'auto',
      accounts: [`0x${privateKey}`],
    },
    
    zombie: {
      url: 'http://127.0.0.1:9999',
      chainId: 667,
      gas: 'auto',
      gasPrice: 'auto',
      accounts: [`0x${privateKey}`],
    },
    
    amoy: {
      url: 'https://rpc.ankr.com/polygon_amoy',
      chainId: 80002,
      gas: 'auto',
      gasPrice: 'auto',
      accounts: [`0x${privateKey}`],
    },

    polygonMainnet: {
      url: 'https://polygon-rpc.com',
      chainId: 137,
      gas: 'auto',
      gasPrice: 'auto',
      accounts: [`0x${privateKey}`],
    },
    
    sigma: {
      url: 'https://rpc.laossigma.laosfoundation.io',
      chainId: 62850,
      gas: 'auto',
      gasPrice: 'auto',
      accounts: [`0x${privateKey}`],
    },

    'laos-chain': {
      url: 'https://rpc.laos.laosfoundation.io',
      chainId: 6283,
      gas: 'auto',
      gasPrice: 'auto',
      accounts: [`0x${privateKey}`],
    },
  },

  sourcify: {
    enabled: true
  },
  etherscan: {
    apiKey: {
      mainnet: ETHERSCAN_KEY,
      polygon: POLYGONSCAN_KEY,
      eth: ETHERSCAN_KEY,
      arbitrum: ARBITRUMSCAN_KEY,
      arbitrumOne: ARBITRUMSCAN_KEY,
      'laos-chain': 'empty',
    },
    customChains: [
      {
        network: "laos-chain",
        chainId: 6283,
        urls: {
          apiURL: "https://blockscout-be.laos.laosfoundation.io/api",
          browserURL: "https://blockscout.laos.laosfoundation.io:3000"
        }
      }
    ]
  },
};

export default config;
