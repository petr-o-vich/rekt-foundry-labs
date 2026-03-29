// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FixedAevoSettlement {
    uint256 public expiryPrice;
    address public immutable oracle;

    constructor(address _oracle) payable {
        oracle = _oracle;
    }

    function setExpiryPrice(uint256 newPrice) external {
        require(msg.sender == oracle, "not oracle");
        expiryPrice = newPrice;
    }

    function settleAndPayout() external {
        require(expiryPrice >= 5_000e8, "not in profit");
        uint256 payout = 10 ether;
        require(address(this).balance >= payout, "insufficient vault");
        (bool ok, ) = msg.sender.call{value: payout}("");
        require(ok, "transfer failed");
    }

    receive() external payable {}
}
