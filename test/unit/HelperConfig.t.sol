// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;
import {Test} from "forge-std/Test.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract HelperConfigTest is Test {
    HelperConfig helperConfig;

    function setUp() external {
        helperConfig = new HelperConfig();
    }
}
