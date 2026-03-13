// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract VulnerableNomadLikeBridge {
    bytes32 public trustedRoot;
    mapping(bytes32 => bool) public processed;

    constructor() payable {}

    function initialize(bytes32 _root) external {
        // VULN: can be called by anyone, any time; zero root is allowed.
        trustedRoot = _root;
    }

    function relay(
        bytes32 messageHash,
        address to,
        uint256 amount,
        bytes32 providedRoot
    ) external {
        require(providedRoot == trustedRoot, "bad root");
        require(!processed[messageHash], "already processed");

        processed[messageHash] = true;
        (bool ok, ) = to.call{value: amount}("");
        require(ok, "transfer failed");
    }

    receive() external payable {}
}
