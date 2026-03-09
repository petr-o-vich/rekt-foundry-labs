// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Fixed.sol";

contract FixedInvariantTest is Test {
    FixedVault vault;
    address userA = makeAddr("userA");
    address userB = makeAddr("userB");

    function setUp() public {
        vault = new FixedVault();
        vm.deal(userA, 5 ether);
        vm.deal(userB, 7 ether);

        vm.prank(userA);
        vault.deposit{value: 5 ether}();

        vm.prank(userB);
        vault.deposit{value: 7 ether}();
    }

    function invariant_balanceBackedByRecordedBalances() public view {
        uint256 recorded = vault.balances(userA) + vault.balances(userB);
        assertEq(address(vault).balance, recorded);
    }
}
