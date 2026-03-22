// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Fixed.sol";

contract LodestarOracleFixTest is Test {
    MockCappedOracle oracle;
    FixedLodestarLending lending;

    address attacker = makeAddr("attacker");

    function setUp() public {
        oracle = new MockCappedOracle(1e18);
        lending = new FixedLodestarLending{value: 1_000 ether}(address(oracle));

        vm.prank(attacker);
        lending.depositCollateral(100 ether);
    }

    function testBorrowBlockedByCollateralPriceCap() public {
        // Spot is pumped, anchor stays at fair price.
        oracle.update(10e18, 1e18);

        vm.startPrank(attacker);
        vm.expectRevert("insufficient collateral");
        lending.borrow(100 ether);
        vm.stopPrank();

        assertEq(address(lending).balance, 1_000 ether, "pool remains intact");
    }
}
