// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundCollector} from "../../src/FundCollector.sol";
import {DeployFundCollector} from "../../script/DeployFundCollector.s.sol";

contract FundCollectorTest is Test {
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

    modifier funded() {
        vm.prank(USER);
        fundCollector.donate{value: POINT_FIVE_ETH}();
        _;
    }

    function testOwnerIsDeployer() public view {
        assertEq(fundCollector.getOwner(), msg.sender);
    }

    function testMinimumDollarIsFive() public {
        vm.prank(USER);
        assertEq(fundCollector.MINIMUM_USD(), 5e18);
    }

    function testDonate() public funded {
        assertEq(fundCollector.getFunderAmount(USER), POINT_FIVE_ETH);

        assertEq(fundCollector.getFunder(0), USER);
    }

    function testDonateThrowErrorIfWeDoNotSendFundToDonate() public {
        vm.expectRevert("You need to send some ether");
        fundCollector.donate();
    }

    // function testDonateThrowErrorIfWeDoNotSendEnoughFundToDonate() public {
    //     vm.prank(USER);
    //     vm.expectRevert("You need to send some ether");
    //     fundCollector.donate{value: 2e18}();
    // }

    function testGetBalance() public {
        assertEq(fundCollector.getBalance(), 0);
        fundCollector.donate{value: POINT_FIVE_ETH}();
        assertEq(fundCollector.getBalance(), POINT_FIVE_ETH);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert("Only the owner can withdraw the funds");
        fundCollector.withdraw();
    }

    function testWithDrawWithASingleFunder() public funded {
        uint256 ownerBalanceBeforeWithdraw = fundCollector.getOwner().balance;
        uint256 fundCollectorBalance = address(fundCollector).balance;

        // pranking the current user to be a owner
        vm.prank(fundCollector.getOwner());

        fundCollector.withdraw();
        uint256 ownerBalanceAfterWithdraw = fundCollector.getOwner().balance;
        uint256 fundCollectorBalanceAfterWithDraw = address(fundCollector)
            .balance;

        assertEq(fundCollectorBalanceAfterWithDraw, 0);
        assertEq(
            ownerBalanceBeforeWithdraw + fundCollectorBalance,
            ownerBalanceAfterWithdraw
        );
        assertEq(fundCollector.getFunders().length, 0);
    }

    function testWithDrawFromMultipleFunders() public funded {
        // arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        // for the following address set 0.5 eth balance,
        // then donate 0.5 eth to the fundCollector
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // hoax does vm.deal and vm.prank
            hoax(address(i), POINT_FIVE_ETH);
            fundCollector.donate{value: POINT_FIVE_ETH}();
        }

        uint256 ownerBalanceBeforeWithdraw = fundCollector.getOwner().balance;
        uint256 fundCollectorBalanceBeforeWithDraw = address(fundCollector)
            .balance;

        // pranking the current user to be a owner
        vm.startPrank(fundCollector.getOwner());
        fundCollector.withdraw();
        vm.stopPrank();

        uint256 ownerBalanceAfterWithdraw = fundCollector.getOwner().balance;
        uint256 fundCollectorBalanceAfterWithDraw = address(fundCollector)
            .balance;

        assertEq(fundCollectorBalanceAfterWithDraw, 0);
        assertEq(
            ownerBalanceBeforeWithdraw + fundCollectorBalanceBeforeWithDraw,
            ownerBalanceAfterWithdraw
        );
        assertEq(fundCollector.getFunders().length, 0);
    }

    function testCheaperWithDrawFromMultipleFunders() public funded {
        // arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        // for the following address set 0.5 eth balance,
        // then donate 0.5 eth to the fundCollector
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // hoax does vm.deal and vm.prank
            hoax(address(i), POINT_FIVE_ETH);
            fundCollector.donate{value: POINT_FIVE_ETH}();
        }

        uint256 ownerBalanceBeforeWithdraw = fundCollector.getOwner().balance;
        uint256 fundCollectorBalanceBeforeWithDraw = address(fundCollector)
            .balance;

        // pranking the current user to be a owner
        vm.startPrank(fundCollector.getOwner());
        fundCollector.cheaperWithDraw();
        vm.stopPrank();

        uint256 ownerBalanceAfterWithdraw = fundCollector.getOwner().balance;
        uint256 fundCollectorBalanceAfterWithDraw = address(fundCollector)
            .balance;

        assertEq(fundCollectorBalanceAfterWithDraw, 0);
        assertEq(
            ownerBalanceBeforeWithdraw + fundCollectorBalanceBeforeWithDraw,
            ownerBalanceAfterWithdraw
        );
        assertEq(fundCollector.getFunders().length, 0);
    }

    function testPriceFeedVersion() public view {
        assertEq(fundCollector.getVersion(), 4);
    }
}
