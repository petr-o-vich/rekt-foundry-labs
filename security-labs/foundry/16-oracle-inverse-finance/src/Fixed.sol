// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MockInverseOracleFixed {
    uint256 public priceE18;

    constructor(uint256 initialPriceE18) {
        priceE18 = initialPriceE18;
    }

    // Still manipulable in this toy model; mitigation is in consumer logic.
    function setPrice(uint256 newPriceE18) external {
        priceE18 = newPriceE18;
    }
}

contract FixedInverseLending {
    MockInverseOracleFixed public immutable oracle;

    uint256 public constant COLLATERAL_FACTOR_BPS = 7500; // 75%
    uint256 public constant MAX_STEP_BPS = 500; // 5% per sync
    uint256 public safePriceE18;

    mapping(address => uint256) public collateralUnits;
    mapping(address => uint256) public debt;

    constructor(address oracle_) payable {
        oracle = MockInverseOracleFixed(oracle_);
        safePriceE18 = oracle.priceE18();
    }

    function depositCollateral(uint256 units) external {
        collateralUnits[msg.sender] += units;
    }

    function syncPrice() external {
        uint256 spot = oracle.priceE18();
        uint256 maxUp = (safePriceE18 * (10_000 + MAX_STEP_BPS)) / 10_000;
        uint256 maxDown = (safePriceE18 * (10_000 - MAX_STEP_BPS)) / 10_000;

        if (spot > maxUp) {
            safePriceE18 = maxUp;
        } else if (spot < maxDown) {
            safePriceE18 = maxDown;
        } else {
            safePriceE18 = spot;
        }
    }

    function maxBorrow(address user) public view returns (uint256) {
        return (collateralUnits[user] * safePriceE18 * COLLATERAL_FACTOR_BPS) / 10_000 / 1e18;
    }

    function borrow(uint256 amount) external {
        require(debt[msg.sender] + amount <= maxBorrow(msg.sender), "insufficient collateral");
        debt[msg.sender] += amount;
        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok, "transfer failed");
    }

    receive() external payable {}
}
