// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.20;

/**
 * @title Interface to contract that manages the set of supported contracts
 * @notice Developed and maintained by the LAOS Team and Freeverse.
 */

interface ISupportedContractsManager {
    /**
     * @dev Represents a supported contract, detailing the chain ID and address of deploy,
     * as well as an optional description of the contract
     */
    struct Contract {
        uint32 chain;
        address contractAddress;
        string observations;
    }

    error SenderIsNotSupportedContractsManager();

    /**
     * @notice Sets the address with permissions to manage the set of supported contracts
     * @param _newManager the new address that will have permission to add supported contracts
     */
    function setSupportedContractsManager(address _newManager) external;

    /**
     * @notice Adds a new supported contract
     * @param _chain the chain ID where the contract is deployed
     * @param _contractAddress the address of the deployed contract
     * @param _observations opntional description of the supported contract
     */
    function addSupportedContract(
        uint32 _chain,
        address _contractAddress,
        string calldata _observations
    ) external;

    /**
     * @notice Returns all currently supported contracts
     * @return _allContracts an array with all currently supported contracts
     */
    function allSupportedContracts() external view returns(Contract[] memory _allContracts);

}
