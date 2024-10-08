// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.3;

import "../BattleOfChains.sol";

contract BattleOfChainsTest is BattleOfChains {

    constructor(address _laosCollectionAddress) BattleOfChains(msg.sender) {}

    function joinChainIfNeeded(uint32 _homeChain) public {
        _joinChainIfNeeded(_homeChain);
    }
}