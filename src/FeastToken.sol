// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "forge-std/console.sol";

contract FeastToken is ERC20 {

    uint256 internal constant initialSupply = 1000000 * 10 ** 18;

    uint256 internal constant january20BaseTimestamp = 1674172800; // Timestamp for 20th January 2023, 00:00:00 UTC
    uint256 internal constant january20BaseYear = 2023;

    uint256 internal constant yearInSeconds = 31536000; // Number of seconds in a year (365 days)
    uint256 internal constant dayInSeconds = 86400; // Number of seconds in a day (24 hours)

    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {
        _mint(msg.sender, initialSupply);
    }

    function _isTransferAllowed() internal view returns (bool) {
        uint256 currentTime = block.timestamp;
        uint256 yearsPassed = (currentTime - january20BaseTimestamp) / yearInSeconds;
        // if not in january 20 => nextJanuary20Timestamp=january20BaseTimestamp
        // if in january 20 => nextJanuary20Timestamp=january20BaseTimestamp+yearsPassed*yearInSeconds
        uint256 nextJanuary20Timestamp = january20BaseTimestamp + yearsPassed * yearInSeconds;

        uint256 currentYear = january20BaseYear + yearsPassed;

        console.log("currentYear : %d", currentYear);

        // doesn't take into account the current year because it's not finished yet
        for (uint256 i = january20BaseYear; i < currentYear; i++) {
            console.log("i=%d", i);
            if (isLeap(i)) {
                nextJanuary20Timestamp += dayInSeconds;
                console.log("leap!");
            }
        }
 
        return (currentTime >= nextJanuary20Timestamp && currentTime < nextJanuary20Timestamp+dayInSeconds);
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

    // function isLeap(uint256 year) public pure returns (bool) {
    //     if (year % 400 == 0) {
    //         return true;
    //     } else if (year % 100 == 0) {
    //         return false;
    //     } else if (year % 4 == 0) {
    //         return true;
    //     } else {
    //         return false;
    //     }
    // }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(_isTransferAllowed(), "Transfers are only allowed on 20th January of each year");
        return super.transfer(recipient, amount);
    }
}