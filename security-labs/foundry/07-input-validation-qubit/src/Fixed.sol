// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Vulnerable.sol";

contract FixedDepositBridge {
    error InvalidNativeDeposit();
    error UnsupportedToken();

    MockQToken public immutable qToken;

    constructor(address _qToken) {
        qToken = MockQToken(_qToken);
    }

    function deposit(address token, uint256 amount) external payable {
        if (token == address(0)) {
            if (amount == 0 || msg.value != amount) revert InvalidNativeDeposit();
        } else {
            revert UnsupportedToken();
        }

        qToken.mint(msg.sender, amount);
    }
}
