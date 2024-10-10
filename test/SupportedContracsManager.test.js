const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("SupportedContractsManager", function () {
  let SupContracts, supContracts, owner, addr1;
  const dummyAddress = '0xfFfffFFFffFFFffffffFfFfe0000000000000001';
  
  beforeEach(async function () {
    [owner, addr1] = await ethers.getSigners();
    SupContracts = await ethers.getContractFactory("SupportedContractsManager");
    supContracts = await SupContracts.deploy();
  });

  it("only contracts manager can add contracts", async function () {
    expect(await supContracts.supportedContractsManager()).to.equal(owner.address);
    const chain = 123;
    const observations = 'used to trade on this chain';
    await expect(supContracts.connect(addr1).addSupportedContract(chain, dummyAddress, observations))
      .to.be.revertedWithCustomError(supContracts, "SenderIsNotSupportedContractsManager")

    await expect(supContracts.connect(owner).addSupportedContract(chain, dummyAddress, observations))
      .not.to.be.reverted;
  });

  it("can set new contracts manager, who can then operate as expected", async function () {
    expect(await supContracts.supportedContractsManager()).to.equal(owner.address);

    await expect(supContracts.connect(addr1).setSupportedContractsManager(addr1.address))
      .to.be.revertedWithCustomError(supContracts, "SenderIsNotSupportedContractsManager")

    await supContracts.connect(owner).setSupportedContractsManager(addr1.address);
    expect(await supContracts.supportedContractsManager()).to.equal(addr1.address);

    const chain = 123;
    const observations = 'used to trade on this chain';

    await expect(supContracts.connect(addr1).addSupportedContract(chain, dummyAddress, observations))
      .not.to.be.reverted;
  });
});

