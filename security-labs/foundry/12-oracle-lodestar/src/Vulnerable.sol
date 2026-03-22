// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MockCollateralOracle {
    uint256 public priceE18;

    constructor(uint256 initialPriceE18) {
        priceE18 = initialPriceE18;
    }

    // VULN MODEL: permissionless spot update (manipulable source)
    function setPrice(uint256 newPriceE18) external {
        priceE18 = newPriceE18;
    }
}

contract VulnerableLodestarLending {
    MockCollateralOracle public immutable oracle;
    uint256 public constant LTV_BPS = 7000; // 70%

    mapping(address => uint256) public collateralUnits;
    mapping(address => uint256) public debt;

    constructor(address oracle_) payable {
        oracle = MockCollateralOracle(oracle_);
    }

    function depositCollateral(uint256 units) external {
        collateralUnits[msg.sender] += units;
    }

    function maxBorrow(address user) public view returns (uint256) {
        // BUG: raw spot price directly trusted.
        uint256 px = oracle.priceE18();
        return (collateralUnits[user] * px * LTV_BPS) / 10_000 / 1e18;
    }

    function borrow(uint256 amount) external {
        require(debt[msg.sender] + amount <= maxBorrow(msg.sender), "insufficient collateral");
        debt[msg.sender] += amount;
        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok, "transfer failed");
    }

    receive() external payable {}
}
