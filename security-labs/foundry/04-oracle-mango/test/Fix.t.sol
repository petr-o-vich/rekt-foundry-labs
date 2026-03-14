// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Fixed.sol";

contract MangoOracleManipulationFixTest is Test {
    MockSafeOracle oracle;
    FixedOracleLending lending;

    address attacker = makeAddr("attacker");

    function setUp() public {
        oracle = new MockSafeOracle(1e18); // $1
        lending = new FixedOracleLending{value: 1_000 ether}(address(oracle));

        vm.prank(attacker);
        lending.depositCollateral(1_000 ether);
    }

    function testBorrowBlockedAfterPriceSpike() public {
        // Spot jumps 10x while TWAP stays flat.
        oracle.updatePrices(10e18, 1e18);

        vm.startPrank(attacker);
        vm.expectRevert("price deviation too high");
        lending.borrow(1 ether);
        vm.stopPrank();

        assertEq(address(lending).balance, 1_000 ether, "liquidity should remain safe");
    }
}
