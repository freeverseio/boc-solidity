// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.3;

import "./IEvolutionCollection.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Battle of Chains
/// @author LAOS Team and Freeverse

// TODOS:
// use latest compiler in header
// separate interface
// rething naming everywhere
// estimate costs, and balance order of params, and number of params emitted
// test a uriManager contract
// test a supportedContractManager
// add daily chain action
// consider using structs instead of separate variables
// think of emitting addresses instead of (x,y)
// think of attacking a particular place
// calldata vs memory in all functions
// review != 0 in favour of just variable

contract BattleOfChains is Ownable {

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

    IEvolutionCollection public immutable collectionContract;
    mapping(address user => uint32 homeChain) public homeChainOfUser;
    mapping(uint32 => string) public tokenURIs;
    string public missingTypeURI;
    address public uriManager;
    address public supportedContractsManager;
    
    Contract[] public supportedContracts;

    error HomeChainMustBeGreaterThanZero();
    error UserAlreadyJoinedChain(address _user, uint32 _chain);
    error UserHasNotJoinedChainYet(address _user);
    error IncorrectArrayLengths();
    error SenderIsNotURIManager();
    error SenderIsNotSupportedContractsManager();
    error IncorrectAttackInput();
    error AttackAddressCannotBeEmpty();

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

    modifier onlyURIManager {
        if (msg.sender != uriManager) revert SenderIsNotURIManager();
        _;
    }

    modifier onlySupportedContractsManager {
        if (msg.sender != supportedContractsManager) revert SenderIsNotSupportedContractsManager();
        _;
    }

    constructor(address _laosCollectionAddress) Ownable(msg.sender) {
        collectionContract = IEvolutionCollection(_laosCollectionAddress);
        uriManager = msg.sender;
        supportedContractsManager = msg.sender;
    }

    function setURIManager(address _newManager) public onlyURIManager {
        uriManager = _newManager;
    }

    function setSupportedContractsManager(address _newManager) public onlySupportedContractsManager {
        supportedContractsManager = _newManager;
    }

    function addSupportedContract(uint32 _chain, address _contractAddress, string calldata _observations) public onlySupportedContractsManager {
        supportedContracts.push(
            Contract({
                chain: _chain,
                contractAddress: _contractAddress,
                observations: _observations
            })
        );
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

    function joinChain(uint32 _homeChain) public {
        _joinChain(_homeChain);
    }

    function multichainMint(uint32 _homeChain, uint32 _type) public returns (uint256 _tokenId) {
        _joinChainIfNeeded(_homeChain);
        return _multichainMint(_homeChain, _type);
    }

    function multichainMint(uint32 _type) public returns (uint256 _tokenId) {
        uint32 _homeChain = homeChainOfUser[msg.sender];
        if (_homeChain == 0) revert UserHasNotJoinedChainYet(msg.sender);
        return _multichainMint(_homeChain, _type);
    }

    ////////////////
    // Daily Actions
    ////////////////
    function voteChainAction(ChainAction calldata _chainAction) public returns (bytes32 _chainActionHash) {
        if (!areChainActionInputsCorrect(_chainAction)) revert IncorrectAttackInput();
        return hashChainAction(_chainAction);
    }

    // TODO: REFACTOR ORDER FOR GAS SAVING
    function areChainActionInputsCorrect(ChainAction calldata _chainAction) public pure returns (bool _isOK) {
        bool _isAttack = (_chainAction.actionType == ChainActionType.ATTACK_ADDRESS) || (_chainAction.actionType == ChainActionType.ATTACK_AREA);
        bool _isAttackAddressNull = _chainAction.attackAddress == address(0);
        bool _isAttackAreaNull = _chainAction.attackArea == Attack_Area.NULL;

        if (!_isAttack) {
            return _isAttackAddressNull && _isAttackAreaNull;
        }
        if  (_chainAction.actionType == ChainActionType.ATTACK_AREA) {
            return _isAttackAddressNull;
        }
        if  (_chainAction.actionType == ChainActionType.ATTACK_ADDRESS) {
            return !_isAttackAddressNull && _isAttackAreaNull;
        }
    }

    function hashChainAction(ChainAction calldata _chainAction) public returns (bytes32) {
        return bytes32(0);
    }

    //////////////// 

    function _multichainMint(uint32 _homeChain, uint32 _type) private returns (uint256 _tokenId) {
        uint96 _slot = uint96(uint256(blockhash(block.number - 1)));
        _tokenId = collectionContract.mintWithExternalURI(msg.sender, _slot, typeTokenURI(_type));
        emit MultichainMint(_tokenId, msg.sender, _type, _homeChain);
        return _tokenId;
    }

    function _joinChain(uint32 _homeChain) private {
        if (_homeChain == 0) revert HomeChainMustBeGreaterThanZero();
        if (homeChainOfUser[msg.sender] != 0) revert UserAlreadyJoinedChain(msg.sender, homeChainOfUser[msg.sender]);
        homeChainOfUser[msg.sender] = _homeChain;
        emit JoinedChain(msg.sender, _homeChain);
    }

    function _joinChainIfNeeded(uint32 _homeChain) internal {
        if (_homeChain == 0) revert HomeChainMustBeGreaterThanZero();
        uint32 prevJoinedChain = homeChainOfUser[msg.sender];
        if (prevJoinedChain == 0) {
            _joinChain(_homeChain);
        } else {
            if (prevJoinedChain != _homeChain) revert UserAlreadyJoinedChain(msg.sender, prevJoinedChain);
        }
    }

    function typeTokenURI(uint32 _type) public view returns (string memory _uri) {
        _uri = tokenURIs[_type];
        return bytes(_uri).length == 0 ? missingTypeURI : _uri;
    }

    function creatorFromTokenId(uint256 _tokenId) public pure returns(address _creator) {
        return address(uint160(_tokenId));
    }

    function coordinatesOf(address _user) public pure returns (uint256 _x, uint256 _y) {
        uint160 user160 = uint160(_user);

        _x = uint256(user160 >> 80);
        _y = uint256(user160 & ((1 << 80) - 1));
    }

    function attack(uint256[] calldata _tokenIds, uint256 _x, uint256 _y, uint32 _targetChain, uint32 _strategy) public {
        _attack(_tokenIds, _x, _y, msg.sender, _targetChain, _strategy);
    }

    function attack(uint256[] calldata _tokenIds, address targetUser, uint32 _targetChain, uint32 _strategy) public {
        (uint256 _x, uint256 _y) = coordinatesOf(targetUser);
        _attack(_tokenIds, _x, _y, msg.sender, _targetChain, _strategy);
    }

    function attackOnBehalfOf(uint256[] calldata _tokenIds, uint256 _x, uint256 _y, uint32 _targetChain, uint32 _strategy, address _attacker) public {
        _attack(_tokenIds, _x, _y, _attacker, _targetChain, _strategy);
    }

    function attackOnBehalfOf(uint256[] calldata _tokenIds, address targetUser, uint32 _targetChain, uint32 _strategy, address _attacker) public {
        (uint256 _x, uint256 _y) = coordinatesOf(targetUser);
        _attack(_tokenIds, _x, _y, _attacker, _targetChain, _strategy);
    }

    function _attack(uint256[] calldata tokenIds, uint256 _x, uint256 _y, address _attacker, uint32 _targetChain, uint32 _strategy) private {
        emit Attack(tokenIds, _x, _y, msg.sender, _attacker, _targetChain, _strategy);
    }


}
