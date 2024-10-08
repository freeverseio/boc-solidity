# Battle of Chains

Make sure you have all the required dependencies:

```bash
npm ci
```

### Compiling the Contract

Compile the contracts with the following command:

```bash
npx hardhat compile
```

### Testing the Contract

The following command runs the test suite:

```bash
npx hardhat test
```

### Deploying the Contract

You will first need some currency on your deploying account. Then add the private key in your local `.env` file, in this way:
```bash
$ cat .env
PRIVATE_KEY="abc.......123"
```

To deploy the contract, edit the `hardhat.config.ts` file, and use the following command:

```bash
npx hardhat run --network <network-name> scripts/deploy.ts
```
