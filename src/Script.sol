// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "./Cheats.sol";
import "./console.sol";
import "./console2.sol";
import "./Utils.sol";

abstract contract ScriptBase {
    address internal constant VM_ADDRESS = address(uint160(uint256(keccak256("hevm cheat code"))));
    Vm internal constant vm = Vm(VM_ADDRESS);
}

abstract contract Script is ScriptBase, Cheats, Utils {
    bool public IS_SCRIPT = true;
}
