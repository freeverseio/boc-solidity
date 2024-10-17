// Sources flattened with hardhat v2.22.13 https://hardhat.org

// SPDX-License-Identifier: GPL-3.0-only AND MIT

// File @openzeppelin/contracts/utils/Context.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}


// File @openzeppelin/contracts/access/Ownable.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// File contracts/IBattleOfChains.sol

// Original license: SPDX_License_Identifier: GPL-3.0-only
pragma solidity >=0.8.20;

/**
 * @title IBattleOfChains Interface
 * @dev Interface for the Battle of Chains contract, which defines
 * the structure and functions required for implementing the Battle of Chains logic.
 * This interface outlines the core functionalities for managing user actions,
 * cross-chain interactions, and NFT minting in a game environment.
 * It is intended to be implemented by contracts that manage game logic and interactions.
 * @notice Developed and maintained by the LAOS Team and Freeverse.
 */

interface IBattleOfChains {
    /**
     * @dev The set of possible chain actions:
     */
    enum ChainActionType {
        DEFEND,
        IMPROVE,
        ATTACK_AREA,
        ATTACK_ADDRESS
    }

    /**
     * @dev
     * The set of possible attack areas used in actions of type ATTACK_AREA
     * If the desired action is not of type ATTACK_AREA, then AttackArea must be set to NULL
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
     * @dev Represents an action proposed to / voted by a user to its home chain
     * Used as input to functions that require details about chain actions,
     * as well as to emitted events.
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
     * @dev Emitted when a user joins a chain. The chain is specified by its chain ID
     */
    event JoinedChain(address indexed _user, uint32 indexed _homeChain);

    /**
     * @dev Emitted when a user performs a multichain mint, specifying the homechain
     * to which the user is assigned, the type of mint, and the tokenId.
     * The resulting tokenId identifies every NFT produced in all supported contracts
     * on all supported chains.
     */
    event MultichainMint(
        uint256 _tokenId,
        address indexed _user,
        uint256 indexed _type,
        uint32 indexed _homeChain
    );

    /**
     * @dev Emitted when a user performs an attack within a target chain, at the specified targetAddress,
     * using the assets owned in the target chain, with the provided attack strategy.
     * If _tokenIds is an empty list, the attack defaults to using all available assets owned by the sender in the target chain.
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
     * @notice Assigns the sender of the transaction to the specified chain. The assignment cannot be changed.
     * @dev Reverts if called more than once. ChainId = 0 is not allowed.
     * @param _homeChain the chainId of the chain to assign to the sender
     */
    function joinHomeChain(uint32 _homeChain) external;

    /**
     * @notice Mints NFTs across all supported chains of the provided _type
     * @notice The attributes of the minted NFT depend on the current state of the user and the game
     * @notice Reverts if the provided token type is not supported
     * @param _type An integer specifying the desired type of minted NFTs
     * @return _tokenId The tokenId that identifies the minted NFTs in the contracts on all supported chains
     */
    function multichainMint(uint256 _type) external returns (uint256 _tokenId);

    /**
     * @notice Executes an attack on the specified target chain, at the specified targetAddress, using the sender's assets in the target chain
     * @notice specified by _tokenIds, using the provided attack strategy.
     * @notice If _tokenIds is an empty list, the attack defaults to using all available assets owned by the sender in the target chain.
     * @notice The effect of the attack depends on the offchain state of the user and the game.
     * @param _tokenIds the list of the NFTs participating in the attack. If empty, all possible assets are used.
     * @param _targetAddress the address in the targetChain to attack.
     * @param _targetChain the chainId of the chain where the attack is to be performed.
     * @param _strategy a uint32 specifying the attack strategy.
     */
    function attack(
        uint256[] calldata _tokenIds,
        address _targetAddress,
        uint32 _targetChain,
        uint32 _strategy
    ) external;

