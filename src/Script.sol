// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import {CommonBase} from "./Common.sol";
// forgefmt: disable-next-line
import {console, console2, StdChains, StdCheatsSafe, stdJson, stdMath, StdStorage, stdStorageSafe, StdUtils, VmSafe} from "./Components.sol";

abstract contract ScriptBase is CommonBase {
    VmSafe internal constant vmSafe = VmSafe(VM_ADDRESS);
}

abstract contract Script is StdChains, StdCheatsSafe, StdUtils, ScriptBase {
    bool public IS_SCRIPT = true;
}
