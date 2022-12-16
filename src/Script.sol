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

// 📦 BOILERPLATE
abstract contract ScriptBase is CommonBase {
    // Used when deploying with create2, https://github.com/Arachnid/deterministic-deployment-proxy.
    address internal constant CREATE2_FACTORY = 0x4e59b44847b379578588920cA78FbF26c0B4956C;

    VmSafe internal constant vmSafe = VmSafe(VM_ADDRESS);
}

// ⚡️ SCRIPT DX
abstract contract Script is StdChains, StdCheatsSafe, StdUtils, ScriptBase {
    // Note: IS_SCRIPT() must return true.
    bool public IS_SCRIPT = true;
}