    /**
     * @notice Tries to perform an attack on behalf of the provided attacker address.
     * @notice The effect is disregarded off-chain unless the user has authorized the transaction sender as an operator
     * @notice If not disregarded, it executes an attack on the provided target chain, at the provided targetAddress, with the assets
     * @notice owned by the sender in the target chain, specified by the provided _tokenIds, using the provided attack strategy.
     * @notice If _tokenIds is an empty list, the attack defaults to using all available assets owned by the sender in the target chain.
     * @notice The effect of the attack depends on the offchain state of the attacker and the game.
     * @param _tokenIds the list of the NFTs participating in the attack. If empty, all possible assets are used.
     * @param _targetAddress the address in the targetChain to attack.
     * @param _targetChain the chainId of the chain where the attack is to be performed.
     * @param _strategy a uint32 specifying the attack strategy.
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
     * @notice Votes for the homeChain of the sender to perform the provided chain action during
     * @notice the current voting period. The effect of the vote depends on the current state of the user and the game
     * @param _chainAction The desired action to be performed by the chain of the sender in the current period
     * @param _comment An optional string providing arguments for the proposed action
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
     * @param _chainAction The desired action to be performed by the chain of the provided user in the current period
     * @param _comment An optional string providing arguments for the proposed action
     */
    function proposeChainActionOnBehalfOf(
        address _user,
        ChainAction calldata _chainAction,
        string calldata _comment
    ) external;

    /**
     * @notice Returns true if the provided user has previously joined a chain
     * @param _user the address of the user
     */
    function hasHomeChain(address _user) external view returns (bool);

    /**
     * @notice Returns true if the provided chainAction is formally correct
     * @param _chainAction the desired action to be performed by the chain of the provided user in the current period
     * @return _isOK true if the provided chainAction is formally correct
     */
    function areChainActionInputsCorrect(ChainAction calldata _chainAction) external pure returns (bool _isOK);

    /**
     * @notice Returns the user that executed the multichain mint corresponding to the provided tokenId.
     * @notice Note that NFTs minted on different chains may have been traded and may be owned by other players.
     * @param _tokenId the tokenId of the multichain mint
     * @return _creator the address of the user that executed the multichain mint
     */
    function creatorFromTokenId(uint256 _tokenId) external pure returns(address _creator);

    /**
     * @notice Returns the (x,y) coordinates associated to the provided address
     * @param _user the address of the user
     */
    function coordinatesOf(address _user) external pure returns (uint256 _x, uint256 _y);

}


// File contracts/IEvolutionCollection.sol

// Original license: SPDX_License_Identifier: GPL-3.0-only
pragma solidity >=0.8.20;

/// @title Pallet Laos Evolution Interface
/// @author LAOS Team
/// @notice This interface allows Solidity contracts to interact with pallet-laos-evolution
interface IEvolutionCollection {
    /// @notice Emitted when a new token is minted
    /// @notice The emitted tokenURI has not undergone any on-chain validation.
    /// @notice Users are fully responsible for accuracy,
    /// @notice authenticity and preventing potential misuse or exploits.
    /// @dev Id of the token is concatenation of `slot` and `to`
    /// @param _to the initial owner of the newly minted token
    /// @param _slot the slot of the token
    /// @param _tokenId the resulting id of the newly minted token
    /// @param _tokenURI the URI of the newly minted token
    event MintedWithExternalURI(
        address indexed _to,
        uint96 _slot,
        uint256 _tokenId,
        string _tokenURI
    );

    /// @notice Emitted when a token metadata is updated
    /// @notice The emitted tokenURI has not undergone any on-chain validation.
    /// @notice Users are fully responsible for accuracy,
    /// @notice authenticity and preventing potential misuse or exploits.
    /// @param _tokenId the id of the token for which the metadata has changed
    /// @param _tokenURI the new URI of the token
    event EvolvedWithExternalURI(uint256 indexed _tokenId, string _tokenURI);

    /// @notice Emitted when ownership of the collection changes
    /// @param _previousOwner the previous owner of the collection
    /// @param _newOwner the new owner of the collection
    event OwnershipTransferred(
        address indexed _previousOwner,
        address indexed _newOwner
    );

