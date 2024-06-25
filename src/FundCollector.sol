// SPDX-Licence-Identifier: MIT
pragma solidity 0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundCollector__NotOwner();

contract FundCollector {
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5e18;
    mapping(address => uint256) private s_addressToAmountFunded;
    address[] private s_funders;
    address private /*immutable value*/ i_owner;
    AggregatorV3Interface private s_priceFeedAddress;

    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeedAddress = AggregatorV3Interface(priceFeedAddress);
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
        s_addressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
    }

    function cheaperWithDraw() public onlyOwner {
        uint256 fundersLength = s_funders.length;
        for (uint256 funderIndex = 0; funderIndex < fundersLength; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        s_funders = new address[](0);

        (bool callSuccess,) = payable(i_owner).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    function withdraw() public {
        require(msg.sender == i_owner, "Only the owner can withdraw the funds");
        // payable(owner).transfer(address(this).balance);

        for (uint256 funderIndex = 0; funderIndex < s_funders.length; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        s_funders = new address[](0);
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

    // view or pure functions
    function getFunderAmount(address funder) external view returns (uint256) {
        return s_addressToAmountFunded[funder];
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getFunders() external view returns (address[] memory) {
        return s_funders;
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
