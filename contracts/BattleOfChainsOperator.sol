// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.20;

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

    /// @inheritdoc IBattleOfChainsOperator
    function shareTreasuryAbsolute(ShareTX[] calldata _shareTXs) public {
        emit ShareTreasury(msg.sender, TreasuryShareMethod.ABSOLUTE, _shareTXs);
    }

    /// @inheritdoc IBattleOfChainsOperator
    function shareTreasuryPercentage(ShareTX[] calldata _shareTXs) public {
        uint256 totalPercentage;
        for (uint256 i = 0; i < _shareTXs.length; i++) {
            totalPercentage += _shareTXs[i].amount;
        }
        if (totalPercentage > 1000) revert PercentageAbove100(totalPercentage);
        emit ShareTreasury(msg.sender, TreasuryShareMethod.PERCENTAGE_BPS, _shareTXs);
    }
}
