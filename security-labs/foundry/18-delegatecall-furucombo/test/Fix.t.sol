// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Fixed.sol";

contract FurucomboFixTest is Test {
    FixedFurucomboProxy proxy;
    SafeNoopModule safeModule;
    MaliciousInitModuleFixed malicious;

    address attacker = makeAddr("attacker");

    function setUp() public {
        proxy = new FixedFurucomboProxy{value: 10 ether}();
        safeModule = new SafeNoopModule();
        malicious = new MaliciousInitModuleFixed();

        proxy.setTrustedTarget(address(safeModule), true);
    }

    function testUntrustedModuleCannotHijackOwner() public {
        vm.prank(attacker);
        vm.expectRevert("target not trusted");
        proxy.execute(address(malicious), abi.encodeWithSignature("initAndHijack(address)", attacker));

        assertEq(proxy.owner(), address(this), "owner remains unchanged");

        vm.prank(attacker);
        vm.expectRevert("not owner");
        proxy.sweep(payable(attacker));

        assertEq(address(proxy).balance, 10 ether, "funds remain safe");
    }
}
