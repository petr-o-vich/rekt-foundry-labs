// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FixedRoninBridge {
    mapping(address => bool) public isValidator;
    uint256 public validatorCount;
    uint256 public threshold;
    address public owner;

    mapping(address => uint256) public balance;

    constructor(address[] memory initialValidators, uint256 _threshold, uint256 initialLiquidity) {
        require(initialValidators.length >= _threshold, "bad setup");

        owner = msg.sender;

        for (uint256 i = 0; i < initialValidators.length; i++) {
            isValidator[initialValidators[i]] = true;
        }

        validatorCount = initialValidators.length;
        threshold = _threshold;
        balance[address(this)] = initialLiquidity;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner");
        _;
    }

    // FIX: only governance/owner can change validator set.
    function addValidator(address validator) external onlyOwner {
        require(!isValidator[validator], "exists");
        isValidator[validator] = true;
        validatorCount += 1;
    }

    function submitWithdrawal(
        address to,
        uint256 amount,
        address[] calldata signers
    ) external {
        require(amount <= balance[address(this)], "insufficient liquidity");
        require(_countValidSigners(signers) >= threshold, "not enough signatures");

        balance[address(this)] -= amount;
        balance[to] += amount;
    }

    function _countValidSigners(address[] calldata signers) internal view returns (uint256 valid) {
        for (uint256 i = 0; i < signers.length; i++) {
            if (isValidator[signers[i]]) valid += 1;
        }
    }
}
