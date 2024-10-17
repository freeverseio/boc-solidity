/* eslint-disable @typescript-eslint/no-unused-expressions */
/* eslint-disable no-undef */
/* eslint-disable @typescript-eslint/no-require-imports */
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("BattleOfChains", function () {
  let BattleOfChains, battleOfChains, owner, addr1;
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
    BattleOfChains = await ethers.getContractFactory("BattleOfChainsTest");
    battleOfChains = await BattleOfChains.deploy(collectionAddress);
  });

  it("collection contract is correctly set on deploy", async function () {
    expect(await battleOfChains.collectionContract()).to.equal(collectionAddress);
  });

  it("should return the correct creator address from token ID", async function () {
    const creatorAddress = await battleOfChains.creatorFromTokenId("0x123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef");
    expect(creatorAddress).to.equal("0x89abCdef0123456789AbCDEf0123456789AbCDEF");
  });

  it("user can join a chain, only once", async function () {
    expect(await battleOfChains.homeChainOf(owner)).to.equal(0);
    await battleOfChains.joinChain(homechain = 3, nickname = 'rambo');
    expect(await battleOfChains.homeChainOf(owner)).to.equal(homechain);
    await expect(battleOfChains.joinChain(newchain = 2, nickname = 'rambo'))
      .to.be.revertedWithCustomError(battleOfChains, "UserAlreadyJoinedChain")
      .withArgs(owner.address, homechain);
  });

  it("joining emits the expected event", async function () {
    const eventJoinchainTopic0 = "0xb76888af89162640d1f93bf6507c4dffd2cee8cbccdffff114d8057a6e679b37";
    const tx = await battleOfChains.connect(owner).joinChain(homechain = 3, nickname = 'rambo');
    await expect(tx)
      .to.emit(battleOfChains, "JoinedChain")
      .withArgs(owner.address, homechain, nickname);
    const receipt = await tx.wait();
    expect(receipt.logs[0].topics[0]).to.equal(eventJoinchainTopic0);
  });

  it("user cannot join null chain", async function () {
    await expect(battleOfChains.joinChain(0, nickname = 'rambo'))
      .to.be.revertedWithCustomError(battleOfChains, "HomeChainMustBeGreaterThanZero");
  });

  it("cannot mint a type not previously defined", async function () {
    await expect(battleOfChains.multichainMint(type = 1))
      .to.be.revertedWithCustomError(battleOfChains, "TokenURIForTypeNotDefined")
      .withArgs(type);
  });

  it("cannot mint without specifying homeChain nor joining previously", async function () {
    await battleOfChains.addTokenURIs(["ipfs://QmType0", "ipfs://QmType1"]);
    await expect(battleOfChains.multichainMint(type = 1))
      .to.be.revertedWithCustomError(battleOfChains, "UserHasNotJoinedChainYet")
      .withArgs(owner.address);
  });

  it("MultichainMint produces expected event", async function () {
    const eventMintTopic0 = "0xb189b714f887ae698b140ddf7c6e07d5df979975e4675f19700ad7149a2e1ca3";
    const tx = await battleOfChains.emitMultichainEvent(tokenId = '123', user = addr1.address, type = 1, homeChain = 232); 
    await expect(tx)
      .to.emit(battleOfChains, "MultichainMint")
      .withArgs(tokenId, user, type, homeChain);

    const receipt = await tx.wait();
    expect(receipt.logs[0].topics[0]).to.equal(eventMintTopic0);
  });

  it("MultichainMintTest succeeds on correct inputs", async function () {
    const eventMintTopic0 = "0xb189b714f887ae698b140ddf7c6e07d5df979975e4675f19700ad7149a2e1ca3";
    await battleOfChains.addTokenURIs(["ipfs://QmType0", "ipfs://QmType1"]);
    await battleOfChains.joinChain(homeChain = 1, nickname = 'rambo');
    const tx = await battleOfChains.multichainMintTest(type = 1); 
    await expect(tx)
      .to.emit(battleOfChains, "MultichainMint")
      .withArgs("1234578123453234", owner.address, type, homeChain);

    const receipt = await tx.wait();
    expect(receipt.logs[0].topics[0]).to.equal(eventMintTopic0);
  });

  it("getCoordinates works as expected", async function () {
    let coordinates;
    coordinates = await battleOfChains.coordinatesOf('0x1111111111111111111100000000000000000000');
    expect(coordinates._x.toString()).to.equal('80595054640975278313745');
    expect(coordinates._y.toString()).to.equal('0');

    coordinates = await battleOfChains.coordinatesOf('0x0000000000000000000011111111111111111111');
    expect(coordinates._y.toString()).to.equal('80595054640975278313745');
    expect(coordinates._x.toString()).to.equal('0');
  });

  it("attack address emits expected event", async function () {
    const eventAttackTopic0 = "0x275ad433213dc8c15bff507f1e7f3758b0b460a5d55a44411ed2d816d90dfdc4";
    const tokenIds = [1, 2];
    const user = '0x1111111111111111111100000000000000000000';
    const tx = await battleOfChains.connect(owner)["attack(uint256[],address,uint32,uint32)"](tokenIds, user, targetChain = 3, strategy = 52);
    await expect(tx)
      .to.emit(battleOfChains, "Attack")
      .withArgs(tokenIds, user, owner.address, owner.address, targetChain, strategy);

    const receipt = await tx.wait();
    expect(receipt.logs[0].topics[0]).to.equal(eventAttackTopic0);
  });

  it("attack address emits expected event", async function () {
    const tokenIds = [1, 2];
    const user = '0x1111111111111111111100000000000000000000';
    const delegatedUser = addr1.address;
    await expect(
      battleOfChains.connect(owner)["attackOnBehalfOf(uint256[],address,uint32,uint32,address)"](tokenIds, user, targetChain = 3, strategy = 52, delegatedUser)
    )
      .to.emit(battleOfChains, "Attack")
      .withArgs(tokenIds, user, owner.address, delegatedUser, targetChain, strategy);
  });

  it("areChainActionInputsCorrect should return true for valid defend", async function () {
    expect(
      await battleOfChains.areChainActionInputsCorrect(
        {
          targetChain: 0,
          actionType: ChainActionType.DEFEND,
          attackAddress: nullAddress,
          attackArea: Attack_Area.NULL,
        }
    )).to.be.true;
  });

  it("areChainActionInputsCorrect should return true for valid improve", async function () {
    expect(
      await battleOfChains.areChainActionInputsCorrect(
        {
          targetChain: 0,
          actionType: ChainActionType.IMPROVE,
          attackAddress: nullAddress,
          attackArea: Attack_Area.NULL,
        }
    )).to.be.true;
  });

  it("areChainActionInputsCorrect should return false for wrong defend", async function () {
    expect(
      await battleOfChains.areChainActionInputsCorrect(
        {
          targetChain: 0,
          actionType: ChainActionType.DEFEND,
          attackAddress: collectionAddress,
          attackArea: Attack_Area.NULL,
        }
    )).to.be.false;
    expect(
      await battleOfChains.areChainActionInputsCorrect(
        {
          targetChain: 0,
          actionType: ChainActionType.DEFEND,
          attackAddress: nullAddress,
          attackArea: Attack_Area.NORTH,
        }
    )).to.be.false;
    expect(
      await battleOfChains.areChainActionInputsCorrect(
        {
          targetChain: 1,
          actionType: ChainActionType.DEFEND,
          attackAddress: nullAddress,
          attackArea: Attack_Area.NULL,
        }
    )).to.be.false;
  });

  it("areChainActionInputsCorrect should return false for wrong improve", async function () {
    expect(
      await battleOfChains.areChainActionInputsCorrect(
        {
          targetChain: 0,
          actionType: ChainActionType.IMPROVE,
          attackAddress: collectionAddress,
          attackArea: Attack_Area.NULL,
        }
    )).to.be.false;
    expect(
      await battleOfChains.areChainActionInputsCorrect(
        {
          targetChain: 0,
          actionType: ChainActionType.IMPROVE,
          attackAddress: nullAddress,
          attackArea: Attack_Area.NORTH,
        }
    )).to.be.false;    expect(
    await battleOfChains.areChainActionInputsCorrect(
        {
          targetChain: 1,
          actionType: ChainActionType.IMPROVE,
          attackAddress: nullAddress,
          attackArea: Attack_Area.NULL,
        }
    )).to.be.false;
  });

  it("areChainActionInputsCorrect should return true for valid attack_address", async function () {
    expect(
      await battleOfChains.areChainActionInputsCorrect(
        {
          targetChain: 12,
          actionType: ChainActionType.ATTACK_ADDRESS,
          attackAddress: collectionAddress,
          attackArea: Attack_Area.NULL,
        }
    )).to.be.true;
  });

  it("areChainActionInputsCorrect should return true for valid attack_area", async function () {
    expect(
      await battleOfChains.areChainActionInputsCorrect(
        {
          targetChain: 41,
          actionType: ChainActionType.ATTACK_AREA,
          attackAddress: nullAddress,
          attackArea: Attack_Area.NORTH,
        }
    )).to.be.true;
  });

  it("areChainActionInputsCorrect should return false for wrong attack_address", async function () {
    expect(
      await battleOfChains.areChainActionInputsCorrect(
        {
          targetChain: 12,
          actionType: ChainActionType.ATTACK_ADDRESS,
          attackAddress: nullAddress,
          attackArea: Attack_Area.NULL,
        }
    )).to.be.false;
    expect(
      await battleOfChains.areChainActionInputsCorrect(
        {
          targetChain: 12,
          actionType: ChainActionType.ATTACK_ADDRESS,
          attackAddress: collectionAddress,
          attackArea: Attack_Area.NORTH,
        }
    )).to.be.false;
    expect(
      await battleOfChains.areChainActionInputsCorrect(
        {
          targetChain: 0,
          actionType: ChainActionType.ATTACK_ADDRESS,
          attackAddress: collectionAddress,
          attackArea: Attack_Area.NULL,
        }
    )).to.be.false;
  });

  it("areChainActionInputsCorrect should return false for wrong attack_area", async function () {
    expect(
      await battleOfChains.areChainActionInputsCorrect(
        {
          targetChain: 12,
          actionType: ChainActionType.ATTACK_AREA,
          attackAddress: collectionAddress,
          attackArea: Attack_Area.NORTH,
        }
    )).to.be.false;
    expect(
      await battleOfChains.areChainActionInputsCorrect(
        {
          targetChain: 12,
          actionType: ChainActionType.ATTACK_AREA,
          attackAddress: nullAddress,
          attackArea: Attack_Area.NULL,
        }
    )).to.be.false;
    expect(
      await battleOfChains.areChainActionInputsCorrect(
        {
          targetChain: 0,
          actionType: ChainActionType.ATTACK_AREA,
          attackAddress: nullAddress,
          attackArea: Attack_Area.NORTH,
        }
    )).to.be.false;
  });

  it("proposeChainAction fails if user has not joined yet", async function () {
    expect(await battleOfChains.hasHomeChain(owner)).to.be.false;
    await expect(battleOfChains.proposeChainAction(
      {
        targetChain: 0,
        actionType: ChainActionType.DEFEND,
        attackAddress: nullAddress,
        attackArea: Attack_Area.NULL,
      },
      "dummy comment"
    )).to.be.revertedWithCustomError(battleOfChains, "UserHasNotJoinedChainYet");
    await battleOfChains.joinChain(32, nickname = 'rambo');
    await expect(battleOfChains.proposeChainAction(
      {
        targetChain: 0,
        actionType: ChainActionType.DEFEND,
        attackAddress: nullAddress,
        attackArea: Attack_Area.NULL,
      },
      "dummy comment"
    )).not.to.be.reverted;
  });

  it("proposeChainActionOnBehalfOf fails if user has not joined yet", async function () {
    expect(await battleOfChains.hasHomeChain(addr1)).to.be.false;
    await expect(battleOfChains.proposeChainActionOnBehalfOf(
      addr1.address,
      {
        targetChain: 0,
        actionType: ChainActionType.DEFEND,
        attackAddress: nullAddress,
        attackArea: Attack_Area.NULL,
      },
      "dummy comment"
    )).to.be.revertedWithCustomError(battleOfChains, "UserHasNotJoinedChainYet");
    await battleOfChains.connect(addr1).joinChain(32, nickname = 'rambo');
    await expect(battleOfChains.proposeChainActionOnBehalfOf(
      addr1.address,
      {
        targetChain: 0,
        actionType: ChainActionType.DEFEND,
        attackAddress: nullAddress,
        attackArea: Attack_Area.NULL,
      },
      "dummy comment"
    )).not.to.be.reverted;
  });

  it("proposeChainAction fails on wrong inputs", async function () {
    await battleOfChains.joinChain(32, nickname = 'rambo');
    await expect(battleOfChains.proposeChainAction(
      {
        targetChain: 0,
        actionType: ChainActionType.DEFEND,
        attackAddress: collectionAddress,
        attackArea: Attack_Area.NORTH,
      },
      "dummy comment"
    )).to.be.revertedWithCustomError(battleOfChains, "IncorrectAttackInput")
    await expect(battleOfChains.proposeChainAction(
      {
        targetChain: 0,
        actionType: ChainActionType.ATTACK_ADDRESS,
        attackAddress: nullAddress,
        attackArea: Attack_Area.NULL,
      },
      "dummy comment"
    )).to.be.revertedWithCustomError(battleOfChains, "IncorrectAttackInput")
  });

  it("proposeChainAction succeeds on correct inputs", async function () {
    await battleOfChains.joinChain(32, nickname = 'rambo');
    await expect(battleOfChains.proposeChainAction(
      {
        targetChain: 0,
        actionType: ChainActionType.DEFEND,
        attackAddress: nullAddress,
        attackArea: Attack_Area.NULL,
      },
      "dummy comment"
    )).not.to.be.reverted;
    await expect(battleOfChains.proposeChainAction(
      {
        targetChain: 12,
        actionType: ChainActionType.ATTACK_ADDRESS,
        attackAddress: collectionAddress,
        attackArea: Attack_Area.NULL,
      },
      "dummy comment"
    )).not.to.be.reverted;
  });

  it("emits ChainActionProposal event when proposeChainAction is called", async function () {
    const eventChainActionTopic0 = "0x8747b87ceb2b2f1164eca74f645e359271ec95927021b6ff6470b000a5693f03";
    await battleOfChains.joinChain(sourceChain = 32, nickname = 'rambo');
    const _targetChain = 0;
    const chainAction = {
      targetChain: _targetChain,
      actionType: ChainActionType.DEFEND,
      attackArea: Attack_Area.NULL,
      attackAddress: nullAddress,
    };
    const comment = "dummy comment";

    const tx = await battleOfChains.proposeChainAction(chainAction, comment);

    await expect(tx)
      .to.emit(battleOfChains, "ChainActionProposal")
      .withArgs(
        owner.address,
        owner.address,
        sourceChain,
        [_targetChain, chainAction.actionType, chainAction.attackArea, chainAction.attackAddress],
        comment,
      );

      const receipt = await tx.wait();
      expect(receipt.logs[0].topics[0]).to.equal(eventChainActionTopic0);
  
  });

  it("emits ChainActionProposal event when proposeChainActionOnBehalfOf is called", async function () {
    await battleOfChains.connect(addr1).joinChain(sourceChain = 32, nickname = 'rambo');
    const _targetChain = 0;
    const chainAction = {
      targetChain: 0,
      actionType: ChainActionType.DEFEND,
      attackArea: Attack_Area.NULL,
      attackAddress: nullAddress,
    };
    const comment = "dummy comment";

    const tx = await battleOfChains.proposeChainActionOnBehalfOf(addr1.address, chainAction, comment);

    await expect(tx)
      .to.emit(battleOfChains, "ChainActionProposal")
      .withArgs(
        owner.address,
        addr1.address,
        sourceChain,
        [_targetChain, chainAction.actionType, chainAction.attackArea, chainAction.attackAddress],
        comment,
      );
  });

  it("upgrade emits expected event", async function () {
    await expect(
      battleOfChains.upgrade(chain = 432, tokenId = 312312)
    )
      .to.emit(battleOfChains, "Upgrade")
      .withArgs(owner.address, owner.address, chain, tokenId);
  });

  it("upgradeOnBehalfOf emits expected event", async function () {
    await expect(
      battleOfChains.upgradeOnBehalfOf(addr1.address, chain = 432, tokenId = 312312)
    )
      .to.emit(battleOfChains, "Upgrade")
      .withArgs(owner.address, addr1.address, chain, tokenId);
  });

});

