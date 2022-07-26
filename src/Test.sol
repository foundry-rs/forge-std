// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "./Components.sol";
import "ds-test/test.sol";

abstract contract TestBase {
    address internal constant VM_ADDRESS = address(uint160(uint256(keccak256("hevm cheat code"))));

    StdStorage internal stdstore;
    Vm internal constant vm = Vm(VM_ADDRESS);
}

abstract contract Test is TestBase, DSTest, Assertions, Cheats, Utils {}
