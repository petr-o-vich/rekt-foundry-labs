// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IAmmFixed {
    function swapTokenForUsdc(uint256 amountIn, uint256 minOut) external returns (uint256 out);
}

contract FixedHarvestStrategy {
    IAmmFixed public immutable amm;

    uint256 public tokenBalance;
    uint256 public usdcBalance;

    uint256 public immutable oraclePriceE18; // USDC per TOKEN, 1e18 scale
    uint256 public immutable maxSlippageBps;

    constructor(
        address _amm,
        uint256 initialTokenBalance,
        uint256 _oraclePriceE18,
        uint256 _maxSlippageBps
    ) {
        require(_maxSlippageBps <= 2_000, "slippage too wide");

        amm = IAmmFixed(_amm);
        tokenBalance = initialTokenBalance;
        oraclePriceE18 = _oraclePriceE18;
        maxSlippageBps = _maxSlippageBps;
    }

    // FIX: enforce minOut from reference price and slippage bound.
    function harvest(uint256 amountToken) external {
        require(amountToken <= tokenBalance, "insufficient token");

        uint256 expectedOut = (amountToken * oraclePriceE18) / 1e18;
        uint256 minOut = (expectedOut * (10_000 - maxSlippageBps)) / 10_000;

        tokenBalance -= amountToken;
        uint256 out = amm.swapTokenForUsdc(amountToken, minOut);
        usdcBalance += out;
    }
}

contract MockAmmFixed {
    uint256 public reserveToken;
    uint256 public reserveUsdc;

    constructor(uint256 _reserveToken, uint256 _reserveUsdc) {
        reserveToken = _reserveToken;
        reserveUsdc = _reserveUsdc;
    }

    function swapTokenForUsdc(uint256 amountIn, uint256 minOut) external returns (uint256 out) {
        require(amountIn > 0, "zero in");
        out = (amountIn * reserveUsdc) / reserveToken;
        require(out >= minOut, "slippage");
        require(out <= reserveUsdc, "insufficient usdc");

        reserveToken += amountIn;
        reserveUsdc -= out;
    }

    function setReserves(uint256 _reserveToken, uint256 _reserveUsdc) external {
        reserveToken = _reserveToken;
        reserveUsdc = _reserveUsdc;
    }
}
