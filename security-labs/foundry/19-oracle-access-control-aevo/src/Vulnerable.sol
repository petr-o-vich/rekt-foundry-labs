// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract VulnerableAevoSettlement {
    uint256 public expiryPrice;
    address public owner;

    constructor() payable {
        owner = msg.sender;
    }

    function setExpiryPrice(uint256 newPrice) external {
        // BUG: no access control
        expiryPrice = newPrice;
    }

    function settleAndPayout() external {
        // Simplified payout logic: if expiryPrice is high enough, pay caller.
        require(expiryPrice >= 5_000e8, "not in profit");
        uint256 payout = 10 ether;
        require(address(this).balance >= payout, "insufficient vault");
        (bool ok, ) = msg.sender.call{value: payout}("");
        require(ok, "transfer failed");
    }

    receive() external payable {}
}
