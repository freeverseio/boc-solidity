// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.27;

/**
 * @title IBattleOfChainsAlliance Interface
 * @dev A general alliance can be an arbitrarily complex contract
 * @dev It is strongly recommended that alliances implement the minimal logic
 * @dev that this interface contains: assigning operators on LAOS, and responding 
 * @dev to alliance name and alliance description.
 * @notice Developed and maintained by the LAOS Team and Freeverse.
 */

interface IBattleOfChainsAlliance {
    /**
     * @notice Returns the name of the alliance
     * @param name the name of the alliance
     */
    function allianceName() external returns (string memory name);

    /**
     * @notice Returns a human readable description of the alliance
     * @param description the name of the alliance
     */
    function allianceDescription() external returns (string memory description);
}
