// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

// Inheritted by test contracts where afterTest() is needed
abstract contract StdAfterTest {
    // This modifier needs to applied to the test after which we want to run the afterTest() function
    modifier runAftetTest() {
        _;
        afterTest();
    }

    // This is needs to be overriden by the Test contract that inherits this
    function afterTest() public virtual;
}
