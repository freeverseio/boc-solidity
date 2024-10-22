import { ethers, network } from "hardhat";

async function main() {
  // const battleOfChainsAddressOnLAOS = '0x12Cc8Ab85b9dc8f8Cddd5fc0e96d7a42847661B1';
  const precompileCollectionOnLAOS = '0xfFFfFFffFffFfFFFffFffFFe0000000000000016';
  const useLAOSMainnet = true;
  const baseULOC =
    useLAOSMainnet ?
    "https://uloc.io/GlobalConsensus(2)/Parachain(3370)/PalletInstance(51)" :
    "GlobalConsensus(0:0x77afd6190f1554ad45fd0d31aee62aacc33c6db0ea801129acb813f913e0764f)/Parachain(4006)/PalletInstance(51)";
  const baseURI = `${baseULOC}/AccountKey20(${precompileCollectionOnLAOS})/`;

  const accounts = await ethers.getSigners();
  console.log("Deploying contracts with the account:", accounts[0].address);

  const balance = await ethers.provider.getBalance(accounts[0].address);
  console.log("Deployer balance (in wei):", balance.toString());

  const ContractFactory = await ethers.getContractFactory(
    "BattleOfChains721",
  );

  const instance = await ContractFactory.deploy(accounts[0].address, baseURI);
  await instance.waitForDeployment();

  console.log(`Contract deployed to ${await instance.getAddress()}`);
  console.log(`
    If the deploy chain is compatible with Hardhat verification, you can verify it by running:
     npx hardhat verify --network ${network.name} "${await instance.getAddress()}" "${accounts[0].address}" "${baseURI}"
  `);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
