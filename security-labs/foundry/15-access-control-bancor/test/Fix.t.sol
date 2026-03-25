// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Fixed.sol";

contract BancorAccessControlFixTest is Test {
    FixedBancorVault vault;

    address deployer = makeAddr("deployer");
    address attacker = makeAddr("attacker");
    address treasurySink = makeAddr("treasurySink");

    function setUp() public {
        vm.prank(deployer);
        vault = new FixedBancorVault{value: 1_000 ether}();
    }

    function testUnauthorizedEmergencyWithdrawReverts() public {
        vm.prank(attacker);
        vm.expectRevert(FixedBancorVault.NotOwner.selector);
        vault.emergencyWithdraw(payable(attacker), 1 ether);

        assertEq(address(vault).balance, 1_000 ether, "vault unchanged");
    }

    function testOwnerEmergencyWithdrawStillWorks() public {
        vm.prank(deployer);
        vault.emergencyWithdraw(payable(treasurySink), 250 ether);

        assertEq(treasurySink.balance, 250 ether, "owner can migrate funds");
        assertEq(address(vault).balance, 750 ether, "remaining balance is correct");
    }
}
