const { expect } = require("chai");
const { ethers } = require("hardhat");
const { AbiCoder, keccak256 } = require("ethers");

describe("URIManager", function () {
  let URIManager, uriManager, owner, addr1;
  const collectionAddress = '0xfFfffFFFffFFFffffffFfFfe0000000000000001';
  const nullAddress = '0x0000000000000000000000000000000000000000';
  const ChainActionType = {
    DEFEND: 0,
    IMPROVE: 1,
    ATTACK_AREA: 2,
    ATTACK_ADDRESS: 3,
  };
  const Attack_Area = {
    NULL: 0,
    NORTH: 1,
    SOUTH: 2,
    EAST: 3,
    WEST: 4,
    ALL: 5,
  };

  
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

    await expect(uriManager.connect(addr1).setMissingTypeURI("ipfs://Qmdefault"))
      .to.not.be.reverted;

    await expect(uriManager.connect(addr1).setTokenURIs([0, 1], ["ipfs://QmType0", "ipfs://QmType1"]))
      .to.not.be.reverted;

    await expect(uriManager.connect(addr1).setURIManager(owner.address))
      .to.not.be.reverted;
  });

  it("should return correct typeTokenURI for valid types", async function () {
    expect(await uriManager.typeTokenURI(0)).to.equal("");
    await uriManager.setMissingTypeURI("ipfs://Qmdefault");
    expect(await uriManager.typeTokenURI(0)).to.equal("ipfs://Qmdefault");
    expect(await uriManager.typeTokenURI(1)).to.equal("ipfs://Qmdefault");
    await uriManager.setTokenURIs([0, 1], ["ipfs://QmType0", "ipfs://QmType1"]);
    expect(await uriManager.typeTokenURI(0)).to.equal("ipfs://QmType0");
    expect(await uriManager.typeTokenURI(1)).to.equal("ipfs://QmType1");
    expect(await uriManager.typeTokenURI(2)).to.equal("ipfs://Qmdefault");
    expect(await uriManager.typeTokenURI(3)).to.equal("ipfs://Qmdefault");
    expect(await uriManager.typeTokenURI(99)).to.equal("ipfs://Qmdefault");
  });

});

