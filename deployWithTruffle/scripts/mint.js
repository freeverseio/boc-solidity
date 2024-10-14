/* eslint-disable no-undef */
const BattleOfChains = artifacts.require("BattleOfChains");
const EvolutionCollectionFactory = artifacts.require("EvolutionCollectionFactory");
const EvolutionCollection = artifacts.require("EvolutionCollection");

module.exports = async (callback) => {
  try {
    const deployedBattleOfChainsAddress = '0x481dBf390D744ab679bB790F184BC0b3b2446da8';

    // Deployer must be the owner of the current precompile collection
    const [deployer] = await web3.eth.getAccounts();
    console.log('Deployer = ', deployer);  
    const aliceBalance = await web3.eth.getBalance(deployer);
    console.log('Deployer\'s balance:', web3.utils.fromWei(aliceBalance, 'ether'), 'LAOS');

    console.log('Connecting BattleOfChains to...', deployedBattleOfChainsAddress);
    const battle = await BattleOfChains.at(deployedBattleOfChainsAddress);
    console.log('...DONE. Connected to...', battle.address);
    
    console.log('Check that tokenURI is assigned for type 1...');
    console.log('Is type 1 defined? ', await battle.isTypeDefined(1) == true);
    console.log(await battle.tokenURIForType(1));
    console.log('...DONE');

    return
    console.log('Is owner of precompile the battleOfChains contract?', battle.address === await precompileContract.owner());
    console.log('....', battle.address, await precompileContract.owner());

    // Activate these lines only if a mint test is required
    console.log('user joinChain...')
    await battle.joinChain(1);
    console.log('user joinChain... DONE')

    console.log('user mints')
    await battle.multichainMint(0);
    console.log('user mints...DONE')


    callback();
  } catch (error) {
    console.log(error);
    callback();
  }
};
