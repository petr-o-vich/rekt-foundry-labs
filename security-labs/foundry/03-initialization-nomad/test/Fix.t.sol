// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Fixed.sol";

contract NomadInitializationFixTest is Test {
    FixedNomadLikeBridge bridge;
    address relayer = makeAddr("relayer");
    address attacker = makeAddr("attacker");
    address user = makeAddr("user");

    function setUp() public {
        bridge = new FixedNomadLikeBridge{value: 100 ether}(relayer);
        bridge.initialize(keccak256("root-v1"));
    }

    function testAttackerCannotReinitializeOrRelay() public {
        vm.prank(attacker);
        vm.expectRevert("only owner");
        bridge.initialize(bytes32(uint256(1)));

        bytes32 msgHash = keccak256(abi.encode(block.chainid, address(bridge), attacker, 100 ether, uint256(1)));

        vm.prank(attacker);
        vm.expectRevert("only relayer");
        bridge.relay(msgHash, attacker, 100 ether, 1, keccak256("root-v1"));

        assertEq(address(bridge).balance, 100 ether, "funds must stay in bridge");
    }

    function testRelayerCanProcessValidMessageOnce() public {
        bytes32 root = keccak256("root-v2");
        bridge.updateRoot(root);

        uint256 amount = 5 ether;
        uint256 nonce = 77;
        bytes32 msgHash = keccak256(abi.encode(block.chainid, address(bridge), user, amount, nonce));

        vm.prank(relayer);
        bridge.relay(msgHash, user, amount, nonce, root);

        assertEq(user.balance, amount, "user gets bridged funds");

        vm.prank(relayer);
        vm.expectRevert("already processed");
        bridge.relay(msgHash, user, amount, nonce, root);
    }
}
