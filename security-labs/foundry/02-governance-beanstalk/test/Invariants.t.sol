// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Fixed.sol";

contract GovernanceInvariantTest is Test {
    FixedGovToken token;
    FixedGovernance gov;
    address user = makeAddr("user");

    function setUp() public {
        token = new FixedGovToken();
        gov = new FixedGovernance{value: 10 ether}(token, 100 ether);

        token.mint(user, 200 ether);
        vm.prank(user);
        gov.lock(120 ether);
        vm.prank(user);
        gov.proposeDrain();
    }

    function invariant_noDrainBeforeETA() public view {
        if (block.timestamp < gov.eta(user)) {
            assertEq(address(gov.treasury()).balance, 10 ether);
        }
    }
}
