// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {FeastToken} from "../src/FeastToken.sol";

contract ContractScript is Script {
    FeastToken public sebcoin;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        sebcoin = new FeastToken("sebcoin", "SEB");
        // sebcoin.transfer(0x70997970C51812dc3A010C7d01b50e0d17dc79C8, 100);
        vm.stopBroadcast();
    }
}
