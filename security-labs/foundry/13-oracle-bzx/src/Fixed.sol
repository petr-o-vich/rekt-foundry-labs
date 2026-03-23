// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MockAnchorOracle {
    uint256 public spotPriceE18;
    uint256 public anchorPriceE18;

    constructor(uint256 initialPriceE18) {
        spotPriceE18 = initialPriceE18;
        anchorPriceE18 = initialPriceE18;
    }

    function setSpotPrice(uint256 newSpotPriceE18) external {
        spotPriceE18 = newSpotPriceE18;
    }

    function setAnchorPrice(uint256 newAnchorPriceE18) external {
        anchorPriceE18 = newAnchorPriceE18;
    }
}

contract FixedBzxLending {
    MockAnchorOracle public immutable oracle;
    uint256 public constant COLLATERAL_FACTOR_BPS = 7500; // 75%
    uint256 public constant MAX_DEVIATION_BPS = 1000; // 10%

    mapping(address => uint256) public collateralUnits;
    mapping(address => uint256) public debt;

    constructor(address oracle_) payable {
        oracle = MockAnchorOracle(oracle_);
    }

    function depositCollateral(uint256 units) external {
        collateralUnits[msg.sender] += units;
    }

    function _validatedPrice() internal view returns (uint256) {
        uint256 spot = oracle.spotPriceE18();
        uint256 anchor = oracle.anchorPriceE18();

        uint256 lower = (anchor * (10_000 - MAX_DEVIATION_BPS)) / 10_000;
        uint256 upper = (anchor * (10_000 + MAX_DEVIATION_BPS)) / 10_000;

        require(spot >= lower && spot <= upper, "oracle deviation too high");
        return spot;
    }

    function maxBorrow(address user) public view returns (uint256) {
        uint256 px = _validatedPrice();
        return (collateralUnits[user] * px * COLLATERAL_FACTOR_BPS) / 10_000 / 1e18;
    }

    function borrow(uint256 amount) external {
        require(debt[msg.sender] + amount <= maxBorrow(msg.sender), "insufficient collateral");
        debt[msg.sender] += amount;
        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok, "transfer failed");
    }

    receive() external payable {}
}