    /// @notice Owner of the collection
    /// @dev Call this function to get the owner of a collection
    /// @return the owner of the collection
    function owner() external view returns (address);

    /// @notice Provides a distinct Uniform Resource Identifier (URI) for a given token within a specified collection.
    /// @notice The tokenURI returned by this method has not undergone
    /// @notice any on-chain validation. Users are fully responsible for accuracy,
    /// @notice authenticity and preventing potential misuse or exploits.
    /// @dev Implementations must follow the ERC-721 standard for token URIs, which should point to a JSON file conforming to the "ERC721 Metadata JSON Schema".
    /// @param _tokenId The unique identifier of the token within the specified collection.
    /// @return A string representing the URI of the specified token.
    function tokenURI(uint256 _tokenId) external view returns (string memory);

    /// @notice Mint a new token
    /// @notice The tokenURI provided to this method does not undergo
    /// @notice any on-chain validation. Users are fully responsible for accuracy,
    /// @notice authenticity and preventing potential misuse or exploits.
    /// @dev Call this function to mint a new token, the caller must be the owner of the collection
    /// @param _to the owner of the newly minted token
    /// @param _slot the slot of the token
    /// @param _tokenURI the tokenURI of the newly minted token
    /// @return the id of the newly minted token
    function mintWithExternalURI(
        address _to,
        uint96 _slot,
        string calldata _tokenURI
    ) external returns (uint256);

    /// @notice Changes the tokenURI of an existing token
    /// @notice The tokenURI provided to this method does not undergo
    /// @notice any on-chain validation. Users are fully responsible for accuracy,
    /// @notice authenticity and preventing potential misuse or exploits.
    /// @dev Call this function to evolve an existing token, the caller must be the owner of the collection
    /// @param _tokenId the id of the token
    /// @param _tokenURI the new tokenURI of the token
    function evolveWithExternalURI(
        uint256 _tokenId,
        string calldata _tokenURI
    ) external;

    /// @notice Transfers ownership of the collection to a new account (`newOwner`).
    /// @dev Call this function to transfer ownership of the collection, the caller must be the owner of the collection
    /// @param _newOwner The address to transfer ownership to.
    function transferOwnership(address _newOwner) external;
}


// File contracts/ISupportedContractsManager.sol

// Original license: SPDX_License_Identifier: GPL-3.0-only
pragma solidity >=0.8.20;

/**
 * @title Interface to contract that manages the set of supported contracts
 * @notice Developed and maintained by the LAOS Team and Freeverse.
 */

interface ISupportedContractsManager {
    /**
     * @dev Represents a supported contract, detailing the chain ID and address of deploy,
     * as well as an optional description of the contract
     */
    struct Contract {
        uint32 chain;
        address contractAddress;
        string observations;
    }

    error SenderIsNotSupportedContractsManager();

    /**
     * @notice Sets the address with permissions to manage the set of supported contracts
     * @param _newManager the new address that will have permission to add supported contracts
     */
    function setSupportedContractsManager(address _newManager) external;

    /**
     * @notice Adds a new supported contract
     * @param _chain the chain ID where the contract is deployed
     * @param _contractAddress the address of the deployed contract
     * @param _observations opntional description of the supported contract
     */
    function addSupportedContract(
        uint32 _chain,
        address _contractAddress,
        string calldata _observations
    ) external;

    /**
     * @notice Returns all currently supported contracts
     * @return _allContracts an array with all currently supported contracts
     */
    function allSupportedContracts() external view returns(Contract[] memory _allContracts);

}


// File contracts/SupportedContractsManager.sol

// Original license: SPDX_License_Identifier: GPL-3.0-only
pragma solidity >=0.8.20;

/**
 * @title  Contract that manages the set of supported contracts
 * @notice Developed and maintained by the LAOS Team and Freeverse.
 */

