// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.3;

import "./IEvolutionCollection.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Battle of Chains
/// @author LAOS Team and Freeverse

contract BattleOfChains is Ownable {

    address public collectionAddress = 0xfFfffFFFffFFFffffffFfFfe0000000000000001;
    IEvolutionCollection private collectionContract = IEvolutionCollection(collectionAddress);

    constructor() Ownable(msg.sender) {}

    function generateRandom() public view returns(uint256) {
        return uint256(blockhash(block.number - 1));
    }

    // currently only the 1st two types are supported
    function generateType(uint256 _random) public pure returns(uint256) {
        return _random % 2;
    }

    function generateSlot(uint256 _random, uint256 _type) public pure returns (uint96 _slot) {
        return uint96((_random << 3) | _type);
    }

    function presetTokenURI(uint256 _type) public pure returns (string memory) {
        if (_type == 0) return "ipfs://QmType0";
        if (_type == 1) return "ipfs://QmType1";
        // Revert with a custom error message if type is not supported
        revert("Type not supported");
    }


    // Doubts: add a _to to mint, so you can mint for other people too?

    function mint(uint256 _joinedChainId) public returns (uint256 _tokenId) {
        uint256 _random = generateRandom();
        uint256 _type = generateType(_random);
        uint96 _slot = generateSlot(_random, _type);
        return collectionContract.mintWithExternalURI(msg.sender, _slot, presetTokenURI(_type));
    }

    function mintWithExternalURI(
        address _to,
        uint96 _slot,
        string calldata _tokenURI
    ) external returns (uint256) {
        return collectionContract.mintWithExternalURI(_to, _slot, _tokenURI);
    }

}