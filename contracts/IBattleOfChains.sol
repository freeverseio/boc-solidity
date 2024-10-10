// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.27;

/// @title Interface for Battle of Chains
/// @author LAOS Team and Freeverse

interface IBattleOfChains {

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
    error IncorrectAttackInput();
    error AttackAddressCannotBeEmpty();

    event ChainActionProposal(
        address indexed _operator,
        address indexed _user,
        ChainAction _action
    );
    // TODO: emit also originChain , targetChain

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


    function joinChain(uint32 _homeChain) external;

    function multichainMint(uint32 _type) external returns (uint256 _tokenId);

    // VoteForChainAction, add "comment"
    function proposeChainAction(ChainAction calldata _chainAction) external;

    function proposeChainActionOnBehalfOf(address _user, ChainAction calldata _chainAction) external;

    function areChainActionInputsCorrect(ChainAction calldata _chainAction) external pure returns (bool _isOK);

    function creatorFromTokenId(uint256 _tokenId) external pure returns(address _creator);

    function coordinatesOf(address _user) external pure returns (uint256 _x, uint256 _y);

    function attack(uint256[] calldata _tokenIds, address targetAddress, uint32 _targetChain, uint32 _strategy) external;

    function attackOnBehalfOf(uint256[] calldata _tokenIds, address targetAddress, uint32 _targetChain, uint32 _strategy, address _attacker) external;

}
