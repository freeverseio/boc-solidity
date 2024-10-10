// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.27;

/// @title Interface to contract that manages URIs
/// @author LAOS Team and Freeverse

interface ISupportedContractsManager {

    struct Contract {
        uint32 chain;
        address contractAddress;
        string observations;
    }

    error SenderIsNotSupportedContractsManager();

    /**
     * @notice Sets the address with permissions to add contracts supported by the Battle of Chains
     * @param _newManager the new address that will have permission to add contracts supported by the Battle of Chains
     */
    function setSupportedContractsManager(address _newManager) external;

    function addSupportedContract(uint32 _chain, address _contractAddress, string calldata _observations) external;

}
