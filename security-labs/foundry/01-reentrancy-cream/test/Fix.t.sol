// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Fixed.sol";

contract ReentrantAttackerFixed {
    FixedVault public target;
    uint256 public chunk;

    constructor(FixedVault _target) {
        target = _target;
    }

    function attack(uint256 amount) external payable {
        chunk = amount;
        target.deposit{value: msg.value}();
        target.withdraw(amount);
    }

    receive() external payable {
        if (address(target).balance >= chunk) {
            // second call should fail due to nonReentrant / CEI
            try target.withdraw(chunk) {} catch {}
        }
    }
}

contract FixedExploitTest is Test {
    FixedVault vault;
    ReentrantAttackerFixed attacker;

    address victim = makeAddr("victim");

    function setUp() public {
        vault = new FixedVault();
        attacker = new ReentrantAttackerFixed(vault);

        vm.deal(victim, 10 ether);
        vm.prank(victim);
        vault.deposit{value: 10 ether}();

        vm.deal(address(attacker), 1 ether);
    }

    function testExploitFailsAfterFix() public {
        uint256 before = address(attacker).balance;

        vm.prank(address(attacker));
        attacker.attack{value: 1 ether}(1 ether);

        uint256 afterBal = address(attacker).balance;

        // attacker only gets back its own 1 ether withdrawal; cannot steal victim funds
        assertLe(afterBal, before + 1 ether, "attacker must not drain extra funds");
        assertEq(address(vault).balance, 10 ether, "victim funds remain in vault");
    }
}
