const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("BattleOfChains", function () {
  let BattleOfChains, battleOfChains, owner, addr1;
  const collectionAddress = "0xffFFFffFFffFFfFFFFfFFfFE0000000000000001";

  beforeEach(async function () {
    // Get signers
    [owner, addr1] = await ethers.getSigners();

    // Deploy the BattleOfChains contract
    BattleOfChains = await ethers.getContractFactory("BattleOfChains");
    battleOfChains = await BattleOfChains.deploy();
  });

  it("should generate a random number from the previous block", async function () {
    const random = await battleOfChains.generateRandom();
    expect(random).to.be.a("bigint");
  });

  it("should generate a valid type (0 or 1) from random number", async function () {
    const random = await battleOfChains.generateRandom();
    const typeGenerated = await battleOfChains.generateType(random);
    expect(Number(typeGenerated)).to.be.oneOf([0, 1]);
  });


  it("should generate a valid slot with the joinedChainId", async function () {
    const random = await battleOfChains.generateRandom();
    const typeGenerated = await battleOfChains.generateType(random);
    const joinedChainId = 12345;
    const slot = await battleOfChains.generateSlot(random, typeGenerated, joinedChainId);
    expect(slot).to.be.a("bigint");
  });

  it("should return correct presetTokenURI for valid types", async function () {
    const type0URI = await battleOfChains.presetTokenURI(0);
    const type1URI = await battleOfChains.presetTokenURI(1);

    expect(type0URI).to.equal("ipfs://QmType0");
    expect(type1URI).to.equal("ipfs://QmType1");
  });

  it("should revert when requesting unsupported token type URI", async function () {
    await expect(battleOfChains.presetTokenURI(2)).to.be.revertedWith("Type not supported");
  });

  it("should return the correct type from token ID", async function () {
    const typeFromTokenId = await battleOfChains.typeFromTokenId("0x123456789abcdef0123400089abcdef0123456789abcdef0123456789abcdef");
    expect(Number(typeFromTokenId)).to.equal(0);
    const typeFromTokenId2 = await battleOfChains.typeFromTokenId("0x123456789abcdef0123400189abcdef0123456789abcdef0123456789abcdef");
    expect(Number(typeFromTokenId2)).to.equal(1);
  });

  it("should return the correct chain ID from token ID", async function () {
    const chainIdFromTokenId = await battleOfChains.chainIdFromTokenId("0x123456789abcde00000000189abcdef0123456789abcdef0123456789abcdef");
    expect(Number(chainIdFromTokenId)).to.equal(0);
    const chainIdFromTokenId2 = await battleOfChains.chainIdFromTokenId("0x123456789abcde00000000989abcdef0123456789abcdef0123456789abcdef");
    expect(Number(chainIdFromTokenId2)).to.equal(1);
  });

  it("should return the correct creator address from token ID", async function () {
    const creatorAddress = await battleOfChains.creatorFromTokenId("0x123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef");
    expect(creatorAddress).to.equal("0x89abCdef0123456789AbCDEf0123456789AbCDEF");
  });
});
