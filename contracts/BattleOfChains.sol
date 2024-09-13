// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.3;

import "./IEvolutionCollection.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Battle of Chains
/// @author LAOS Team and Freeverse

// TODOS:
// add events
// consider a mintTo, so you can mint for other people too

contract BattleOfChains is Ownable {

    address public constant COLLECTION_ADDRESS = 0xfFfffFFFffFFFffffffFfFfe0000000000000001;
    IEvolutionCollection private collectionContract = IEvolutionCollection(COLLECTION_ADDRESS);

    constructor() Ownable(msg.sender) {}

    function generateRandom() public view returns(uint256) {
        return uint256(blockhash(block.number - 1));
    }

    // currently only the 1st two types are supported
    function generateType(uint256 _random) public pure returns(uint256) {
        return _random % 2;
    }

    function generateSlot(uint256 _random, uint256 _type, uint32 _joinedChainId) public pure returns (uint96 _slot) {
        return uint96((_random << 35) | uint256(_joinedChainId) << 3 | _type);
    }

    function presetTokenURI(uint256 _type) public pure returns (string memory) {
        if (_type == 0) return "ipfs://QmType0";
        if (_type == 1) return "ipfs://QmType1";
        // Revert with a custom error message if type is not supported
        revert("Type not supported");
    }

    function typeFromTokenId(uint256 _tokenId) public pure returns(uint256) {
        return (_tokenId >> 160) & 0x7;
    }

    function chainIdFromTokenId(uint256 _tokenId) public pure returns(uint256) {
        return (_tokenId >> 163) & 0xFFFFFFFF;
    }

    function creatorFromTokenId(uint256 _tokenId) public pure returns(address) {
        return address(uint160(_tokenId));
    }

    function mint(uint32 _joinedChainId) public returns (uint256 _tokenId) {
        uint256 _random = generateRandom();
        uint256 _type = generateType(_random);
        uint96 _slot = generateSlot(_random, _type, _joinedChainId);
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