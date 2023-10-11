// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FeastToken is ERC20 {

    uint256 internal constant initialSupply = 1000000 * 10 ** 18;

    uint256 internal constant january20Timestamp = 1674172800; // Timestamp for 20th January 2023, 00:00:00 UTC
    uint256 internal constant yearInSeconds = 31536000; // Number of seconds in a year (365 days)
    uint256 internal constant dayInSeconds = 86400; // Number of seconds in a day (24 hours)

    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {
        _mint(msg.sender, initialSupply);
    }

    function _isTransferAllowed() internal view returns (bool) {
        uint256 currentTime = block.timestamp;
        uint256 yearsPassed = (currentTime - january20Timestamp) / yearInSeconds;
        // if not in january 20 => nextJanuary20Timestamp=january20Timestamp
        // if in january 20 => nextJanuary20Timestamp=january20Timestamp+yearsPassed*yearInSeconds
        uint256 nextJanuary20Timestamp = january20Timestamp + yearsPassed * yearInSeconds;
        return (currentTime >= nextJanuary20Timestamp && currentTime < nextJanuary20Timestamp+dayInSeconds);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(_isTransferAllowed(), "Transfers are only allowed on 20th January of each year");
        return super.transfer(recipient, amount);
    }
}