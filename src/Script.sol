// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

// 💬 ABOUT
/**
 *  Standard Library's default Script DX.
 *
 *  You can customize it to suit the needs of your project by creating a similar file:
 *
 *      - import the standard modules you need
 *      - customize the standard modules by overriding and extending functionality
 *      - make your own modules
 *      - install community modules
 */

// 🧩 MODULES
import {ScriptBase} from "./Base.sol";
import {console} from "./console.sol";
import {console2} from "./console2.sol";
import {StdChains} from "./StdChains.sol";
import {StdCheatsSafe} from "./StdCheats.sol";
import {stdJson} from "./StdJson.sol";
import {stdMath} from "./StdMath.sol";
import {StdStorage, stdStorageSafe} from "./StdStorage.sol";
import {StdUtils} from "./StdUtils.sol";
import {VmSafe} from "./Vm.sol";

// ✨ SCRIPT DX
abstract contract Script is StdChains, StdCheatsSafe, StdUtils, ScriptBase {
    // Note: IS_SCRIPT() must return true.
    bool public IS_SCRIPT = true;
}
