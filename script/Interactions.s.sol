// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundCollector} from "../src/FundCollector.sol";

contract DonateFundCollector is Script {
    uint256 public constant SEND_VALUE = 0.01 ether;

    function donateFundCollector(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundCollector(payable(mostRecentlyDeployed)).donate{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Donated to FundCollector with %s", SEND_VALUE);
    }

    function run() external {
        address mostRecentDeployed = DevOpsTools.get_most_recent_deployment("FundCollector", block.chainid);
        vm.startBroadcast();
        donateFundCollector(mostRecentDeployed);
        vm.stopBroadcast();
    }
}

contract WithDrawFundCollector is Script {
    uint256 public constant SEND_VALUE = 0.01 ether;

    function withDrawFundCollector(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundCollector(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentDeployed = DevOpsTools.get_most_recent_deployment("FundCollector", block.chainid);
        vm.startBroadcast();
        withDrawFundCollector(mostRecentDeployed);
        vm.stopBroadcast();
    }
}
