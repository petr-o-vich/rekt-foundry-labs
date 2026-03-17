// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Vulnerable.sol";
import "../src/Fixed.sol";

contract QubitLikeValidationFixTest is Test {
    MockQToken qToken;
    FixedDepositBridge bridge;
    address user = makeAddr("user");

    function setUp() public {
        qToken = new MockQToken();
        bridge = new FixedDepositBridge(address(qToken));
    }

    function testZeroValueNativeDepositBlocked() public {
        vm.prank(user);
        vm.expectRevert(FixedDepositBridge.InvalidNativeDeposit.selector);
        bridge.deposit(address(0), 100 ether);

        assertEq(qToken.balanceOf(user), 0, "no free mint");
    }

    function testValidNativeDepositMints() public {
        vm.deal(user, 10 ether);

        vm.prank(user);
        bridge.deposit{value: 3 ether}(address(0), 3 ether);

        assertEq(qToken.balanceOf(user), 3 ether, "mint backed by native deposit");
    }
}
