// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.27;

import "./IURIManager.sol";

/// @title Contract that manages URIs
/// @author LAOS Team and Freeverse

contract URIManager is IURIManager {

    string public missingTypeURI;
    address public uriManager;
    mapping(uint32 => string) public tokenURIs;

    modifier onlyURIManager {
        if (msg.sender != uriManager) revert SenderIsNotURIManager();
        _;
    }
    constructor() {
        uriManager = msg.sender;
    }

    function setURIManager(address _newManager) public onlyURIManager {
        uriManager = _newManager;
    }

    function setTokenURIs(uint32[] memory _types, string[] memory _tokenURIs) public onlyURIManager {
        if (_types.length != _tokenURIs.length) revert IncorrectArrayLengths();
        for (uint256 i = 0; i <_types.length; i++) {
            tokenURIs[_types[i]] = _tokenURIs[i];
        }
    }

    function setMissingTypeURI(string calldata _tokenURI) public onlyURIManager {
        missingTypeURI = _tokenURI;
    }

    function typeTokenURI(uint32 _type) public view returns (string memory _uri) {
        _uri = tokenURIs[_type];
        return bytes(_uri).length == 0 ? missingTypeURI : _uri;
    }


}
