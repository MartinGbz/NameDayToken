// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/FeastToken.sol";
import "forge-std/console.sol";

contract FeastTokenTest is Test {
    FeastToken public sebcoin;
    address dapp = address(0x1);
    address alice = address(0x2);

    function setUp() public {
        sebcoin = new FeastToken("sebcoin", "SEB");
    }

    function testName() public {
        console.log("name : %s", sebcoin.name());
        assertEq(sebcoin.name(), "sebcoin");
        console.log("total supply : %e", sebcoin.totalSupply());
        assertEq(sebcoin.totalSupply(), 1e24);
        console.log(block.timestamp);
    }

    function testApprove() public {
        assertTrue(sebcoin.approve(dapp, 100));
        assertEq(sebcoin.allowance(address(this), dapp), 100);
    }

    function testSend() public {
        assertTrue(sebcoin.transfer(alice, 100));
        console.log("alice : %e", sebcoin.balanceOf(alice));
        assertEq(sebcoin.balanceOf(alice), 1e2);
        assertEq(sebcoin.balanceOf(address(this)), 1e24 - 1e2);
    }

    function testApproveAndSend() public {
        assertTrue(sebcoin.transfer(alice, 100));
        vm.startPrank(alice);
        console.log("1: alice : %e", sebcoin.balanceOf(alice));
        assertTrue(sebcoin.approve(dapp, 1e2));
        vm.stopPrank();
        vm.startPrank(dapp);
        assertTrue(sebcoin.transferFrom(alice, dapp, 1e2));
        console.log("2: dapp : %e", sebcoin.balanceOf(dapp));
        vm.stopPrank();
        console.log("this : %e", sebcoin.balanceOf(address(this)));
        console.log("dapp : %e", sebcoin.balanceOf(dapp));
        console.log("alice : %e", sebcoin.balanceOf(alice));
        assertEq(sebcoin.balanceOf(address(this)), 1e24 - 1e2);
        assertEq(sebcoin.balanceOf(dapp), 1e2);
        assertEq(sebcoin.balanceOf(alice), 0);
    }
}

