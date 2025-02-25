// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PriceConvertor} from "./PriceConvertor.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

error NotOwner();

contract FundMe {
    using PriceConvertor for uint256;

    //constant, immutable

    uint256 public constant MINIMUM_USD = 5e18;

    address[] private s_funders;
    mapping(address funder => uint256 amountFunded)
        private s_addressToAmountFunded;

    address public immutable i_owner;
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable {
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "didn't sent enough ETH"
        ); //1e18 = 1ETH = 1 * 10^18 wie
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] =
            s_addressToAmountFunded[msg.sender] +
            msg.value;
    }

    function getVersion() public view returns(uint256){
        return s_priceFeed.version();
    }

    function withdraw() public onlyOwner {
        // for loop
        // [1,2,3,4] elements
        // 0,1,2,3 indexes
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0); // reset the array

        //withdraw the funds - 3 ways:
        // transfer
        // send
        // call

        //tranfer-->

        //msg.sender = address
        //payble(msg.sender) = payble address
        // payable(msg.sender).transfer(address(this).balance);

        // send-->

        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send Failed");

        //call-->

        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }

    modifier onlyOwner() {
        // require(msg.sender == i_owner, "Sender is not i_owner!");
        if (msg.sender != i_owner) {
            revert NotOwner();
        }
        _; // code after the aboce line
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    /**
     * View / Pure functions (Getters)
     */

    function getAddressToAmountFunded(address fundingAddress) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }
}
