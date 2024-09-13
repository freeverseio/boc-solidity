import { ethers } from "hardhat";

async function main() {
  const tokenName = "FutureLAOS";
  const tokenSymbol = "FLAOS";

  const accounts = await ethers.getSigners();
  console.log("Deploying contracts with the account:", accounts[0].address);

  const ContractFactory = await ethers.getContractFactory(
    "Balances",
  );

  const instance = await ContractFactory.deploy(
    tokenName,
    tokenSymbol,
  );
  await instance.waitForDeployment();

  console.log(`Contract deployed to ${await instance.getAddress()}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