contract SupportedContractsManager is ISupportedContractsManager {
    // The address authorized to manage the supported contracts
    address public supportedContractsManager;

    // The array containing all currently supported contracts
    Contract[] public supportedContracts;

    modifier onlySupportedContractsManager {
        if (msg.sender != supportedContractsManager) revert SenderIsNotSupportedContractsManager();
        _;
    }

    constructor() {
        supportedContractsManager = msg.sender;
    }

    /// @inheritdoc ISupportedContractsManager
    function setSupportedContractsManager(address _newManager) public onlySupportedContractsManager {
        supportedContractsManager = _newManager;
    }

    /// @inheritdoc ISupportedContractsManager
    function addSupportedContract(
        uint32 _chain,
        address _contractAddress,
        string calldata _observations
    ) public onlySupportedContractsManager {
        supportedContracts.push(
            Contract({
                chain: _chain,
                contractAddress: _contractAddress,
                observations: _observations
            })
        );
    }

    /// @inheritdoc ISupportedContractsManager
    function allSupportedContracts() external view returns(Contract[] memory _allContracts) {
        _allContracts = new Contract[](supportedContracts.length);
        for (uint256 i = 0; i < supportedContracts.length; i++) {
            _allContracts[i] = supportedContracts[i];
        }
    }
}


// File contracts/IURIManager.sol

// Original license: SPDX_License_Identifier: GPL-3.0-only
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


// File contracts/URIManager.sol

// Original license: SPDX_License_Identifier: GPL-3.0-only
pragma solidity >=0.8.20;

/**
 * @title Contract that manages URIs
 * @notice Developed and maintained by the LAOS Team and Freeverse.
 */

contract URIManager is IURIManager {
    // The address authorized to manage this contract's URIs
    address public uriManager;

    // The map of on-chain assignments of a URI to each token type
    string[] public tokenURIForType;

    modifier onlyURIManager() {
        if (msg.sender != uriManager) revert SenderIsNotURIManager();
        _;
    }

    constructor() {
        uriManager = msg.sender;
    }

    /// @inheritdoc IURIManager
    function setURIManager(address _newManager) public onlyURIManager {
        uriManager = _newManager;
    }

    /// @inheritdoc IURIManager
    function addTokenURIs(
        string[] memory _tokenURIs
    ) public onlyURIManager {
        for (uint256 i = 0; i < _tokenURIs.length; i++) {
            tokenURIForType.push(_tokenURIs[i]);
        }
    }

    /// @inheritdoc IURIManager
    function changeTokenURIs(
        uint256[] memory _types,
        string[] memory _tokenURIs
    ) public onlyURIManager {
        if (_types.length != _tokenURIs.length) revert IncorrectArrayLengths();
        for (uint256 i = 0; i < _types.length; i++) {
            if (!isTypeDefined(_types[i])) revert TokenURIForTypeNotDefined(_types[i]);
            tokenURIForType[_types[i]] = _tokenURIs[i];
        }
    }

    /// @inheritdoc IURIManager
    function nDefinedTypes() public view returns(uint256) {
        return tokenURIForType.length;
    }

    /// @inheritdoc IURIManager
    function isTypeDefined(uint256 _type) public view returns(bool) {
        return _type < tokenURIForType.length;
    }

}


// File contracts/BattleOfChains.sol

// Original license: SPDX_License_Identifier: GPL-3.0-only
pragma solidity >=0.8.20;





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
    function joinHomeChain(uint32 _homeChain) public {
        if (_homeChain == NULL_CHAIN) revert HomeChainMustBeGreaterThanZero();
        if (homeChainOf[msg.sender] != NULL_CHAIN)
            revert UserAlreadyJoinedChain(msg.sender, homeChainOf[msg.sender]);
        homeChainOf[msg.sender] = _homeChain;
        emit JoinedChain(msg.sender, _homeChain);
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

    /// @inheritdoc IBattleOfChains
    function hasHomeChain(address _user) public view returns (bool) {
        return homeChainOf[_user] != NULL_CHAIN;
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
