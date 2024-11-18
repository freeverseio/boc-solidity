 
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

  it("should emit SendGameTreasury event with absolute method", async function () {
    const sendTXs = [
      { recipient: addr1.address, amount: 100000 },
      { recipient: owner.address, amount: 200000 }
    ];

    await expect(battleOfChains.sendGameTreasuryAbsolute(sendTXs))
    .to.emit(battleOfChains, "SendGameTreasury")
    .withArgs(owner.address, 0, [[addr1.address, 100000],[owner.address, 200000]]);
  });

  it("should emit SendGameTreasury event with percentage method", async function () {
    const sendTXs = [
      { recipient: addr1.address, amount: 10 },
      { recipient: owner.address, amount: 20 }
    ];

    await expect(battleOfChains.sendGameTreasuryPercentage(sendTXs))
    .to.emit(battleOfChains, "SendGameTreasury")
    .withArgs(owner.address, 1, [[addr1.address, 10],[owner.address, 20]]);
  });

  it("should revert sendGameTreasuryPercentage when one inputs exceed 100", async function () {
    const sendTXs = [
      { recipient: addr1.address, amount: 0 },
      { recipient: owner.address, amount: 10001 }
    ];

    await expect(battleOfChains.sendGameTreasuryPercentage(sendTXs))
      .to.be.revertedWithCustomError(battleOfChains, "PercentageAbove100")
      .withArgs(10001);
  });

  it("should accept SendGameTreasury one inputs equal to 100", async function () {
    const sendTXs = [
      { recipient: addr1.address, amount: 0 },
      { recipient: owner.address, amount: 10000 }
    ];

    await expect(battleOfChains.sendGameTreasuryPercentage(sendTXs))
      .not.to.be.reverted;
  });

  it("should accept SendGameTreasury inputs sum to 100", async function () {
    const sendTXs = [
      { recipient: addr1.address, amount: 9999 },
      { recipient: owner.address, amount: 1 }
    ];

    await expect(battleOfChains.sendGameTreasuryPercentage(sendTXs))
      .not.to.be.reverted;
  });

  it("should revert SendGameTreasury when sum of inputs exceed 100", async function () {
    const sendTXs = [
      { recipient: addr1.address, amount: 9999 },
      { recipient: owner.address, amount: 2 }
    ];

    await expect(battleOfChains.sendGameTreasuryPercentage(sendTXs))
      .to.be.revertedWithCustomError(battleOfChains, "PercentageAbove100")
      .withArgs(10001);
  });

  it("should accept SendGameTreasury with one amount as the largest possible uint256", async function () {
    const maxUint256 = "0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff";

    const sendTXs = [
        { recipient: addr1.address, amount: 0 },
        { recipient: owner.address, amount: maxUint256 }
    ];

    await expect(battleOfChains.sendGameTreasuryAbsolute(sendTXs))
        .not.to.be.reverted;
  });

  it("does not revert even if sum overflows", async function () {
    const maxUint256 = "0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff";

    const sendTXs = [
        { recipient: addr1.address, amount: maxUint256 },
        { recipient: owner.address, amount: maxUint256 }
    ];

    await expect(battleOfChains.sendGameTreasuryAbsolute(sendTXs))
        .not.to.be.reverted;
  });
});

