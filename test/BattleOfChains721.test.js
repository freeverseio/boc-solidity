/* eslint-disable @typescript-eslint/no-unused-expressions */
/* eslint-disable no-undef */
/* eslint-disable @typescript-eslint/no-require-imports */
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("BattleOfChains721", function () {
  let BattleOfChains721, battleOfChains, owner, addr1;
  const baseURI = 'dummyBaseURI';
  const name = 'BattleOfChains721';
  const symbol = 'BOC';

  beforeEach(async function () {
    [owner, addr1] = await ethers.getSigners();
    BattleOfChains721 = await ethers.getContractFactory("BattleOfChains721");
    battleOfChains = await BattleOfChains721.deploy(owner.address, baseURI);
  });

  it("deploy sets storage as expected", async function () {
    expect(await battleOfChains.owner()).to.equal(owner.address);
    expect(await battleOfChains.baseURI()).to.equal(baseURI);
    expect(await battleOfChains.name()).to.equal(name);
    expect(await battleOfChains.symbol()).to.equal(symbol);
  });

});

