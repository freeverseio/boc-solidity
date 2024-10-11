// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.27;

import "./IBattleOfChainsOperator.sol";

/**
 * @title BattleOfChains contract that allows assigning an operator on the LAOS Network
 * @notice Developed and maintained by the LAOS Team and Freeverse.
 */

contract BattleOfChainsOperator is IBattleOfChainsOperator {
    /// @inheritdoc IBattleOfChainsOperator
    function assignOperator(address _operator) public {
        emit AssignOperator(msg.sender, _operator);
    }
}
