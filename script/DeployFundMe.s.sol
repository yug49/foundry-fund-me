//SPDX-License-Indentier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "../lib/forge-std/src/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        //Before startBroadcast -> Not a 'real' tx
        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();

        //After startBradcast -> 'real' tx
        vm.startBroadcast(); //vm cheatcodes only valid in foundry and will not work on other solidity frameworks
        FundMe fundMe = new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();

        return fundMe;
    }
}
