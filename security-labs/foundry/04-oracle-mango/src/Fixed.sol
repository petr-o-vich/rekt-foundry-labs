// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MockSafeOracle {
    uint256 public twapPriceE18;
    uint256 public lastPriceE18;

    constructor(uint256 initialPriceE18) {
        twapPriceE18 = initialPriceE18;
        lastPriceE18 = initialPriceE18;
    }

    function updatePrices(uint256 newSpotE18, uint256 newTwapE18) external {
        lastPriceE18 = newSpotE18;
        twapPriceE18 = newTwapE18;
    }
}

contract FixedOracleLending {
    MockSafeOracle public immutable oracle;
    uint256 public constant MAX_DEVIATION_BPS = 2000; // 20%
    uint256 public constant LTV_BPS = 5000; // 50%

    mapping(address => uint256) public collateralUnits;
    mapping(address => uint256) public debt;

    constructor(address oracle_) payable {
        oracle = MockSafeOracle(oracle_);
    }

    function depositCollateral(uint256 units) external {
        collateralUnits[msg.sender] += units;
    }

    function _checkedPrice() internal view returns (uint256) {
        uint256 spot = oracle.lastPriceE18();
        uint256 twap = oracle.twapPriceE18();
        require(twap > 0, "bad twap");

        uint256 diff = spot > twap ? spot - twap : twap - spot;
        require(diff * 10_000 <= twap * MAX_DEVIATION_BPS, "price deviation too high");

        return twap;
    }

    function maxBorrow(address user) public view returns (uint256) {
        uint256 px = _checkedPrice();
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
