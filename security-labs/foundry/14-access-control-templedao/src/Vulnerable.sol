// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract VulnerableTempleTreasury {
    address public immutable owner;

    constructor() payable {
        owner = msg.sender;
    }

    // BUG: migration function is externally callable by anyone.
    function migrate(address payable to, uint256 amount) external {
        require(address(this).balance >= amount, "insufficient");
        (bool ok, ) = to.call{value: amount}("");
        require(ok, "transfer failed");
    }

    receive() external payable {}
}
