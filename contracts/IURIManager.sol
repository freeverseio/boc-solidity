// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.27;

/// @title Interface to contract that manages URIs
/// @author LAOS Team and Freeverse

interface IURIManager {

    error SenderIsNotURIManager();
    error IncorrectArrayLengths();

    /**
     * @notice Sets the address with permissions to manage mapping between token type and tokenURI
     * @param _newManager the new address that will have permission to manage mapping between token type and tokenURI
     */
    function setURIManager(address _newManager) external;

    function setTokenURIs(uint32[] memory _types, string[] memory _tokenURIs) external;

    function setMissingTypeURI(string calldata _tokenURI) external;

    function typeTokenURI(uint32 _type) external view returns (string memory _uri);

}
