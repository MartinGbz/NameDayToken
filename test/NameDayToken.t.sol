// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/NameDayToken.sol";
import "forge-std/console.sol";

contract NameDayTokenTest is Test {
    NameDayToken public aliceToken;
    // address dapp = address(0x1);
    // address alice = address(0x2);
    // address seb = address(0xf1D9B3Ed2a6F6210203B91EdCF4156203Ca47943);
    address alice = address(0xcd2E72aEBe2A203b84f46DEEC948E6465dB51c75);
    address alice1 = address(0x3f125f040a5AA108C8E136c5d671895e533742E9);
    address alicecooper = address(0xa54fb799525Ac436F8bf3d88b3FA241A4e9e2599);

    function setUp() public {
        // sebcoin = new NameDayToken("sebcoin", "SEB", "seb", 1674172800, 100, 1e24);
        vm.warp(1702684800);
        aliceToken = new NameDayToken("AliceToken", "ALICE", "alice", 1702684800, 100, 1e24);
    }

    function testConstructor() public {
        console.log("name : %s", aliceToken.name());
        console.log(block.timestamp);
        assertEq(aliceToken.name(), "AliceToken");
        assertEq(aliceToken.totalSupply(), 0);
    }


    function testMintSuccess() public {
        // vm.warp(1702684800);
        emit log_uint(block.timestamp);
        vm.startPrank(alice);
        aliceToken.mint("alice");
    }

    // error with alice1 because there is no resolving address for alice1.eth
    // function testMintSuccessOtherName1() public {
    //     emit log_uint(block.timestamp);
    //     vm.startPrank(alice1);
    //     aliceToken.mint("alice1");
    // }

    function testMintSuccessOtherName1() public {
        emit log_uint(block.timestamp);
        vm.startPrank(alicecooper);
        aliceToken.mint("alicecooper");
    }

    function testMintFailNoResolvingAddress() public {
        emit log_uint(block.timestamp);
        // at the time of the test (17/11/2023) alice1.eth has no resolving address
        vm.startPrank(alice1);
        vm.expectRevert(bytes("Resolver has not been found"));
        aliceToken.mint("alice1");
    }

    function testMintFailDate() public {
        // 1 day later
        vm.warp(1702771200);
        vm.startPrank(alice);
        vm.expectRevert(bytes("Transfers are only allowed on alice's day"));
        aliceToken.mint("alice");
    }

    // function testMintFailSupply() public {
    //     vm.startPrank(alice);
    //     aliceToken.mint("alice");
    //     address alice1 = address(0x3f125f040a5AA108C8E136c5d671895e533742E9);
    //     vm.startPrank(alice1);
    //     vm.expectRevert(bytes("Max supply reached"));
    //     aliceToken.mint("bob");
    // }

    // function testName() public {
    //     console.log("name : %s", sebcoin.name());
    //     assertEq(sebcoin.name(), "sebcoin");
        
    //     console.log("total supply : %e", sebcoin.totalSupply());
    //     assertEq(sebcoin.totalSupply(), 1e24);

    //     console.log(block.timestamp);
    // }

    // function testApprove() public {
    //     vm.startPrank(alice);
    //     assertTrue(aliceToken.approve(dapp, 100));
    //     assertEq(aliceToken.allowance(address(this), dapp), 100);
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

