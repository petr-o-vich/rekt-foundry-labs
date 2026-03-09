// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FixedGovToken {
    mapping(address => uint256) public balanceOf;

    function transfer(address to, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "insufficient");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }

    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
    }

    function burn(address from, uint256 amount) external {
        require(balanceOf[from] >= amount, "insufficient");
        balanceOf[from] -= amount;
    }
}

contract FixedTreasury {
    address public governance;

    constructor(address _governance) payable {
        governance = _governance;
    }

    function drain(address to) external {
        require(msg.sender == governance, "only governance");
        (bool ok, ) = to.call{value: address(this).balance}("");
        require(ok, "transfer failed");
    }

    receive() external payable {}
}

contract FixedGovernance {
    FixedGovToken public token;
    FixedTreasury public treasury;
    uint256 public immutable quorum;
    uint256 public constant DELAY = 1 days;

    mapping(address => uint256) public locked;
    mapping(address => uint256) public eta;

    constructor(FixedGovToken _token, uint256 _quorum) payable {
        token = _token;
        quorum = _quorum;
        treasury = new FixedTreasury{value: msg.value}(address(this));
    }

    function lock(uint256 amount) external {
        require(token.transfer(address(this), amount), "lock transfer failed");
        locked[msg.sender] += amount;
    }

    function unlock(uint256 amount) external {
        require(block.timestamp > eta[msg.sender], "proposal pending");
        require(locked[msg.sender] >= amount, "insufficient locked");
        locked[msg.sender] -= amount;
        require(token.transfer(msg.sender, amount), "unlock transfer failed");
    }

    function proposeDrain() external {
        require(locked[msg.sender] >= quorum, "not enough locked voting power");
        eta[msg.sender] = block.timestamp + DELAY;
    }

    function executeDrain(address to) external {
        require(locked[msg.sender] >= quorum, "not enough locked voting power");
        require(eta[msg.sender] != 0 && block.timestamp >= eta[msg.sender], "timelock");
        eta[msg.sender] = 0;
        treasury.drain(to);
    }
}
