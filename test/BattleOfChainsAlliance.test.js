 
/* eslint-disable no-undef */
/* eslint-disable @typescript-eslint/no-require-imports */
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("BattleOfChainsAlliance", function () {
  let BattleOfChainsAlliance, battleOfChains, owner, addr1;
  const allianceName = 'City of 0xsteros';
  const description = 'We attack as often as possible and equally share what is earned in battle';

  beforeEach(async function () {
    [owner, addr1] = await ethers.getSigners();
    BattleOfChainsAlliance = await ethers.getContractFactory("BattleOfChainsAlliance");
    battleOfChains = await BattleOfChainsAlliance.deploy(allianceName, description);
  });

  it("deploy sets storage as expected", async function () {
    expect(await battleOfChains.allianceName()).to.equal(allianceName);
    expect(await battleOfChains.allianceDescription()).to.equal(description);
  });

  it("assignOperator emits expected event", async function () {
    await expect(battleOfChains.assignOperator(addr1.address))
      .to.emit(battleOfChains, "AssignOperator")
      .withArgs(owner.address, addr1.address);
  });
});

