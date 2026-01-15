// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.20 <0.9.0;

// 💬 ABOUT
// Forge Std V2 Test - AI/Agent-first design with explicit type-named assertions.
//
// BREAKING CHANGES FROM V1:
// - Assertions use explicit type names: assertEqUint, assertEqAddress, etc.
// - No console.sol or safeconsole.sol (use console2 only)
// - No deprecated functions (changePrank, assumeNoBlacklisted)
// - Requires Solidity >=0.8.20
//
// For unified namespace access, use: import {forge} from "forge-std/Forge.sol";

// 🧩 MODULES
import {console2} from "./console2.sol";
import {StdAssertionsV2} from "./StdAssertionsV2.sol";
import {StdChains} from "./StdChains.sol";
import {StdCheats} from "./StdCheats.sol";
import {StdConstants} from "./StdConstants.sol";
import {stdError} from "./StdError.sol";
import {StdInvariant} from "./StdInvariant.sol";
import {stdJson} from "./StdJson.sol";
import {stdMath} from "./StdMath.sol";
import {StdStorage, stdStorage} from "./StdStorage.sol";
import {StdStyle} from "./StdStyle.sol";
import {stdToml} from "./StdToml.sol";
import {StdUtils} from "./StdUtils.sol";
import {Vm} from "./Vm.sol";

// 📦 BOILERPLATE
import {TestBase} from "./Base.sol";

// ⭐️ TEST V2
/// @title TestV2 - AI/Agent-first test base contract
/// @notice Uses explicit type-named assertions for better AI disambiguation
/// @dev Inherit from this instead of Test for new projects
abstract contract TestV2 is TestBase, StdAssertionsV2, StdChains, StdCheats, StdInvariant, StdUtils {
    // Note: IS_TEST() must return true.
    bool public IS_TEST = true;
}
