// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.20;

/**
 * @title IBattleOfChains Interface
 * @dev Interface for the Battle of Chains contract, defining the core structure and functions 
 * required for managing user actions, cross-chain interactions, and NFT minting in the game environment.
 * This is intended for implementation by contracts managing game logic.
 * @notice Developed and maintained by the LAOS Team and Freeverse.
 */

interface IBattleOfChains {
    /**
     * @dev The set of possible chain actions.
     */
    enum ChainActionType {
        DEFEND,
        IMPROVE,
        ATTACK_AREA,
        ATTACK_ADDRESS
    }

    /**
     * @dev The set of possible attack areas for actions of type ATTACK_AREA.
     * If the action is not ATTACK_AREA, AttackArea should be set to NULL.
     */
    enum AttackArea {
        NULL,
        NORTH,
        SOUTH,
        EAST,
        WEST,
        ALL
    }

    /**
     * @dev Represents an action proposed by a user to their home chain.
     * This struct is used as input to functions and emitted in events.
     */
    struct ChainAction {
        uint32 targetChain;
        ChainActionType actionType;
        AttackArea attackArea;
        address attackAddress;
    }

    error HomeChainMustBeGreaterThanZero();
    error UserAlreadyJoinedChain(address _user, uint32 _chain);
    error UserHasNotJoinedChainYet(address _user);
    error IncorrectAttackInput();
    error AttackAddressCannotBeEmpty();

    /**
     * @dev Emitted when a user joins a chain, specifying the home chain ID and the user's nickname.
     */
    event JoinedChain(address indexed _user, uint32 indexed _homeChain, string _nickname);

    /**
     * @dev Emitted when a user performs a multichain mint, specifying the home chain to which
     * the user belongs, the type of mint, and the token ID.
     * The tokenId identifies NFTs created on all supported chains.
     */
    event MultichainMint(
        uint256 _tokenId,
        address indexed _user,
        uint256 indexed _type,
        uint32 indexed _homeChain
    );

    /**
     * @dev Emitted when a user executes an attack on a target chain, using their assets in the target chain.
     * If _tokenIds is empty, all available assets are used.
     */
    event Attack(
        uint256[] _tokenIds,
        address _targetAddress,
        address indexed _operator,
        address indexed _attacker,
        uint32 indexed _targetChain,
        uint32 _strategy
    );

    /**
     * @dev Emitted when a user proposes a chain action to be performed.
     * This event captures the details of the proposed action, including the operator initiating
     * the proposal, the user for whom the action is proposed, the source chain, the action details,
     * and any additional comments.
     * User and operator coincide if the user sent the proposal transaction directly
     */
    event ChainActionProposal(
        address indexed _operator,
        address indexed _user,
        uint32 _sourceChain,
        ChainAction _action,
        string _comment
    );

    /**
     * @dev Emitted when a user attempts to upgrade an asset.
     */
    event Upgrade(
        address indexed _operator,
        address indexed _user,
        uint32 _chain,
        uint256 _tokenId
    );

    /**
     * @notice Assigns the transaction sender to the specified chain. This assignment is permanent.
     * @dev Reverts if called more than once. ChainId must be greater than 0.
     * @param _homeChain The chainId to assign the sender to.
     * @param _userNickname The nickname desired by the user within the game.
     */
    function joinChain(uint32 _homeChain, string memory _userNickname) external;

    /**
     * @notice Mints NFTs across all supported chains for the specified _type.
     * The attributes of the minted NFT depend on the current game state.
     * Reverts if the provided token type is unsupported.
     * @param _type The type of NFTs to mint.
     * @return _tokenId The tokenId for the minted NFTs.
     */
    function multichainMint(uint256 _type) external returns (uint256 _tokenId);

    /**
     * @notice Executes an attack on a specified target chain using the sender's assets in the target chain.
     * If _tokenIds is empty, all available assets are used.
     * @param _tokenIds The list of NFTs used in the attack. If empty, all available assets are used.
     * @param _targetAddress The address in the target chain to attack.
     * @param _targetChain The chainId where the attack takes place.
     * @param _strategy The attack strategy used.
     */
    function attack(
        uint256[] calldata _tokenIds,
        address _targetAddress,
        uint32 _targetChain,
        uint32 _strategy
    ) external;

