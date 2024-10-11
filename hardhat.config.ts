import { HardhatUserConfig } from 'hardhat/config';
import '@nomicfoundation/hardhat-toolbox';
import "@nomicfoundation/hardhat-verify";
import * as dotenv from 'dotenv';
dotenv.config();

const privateKey =
  process.env.PRIVATE_KEY !== undefined
    ? process.env.PRIVATE_KEY
    : '123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0';

const POLYGONSCAN_KEY = process.env.POLYGONSCAN_KEY;

const config: HardhatUserConfig = {
  solidity: {
    version: '0.8.27',
    settings: {
      optimizer: {
        enabled: true,
      },
    },
  },
  networks: {
    hardhat: {
      chainId: 1337, // Hardhat Network's chain ID
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

    laos: {
      url: 'https://rpc.laos.laosfoundation.io',
      chainId: 6283,
      gas: 'auto',
      gasPrice: 'auto',
      accounts: [`0x${privateKey}`],
    },
  },

  etherscan: {
    apiKey: {
      polygon: POLYGONSCAN_KEY,
    },
  },
};

export default config;
