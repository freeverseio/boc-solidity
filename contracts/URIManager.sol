// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.27;

import "./IURIManager.sol";

/**
 * @title Contract that manages URIs
 * @notice Developed and maintained by the LAOS Team and Freeverse.
 */

contract URIManager is IURIManager {
    // The address authorized to manage this contract's URIs
    address public uriManager;

    // The map of on-chain assignments of a URI to each token type
    string[] public tokenURIForType;

    modifier onlyURIManager() {
        if (msg.sender != uriManager) revert SenderIsNotURIManager();
        _;
    }

    constructor() {
        uriManager = msg.sender;
    }

    /// @inheritdoc IURIManager
    function setURIManager(address _newManager) public onlyURIManager {
        uriManager = _newManager;
    }

    /// @inheritdoc IURIManager
    function addTokenURIs(
        uint32[] memory _types,
        string[] memory _tokenURIs
    ) public onlyURIManager {
        if (_types.length != _tokenURIs.length) revert IncorrectArrayLengths();
        for (uint256 i = 0; i < _types.length; i++) {
            tokenURIForType.push(_tokenURIs[i]);
        }
    }
}
