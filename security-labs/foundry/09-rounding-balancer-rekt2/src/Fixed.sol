// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FixedRoundingPool {
    mapping(address => uint256) public tokenBalance;
    mapping(address => uint256) public bptBalance;

    uint256 public tokenReserve;
    uint256 public bptSupply;

    constructor(uint256 _tokenReserve, uint256 _bptSupply) {
        tokenReserve = _tokenReserve;
        bptSupply = _bptSupply;
    }

    function faucet(address to, uint256 amount) external {
        tokenBalance[to] += amount;
    }

    // FIX: exact-BPT-out path must round UP the token payment.
    function swapGivenOutBpt(uint256 bptOut) external {
        uint256 tokenIn = _ceilDiv(bptOut * tokenReserve, bptSupply);

        require(tokenBalance[msg.sender] >= tokenIn, "insufficient token");
        tokenBalance[msg.sender] -= tokenIn;
        tokenReserve += tokenIn;

        bptBalance[msg.sender] += bptOut;
        bptSupply += bptOut;
    }

    // FIX: exact-BPT-in path must round DOWN token payout.
    function swapGivenInBpt(uint256 bptIn) external {
        require(bptBalance[msg.sender] >= bptIn, "insufficient bpt");

        uint256 tokenOut = (bptIn * tokenReserve) / bptSupply;
        require(tokenReserve >= tokenOut, "insufficient reserve");

        bptBalance[msg.sender] -= bptIn;
        bptSupply -= bptIn;

        tokenReserve -= tokenOut;
        tokenBalance[msg.sender] += tokenOut;
    }

    function _ceilDiv(uint256 x, uint256 y) internal pure returns (uint256) {
        if (x == 0) return 0;
        return (x - 1) / y + 1;
    }
}
