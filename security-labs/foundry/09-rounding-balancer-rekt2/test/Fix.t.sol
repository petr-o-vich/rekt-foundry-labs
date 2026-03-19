// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Fixed.sol";

contract BalancerLikeRoundingFixTest is Test {
    FixedRoundingPool pool;
    address attacker = makeAddr("attacker");

    function setUp() public {
        pool = new FixedRoundingPool(1000, 3000);
        pool.faucet(attacker, 1);
    }

    function testExactBptOutNowChargesCeilTokenIn() public {
        vm.prank(attacker);
        pool.swapGivenOutBpt(2);

        // Ceil(2*1000/3000) = 1, so attacker pays 1 and cannot mint for free.
        assertEq(pool.tokenBalance(attacker), 0, "attacker paid required tokenIn");
        assertEq(pool.bptBalance(attacker), 2, "attacker received BPT after payment");
    }

    function testRoundTripNoFreeProfit() public {
        vm.startPrank(attacker);

        uint256 startToken = pool.tokenBalance(attacker);

        pool.swapGivenOutBpt(2);
        pool.swapGivenInBpt(2);

        assertEq(pool.tokenBalance(attacker), startToken, "no rounding arbitrage profit");
        vm.stopPrank();
    }
}
