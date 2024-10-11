/* eslint-disable no-undef */
const BattleOfChains = artifacts.require("BattleOfChains");
const EvolutionCollectionFactory = artifacts.require("EvolutionCollectionFactory");

const assignedCollectionAddress = "0xfFFfFffffFffFFfFFffffffe000000000000000D";

module.exports = async (callback) => {
  try {
    // Deployer must be the owner of the current precompile collection
    const [deployer] = await web3.eth.getAccounts();
    console.log('Deployer = ', deployer);  
    const aliceBalance = await web3.eth.getBalance(deployer);
    console.log('Deployer\'s balance:', web3.utils.fromWei(aliceBalance, 'ether'), 'LAOS');

    console.log('Connecting to collection factory...');
    const newcol = await EvolutionCollectionFactory.at("0x0000000000000000000000000000000000000403");
    console.log('...DONE');
      return;

    console.log('deploying BattleOfChains... assigned to collection ', assignedCollectionAddress);
    const battle = await BattleOfChains.new(assignedCollectionAddress);
    console.log('...DONE. Deployed at ', battle.address);
    
    console.log('assigning tokenURI for type 0 and type 1 multimints...');
    await battle.addTokenURIs([0, 1], ["ipfs://QmS5adNn3aAWVLLBXmjG3kK8gbq36NfnefmKm9udFhGi3K", "ipfs://QmS5adNn3aAWVLLBXmjG3kK8gbq36NfnefmKm9udFhGi3K"]);
    console.log('...DONE');

    callback();
  } catch (error) {
    console.log(error);
    callback();
  }
};
