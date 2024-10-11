// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.27;

import "./ISupportedContractsManager.sol";

/**
 * @title  Contract that manages the set of supported contracts
 * @notice Developed and maintained by the LAOS Team and Freeverse.
 */

contract SupportedContractsManager is ISupportedContractsManager {
    // The address authorized to manage the supported contracts
    address public supportedContractsManager;

    // The array containing all currently supported contracts
    Contract[] public supportedContracts;

    modifier onlySupportedContractsManager {
        if (msg.sender != supportedContractsManager) revert SenderIsNotSupportedContractsManager();
        _;
    }

    constructor() {
        supportedContractsManager = msg.sender;
    }

    /// @inheritdoc ISupportedContractsManager
    function setSupportedContractsManager(address _newManager) public onlySupportedContractsManager {
        supportedContractsManager = _newManager;
    }

    /// @inheritdoc ISupportedContractsManager
    function addSupportedContract(
        uint32 _chain,
        address _contractAddress,
        string calldata _observations
    ) public onlySupportedContractsManager {
        supportedContracts.push(
            Contract({
                chain: _chain,
                contractAddress: _contractAddress,
                observations: _observations
            })
        );
    }

    /// @inheritdoc ISupportedContractsManager
    function allSupportedContracts() external view returns(Contract[] memory _allContracts) {
        _allContracts = new Contract[](supportedContracts.length);
        for (uint256 i = 0; i < supportedContracts.length; i++) {
            _allContracts[i] = supportedContracts[i];
        }
    }
}
