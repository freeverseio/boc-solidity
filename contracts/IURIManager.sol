// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.27;

/**
 * @title Interface to contract that manages URIs
 * @notice Developed and maintained by the LAOS Team and Freeverse.
 */

interface IURIManager {
    error SenderIsNotURIManager();
    error IncorrectArrayLengths();

    /**
     * @notice Sets the address with permissions to manage the mapping between token type and tokenURI
     * @param _newManager the new address that will have permission to manage mapping between token type and tokenURI
     */
    function setURIManager(address _newManager) external;

    /**
     * @notice Sets the tokenURIOfType for the provided token types
     * @dev Reverts unless the two provided arrays must have the same length
     * @param _types the ordered array containing the token types
     * @param _tokenURIs the ordered array containing the tokenURIOfType
     */
    function setTokenURIs(
        uint32[] memory _types,
        string[] memory _tokenURIs
    ) external;

    /**
     * @notice Sets the tokenURI to be returned when querying about token types
     * for which no on-chain assignment exists
     * @param _tokenURI the tokenURI
     */
    function setMissingTypeURI(string calldata _tokenURI) external;

    /**
     * @notice Returns the tokenURI of the provide token type. If no on-chain assignment
     * currently exists, it returns the default tokenURI.
     * @return _uri the tokenURI
     */
    function typeTokenURI(uint32 _type) external view returns (string memory _uri);

}
