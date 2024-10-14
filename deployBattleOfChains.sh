echo "This script flattens the BattleOfChains contract and overwrites the output to  ./deployWithTruffle/contracts/BattleOfChains.sol "
echo "Then it runs truffle to deploy and setup the contract on LAOS"
echo "Flatening..."
npx hardhat flatten ./contracts/BattleOfChains.sol > ./deployWithTruffle/contracts/BattleOfChains.sol 
echo "...DONE"
echo "Compiling flattened file..."
(cd deployWithTruffle && ./node_modules/.bin/truffle compile)
echo "...DONE"
echo "Deploying with truffle..."
(cd deployWithTruffle && ./node_modules/.bin/truffle exec scripts/deploy.js --network laos)
echo "...DONE"

