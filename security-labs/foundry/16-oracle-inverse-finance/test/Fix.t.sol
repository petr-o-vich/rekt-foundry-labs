// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Fixed.sol";

contract InverseOracleFixTest is Test {
    MockInverseOracleFixed oracle;
    FixedInverseLending lending;

    address attacker = makeAddr("attacker");

    function setUp() public {
        oracle = new MockInverseOracleFixed(1_000 ether); // fair price
        lending = new FixedInverseLending{value: 100_000 ether}(address(oracle));
    }

    function testFixBlocksSameOverBorrowIntent() public {
        vm.startPrank(attacker);
        lending.depositCollateral(1 ether);

        oracle.setPrice(100_000 ether); // same manipulation intent
        lending.syncPrice(); // clamped to +5%

        vm.expectRevert("insufficient collateral");
        lending.borrow(50_000 ether);
        vm.stopPrank();

        assertEq(lending.safePriceE18(), 1_050 ether, "price change is rate-limited");
        assertEq(address(lending).balance, 100_000 ether, "pool not drained");
    }
}
