// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.20;

import "./uERC721/ERC721Universal.sol";
import "./BattleOfChainsOperator.sol";

/**
 * @title BattleOfChains Main Contract for the supported Ownership Chains
 * @notice Developed and maintained by the LAOS Team and Freeverse.
 */

contract BattleOfChains721 is ERC721Universal, BattleOfChainsOperator {
    constructor(
        address owner_,
        string memory baseURI_
    ) ERC721Universal(owner_, "BattleOfChains721", "BOC", baseURI_) {}
}
