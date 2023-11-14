// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "forge-std/console.sol";

// import 'ens-namehash/contracts/ENSNamehash.sol';

// import "@openzeppelin/contracts/utils/Strings.sol";

import "https://github.com/Arachnid/solidity-stringutils/strings.sol";


contract NameDayToken is ERC20 {

    string internal dayName;
    // uint256 internal nextDayTimestamp = 1000000 * 10 ** 18;
    uint256 internal nameDayTimestamp = 1674172800; // Timestamp for 20th January 2023, 00:00:00 UTC
    uint256 internal mintPerUserPerYear = 100;
    // uint256 internal constant january20BaseYear = 2023;
    uint256 internal constant january20BaseYear = 0;
    uint256 internal constant yearInSeconds = 31536000; // Number of seconds in a year (365 days)
    uint256 internal constant dayInSeconds = 86400; // Number of seconds in a day (24 hours)

    mapping(uint256 => mapping(string => bool)) internal minted;

    // uint256 internal constant mintPerUserPerDay = 1;
    // uint256 internal constant name = 1;

    constructor(string memory name_, string memory symbol_, string memory dayName_, uint256 nameDayTimestamp_, uint256 mintPerUserPerYear_, uint256 nextDayTimestamp_) ERC20(name_, symbol_) {
        nameDayTimestamp = nameDayTimestamp_;
        mintPerUserPerYear = mintPerUserPerYear_;
        dayName = dayName_;
        // nextDayTimestamp = nextDayTimestamp_;
        _mint(msg.sender, nextDayTimestamp_);

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
        return resolver.addr(node);
    }

    function _isTransferAllowed() internal view returns (bool) {
        uint256 currentTime = block.timestamp;
        uint256 yearsPassed = (currentTime - nameDayTimestamp) / yearInSeconds;
        // if not in january 20 => nextDayTimestamp=nameDayTimestamp
        // if in january 20 => nextDayTimestamp=nameDayTimestamp+yearsPassed*yearInSeconds
        uint256 nextDayTimestamp = nameDayTimestamp + yearsPassed * yearInSeconds;

        uint256 currentYear = january20BaseYear + yearsPassed;

        

        // add the number of leap days
        // doesn't take into account the current year because it's not finished yet
        for (uint256 i = january20BaseYear; i < currentYear; i++) {
            if (isLeap(i)) {
                nextDayTimestamp += dayInSeconds;
            }
        }
 
        return (currentTime >= nextDayTimestamp && currentTime < nextDayTimestamp+dayInSeconds);
    }

    // function getTimes() internal view returns (uint256, uint256, uint256) {
    //     uint256 currentTime = block.timestamp;
    //     uint256 yearsPassed = (currentTime - nameDayTimestamp) / yearInSeconds;
    //     // if not in january 20 => nextDayTimestamp=nameDayTimestamp
    //     // if in january 20 => nextDayTimestamp=nameDayTimestamp+yearsPassed*yearInSeconds
    //     uint256 nextDayTimestamp = nameDayTimestamp + yearsPassed * yearInSeconds;

    //     uint256 currentYear = january20BaseYear + yearsPassed;
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
        require(_isTransferAllowed(), "Transfers are only allowed on 20th January of each year");
        return super.transfer(recipient, amount);
    }

    function _isMintAllowed (string memory ensName) internal view returns (bool) {
        // ensName starts with _name and ends with .eth
        require(ensName.endsWith(".eth"), "ENS name not valid");
        require(ensName.contains(dayName), "Only an owner of an ENS name that contains "+ dayName +" can mint tokens");

        // Check si il a pas déjà mint ce jour
        require(minted(getCurrentYear(), ensName) == false, "You already minted tokens this year");

        bytes32 namehash = computeNamehash(ensName);
        address ensResolved = resolve(namehash);
        require(ensResolved == msg.sender, "Only the owner of the ENS name can mint tokens");
        return true;
    }

    function mint (string memory ensName) public {
        require(_isTransferAllowed(), "Transfers are only allowed on 20th January of each year");
        require(_isMintAllowed(ensName), "Only the owner of the ENS name can mint tokens");
        _mint(msg.sender, mintPerUserPerYear);
        minted(getCurrentYear(), ensName) = true;
    }

    // computeNamehash for ENS (function not recursive - subdomains are not supported)
    function computeNamehash(string memory _name) public pure returns (bytes32 namehash) {
        namehash = 0x0000000000000000000000000000000000000000000000000000000000000000;
        namehash = keccak256(
        abi.encodePacked(namehash, keccak256(abi.encodePacked('eth')))
        );
        namehash = keccak256(
        abi.encodePacked(namehash, keccak256(abi.encodePacked(_name)))
        );
    }

    function getCurrentYear() internal returns (uint256) {
        uint256 yearsPassed = (block.timestamp - nameDayTimestamp) / yearInSeconds;
        return january20BaseYear + yearsPassed;
    }
}

abstract contract ENS {
    function resolver(bytes32 node) public virtual view returns (Resolver);
}

abstract contract Resolver {
    function addr(bytes32 node) public virtual view returns (address);
}