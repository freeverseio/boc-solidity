// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.27;

/// @title Interface for Battle of Chains
/// @author LAOS Team and Freeverse

interface IBattleOfChains {

    enum ChainActionType{ DEFEND, IMPROVE, ATTACK_AREA, ATTACK_ADDRESS }
    enum Attack_Area{ NULL, NORTH, SOUTH, EAST, WEST, ALL }

    struct ChainAction {
        uint32 targetChain;
        ChainActionType actionType;
        Attack_Area attackArea;
        address attackAddress;
    }

    error HomeChainMustBeGreaterThanZero();
    error UserAlreadyJoinedChain(address _user, uint32 _chain);
    error UserHasNotJoinedChainYet(address _user);
    error IncorrectAttackInput();
    error AttackAddressCannotBeEmpty();

    event ChainActionProposal(
        address indexed _operator,
        address indexed _user,
        uint32 _sourceChain,
        ChainAction _action,
        string _comment
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
        address _targetAddress,
        address indexed _operator,
        address indexed _attacker,
        uint32 indexed _targetChain,
        uint32 _strategy
    );


    /**
     * @notice Assigns the sender of the TX to the provided chain. Assignment cannot be modified.
     * @dev Reverts if called more than once. ChainId = 0 is not allowed.
     * @param _homeChain the chainId of the chain to assign to the sender
     */
    function joinChain(uint32 _homeChain) external;

    /**
     * @notice Returns true if provided user has previously joined a chain
     * @param _user the address of the user
     */
    function hasHomeChain(address _user) external returns (bool);

    /**
     * @notice Mints NFTs accross all supported chains of the provided _type
     * @notice The attributes of the minted NFT depend on the current state of the user and the game
     * @param _type a uint32 specifying the desired type of minted NFTs 
     * @return _tokenId the tokenId that identifies the minted NFTs in the contracts on all supported chains
     */
    function multichainMint(uint32 _type) external returns (uint256 _tokenId);

    /**
     * @notice Votes for the homeChain of the sender to perform the provided chain action during
     * @notice the current voting period. The effect of the vote depends on the current state of the user and the game
     * @param _chainAction the desired action to be performed by the chain of the sender in the current period
     * @param _comment a completely optional string arguing about the convenience of the proposed action
     */
    function proposeChainAction(ChainAction calldata _chainAction, string calldata _comment) external;

    /**
     * @notice Tries to perform proposeChainAction on behalf of the provided user address.
     * @notice The effect is completely disregarded offchain unless the user has previously authorized the
     * @notice transaction sender as operator.
     * @notice If not disregarded, it votes for the homeChain of the provided user to perform the provided chain action during
     * @notice the current voting period. The effect of the vote depends on the current state of the user and the game
     * @param _user The user on whose behalf the sender is attempting to perform the action.
     * @param _chainAction the desired action to be performed by the chain of the provided user in the current period
     * @param _comment a completely optional string arguing about the convenience of the proposed action
     */
    function proposeChainActionOnBehalfOf(address _user, ChainAction calldata _chainAction, string calldata _comment) external;

    /**
     * @notice Executes an attack on the provideed target chain, at the provided targetAddress, with the assets
     * @notice owned by the sender in the target chain, specified by the provided _tokenIds, using the provided attack strategy. 
     * @notice If _tokenIds are an empty list, it default to attack with all possible assets owned by the sender in the target chain.
     * @notice The effect of the attack depends on the offchain state of the user and the game.
     * @param _tokenIds the list of the NFTs participating in the attack. If empty, all possible assets are used. 
     * @param _targetAddress the address in the targetChain to attack. 
     * @param _targetChain the chainId of the chain where the attack is to be performed. 
     * @param _strategy a uint32 specifying the attack strategy. 
     */
    function attack(uint256[] calldata _tokenIds, address _targetAddress, uint32 _targetChain, uint32 _strategy) external;

    /**
     * @notice Tries to perform an attack on behalf of the provided attacker address.
     * @notice The effect is completely disregarded offchain unless the attacker has previously authorized the
     * @notice transaction sender as operator.
     * @notice If not disregarded, it executes an attack on the provideed target chain, at the provided targetAddress, with the assets
     * @notice owned by the sender in the target chain, specified by the provided _tokenIds, using the provided attack strategy. 
     * @notice If _tokenIds are an empty list, it default to attack with all possible assets owned by the sender in the target chain.
     * @notice The effect of the attack depends on the offchain state of the attacker and the game.
     * @param _tokenIds the list of the NFTs participating in the attack. If empty, all possible assets are used. 
     * @param _targetAddress the address in the targetChain to attack. 
     * @param _targetChain the chainId of the chain where the attack is to be performed. 
     * @param _strategy a uint32 specifying the attack strategy. 
     * @param _attacker The user on whose behalf the sender is attempting to perform the action.
     */
    function attackOnBehalfOf(uint256[] calldata _tokenIds, address _targetAddress, uint32 _targetChain, uint32 _strategy, address _attacker) external;

    /**
     * @notice Returns true if the provided chainAction is formally correct
     * @param _chainAction the desired action to be performed by the chain of the provided user in the current period
     * @return _isOK true if the provided chainAction is formally correct
     */
    function areChainActionInputsCorrect(ChainAction calldata _chainAction) external pure returns (bool _isOK);

    /**
     * @notice Returns the user that executed the multichain corresponding to the provided tokenId.
     * @notice Note that the NFTs minted on different chains may have been traded are be owned by other players.
     * @param _tokenId the tokenId of the multichain mint
     * @return _creator the address of the user that executed the multichain
     */
    function creatorFromTokenId(uint256 _tokenId) external pure returns(address _creator);

    /**
     * @notice Returns (x,y) coordinates associated to the provided address
     * @param _user the address of the user
     */
    function coordinatesOf(address _user) external pure returns (uint256 _x, uint256 _y);


}
