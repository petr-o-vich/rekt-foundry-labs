// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract GovToken {
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

contract Treasury {
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

contract VulnerableGovernance {
    GovToken public token;
    Treasury public treasury;
    uint256 public immutable quorum;

    constructor(GovToken _token, uint256 _quorum) payable {
        token = _token;
        quorum = _quorum;
        treasury = new Treasury{value: msg.value}(address(this));
    }

    // VULN: spot balance voting + immediate execution
    function executeDrain(address to) external {
        require(token.balanceOf(msg.sender) >= quorum, "not enough voting power");
        treasury.drain(to);
    }
}
