// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Vulnerable.sol";
import "../src/Fixed.sol";

contract AudiusLikeReinitFixTest is Test {
    MockERC20 token;
    FixedGovernanceTreasury treasury;

    address legitGuardian = makeAddr("legitGuardian");
    address legitTreasury = makeAddr("legitTreasury");
    address attacker = makeAddr("attacker");

    function setUp() public {
        token = new MockERC20();
        treasury = new FixedGovernanceTreasury();

        treasury.initialize(legitGuardian, legitTreasury);
        token.mint(address(treasury), 500_000 ether);
    }

    function testReinitializeBlockedAndDrainDenied() public {
        vm.prank(attacker);
        vm.expectRevert(FixedGovernanceTreasury.AlreadyInitialized.selector);
        treasury.initialize(attacker, legitTreasury);

        vm.prank(attacker);
        vm.expectRevert(FixedGovernanceTreasury.Unauthorized.selector);
        treasury.emergencyTransfer(address(token), attacker, 500_000 ether);

        assertEq(token.balanceOf(address(treasury)), 500_000 ether, "funds remain");
        assertEq(token.balanceOf(attacker), 0, "attacker gets nothing");
    }
}
