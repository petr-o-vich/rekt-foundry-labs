// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Fixed1InchRouter {
    mapping(address => uint256) public makerBalance;
    mapping(bytes32 => bool) public used;

    error BadSig();
    error ZeroAmount();
    error InsufficientMaker();
    error OrderAlreadyUsed();

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
        if (!signatureValid) revert BadSig();
        if (amount == 0) revert ZeroAmount();
        if (used[orderHash]) revert OrderAlreadyUsed();
        if (makerBalance[maker] < amount) revert InsufficientMaker();

        used[orderHash] = true;
        makerBalance[maker] -= amount;
        (bool ok, ) = taker.call{value: amount}("");
        require(ok, "transfer failed");
    }

    receive() external payable {}
}
