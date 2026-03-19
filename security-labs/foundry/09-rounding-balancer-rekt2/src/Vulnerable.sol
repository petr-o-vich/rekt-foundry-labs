// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract VulnerableRoundingPool {
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

    // BUG #1: round down on "exact BPT out" lets small mints cost 0 when bptSupply > tokenReserve.
    function swapGivenOutBpt(uint256 bptOut) external {
        uint256 tokenIn = (bptOut * tokenReserve) / bptSupply;

        require(tokenBalance[msg.sender] >= tokenIn, "insufficient token");
        tokenBalance[msg.sender] -= tokenIn;
        tokenReserve += tokenIn;

        bptBalance[msg.sender] += bptOut;
        bptSupply += bptOut;
    }

    // BUG #2: round up on "exact BPT in" overpays tokenOut by up to 1 each swap.
    function swapGivenInBpt(uint256 bptIn) external {
        require(bptBalance[msg.sender] >= bptIn, "insufficient bpt");

        uint256 tokenOut = (bptIn * tokenReserve + bptSupply - 1) / bptSupply;
        require(tokenReserve >= tokenOut, "insufficient reserve");

        bptBalance[msg.sender] -= bptIn;
        bptSupply -= bptIn;

        tokenReserve -= tokenOut;
        tokenBalance[msg.sender] += tokenOut;
    }
}
