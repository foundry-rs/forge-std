// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.20 <0.9.0;

import {Vm} from "./Vm.sol";

/// @title StdAssertionsV2 - Explicit type-named assertions for AI/agent disambiguation
/// @notice Use assertEqUint, assertEqInt, assertEqAddress instead of overloaded assertEq
/// @dev Each assertion function has a unique name that includes the type being compared
abstract contract StdAssertionsV2 {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    event log(string);
    event logs(bytes);

    event log_address(address);
    event log_bytes32(bytes32);
    event log_int(int256);
    event log_uint(uint256);
    event log_bytes(bytes);
    event log_string(string);

    event log_named_address(string key, address val);
    event log_named_bytes32(string key, bytes32 val);
    event log_named_decimal_int(string key, int256 val, uint256 decimals);
    event log_named_decimal_uint(string key, uint256 val, uint256 decimals);
    event log_named_int(string key, int256 val);
    event log_named_uint(string key, uint256 val);
    event log_named_bytes(string key, bytes val);
    event log_named_string(string key, string val);

    event log_array(uint256[] val);
    event log_array(int256[] val);
    event log_array(address[] val);
    event log_named_array(string key, uint256[] val);
    event log_named_array(string key, int256[] val);
    event log_named_array(string key, address[] val);

    bytes32 private constant FAILED_SLOT = bytes32("failed");

    bool private _failed;

    function failed() public view returns (bool) {
        if (_failed) {
            return true;
        } else {
            return vm.load(address(vm), FAILED_SLOT) != bytes32(0);
        }
    }

    function fail() internal virtual {
        vm.store(address(vm), FAILED_SLOT, bytes32(uint256(1)));
        _failed = true;
    }

    function fail(string memory message) internal virtual {
        fail();
        vm.assertTrue(false, message);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // BOOLEAN ASSERTIONS
    // ═══════════════════════════════════════════════════════════════════════

    function assertTrue(bool data) internal pure virtual {
        if (!data) {
            vm.assertTrue(data);
        }
    }

    function assertTrue(bool data, string memory err) internal pure virtual {
        if (!data) {
            vm.assertTrue(data, err);
        }
    }

    function assertFalse(bool data) internal pure virtual {
        if (data) {
            vm.assertFalse(data);
        }
    }

    function assertFalse(bool data, string memory err) internal pure virtual {
        if (data) {
            vm.assertFalse(data, err);
        }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // EQUALITY ASSERTIONS - BOOL
    // ═══════════════════════════════════════════════════════════════════════

    function assertEqBool(bool left, bool right) internal pure virtual {
        if (left != right) {
            vm.assertEq(left, right);
        }
    }

    function assertEqBool(bool left, bool right, string memory err) internal pure virtual {
        if (left != right) {
            vm.assertEq(left, right, err);
        }
    }

    function assertNotEqBool(bool left, bool right) internal pure virtual {
        if (left == right) {
            vm.assertNotEq(left, right);
        }
    }

    function assertNotEqBool(bool left, bool right, string memory err) internal pure virtual {
        if (left == right) {
            vm.assertNotEq(left, right, err);
        }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // EQUALITY ASSERTIONS - UINT256
    // ═══════════════════════════════════════════════════════════════════════

    function assertEqUint(uint256 left, uint256 right) internal pure virtual {
        if (left != right) {
            vm.assertEq(left, right);
        }
    }

    function assertEqUint(uint256 left, uint256 right, string memory err) internal pure virtual {
        if (left != right) {
            vm.assertEq(left, right, err);
        }
    }

    function assertEqUintDecimal(uint256 left, uint256 right, uint256 decimals) internal pure virtual {
        vm.assertEqDecimal(left, right, decimals);
    }

    function assertEqUintDecimal(uint256 left, uint256 right, uint256 decimals, string memory err)
        internal
        pure
        virtual
    {
        vm.assertEqDecimal(left, right, decimals, err);
    }

    function assertNotEqUint(uint256 left, uint256 right) internal pure virtual {
        if (left == right) {
            vm.assertNotEq(left, right);
        }
    }

    function assertNotEqUint(uint256 left, uint256 right, string memory err) internal pure virtual {
        if (left == right) {
            vm.assertNotEq(left, right, err);
        }
    }

    function assertNotEqUintDecimal(uint256 left, uint256 right, uint256 decimals) internal pure virtual {
        vm.assertNotEqDecimal(left, right, decimals);
    }

    function assertNotEqUintDecimal(uint256 left, uint256 right, uint256 decimals, string memory err)
        internal
        pure
        virtual
    {
        vm.assertNotEqDecimal(left, right, decimals, err);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // EQUALITY ASSERTIONS - INT256
    // ═══════════════════════════════════════════════════════════════════════

    function assertEqInt(int256 left, int256 right) internal pure virtual {
        if (left != right) {
            vm.assertEq(left, right);
        }
    }

    function assertEqInt(int256 left, int256 right, string memory err) internal pure virtual {
        if (left != right) {
            vm.assertEq(left, right, err);
        }
    }

    function assertEqIntDecimal(int256 left, int256 right, uint256 decimals) internal pure virtual {
        vm.assertEqDecimal(left, right, decimals);
    }

    function assertEqIntDecimal(int256 left, int256 right, uint256 decimals, string memory err)
        internal
        pure
        virtual
    {
        vm.assertEqDecimal(left, right, decimals, err);
    }

    function assertNotEqInt(int256 left, int256 right) internal pure virtual {
        if (left == right) {
            vm.assertNotEq(left, right);
        }
    }

    function assertNotEqInt(int256 left, int256 right, string memory err) internal pure virtual {
        if (left == right) {
            vm.assertNotEq(left, right, err);
        }
    }

    function assertNotEqIntDecimal(int256 left, int256 right, uint256 decimals) internal pure virtual {
        vm.assertNotEqDecimal(left, right, decimals);
    }

    function assertNotEqIntDecimal(int256 left, int256 right, uint256 decimals, string memory err)
        internal
        pure
        virtual
    {
        vm.assertNotEqDecimal(left, right, decimals, err);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // EQUALITY ASSERTIONS - ADDRESS
    // ═══════════════════════════════════════════════════════════════════════

    function assertEqAddress(address left, address right) internal pure virtual {
        if (left != right) {
            vm.assertEq(left, right);
        }
    }

    function assertEqAddress(address left, address right, string memory err) internal pure virtual {
        if (left != right) {
            vm.assertEq(left, right, err);
        }
    }

    function assertNotEqAddress(address left, address right) internal pure virtual {
        if (left == right) {
            vm.assertNotEq(left, right);
        }
    }

    function assertNotEqAddress(address left, address right, string memory err) internal pure virtual {
        if (left == right) {
            vm.assertNotEq(left, right, err);
        }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // EQUALITY ASSERTIONS - BYTES32
    // ═══════════════════════════════════════════════════════════════════════

    function assertEqBytes32(bytes32 left, bytes32 right) internal pure virtual {
        if (left != right) {
            vm.assertEq(left, right);
        }
    }

    function assertEqBytes32(bytes32 left, bytes32 right, string memory err) internal pure virtual {
        if (left != right) {
            vm.assertEq(left, right, err);
        }
    }

    function assertNotEqBytes32(bytes32 left, bytes32 right) internal pure virtual {
        if (left == right) {
            vm.assertNotEq(left, right);
        }
    }

    function assertNotEqBytes32(bytes32 left, bytes32 right, string memory err) internal pure virtual {
        if (left == right) {
            vm.assertNotEq(left, right, err);
        }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // EQUALITY ASSERTIONS - STRING
    // ═══════════════════════════════════════════════════════════════════════

    function assertEqString(string memory left, string memory right) internal pure virtual {
        vm.assertEq(left, right);
    }

    function assertEqString(string memory left, string memory right, string memory err) internal pure virtual {
        vm.assertEq(left, right, err);
    }

    function assertNotEqString(string memory left, string memory right) internal pure virtual {
        vm.assertNotEq(left, right);
    }

    function assertNotEqString(string memory left, string memory right, string memory err) internal pure virtual {
        vm.assertNotEq(left, right, err);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // EQUALITY ASSERTIONS - BYTES
    // ═══════════════════════════════════════════════════════════════════════

    function assertEqBytes(bytes memory left, bytes memory right) internal pure virtual {
        vm.assertEq(left, right);
    }

    function assertEqBytes(bytes memory left, bytes memory right, string memory err) internal pure virtual {
        vm.assertEq(left, right, err);
    }

    function assertNotEqBytes(bytes memory left, bytes memory right) internal pure virtual {
        vm.assertNotEq(left, right);
    }

    function assertNotEqBytes(bytes memory left, bytes memory right, string memory err) internal pure virtual {
        vm.assertNotEq(left, right, err);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // EQUALITY ASSERTIONS - ARRAYS
    // ═══════════════════════════════════════════════════════════════════════

    function assertEqUintArray(uint256[] memory left, uint256[] memory right) internal pure virtual {
        vm.assertEq(left, right);
    }

    function assertEqUintArray(uint256[] memory left, uint256[] memory right, string memory err)
        internal
        pure
        virtual
    {
        vm.assertEq(left, right, err);
    }

    function assertEqIntArray(int256[] memory left, int256[] memory right) internal pure virtual {
        vm.assertEq(left, right);
    }

    function assertEqIntArray(int256[] memory left, int256[] memory right, string memory err) internal pure virtual {
        vm.assertEq(left, right, err);
    }

    function assertEqAddressArray(address[] memory left, address[] memory right) internal pure virtual {
        vm.assertEq(left, right);
    }

    function assertEqAddressArray(address[] memory left, address[] memory right, string memory err)
        internal
        pure
        virtual
    {
        vm.assertEq(left, right, err);
    }

    function assertEqBytes32Array(bytes32[] memory left, bytes32[] memory right) internal pure virtual {
        vm.assertEq(left, right);
    }

    function assertEqBytes32Array(bytes32[] memory left, bytes32[] memory right, string memory err)
        internal
        pure
        virtual
    {
        vm.assertEq(left, right, err);
    }

    function assertEqBoolArray(bool[] memory left, bool[] memory right) internal pure virtual {
        vm.assertEq(left, right);
    }

    function assertEqBoolArray(bool[] memory left, bool[] memory right, string memory err) internal pure virtual {
        vm.assertEq(left, right, err);
    }

    function assertEqStringArray(string[] memory left, string[] memory right) internal pure virtual {
        vm.assertEq(left, right);
    }

    function assertEqStringArray(string[] memory left, string[] memory right, string memory err)
        internal
        pure
        virtual
    {
        vm.assertEq(left, right, err);
    }

    function assertEqBytesArray(bytes[] memory left, bytes[] memory right) internal pure virtual {
        vm.assertEq(left, right);
    }

    function assertEqBytesArray(bytes[] memory left, bytes[] memory right, string memory err) internal pure virtual {
        vm.assertEq(left, right, err);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // COMPARISON ASSERTIONS - UINT256
    // ═══════════════════════════════════════════════════════════════════════

    function assertGtUint(uint256 left, uint256 right) internal pure virtual {
        if (left <= right) {
            vm.assertGt(left, right);
        }
    }

    function assertGtUint(uint256 left, uint256 right, string memory err) internal pure virtual {
        if (left <= right) {
            vm.assertGt(left, right, err);
        }
    }

    function assertGtUintDecimal(uint256 left, uint256 right, uint256 decimals) internal pure virtual {
        vm.assertGtDecimal(left, right, decimals);
    }

    function assertGtUintDecimal(uint256 left, uint256 right, uint256 decimals, string memory err)
        internal
        pure
        virtual
    {
        vm.assertGtDecimal(left, right, decimals, err);
    }

    function assertGeUint(uint256 left, uint256 right) internal pure virtual {
        if (left < right) {
            vm.assertGe(left, right);
        }
    }

    function assertGeUint(uint256 left, uint256 right, string memory err) internal pure virtual {
        if (left < right) {
            vm.assertGe(left, right, err);
        }
    }

    function assertGeUintDecimal(uint256 left, uint256 right, uint256 decimals) internal pure virtual {
        vm.assertGeDecimal(left, right, decimals);
    }

    function assertGeUintDecimal(uint256 left, uint256 right, uint256 decimals, string memory err)
        internal
        pure
        virtual
    {
        vm.assertGeDecimal(left, right, decimals, err);
    }

    function assertLtUint(uint256 left, uint256 right) internal pure virtual {
        if (left >= right) {
            vm.assertLt(left, right);
        }
    }

    function assertLtUint(uint256 left, uint256 right, string memory err) internal pure virtual {
        if (left >= right) {
            vm.assertLt(left, right, err);
        }
    }

    function assertLtUintDecimal(uint256 left, uint256 right, uint256 decimals) internal pure virtual {
        vm.assertLtDecimal(left, right, decimals);
    }

    function assertLtUintDecimal(uint256 left, uint256 right, uint256 decimals, string memory err)
        internal
        pure
        virtual
    {
        vm.assertLtDecimal(left, right, decimals, err);
    }

    function assertLeUint(uint256 left, uint256 right) internal pure virtual {
        if (left > right) {
            vm.assertLe(left, right);
        }
    }

    function assertLeUint(uint256 left, uint256 right, string memory err) internal pure virtual {
        if (left > right) {
            vm.assertLe(left, right, err);
        }
    }

    function assertLeUintDecimal(uint256 left, uint256 right, uint256 decimals) internal pure virtual {
        vm.assertLeDecimal(left, right, decimals);
    }

    function assertLeUintDecimal(uint256 left, uint256 right, uint256 decimals, string memory err)
        internal
        pure
        virtual
    {
        vm.assertLeDecimal(left, right, decimals, err);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // COMPARISON ASSERTIONS - INT256
    // ═══════════════════════════════════════════════════════════════════════

    function assertGtInt(int256 left, int256 right) internal pure virtual {
        if (left <= right) {
            vm.assertGt(left, right);
        }
    }

    function assertGtInt(int256 left, int256 right, string memory err) internal pure virtual {
        if (left <= right) {
            vm.assertGt(left, right, err);
        }
    }

    function assertGtIntDecimal(int256 left, int256 right, uint256 decimals) internal pure virtual {
        vm.assertGtDecimal(left, right, decimals);
    }

    function assertGtIntDecimal(int256 left, int256 right, uint256 decimals, string memory err)
        internal
        pure
        virtual
    {
        vm.assertGtDecimal(left, right, decimals, err);
    }

    function assertGeInt(int256 left, int256 right) internal pure virtual {
        if (left < right) {
            vm.assertGe(left, right);
        }
    }

    function assertGeInt(int256 left, int256 right, string memory err) internal pure virtual {
        if (left < right) {
            vm.assertGe(left, right, err);
        }
    }

    function assertGeIntDecimal(int256 left, int256 right, uint256 decimals) internal pure virtual {
        vm.assertGeDecimal(left, right, decimals);
    }

    function assertGeIntDecimal(int256 left, int256 right, uint256 decimals, string memory err)
        internal
        pure
        virtual
    {
        vm.assertGeDecimal(left, right, decimals, err);
    }

    function assertLtInt(int256 left, int256 right) internal pure virtual {
        if (left >= right) {
            vm.assertLt(left, right);
        }
    }

    function assertLtInt(int256 left, int256 right, string memory err) internal pure virtual {
        if (left >= right) {
            vm.assertLt(left, right, err);
        }
    }

    function assertLtIntDecimal(int256 left, int256 right, uint256 decimals) internal pure virtual {
        vm.assertLtDecimal(left, right, decimals);
    }

    function assertLtIntDecimal(int256 left, int256 right, uint256 decimals, string memory err)
        internal
        pure
        virtual
    {
        vm.assertLtDecimal(left, right, decimals, err);
    }

    function assertLeInt(int256 left, int256 right) internal pure virtual {
        if (left > right) {
            vm.assertLe(left, right);
        }
    }

    function assertLeInt(int256 left, int256 right, string memory err) internal pure virtual {
        if (left > right) {
            vm.assertLe(left, right, err);
        }
    }

    function assertLeIntDecimal(int256 left, int256 right, uint256 decimals) internal pure virtual {
        vm.assertLeDecimal(left, right, decimals);
    }

    function assertLeIntDecimal(int256 left, int256 right, uint256 decimals, string memory err)
        internal
        pure
        virtual
    {
        vm.assertLeDecimal(left, right, decimals, err);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // APPROXIMATE EQUALITY ASSERTIONS
    // ═══════════════════════════════════════════════════════════════════════

    function assertApproxEqAbsUint(uint256 left, uint256 right, uint256 maxDelta) internal pure virtual {
        vm.assertApproxEqAbs(left, right, maxDelta);
    }

    function assertApproxEqAbsUint(uint256 left, uint256 right, uint256 maxDelta, string memory err)
        internal
        pure
        virtual
    {
        vm.assertApproxEqAbs(left, right, maxDelta, err);
    }

    function assertApproxEqAbsUintDecimal(uint256 left, uint256 right, uint256 maxDelta, uint256 decimals)
        internal
        pure
        virtual
    {
        vm.assertApproxEqAbsDecimal(left, right, maxDelta, decimals);
    }

    function assertApproxEqAbsUintDecimal(
        uint256 left,
        uint256 right,
        uint256 maxDelta,
        uint256 decimals,
        string memory err
    ) internal pure virtual {
        vm.assertApproxEqAbsDecimal(left, right, maxDelta, decimals, err);
    }

    function assertApproxEqAbsInt(int256 left, int256 right, uint256 maxDelta) internal pure virtual {
        vm.assertApproxEqAbs(left, right, maxDelta);
    }

    function assertApproxEqAbsInt(int256 left, int256 right, uint256 maxDelta, string memory err)
        internal
        pure
        virtual
    {
        vm.assertApproxEqAbs(left, right, maxDelta, err);
    }

    function assertApproxEqAbsIntDecimal(int256 left, int256 right, uint256 maxDelta, uint256 decimals)
        internal
        pure
        virtual
    {
        vm.assertApproxEqAbsDecimal(left, right, maxDelta, decimals);
    }

    function assertApproxEqAbsIntDecimal(
        int256 left,
        int256 right,
        uint256 maxDelta,
        uint256 decimals,
        string memory err
    ) internal pure virtual {
        vm.assertApproxEqAbsDecimal(left, right, maxDelta, decimals, err);
    }

    function assertApproxEqRelUint(uint256 left, uint256 right, uint256 maxPercentDelta) internal pure virtual {
        vm.assertApproxEqRel(left, right, maxPercentDelta);
    }

    function assertApproxEqRelUint(uint256 left, uint256 right, uint256 maxPercentDelta, string memory err)
        internal
        pure
        virtual
    {
        vm.assertApproxEqRel(left, right, maxPercentDelta, err);
    }

    function assertApproxEqRelUintDecimal(uint256 left, uint256 right, uint256 maxPercentDelta, uint256 decimals)
        internal
        pure
        virtual
    {
        vm.assertApproxEqRelDecimal(left, right, maxPercentDelta, decimals);
    }

    function assertApproxEqRelUintDecimal(
        uint256 left,
        uint256 right,
        uint256 maxPercentDelta,
        uint256 decimals,
        string memory err
    ) internal pure virtual {
        vm.assertApproxEqRelDecimal(left, right, maxPercentDelta, decimals, err);
    }

    function assertApproxEqRelInt(int256 left, int256 right, uint256 maxPercentDelta) internal pure virtual {
        vm.assertApproxEqRel(left, right, maxPercentDelta);
    }

    function assertApproxEqRelInt(int256 left, int256 right, uint256 maxPercentDelta, string memory err)
        internal
        pure
        virtual
    {
        vm.assertApproxEqRel(left, right, maxPercentDelta, err);
    }

    function assertApproxEqRelIntDecimal(int256 left, int256 right, uint256 maxPercentDelta, uint256 decimals)
        internal
        pure
        virtual
    {
        vm.assertApproxEqRelDecimal(left, right, maxPercentDelta, decimals);
    }

    function assertApproxEqRelIntDecimal(
        int256 left,
        int256 right,
        uint256 maxPercentDelta,
        uint256 decimals,
        string memory err
    ) internal pure virtual {
        vm.assertApproxEqRelDecimal(left, right, maxPercentDelta, decimals, err);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // CALL ASSERTIONS
    // ═══════════════════════════════════════════════════════════════════════

    function assertEqCall(address target, bytes memory callDataA, bytes memory callDataB) internal virtual {
        assertEqCall(target, callDataA, target, callDataB, true);
    }

    function assertEqCall(address targetA, bytes memory callDataA, address targetB, bytes memory callDataB)
        internal
        virtual
    {
        assertEqCall(targetA, callDataA, targetB, callDataB, true);
    }

    function assertEqCall(address target, bytes memory callDataA, bytes memory callDataB, bool strictRevertData)
        internal
        virtual
    {
        assertEqCall(target, callDataA, target, callDataB, strictRevertData);
    }

    function assertEqCall(
        address targetA,
        bytes memory callDataA,
        address targetB,
        bytes memory callDataB,
        bool strictRevertData
    ) internal virtual {
        (bool successA, bytes memory returnDataA) = address(targetA).call(callDataA);
        (bool successB, bytes memory returnDataB) = address(targetB).call(callDataB);

        if (successA && successB) {
            assertEqBytes(returnDataA, returnDataB, "Call return data does not match");
        }

        if (!successA && !successB && strictRevertData) {
            assertEqBytes(returnDataA, returnDataB, "Call revert data does not match");
        }

        if (!successA && successB) {
            emit log("Error: Calls were not equal");
            emit log_named_bytes("  Left call revert data", returnDataA);
            emit log_named_bytes(" Right call return data", returnDataB);
            revert("assertion failed");
        }

        if (successA && !successB) {
            emit log("Error: Calls were not equal");
            emit log_named_bytes("  Left call return data", returnDataA);
            emit log_named_bytes(" Right call revert data", returnDataB);
            revert("assertion failed");
        }
    }
}
