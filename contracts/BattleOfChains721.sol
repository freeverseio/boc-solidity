// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.27;

import "./uERC721/ERC721Universal.sol";

/// @title Battle of Chains
/// @author LAOS Team and Freeverse

// TODOS:

contract BattleOfChains721 is ERC721Universal {

    constructor(
        address owner_,
        string memory baseURI_
    ) ERC721Universal(owner_, "BattleOfChains721", "BOC", baseURI_) {}

    function attack(uint256 _tokenId, uint32 _targetChainId, uint32 _x, uint32 _y) public {
        require(_msgSender() == ownerOf(_tokenId), "sender not authorized to attack with this token");
        address _to = address(uint160(uint160(_targetChainId) << 64) | (uint160(_x) << 32) | uint160(_y));
        _update(_to, _tokenId, _msgSender());
    }

}