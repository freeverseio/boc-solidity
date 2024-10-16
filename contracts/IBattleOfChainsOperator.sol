// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.20;

/**
 * @title IBattleOfChainsOperator Interface
 * @dev Interface for the Battle of Chains contract for ownership chains
 * @notice Developed and maintained by the LAOS Team and Freeverse.
 */

interface IBattleOfChainsOperator {
    enum TreasuryShareMethod {
        ABSOLUTE,
        PERCENTAGE_BPS
    }

    struct ShareTX {
        address recipient;
        uint256 amount;
    }

    error PercentageAbove100(uint256 _value);

    /**
     * @notice Emitted when a user assigns an operator.
     * @param _from The user granting permission.
     * @param _operator The address on the LAOS Network receiving the permission.
     */
    event AssignOperator(address indexed _from, address indexed _operator);

    /**
     * @notice Emitted when a user shares their treasury obtained in the Battle of Chains game.
     * Any treasury not shared will stay with the `_from` user.
     * When using absolute values, the transaction is disregarded off-chain if the sum of shared amounts
     * exceeds the off-chain balance of the `_from` user.
     * @param _from The user sharing the treasury
     * @param _method Specifies how the amounts are interpreted:
     *    - if _method = 0 => absolute values,
     *    - if _method = 1 => percentage values in Basis Points (e.g., amount = 1580 implies 15.80%).
     * @param _shareTXs The list of share transactions, each specifying the recipient and amount.
     */
    event ShareTreasury(address indexed _from, TreasuryShareMethod _method, ShareTX[] _shareTXs);

    /**
     * @notice Grants permission to the specified operator address on the LAOS Network
     * to perform game actions in the Battle of Chains, such as attacks and chain action proposals.
     * @notice The ERC-721 logic remains unaffected, and all NFT trading continues on-chain.
     * @notice Permissions can be updated anytime. They can be revoked by calling this method with _operator = msg.sender.
     * @dev This method does not store any variables; it simply emits an event for off-chain processing.
     * @param _operator The address on the LAOS Network to which permission is granted.
     */
    function assignOperator(address _operator) external;

    /**
     * @notice Emits an event showing the user's intention to share the treasury obtained in the Battle of Chains game.
     * Any remaining treasury stays with the user that sends this transaction.
     * The amounts must be expressed as absolute values. Off-chain, the transaction is disregarded if the sum exceeds the user's balance.
     * @param _shareTXs The list of share transactions, each specifying the recipient and the absolute amount.
     */
    function shareTreasuryAbsolute(ShareTX[] calldata _shareTXs) external;

    /**
     * @notice Emits an event showing the user's intention to share the treasury obtained in the Battle of Chains game.
     * Any remaining treasury stays with the user that sends this transaction.
     * The amounts must be expressed as percentages in Basis Points (BPS). 
     * For example, an amount of 1580 implies 15.80% of the treasury.
     * @dev The transaction fails if the total sum of percentages exceeds 100%.
     * @param _shareTXs The list of share transactions, each specifying the recipient and the percentage amount.
     */
    function shareTreasuryPercentage(ShareTX[] calldata _shareTXs) external;

}
