// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IAmm {
    function swapTokenForUsdc(uint256 amountIn, uint256 minOut) external returns (uint256 out);
}

contract VulnerableHarvestStrategy {
    IAmm public immutable amm;

    uint256 public tokenBalance;
    uint256 public usdcBalance;

    constructor(address _amm, uint256 initialTokenBalance) {
        amm = IAmm(_amm);
        tokenBalance = initialTokenBalance;
    }

    // BUG: minOut = 0, strategy accepts any execution price.
    function harvest(uint256 amountToken) external {
        require(amountToken <= tokenBalance, "insufficient token");

        tokenBalance -= amountToken;
        uint256 out = amm.swapTokenForUsdc(amountToken, 0);
        usdcBalance += out;
    }
}

contract MockAmm {
    uint256 public reserveToken;
    uint256 public reserveUsdc;

    constructor(uint256 _reserveToken, uint256 _reserveUsdc) {
        reserveToken = _reserveToken;
        reserveUsdc = _reserveUsdc;
    }

    // Simplified x*y style quote for the lab.
    function swapTokenForUsdc(uint256 amountIn, uint256 minOut) external returns (uint256 out) {
        require(amountIn > 0, "zero in");
        out = (amountIn * reserveUsdc) / reserveToken;
        require(out >= minOut, "slippage");
        require(out <= reserveUsdc, "insufficient usdc");

        reserveToken += amountIn;
        reserveUsdc -= out;
    }

    // Lab helper to model temporary manipulation.
    function setReserves(uint256 _reserveToken, uint256 _reserveUsdc) external {
        reserveToken = _reserveToken;
        reserveUsdc = _reserveUsdc;
    }
}
