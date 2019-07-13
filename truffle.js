require('dotenv').config();
const HDWalletProvider = require('truffle-hdwallet-provider');

module.exports = {
    // See <http://truffleframework.com/docs/advanced/configuration>
    // for more about customizing your Truffle configuration!
    networks: {
        development: {
            host: "127.0.0.1",
            port: 8545,
            gas: 6721975,
            network_id: "*" // Match any network id
        },
        ropsten: {
            provider: function() {
                return new HDWalletProvider(
                    process.env.MNEMONIC,
                    `https://ropsten.infura.io/v3/${ process.env.INFURA_API_KEY }`
                )
            },
            gas: 8500000,
            gasPrice: 20000000000,
            network_id: 3
        }
    },
    compilers: {
        solc: {
            version: "^0.5.0",
            settings: {
                optimizer: {
                    enabled: true,
                    runs: 200
                }
            }
        }
    }
};
