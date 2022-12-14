// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import {CommonBase} from "./Common.sol";
import {console} from "./console.sol";
import {console2} from "./console2.sol";
import {StdChains} from "./StdChains.sol";
import {StdCheatsSafe} from "./StdCheats.sol";
import {stdJson} from "./StdJson.sol";
import {stdMath} from "./StdMath.sol";
import {StdStorage, stdStorageSafe} from "./StdStorage.sol";
import {StdUtils} from "./StdUtils.sol";
import {VmSafe} from "./Vm.sol";

abstract contract ScriptBase is CommonBase {
    // Create2 factory used by scripts when deploying with create2, https://github.com/Arachnid/deterministic-deployment-proxy.
    address internal constant CREATE2_FACTORY = 0x4e59b44847b379578588920cA78FbF26c0B4956C;

    VmSafe internal constant vmSafe = VmSafe(VM_ADDRESS);
}

abstract contract Script is StdChains, StdCheatsSafe, StdUtils, ScriptBase {
    bool public IS_SCRIPT = true;
}
