// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.20;

import "./IBattleOfChainsAlliance.sol";

/**
 * @title BattleOfChains Main Contract for the supported Ownership Chains
 * @notice Developed and maintained by the LAOS Team and Freeverse.
 */

contract BattleOfChainsAlliance is IBattleOfChainsAlliance {

    address public immutable battleOfChains721Contract;

    /// @inheritdoc IBattleOfChainsAlliance
    string public allianceName;

    /// @inheritdoc IBattleOfChainsAlliance
    string public allianceDescription;

    constructor(
        string memory _allianceName,
        string memory _allianceDescription,
        address _battleOfChains721Contract
    ) {
        allianceName = _allianceName;
        allianceDescription = _allianceDescription;
        battleOfChains721Contract = _battleOfChains721Contract;
    }

    /// @inheritdoc IBattleOfChainsOperator
    function assignOperator(address _operator) public {
        IBattleOfChainsOperator(battleOfChains721Contract).assignOperator(_operator);
    }

    /// @inheritdoc IBattleOfChainsOperator
    function sendGameTreasuryAbsolute(SendTX[] calldata _sendTXs) public  {
        IBattleOfChainsOperator(battleOfChains721Contract).sendGameTreasuryAbsolute(_sendTXs);
    }

    /// @inheritdoc IBattleOfChainsOperator
    function sendGameTreasuryPercentage(SendTX[] calldata _sendTXs) public {
        IBattleOfChainsOperator(battleOfChains721Contract).sendGameTreasuryPercentage(_sendTXs);
    }
}
