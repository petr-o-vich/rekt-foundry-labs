// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Vulnerable.sol";
import "../src/Fixed.sol";

contract WormholeLikeSignatureFixTest is Test {
    FixedGuardianBridge bridge;

    uint256 guardian0Pk = 0xA11CE;
    uint256 guardian1Pk = 0xB0B;
    uint256 guardian2Pk = 0xCAFE;

    address guardian0;
    address guardian1;
    address guardian2;

    function setUp() public {
        guardian0 = vm.addr(guardian0Pk);
        guardian1 = vm.addr(guardian1Pk);
        guardian2 = vm.addr(guardian2Pk);

        address[] memory gs = new address[](3);
        gs[0] = guardian0;
        gs[1] = guardian1;
        gs[2] = guardian2;

        bridge = new FixedGuardianBridge(gs, 2);
    }

    function testDuplicateGuardianIndexReverts() public {
        bytes32 digest = keccak256("wormhole-like message");

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(guardian0Pk, digest);
        bytes memory sig = abi.encodePacked(r, s, v);

        uint8[] memory idx = new uint8[](2);
        idx[0] = 0;
        idx[1] = 0;

        bytes[] memory sigs = new bytes[](2);
        sigs[0] = sig;
        sigs[1] = sig;

        vm.expectRevert(FixedGuardianBridge.DuplicateGuardian.selector);
        bridge.submit(digest, idx, sigs);

        assertFalse(bridge.accepted(digest), "digest must stay unaccepted");
    }

    function testUniqueGuardiansReachQuorum() public {
        bytes32 digest = keccak256("wormhole-like valid message");

        (uint8 v0, bytes32 r0, bytes32 s0) = vm.sign(guardian0Pk, digest);
        (uint8 v1, bytes32 r1, bytes32 s1) = vm.sign(guardian1Pk, digest);

        uint8[] memory idx = new uint8[](2);
        idx[0] = 0;
        idx[1] = 1;

        bytes[] memory sigs = new bytes[](2);
        sigs[0] = abi.encodePacked(r0, s0, v0);
        sigs[1] = abi.encodePacked(r1, s1, v1);

        bridge.submit(digest, idx, sigs);

        assertTrue(bridge.accepted(digest), "digest should be accepted with unique quorum");
    }
}
