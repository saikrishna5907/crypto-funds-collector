// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {FundCollector} from "../src/FundCollector.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

// Sepolia ETH / USD Address
// https://docs.chain.link/data-feeds/price-feeds/addresses

contract DeployFundCollector is Script {
    function run() public returns (FundCollector) {
        HelperConfig helperConfig = new HelperConfig();

        address priceFeedAddress = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        FundCollector fundCollector = new FundCollector(priceFeedAddress);
        vm.stopBroadcast();

        return fundCollector;
    }
}
