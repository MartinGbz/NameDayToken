// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "forge-std/console.sol";

// import 'ens-namehash/contracts/ENSNamehash.sol';

// import "@openzeppelin/contracts/utils/Strings.sol";

import "@arachnid/contracts/strings.sol";
// import "@arachnid/contracts/src/strings.sol";

import "forge-std/console.sol";


contract NameDayToken is ERC20 {

    using strings for *;
    // using strings for string;
    
    string private _dayName;
    // uint256 private nextDayTimestamp = 1000000 * 10 ** 18;
    uint256 private _nameDayTimestamp = 1674172800; // Timestamp for 20th January 2023, 00:00:00 UTC
    uint256 private _mintPerUserPerYear = 100;
    uint256 private _maxSupply = 1e24;
    // uint256 private constant BASE_YEAR = 2023;
    uint256 private constant BASE_YEAR = 0;
    uint256 private constant YEAR_IN_SECONDS = 31536000; // Number of seconds in a year (365 days)
    uint256 private constant DAY_IN_SECONDS = 86400; // Number of seconds in a day (24 hours)

    mapping(uint256 => mapping(string => bool)) private minted;

    event Log(string message);

    constructor(string memory name_, string memory symbol_, string memory dayName_, uint256 nameDayTimestamp_, uint256 mintPerUserPerYear_, uint256 maxSupply_) ERC20(name_, symbol_) {
        _nameDayTimestamp = nameDayTimestamp_;
        _mintPerUserPerYear = mintPerUserPerYear_;
        _dayName = dayName_;
        _maxSupply = maxSupply_;
        // nextDayTimestamp = nextDayTimestamp_;
        // _mint(msg.sender, nextDayTimestamp_);

        // bytes32 namehash = computeNamehash("martingbz");
        // console.log("namehash :");
        // console.logBytes32(namehash);
        // address ensResolved = resolve(namehash);

        // address ensResolved = resolve(0x1d4589635bb608ca7364f7a6c6b8df715726202b08df62322b7366c2bcc93826);
        
        // bytes name = bytes("martingbz.eth");
        // address ens = resolve( name.namehash());

        // console.log("ens : %s", ensResolved);
    }

    // Same address for Mainnet, Ropsten, Rinkerby, Gorli and other networks;
    ENS ens = ENS(0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e);

    function resolve(bytes32 node) public view returns(address) {
        Resolver resolver = ens.resolver(node);
        require(address(resolver) != address(0), "Resolver has not been found");
        address ensName = resolver.addr(node);
        require(address(resolver) != address(0), "Address can't be resolved");
        return ensName;
    }

    function _isRightDay() private view returns (bool) {
        uint256 currentTime = block.timestamp;
        uint256 yearsPassed = (currentTime - _nameDayTimestamp) / YEAR_IN_SECONDS;
        // if not in january 20 => nextDayTimestamp=_nameDayTimestamp
        // if in january 20 => nextDayTimestamp=_nameDayTimestamp+yearsPassed*YEAR_IN_SECONDS
        uint256 nextDayTimestamp = _nameDayTimestamp + yearsPassed * YEAR_IN_SECONDS;

        uint256 currentYear = BASE_YEAR + yearsPassed;

        

        // add the number of leap days
        // doesn't take into account the current year because it's not finished yet
        for (uint256 i = BASE_YEAR; i < currentYear; i++) {
            if (isLeap(i)) {
                nextDayTimestamp += DAY_IN_SECONDS;
            }
        }
 
        return (currentTime >= nextDayTimestamp && currentTime < nextDayTimestamp+DAY_IN_SECONDS);
    }

    function _isMaxSupplyReach(uint256 amount) private view returns (bool) {
        return totalSupply()+amount <= _maxSupply;
    }

    // function _isTransferAllowed(uint256 amount) private view returns (bool) {
    //     return _isMaxSupplyReach(amount) && _isRightDay();
    // }

    // function getTimes() private view returns (uint256, uint256, uint256) {
    //     uint256 currentTime = block.timestamp;
    //     uint256 yearsPassed = (currentTime - _nameDayTimestamp) / YEAR_IN_SECONDS;
    //     // if not in january 20 => nextDayTimestamp=_nameDayTimestamp
    //     // if in january 20 => nextDayTimestamp=_nameDayTimestamp+yearsPassed*YEAR_IN_SECONDS
    //     uint256 nextDayTimestamp = _nameDayTimestamp + yearsPassed * YEAR_IN_SECONDS;

    //     uint256 currentYear = BASE_YEAR + yearsPassed;
    //     return (currentTime, nextDayTimestamp, currentYear);
    // }

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

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(_isMaxSupplyReach(amount), "Max supply reached");
        require(_isRightDay(), "Transfers are only allowed on 20th January of each year");
        return super.transfer(recipient, amount);
    }

    function _isUserAllowed (string memory ensName) private view returns (bool) {
        // ensName starts with _name and ends with .eth
        
        require(!ensName.toSlice().endsWith(".eth".toSlice()), "ENS name not valid. Please remove the .eth extension");
        require(ensName.toSlice().contains(_dayName.toSlice()), "Only an owner of an ENS name that contains ".toSlice().concat(_dayName.toSlice()).toSlice().concat(" can mint tokens".toSlice()));

        // Check si il a pas déjà mint ce jour
        // require(minted(getCurrentYear(), ensName) == false, "You already minted tokens this year");
        require(!minted[getCurrentYear()][ensName], "You already minted tokens this year");

        bytes32 namehash = computeNamehash(ensName);
        address ensResolved = resolve(namehash);

        // Resolver resolver = getResolver(namehash);
        // address ensResolved = resolveName(resolver, namehash);

        require(ensResolved == msg.sender, "Only the owner of the ENS name can mint tokens");
        return true;
    }

    // function getResolver(bytes32 namehash) public view returns (Resolver resolver) {
    //     try ens.resolver(namehash) returns (Resolver result) {
    //         resolver = result;
    //          console.log('no error 1');
    //          console.log(result == address(0));
    //         // emit Log(result);
    //     } catch {
    //         console.log('error catch 1');
    //         // ensResolved = address(0);
    //         revert("Issue with ENS resolution 1");
    //     }
    // }

    // function resolveName(Resolver resolver, bytes32 namehash) public view returns (address ensResolved) {
    //     try resolver.addr(namehash) returns (address result) {
    //         ensResolved = result;
    //         console.log('no error 2');
    //         // emit Log(result);
    //     } catch {
    //         console.log('error catch 2');
    //         // ensResolved = address(0);
    //         revert("Issue with ENS resolution 2");
    //     }
    // }

    function mint (string memory ensName) public {
        require(_isMaxSupplyReach(_mintPerUserPerYear), "Max supply reached");
        require(_isRightDay(), "Transfers are only allowed on ".toSlice().concat(_dayName.toSlice()).toSlice().concat("'s day".toSlice()));
        require(_isUserAllowed(ensName), "Only the owner of the ENS name can mint tokens");
        _mint(msg.sender, _mintPerUserPerYear);
        minted[getCurrentYear()][ensName] = true;
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

    function getCurrentYear() private view returns (uint256) {
        uint256 yearsPassed = (block.timestamp - _nameDayTimestamp) / YEAR_IN_SECONDS;
        return BASE_YEAR + yearsPassed;
    }
}

abstract contract ENS {
    function resolver(bytes32 node) public virtual view returns (Resolver);
}

abstract contract Resolver {
    function addr(bytes32 node) public virtual view returns (address);
}