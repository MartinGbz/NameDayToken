// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@arachnid/contracts/strings.sol";
import "forge-std/console.sol";

abstract contract ENS {
    function resolver(bytes32 node) public virtual view returns (Resolver);
}

abstract contract Resolver {
    function addr(bytes32 node) public virtual view returns (address);
}

contract NameDayToken is ERC20 {

    using strings for *;
    
    string private _dayName;
    uint256 private _nameDayTimestamp;
    uint256 private _mintPerUserPerYear;
    uint256 private _maxSupply;
    uint16 private _baseYear;
    uint256 private constant YEAR_IN_SECONDS = 31536000; // Number of seconds in a year (365 days)
    uint256 private constant DAY_IN_SECONDS = 86400; // Number of seconds in a day (24 hours)

    mapping(uint16 => mapping(string => bool)) private _minted;

    constructor(string memory name_, string memory symbol_, string memory dayName_, uint256 nameDayTimestamp_, uint256 mintPerUserPerYear_, uint256 maxSupply_) ERC20(name_, symbol_) {
        _nameDayTimestamp = nameDayTimestamp_;
        _mintPerUserPerYear = mintPerUserPerYear_;
        _dayName = dayName_;
        _maxSupply = maxSupply_;
        _baseYear = _getCurrentYear();
    }

    function dayName() public view virtual returns (string memory) {
        return _dayName;
    }

    function nameDayTimestamp() public view virtual returns (uint256) {
        return _nameDayTimestamp;
    }

    function mintPerUserPerYear() public view virtual returns (uint256) {
        return _mintPerUserPerYear;
    }

    function maxSupply() public view virtual returns (uint256) {
        return _maxSupply;
    }

    function getBaseYear() public view virtual returns (uint16) {
        return _baseYear;
    }

    function _getCurrentYear() private view returns (uint16) {
        console.log(block.timestamp);
        console.log(_nameDayTimestamp);
        console.log(YEAR_IN_SECONDS);
        console.log(uint16((block.timestamp - _nameDayTimestamp) / YEAR_IN_SECONDS));
        return uint16((block.timestamp - _nameDayTimestamp) / YEAR_IN_SECONDS);
    }

    // function _getCurrentYear() private view returns (uint16) {
    //     return uint16((block.timestamp - _nameDayTimestamp) / YEAR_IN_SECONDS);
    // }

    // Same address for Mainnet, Ropsten, Rinkerby, Gorli and other networks;
    ENS ens = ENS(0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e);

    function resolve(bytes32 node) public view returns(address) {
        Resolver resolver = ens.resolver(node);
        require(address(resolver) != address(0), "Resolver has not been found");
        address ensName = resolver.addr(node);
        require(address(resolver) != address(0), "Address can't be resolved");
        return ensName;
    }

    // computeNamehash for ENS (function not recursive - subdomains are not supported)
    function computeNamehash(string memory name_) public pure returns (bytes32 namehash) {
        namehash = 0x0000000000000000000000000000000000000000000000000000000000000000;
        namehash = keccak256(
        abi.encodePacked(namehash, keccak256(abi.encodePacked('eth')))
        );
        namehash = keccak256(
        abi.encodePacked(namehash, keccak256(abi.encodePacked(name_)))
        );
    }

    function _isUserAllowed (string memory ensName) private view returns (bool) {
        require(!ensName.toSlice().startsWith(".eth".toSlice()), "ENS name not valid. Please remove the .eth extension");
        require(ensName.toSlice().contains(_dayName.toSlice()), "Only an owner of an ENS name that contains ".toSlice().concat(_dayName.toSlice()).toSlice().concat(" can mint tokens".toSlice()));
        require(!_minted[_getCurrentYear()][ensName], "You already minted tokens this year");

        bytes32 namehash = computeNamehash(ensName);
        address ensResolved = resolve(namehash);
        if(ensResolved == msg.sender) {
            return true;
        } 
        else {
            return false;
        }
    }

    function isLeap(uint256 year) public pure returns (bool) {
        if (year % 4 != 0) {
            return false;
        } else if (year % 100 != 0) {
            return true;
        } else if (year % 400 == 0) {
            return true;
        } else {
            return false;
        }
    }

    function _isRightDay() private view returns (bool) {
        uint256 currentTime = block.timestamp;
        if(currentTime < _nameDayTimestamp) {
            return false;
        }
        // uint256 currentYear = (currentTime - _nameDayTimestamp) / YEAR_IN_SECONDS;
        uint16 currentYear = _getCurrentYear();
        uint256 nextDayTimestamp = _nameDayTimestamp + currentYear * YEAR_IN_SECONDS;
        // uint256 currentYear = _baseYear + yearsPassed;

        // console.logUint(currentTime);
        // console.logUint(yearsPassed);
        // console.logUint(nextDayTimestamp);
        // console.logUint(currentYear);

        // add leap days
        // doesn't take into account the current year because it's not finished yet
        for (uint16 i = _baseYear; i < currentYear; i++) {
            if (isLeap(i)) {
                nextDayTimestamp += DAY_IN_SECONDS;
            }
        }
 
        return (currentTime >= nextDayTimestamp && currentTime < nextDayTimestamp+DAY_IN_SECONDS);
    }

    function _isMaxSupplyReach(uint256 amount) private view returns (bool) {
        return totalSupply() + amount <= _maxSupply;
    }

    function transfer(address to, uint256 value) public override returns (bool) {
        require(_isMaxSupplyReach(value), "Max supply reached");
        require(_isRightDay(), "Transfers are only allowed on ".toSlice().concat(_dayName.toSlice()).toSlice().concat("'s day".toSlice()));
        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        require(_isMaxSupplyReach(value), "Max supply reached");
        require(_isRightDay(), "Transfers are only allowed on ".toSlice().concat(_dayName.toSlice()).toSlice().concat("'s day".toSlice()));
        return super.transferFrom(from, to, value);
    }

    function mint (string memory ensName) public {
        require(_isMaxSupplyReach(_mintPerUserPerYear), "Max supply reached");
        require(_isRightDay(), "Transfers are only allowed on ".toSlice().concat(_dayName.toSlice()).toSlice().concat("'s day".toSlice()));
        require(_isUserAllowed(ensName), "Only the owner of the ENS name can mint tokens");
        _mint(msg.sender, _mintPerUserPerYear);
        _minted[_getCurrentYear()][ensName] = true;
    }
}