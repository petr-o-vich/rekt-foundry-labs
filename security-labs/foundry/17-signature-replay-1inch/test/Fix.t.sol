// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Fixed.sol";

contract OneInchReplayFixTest is Test {
    Fixed1InchRouter router;

    address maker = makeAddr("maker");
    address taker = makeAddr("taker");

    function setUp() public {
        router = new Fixed1InchRouter{value: 100 ether}();
        router.depositFor(maker, 100 ether);
    }

    function testReplaySecondFillRevertsAndFundsStaySafe() public {
        bytes32 orderHash = keccak256("1inch-order-1");

        router.fillOrder(orderHash, maker, taker, 40 ether, true);
        assertEq(taker.balance, 40 ether, "first fill works");

        vm.expectRevert(Fixed1InchRouter.OrderAlreadyUsed.selector);
        router.fillOrder(orderHash, maker, taker, 40 ether, true);

        assertEq(taker.balance, 40 ether, "no second payout");
        assertEq(router.makerBalance(maker), 60 ether, "maker protected after first fill");
    }
}
