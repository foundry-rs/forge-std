// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "ds-test/test.sol";
import "./Assertions.sol";
import "./Cheats.sol";
import "./console.sol";
import "./console2.sol";
import "./Errors.sol";
import "./Math.sol";
import "./Storage.sol";
import "./Utils.sol";
import "./Vm.sol";

abstract contract TestBase {
    address internal constant VM_ADDRESS = address(uint160(uint256(keccak256("hevm cheat code"))));

    StdStorage internal stdstore;
    Vm internal constant vm = Vm(VM_ADDRESS);
}

abstract contract Test is TestBase, DSTest, Assertions, Cheats, Utils {}
