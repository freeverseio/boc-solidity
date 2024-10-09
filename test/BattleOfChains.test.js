const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("BattleOfChains", function () {
  let BattleOfChains, battleOfChains, owner, addr1;
  const collectionAddress = "0xfFfffFFFffFFFffffffFfFfe0000000000000001";

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
    expect(await battleOfChains.homeChainOfUser(owner)).to.equal(0);
    await battleOfChains.joinChain(homechain = 3);
    expect(await battleOfChains.homeChainOfUser(owner)).to.equal(homechain);
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


  it("cannot mint with null homechain", async function () {
    await expect(battleOfChains["multichainMint(uint32,uint32)"](homechain = 0, type = 3))
      .to.be.revertedWithCustomError(battleOfChains, "HomeChainMustBeGreaterThanZero");
  });

  it("cannot mint using homechain different from previously joined chain", async function () {
    await battleOfChains.joinChain(homechain = 1);
    await expect(battleOfChains["multichainMint(uint32,uint32)"](newhomechain = 2, type = 3))
      .to.be.revertedWithCustomError(battleOfChains, "UserAlreadyJoinedChain")
      .withArgs(owner.address, homechain);
  });

  it("cannot mint without specifying homeChain nor joining previously", async function () {
    await expect(battleOfChains["multichainMint(uint32)"](type = 3))
      .to.be.revertedWithCustomError(battleOfChains, "UserHasNotJoinedChainYet")
      .withArgs(owner.address);
  });

  it("joinChainIfNeeded fails if previously joined a different chain", async function () {
    await battleOfChains.joinChain(homechain = 1);
    await expect(battleOfChains.joinChainIfNeeded(newhomechain = 2))
      .to.be.revertedWithCustomError(battleOfChains, "UserAlreadyJoinedChain")
      .withArgs(owner.address, homechain);
  });

  it("joinChainIfNeeded succeeds if previously joined the same chain", async function () {
    await battleOfChains.joinChain(homechain = 1);
    await expect(battleOfChains.joinChainIfNeeded(homechain))
      .to.not.be.reverted;
  });

  it("joinChainIfNeeded succeeds if previously did not join any chain", async function () {
    expect(await battleOfChains.homeChainOfUser(owner)).to.equal(0);
    await expect(battleOfChains.joinChainIfNeeded(homechain = 3))
      .to.not.be.reverted;
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

  it("attack (x,y) emits expected event", async function () {
    const tokenIds = [1, 2];
    await expect(
      battleOfChains.connect(owner)["attack(uint256[],uint256,uint256,uint32,uint32)"](tokenIds, x = 5, y = 6, targetChain = 3, strategy = 52)
    )
      .to.emit(battleOfChains, "Attack")
      .withArgs(tokenIds, x, y, owner.address, owner.address, targetChain, strategy);
  });
  
  it("attack address emits expected event", async function () {
    const tokenIds = [1, 2];
    const user = '0x1111111111111111111100000000000000000000';
    const x = '80595054640975278313745';
    const y = '0';
    await expect(
      battleOfChains.connect(owner)["attack(uint256[],address,uint32,uint32)"](tokenIds, user, targetChain = 3, strategy = 52)
    )
      .to.emit(battleOfChains, "Attack")
      .withArgs(tokenIds, x, y, owner.address, owner.address, targetChain, strategy);
  });

  it("attack (x,y) emits expected event", async function () {
    const tokenIds = [1, 2];
    const delegatedUser = addr1.address;
    await expect(
      battleOfChains.connect(owner)["attackOnBehalfOf(uint256[],uint256,uint256,uint32,uint32,address)"](tokenIds, x = 5, y = 6, targetChain = 3, strategy = 52, delegatedUser)
    )
      .to.emit(battleOfChains, "Attack")
      .withArgs(tokenIds, x, y, owner.address, delegatedUser, targetChain, strategy);
  });

  it("attack address emits expected event", async function () {
    const tokenIds = [1, 2];
    const user = '0x1111111111111111111100000000000000000000';
    const x = '80595054640975278313745';
    const y = '0';
    const delegatedUser = addr1.address;
    await expect(
      battleOfChains.connect(owner)["attackOnBehalfOf(uint256[],address,uint32,uint32,address)"](tokenIds, user, targetChain = 3, strategy = 52, delegatedUser)
    )
      .to.emit(battleOfChains, "Attack")
      .withArgs(tokenIds, x, y, owner.address, delegatedUser, targetChain, strategy);
  });

});

