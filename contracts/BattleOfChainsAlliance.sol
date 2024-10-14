// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.26;

import "./BattleOfChainsOperator.sol";
import "./IBattleOfChainsAlliance.sol";

/**
 * @title BattleOfChains Main Contract for the supported Ownership Chains
 * @notice Developed and maintained by the LAOS Team and Freeverse.
 */

contract BattleOfChainsAlliance is BattleOfChainsOperator, IBattleOfChainsAlliance {

    /// @inheritdoc IBattleOfChainsAlliance
    string public allianceName;

    /// @inheritdoc IBattleOfChainsAlliance
    string public allianceDescription;

    constructor(
        string memory _allianceName,
        string memory _allianceDescription
    ) {
        allianceName = _allianceName;
        allianceDescription = _allianceDescription;
    }
}
