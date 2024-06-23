// SPDX-Licence-Identifier: MIT
pragma solidity 0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
error FundCollector__NotOwner();

contract FundCollector {
    using PriceConverter for uint256;

    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;

    address public /*immutable value*/ i_owner;

    AggregatorV3Interface private s_priceFeedAddress;
    HelperConfig helperConfig;
    uint256 MINIMUM_USD;

    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeedAddress = AggregatorV3Interface(priceFeedAddress);
        helperConfig = new HelperConfig();
        MINIMUM_USD = helperConfig.getMinimumUsdToDonate();
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) revert FundCollector__NotOwner();
        _;
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeedAddress.version();
    }

    function donate() public payable {
        require(msg.value.getConversionRate(s_priceFeedAddress) >= MINIMUM_USD, "You need to send some ether");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function withdraw() public {
        require(msg.sender == i_owner, "Only the owner can withdraw the funds");
        // payable(owner).transfer(address(this).balance);

        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        // // transfer
        // payable(i_owner).transfer(address(this).balance);

        // // send
        // bool sendSuccess = payable(i_owner).send(address(this).balance);
        // require(sendSuccess, "Send failed");

        // call
        (bool callSuccess,) = payable(i_owner).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    // Explainer from: https://solidity-by-example.org/fallback/
    // Ether is sent to contract
    //      is msg.data empty?
    //          /   \
    //         yes  no
    //         /     \
    //    receive()?  fallback()
    //     /   \
    //   yes   no
    //  /        \
    //receive()  fallback()

    fallback() external payable {
        donate();
    }

    receive() external payable {
        donate();
    }
}
