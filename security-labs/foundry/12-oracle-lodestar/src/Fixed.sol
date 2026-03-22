// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MockCappedOracle {
    uint256 public anchorPriceE18;
    uint256 public spotPriceE18;

    constructor(uint256 initialPriceE18) {
        anchorPriceE18 = initialPriceE18;
        spotPriceE18 = initialPriceE18;
    }

    function update(uint256 newSpotE18, uint256 newAnchorE18) external {
        spotPriceE18 = newSpotE18;
        anchorPriceE18 = newAnchorE18;
    }
}

contract FixedLodestarLending {
    MockCappedOracle public immutable oracle;

    uint256 public constant LTV_BPS = 6000; // tighter LTV
    uint256 public constant MAX_INCREASE_BPS = 2000; // allow max +20% vs anchor

    mapping(address => uint256) public collateralUnits;
    mapping(address => uint256) public debt;

    constructor(address oracle_) payable {
        oracle = MockCappedOracle(oracle_);
    }

    function depositCollateral(uint256 units) external {
        collateralUnits[msg.sender] += units;
    }

    function effectivePriceE18() public view returns (uint256) {
        uint256 anchor = oracle.anchorPriceE18();
        uint256 spot = oracle.spotPriceE18();
        require(anchor > 0, "bad anchor");

        uint256 cap = (anchor * (10_000 + MAX_INCREASE_BPS)) / 10_000;
        return spot > cap ? cap : spot;
    }

    function maxBorrow(address user) public view returns (uint256) {
        uint256 px = effectivePriceE18();
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
