/* eslint-disable no-undef */
const BattleOfChains = artifacts.require("BattleOfChains");
const EvolutionCollectionFactory = artifacts.require("EvolutionCollectionFactory");
const EvolutionCollection = artifacts.require("EvolutionCollection");

module.exports = async (callback) => {
  try {
    // Deployer must be the owner of the current precompile collection
    const [deployer] = await web3.eth.getAccounts();
    console.log('Deployer = ', deployer);  
    const aliceBalance = await web3.eth.getBalance(deployer);
    console.log('Deployer\'s balance:', web3.utils.fromWei(aliceBalance, 'ether'), 'LAOS');

    console.log('Connecting to collection factory...');
    const colectionFactory = await EvolutionCollectionFactory.at("0x0000000000000000000000000000000000000403");
    console.log('Connecting to collection factory...DONE');

    console.log('Creating new collection...');
    const response = await colectionFactory.createCollection(deployer);
    const newCollectionAddress = response.logs[0].args["_collectionAddress"];
    console.log('Creating new collection... DONE at address: ', newCollectionAddress);
    const precompileContract = await EvolutionCollection.at(newCollectionAddress);

    console.log('deploying BattleOfChains... assigned to collection ', newCollectionAddress);
    const battle = await BattleOfChains.new(newCollectionAddress);
    console.log('...DONE. Deployed at ', battle.address);
    
    console.log('Setting precompile owner to BattleOfChains contract...');
    await precompileContract.transferOwnership(battle.address);
    console.log('Setting precompile owner to BattleOfChains contract...DONE');

    console.log('assigning tokenURI for type 0 and type 1 multimints...');
    await battle.addTokenURIs([0, 1], ["ipfs://QmS5adNn3aAWVLLBXmjG3kK8gbq36NfnefmKm9udFhGi3K", "ipfs://QmS5adNn3aAWVLLBXmjG3kK8gbq36NfnefmKm9udFhGi3K"]);
    console.log('...DONE');

    callback();
  } catch (error) {
    console.log(error);
    callback();
  }
};
