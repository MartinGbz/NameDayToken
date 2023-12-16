// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./NameDayToken.sol";
// import "forge-std/console.sol";

contract NameDayTokenFactory {
    address[] public tokens;
    // mapping(address => address[]) public tokens;
    uint256 public tokenCount;
    event TokenDeployed(address indexed tokenAddress, address indexed deployer);

    function deployToken(string memory name_, string memory symbol_, string memory dayName_, uint256 nameDayTimestamp_, uint256 mintPerUserPerYear_, uint256 maxSupply_) public returns (address) {
        NameDayToken token = new NameDayToken(name_, symbol_, dayName_, nameDayTimestamp_, mintPerUserPerYear_, maxSupply_);
        tokens.push(address(token));
        // tokens[msg.sender].push(address(token));
        tokenCount += 1;
        emit TokenDeployed(address(token), msg.sender);
        return address(token);
    }
}