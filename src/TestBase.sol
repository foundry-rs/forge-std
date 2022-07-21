// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "./Storage.sol";
import "./Vm.sol";

abstract contract TestBase {
    address internal constant VM_ADDRESS = address(uint160(uint256(keccak256("hevm cheat code"))));

    StdStorage internal stdstore;
    Vm internal constant vm = Vm(VM_ADDRESS);
}