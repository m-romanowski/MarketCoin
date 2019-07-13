var MarketCoin = artifacts.require("./MarketCoin.sol");

module.exports = function(deployer, network, accounts) {
    // Deploys the MarketCoin contract and funds it with 0.5 ETH.
    deployer.deploy(MarketCoin, {
        from: accounts[9],
        gas: 6721975,
        value: 500000000000000000
    });
};
