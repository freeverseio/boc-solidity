// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.26;

import "../BattleOfChains.sol";

contract BattleOfChainsTest is BattleOfChains {

    constructor(address _laosCollectionAddress) BattleOfChains(_laosCollectionAddress) {}

    function emitMultichainEvent(uint256 _tokenId, address _user, uint256 _type, uint32 _homeChain) public {
        emit MultichainMint(_tokenId, _user, _type, _homeChain);
    }
}