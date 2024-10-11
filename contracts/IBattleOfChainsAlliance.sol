// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.27;

import './IBattleOfChainsOperator.sol';

/**
 * @title IBattleOfChainsAlliance Interface
 * @dev A general alliance contract can be an arbitrarily complex contract
 * @dev Battle of Chains recommendeds that alliances implement the minimal logic
 * @dev that this interface contains, which allows the alliance to:
 * @dev assign an operator on LAOS, responding to alliance name and alliance description.
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
