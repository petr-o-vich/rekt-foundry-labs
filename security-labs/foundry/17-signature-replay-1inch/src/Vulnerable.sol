// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Vulnerable1InchRouter {
    mapping(address => uint256) public makerBalance;

    constructor() payable {}

    function depositFor(address maker, uint256 amount) external {
        makerBalance[maker] += amount;
    }

    function fillOrder(
        bytes32 orderHash,
        address maker,
        address taker,
        uint256 amount,
        bool signatureValid
    ) external {
        require(signatureValid, "bad sig");
        require(amount > 0, "zero");
        require(makerBalance[maker] >= amount, "insufficient maker");

        // BUG: orderHash is checked by signature logic off-chain,
        // but never consumed on-chain. Same signed order can be replayed.
        makerBalance[maker] -= amount;
        (bool ok, ) = taker.call{value: amount}("");
        require(ok, "transfer failed");
    }

    receive() external payable {}
}
