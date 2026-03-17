// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MockQToken {
    mapping(address => uint256) public balanceOf;

    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
    }
}

contract VulnerableDepositBridge {
    MockQToken public immutable qToken;

    constructor(address _qToken) {
        qToken = MockQToken(_qToken);
    }

    // BUG: native branch does not validate msg.value against amount.
    function deposit(address token, uint256 amount) external payable {
        if (token == address(0)) {
            // missing: require(msg.value == amount && amount > 0)
        } else {
            revert("erc20 path omitted");
        }

        qToken.mint(msg.sender, amount);
    }
}
