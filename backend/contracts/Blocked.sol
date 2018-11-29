pragma solidity ^0.4.23;

contract ERC721 {
    // Required methods
    function totalSupply() public view returns (uint256 total);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function ownerOf(uint256 _tokenId) external view returns (address owner);
    function approve(address _to, uint256 _tokenId) external;
    function transfer(address _to, uint256 _tokenId) external;
    function transferFrom(address _from, address _to, uint256 _tokenId) external;

    // Events
    event Transfer(address from, address to, uint256 tokenId);
    event Approval(address owner, address approved, uint256 tokenId);

    // ERC-165 Compatibility (https://github.com/ethereum/EIPs/issues/165)
    function supportsInterface(bytes4 _interfaceID) external view returns (bool);
}

contract GunAccessControl {
    // This facet controls access control for Blocked and Loaded. There are four roles managed here:
    //
    //     - The CEO: The CEO can reassign other roles and change the addresses of our dependent smart
    //         contracts. It is also the only role that can unpause the smart contract. It is initially
    //         set to the address that created the smart contract in the GunCore constructor.
    //
    //     - The CFO: The CFO can withdraw funds from GunCore and its auction contracts.
    //
    //     - The COO
    //
    // It should be noted that these roles are distinct without overlap in their access abilities, the
    // abilities listed for each role above are exhaustive. In particular, while the CEO can assign any
    // address to any role, the CEO address itself doesn't have the ability to act in those roles. This
    // restriction is intentional so that we aren't tempted to use the CEO address frequently out of
    // convenience. The less we use an address, the less likely it is that we somehow compromise the
    // account.

    event ContractUpgrade(address newContract);

    // The addresses of the accounts (or contracts) that can execute actions within each roles.
    address public ceoAddress;
    address public cfoAddress;
    address public cooAddress;

    // Keeps track whether the contract is paused. When that is true, most actions are blocked
    bool public paused = false;

    /// Access modifier for CEO-only functionality
    modifier onlyCEO() {
        require(msg.sender == ceoAddress);
        _;
    }

    /// Access modifier for CFO-only functionality
    modifier onlyCFO() {
        require(msg.sender == cfoAddress);
        _;
    }

    /// Access modifier for COO-only functionality
    modifier onlyCOO() {
        require(msg.sender == cooAddress);
        _;
    }

    modifier onlyCLevel() {
        require(
            msg.sender == cooAddress ||
            msg.sender == ceoAddress ||
            msg.sender == cfoAddress
        );
        _;
    }

    /// Assigns a new address to act as the CEO. Only available to the current CEO.
    function setCEO(address _newCEO) external onlyCEO {
        require(_newCEO != address(0));

        ceoAddress = _newCEO;
    }

    /// Assigns a new address to act as the CFO. Only available to the current CEO.
    function setCFO(address _newCFO) external onlyCEO {
        require(_newCFO != address(0));

        cfoAddress = _newCFO;
    }

    /// Assigns a new address to act as the COO. Only available to the current CEO.
    function setCOO(address _newCOO) external onlyCEO {
        require(_newCOO != address(0));

        cooAddress = _newCOO;
    }

    /*** Pausable functionality adapted from OpenZeppelin ***/

    /// Modifier to allow actions only when the contract IS NOT paused
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /// Modifier to allow actions only when the contract IS paused
    modifier whenPaused {
        require(paused);
        _;
    }

    /// Called by any "C-level" role to pause the contract.
    function pause() external onlyCLevel whenNotPaused {
        paused = true;
    }

    ///  Unpauses the smart contract. Can only be called by the CEO, since
    ///  one reason we may pause the contract is when CFO or COO accounts are
    ///  compromised.
    function unpause() public onlyCEO whenPaused {
        paused = false;
    }
}

