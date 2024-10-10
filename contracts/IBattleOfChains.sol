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
        ChainAction _action,
        bytes32 _actionHash
    );
    // emit also originChain , targetChain

    

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


    function joinChain(uint32 _homeChain) external;

    // eliminate this:
    function multichainMint(uint32 _homeChain, uint32 _type) external returns (uint256 _tokenId);

    function multichainMint(uint32 _type) external returns (uint256 _tokenId);

    // we kill all hashes. VoteForChainAction, add "comment", elimintate hashes
    function proposeChainAction(ChainAction calldata _chainAction) external returns (bytes32 _chainActionHash);

    function proposeChainActionOnBehalfOf(address _user, ChainAction calldata _chainAction) external returns (bytes32 _chainActionHash);

    function areChainActionInputsCorrect(ChainAction calldata _chainAction) external pure returns (bool _isOK);

    function hashChainAction(ChainAction calldata _chainAction) external pure returns (bytes32);

    function creatorFromTokenId(uint256 _tokenId) external pure returns(address _creator);

    function coordinatesOf(address _user) external pure returns (uint256 _x, uint256 _y);

    // remove x,y and leave only attacks to addresses
    function attack(uint256[] calldata _tokenIds, uint256 _x, uint256 _y, uint32 _targetChain, uint32 _strategy) external;

    // tarketUser --> targetAddress
    function attack(uint256[] calldata _tokenIds, address targetUser, uint32 _targetChain, uint32 _strategy) external;

    function attackOnBehalfOf(uint256[] calldata _tokenIds, uint256 _x, uint256 _y, uint32 _targetChain, uint32 _strategy, address _attacker) external;

    function attackOnBehalfOf(uint256[] calldata _tokenIds, address targetUser, uint32 _targetChain, uint32 _strategy, address _attacker) external;

}
