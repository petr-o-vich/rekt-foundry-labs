// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Vulnerable.sol";

contract FixedGovernanceTreasury {
    error AlreadyInitialized();
    error Unauthorized();
    error ZeroAddress();

    address public guardian;
    address public treasury;
    bool public initialized;

    function initialize(address _guardian, address _treasury) external {
        if (initialized) revert AlreadyInitialized();
        if (_guardian == address(0) || _treasury == address(0)) revert ZeroAddress();

        guardian = _guardian;
        treasury = _treasury;
        initialized = true;
    }

    function emergencyTransfer(address token, address to, uint256 amount) external {
        if (msg.sender != guardian) revert Unauthorized();
        MockERC20(token).transfer(to, amount);
    }
}
