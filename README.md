# Battle of Chains

Battle of Chains is the first multi-chain game that is truly permissionless, decentralized, and unstoppable. The gameplay leverages the Multichain Atomic Mint crypto-primitive, provided by the [LAOS Network's](https://laosnetwork.io/) Bridgeless Minting pattern.

For further information: [Developer Docs](https://docs.laosnetwork.io/), [LAOS Network Medium](https://medium.com/laosnetwork).

## Installing

To install, compile, and test:

```bash
npm ci
npx hardhat compile
npx hardhat test
```

## Deploying the Contract

You will first need some currency in your deploying account. Add the corresponding private key in your local `.env` file:
```bash
$ cat .env
PRIVATE_KEY="abc.......123"
```

To deploy the contract, ensure that the network name and parameteres are correctly entered in the [Hardhat config file](./hardhat.config.ts), and use the following command:
```bash
npx hardhat run --network <network-name> scripts/deploy.ts
```

On the supported ownership chains, contracts are deployed via:
```bash
npx hardhat run --network <network-name> scripts/deploy721.ts
```

## Verifying the Contract


Hardhat has a flattener plugin that creates a single Solidity file with all imports included:
```bash
npx hardhat flatten ./contracts/BattleOfChains.sol > flattened.sol
```
This file can be uploaded to explorers, alongside the correct Solidity compiler parameters in the [hardhat config file](./hardhat.config.ts), e.g.:
```javascript
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
```