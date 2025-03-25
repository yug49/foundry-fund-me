// SPDX-License-Indentifier : MIT

pragma solidity ^0.8.18;

import {Test, console} from "../../lib/forge-std/src/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {ZkSyncChainChecker} from "../../lib/foundry-devops/src/ZkSyncChainChecker.sol";
import {FoundryZkSyncChecker} from "../../lib/foundry-devops/src/FoundryZkSyncChecker.sol";
import {HelperConfig, CodeConstants} from "../../script/HelperConfig.s.sol";
import {MockV3Aggregator} from "../mocks/MockV3Aggregator.sol";
import {StdCheats} from "../../lib/forge-std/src/StdCheats.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is ZkSyncChainChecker, CodeConstants, StdCheats, Test {
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
        if (!isZkSyncChain()) {
            DeployFundMe deployFundMe = new DeployFundMe();
            fundMe = deployFundMe.run();
        } else {
            MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
            fundMe = new FundMe(address(mockPriceFeed));
        }

        vm.deal(USER, START_BALANCE);
    }

    function testUserCanFundAndOwnerWithdraw() public skipZkSync {
        uint256 preUserBalance = address(USER).balance;
        uint256 preOwnerBalance = fundMe.getOwner().balance;

        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.run();

        uint256 afterUserBalance = address(USER).balance;
        uint256 afterOwnerBalance = fundMe.getOwner().balance;

        assert(address(fundMe).balance == 0);
        assertEq(afterUserBalance + SEND_VALUE, preUserBalance);
        assertEq(preOwnerBalance + SEND_VALUE, afterOwnerBalance);

        // FundFundMe fundFundMe = new FundFundMe();

        // fundFundMe.fundFundMe(address(fundMe));

        // WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        // withdrawFundMe.withdrawFundMe(address(fundMe));

        // assert(address(fundMe).balance == 0);

        // vm.startBroadcast();
        // fundFundMe.fundFundMe(address(fundMe));
        // vm.stopBroadcast();

        // address funder = fundMe.getFunder(0);

        // assert(funder == USER);
    }
}
