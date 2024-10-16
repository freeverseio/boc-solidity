 
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

  it("should emit ShareTreasury event with absolute method", async function () {
    const shareTXs = [
      { recipient: addr1.address, amount: 100000 },
      { recipient: owner.address, amount: 200000 }
    ];

    await expect(battleOfChains.shareTreasuryAbsolute(shareTXs))
    .to.emit(battleOfChains, "ShareTreasury")
    .withArgs(
      owner.address,
      0, // ABSOLUTE method (enum value)
      [[addr1.address, 100000],[owner.address, 200000]]
    );
  });

});

