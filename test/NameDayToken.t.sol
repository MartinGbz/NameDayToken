// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/NameDayToken.sol";
import "forge-std/console.sol";

contract NameDayTokenTest is Test {
    NameDayToken public aliceToken;
    address alice = address(0xcd2E72aEBe2A203b84f46DEEC948E6465dB51c75);
    address alice1 = address(0x3f125f040a5AA108C8E136c5d671895e533742E9);
    address alicecooper = address(0xa54fb799525Ac436F8bf3d88b3FA241A4e9e2599);
    address martingbz = address(0x4801eB5a2A6E2D04F019098364878c70a05158F1);

    function setUp() public {
        // 16/12/2023 : 0am
        vm.warp(1702684800);
        aliceToken = new NameDayToken("AliceToken", "ALICE", "alice", 1702684800, 100, 1e24);
    }

    function testConstructor() public {
        console.log("name : %s", aliceToken.name());
        console.log(block.timestamp);
        assertEq(aliceToken.name(), "AliceToken");
        assertEq(aliceToken.totalSupply(), 0);
    }

    /*---------- MINT TESTS ----------*/
    // mint tests can fail because if owners of alice*.eth remove resolving address, the test will fail

    function testMintSuccess() public {
        // vm.warp(1702684800);
        vm.startPrank(alice);
        aliceToken.mint("alice");
    }

    function testMintSuccessOtherTime() public {
        // 16/12/2023 : 13am
        vm.warp(1702731600);
        vm.startPrank(alice);
        aliceToken.mint("alice");
    }

    function testMintSuccessOtherName() public {
        vm.startPrank(alicecooper);
        aliceToken.mint("alicecooper");
    }

    function testMintFailNoResolvingAddress() public {
        // at the time of the test (17/11/2023) alice1.eth has no resolving address
        vm.startPrank(alice1);
        vm.expectRevert(bytes("Resolver has not been found"));
        aliceToken.mint("alice1");
    }

    function testMintFailSupply() public {
        NameDayToken aliceToken2 = new NameDayToken("AliceToken", "ALICE", "alice", 1702684800, 100, 150);
        vm.startPrank(alice);
        aliceToken2.mint("alice");
        vm.startPrank(alicecooper);
        vm.expectRevert(bytes("Max supply reached"));
        aliceToken2.mint("alicecooper");
    }

    function testMintFailDate() public {
        // 1 day later : 17/12/2023
        vm.warp(1702771200);
        vm.startPrank(alice);
        vm.expectRevert(bytes("Transfers are only allowed on alice's day"));
        aliceToken.mint("alice");
    }

    function testMintFailUserNotAllowed() public {
        vm.startPrank(martingbz);
        vm.expectRevert(bytes("Only an owner of an ENS name that contains alice can mint tokens"));
        aliceToken.mint("martingbz");
    }

    function testMintFailImpersonate() public {
        vm.startPrank(martingbz);
        vm.expectRevert(bytes("Only the owner of the ENS name can mint tokens"));
        aliceToken.mint("alice");
    }

    function testDoubleMintInADay() public {
        vm.startPrank(alice);
        aliceToken.mint("alice");
        vm.expectRevert(bytes("You already minted tokens this year"));
        aliceToken.mint("alice");
    }

    function testMintSuccessAfterLeapYear() public {
        // 16/12/25 : 5am
        vm.warp(1765857600);
        vm.startPrank(alice);
        aliceToken.mint("alice");
    }

    // TODO: test edges cases
    // - leap years => ok
    // v => would be better to do fuzz testing
    // - last day of the year
    //      31/12/2023
    // - first day of the year
    //      1/1/2024
    

    /*---------- TRANSFERT TESTS ----------*/

    function testMintAndTransferSuccess() public {
        vm.startPrank(alice);
        aliceToken.mint("alice");
        aliceToken.transfer(martingbz, 50);
        assertEq(aliceToken.balanceOf(alice), 50);
        assertEq(aliceToken.balanceOf(martingbz), 50);
        assertEq(aliceToken.totalSupply(), 100);
    }

    function testMintAndApproveAndTransferFromSuccess() public {
        vm.startPrank(alice);
        aliceToken.mint("alice");
        aliceToken.approve(martingbz, 50);

        vm.startPrank(martingbz);
        aliceToken.transferFrom(alice, martingbz, 50);

        assertEq(aliceToken.balanceOf(alice), 50);
        assertEq(aliceToken.balanceOf(martingbz), 50);
        assertEq(aliceToken.totalSupply(), 100);
    }

    function testMintAndTransferFailDate() public {
        vm.startPrank(alice);
        aliceToken.mint("alice");
        // 17/12/2023 : 10am
        vm.warp(1702807200);
        vm.expectRevert(bytes("Transfers are only allowed on alice's day"));
        aliceToken.transfer(martingbz, 50);
    }

     function testMintAndApproveAndTransferFromFailDate() public {
        vm.startPrank(alice);
        aliceToken.mint("alice");

        // 10/04/2024 : 15am
        vm.warp(1712761200);

        console.log("BEFORE");
        aliceToken.approve(martingbz, 50); // should not revert
        console.log("AFTER");

        vm.startPrank(martingbz);
        vm.expectRevert(bytes("Transfers are only allowed on alice's day"));
        aliceToken.transferFrom(alice, martingbz, 50);
    }

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

