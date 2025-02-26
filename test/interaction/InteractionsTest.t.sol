// SPDX-License-Indentifier : MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    FundMe fundMe;

    uint256 private constant START_BALANCE = 100 ether;
    uint256 private constant SEND_VALUE = 0.1 ether; //100000000000000000 wei
    uint256 private constant GAS_PRICE = 1;

    //makeAddr, deal & prank are fondry cheatcodes
    address USER = makeAddr("user");

    // modifier funded() {
    //     vm.prank(USER); // The next Tx will be sent by USER
    //     fundMe.fund{value: SEND_VALUE}();
    //     _;
    // }

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER,START_BALANCE);
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();

        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));
        
        assert(address(fundMe).balance == 0);

        // vm.startBroadcast();
        // fundFundMe.fundFundMe(address(fundMe));
        // vm.stopBroadcast();
        
        // address funder = fundMe.getFunder(0);

        // assert(funder == USER);
    }
}