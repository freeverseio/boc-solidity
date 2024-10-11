const BattleOfChains = artifacts.require("BattleOfChains");
const truffleAssert = require('truffle-assertions');

const assignedCollectionAddress = "0xfFFfFffffFffFFfFFffffffe000000000000000D";
const maxGas = 10000000;

module.exports = async (callback) => {
  try {
    // Alice must be the owner of the current precompile collection
    const [alice] = await web3.eth.getAccounts();
    console.log('Alice = ', alice);  
    const aliceBalance = await web3.eth.getBalance(alice);
    console.log('Alice\'s balance:', web3.utils.fromWei(aliceBalance, 'ether'), 'LAOS');

    console.log('deploying BattleOfChains... assigned to collection ', assignedCollectionAddress);
    const battle = await BattleOfChains.new(assignedCollectionAddress);
    console.log('...deployed at ', battle.address);
    
    callback();
  } catch (error) {
    console.log(error);
    callback();
  }
};
