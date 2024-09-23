// SPDX_License_Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import { FundMe } from "../src/FundMe.sol";

// Fund
// Withdraw

contract FundFundMe is Script {
    uint256 constant AMOUNT_SENT = 0.01 ether;
    // FundMe fundMe =  new FundMe();

    function fundFundMe (address mostRecentlyDeployedContract) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployedContract)).fund{value: AMOUNT_SENT}();
        vm.stopBroadcast();
        console.log("Funded FundMe with %s", AMOUNT_SENT);
    }

    function run() external {
        address mostRecentlyDeployedContract = DevOpsTools.get_most_recent_deployment(
            "FundMe", 
            block.chainid
        );
        fundFundMe(mostRecentlyDeployedContract);
    }
}

contract WithdrawFundMe is Script {

    function withdrawFundMe (address mostRecentlyDeployedContract) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployedContract)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentlyDeployedContract = DevOpsTools.get_most_recent_deployment(
            "FundMe", 
            block.chainid
        );
        withdrawFundMe(mostRecentlyDeployedContract);
    }
}
