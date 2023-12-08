// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@arachnid/contracts/strings.sol";
import "@rollaProject/DateTime.sol";

abstract contract ENS {
    function resolver(bytes32 node) public virtual view returns (Resolver);
}

abstract contract Resolver {
    function addr(bytes32 node) public virtual view returns (address);
}

contract NameDayToken is ERC20 {

    using strings for *;
    using DateTime for *;
    
    string private _dayName;
    uint256 public immutable nameDayTimestamp;
    uint256 public immutable mintPerUserPerYear;
    uint256 public immutable maxSupply;
    uint256 public immutable baseTimestamp;
    uint256 private constant DAY_IN_SECONDS = 24 * 60 * 60; // Number of seconds in a day (24 hours)

    mapping(uint256 => mapping(string => bool)) private _mints;

    // Same address for Mainnet, Ropsten, Rinkerby, Gorli and other networks;
    ENS private constant ens = ENS(0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e);

    event Mint(uint256 indexed year, string indexed ensName);

    constructor(string memory name_, string memory symbol_, string memory dayName_, uint256 nameDayTimestamp_, uint256 mintPerUserPerYear_, uint256 maxSupply_) ERC20(name_, symbol_) {
        nameDayTimestamp = nameDayTimestamp_;
        mintPerUserPerYear = mintPerUserPerYear_;
        _dayName = dayName_;
        maxSupply = maxSupply_;
        baseTimestamp = block.timestamp;
    }

    function getCurrentYearNameDayTimestamp() public view returns (uint256) {
        uint256 currentYear = DateTime.getYear(block.timestamp);
        (, uint month, uint day, uint hour, uint minute, uint second) = DateTime.timestampToDateTime
        (nameDayTimestamp);
        return DateTime.timestampFromDateTime(currentYear, month, day, hour, minute, second);
    }

    function transfer(address to, uint256 value) public override returns (bool) {
        require(_isMaxSupplyNotReached(value), "Max supply reached");
        require(_isRightDay(), "Transfers are only allowed on ".toSlice().concat(_dayName.toSlice()).toSlice().concat("'s day".toSlice()));
        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        require(_isMaxSupplyNotReached(value), "Max supply reached");
        require(_isRightDay(), "Transfers are only allowed on ".toSlice().concat(_dayName.toSlice()).toSlice().concat("'s day".toSlice()));
        return super.transferFrom(from, to, value);
    }

    function mint (string memory ensName) public {
        require(_isMaxSupplyNotReached(mintPerUserPerYear), "Max supply reached");
        require(_isRightDay(), "Transfers are only allowed on ".toSlice().concat(_dayName.toSlice()).toSlice().concat("'s day".toSlice()));
        require(_isUserAllowed(ensName), "Only the owner of the ENS name can mint tokens");
        
        uint256 currentYear = DateTime.getYear(block.timestamp);
        _mints[currentYear][ensName] = true;

        _mint(msg.sender, mintPerUserPerYear);
        
        emit Mint(currentYear, ensName);
    }

    function dayName() external view virtual returns (string memory) {
        return _dayName;
    }

    function hasMinted(uint256 year, string calldata ensName) external view virtual returns (bool) {
        return _mints[year][ensName];
    }

    function getUserMints(string calldata ensName) external view virtual returns (bool[] memory) {
        uint256 currentYear = DateTime.getYear(block.timestamp);
        uint256 baseYear = DateTime.getYear(baseTimestamp);
        bool[] memory mints = new bool[](currentYear - baseYear + 1);
        uint256 i = 0;
        for (uint256 year = baseYear; year <= currentYear; year++) {
            mints[i] = _mints[year][ensName];
            i++;
        }
        return mints;
    }

    function _isUserAllowed (string memory ensName) private view returns (bool) {
        require(!ensName.toSlice().startsWith(".eth".toSlice()), "ENS name not valid. Please remove the .eth extension");
        require(ensName.toSlice().contains(_dayName.toSlice()), "Only an owner of an ENS name that contains ".toSlice().concat(_dayName.toSlice()).toSlice().concat(" can mint tokens".toSlice()));
        require(!_mints[DateTime.getYear(block.timestamp)][ensName], "You already minted tokens this year");

        bytes32 namehash = _computeNamehash(ensName);
        address ensResolved = _resolve(namehash);
        if(ensResolved == msg.sender) {
            return true;
        } 
        else {
            return false;
        }
    }

    function _isRightDay() private view returns (bool) {
        uint256 nextNameDayTimestamp = getCurrentYearNameDayTimestamp();
        
        // nextNameDayTimestamp + DAY_IN_SECONDS can overflow if the nextNameDayTimestamp it's > MAX_INT
        return (block.timestamp >= nextNameDayTimestamp && block.timestamp < nextNameDayTimestamp + DAY_IN_SECONDS);
    }

    function _isMaxSupplyNotReached(uint256 amount) private view returns (bool) {
        return totalSupply() + amount <= maxSupply;
    }

    function _resolve(bytes32 node) private view returns(address) {
        Resolver resolver = ens.resolver(node);
        require(address(resolver) != address(0), "Resolver has not been found");
        address ensName = resolver.addr(node);
        require(address(resolver) != address(0), "Address can't be resolved");
        return ensName;
    }

    // computeNamehash for ENS (function not recursive - subdomains are not supported)
    function _computeNamehash(string memory name_) private pure returns (bytes32 namehash) {
        namehash = 0x0000000000000000000000000000000000000000000000000000000000000000;
        namehash = keccak256(
        abi.encodePacked(namehash, keccak256(abi.encodePacked('eth')))
        );
        namehash = keccak256(
        abi.encodePacked(namehash, keccak256(abi.encodePacked(name_)))
        );
    }
}