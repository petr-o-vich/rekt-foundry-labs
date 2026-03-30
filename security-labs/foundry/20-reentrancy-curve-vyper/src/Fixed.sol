// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FixedCurvePool {
    mapping(address => uint256) public balances;
    bool private locked;

    modifier nonReentrant() {
        require(!locked, "reentrancy");
        locked = true;
        _;
        locked = false;
    }

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) external nonReentrant {
        require(balances[msg.sender] >= amount, "insufficient");

        // FIX: CEI + lock
        balances[msg.sender] -= amount;
        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok, "transfer failed");
    }
}

contract ReentrantAttackerFixed {
    FixedCurvePool public target;

    constructor(FixedCurvePool _target) {
        target = _target;
    }

    function attack() external payable {
        require(msg.value >= 1 ether, "seed >= 1 ether");
        target.deposit{value: 1 ether}();
        target.withdraw(1 ether);
    }

    receive() external payable {
        if (address(target).balance >= 1 ether) {
            target.withdraw(1 ether);
        }
    }
}
