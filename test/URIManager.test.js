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

    await expect(uriManager.connect(addr1).addTokenURIs([0, 1], ["ipfs://QmType0", "ipfs://QmType1"]))
      .to.not.be.reverted;

    await expect(uriManager.connect(addr1).setURIManager(owner.address))
      .to.not.be.reverted;
  });

  it("should return correct tokenURIForType for valid types after addTokenURIs", async function () {
    await expect(uriManager.tokenURIForType(0)).to.be.reverted;
    await uriManager.addTokenURIs([0, 1], ["ipfs://QmType0", "ipfs://QmType1"]);
    expect(await uriManager.tokenURIForType(0)).to.equal("ipfs://QmType0");
    expect(await uriManager.tokenURIForType(1)).to.equal("ipfs://QmType1");
    await expect(uriManager.tokenURIForType(2)).to.be.reverted;
  });

});

