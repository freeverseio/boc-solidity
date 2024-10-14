// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.20;

/**
 * @title Interface to contract that manages URIs
 * @notice Developed and maintained by the LAOS Team and Freeverse.
 */

interface IURIManager {
    error SenderIsNotURIManager();
    error IncorrectArrayLengths();
    error TokenURIForTypeNotDefined(uint256 _type);

    /**
     * @notice Sets the address with permissions to manage the mapping between token type and tokenURI
     * @param _newManager the new address that will have permission to manage mapping between token type and tokenURI
     */
    function setURIManager(address _newManager) external;

    /**
     * @notice Adds the provided tokenURIs to the list of supported types
     * @dev Assigns types to provide URIs incrementally from last supported type
     * @param _tokenURIs the ordered array containing the tokenURIs
     */
    function addTokenURIs(
        string[] memory _tokenURIs
    ) external;

    /**
     * @notice Changes the previously defined tokenURIs for the provided token types
     * @dev Reverts if the two provided arrays do not have the same length
     * @dev Reverts if any of the provided types did not have a previously defined tokenURI
     * @param _types the ordered array containing the token types
     * @param _tokenURIs the ordered array containing the tokenURIs
     */
    function changeTokenURIs(
        uint256[] memory _types,
        string[] memory _tokenURIs
    ) external;

    /**
     * @notice Returns the number of token types for which a tokenURI has been defined
     * @return the number of token types
     */
    function nDefinedTypes() external view returns(uint256);

    /**
     * @notice Returns true if the provided token type has been defined
     * @return true if the provided token type has been defined
     */
    function isTypeDefined(uint256 _type) external view returns(bool);
}