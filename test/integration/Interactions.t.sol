// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundCollector} from "../../src/FundCollector.sol";
import {DeployFundCollector} from "../../script/DeployFundCollector.s.sol";
import {DonateFundCollector, WithDrawFundCollector} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    FundCollector fundCollector;
    address USER = makeAddr("user");
    uint256 constant STARTING_BALANCE_ETH = 10 ether;
    uint256 constant POINT_FIVE_ETH = 0.5 ether;
    uint256 constant ONE_ETH = 1 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundCollector deployFundCollector = new DeployFundCollector();
        fundCollector = deployFundCollector.run();
        vm.deal(USER, STARTING_BALANCE_ETH);
    }

    function testUserCanDonateInteractions() public {
        address fundAddress = address(fundCollector);

        DonateFundCollector donateFundCollector = new DonateFundCollector();
        donateFundCollector.donateFundCollector(fundAddress);

        WithDrawFundCollector withDrawFundCollector = new WithDrawFundCollector();
        withDrawFundCollector.withDrawFundCollector(fundAddress);
        // assertEq(fundCollector.getFunderAmount(fundAddress), POINT_FIVE_ETH);

        assert(fundAddress.balance == 0);
    }
}
