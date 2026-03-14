// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MockSpotOracle {
    uint256 public priceE18;

    constructor(uint256 initialPriceE18) {
        priceE18 = initialPriceE18;
    }

    // VULN MODEL: permissionless price update (as if thin pool spot can be pushed)
    function setPrice(uint256 newPriceE18) external {
        priceE18 = newPriceE18;
    }
}

contract VulnerableOracleLending {
    MockSpotOracle public immutable oracle;

    mapping(address => uint256) public collateralUnits;
    mapping(address => uint256) public debt;

    constructor(address oracle_) payable {
        oracle = MockSpotOracle(oracle_);
    }

    function depositCollateral(uint256 units) external {
        collateralUnits[msg.sender] += units;
    }

    function maxBorrow(address user) public view returns (uint256) {
        // 80% LTV against spot price (manipulable)
        uint256 spot = oracle.priceE18();
        return (collateralUnits[user] * spot * 80) / 100 / 1e18;
    }

    function borrow(uint256 amount) external {
        require(debt[msg.sender] + amount <= maxBorrow(msg.sender), "insufficient collateral");
        debt[msg.sender] += amount;
        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok, "transfer failed");
    }

    receive() external payable {}
}
