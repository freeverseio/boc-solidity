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

    function mintWithExternalURI(
        address _to,
        uint96 _slot,
        string calldata _tokenURI
    ) external returns (uint256) {
        return collectionContract.mintWithExternalURI(_to, _slot, _tokenURI);
    }

}