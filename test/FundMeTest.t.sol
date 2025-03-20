// SPDX-License-Indentifier : MIT

pragma solidity ^0.8.18;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";
import {ZkSyncChainChecker} from "../lib/foundry-devops/src/ZkSyncChainChecker.sol";
import {FoundryZkSyncChecker} from "../lib/foundry-devops/src/FoundryZkSyncChecker.sol";
import {HelperConfig, CodeConstants} from "../script/HelperConfig.s.sol";
import {MockV3Aggregator} from "./mocks/MockV3Aggregator.sol";
import {StdCheats} from "../lib/forge-std/src/StdCheats.sol";

contract FundMeTest is ZkSyncChainChecker, CodeConstants, StdCheats, Test {
    FundMe fundMe;

    uint256 private constant START_BALANCE = 100 ether;
    uint256 private constant SEND_VALUE = 0.1 ether; //100000000000000000 wei
    uint256 private constant GAS_PRICE = 1;

    //makeAddr, deal & prank are fondry cheatcodes
    address USER = makeAddr("user");

    modifier funded() {
        vm.prank(USER); // The next Tx will be sent by USER
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

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

    function testMinimumDollarIsFive() public skipZkSync {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public skipZkSync {
        // assertEq(fundMe.i_owner(), msg.sender); //failed because us-->FundMeTest-->FundMe
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public skipZkSync {
        uint256 version = fundMe.getVersion();
        console.log(version);
        assertEq(version, 6);
    }

    function testFundFailsWithoutEnoughEth() public skipZkSync {
        vm.expectRevert(); // the next line, should revert!
        // assert(This tx fails/reverts)
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public funded skipZkSync {
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public funded skipZkSync {
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testPrintStorageData() public view{
        for (uint256 i = 0; i < 3; i++) {
            bytes32 value = vm.load(address(fundMe), bytes32(i));
            console.log("Value at location", i, ":");
            console.logBytes32(value);
        }
        console.log("PriceFeed address:", address(fundMe.getPriceFeed()));
    }

    function testOnlyOwnerCanWithdraw() public funded skipZkSync {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithDrawWithASingleFunder() public funded skipZkSync {
        //Arrange

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(endingOwnerBalance, startingOwnerBalance + startingFundMeBalance);
    }

    function testWithdrawFromMultipleFunders() public funded skipZkSync {
        //Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 0;
        //generating address with number, then it should be of type int160

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            //vm.prank new address
            //vm.deal new address
            hoax(address(i), SEND_VALUE);
            //fund the fundMe
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        // uint256 gasStart = gasleft();   //gasleft() tells you how much gas is left in the current transaction
        // vm.txGasPrice(GAS_PRICE);   //test will have gas price

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // uint256 gasEnd = gasleft();
        // uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice; //tx.gasprice is the gas price of the current transaction

        //assert
        assert(address(fundMe).balance == 0);
        assert(fundMe.getOwner().balance == startingOwnerBalance + startingFundMeBalance);
        assert((numberOfFunders + 1) * SEND_VALUE == fundMe.getOwner().balance - startingOwnerBalance);
    }
}
