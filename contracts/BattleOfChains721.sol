// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.27;

import "./uERC721/ERC721Universal.sol";
import "./IBattleOfChains721.sol";

/**
 * @title BattleOfChains Main Contract for the supported Ownership Chains
 * @notice Developed and maintained by the LAOS Team and Freeverse.
 */

contract BattleOfChains721 is ERC721Universal, IBattleOfChains721 {
    constructor(
        address owner_,
        string memory baseURI_
    ) ERC721Universal(owner_, "BattleOfChains721", "BOC", baseURI_) {}

    /// @inheritdoc IBattleOfChains721
    function assignOperator(address _operator) public {
        emit AssignOperator(msg.sender, _operator);
    }
}
