// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.3;

import "./IEvolutionCollection.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Battle of Chains
/// @author LAOS Team and Freeverse

// TODOS:
// add events

contract BattleOfChains is Ownable {

    address public laosCollectionAddress;
    IEvolutionCollection private collectionContract = IEvolutionCollection(laosCollectionAddress);

    event MultichainMint(
        uint256 _tokenId,
        address indexed _creator, 
        uint32 indexed _type,
        uint32 indexed _homeChain
    );

    constructor(address _laosCollectionAddress) Ownable(msg.sender) {
        laosCollectionAddress = _laosCollectionAddress;
    }

    function mint(uint32 _homeChain, uint32 _type) public returns (uint256 _tokenId) {
        uint96 _slot = uint96(uint256(blockhash(block.number - 1)));
        _tokenId = collectionContract.mintWithExternalURI(msg.sender, _slot, typeTokenURI(_type));
        emit MultichainMint(_tokenId, msg.sender, _type, _homeChain);
        return _tokenId;
    }

    function typeTokenURI(uint256 _type) public pure returns (string memory) {
        if (_type == 0) return "ipfs://QmType0";
        if (_type == 1) return "ipfs://QmType1";
        return "ipfs://Qmdefault";
    }

    function creatorFromTokenId(uint256 _tokenId) public pure returns(address) {
        return address(uint160(_tokenId));
    }
}