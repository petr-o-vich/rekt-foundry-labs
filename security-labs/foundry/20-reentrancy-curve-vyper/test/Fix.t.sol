// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Fixed.sol";

contract CurveFixTest is Test {
    FixedCurvePool pool;
    ReentrantAttackerFixed attacker;
    address lp = makeAddr("lp");

    function setUp() public {
        pool = new FixedCurvePool();
        attacker = new ReentrantAttackerFixed(pool);

        vm.deal(lp, 20 ether);
        vm.prank(lp);
        pool.deposit{value: 20 ether}();

        vm.deal(address(attacker), 1 ether);
    }

    function testReentrancyBlockedByLockAndCEI() public {
        vm.expectRevert(bytes("transfer failed"));
        vm.prank(address(attacker));
        attacker.attack{value: 1 ether}();

        assertEq(address(pool).balance, 20 ether, "pool remains intact");
        assertEq(address(attacker).balance, 1 ether, "attacker failed to extract funds");
    }
}
