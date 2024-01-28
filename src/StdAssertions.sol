// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import {stdMath} from "./StdMath.sol";
import {Vm} from "./Vm.sol";
import {console2} from "./console2.sol";

abstract contract StdAssertions {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    event log(string);
    event log_named_bytes(string key, bytes val);

    function assertTrue(bool data) internal virtual {
        vm.assertTrue(data);
    }

    function assertTrue(bool data, string memory err) internal virtual {
        vm.assertTrue(data, err);
    }

    function assertFalse(bool data) internal virtual {
        vm.assertFalse(data);
    }

    function assertFalse(bool data, string memory err) internal virtual {
        vm.assertFalse(data, err);
    }

    function assertEq(bool left, bool right) internal virtual {
        vm.assertEq(left, right);
    }

    function assertEq(bool left, bool right, string memory err) internal virtual {
        vm.assertEq(left, right, err);
    }

    function assertEq(uint256 left, uint256 right) internal virtual {
        vm.assertEq(left, right);
    }

    function assertEq(uint256 left, uint256 right, string memory err) internal virtual {
        vm.assertEq(left, right, err);
    }

    function assertEqDecimal(uint256 left, uint256 right, uint256 decimals) internal virtual {
        vm.assertEqDecimal(left, right, decimals);
    }

    function assertEqDecimal(uint256 left, uint256 right, uint256 decimals, string memory err) internal virtual {
        vm.assertEqDecimal(left, right, decimals, err);
    }

    function assertEq(int256 left, int256 right) internal virtual {
        vm.assertEq(left, right);
    }

    function assertEq(int256 left, int256 right, string memory err) internal virtual {
        vm.assertEq(left, right, err);
    }

    function assertEqDecimal(int256 left, int256 right, uint256 decimals) internal virtual {
        vm.assertEqDecimal(left, right, decimals);
    }

    function assertEqDecimal(int256 left, int256 right, uint256 decimals, string memory err) internal virtual {
        vm.assertEqDecimal(left, right, decimals, err);
    }

    function assertEq(address left, address right) internal virtual {
        vm.assertEq(left, right);
    }

    function assertEq(address left, address right, string memory err) internal virtual {
        vm.assertEq(left, right, err);
    }

    function assertEq(bytes32 left, bytes32 right) internal virtual {
        vm.assertEq(left, right);
    }

    function assertEq(bytes32 left, bytes32 right, string memory err) internal virtual {
        vm.assertEq(left, right, err);
    }

    function assertEq(string memory left, string memory right) internal virtual {
        vm.assertEq(left, right);
    }

    function assertEq(string memory left, string memory right, string memory err) internal virtual {
        vm.assertEq(left, right, err);
    }

    function assertEq(bytes memory left, bytes memory right) internal virtual {
        vm.assertEq(left, right);
    }

    function assertEq(bytes memory left, bytes memory right, string memory err) internal virtual {
        vm.assertEq(left, right, err);
    }

    function assertEq(bool[] memory left, bool[] memory right) internal virtual {
        vm.assertEq(left, right);
    }

    function assertEq(bool[] memory left, bool[] memory right, string memory err) internal virtual {
        vm.assertEq(left, right, err);
    }

    function assertEq(uint256[] memory left, uint256[] memory right) internal virtual {
        vm.assertEq(left, right);
    }

    function assertEq(uint256[] memory left, uint256[] memory right, string memory err) internal virtual {
        vm.assertEq(left, right, err);
    }

    function assertEq(int256[] memory left, int256[] memory right) internal virtual {
        vm.assertEq(left, right);
    }

    function assertEq(int256[] memory left, int256[] memory right, string memory err) internal virtual {
        vm.assertEq(left, right, err);
    }

    function assertEq(address[] memory left, address[] memory right) internal virtual {
        vm.assertEq(left, right);
    }

    function assertEq(address[] memory left, address[] memory right, string memory err) internal virtual {
        vm.assertEq(left, right, err);
    }

    function assertEq(bytes32[] memory left, bytes32[] memory right) internal virtual {
        vm.assertEq(left, right);
    }

    function assertEq(bytes32[] memory left, bytes32[] memory right, string memory err) internal virtual {
        vm.assertEq(left, right, err);
    }

    function assertEq(string[] memory left, string[] memory right) internal virtual {
        vm.assertEq(left, right);
    }

    function assertEq(string[] memory left, string[] memory right, string memory err) internal virtual {
        vm.assertEq(left, right, err);
    }

    function assertEq(bytes[] memory left, bytes[] memory right) internal virtual {
        vm.assertEq(left, right);
    }

    function assertEq(bytes[] memory left, bytes[] memory right, string memory err) internal virtual {
        vm.assertEq(left, right, err);
    }

    // Legacy helper
    function assertEqUint(uint256 a, uint256 b) internal virtual {
        assertEq(a, b);
    }

    function assertNotEq(bool left, bool right) internal virtual {
        vm.assertNotEq(left, right);
    }

    function assertNotEq(bool left, bool right, string memory err) internal virtual {
        vm.assertNotEq(left, right, err);
    }

    function assertNotEq(uint256 left, uint256 right) internal virtual {
        vm.assertNotEq(left, right);
    }

    function assertNotEq(uint256 left, uint256 right, string memory err) internal virtual {
        vm.assertNotEq(left, right, err);
    }

    function assertNotEqDecimal(uint256 left, uint256 right, uint256 decimals) internal virtual {
        vm.assertNotEqDecimal(left, right, decimals);
    }

    function assertNotEqDecimal(uint256 left, uint256 right, uint256 decimals, string memory err) internal virtual {
        vm.assertNotEqDecimal(left, right, decimals, err);
    }

    function assertNotEq(int256 left, int256 right) internal virtual {
        vm.assertNotEq(left, right);
    }

    function assertNotEq(int256 left, int256 right, string memory err) internal virtual {
        vm.assertNotEq(left, right, err);
    }

    function assertNotEqDecimal(int256 left, int256 right, uint256 decimals) internal virtual {
        vm.assertNotEqDecimal(left, right, decimals);
    }

    function assertNotEqDecimal(int256 left, int256 right, uint256 decimals, string memory err) internal virtual {
        vm.assertNotEqDecimal(left, right, decimals, err);
    }

    function assertNotEq(address left, address right) internal virtual {
        vm.assertNotEq(left, right);
    }

    function assertNotEq(address left, address right, string memory err) internal virtual {
        vm.assertNotEq(left, right, err);
    }

    function assertNotEq(bytes32 left, bytes32 right) internal virtual {
        vm.assertNotEq(left, right);
    }

    function assertNotEq(bytes32 left, bytes32 right, string memory err) internal virtual {
        vm.assertNotEq(left, right, err);
    }

    function assertNotEq(string memory left, string memory right) internal virtual {
        vm.assertNotEq(left, right);
    }

    function assertNotEq(string memory left, string memory right, string memory err) internal virtual {
        vm.assertNotEq(left, right, err);
    }

    function assertNotEq(bytes memory left, bytes memory right) internal virtual {
        vm.assertNotEq(left, right);
    }

    function assertNotEq(bytes memory left, bytes memory right, string memory err) internal virtual {
        vm.assertNotEq(left, right, err);
    }

    function assertNotEq(bool[] memory left, bool[] memory right) internal virtual {
        vm.assertNotEq(left, right);
    }

    function assertNotEq(bool[] memory left, bool[] memory right, string memory err) internal virtual {
        vm.assertNotEq(left, right, err);
    }

    function assertNotEq(uint256[] memory left, uint256[] memory right) internal virtual {
        vm.assertNotEq(left, right);
    }

    function assertNotEq(uint256[] memory left, uint256[] memory right, string memory err) internal virtual {
        vm.assertNotEq(left, right, err);
    }

    function assertNotEq(int256[] memory left, int256[] memory right) internal virtual {
        vm.assertNotEq(left, right);
    }

    function assertNotEq(int256[] memory left, int256[] memory right, string memory err) internal virtual {
        vm.assertNotEq(left, right, err);
    }

    function assertNotEq(address[] memory left, address[] memory right) internal virtual {
        vm.assertNotEq(left, right);
    }

    function assertNotEq(address[] memory left, address[] memory right, string memory err) internal virtual {
        vm.assertNotEq(left, right, err);
    }

    function assertNotEq(bytes32[] memory left, bytes32[] memory right) internal virtual {
        vm.assertNotEq(left, right);
    }

    function assertNotEq(bytes32[] memory left, bytes32[] memory right, string memory err) internal virtual {
        vm.assertNotEq(left, right, err);
    }

    function assertNotEq(string[] memory left, string[] memory right) internal virtual {
        vm.assertNotEq(left, right);
    }

    function assertNotEq(string[] memory left, string[] memory right, string memory err) internal virtual {
        vm.assertNotEq(left, right, err);
    }

    function assertNotEq(bytes[] memory left, bytes[] memory right) internal virtual {
        vm.assertNotEq(left, right);
    }

    function assertNotEq(bytes[] memory left, bytes[] memory right, string memory err) internal virtual {
        vm.assertNotEq(left, right, err);
    }

    function assertLt(uint256 left, uint256 right) internal virtual {
        vm.assertLt(left, right);
    }

    function assertLt(uint256 left, uint256 right, string memory err) internal virtual {
        vm.assertLt(left, right, err);
    }

    function assertLtDecimal(uint256 left, uint256 right, uint256 decimals) internal virtual {
        vm.assertLtDecimal(left, right, decimals);
    }

    function assertLtDecimal(uint256 left, uint256 right, uint256 decimals, string memory err) internal virtual {
        vm.assertLtDecimal(left, right, decimals, err);
    }

    function assertLt(int256 left, int256 right) internal virtual {
        vm.assertLt(left, right);
    }

    function assertLt(int256 left, int256 right, string memory err) internal virtual {
        vm.assertLt(left, right, err);
    }

    function assertLtDecimal(int256 left, int256 right, uint256 decimals) internal virtual {
        vm.assertLtDecimal(left, right, decimals);
    }

    function assertLtDecimal(int256 left, int256 right, uint256 decimals, string memory err) internal virtual {
        vm.assertLtDecimal(left, right, decimals, err);
    }

    function assertGt(uint256 left, uint256 right) internal virtual {
        vm.assertGt(left, right);
    }

    function assertGt(uint256 left, uint256 right, string memory err) internal virtual {
        vm.assertGt(left, right, err);
    }

    function assertGtDecimal(uint256 left, uint256 right, uint256 decimals) internal virtual {
        vm.assertGtDecimal(left, right, decimals);
    }

    function assertGtDecimal(uint256 left, uint256 right, uint256 decimals, string memory err) internal virtual {
        vm.assertGtDecimal(left, right, decimals, err);
    }

    function assertGt(int256 left, int256 right) internal virtual {
        vm.assertGt(left, right);
    }

    function assertGt(int256 left, int256 right, string memory err) internal virtual {
        vm.assertGt(left, right, err);
    }

    function assertGtDecimal(int256 left, int256 right, uint256 decimals) internal virtual {
        vm.assertGtDecimal(left, right, decimals);
    }

    function assertGtDecimal(int256 left, int256 right, uint256 decimals, string memory err) internal virtual {
        vm.assertGtDecimal(left, right, decimals, err);
    }

    function assertLe(uint256 left, uint256 right) internal virtual {
        vm.assertLe(left, right);
    }

    function assertLe(uint256 left, uint256 right, string memory err) internal virtual {
        vm.assertLe(left, right, err);
    }

    function assertLeDecimal(uint256 left, uint256 right, uint256 decimals) internal virtual {
        vm.assertLeDecimal(left, right, decimals);
    }

    function assertLeDecimal(uint256 left, uint256 right, uint256 decimals, string memory err) internal virtual {
        vm.assertLeDecimal(left, right, decimals, err);
    }

    function assertLe(int256 left, int256 right) internal virtual {
        vm.assertLe(left, right);
    }

    function assertLe(int256 left, int256 right, string memory err) internal virtual {
        vm.assertLe(left, right, err);
    }

    function assertLeDecimal(int256 left, int256 right, uint256 decimals) internal virtual {
        vm.assertLeDecimal(left, right, decimals);
    }

    function assertLeDecimal(int256 left, int256 right, uint256 decimals, string memory err) internal virtual {
        vm.assertLeDecimal(left, right, decimals, err);
    }

    function assertGe(uint256 left, uint256 right) internal virtual {
        vm.assertGe(left, right);
    }

    function assertGe(uint256 left, uint256 right, string memory err) internal virtual {
        vm.assertGe(left, right, err);
    }

    function assertGeDecimal(uint256 left, uint256 right, uint256 decimals) internal virtual {
        vm.assertGeDecimal(left, right, decimals);
    }

    function assertGeDecimal(uint256 left, uint256 right, uint256 decimals, string memory err) internal virtual {
        vm.assertGeDecimal(left, right, decimals, err);
    }

    function assertGe(int256 left, int256 right) internal virtual {
        vm.assertGe(left, right);
    }

    function assertGe(int256 left, int256 right, string memory err) internal virtual {
        vm.assertGe(left, right, err);
    }

    function assertGeDecimal(int256 left, int256 right, uint256 decimals) internal virtual {
        vm.assertGeDecimal(left, right, decimals);
    }

    function assertGeDecimal(int256 left, int256 right, uint256 decimals, string memory err) internal virtual {
        vm.assertGeDecimal(left, right, decimals, err);
    }

    function assertApproxEqAbs(uint256 left, uint256 right, uint256 maxDelta) internal virtual {
        vm.assertApproxEqAbs(left, right, maxDelta);
    }

    function assertApproxEqAbs(uint256 left, uint256 right, uint256 maxDelta, string memory err) internal virtual {
        vm.assertApproxEqAbs(left, right, maxDelta, err);
    }

    function assertApproxEqAbsDecimal(uint256 left, uint256 right, uint256 maxDelta, uint256 decimals)
        internal
        virtual
    {
        vm.assertApproxEqAbsDecimal(left, right, maxDelta, decimals);
    }

    function assertApproxEqAbsDecimal(
        uint256 left,
        uint256 right,
        uint256 maxDelta,
        uint256 decimals,
        string memory err
    ) internal virtual {
        vm.assertApproxEqAbsDecimal(left, right, maxDelta, decimals, err);
    }

    function assertApproxEqAbs(int256 left, int256 right, uint256 maxDelta) internal virtual {
        vm.assertApproxEqAbs(left, right, maxDelta);
    }

    function assertApproxEqAbs(int256 left, int256 right, uint256 maxDelta, string memory err) internal virtual {
        vm.assertApproxEqAbs(left, right, maxDelta, err);
    }

    function assertApproxEqAbsDecimal(int256 left, int256 right, uint256 maxDelta, uint256 decimals) internal virtual {
        vm.assertApproxEqAbsDecimal(left, right, maxDelta, decimals);
    }

    function assertApproxEqAbsDecimal(int256 left, int256 right, uint256 maxDelta, uint256 decimals, string memory err)
        internal
        virtual
    {
        vm.assertApproxEqAbsDecimal(left, right, maxDelta, decimals, err);
    }

    function assertApproxEqRel(
        uint256 left,
        uint256 right,
        uint256 maxPercentDelta // An 18 decimal fixed point number, where 1e18 == 100%
    ) internal virtual {
        vm.assertApproxEqRel(left, right, maxPercentDelta);
    }

    function assertApproxEqRel(
        uint256 left,
        uint256 right,
        uint256 maxPercentDelta, // An 18 decimal fixed point number, where 1e18 == 100%
        string memory err
    ) internal virtual {
        vm.assertApproxEqRel(left, right, maxPercentDelta, err);
    }

    function assertApproxEqRelDecimal(
        uint256 left,
        uint256 right,
        uint256 maxPercentDelta, // An 18 decimal fixed point number, where 1e18 == 100%
        uint256 decimals
    ) internal virtual {
        vm.assertApproxEqRelDecimal(left, right, maxPercentDelta, decimals);
    }

    function assertApproxEqRelDecimal(
        uint256 left,
        uint256 right,
        uint256 maxPercentDelta, // An 18 decimal fixed point number, where 1e18 == 100%
        uint256 decimals,
        string memory err
    ) internal virtual {
        vm.assertApproxEqRelDecimal(left, right, maxPercentDelta, decimals, err);
    }

    function assertApproxEqRel(int256 left, int256 right, uint256 maxPercentDelta) internal virtual {
        vm.assertApproxEqRel(left, right, maxPercentDelta);
    }

    function assertApproxEqRel(
        int256 left,
        int256 right,
        uint256 maxPercentDelta, // An 18 decimal fixed point number, where 1e18 == 100%
        string memory err
    ) internal virtual {
        vm.assertApproxEqRel(left, right, maxPercentDelta, err);
    }

    function assertApproxEqRelDecimal(
        int256 left,
        int256 right,
        uint256 maxPercentDelta, // An 18 decimal fixed point number, where 1e18 == 100%
        uint256 decimals
    ) internal virtual {
        vm.assertApproxEqRelDecimal(left, right, maxPercentDelta, decimals);
    }

    function assertApproxEqRelDecimal(
        int256 left,
        int256 right,
        uint256 maxPercentDelta, // An 18 decimal fixed point number, where 1e18 == 100%
        uint256 decimals,
        string memory err
    ) internal virtual {
        vm.assertApproxEqRelDecimal(left, right, maxPercentDelta, decimals, err);
    }

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

        console2.log(successA, successB);

        if (successA && successB) {
            assertEq(returnDataA, returnDataB, "Call return data does not match");
        }

        if (!successA && !successB && strictRevertData) {
            assertEq(returnDataA, returnDataB, "Call revert data does not match");
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