    /**
     * @notice Tries to perform an attack on behalf of the provided attacker address.
     * @notice The effect is disregarded off-chain unless the attacker has authorized the transaction sender as an operator
     * @notice If not disregarded, it executes an attack on the provided target chain, at the provided targetAddress, with the assets
     * @notice owned by the sender in the target chain, specified by the provided _tokenIds, using the provided attack strategy.
     * @notice If _tokenIds is an empty list, the attack defaults to using all available assets owned by the sender in the target chain.
     * @notice The effect of the attack depends on the offchain state of the attacker and the game.
     * @param _tokenIds The list of NFTs used in the attack. If empty, all available assets are used.
     * @param _targetAddress the address in the targetChain to attack.
     * @param _targetChain The chainId where the attack takes place.
     * @param _strategy The attack strategy used.
     * @param _attacker The user on whose behalf the sender is attempting to perform the action.
     */
    function attackOnBehalfOf(
        uint256[] calldata _tokenIds,
        address _targetAddress,
        uint32 _targetChain,
        uint32 _strategy,
        address _attacker
    ) external;

    /**
     * @notice Allows the sender to propose an action to their home chain
     * during the current voting period.
     * The effect depends on the current state of the user and game.
     * @param _chainAction The action proposed for the sender's home chain.
     * @param _comment An optional comment providing arguments for the proposed action
     */
    function proposeChainAction(
        ChainAction calldata _chainAction,
        string calldata _comment
    ) external;

    /**
     * @notice Tries to perform proposeChainAction on behalf of the provided user address.
     * @notice The effect is completely disregarded offchain unless the user has previously authorized the
     * @notice transaction sender as operator.
     * @notice If not disregarded, it votes for the homeChain of the provided user to perform the provided chain action during
     * @notice the current voting period. The effect of the vote depends on the current state of the user and the game
     * @param _user The user on whose behalf the sender is attempting to perform the action.
     * @param _chainAction The action proposed for the user's home chain.
     * @param _comment An optional comment providing arguments for the proposed action
     */
    function proposeChainActionOnBehalfOf(
        address _user,
        ChainAction calldata _chainAction,
        string calldata _comment
    ) external;

    /**
     * @notice Attempts to perform an upgrade on an asset owned by the sender
     * on the provided chain
     * @param _chain The chainID of the chain where the asset resides.
     * @param _tokenId The tokenId of the asset.
     */
    function upgrade(uint32 _chain, uint256 _tokenId) external;

    /**
     * @notice Attempts to upgrade an asset on behalf of the specified user.
     * @notice The effect is completely disregarded offchain unless the user has previously authorized the
     * @notice transaction sender as operator.
     * @param _user The user on whose behalf the action is taken.
     * @param _chain The chainId of the chain where the asset resides.
     * @param _tokenId The tokenId of the asset.
     */
    function upgradeOnBehalfOf(address _user, uint32 _chain, uint256 _tokenId) external;

    /**
     * @notice Returns true if a user has joined a chain.
     * @param _user The address of the user.
     * @return True if the user has joined a chain.
     */
    function hasHomeChain(address _user) external view returns (bool);

    /**
     * @notice Validates whether a proposed chain action is formally correct.
     * @param _chainAction The action proposed.
     * @return _isOK True if the action is valid.
     */
    function areChainActionInputsCorrect(ChainAction calldata _chainAction) external pure returns (bool _isOK);

    /**
     * @notice Returns the user who executed the multichain mint for the specified tokenId.
     * Note that minted NFTs may have been traded and, hence, be owned by other players.
     * @param _tokenId The tokenId of the multichain mint.
     * @return _creator The address of the user who executed the multichain mint.
     */
    function creatorFromTokenId(uint256 _tokenId) external pure returns (address _creator);

    /**
     * @notice Returns the (x, y) coordinates associated with a given address.
     * @param _user The address of the user.
     */
    function coordinatesOf(address _user) external pure returns (uint256 _x, uint256 _y);

    /**
     * @notice Returns the tokenURI of the provided multichain-minted token
     * @dev It internally calls the precompile collection contract
     * @dev It reverts if the token has not been minted. 
     * @param _tokenId the tokenId of the multichain mint
     */
    function tokenURI(uint256 _tokenId) external view returns (string memory);
}
