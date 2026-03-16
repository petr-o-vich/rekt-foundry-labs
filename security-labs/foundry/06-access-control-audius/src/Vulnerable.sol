// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MockERC20 {
    mapping(address => uint256) public balanceOf;

    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "insufficient");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}

contract VulnerableGovernanceTreasury {
    address public guardian;
    address public treasury;

    // BUG: can be called multiple times, allowing role takeover.
    function initialize(address _guardian, address _treasury) external {
        guardian = _guardian;
        treasury = _treasury;
    }

    function emergencyTransfer(address token, address to, uint256 amount) external {
        require(msg.sender == guardian, "not guardian");
        MockERC20(token).transfer(to, amount);
    }
}
