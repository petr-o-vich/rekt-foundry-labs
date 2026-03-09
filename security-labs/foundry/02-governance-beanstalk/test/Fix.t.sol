// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Fixed.sol";

contract GovernanceFixTest is Test {
    FixedGovToken token;
    FixedGovernance gov;
    address attacker = makeAddr("attacker");

    function setUp() public {
        token = new FixedGovToken();
        gov = new FixedGovernance{value: 100 ether}(token, 500_000 ether);
    }

    function testSameTxFlashLoanPathFailsAfterFix() public {
        // Simulate temporary voting power in one tx.
        token.mint(attacker, 1_000_000 ether);

        vm.startPrank(attacker);
        gov.lock(600_000 ether);
        gov.proposeDrain();
        vm.expectRevert(bytes("timelock"));
        gov.executeDrain(attacker);
        vm.stopPrank();

        // Simulate flash-loan repayment (temporary balance gone).
        token.burn(attacker, 400_000 ether);

        assertEq(address(gov.treasury()).balance, 100 ether, "treasury must remain intact");
    }

    function testDrainAllowedOnlyAfterDelayWithLockedVotingPower() public {
        token.mint(attacker, 600_000 ether);

        vm.startPrank(attacker);
        gov.lock(600_000 ether);
        gov.proposeDrain();

        vm.warp(block.timestamp + gov.DELAY());
        gov.executeDrain(attacker);
        vm.stopPrank();

        assertEq(address(gov.treasury()).balance, 0, "drain allowed only after delay");
    }
}
