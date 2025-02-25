//SPDX-License-Indentier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";

contract DeployFundMe is Script {
    function run() external returns(FundMe){
        vm.startBroadcast(); //vm cheatcodes only valid in foundry and will not work on other solidity frameworks
        FundMe fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        vm.stopBroadcast();

        return fundMe;
    }
}
