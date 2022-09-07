// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import {StdCheatsSafe, console, console2, stdMath, stdStorageSafe, StdStorage, StdUtils, VmSafe} from "./Components.sol";

abstract contract ScriptBase {
    address internal constant VM_ADDRESS = address(uint160(uint256(keccak256("hevm cheat code"))));

    StdStorage internal stdstore;
    VmSafe internal constant vm = VmSafe(VM_ADDRESS);
}

abstract contract Script is ScriptBase, StdCheatsSafe, StdUtils {
    bool public IS_SCRIPT = true;
}
