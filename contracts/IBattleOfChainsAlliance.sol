// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.27;

/**
 * @title IBattleOfChainsOperator Interface
 * @dev Interface for the Battle of Chains contract for ownership chains
 * @notice Developed and maintained by the LAOS Team and Freeverse.
 */

interface IBattleOfChainsAlliance {
    /**
     * @notice Grants permissions to the provide operator address on the LAOS Network to perform
     * @notice game actions in the Battle of Chains game, such as attack, chain action proposals, etc.
     * @notice Note that the entire 721 logic remains unaffectd by this assignment.
     * @notice In particular, trading of all NFTs remains on-chain in this chain and contract.
     * @notice The granted permission can be changed as many times as desired.
     * @notice The granted permission can be revoked by simple calling this method with _operator = msg.sender.
     * @dev This method needs not store any variable. It just emits the event, for offchain processing.
     * @param name the name of the alliance
     */
    function allianceName() external returns (string memory name);

    /**
     * @notice Grants permissions to the provide operator address on the LAOS Network to perform
     * @notice game actions in the Battle of Chains game, such as attack, chain action proposals, etc.
     * @notice Note that the entire 721 logic remains unaffectd by this assignment.
     * @notice In particular, trading of all NFTs remains on-chain in this chain and contract.
     * @notice The granted permission can be changed as many times as desired.
     * @notice The granted permission can be revoked by simple calling this method with _operator = msg.sender.
     * @dev This method needs not store any variable. It just emits the event, for offchain processing.
     * @param description the name of the alliance
     */
    function allianceDescription() external returns (string memory description);
}
