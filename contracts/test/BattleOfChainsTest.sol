// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.20;

import "../BattleOfChains.sol";

contract BattleOfChainsTest is BattleOfChains {

    uint32 private constant NULL_CHAIN = 0;

    constructor(address _laosCollectionAddress) BattleOfChains(_laosCollectionAddress) {}

    function emitMultichainEvent(uint256 _tokenId, address _user, uint256 _type, uint32 _homeChain) public {
        emit MultichainMint(_tokenId, _user, _type, _homeChain);
    }

    function multichainMintTest(uint256 _type) public returns (uint256 _tokenId) {
        if (!isTypeDefined(_type)) revert TokenURIForTypeNotDefined(_type);
        uint32 _homeChain = homeChainOf[msg.sender];
        if (_homeChain == NULL_CHAIN) revert UserHasNotJoinedChainYet(msg.sender);
        uint96 _slot = uint96(uint256(blockhash(block.number - 1)));
        // _tokenId = collectionContract.mintWithExternalURI(msg.sender, _slot, tokenURIForType(_type));
        _tokenId = 1234578123453234;
        emit MultichainMint(_tokenId, msg.sender, _type, _homeChain);
        return _tokenId;
    }
}