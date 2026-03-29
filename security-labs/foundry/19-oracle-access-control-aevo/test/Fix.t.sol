// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Fixed.sol";

contract AevoFixTest is Test {
    FixedAevoSettlement settlement;
    address oracle = makeAddr("oracle");
    address attacker = makeAddr("attacker");

    function setUp() public {
        settlement = new FixedAevoSettlement{value: 20 ether}(oracle);
    }

    function testUnauthorizedWriterBlocked() public {
        vm.prank(attacker);
        vm.expectRevert("not oracle");
        settlement.setExpiryPrice(9_999e8);

        vm.prank(attacker);
        vm.expectRevert("not in profit");
        settlement.settleAndPayout();

        assertEq(address(settlement).balance, 20 ether, "vault safe");
    }

    function testAuthorizedOracleCanSetPrice() public {
        vm.prank(oracle);
        settlement.setExpiryPrice(5_100e8);

        vm.prank(attacker);
        settlement.settleAndPayout();

        assertEq(attacker.balance, 10 ether, "normal payout after valid oracle update");
    }
}
