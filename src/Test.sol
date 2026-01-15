// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.20 <0.9.0;

// 💬 ABOUT
// Forge Std Test - AI/Agent-first design with explicit type-named assertions.
//
// FEATURES:
// - Assertions use explicit type names: assertEqUint, assertEqAddress, etc.
// - Uses console2 for logging
// - Requires Solidity >=0.8.20
//
// For unified namespace access, use: import {forge} from "forge-std/Forge.sol";

// 🧩 MODULES
import {console} from "./console.sol";
import {StdAssertions} from "./StdAssertions.sol";
import {StdCheats} from "./test/StdCheats.sol";
import {StdConstants} from "./StdConstants.sol";
import {StdErrors} from "./utils/StdErrors.sol";
import {StdInvariant} from "./test/StdInvariant.sol";
import {stdJson} from "./script/StdJson.sol";
import {stdMath} from "./utils/StdMath.sol";
import {StdStorage, stdStorage} from "./test/StdStorage.sol";
import {stdToml} from "./script/StdToml.sol";
import {StdUtils} from "./test/StdUtils.sol";
import {Vm} from "./Vm.sol";

// ⭐️ TEST
/// @title Test - AI/Agent-first test base contract
/// @notice Uses explicit type-named assertions for better AI disambiguation
abstract contract Test is StdAssertions, StdCheats, StdInvariant, StdUtils {
    bool public IS_TEST = true;

    Vm internal constant vm = StdConstants.VM;
    StdStorage internal stdstore;
}
