// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FixedTempleTreasury {
    address public immutable owner;

    constructor() payable {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    function migrate(address payable to, uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "insufficient");
        (bool ok, ) = to.call{value: amount}("");
        require(ok, "transfer failed");
    }

    receive() external payable {}
}
