const { expect } = require("chai");
const { ethers } = require("hardhat");
const { AbiCoder, keccak256 } = require("ethers");

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

  it("only contracts manager can add contracts", async function () {
    expect(await battleOfChains.supportedContractsManager()).to.equal(owner.address);
    const chain = 123;
    const observations = 'used to trade on this chain';
    await expect(battleOfChains.connect(addr1).addSupportedContract(chain, collectionAddress, observations))
      .to.be.revertedWithCustomError(battleOfChains, "SenderIsNotSupportedContractsManager")

    await expect(battleOfChains.connect(owner).addSupportedContract(chain, collectionAddress, observations))
      .not.to.be.reverted;
  });

  it("only contracts manager can add contracts", async function () {
    expect(await battleOfChains.supportedContractsManager()).to.equal(owner.address);
    const chain = 123;
    const observations = 'used to trade on this chain';
    await expect(battleOfChains.connect(addr1).addSupportedContract(chain, collectionAddress, observations))
      .to.be.revertedWithCustomError(battleOfChains, "SenderIsNotSupportedContractsManager")

    await expect(battleOfChains.connect(owner).addSupportedContract(chain, collectionAddress, observations))
      .not.to.be.reverted;
  });


  it("can set new contracts manager, who can then operate as expected", async function () {
    expect(await battleOfChains.supportedContractsManager()).to.equal(owner.address);

    await expect(battleOfChains.connect(addr1).setSupportedContractsManager(addr1.address))
      .to.be.revertedWithCustomError(battleOfChains, "SenderIsNotSupportedContractsManager")

    await battleOfChains.connect(owner).setSupportedContractsManager(addr1.address);
    expect(await battleOfChains.supportedContractsManager()).to.equal(addr1.address);

    const chain = 123;
    const observations = 'used to trade on this chain';

    await expect(battleOfChains.connect(addr1).addSupportedContract(chain, collectionAddress, observations))
      .not.to.be.reverted;
  });

  it("can set new URI manager, who can then operate as expected", async function () {
    await expect(battleOfChains.connect(addr1).setURIManager(addr1.address))
      .to.be.revertedWithCustomError(battleOfChains, "SenderIsNotURIManager")

    await battleOfChains.connect(owner).setURIManager(addr1.address);
    expect(await battleOfChains.uriManager()).to.equal(addr1.address);

    await expect(battleOfChains.connect(addr1).setMissingTypeURI("ipfs://Qmdefault"))
      .to.not.be.reverted;

    await expect(battleOfChains.connect(addr1).setTokenURIs([0, 1], ["ipfs://QmType0", "ipfs://QmType1"]))
      .to.not.be.reverted;

    await expect(battleOfChains.connect(addr1).setURIManager(owner.address))
      .to.not.be.reverted;
  });

  it("should return correct typeTokenURI for valid types", async function () {
    expect(await battleOfChains.typeTokenURI(0)).to.equal("");
    await battleOfChains.setMissingTypeURI("ipfs://Qmdefault");
    expect(await battleOfChains.typeTokenURI(0)).to.equal("ipfs://Qmdefault");
    expect(await battleOfChains.typeTokenURI(1)).to.equal("ipfs://Qmdefault");
    await battleOfChains.setTokenURIs([0, 1], ["ipfs://QmType0", "ipfs://QmType1"]);
    expect(await battleOfChains.typeTokenURI(0)).to.equal("ipfs://QmType0");
    expect(await battleOfChains.typeTokenURI(1)).to.equal("ipfs://QmType1");
    expect(await battleOfChains.typeTokenURI(2)).to.equal("ipfs://Qmdefault");
    expect(await battleOfChains.typeTokenURI(3)).to.equal("ipfs://Qmdefault");
    expect(await battleOfChains.typeTokenURI(99)).to.equal("ipfs://Qmdefault");
  });

  it("should return the correct creator address from token ID", async function () {
    const creatorAddress = await battleOfChains.creatorFromTokenId("0x123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef");
    expect(creatorAddress).to.equal("0x89abCdef0123456789AbCDEf0123456789AbCDEF");
  });

  it("user can join a chain, only once", async function () {
    expect(await battleOfChains.homeChainOf(owner)).to.equal(0);
    await battleOfChains.joinChain(homechain = 3);
    expect(await battleOfChains.homeChainOf(owner)).to.equal(homechain);
    await expect(battleOfChains.joinChain(newchain = 2))
      .to.be.revertedWithCustomError(battleOfChains, "UserAlreadyJoinedChain")
      .withArgs(owner.address, homechain);
  });

  it("joining emits the expected event", async function () {
    await expect(battleOfChains.connect(owner).joinChain(homechain = 3))
      .to.emit(battleOfChains, "JoinedChain")
      .withArgs(owner.address, homechain);
  });

  it("user cannot join null chain", async function () {
    await expect(battleOfChains.joinChain(0))
      .to.be.revertedWithCustomError(battleOfChains, "HomeChainMustBeGreaterThanZero");
  });


  it("cannot mint without specifying homeChain nor joining previously", async function () {
    await expect(battleOfChains["multichainMint(uint32)"](type = 3))
      .to.be.revertedWithCustomError(battleOfChains, "UserHasNotJoinedChainYet")
      .withArgs(owner.address);
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
    const tokenIds = [1, 2];
    const user = '0x1111111111111111111100000000000000000000';
    await expect(
      battleOfChains.connect(owner)["attack(uint256[],address,uint32,uint32)"](tokenIds, user, targetChain = 3, strategy = 52)
    )
      .to.emit(battleOfChains, "Attack")
      .withArgs(tokenIds, user, owner.address, owner.address, targetChain, strategy);
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
    await battleOfChains.joinChain(32);
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
    await battleOfChains.connect(addr1).joinChain(32);
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
    await battleOfChains.joinChain(32);
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
    await battleOfChains.joinChain(32);
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
    await battleOfChains.joinChain(sourceChain = 32);
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
  });

  it("emits ChainActionProposal event when proposeChainActionOnBehalfOf is called", async function () {
    await battleOfChains.connect(addr1).joinChain(sourceChain = 32);
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

});

