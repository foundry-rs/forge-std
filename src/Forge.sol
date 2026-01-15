// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.20 <0.9.0;

// ═══════════════════════════════════════════════════════════════════════════
// FORGE-STD V2 - Unified Namespace
// ═══════════════════════════════════════════════════════════════════════════
//
// Usage:
//   import {forge} from "forge-std/Forge.sol";
//   forge.vm.prank(alice);
//   forge.logString("hello");
//
// For advanced features, import the individual modules:
//   import {scenario, ScenarioBuilder} from "forge-std/Scenario.sol";
//   import {expect, Expectation} from "forge-std/Expect.sol";
//   import {mock, MockSetup} from "forge-std/Mock.sol";
//   import {gas, GasReport} from "forge-std/Gas.sol";
//   import {trace, CallTrace} from "forge-std/Trace.sol";
//
// For invariant-first testing:
//   import {InvariantBase, HandlerBase} from "forge-std/InvariantBase.sol";
//
// ═══════════════════════════════════════════════════════════════════════════

import {Vm} from "./Vm.sol";
import {console2} from "./console2.sol";
import {stdStorage, StdStorage} from "./StdStorage.sol";
import {stdJson} from "./StdJson.sol";
import {stdToml} from "./StdToml.sol";
import {stdMath} from "./StdMath.sol";
import {stdError} from "./StdError.sol";
import {StdChains} from "./StdChains.sol";
import {StdStyle} from "./StdStyle.sol";

// V2 Advanced modules (re-exported for convenience)
import {scenario, ScenarioBuilder, ScenarioResult, ScenarioActor, Actor} from "./Scenario.sol";
import {expect, Expectation, ExpectationResult} from "./Expect.sol";
import {mock, spy, MockSetup, Spy} from "./Mock.sol";
import {gas, GasProfile, GasReport, GasBenchmark} from "./Gas.sol";
import {trace, CallTrace, CallNode} from "./Trace.sol";
import {InvariantBase, HandlerBase} from "./InvariantBase.sol";
import {Spec, ActionsBase, Actions, IActionSet, SpecActor} from "./Spec.sol";

