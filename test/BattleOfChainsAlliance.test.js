 
/* eslint-disable no-undef */
/* eslint-disable @typescript-eslint/no-require-imports */
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("BattleOfChainsAlliance", function () {
  let BattleOfChains721, battleOfChains721, BattleOfChainsAlliance, battleOfChainsAlliance, owner, addr1;
  const allianceName = 'City of 0xsteros';
  const description = 'We attack as often as possible and equally share what is earned in battle';
  const baseURI = 'dummyBaseURI';

  beforeEach(async function () {
    [owner, addr1] = await ethers.getSigners();
    BattleOfChains721 = await ethers.getContractFactory("BattleOfChains721");
    battleOfChains721 = await BattleOfChains721.deploy(owner.address, baseURI);
    BattleOfChainsAlliance = await ethers.getContractFactory("BattleOfChainsAlliance");
    battleOfChainsAlliance = await BattleOfChainsAlliance.deploy(allianceName, description, battleOfChains721.getAddress());
  });

  it("deploy sets storage as expected", async function () {
    expect(await battleOfChainsAlliance.allianceName()).to.equal(allianceName);
    expect(await battleOfChainsAlliance.allianceDescription()).to.equal(description);
  });

  it("assignOperator emits expected event, with emitter = alliance contract address", async function () {
    await expect(battleOfChainsAlliance.assignOperator(addr1.address))
      .to.emit(battleOfChains721, "AssignOperator")
      .withArgs(battleOfChainsAlliance.getAddress(), addr1.address);
  });
});

