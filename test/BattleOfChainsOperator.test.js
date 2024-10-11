/* eslint-disable @typescript-eslint/no-unused-expressions */
/* eslint-disable no-undef */
/* eslint-disable @typescript-eslint/no-require-imports */
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("BattleOfChainsOperator", function () {
  let BattleOfChainsOperator, battleOfChains, owner, addr1;

  beforeEach(async function () {
    [owner, addr1] = await ethers.getSigners();
    BattleOfChainsOperator = await ethers.getContractFactory("BattleOfChainsOperator");
    battleOfChains = await BattleOfChainsOperator.deploy();
  });

  it("assignOperator emits expected event", async function () {
    await expect(battleOfChains.assignOperator(addr1.address))
      .to.emit(battleOfChains, "AssignOperator")
      .withArgs(owner.address, addr1.address);
  });
});

