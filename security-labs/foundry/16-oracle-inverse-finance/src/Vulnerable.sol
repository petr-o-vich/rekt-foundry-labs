// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MockInverseOracle {
    uint256 public priceE18;

    constructor(uint256 initialPriceE18) {
        priceE18 = initialPriceE18;
    }

    // VULN MODEL: permissionless spot update.
    function setPrice(uint256 newPriceE18) external {
        priceE18 = newPriceE18;
    }
}

contract VulnerableInverseLending {
    MockInverseOracle public immutable oracle;
    uint256 public constant COLLATERAL_FACTOR_BPS = 7500; // 75%

    mapping(address => uint256) public collateralUnits;
    mapping(address => uint256) public debt;

    constructor(address oracle_) payable {
        oracle = MockInverseOracle(oracle_);
    }

    function depositCollateral(uint256 units) external {
        collateralUnits[msg.sender] += units;
    }

    function maxBorrow(address user) public view returns (uint256) {
        // BUG: trusts manipulative spot price directly.
        return (collateralUnits[user] * oracle.priceE18() * COLLATERAL_FACTOR_BPS) / 10_000 / 1e18;
    }

    function borrow(uint256 amount) external {
        require(debt[msg.sender] + amount <= maxBorrow(msg.sender), "insufficient collateral");
        debt[msg.sender] += amount;
        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok, "transfer failed");
    }

    receive() external payable {}
}
