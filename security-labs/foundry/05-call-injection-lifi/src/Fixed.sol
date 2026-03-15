// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FixedBridgeExecutor {
    error Unauthorized();
    error TargetNotAllowed();
    error SelectorNotAllowed();

    address public immutable relayer;
    mapping(address => bool) public allowedTarget;
    mapping(bytes4 => bool) public allowedSelector;

    constructor(address _relayer, address _allowedTarget, bytes4 _allowedSelector) {
        relayer = _relayer;
        allowedTarget[_allowedTarget] = true;
        allowedSelector[_allowedSelector] = true;
    }

    function execute(address target, bytes calldata data) external returns (bytes memory) {
        if (msg.sender != relayer) revert Unauthorized();
        if (!allowedTarget[target]) revert TargetNotAllowed();

        bytes4 sel;
        assembly {
            sel := calldataload(data.offset)
        }
        if (!allowedSelector[sel]) revert SelectorNotAllowed();

        (bool ok, bytes memory ret) = target.call(data);
        require(ok, "call failed");
        return ret;
    }
}

contract TrustedBridgeTarget {
    mapping(address => uint256) public credited;

    function credit(address user, uint256 amount) external {
        credited[user] += amount;
    }
}
