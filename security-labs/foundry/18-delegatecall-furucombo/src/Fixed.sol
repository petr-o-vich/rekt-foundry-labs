// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FixedFurucomboProxy {
    address public owner;
    mapping(address => bool) public trustedTarget;

    constructor() payable {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    function setTrustedTarget(address target, bool allowed) external onlyOwner {
        trustedTarget[target] = allowed;
    }

    function execute(address target, bytes calldata data) external {
        require(trustedTarget[target], "target not trusted");
        (bool ok, ) = target.delegatecall(data);
        require(ok, "delegatecall failed");
    }

    function sweep(address payable to) external onlyOwner {
        (bool ok, ) = to.call{value: address(this).balance}("");
        require(ok, "send failed");
    }

    receive() external payable {}
}

contract SafeNoopModule {
    uint256 public calls;

    function run() external {
        calls += 1;
    }
}

contract MaliciousInitModuleFixed {
    function initAndHijack(address newOwner) external {
        assembly {
            sstore(0, newOwner)
        }
    }
}
