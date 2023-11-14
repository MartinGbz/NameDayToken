// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {NameDayToken} from "../src/NameDayToken.sol";

contract ContractScript is Script {
    NameDayToken public sebcoin;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        sebcoin = new NameDayToken("sebcoin", "SEB", "seb", 1674172800, 100, 1e24);
        // sebcoin.transfer(0x70997970C51812dc3A010C7d01b50e0d17dc79C8, 100);
        vm.stopBroadcast();
    }
}
