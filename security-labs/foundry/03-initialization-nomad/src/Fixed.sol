// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FixedNomadLikeBridge {
    address public owner;
    address public relayer;
    bool public initialized;
    bytes32 public trustedRoot;
    mapping(bytes32 => bool) public processed;

    constructor(address _relayer) payable {
        owner = msg.sender;
        relayer = _relayer;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner");
        _;
    }

    modifier onlyRelayer() {
        require(msg.sender == relayer, "only relayer");
        _;
    }

    function initialize(bytes32 _root) external onlyOwner {
        require(!initialized, "already initialized");
        require(_root != bytes32(0), "zero root");

        initialized = true;
        trustedRoot = _root;
    }

    function updateRoot(bytes32 _root) external onlyOwner {
        require(initialized, "not initialized");
        require(_root != bytes32(0), "zero root");
        trustedRoot = _root;
    }

    function relay(
        bytes32 messageHash,
        address to,
        uint256 amount,
        uint256 nonce,
        bytes32 providedRoot
    ) external onlyRelayer {
        require(initialized, "not initialized");
        require(providedRoot == trustedRoot, "bad root");
        require(!processed[messageHash], "already processed");

        bytes32 expected = keccak256(abi.encode(block.chainid, address(this), to, amount, nonce));
        require(messageHash == expected, "bad message");

        processed[messageHash] = true;
        (bool ok, ) = to.call{value: amount}("");
        require(ok, "transfer failed");
    }

    receive() external payable {}
}
