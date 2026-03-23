// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Fixed.sol";

contract BzxOracleFixTest is Test {
    MockAnchorOracle oracle;
    FixedBzxLending lending;

    address attacker = makeAddr("attacker");

    function setUp() public {
        oracle = new MockAnchorOracle(1e18);
        lending = new FixedBzxLending{value: 1_000 ether}(address(oracle));

        vm.prank(attacker);
        lending.depositCollateral(100 ether);
    }

    function testBorrowBlockedWhenSpotDeviatesFromAnchor() public {
        // Same attack intent: spot is pumped far above anchor.
        oracle.setSpotPrice(8e18);

        vm.prank(attacker);
        vm.expectRevert("oracle deviation too high");
        lending.borrow(600 ether);

        assertEq(attacker.balance, 0, "attacker gets nothing");
        assertEq(address(lending).balance, 1_000 ether, "pool remains intact");
    }
}
