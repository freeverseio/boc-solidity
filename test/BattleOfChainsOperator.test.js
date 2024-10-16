 
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
    .withArgs(owner.address, 0, [[addr1.address, 100000],[owner.address, 200000]]);
  });

  it("should emit ShareTreasury event with percentage method", async function () {
    const shareTXs = [
      { recipient: addr1.address, amount: 10 },
      { recipient: owner.address, amount: 20 }
    ];

    await expect(battleOfChains.shareTreasuryPercentage(shareTXs))
    .to.emit(battleOfChains, "ShareTreasury")
    .withArgs(owner.address, 1, [[addr1.address, 10],[owner.address, 20]]);
  });

  it("should revert ShareTreasury when inputs exceed 100", async function () {
    const shareTXs = [
      { recipient: addr1.address, amount: 1000 },
      { recipient: owner.address, amount: 1001 }
    ];

    await expect(battleOfChains.shareTreasuryPercentage(shareTXs))
      .to.be.revertedWithCustomError(battleOfChains, "IndividualPercentageAbove100")
      .withArgs(1001);
  });

  it("should revert ShareTreasury when sum of inputs exceed 100", async function () {
    const shareTXs = [
      { recipient: addr1.address, amount: 999 },
      { recipient: owner.address, amount: 2 }
    ];

    await expect(battleOfChains.shareTreasuryPercentage(shareTXs))
      .to.be.revertedWithCustomError(battleOfChains, "TotalPercentageAbove100")
      .withArgs(1001);
  });
});

