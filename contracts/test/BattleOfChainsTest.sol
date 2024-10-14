// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.26;

import "../BattleOfChains.sol";

contract BattleOfChainsTest is BattleOfChains {

    constructor(address _laosCollectionAddress) BattleOfChains(_laosCollectionAddress) {}
}