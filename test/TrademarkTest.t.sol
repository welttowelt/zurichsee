// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/contracts/Trademark.sol";
import "forge-std/Test.sol";

contract TrademarkTest is Test {
    Trademark trademark;
    address owner;

    function setUp() public {
        owner = address(this);
        trademark = new Trademark(0.00001 ether);
    }

    function testApplyForTrademark() public {
        vm.deal(address(this), 0.00002 ether);
        trademark.applyForTrademark{value: 0.00001 ether}("MyTrademark");
        Trademark.TrademarkApplication[] memory applications = trademark.getApplications();
        assertEq(applications.length, 1);
        assertEq(applications[0].trademark, "MyTrademark");
    }

    function testApplyForTrademarkInsufficientFee() public {
        vm.deal(address(this), 0.000005 ether);
        vm.expectRevert("Insufficient fee");
        trademark.applyForTrademark{value: 0.000005 ether}("MyTrademark");
    }

    function testIsOwner() public {
        vm.deal(address(this), 0.00002 ether);
        trademark.applyForTrademark{value: 0.00001 ether}("MyTrademark");
        bool isOwner = trademark.isOwner(address(this), "MyTrademark");
        assertTrue(isOwner);
    }

    function testIsNotOwner() public {
        vm.deal(address(this), 0.00002 ether);
        trademark.applyForTrademark{value: 0.00001 ether}("MyTrademark");
        bool isOwner = trademark.isOwner(address(0x123), "MyTrademark");
        assertFalse(isOwner);
    }

    function testTransferOwnership() public {
        vm.deal(address(this), 0.00002 ether);
        trademark.applyForTrademark{value: 0.00001 ether}("MyTrademark");
        trademark.transferOwnership(address(0x123), "MyTrademark");
        bool isOwner = trademark.isOwner(address(0x123), "MyTrademark");
        assertTrue(isOwner);
    }

    function testTransferOwnershipNotOwner() public {
        vm.deal(address(this), 0.00002 ether);
        trademark.applyForTrademark{value: 0.00001 ether}("MyTrademark");
        vm.expectRevert("Only the owner can transfer ownership");
        vm.prank(address(0x456));
        trademark.transferOwnership(address(0x123), "MyTrademark");
    }

    function testWithdraw() public {
        // Ensure contract has enough balance
        vm.deal(address(trademark), 0.00002 ether); // Add Ether to the contract
        vm.deal(address(this), 0.00002 ether); // Add Ether to the test address to ensure applyForTrademark works
        trademark.applyForTrademark{value: 0.00001 ether}("MyTrademark");

        uint256 initialBalance = owner.balance;
        uint256 contractBalanceBefore = address(trademark).balance;

        emit log_named_uint("Contract balance before withdraw", contractBalanceBefore);
        emit log_named_uint("Owner balance before withdraw", initialBalance);  // Debug log

        // Ensure that the owner is making the withdraw call
        vm.prank(owner);
        (bool success, bytes memory data) = address(trademark).call(abi.encodeWithSignature("withdraw(uint256)", 0.00001 ether));
        require(success, "Withdraw failed");

        uint256 contractBalanceAfter = address(trademark).balance;
        emit log_named_uint("Contract balance after withdraw", contractBalanceAfter);

        uint256 finalBalance = owner.balance;
        emit log_named_uint("Owner final balance", finalBalance);

        assertEq(finalBalance, initialBalance + 0.00001 ether);
    }
}

