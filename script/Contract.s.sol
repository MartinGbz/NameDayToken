// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {NameDayToken} from "../src/NameDayToken.sol";

contract ContractScript is Script {
    NameDayToken public martinToken;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        martinToken = new NameDayToken("MartinToken", "MARTIN", "martin", 1700693839, 100, 100000);
        vm.stopBroadcast();
    }
}
