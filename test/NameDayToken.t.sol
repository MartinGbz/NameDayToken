// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/NameDayToken.sol";
import "forge-std/console.sol";

contract NameDayTokenTest is Test {
    NameDayToken public sebcoin;
    address dapp = address(0x1);
    // address alice = address(0x2);
    address seb = address(0xf1D9B3Ed2a6F6210203B91EdCF4156203Ca47943);

    function setUp() public {
        sebcoin = new NameDayToken("sebcoin", "SEB", "seb", 1674172800, 100, 1e24);
    }

    function testConstructor() public {
        console.log("name : %s", sebcoin.name());
        console.log(block.timestamp);
        assertEq(sebcoin.name(), "sebcoin");
        // assertEq(sebcoin.totalSupply(), 1e24);
    }

    // function testName() public {
    //     console.log("name : %s", sebcoin.name());
    //     assertEq(sebcoin.name(), "sebcoin");
        
    //     console.log("total supply : %e", sebcoin.totalSupply());
    //     assertEq(sebcoin.totalSupply(), 1e24);

    //     console.log(block.timestamp);
    // }

    // function testApprove() public {
    //     assertTrue(sebcoin.approve(dapp, 100));
    //     assertEq(sebcoin.allowance(address(this), dapp), 100);
    // }

    // function testSend() public {
    //     assertTrue(sebcoin.transfer(alice, 100));
    //     console.log("alice : %e", sebcoin.balanceOf(alice));
    //     assertEq(sebcoin.balanceOf(alice), 1e2);
    //     assertEq(sebcoin.balanceOf(address(this)), 1e24 - 1e2);
    // }

    // function testApproveAndSend() public {
    //     assertTrue(sebcoin.transfer(alice, 100));
    //     vm.startPrank(alice);
    //     console.log("1: alice : %e", sebcoin.balanceOf(alice));
    //     assertTrue(sebcoin.approve(dapp, 1e2));
    //     vm.stopPrank();
    //     vm.startPrank(dapp);
    //     assertTrue(sebcoin.transferFrom(alice, dapp, 1e2));
    //     console.log("2: dapp : %e", sebcoin.balanceOf(dapp));
    //     vm.stopPrank();
    //     console.log("this : %e", sebcoin.balanceOf(address(this)));
    //     console.log("dapp : %e", sebcoin.balanceOf(dapp));
    //     console.log("alice : %e", sebcoin.balanceOf(alice));
    //     assertEq(sebcoin.balanceOf(address(this)), 1e24 - 1e2);
    //     assertEq(sebcoin.balanceOf(dapp), 1e2);
    //     assertEq(sebcoin.balanceOf(alice), 0);
    // }
}

