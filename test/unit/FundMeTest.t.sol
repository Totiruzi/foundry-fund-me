// SPDX-License-identidier: MIT

pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant AMOUNT_SENT = 0.1 ether;
    uint256 constant STARTING_BALANCE = 20 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testIfOwnerIsMessageSender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testVersionNumberIsCorrect() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: AMOUNT_SENT}();
        _;
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesDataStructure() public funded {
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, AMOUNT_SENT);
    }

    function testAddFunderToArrayOfFunders() public funded {
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Action
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;

        console.log(gasUsed);

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);
    }

    function testWithdrawFromMultipleFunders() public funded {
        uint160 numbersOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 funderIndex = startingFunderIndex; funderIndex < numbersOfFunders; funderIndex++) {
            // Arrange
            /**
             * Vm prank
             * Vm deal
             * hoax(address, amount) does what prank and deal does
             */
            hoax(address(funderIndex), AMOUNT_SENT);

            // Fund the fundMe
            fundMe.fund{value: AMOUNT_SENT}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Action
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundeMeBalance = address(fundMe).balance;
        assertEq(endingFundeMeBalance, 0);
        assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);
    }

    function testWithdrawFromMultipleFundersCheaper() public funded {
        uint160 numbersOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 funderIndex = startingFunderIndex; funderIndex < numbersOfFunders; funderIndex++) {
            // Arrange
            /**
             * Vm prank
             * Vm deal
             * hoax(address, amount) does what prank and deal does
             */
            hoax(address(funderIndex), AMOUNT_SENT);

            // Fund the fundMe
            fundMe.fund{value: AMOUNT_SENT}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Action
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundeMeBalance = address(fundMe).balance;
        assertEq(endingFundeMeBalance, 0);
        assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);
    }
}
