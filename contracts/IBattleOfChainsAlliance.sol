// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.20;

import './IBattleOfChainsOperator.sol';

/**
 * @title IBattleOfChainsAlliance Interface
 * @dev Defines the minimal logic for alliances in the Battle of Chains ecosystem.
 * @dev Developers of alliance contracts are adviced to implement the minimal logic
 * @dev described in this interface, which allows the alliance to
 * @dev assign an operator on LAOS, and to respond to alliance name and alliance description.
 * @notice Developed and maintained by the LAOS Team and Freeverse.
 */

interface IBattleOfChainsAlliance is IBattleOfChainsOperator {
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
