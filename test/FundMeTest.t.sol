// SPDX-License-Indentifier : MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    uint256 constant private START_BALANCE = 100 ether;
    uint256 constant private SEND_VALUE = 0.1 ether; //100000000000000000 wei

    //makeAddr, deal & prank are fondry cheatcodes
    address USER = makeAddr("user");

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, START_BALANCE);
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        // assertEq(fundMe.i_owner(), msg.sender); //failed because us-->FundMeTest-->FundMe
        assertEq(fundMe.i_owner(), msg.sender); //failed because us-->FundMeTest-->FundMe
    }

    function testPriceFeedVersionIsAccurate() public view{
        uint256 version = fundMe.getVersion();
        console.log(version);
        assertEq(version, 6);
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert(); // the next line, should revert!
        // assert(This tx fails/reverts)
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public {

        vm.prank(USER); // The next Tx will be sent by USER

        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    
}
