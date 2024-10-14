// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.26;

/**
 * @title IBattleOfChainsOperator Interface
 * @dev Interface for the Battle of Chains contract for ownership chains
 * @notice Developed and maintained by the LAOS Team and Freeverse.
 */

interface IBattleOfChainsOperator {
    /**
     * @notice Emitted when a user assigns an operator.
     * @param _from The user granting permission.
     * @param _operator The address on the LAOS Network receiving the permission.
     */
    event AssignOperator(address indexed _from, address indexed _operator);

    /**
     * @notice Grants permission to the specified operator address on the LAOS Network
     * to perform game actions in the Battle of Chains, such as attacks and chain action proposals.
     * @notice The ERC-721 logic remains unaffected, and all NFT trading continues on-chain.
     * @notice Permissions can be updated anytime. They can be revoked by calling this method with _operator = msg.sender.
     * @dev This method does not store any variables; it simply emits an event for off-chain processing.
     * @param _operator The address on the LAOS Network to which permission is granted.
     */
    function assignOperator(address _operator) external;
}
