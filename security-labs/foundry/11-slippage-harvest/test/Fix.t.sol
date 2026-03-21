// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Fixed.sol";

contract HarvestSlippageFixTest is Test {
    MockAmmFixed amm;
    FixedHarvestStrategy strategy;

    function setUp() public {
        amm = new MockAmmFixed(1_000_000 ether, 1_000_000 ether);
        // oracle says 1 TOKEN = 1 USDC, max slippage 5%
        strategy = new FixedHarvestStrategy(address(amm), 100 ether, 1e18, 500);
    }

    function testManipulatedPriceRevertsOnSlippageGuard() public {
        amm.setReserves(1_000_000 ether, 100_000 ether); // manipulated low output

        vm.expectRevert("slippage");
        strategy.harvest(100 ether);

        assertEq(strategy.usdcBalance(), 0, "no bad execution");
        assertEq(strategy.tokenBalance(), 100 ether, "tokens preserved");
    }
}
