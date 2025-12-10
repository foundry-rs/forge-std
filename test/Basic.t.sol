// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../src/Test.sol";
import "../src/Script.sol";

contract BasicTest is Test {
    function test_ok() public {
        assertTrue(true);
    }
}

contract BasicScript is Script {
    function run() public {}
}
