// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Vulnerable.sol";
import "../src/Fixed.sol";

contract LifiLikeArbitraryCallFixTest is Test {
    MockERC20 token;
    TrustedBridgeTarget bridgeTarget;
    FixedBridgeExecutor executor;

    address relayer = makeAddr("relayer");
    address attacker = makeAddr("attacker");

    function setUp() public {
        token = new MockERC20();
        bridgeTarget = new TrustedBridgeTarget();
        executor = new FixedBridgeExecutor(
            relayer,
            address(bridgeTarget),
            TrustedBridgeTarget.credit.selector
        );

        token.mint(address(executor), 1_000 ether);
    }

    function testExploitPathBlockedByAuth() public {
        bytes memory payload = abi.encodeWithSelector(
            MockERC20.transfer.selector,
            attacker,
            1_000 ether
        );

        vm.prank(attacker);
        vm.expectRevert(FixedBridgeExecutor.Unauthorized.selector);
        executor.execute(address(token), payload);

        assertEq(token.balanceOf(address(executor)), 1_000 ether, "funds stay in executor");
        assertEq(token.balanceOf(attacker), 0, "attacker gets nothing");
    }

    function testRelayerCannotCallUnapprovedSelectorOrTarget() public {
        bytes memory payload = abi.encodeWithSelector(
            MockERC20.transfer.selector,
            attacker,
            1_000 ether
        );

        vm.prank(relayer);
        vm.expectRevert(FixedBridgeExecutor.TargetNotAllowed.selector);
        executor.execute(address(token), payload);
    }
}
