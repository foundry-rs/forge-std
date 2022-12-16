// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

// 💬 ABOUT
/**
 *  Standard Library's default Test DX.
 *
 *  You can customize it to suit the needs of your project by creating a similar file:
 *
 *      - import the standard modules you need
 *      - customize the standard modules by overriding and extending functionality
 *      - make your own modules
 *      - install community modules
 */

// 🧩 MODULES
import {TestBase} from "./Base.sol";
import {DSTest} from "ds-test/test.sol";
import {console} from "./console.sol";
import {console2} from "./console2.sol";
import {StdAssertions} from "./StdAssertions.sol";
import {StdChains} from "./StdChains.sol";
import {StdCheats} from "./StdCheats.sol";
import {stdError} from "./StdError.sol";
import {stdJson} from "./StdJson.sol";
import {stdMath} from "./StdMath.sol";
import {StdStorage, stdStorage} from "./StdStorage.sol";
import {StdUtils} from "./StdUtils.sol";
import {Vm} from "./Vm.sol";

// ✨ TEST DX
abstract contract Test is DSTest, StdAssertions, StdChains, StdCheats, StdUtils, TestBase {
// Note: IS_TEST() must return true.
// Note: Must have failure system, https://github.com/dapphub/ds-test/blob/cd98eff28324bfac652e63a239a60632a761790b/src/test.sol#L39-L76.
}
