// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/NameDayToken.sol";
import "forge-std/console.sol";

/**
    ALL TESTS NEED TO BE RUN WITH USING SEPOLIA TESTNET
    forge test --fork-url https://ethereum-sepolia.publicnode.com

    I control all the ENS names used in the tests on the sepolia testnet
    This ensures that the tests will always pass
    Otherwise, the tests would fail if someone changed the resolver of the ENS names used in the tests
 */

contract NameDayTokenTest is Test {
    NameDayToken public martinToken;

    address martin = address(0x4801eB5a2A6E2D04F019098364878c70a05158F1);
    address martin1 = address(0x4801eB5a2A6E2D04F019098364878c70a05158F1);
    address martin2 = address(0xFa3ED20a82df27DF4b1a01dfb7EFC9b1b0848241);
    address alice2 = address(0xFa3ED20a82df27DF4b1a01dfb7EFC9b1b0848241);

    uint256 DAY_IN_SECONDS = 24 * 60 * 60;
    uint256 MAX_INT_TYPE = type(uint256).max;

    function setUp() public {
        // 11/11/2023 : 0am
        vm.warp(1699660800);
        martinToken = new NameDayToken("MartinToken", "MARTIN", "martin", 1699660800, 100, 1e24);
    }

    function testConstructor() public {
        console.log("name : %s", martinToken.name());
        console.log(block.timestamp);
        assertEq(martinToken.name(), "MartinToken");
        assertEq(martinToken.totalSupply(), 0);
    }

    /*---------- MINT TESTS ----------*/

    function testMintSuccess() public {
        vm.startPrank(martin);
        martinToken.mint("martin");
    }

    function testMintSuccessOtherTime() public {
        // 11/11/2023 : 13am
        vm.warp(1699707600);
        vm.startPrank(martin);
        martinToken.mint("martin");
    }

    function testMintSuccessOtherName() public {
        vm.startPrank(martin2);
        martinToken.mint("martin2");
    }

    // // at the time of the test (17/11/2023) alice1.eth has no resolving address on ethereum mainnet
    // function testMintFailNoResolvingAddress() public {
    //     vm.startPrank(alice1);
    //     vm.expectRevert(bytes("Resolver has not been found"));
    //     aliceToken.mint("alice1");
    // }
    
    function testMintFailNoETHRecordAddress() public {
        vm.startPrank(martin1);
        vm.expectRevert(bytes("Only the owner of the ENS name can mint tokens"));
        martinToken.mint("martin1");
    }

    function testMintFailSupply() public {
        NameDayToken aliceToken2 = new NameDayToken("MartinToken", "MARTIN", "martin", 1699660800, 100, 150);
        vm.startPrank(martin);
        aliceToken2.mint("martin");
        vm.startPrank(martin2);
        vm.expectRevert(bytes("Max supply reached"));
        aliceToken2.mint("martin2");
    }

    function testMintFailDateBefore() public {
        // 1 day before : 10/11/2023
        vm.warp(1699574400);
        vm.startPrank(martin);
        vm.expectRevert(bytes("Transfers are only allowed on martin's day"));
        martinToken.mint("martin");
    }

    function testMintFailDateAfter() public {
        // 1 day later : 12/11/2023
        vm.warp(1699747200);
        vm.startPrank(martin);
        vm.expectRevert(bytes("Transfers are only allowed on martin's day"));
        martinToken.mint("martin");
    }

    function testMintFailUserNotAllowed() public {
        vm.startPrank(alice2);
        vm.expectRevert(bytes("Only an owner of an ENS name that contains martin can mint tokens"));
        martinToken.mint("alice2");
    }

    function testMintFailImpersonate() public {
        vm.startPrank(alice2);
        vm.expectRevert(bytes("Only the owner of the ENS name can mint tokens"));
        martinToken.mint("martin");
    }

    function testDoubleMintInADay() public {
        vm.startPrank(martin);
        martinToken.mint("martin");
        vm.expectRevert(bytes("You already minted tokens this year"));
        martinToken.mint("martin");
    }

    function testMintSuccessAfterLeapYear() public {
        // 11/11/25 : 5am
        vm.warp(1762837200);
        vm.startPrank(martin);
        martinToken.mint("martin");
    }

    function testFuzz_Mint(uint256 currentTimeStamp, uint256 nameDayTimeStamp) public {
        // We need to make sure that the addition of DAY_IN_SECONDS to nameDayTimeStamp will not overflow
        vm.assume(currentTimeStamp <= MAX_INT_TYPE - DAY_IN_SECONDS);

        vm.warp(currentTimeStamp);
        NameDayToken martinToken2 = new NameDayToken("MartinToken2", "MARTIN2", "martin", nameDayTimeStamp, 100, 1e24);
        vm.startPrank(martin);
        if(currentTimeStamp >= nameDayTimeStamp && currentTimeStamp < nameDayTimeStamp+DAY_IN_SECONDS) {
            martinToken2.mint("martin");
        } else {
            vm.expectRevert(bytes("Transfers are only allowed on martin's day"));
            martinToken2.mint("martin");
        }
    }

    /*---------- TRANSFERT TESTS ----------*/

    function testMintAndTransferSuccess() public {
        vm.startPrank(martin);
        martinToken.mint("martin");
        martinToken.transfer(alice2, 50);
        assertEq(martinToken.balanceOf(martin), 50);
        assertEq(martinToken.balanceOf(alice2), 50);
        assertEq(martinToken.totalSupply(), 100);
    }

    function testMintAndApproveAndTransferFromSuccess() public {
        vm.startPrank(martin);
        martinToken.mint("martin");
        martinToken.approve(alice2, 50);

        vm.startPrank(alice2);
        martinToken.transferFrom(martin, alice2, 50);

        assertEq(martinToken.balanceOf(martin), 50);
        assertEq(martinToken.balanceOf(alice2), 50);
        assertEq(martinToken.totalSupply(), 100);
    }

    function testMintAndTransferFailDate() public {
        vm.startPrank(martin);
        martinToken.mint("martin");

        // 1 day later: 12/11/2023 : 10am
        vm.warp(1699783200);
        vm.expectRevert(bytes("Transfers are only allowed on martin's day"));
        martinToken.transfer(alice2, 50);
    }

     function testMintAndApproveAndTransferFromFailDate() public {
        vm.startPrank(martin);
        martinToken.mint("martin");

        // 10/04/2024 : 15am
        vm.warp(1712761200);
        martinToken.approve(alice2, 50); // should not revert

        vm.startPrank(alice2);
        vm.expectRevert(bytes("Transfers are only allowed on martin's day"));
        martinToken.transferFrom(martin, alice2, 50);
    }

    /*---------- GET FUNCTION TESTS ----------*/

    function testGetBaseYear() public {
        uint256 baseTimestamp = martinToken.getBaseTimestamp();
        assertEq(baseTimestamp, 1699660800);
    }

    function testGetCurrentYearNameDayTimestamp() public {
        // 01/02/2024 : 0am
        vm.warp(1706745600);
        uint256 timestamp = martinToken.getCurrentYearNameDayTimestamp();

        // timestamp should be 16/12/2024 : 0am
        assertEq(timestamp, 1731283200);
    }

    function testHasMinted() public {
        vm.startPrank(martin);
        martinToken.mint("martin");
        assertEq(martinToken.hasMinted(2023, "martin"), true);
        assertEq(martinToken.hasMinted(2023, "martin2"), false);
        assertEq(martinToken.hasMinted(2024, "martin"), false);

        // 11/11/2025 : 0am
        vm.warp(1762819200);
        martinToken.mint("martin");
        assertEq(martinToken.hasMinted(2025, "martin"), true);
        assertEq(martinToken.hasMinted(2024, "martin"), false);
    }

    function testGetUserMints() public {
        vm.startPrank(martin);
        
        martinToken.mint("martin");
        
        // 11/11/2025 : 0am
        vm.warp(1762819200);
        martinToken.mint("martin");
        
        // 11/11/2026 : 0am
        vm.warp(1794355200);
        martinToken.mint("martin");

        bool[] memory mints = martinToken.getUserMints("martin");
        assertTrue(
            mints[0] == true &&
            mints[1] == false &&
            mints[2] == true &&
            mints[3] == true,
            "mints should be [true, false, true, true]"
        );
    }

    /*---------- EVENTS TESTS ----------*/

    event Mint(uint256 indexed year, string indexed ensName);

    function testMintEvent() public {
        vm.startPrank(martin);

        vm.expectEmit(true, true, false, false);
        emit Mint(2023, "martin");

        martinToken.mint("martin");
    }
}