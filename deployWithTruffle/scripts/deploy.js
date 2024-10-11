const BattleOfChains = artifacts.require("BattleOfChains");
const truffleAssert = require('truffle-assertions');

const assignedCollectionAddress = "0xfFFfFffffFffFFfFFffffffe000000000000000D";
const maxGas = 10000000;

module.exports = async (callback) => {
  try {
    const [alice, bob] = await web3.eth.getAccounts();

    console.log('Querying Alice balance...');
    return;
    callback();
  } catch (error) {
    console.log(error);
    callback();
  }
};
