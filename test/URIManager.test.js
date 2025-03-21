/* eslint-disable no-undef */
/* eslint-disable @typescript-eslint/no-require-imports */
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("URIManager", function () {
  let URIManager, uriManager, owner, addr1;
  
  beforeEach(async function () {
    [owner, addr1] = await ethers.getSigners();
    URIManager = await ethers.getContractFactory("URIManager");
    uriManager = await URIManager.deploy();
  });

  it("can set new URI manager, who can then operate as expected", async function () {
    await expect(uriManager.connect(addr1).setURIManager(addr1.address))
      .to.be.revertedWithCustomError(uriManager, "SenderIsNotURIManager")

    await uriManager.connect(owner).setURIManager(addr1.address);
    expect(await uriManager.uriManager()).to.equal(addr1.address);

    await expect(uriManager.connect(addr1).addTokenURIs(["ipfs://QmType0", "ipfs://QmType1"]))
      .to.not.be.reverted;

    await expect(uriManager.connect(addr1).setURIManager(owner.address))
      .to.not.be.reverted;
  });

  it("only URI Manager can change token URIs", async function () {
    await expect(uriManager.connect(owner).addTokenURIs(["ipfs://QmType0", "ipfs://QmType1"]))
      .to.not.be.reverted;


    await expect(uriManager.connect(addr1).changeTokenURIs([0,1],["ipfs://QmType100", "ipfs://QmType200"]))
      .to.be.revertedWithCustomError(uriManager, "SenderIsNotURIManager")

    await expect(uriManager.connect(owner).changeTokenURIs([0,1],["ipfs://QmType100", "ipfs://QmType200"]))
      .to.not.be.reverted;

    expect(await uriManager.tokenURIForType(0)).to.equal("ipfs://QmType100");
    expect(await uriManager.tokenURIForType(1)).to.equal("ipfs://QmType200");
  });

  it("should return correct tokenURIForType for valid types after addTokenURIs", async function () {
    expect(await uriManager.isTypeDefined(0)).to.equal(false);
    expect(await uriManager.nDefinedTypes()).to.equal(0);

    await expect(uriManager.tokenURIForType(0)).to.be.reverted;
    await uriManager.addTokenURIs(["ipfs://QmType0", "ipfs://QmType1"]);
    expect(await uriManager.nDefinedTypes()).to.equal(2);
    expect(await uriManager.isTypeDefined(0)).to.equal(true);
    expect(await uriManager.isTypeDefined(1)).to.equal(true);
    expect(await uriManager.isTypeDefined(2)).to.equal(false);
    expect(await uriManager.tokenURIForType(0)).to.equal("ipfs://QmType0");
    expect(await uriManager.tokenURIForType(1)).to.equal("ipfs://QmType1");
    await expect(uriManager.tokenURIForType(2)).to.be.reverted;
  });

});

