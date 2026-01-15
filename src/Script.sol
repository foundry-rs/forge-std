// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.20 <0.9.0;

// 💬 ABOUT
// Forge Std's default Script.

// 🧩 MODULES
import {console} from "./console.sol";
import {StdCheatsSafe} from "./test/StdCheats.sol";
import {StdConstants} from "./StdConstants.sol";
import {stdJson} from "./script/StdJson.sol";
import {stdMath} from "./utils/StdMath.sol";
import {StdStorage, stdStorageSafe} from "./test/StdStorage.sol";
import {StdUtils} from "./test/StdUtils.sol";
import {Vm, VmSafe} from "./Vm.sol";

// ⭐️ SCRIPT
abstract contract Script is StdCheatsSafe, StdUtils {
    bool public IS_SCRIPT = true;

    Vm internal constant vm = StdConstants.VM;
    VmSafe internal constant vmSafe = VmSafe(StdConstants.VM_ADDRESS);
    StdStorage internal stdstore;
}
