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
    error UserHasNotJoinedChainYet(address _user);

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

    function multichainMint(uint32 _homeChain, uint32 _type) public returns (uint256 _tokenId) {
        _joinChainIfNeeded(_homeChain);
        return _multichainMint(_homeChain, _type);
    }

    function _joinChainIfNeeded(uint32 _homeChain) internal {
        if (_homeChain == 0) revert HomeChainMustBeGreaterThanZero();
        uint32 prevJoinedChain = homeChainOfUser[msg.sender];
        if (prevJoinedChain == 0) {
            _joinChain(_homeChain);
        } else {
            if (prevJoinedChain != _homeChain) revert UserAlreadyJoinedChain(msg.sender, prevJoinedChain);
        }
    }

    function multichainMint(uint32 _type) public returns (uint256 _tokenId) {
        uint32 _homeChain = homeChainOfUser[msg.sender];
        if (_homeChain == 0) revert UserHasNotJoinedChainYet(msg.sender);
        return _multichainMint(_homeChain, _type);
    }

    function _multichainMint(uint32 _homeChain, uint32 _type) private returns (uint256 _tokenId) {
        uint96 _slot = uint96(uint256(blockhash(block.number - 1)));
        _tokenId = collectionContract.mintWithExternalURI(msg.sender, _slot, typeTokenURI(_type));
        emit MultichainMint(_tokenId, msg.sender, _type, _homeChain);
        return _tokenId;
    }

    function _joinChain(uint32 _homeChain) private {
        if (_homeChain == 0) revert HomeChainMustBeGreaterThanZero();
        if (homeChainOfUser[msg.sender] != 0) revert UserAlreadyJoinedChain(msg.sender, homeChainOfUser[msg.sender]);
        homeChainOfUser[msg.sender] = _homeChain;
        emit JoinedChain(msg.sender, _homeChain);
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