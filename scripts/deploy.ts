import { ethers } from "hardhat";

async function main() {
  const collectionAddress = "0xfFfffFFFffFFFffffffFfFfe0000000000000001";

  const accounts = await ethers.getSigners();
  console.log("Deploying contracts with the account:", accounts[0].address);
  const deployerBalance = await ethers.provider.getBalance(accounts[0].address);
  console.log("Account balance:", deployerBalance);
  
  const ContractFactory = await ethers.getContractFactory(
    "BattleOfChains",
  );

  const instance = await ContractFactory.deploy(
    collectionAddress,
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
