// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FixedBancorVault {
    address public immutable owner;

    error NotOwner();

    constructor() payable {
        owner = msg.sender;
    }

    function emergencyWithdraw(address payable to, uint256 amount) external {
        if (msg.sender != owner) revert NotOwner();
        require(address(this).balance >= amount, "insufficient");
        (bool ok, ) = to.call{value: amount}("");
        require(ok, "transfer failed");
    }

    receive() external payable {}
}
