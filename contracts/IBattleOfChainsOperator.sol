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

    error IndividualPercetageAbove100(uint256 _value);
    error TotalPercetageAbove100(uint256 _value);

    /**
     * @notice Emitted when a user assigns an operator.
     * @param _from The user granting permission.
     * @param _operator The address on the LAOS Network receiving the permission.
     */
    event AssignOperator(address indexed _from, address indexed _operator);

    /**
     * @notice Emitted when a user shares the treasury obtained in the Battle of Chains game 
     * Any amount remaining from the treasury will remain in the _from user
     * When using absolute values, the transaction will be disregarded off-chain if the sum of amounts
     * to be shared is larger than the balance of the _from user
     * @param _from The user sharing the treasury
     * @param _method Specifies whether the amounts are to be interpreted as:
     *    - if _method = 0 => absolute values
     *    - if _method = 1 => percetage values, expressed in Basis Points (e.g. amount= 1580 would imply 15.80 percent)
     * @param _shareTXs The list of share TXs, each specifying receipient and amount. 
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
     * @notice Emits an event expressing the user intention to share the treasury obtained in the Battle of Chains game 
     * Any amount remaining from the treasury will remain in the user that sends this TX
     * The amounts to be shared must be expressed as absolute values.
     * This transaction will be disregarded off-chain if the sum of amounts to be shared is larger than the balance of the _from user
     * @param _shareTXs The list of share TXs, each specifying receipient and the absolute amount. 
     */
    function shareTreasuryAbsolute(ShareTX[] calldata _shareTXs) external;

    /**
     * @notice Emits an event expressing the user intention to share the treasury obtained in the Battle of Chains game 
     * Any amount remaining from the treasury will remain in the user that sends this TX
     * The amounts to be shared must be expressed as percentages in Basis Point units (BPS)
     * For example, an amount = 1580 implies 15.80 percent of the treasury. 
     * @dev This transaction fails if the sum of percentages is larger than 100%
     * @param _shareTXs The list of share TXs, each specifying receipient and the absolute amount. 
     */
    function shareTreasuryPercentage(ShareTX[] calldata _shareTXs) external;

}
