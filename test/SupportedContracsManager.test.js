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

  it("should add a supported contract correctly", async function () {
    const chainId = 123;
    const contractAddress = "0x0000000000000000000000000000000000000001";
    const observations = "Initial supported contract";

    await supContracts.addSupportedContract(chainId, contractAddress, observations);

    const addedContract = await supContracts.supportedContracts(0);

    expect(addedContract.chain).to.equal(chainId);
    expect(addedContract.contractAddress).to.equal(contractAddress);
    expect(addedContract.observations).to.equal(observations);
  });

  it("should add multiple supported contracts", async function () {
    const contractsToAdd = [
      { chainId: 123, address: "0x0000000000000000000000000000000000000003", observations: "First contract" },
      { chainId: 456, address: "0x0000000000000000000000000000000000000004", observations: "Second contract" },
    ];

    for (const contract of contractsToAdd) {
      await supContracts.addSupportedContract(
        contract.chainId,
        contract.address,
        contract.observations
      );
    }

    const firstContract = await supContracts.supportedContracts(0);
    const secondContract = await supContracts.supportedContracts(1);

    expect(firstContract.chain).to.equal(contractsToAdd[0].chainId);
    expect(firstContract.contractAddress).to.equal(contractsToAdd[0].address);
    expect(firstContract.observations).to.equal(contractsToAdd[0].observations);

    expect(secondContract.chain).to.equal(contractsToAdd[1].chainId);
    expect(secondContract.contractAddress).to.equal(contractsToAdd[1].address);
    expect(secondContract.observations).to.equal(contractsToAdd[1].observations);
    
    const allContracts = await supContracts.allSupportedContracts();
    expect(allContracts[0].chain).to.equal(contractsToAdd[0].chainId);
    expect(allContracts[0].contractAddress).to.equal(contractsToAdd[0].address);
    expect(allContracts[0].observations).to.equal(contractsToAdd[0].observations);

    expect(allContracts[1].chain).to.equal(contractsToAdd[1].chainId);
    expect(allContracts[1].contractAddress).to.equal(contractsToAdd[1].address);
    expect(allContracts[1].observations).to.equal(contractsToAdd[1].observations);
    

  });  

});

