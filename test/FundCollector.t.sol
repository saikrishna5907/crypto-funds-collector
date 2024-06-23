// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundCollector} from "../src/FundCollector.sol";
import {DeployFundCollector} from "../script/DeployFundCollector.s.sol";

contract FundCollectorTest is Test {
    FundCollector fundCollector;

    function setUp() external {
        DeployFundCollector deployFundCollector = new DeployFundCollector();
        fundCollector = deployFundCollector.run();
    }

    function testOwnerIsDeployer() public view {
        assertEq(fundCollector.i_owner(), msg.sender);
    }

    // function testDonate() public {
    //     fundCollector.donate{value: 6e18}();
    //     console.log(fundCollector.addressToAmountFunded(address(this)));
    //     assertEq(fundCollector.addressToAmountFunded(address(this)), 6e18);
    // }

    function testPriceFeedVersion() public view {
        assertEq(fundCollector.getVersion(), 4);
    }
}
