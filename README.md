# MarketCoin
The MarketCoin is a smart contract that allows you to convert ETH to PLN, USD, GBP, EUR and more. You can use manual update or oraclize api with recursive option. The smart contract stores wei value in the currency of your choice.

## Installation

### Packages
```
npm install
```

### Truffle
```
$ npm install -g truffle
```

### Ganache CLI (for non-public blockchain)
```
$ npm install -g ganache-cli
```

### Ethereum bridge (for non-public blockchain)
```
$ mkdir ethereum-bridge
$ git clone https://github.com/oraclize/ethereum-bridge ethereum-bridge
$ cd ethereum-bridge
$ npm install
```

## Usage

### Ganache CLI
```
$ ganache-cli
```

### Ethereum bridge
```
$ node bridge -a 9 -H 127.0.0.1 -p 8545 --dev
```

If you using non-public blockchain, e.g. ganache-cli, you must add the following line in smart contract (MarketCoin.sol) constructor (when "0x..." is generated during startup ethereum-bridge. If you’re using a different mnemonic than the standard Truffle one, the ETH address shown in between the round brackets will be different). Remove that line before production (like Ropsten testnet).

```
OAR = OraclizeAddrResolverI(0x...);
```

If you using non-public blockchain. At this point you should have open two terminal window with running:
  * ganache-cli
  * ethereum-bridge

Compile and migrate smart contracts:
```
$ truffle migrate --reset --network <type>
```

\<type>
  * development (non-public blockchain - ganache-cli)
  * ropsten (public blockchain testnet)

## Documentation
In progress

## Tests
In progress

## Built With

* [Oraclize](http://www.oraclize.it/)
* [Truffle](https://github.com/trufflesuite/truffle)

## Dependencies
* [Ethereum bridge](https://github.com/provable-things/ethereum-bridge)
* [Ganache CLI](https://github.com/trufflesuite/ganache-cli)

See package.json

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

