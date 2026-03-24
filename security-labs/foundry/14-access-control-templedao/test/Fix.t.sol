// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Fixed.sol";

contract TempleDaoAccessControlFixTest is Test {
    FixedTempleTreasury treasury;

    address deployer = makeAddr("deployer");
    address attacker = makeAddr("attacker");

    function setUp() public {
        vm.prank(deployer);
        treasury = new FixedTempleTreasury{value: 500 ether}();
    }

    function testUnauthorizedMigrateReverts() public {
        vm.prank(attacker);
        vm.expectRevert("not owner");
        treasury.migrate(payable(attacker), 500 ether);

        assertEq(attacker.balance, 0, "attacker got nothing");
        assertEq(address(treasury).balance, 500 ether, "treasury intact");
    }
}
