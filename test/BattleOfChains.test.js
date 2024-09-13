const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("BattleOfChains", function () {
  let BattleOfChains, battleOfChains, mockCollection, owner, addr1;
  const collectionAddress = "0xffFFFffFFffFFfFFFFfFFfFE0000000000000001";

  beforeEach(async function () {
    // Get signers
    [owner, addr1] = await ethers.getSigners();

    // Deploy a mock IEvolutionCollection contract
    const MockCollection = await ethers.getContractFactory("MockCollection");
    mockCollection = await MockCollection.deploy();

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
    const tokenId = ethers.BigNumber.from("0x123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef");
    const chainIdFromTokenId = await battleOfChains.chainIdFromTokenId(tokenId);
    expect(chainIdFromTokenId).to.be.a("bigint");
  });

  it("should return the correct creator address from token ID", async function () {
    const tokenId = ethers.BigNumber.from("0x123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef");
    const creatorAddress = await battleOfChains.creatorFromTokenId(tokenId);
    expect(creatorAddress).to.be.a("string");
    expect(ethers.utils.isAddress(creatorAddress)).to.be.true;
  });

  it("should mint a token with a valid slot and URI", async function () {
    const joinedChainId = 12345;
    await mockCollection.mockMintWithExternalURI(owner.address, 1, "ipfs://QmType0"); // Mock mint for collection

    const tx = await battleOfChains.mint(joinedChainId);
    expect(tx).to.emit(mockCollection, "MintedWithExternalURI");
  });

  it("should mint with external URI", async function () {
    const slot = 123;
    const tokenURI = "ipfs://QmExternalURI";

    await mockCollection.mockMintWithExternalURI(addr1.address, slot, tokenURI); // Mock mint for collection

    const tx = await battleOfChains.mintWithExternalURI(addr1.address, slot, tokenURI);
    expect(tx).to.emit(mockCollection, "MintedWithExternalURI");
  });
});
