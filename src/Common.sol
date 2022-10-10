// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import {StdStorage, Vm} from "./Components.sol";

abstract contract CommonBase {
    address internal constant VM_ADDRESS = address(uint160(uint256(keccak256("hevm cheat code"))));

    StdStorage internal stdstore;
    Vm internal constant vm = Vm(VM_ADDRESS);
}
