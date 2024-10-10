// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.27;

/// @title Interface for Battle of Chains
/// @author LAOS Team and Freeverse

interface IBattleOfChains {

    struct Contract {
        uint32 chain;
        address contractAddress;
        string observations;
    }

    enum ChainActionType{ DEFEND, IMPROVE, ATTACK_AREA, ATTACK_ADDRESS }
    enum Attack_Area{ NULL, NORTH, SOUTH, EAST, WEST, ALL }

    struct ChainAction {
        ChainActionType actionType;
        Attack_Area attackArea;
        address attackAddress;
    }

    error HomeChainMustBeGreaterThanZero();
    error UserAlreadyJoinedChain(address _user, uint32 _chain);
    error UserHasNotJoinedChainYet(address _user);
    error IncorrectArrayLengths();
    error SenderIsNotURIManager();
    error SenderIsNotSupportedContractsManager();
    error IncorrectAttackInput();
    error AttackAddressCannotBeEmpty();

    event ChainActionProposal(
        address indexed _operator,
        address indexed _user,
        ChainAction _action,
        bytes32 _actionHash
    );

    event MultichainMint(
        uint256 _tokenId,
        address indexed _user, 
        uint32 indexed _type,
        uint32 indexed _homeChain
    );

    event JoinedChain(
        address indexed _user, 
        uint32 indexed _homeChain
    );

    event Attack(
        uint256[] _tokenIds,
        uint256 _x,
        uint256 _y,
        address indexed _operator,
        address indexed _attacker,
        uint32 indexed _targetChain,
        uint32 _strategy
    );


    /**
     * @notice Sets the address with permissions to manage mapping between token type and tokenURI
     * @param _newManager the new address that will have permission to manage mapping between token type and tokenURI
     */
    function setURIManager(address _newManager) external;

    /**
     * @notice Sets the address with permissions to add contracts supported by the Battle of Chains
     * @param _newManager the new address that will have permission to add contracts supported by the Battle of Chains
     */
    function setSupportedContractsManager(address _newManager) external;

    function addSupportedContract(uint32 _chain, address _contractAddress, string calldata _observations) external;

    function setTokenURIs(uint32[] memory _types, string[] memory _tokenURIs) external;

    function setMissingTypeURI(string calldata _tokenURI) external;

    function joinChain(uint32 _homeChain) external;

    function multichainMint(uint32 _homeChain, uint32 _type) external returns (uint256 _tokenId);

    function multichainMint(uint32 _type) external returns (uint256 _tokenId);

    function proposeChainAction(ChainAction calldata _chainAction) external returns (bytes32 _chainActionHash);

    function proposeChainActionOnBehalfOf(address _user, ChainAction calldata _chainAction) external returns (bytes32 _chainActionHash);

    function areChainActionInputsCorrect(ChainAction calldata _chainAction) external pure returns (bool _isOK);

    function hashChainAction(ChainAction calldata _chainAction) external pure returns (bytes32);

    function typeTokenURI(uint32 _type) external view returns (string memory _uri);

    function creatorFromTokenId(uint256 _tokenId) external pure returns(address _creator);

    function coordinatesOf(address _user) external pure returns (uint256 _x, uint256 _y);

    function attack(uint256[] calldata _tokenIds, uint256 _x, uint256 _y, uint32 _targetChain, uint32 _strategy) external;

    function attack(uint256[] calldata _tokenIds, address targetUser, uint32 _targetChain, uint32 _strategy) external;

    function attackOnBehalfOf(uint256[] calldata _tokenIds, uint256 _x, uint256 _y, uint32 _targetChain, uint32 _strategy, address _attacker) external;

    function attackOnBehalfOf(uint256[] calldata _tokenIds, address targetUser, uint32 _targetChain, uint32 _strategy, address _attacker) external;

}
