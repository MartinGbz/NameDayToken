// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {NameDayToken} from "../src/NameDayToken.sol";

contract ContractScript is Script {
    NameDayToken public aliceToken;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        aliceToken = new NameDayToken("AliceToken", "ALICE", "alice", 1702684800, 100, 100000);
        vm.stopBroadcast();
    }
}
