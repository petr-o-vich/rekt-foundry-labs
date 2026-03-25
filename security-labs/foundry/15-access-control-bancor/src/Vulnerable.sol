// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract VulnerableBancorVault {
    address public immutable owner;

    constructor() payable {
        owner = msg.sender;
    }

    // BUG: privileged withdraw path is callable by anyone.
    function emergencyWithdraw(address payable to, uint256 amount) external {
        require(address(this).balance >= amount, "insufficient");
        (bool ok, ) = to.call{value: amount}("");
        require(ok, "transfer failed");
    }

    receive() external payable {}
}