contract GunBase is GunAccessControl {
    //Transfer event as defined in current draft of ERC721. Emitted every time
    //a gun ownership is assigned.
    event Transfer(address from, address to, uint256 tokenId);

    //An approximation of currently how many seconds are in between block
    uint256 public secondsPerBlock = 15;

    //Main Gun Struct. 
    struct Gun {
        string name;
        string serial;
        string manufacturer;
        address owner;
    }

    //All guns in existence. The ID of each gun is an index to this array. Gun ID 0 is invalid.
    Gun[] gunRecords;

    //Mapping of gun's ID to address of the owner.
    mapping(uint256 => address) public gunIndexToOwner;

    //Mapping from owner address to count of tokens that address owns.
    mapping(address => uint256) ownershipTokenCount;

    //Mapping from GunIDs to an address that has been approved to call transferFrom().
    //Each Gun can only have 1 approved address for transfer at any time.
    mapping(uint256 => address) public gunIndexToApproved;

    //The address of the ClockAuction contract that handles sales of Guns. This also handles
    //P2P sales.

    //Assigns ownership of a specific Gun to a new address.
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        ownershipTokenCount[_to]++;
        gunIndexToOwner[_tokenId] = _to;

        if (_from != address(0)) {
            ownershipTokenCount[_from]--;
            delete gunIndexToApproved[_tokenId];
        }

        emit Transfer(_from, _to, _tokenId);
    }

    //Creates a new Gun Struct.
    function createGun(string _name, string _serial, string _manufacturer, address _owner) internal returns (uint) {
        Gun memory _newGun = Gun({
            name: _name,
            serial: _serial,
            manufacturer: _manufacturer,
            owner: _owner
        });

        uint256 newGunID = gunRecords.push(_newGun) - 1;
        require(newGunID == uint256(uint32(newGunID)));

        _transfer(0, _owner, newGunID);

        return newGunID;
    }

    function setSecondsPerBlock(uint256 secs) external {
        secondsPerBlock = secs;
    }
}

contract ERC721Metadata {
    /// @dev Given a token Id, returns a byte array that is supposed to be converted into string.
    function getMetadata(uint256 _tokenId, string) public view returns (bytes32[4] buffer, uint256 count) {
        if (_tokenId == 1) {
            buffer[0] = "Hello World! :D";
            count = 15;
        } else if (_tokenId == 2) {
            buffer[0] = "I would definitely choose a medi";
            buffer[1] = "um length string.";
            count = 49;
        } else if (_tokenId == 3) {
            buffer[0] = "Lorem ipsum dolor sit amet, mi e";
            buffer[1] = "st accumsan dapibus augue lorem,";
            buffer[2] = " tristique vestibulum id, libero";
            buffer[3] = " suscipit varius sapien aliquam.";
            count = 128;
        }
    }
}

contract GunOwnership is GunBase, ERC721 {
    //Name and symbol of the non fungible token.
    string public constant name = "PISTL";
    string public constant symbol = "P";

    // The contract that will return gun metadata
    ERC721Metadata public erc721Metadata;

    bytes4 constant InterfaceSignature_ERC165 = bytes4(keccak256("supportsInterface(bytes4)"));

    bytes4 constant InterfaceSignature_ERC721 =
        bytes4(keccak256('name()')) ^
        bytes4(keccak256('symbol()')) ^
        bytes4(keccak256('totalSupply()')) ^
        bytes4(keccak256('balanceOf(address)')) ^
        bytes4(keccak256('ownerOf(uint256)')) ^
        bytes4(keccak256('approve(address,uint256)')) ^
        bytes4(keccak256('transfer(address,uint256)')) ^
        bytes4(keccak256('transferFrom(address,address,uint256)')) ^
        bytes4(keccak256('tokensOfOwner(address)')) ^
        bytes4(keccak256('tokenMetadata(uint256,string)'));

    /// @notice Introspection interface as per ERC-165 (https://github.com/ethereum/EIPs/issues/165).
    ///  Returns true for any standardized interfaces implemented by this contract. We implement
    ///  ERC-165 (obviously!) and ERC-721.
    function supportsInterface(bytes4 _interfaceID) external view returns (bool)
    {
        return ((_interfaceID == InterfaceSignature_ERC165) || (_interfaceID == InterfaceSignature_ERC721));
    }

    /// @dev Set the address of the sibling contract that tracks metadata.
    ///  CEO only.
    function setMetadataAddress(address _contractAddress) public onlyCEO {
        erc721Metadata = ERC721Metadata(_contractAddress);
    }

    //Checks if given address is current owner of a particular gun.
    function _owns(address _claimer, uint256 _tokenID) internal view returns (bool) {
        return gunIndexToOwner[_tokenID] == _claimer;
    }

    //Checks if a given address currently has transferApproval for a specified gun.
    function _approvedFor(address _claimer, uint256 _tokenId) internal view returns (bool) {
        return gunIndexToApproved[_tokenId] == _claimer;
    }

    //Allows address to be approved for transferFrom().
    function _approve(uint256 _tokenId, address _approved) internal {
        gunIndexToApproved[_tokenId] = _approved;
    }

    // Returns the number of Guns owned by a specific address.
    function balanceOf(address _owner) public view returns (uint256 count) {
        return ownershipTokenCount[_owner];
    }

    // Transfers a Gun to another address.
    function transfer(address _to, uint256 _tokenId) external whenNotPaused {
        // Safety check to prevent against an unexpected 0x0 default.
        require(_to != address(0));
        // Disallow transfers to this contract to prevent accidental misuse.
        // The contract should never own any guns.
        require(_to != address(this));

        // You can only transfer your own gun.
        require(_owns(msg.sender, _tokenId));

        // Reassign ownership and emit Transfer event.
        _transfer(msg.sender, _to, _tokenId);
    }

    // Grant another address the right to transfer ownership of a specific Gun.
    function approve(address _to, uint256 _tokenId) external whenNotPaused {
        // Only an owner can grant transfer approval.
        require(_owns(msg.sender, _tokenId));

        // Register the approval (replacing any previous approval).
        _approve(_tokenId, _to);

        // Emit approval event.
        emit Approval(msg.sender, _to, _tokenId);
    }

    // Transfer a Gun owned by another address, for which the calling address
    //  has previously been granted transfer approval by the owner.
    function transferFrom(address _from, address _to, uint256 _tokenId) external whenNotPaused {
        // Safety check to prevent against an unexpected 0x0 default.
        require(_to != address(0));
        // Disallow transfers to this contract to prevent accidental misuse.
        // The contract should never own any guns.
        require(_to != address(this));
        // Check for approval and valid ownership
        require(_approvedFor(msg.sender, _tokenId));
        require(_owns(_from, _tokenId));

        // Reassign ownership and emits Transfer event.
        _transfer(_from, _to, _tokenId);
    }

    // Returns the total number of Guns currently in existence.
    function totalSupply() public view returns (uint) {
        return gunRecords.length - 1;
    }

    // Returns the address currently assigned ownership of a given Gun.
    function ownerOf(uint256 _tokenId) external view returns (address owner) {
        owner = gunIndexToOwner[_tokenId];

        require(owner != address(0));
    }

    // Returns a list of all Gun IDs assigned to an address.
    function tokensOfOwner(address _owner) external view returns(uint256[] ownerTokens) {
        uint256 tokenCount = balanceOf(_owner);

        if (tokenCount == 0) {
            // Return an empty array
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 totalGuns = totalSupply();
            uint256 resultIndex = 0;

            // We count on the fact that all guns have IDs starting at 1 and increasing
            // sequentially up to the totalGun count.
            uint256 gunId;

            for (gunId = 1; gunId <= totalGuns; gunId++) {
                if (gunIndexToOwner[gunId] == _owner) {
                    result[resultIndex] = gunId;
                    resultIndex++;
                }
            }

            return result;
        }
    }
}

