// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {NameDayToken} from "../src/NameDayToken.sol";

contract ContractScript is Script {
    NameDayToken public martinToken;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        martinToken = new NameDayToken("MartinToken", "MARTIN", "martin", 1702285997, 1e20, 1e23);
        vm.stopBroadcast();
    }
}
