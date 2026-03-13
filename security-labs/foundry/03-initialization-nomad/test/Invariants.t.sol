// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Fixed.sol";

contract NomadInvariantTest is Test {
    FixedNomadLikeBridge bridge;
    address relayer = makeAddr("relayer");
    address user = makeAddr("user");

    function setUp() public {
        bridge = new FixedNomadLikeBridge{value: 20 ether}(relayer);
        bridge.initialize(keccak256("root"));
    }

    function testMessageHashCannotBeReplayed() public {
        bytes32 root = keccak256("root");
        uint256 amount = 1 ether;
        uint256 nonce = 1;
        bytes32 msgHash = keccak256(abi.encode(block.chainid, address(bridge), user, amount, nonce));

        vm.prank(relayer);
        bridge.relay(msgHash, user, amount, nonce, root);

        vm.prank(relayer);
        vm.expectRevert("already processed");
        bridge.relay(msgHash, user, amount, nonce, root);
    }
}
