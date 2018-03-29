const MAINET_RPC_URL = 'https://mainnet.infura.io/metamask'
const ROPSTEN_RPC_URL = 'https://ropsten.infura.io/metamask'
const KOVAN_RPC_URL = 'https://kovan.infura.io/metamask'
const RINKEBY_RPC_URL = 'https://rinkeby.infura.io/metamask'

global.METAMASK_DEBUG = 'GULP_METAMASK_DEBUG'

module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  networks: {
      mainnet: MAINET_RPC_URL,
      ropsten: ROPSTEN_RPC_URL,
      kovan: KOVAN_RPC_URL,
      rinkeby: RINKEBY_RPC_URL,
      development: {
          host: "127.0.0.1",
          port: 8545,
          network_id: "*"
      }
  },
  solc: {
      optimizer: {
          version: "^0.4.21",
          enabled: false,
          runs: 200
      }
  }
};
