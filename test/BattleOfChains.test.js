const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("BattleOfChains", function () {
  let BattleOfChains, battleOfChains, owner, addr1;
  const collectionAddress = "0xfFfffFFFffFFFffffffFfFfe0000000000000001";

  beforeEach(async function () {
    // Get signers
    [owner, addr1] = await ethers.getSigners();

    // Deploy the BattleOfChains contract
    BattleOfChains = await ethers.getContractFactory("BattleOfChains");
    battleOfChains = await BattleOfChains.deploy(collectionAddress);
  });

  it("should return correct typeTokenURI for valid types", async function () {
    const type1URI = await battleOfChains.typeTokenURI(1);

    expect(await battleOfChains.typeTokenURI(0)).to.equal("ipfs://QmType0");
    expect(await battleOfChains.typeTokenURI(1)).to.equal("ipfs://QmType1");
    expect(await battleOfChains.typeTokenURI(2)).to.equal("ipfs://Qmdefault");
    expect(await battleOfChains.typeTokenURI(3)).to.equal("ipfs://Qmdefault");
    expect(await battleOfChains.typeTokenURI(99)).to.equal("ipfs://Qmdefault");
  });

  it("should return the correct creator address from token ID", async function () {
    const creatorAddress = await battleOfChains.creatorFromTokenId("0x123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef");
    expect(creatorAddress).to.equal("0x89abCdef0123456789AbCDEf0123456789AbCDEF");
  });
});
