// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.27;

import "./ISupportedContractsManager.sol";

/// @title Contract that manages the set of supported contracts
/// @author LAOS Team and Freeverse

contract SupportedContractsManager is ISupportedContractsManager {

    address public supportedContractsManager;
    
    Contract[] public supportedContracts;

    modifier onlySupportedContractsManager {
        if (msg.sender != supportedContractsManager) revert SenderIsNotSupportedContractsManager();
        _;
    }

    constructor() {
        supportedContractsManager = msg.sender;
    }

    function setSupportedContractsManager(address _newManager) public onlySupportedContractsManager {
        supportedContractsManager = _newManager;
    }

    function addSupportedContract(uint32 _chain, address _contractAddress, string calldata _observations) public onlySupportedContractsManager {
        supportedContracts.push(
            Contract({
                chain: _chain,
                contractAddress: _contractAddress,
                observations: _observations
            })
        );
    }
}
