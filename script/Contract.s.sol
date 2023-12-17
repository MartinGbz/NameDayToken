// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {NameDayTokenFactory} from "../src/NameDayTokenFactory.sol";

contract ContractScript is Script {
    NameDayTokenFactory public factory;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        factory = new NameDayTokenFactory();
        vm.stopBroadcast();
    }
}
