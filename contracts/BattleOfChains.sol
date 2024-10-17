// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.20;

import "./IEvolutionCollection.sol";
import "./IBattleOfChains.sol";
import "./URIManager.sol";
import "./SupportedContractsManager.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title BattleOfChains Main Contract
 * @notice Developed and maintained by the LAOS Team and Freeverse.
 * TODOS:
 * - rethink naming everywhere
 * - estimate costs, and balance order of params, and number of params emitted
 */


contract BattleOfChains is Ownable, IBattleOfChains, URIManager, SupportedContractsManager {

    uint32 private constant NULL_CHAIN = 0;
    IEvolutionCollection public immutable collectionContract;
    mapping(address user => uint32 homeChain) public homeChainOf;

    constructor(address _laosCollectionAddress) Ownable(msg.sender) {
        collectionContract = IEvolutionCollection(_laosCollectionAddress);
    }

    /// @inheritdoc IBattleOfChains
    function joinHomeChain(uint32 _homeChain, string memory _userNickname) public {
        if (_homeChain == NULL_CHAIN) revert HomeChainMustBeGreaterThanZero();
        if (homeChainOf[msg.sender] != NULL_CHAIN)
            revert UserAlreadyJoinedChain(msg.sender, homeChainOf[msg.sender]);
        homeChainOf[msg.sender] = _homeChain;
        emit JoinedChain(msg.sender, _homeChain, _userNickname);
    }

    /// @inheritdoc IBattleOfChains
    function multichainMint(uint256 _type) public returns (uint256 _tokenId) {
        if (!isTypeDefined(_type)) revert TokenURIForTypeNotDefined(_type);
        uint32 _homeChain = homeChainOf[msg.sender];
        if (_homeChain == NULL_CHAIN) revert UserHasNotJoinedChainYet(msg.sender);
        uint96 _slot = uint96(uint256(blockhash(block.number - 1)));
        _tokenId = collectionContract.mintWithExternalURI(msg.sender, _slot, tokenURIForType[_type]);
        emit MultichainMint(_tokenId, msg.sender, _type, _homeChain);
        return _tokenId;
    }

    /// @inheritdoc IBattleOfChains
    function attack(
        uint256[] calldata _tokenIds,
        address _targetAddress,
        uint32 _targetChain,
        uint32 _strategy
    ) public {
        _attack(_tokenIds, _targetAddress, msg.sender, _targetChain, _strategy);
    }

    /// @inheritdoc IBattleOfChains
    function attackOnBehalfOf(
        uint256[] calldata _tokenIds,
        address _targetAddress,
        uint32 _targetChain,
        uint32 _strategy,
        address _attacker
    ) public {
        _attack(_tokenIds, _targetAddress, _attacker, _targetChain, _strategy);
    }

    /// @inheritdoc IBattleOfChains
    function proposeChainAction(
        ChainAction calldata _chainAction,
        string calldata _comment
    ) public {
        _proposeChainAction(msg.sender, _chainAction, _comment);
    }

    /// @inheritdoc IBattleOfChains
    function proposeChainActionOnBehalfOf(
        address _user,
        ChainAction calldata _chainAction,
        string calldata _comment
    ) public {
        _proposeChainAction(_user, _chainAction, _comment);
    }

    /// @inheritdoc IBattleOfChains
    function upgrade(uint32 _chain, uint256 _tokenId) public {
        _upgrade(msg.sender, _chain, _tokenId);
    }

    /// @inheritdoc IBattleOfChains
    function upgradeOnBehalfOf(address _user, uint32 _chain, uint256 _tokenId) public {
        _upgrade(_user, _chain, _tokenId);
    }

    function _attack(
        uint256[] calldata tokenIds,
        address _targetAddress,
        address _attacker,
        uint32 _targetChain,
        uint32 _strategy
    ) private {
        emit Attack(
            tokenIds,
            _targetAddress,
            msg.sender,
            _attacker,
            _targetChain,
            _strategy
        );
    }

    function _proposeChainAction(
        address _user,
        ChainAction calldata _chainAction,
        string calldata _comment
    ) private {
        uint32 _sourceChain = homeChainOf[_user];
        if (_sourceChain == NULL_CHAIN) revert UserHasNotJoinedChainYet(_user);
        if (!areChainActionInputsCorrect(_chainAction)) revert IncorrectAttackInput();
        emit ChainActionProposal(msg.sender, _user, _sourceChain, _chainAction, _comment);
    }

    function _upgrade(address _user, uint32 _chain, uint256 _tokenId) private {
        emit Upgrade(msg.sender, _user, _chain, _tokenId);
    }

    /// @inheritdoc IBattleOfChains
    function hasHomeChain(address _user) public view returns (bool) {
        return homeChainOf[_user] != NULL_CHAIN;
    }

    /// @inheritdoc IBattleOfChains
    function tokenURI(uint256 _tokenId) public view returns (string memory _tokenURI) {
        return collectionContract.tokenURI(_tokenId);
    }

    /// @inheritdoc IBattleOfChains
    function areChainActionInputsCorrect(ChainAction calldata _chainAction) public pure returns (bool _isOK) {
        bool _isAttackAddressNull = _chainAction.attackAddress == address(0);
        bool _isAttackAreaNull = _chainAction.attackArea == AttackArea.NULL;
        bool _isTargetChainNull = _chainAction.targetChain == NULL_CHAIN;
        if  (_chainAction.actionType == ChainActionType.ATTACK_AREA) {
            return !_isTargetChainNull && _isAttackAddressNull && !_isAttackAreaNull;
        }
        if (_chainAction.actionType == ChainActionType.ATTACK_ADDRESS) {
            return
                !_isTargetChainNull &&
                !_isAttackAddressNull &&
                _isAttackAreaNull;
        }
        return _isTargetChainNull && _isAttackAddressNull && _isAttackAreaNull;
    }

    /// @inheritdoc IBattleOfChains
    function creatorFromTokenId(uint256 _tokenId) public pure returns(address _creator) {
        return address(uint160(_tokenId));
    }

    /// @inheritdoc IBattleOfChains
    function coordinatesOf(address _user) public pure returns (uint256 _x, uint256 _y) {
        uint160 user160 = uint160(_user);

        _x = uint256(user160 >> 80);
        _y = uint256(user160 & ((1 << 80) - 1));
    }
}
