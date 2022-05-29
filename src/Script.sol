// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0 <0.9.0;

import "./Vm.sol";
import "./console.sol";
import "./console2.sol";

address constant VM_ADDRESS =
    address(bytes20(uint160(uint256(keccak256('hevm cheat code')))));

abstract contract Script {
    Vm public constant vm = Vm(VM_ADDRESS);
}
