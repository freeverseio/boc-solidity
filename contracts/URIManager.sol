// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.26;

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
        uint256[] memory _types,
        string[] memory _tokenURIs
    ) public onlyURIManager {
        if (_types.length != _tokenURIs.length) revert IncorrectArrayLengths();
        for (uint256 i = 0; i < _types.length; i++) {
            tokenURIForType.push(_tokenURIs[i]);
        }
    }

    /// @inheritdoc IURIManager
    function changeTokenURIs(
        uint256[] memory _types,
        string[] memory _tokenURIs
    ) public onlyURIManager {
        if (_types.length != _tokenURIs.length) revert IncorrectArrayLengths();
        for (uint256 i = 0; i < _types.length; i++) {
            if (!isTypeDefined(_types[i])) revert TokenURIForTypeNotDefined(_types[i]);
            tokenURIForType[_types[i]] = _tokenURIs[i];
        }
    }

    /// @inheritdoc IURIManager
    function nDefinedTypes() public view returns(uint256) {
        return tokenURIForType.length;
    }

    /// @inheritdoc IURIManager
    function isTypeDefined(uint256 _type) public view returns(bool) {
        return _type < tokenURIForType.length;
    }

}
