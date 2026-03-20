// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Fixed.sol";

contract RoninLikeFixTest is Test {
    FixedRoninBridge bridge;

    address[5] legit;
    address attacker = makeAddr("attacker");
    address[5] malicious;

    function setUp() public {
        for (uint256 i = 0; i < 5; i++) {
            legit[i] = makeAddr(string.concat("legit", vm.toString(i)));
            malicious[i] = makeAddr(string.concat("evil", vm.toString(i)));
        }

        address[] memory initialValidators = new address[](5);
        for (uint256 i = 0; i < 5; i++) {
            initialValidators[i] = legit[i];
        }

        bridge = new FixedRoninBridge(initialValidators, 5, 10_000 ether);
    }

    function testUnauthorizedValidatorInjectionReverts() public {
        vm.prank(attacker);
        vm.expectRevert("only owner");
        bridge.addValidator(malicious[0]);
    }

    function testFakeSignerSetCannotDrainFunds() public {
        address[] memory fakeSigs = new address[](5);
        for (uint256 i = 0; i < 5; i++) {
            fakeSigs[i] = malicious[i];
        }

        vm.prank(attacker);
        vm.expectRevert("not enough signatures");
        bridge.submitWithdrawal(attacker, 10_000 ether, fakeSigs);

        assertEq(bridge.balance(attacker), 0, "attacker got nothing");
        assertEq(bridge.balance(address(bridge)), 10_000 ether, "bridge funds safe");
    }
}
