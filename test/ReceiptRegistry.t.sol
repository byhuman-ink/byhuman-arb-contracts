// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReceiptRegistry} from "../src/ReceiptRegistry.sol";

contract ReceiptRegistryTest is Test {
    ReceiptRegistry registry;

    address owner = makeAddr("owner");
    address stranger = makeAddr("stranger");
    bytes32 constant DIGEST = keccak256("a-byhuman-receipt");

    event ReceiptAnchored(bytes32 indexed digest, uint256 timestamp);

    function setUp() public {
        registry = new ReceiptRegistry(owner);
    }

    function test_constructorSetsOwner() public view {
        assertEq(registry.owner(), owner);
    }

    function test_unanchoredByDefault() public view {
        assertEq(registry.anchoredAt(DIGEST), 0);
        assertFalse(registry.isAnchored(DIGEST));
    }

    function test_anchorRecordsTimestampAndEmits() public {
        vm.warp(1_700_000_000);

        vm.expectEmit(true, false, false, true);
        emit ReceiptAnchored(DIGEST, 1_700_000_000);

        vm.prank(owner);
        registry.anchor(DIGEST);

        assertEq(registry.anchoredAt(DIGEST), 1_700_000_000);
        assertTrue(registry.isAnchored(DIGEST));
    }

    function test_anchorRevertsForNonOwner() public {
        vm.prank(stranger);
        vm.expectRevert(
            abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, stranger)
        );
        registry.anchor(DIGEST);
    }

    function test_anchorRevertsWhenAlreadyAnchored() public {
        vm.prank(owner);
        registry.anchor(DIGEST);

        vm.prank(owner);
        vm.expectRevert(abi.encodeWithSelector(ReceiptRegistry.AlreadyAnchored.selector, DIGEST));
        registry.anchor(DIGEST);
    }

    function testFuzz_anchorAnyDigest(bytes32 digest) public {
        vm.prank(owner);
        registry.anchor(digest);
        assertTrue(registry.isAnchored(digest));
        assertEq(registry.anchoredAt(digest), block.timestamp);
    }
}