//Blocked and Loaded main contract.
contract GunCore is GunOwnership {

    // This is the main Blocked and Loaded contract.
    //
    // The core contract is broked into multiple files using inheritence, one for each major
    // facet of functionality of PISTL. The breakdown is as follows:
    //
    //      - GunBase: This is where we define the most fundamental code shared throughout the core
    //             functionality. This includes our main data storage, constants and data types, plus
    //             internal functions for managing these items.
    //
    //      - GunAccessControl: This contract manages the various addresses and constraints for operations
    //             that can be executed only by specific roles. Namely CEO, CFO and COO.
    //
    //      - GunOwnership: This provides the methods required for basic non-fungible token
    //             transactions, following the draft ERC-721 spec (https://github.com/ethereum/EIPs/issues/721).

    //Set in case the core contract is broken and an upgrade is required
    address public newContractAddress;

    //Creates the main Blocked and Loaded smart contract instance.
    constructor() public {
        // Starts paused.
        paused = true;

        // the creator of the contract is the initial CEO
        ceoAddress = msg.sender;

        // the creator of the contract is also the initial COO
        cooAddress = msg.sender;

        // start with invalid gun to prevent ownership issues.
        createGun("", "", "", address(0));
    }

    ///  Used to mark the smart contract as upgraded, in case there is a serious
    ///  breaking bug. This method does nothing but keep track of the new contract and
    ///  emit a message indicating that the new address is set. It's up to clients of this
    ///  contract to update to the new contract address in that case. (This contract will
    ///  be paused indefinitely if such an upgrade takes place.)
    function setNewAddress(address _v2Address) external onlyCEO whenPaused {
        // See README.md for updgrade plan
        newContractAddress = _v2Address;
        emit ContractUpgrade(_v2Address);
    }

    /// Returns all the relevant information about a specific gun.
    function getGun(uint256 _id)
        external
        view
        returns (
        string name,
        string manufacturer,
        string serialNumber
    ) {
        Gun storage _gun = gunRecords[_id];

        // if this variable is 0 then it's not gestating
        name = _gun.name;
        manufacturer = _gun.manufacturer;
        serialNumber = _gun.serial;
    }

    ///  Override unpause so it requires all external contract addresses
    ///  to be set before contract can be unpaused. Also, we can't have
    ///  newContractAddress set either, because then the contract was upgraded.
    function unpause() public onlyCEO whenPaused {
        require(newContractAddress == address(0));

        // Actually unpause the contract.
        super.unpause();
    }
}