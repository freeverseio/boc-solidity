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
    IEvolutionCollection private immutable collectionContract = IEvolutionCollection(laosCollectionAddress);
    mapping(address user => uint32 homeChain) public homeChainOfUser;

    error HomeChainMustBeGreaterThanZero();
    error UserAlreadyJoinedChain(address _user, uint32 _chain);

    event MultichainMint(
        uint256 _tokenId,
        address indexed _user, 
        uint32 indexed _type,
        uint32 indexed _homeChain
    );

    event JoinedChain(
        address indexed _user, 
        uint32 indexed _homeChain
    );

    constructor(address _laosCollectionAddress) Ownable(msg.sender) {
        laosCollectionAddress = _laosCollectionAddress;
    }

    function joinChain(uint32 _homeChain) public {
        _joinChain(_homeChain);
    }

    function _joinChain(uint32 _homeChain) private {
        if (_homeChain == 0) revert HomeChainMustBeGreaterThanZero();
        if (homeChainOfUser[msg.sender] != 0) revert UserAlreadyJoinedChain(msg.sender, homeChainOfUser[msg.sender]);
        homeChainOfUser[msg.sender] = _homeChain;
        emit JoinedChain(msg.sender, _homeChain);
    }

    function multichainMint(uint32 _homeChain, uint32 _type) public returns (uint256 _tokenId) {
        if (_homeChain == 0) revert HomeChainMustBeGreaterThanZero();
        if (homeChainOfUser[msg.sender] != 0 && homeChainOfUser[msg.sender] != _homeChain) revert UserAlreadyJoinedChain(msg.sender, homeChainOfUser[msg.sender]);

        _joinChain(_homeChain);
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