/// @title Forge Standard Library V2 - Unified Namespace
/// @notice Single entry point for all forge-std functionality
/// @dev Import and use as: forge.vm, forge.console, forge.storage, etc.
library forge {
    // ═══════════════════════════════════════════════════════════════════════
    // VM CHEATCODES
    // ═══════════════════════════════════════════════════════════════════════

    Vm internal constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    // ═══════════════════════════════════════════════════════════════════════
    // CONSOLE LOGGING - Using explicit type names for AI disambiguation
    // ═══════════════════════════════════════════════════════════════════════

    function logString(string memory message) internal pure {
        console2.logString(message);
    }

    function logUint(uint256 value) internal pure {
        console2.logUint(value);
    }

    function logInt(int256 value) internal pure {
        console2.logInt(value);
    }

    function logAddress(address value) internal pure {
        console2.logAddress(value);
    }

    function logBool(bool value) internal pure {
        console2.logBool(value);
    }

    function logBytes32(bytes32 value) internal pure {
        console2.logBytes32(value);
    }

    function logBytes(bytes memory value) internal pure {
        console2.logBytes(value);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // ASSERTIONS - Explicit type names for AI disambiguation
    // ═══════════════════════════════════════════════════════════════════════

    function assertEqUint(uint256 left, uint256 right) internal pure {
        if (left != right) {
            vm.assertEq(left, right);
        }
    }

    function assertEqUint(uint256 left, uint256 right, string memory err) internal pure {
        if (left != right) {
            vm.assertEq(left, right, err);
        }
    }

    function assertEqInt(int256 left, int256 right) internal pure {
        if (left != right) {
            vm.assertEq(left, right);
        }
    }

    function assertEqInt(int256 left, int256 right, string memory err) internal pure {
        if (left != right) {
            vm.assertEq(left, right, err);
        }
    }

    function assertEqAddress(address left, address right) internal pure {
        if (left != right) {
            vm.assertEq(left, right);
        }
    }

    function assertEqAddress(address left, address right, string memory err) internal pure {
        if (left != right) {
            vm.assertEq(left, right, err);
        }
    }

    function assertEqBytes32(bytes32 left, bytes32 right) internal pure {
        if (left != right) {
            vm.assertEq(left, right);
        }
    }

    function assertEqBytes32(bytes32 left, bytes32 right, string memory err) internal pure {
        if (left != right) {
            vm.assertEq(left, right, err);
        }
    }

    function assertEqBool(bool left, bool right) internal pure {
        if (left != right) {
            vm.assertEq(left, right);
        }
    }

    function assertEqBool(bool left, bool right, string memory err) internal pure {
        if (left != right) {
            vm.assertEq(left, right, err);
        }
    }

    function assertEqString(string memory left, string memory right) internal pure {
        vm.assertEq(left, right);
    }

    function assertEqString(string memory left, string memory right, string memory err) internal pure {
        vm.assertEq(left, right, err);
    }

    function assertEqBytes(bytes memory left, bytes memory right) internal pure {
        vm.assertEq(left, right);
    }

    function assertEqBytes(bytes memory left, bytes memory right, string memory err) internal pure {
        vm.assertEq(left, right, err);
    }

    // Not-equal assertions
    function assertNotEqUint(uint256 left, uint256 right) internal pure {
        if (left == right) {
            vm.assertNotEq(left, right);
        }
    }

    function assertNotEqUint(uint256 left, uint256 right, string memory err) internal pure {
        if (left == right) {
            vm.assertNotEq(left, right, err);
        }
    }

    function assertNotEqInt(int256 left, int256 right) internal pure {
        if (left == right) {
            vm.assertNotEq(left, right);
        }
    }

    function assertNotEqInt(int256 left, int256 right, string memory err) internal pure {
        if (left == right) {
            vm.assertNotEq(left, right, err);
        }
    }

    function assertNotEqAddress(address left, address right) internal pure {
        if (left == right) {
            vm.assertNotEq(left, right);
        }
    }

    function assertNotEqAddress(address left, address right, string memory err) internal pure {
        if (left == right) {
            vm.assertNotEq(left, right, err);
        }
    }

    function assertNotEqBytes32(bytes32 left, bytes32 right) internal pure {
        if (left == right) {
            vm.assertNotEq(left, right);
        }
    }

    function assertNotEqBytes32(bytes32 left, bytes32 right, string memory err) internal pure {
        if (left == right) {
            vm.assertNotEq(left, right, err);
        }
    }

    // Comparison assertions
    function assertGtUint(uint256 left, uint256 right) internal pure {
        if (left <= right) {
            vm.assertGt(left, right);
        }
    }

    function assertGtUint(uint256 left, uint256 right, string memory err) internal pure {
        if (left <= right) {
            vm.assertGt(left, right, err);
        }
    }

    function assertGtInt(int256 left, int256 right) internal pure {
        if (left <= right) {
            vm.assertGt(left, right);
        }
    }

    function assertGtInt(int256 left, int256 right, string memory err) internal pure {
        if (left <= right) {
            vm.assertGt(left, right, err);
        }
    }

    function assertGeUint(uint256 left, uint256 right) internal pure {
        if (left < right) {
            vm.assertGe(left, right);
        }
    }

    function assertGeUint(uint256 left, uint256 right, string memory err) internal pure {
        if (left < right) {
            vm.assertGe(left, right, err);
        }
    }

    function assertGeInt(int256 left, int256 right) internal pure {
        if (left < right) {
            vm.assertGe(left, right);
        }
    }

    function assertGeInt(int256 left, int256 right, string memory err) internal pure {
        if (left < right) {
            vm.assertGe(left, right, err);
        }
    }

    function assertLtUint(uint256 left, uint256 right) internal pure {
        if (left >= right) {
            vm.assertLt(left, right);
        }
    }

    function assertLtUint(uint256 left, uint256 right, string memory err) internal pure {
        if (left >= right) {
            vm.assertLt(left, right, err);
        }
    }

    function assertLtInt(int256 left, int256 right) internal pure {
        if (left >= right) {
            vm.assertLt(left, right);
        }
    }

    function assertLtInt(int256 left, int256 right, string memory err) internal pure {
        if (left >= right) {
            vm.assertLt(left, right, err);
        }
    }

    function assertLeUint(uint256 left, uint256 right) internal pure {
        if (left > right) {
            vm.assertLe(left, right);
        }
    }

    function assertLeUint(uint256 left, uint256 right, string memory err) internal pure {
        if (left > right) {
            vm.assertLe(left, right, err);
        }
    }

    function assertLeInt(int256 left, int256 right) internal pure {
        if (left > right) {
            vm.assertLe(left, right);
        }
    }

    function assertLeInt(int256 left, int256 right, string memory err) internal pure {
        if (left > right) {
            vm.assertLe(left, right, err);
        }
    }

    // Boolean assertions
    function assertTrue(bool condition) internal pure {
        if (!condition) {
            vm.assertTrue(condition);
        }
    }

    function assertTrue(bool condition, string memory err) internal pure {
        if (!condition) {
            vm.assertTrue(condition, err);
        }
    }

    function assertFalse(bool condition) internal pure {
        if (condition) {
            vm.assertFalse(condition);
        }
    }

    function assertFalse(bool condition, string memory err) internal pure {
        if (condition) {
            vm.assertFalse(condition, err);
        }
    }

    // Approximate equality (useful for decimals)
    function assertApproxEqAbsUint(uint256 left, uint256 right, uint256 maxDelta) internal pure {
        vm.assertApproxEqAbs(left, right, maxDelta);
    }

    function assertApproxEqAbsUint(uint256 left, uint256 right, uint256 maxDelta, string memory err) internal pure {
        vm.assertApproxEqAbs(left, right, maxDelta, err);
    }

    function assertApproxEqRelUint(uint256 left, uint256 right, uint256 maxPercentDelta) internal pure {
        vm.assertApproxEqRel(left, right, maxPercentDelta);
    }

    function assertApproxEqRelUint(uint256 left, uint256 right, uint256 maxPercentDelta, string memory err)
        internal
        pure
    {
        vm.assertApproxEqRel(left, right, maxPercentDelta, err);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // TIME MANIPULATION
    // ═══════════════════════════════════════════════════════════════════════

    function skip(uint256 time) internal {
        vm.warp(vm.getBlockTimestamp() + time);
    }

    function rewind(uint256 time) internal {
        vm.warp(vm.getBlockTimestamp() - time);
    }

    function skipBlocks(uint256 blocks) internal {
        vm.roll(vm.getBlockNumber() + blocks);
    }

    function rewindBlocks(uint256 blocks) internal {
        vm.roll(vm.getBlockNumber() - blocks);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // ACCOUNT MANIPULATION
    // ═══════════════════════════════════════════════════════════════════════

    function hoax(address who) internal {
        vm.deal(who, 1 << 128);
        vm.prank(who);
    }

    function hoax(address who, uint256 give) internal {
        vm.deal(who, give);
        vm.prank(who);
    }

    function startHoax(address who) internal {
        vm.deal(who, 1 << 128);
        vm.startPrank(who);
    }

    function startHoax(address who, uint256 give) internal {
        vm.deal(who, give);
        vm.startPrank(who);
    }

    function makeAddrAndKey(string memory name) internal returns (address addr, uint256 privateKey) {
        privateKey = uint256(keccak256(abi.encodePacked(name)));
        addr = vm.addr(privateKey);
        vm.label(addr, name);
    }

    function makeAddr(string memory name) internal returns (address addr) {
        (addr,) = makeAddrAndKey(name);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // MATH UTILITIES
    // ═══════════════════════════════════════════════════════════════════════

    function abs(int256 x) internal pure returns (uint256) {
        return stdMath.abs(x);
    }

    function delta(uint256 a, uint256 b) internal pure returns (uint256) {
        return stdMath.delta(a, b);
    }

    function delta(int256 a, int256 b) internal pure returns (uint256) {
        return stdMath.delta(a, b);
    }

    function percentDelta(uint256 a, uint256 b) internal pure returns (uint256) {
        return stdMath.percentDelta(a, b);
    }

    function percentDelta(int256 a, int256 b) internal pure returns (uint256) {
        return stdMath.percentDelta(a, b);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // ERRORS
    // ═══════════════════════════════════════════════════════════════════════

    function arithmeticError() internal pure returns (bytes memory) {
        return stdError.arithmeticError;
    }

    function assertionError() internal pure returns (bytes memory) {
        return stdError.assertionError;
    }

    function indexOOBError() internal pure returns (bytes memory) {
        return stdError.indexOOBError;
    }

    function divisionError() internal pure returns (bytes memory) {
        return stdError.divisionError;
    }

    function encodeStorageError() internal pure returns (bytes memory) {
        return stdError.encodeStorageError;
    }

    function popError() internal pure returns (bytes memory) {
        return stdError.popError;
    }

    function memOverflowError() internal pure returns (bytes memory) {
        return stdError.memOverflowError;
    }

    function zeroVarError() internal pure returns (bytes memory) {
        return stdError.zeroVarError;
    }
}
