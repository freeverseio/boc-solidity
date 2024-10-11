// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.27;

import "./IBattleOfChainsOperator.sol";

/**
 * @title BattleOfChains Contract for Assigning Operators on the LAOS Network
 * @dev Allows any address to emit an event indicating the intention to grant
 * permission to a specified LAOS Network operator address for performing game actions in
 * the Battle of Chains, such as attacks and chain action proposals.
 * @dev This does not affect the ERC-721 logic; all NFT trading remains
 * on-chain within this contract.
 * @notice Permissions granted to an operator can be updated or revoked.
 * @notice Developed and maintained by the LAOS Team and Freeverse.
 */


contract BattleOfChainsOperator is IBattleOfChainsOperator {
    /// @inheritdoc IBattleOfChainsOperator
    function assignOperator(address _operator) public {
        emit AssignOperator(msg.sender, _operator);
    }
}
