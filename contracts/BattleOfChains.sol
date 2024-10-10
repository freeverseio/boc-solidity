// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.27;

import "./IEvolutionCollection.sol";
import "./IBattleOfChains.sol";
import "./URIManager.sol";
import "./SupportedContractsManager.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Battle of Chains
/// @author LAOS Team and Freeverse

// TODOS:
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
// consider need for actionHash if we don't have supportHash

contract BattleOfChains is Ownable, IBattleOfChains, URIManager, SupportedContractsManager {

    IEvolutionCollection public immutable collectionContract;
    mapping(address user => uint32 homeChain) public homeChainOfUser;

    constructor(address _laosCollectionAddress) Ownable(msg.sender) {
        collectionContract = IEvolutionCollection(_laosCollectionAddress);
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

    function proposeChainAction(ChainAction calldata _chainAction) public returns (bytes32 _chainActionHash) {
        return _proposeChainAction(msg.sender, _chainAction);
    }

    function proposeChainActionOnBehalfOf(address _user, ChainAction calldata _chainAction) public returns (bytes32 _chainActionHash) {
        return _proposeChainAction(_user, _chainAction);
    }

    function _proposeChainAction(address _user, ChainAction calldata _chainAction) private returns (bytes32 _chainActionHash) {
        if (!areChainActionInputsCorrect(_chainAction)) revert IncorrectAttackInput();
        _chainActionHash = hashChainAction(_chainAction);
        emit ChainActionProposal(msg.sender, _user, _chainAction, _chainActionHash);
        return _chainActionHash;
    }

    function areChainActionInputsCorrect(ChainAction calldata _chainAction) public pure returns (bool _isOK) {
        bool _isAttackAddressNull = _chainAction.attackAddress == address(0);
        bool _isAttackAreaNull = _chainAction.attackArea == Attack_Area.NULL;
        if  (_chainAction.actionType == ChainActionType.ATTACK_AREA) {
            return _isAttackAddressNull && !_isAttackAreaNull;
        }
        if  (_chainAction.actionType == ChainActionType.ATTACK_ADDRESS) {
            return !_isAttackAddressNull && _isAttackAreaNull;
        }
        return _isAttackAddressNull && _isAttackAreaNull;
    }

    function hashChainAction(ChainAction calldata _chainAction) public pure returns (bytes32) {
        return keccak256(
            abi.encode(
                _chainAction.actionType,
                _chainAction.attackArea,
                _chainAction.attackAddress
            )
        );
    }

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
