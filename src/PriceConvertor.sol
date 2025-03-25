// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {AggregatorV3Interface} from
    "../lib/chainlink-brownie-contracts/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConvertor {
    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        // Address sepolia ETC: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        // zksync sepolia ETC: 0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF
        (, int256 price,,,) = priceFeed.latestRoundData();
        // price of eth in terms of usd
        return uint256(price * 1e10);
    }

    function getConversionRate(uint256 ethAmount, AggregatorV3Interface priceFeed) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUsd;
    }
}
