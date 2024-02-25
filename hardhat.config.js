require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config(); 

const { PRIVATE_KEY, INFURA_API_KEY, LINEASCAN_API_KEY } = process.env;

module.exports = {
  solidity: "0.8.22", 
  networks: {
    linea_testnet: {
      url: `https://linea-goerli.infura.io/v3/${INFURA_API_KEY}`,
      accounts: [PRIVATE_KEY],
    },
    linea_mainnet: {
      url: `https://linea-mainnet.infura.io/v3/${INFURA_API_KEY}`, 
      accounts:  [PRIVATE_KEY], 
      chainId: 59144, 
    }
  },
  sourcify: {
    enabled: true
  },  
  etherscan: {
    apiKey: {
      linea_goerli: LINEASCAN_API_KEY,
      linea_mainnet: LINEASCAN_API_KEY
    },
    customChains: [
      {
        network: "linea_goerli",
        chainId: 59140,
        urls: {
          apiURL: "https://api-testnet.lineascan.build/api",
          browserURL: "https://goerli.lineascan.build/"
        }
      },
      {
        network: "linea_mainnet",
        chainId: 59144,
        urls: {
          apiURL: "https://api.lineascan.build/api",
          browserURL: "https://lineascan.build/"
        }
      }
    ]
  }
};
