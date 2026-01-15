// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.20 <0.9.0;

import {Vm} from "./Vm.sol";

/// @title Trace - Structured Call Tracing
/// @notice Capture and analyze call traces in a structured, agent-parseable format
/// @dev Provides call trees that can be programmatically inspected
///
/// Example usage:
/// ```solidity
/// trace.start();
/// target.someFunction();
/// CallTrace memory t = trace.stop();
///
/// // Inspect the trace
/// for (uint i = 0; i < t.calls.length; i++) {
///     console2.log(t.calls[i].target, t.calls[i].selector);
/// }
/// ```

// ═══════════════════════════════════════════════════════════════════════════
// TRACE TYPES
// ═══════════════════════════════════════════════════════════════════════════

enum CallType {
    Call,
    DelegateCall,
    StaticCall,
    Create,
    Create2
}

struct CallNode {
    address from;
    address to;
    CallType callType;
    bytes4 selector;
    bytes input;
    bytes output;
    uint256 value;
    uint256 gasUsed;
    bool success;
    uint256 depth;
    uint256 parentIndex; // Index in the flat array, type(uint256).max for root
    string label; // Human-readable label if available
}

struct CallTrace {
    CallNode[] calls;
    uint256 totalGasUsed;
    uint256 maxDepth;
    bool complete;
    uint256 startTimestamp;
    uint256 endTimestamp;
}

struct TraceFilter {
    address[] includeTargets;
    address[] excludeTargets;
    bytes4[] includeSelectors;
    bytes4[] excludeSelectors;
    uint256 minDepth;
    uint256 maxDepth;
    bool onlyFailed;
    bool onlySucceeded;
}

// ═══════════════════════════════════════════════════════════════════════════
// TRACE ANALYSIS RESULTS
// ═══════════════════════════════════════════════════════════════════════════

struct GasBreakdown {
    address target;
    bytes4 selector;
    uint256 totalGas;
    uint256 callCount;
    uint256 avgGasPerCall;
}

struct TraceAnalysis {
    uint256 uniqueTargets;
    uint256 uniqueSelectors;
    uint256 failedCalls;
    uint256 successfulCalls;
    GasBreakdown[] gasBreakdown;
    address[] callPath; // Ordered list of addresses called
}

library TraceLib {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    // ═══════════════════════════════════════════════════════════════════════
    // RECORDING
    // ═══════════════════════════════════════════════════════════════════════

    function startRecording() internal {
        vm.startStateDiffRecording();
    }

    function stopRecording() internal returns (Vm.AccountAccess[] memory accesses) {
        return vm.stopAndReturnStateDiff();
    }

    // ═══════════════════════════════════════════════════════════════════════
    // CALL CAPTURE (using low-level recording)
    // ═══════════════════════════════════════════════════════════════════════

    function captureCall(address target, bytes memory callData)
        internal
        returns (CallNode memory node, bool success, bytes memory returnData)
    {
        uint256 gasBefore = gasleft();

        (success, returnData) = target.call(callData);

        uint256 gasAfter = gasleft();

        node = CallNode({
            from: address(this),
            to: target,
            callType: CallType.Call,
            selector: bytes4(callData),
            input: callData,
            output: returnData,
            value: 0,
            gasUsed: gasBefore - gasAfter,
            success: success,
            depth: 0,
            parentIndex: type(uint256).max,
            label: ""
        });
    }

    function captureCallWithValue(address target, bytes memory callData, uint256 value)
        internal
        returns (CallNode memory node, bool success, bytes memory returnData)
    {
        uint256 gasBefore = gasleft();

        (success, returnData) = target.call{value: value}(callData);

        uint256 gasAfter = gasleft();

        node = CallNode({
            from: address(this),
            to: target,
            callType: CallType.Call,
            selector: bytes4(callData),
            input: callData,
            output: returnData,
            value: value,
            gasUsed: gasBefore - gasAfter,
            success: success,
            depth: 0,
            parentIndex: type(uint256).max,
            label: ""
        });
    }

    function captureStaticCall(address target, bytes memory callData)
        internal
        view
        returns (CallNode memory node, bool success, bytes memory returnData)
    {
        uint256 gasBefore = gasleft();

        (success, returnData) = target.staticcall(callData);

        uint256 gasAfter = gasleft();

        node = CallNode({
            from: address(this),
            to: target,
            callType: CallType.StaticCall,
            selector: bytes4(callData),
            input: callData,
            output: returnData,
            value: 0,
            gasUsed: gasBefore - gasAfter,
            success: success,
            depth: 0,
            parentIndex: type(uint256).max,
            label: ""
        });
    }

    // ═══════════════════════════════════════════════════════════════════════
    // ANALYSIS
    // ═══════════════════════════════════════════════════════════════════════

    function analyze(CallTrace memory self) internal pure returns (TraceAnalysis memory analysis) {
        if (self.calls.length == 0) {
            return analysis;
        }

        // Count unique targets and collect path
        address[] memory seenTargets = new address[](self.calls.length);
        uint256 uniqueCount = 0;

        analysis.callPath = new address[](self.calls.length);

        for (uint256 i = 0; i < self.calls.length; i++) {
            CallNode memory node = self.calls[i];
            analysis.callPath[i] = node.to;

            if (node.success) {
                analysis.successfulCalls++;
            } else {
                analysis.failedCalls++;
            }

            // Check if target is unique
            bool found = false;
            for (uint256 j = 0; j < uniqueCount; j++) {
                if (seenTargets[j] == node.to) {
                    found = true;
                    break;
                }
            }
            if (!found) {
                seenTargets[uniqueCount++] = node.to;
            }
        }

        analysis.uniqueTargets = uniqueCount;
    }

    function filterCalls(CallTrace memory self, TraceFilter memory filter)
        internal
        pure
        returns (CallNode[] memory filtered)
    {
        // First pass: count matching calls
        uint256 matchCount = 0;
        for (uint256 i = 0; i < self.calls.length; i++) {
            if (matchesFilter(self.calls[i], filter)) {
                matchCount++;
            }
        }

        // Second pass: collect matching calls
        filtered = new CallNode[](matchCount);
        uint256 idx = 0;
        for (uint256 i = 0; i < self.calls.length; i++) {
            if (matchesFilter(self.calls[i], filter)) {
                filtered[idx++] = self.calls[i];
            }
        }
    }

    function matchesFilter(CallNode memory node, TraceFilter memory filter) internal pure returns (bool) {
        // Check depth
        if (node.depth < filter.minDepth) return false;
        if (filter.maxDepth > 0 && node.depth > filter.maxDepth) return false;

        // Check success/failure
        if (filter.onlyFailed && node.success) return false;
        if (filter.onlySucceeded && !node.success) return false;

        // Check include targets
        if (filter.includeTargets.length > 0) {
            bool found = false;
            for (uint256 i = 0; i < filter.includeTargets.length; i++) {
                if (filter.includeTargets[i] == node.to) {
                    found = true;
                    break;
                }
            }
            if (!found) return false;
        }

        // Check exclude targets
        for (uint256 i = 0; i < filter.excludeTargets.length; i++) {
            if (filter.excludeTargets[i] == node.to) return false;
        }

        // Check include selectors
        if (filter.includeSelectors.length > 0) {
            bool found = false;
            for (uint256 i = 0; i < filter.includeSelectors.length; i++) {
                if (filter.includeSelectors[i] == node.selector) {
                    found = true;
                    break;
                }
            }
            if (!found) return false;
        }

        // Check exclude selectors
        for (uint256 i = 0; i < filter.excludeSelectors.length; i++) {
            if (filter.excludeSelectors[i] == node.selector) return false;
        }

        return true;
    }

    function findCallsTo(CallTrace memory self, address target) internal pure returns (CallNode[] memory) {
        TraceFilter memory filter;
        filter.includeTargets = new address[](1);
        filter.includeTargets[0] = target;
        return filterCalls(self, filter);
    }

    function findCallsBySelector(CallTrace memory self, bytes4 selector) internal pure returns (CallNode[] memory) {
        TraceFilter memory filter;
        filter.includeSelectors = new bytes4[](1);
        filter.includeSelectors[0] = selector;
        return filterCalls(self, filter);
    }

    function findFailedCalls(CallTrace memory self) internal pure returns (CallNode[] memory) {
        TraceFilter memory filter;
        filter.onlyFailed = true;
        return filterCalls(self, filter);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // FORMATTING
    // ═══════════════════════════════════════════════════════════════════════

    function format(CallNode memory node) internal pure returns (string memory) {
        string memory callTypeStr;
        if (node.callType == CallType.Call) callTypeStr = "CALL";
        else if (node.callType == CallType.DelegateCall) callTypeStr = "DELEGATECALL";
        else if (node.callType == CallType.StaticCall) callTypeStr = "STATICCALL";
        else if (node.callType == CallType.Create) callTypeStr = "CREATE";
        else if (node.callType == CallType.Create2) callTypeStr = "CREATE2";

        return string.concat(
            callTypeStr,
            " ",
            vm.toString(node.to),
            "::",
            vm.toString(node.selector),
            node.success ? " [OK]" : " [FAIL]",
            " (",
            vm.toString(node.gasUsed),
            " gas)"
        );
    }

    function formatTrace(CallTrace memory self) internal pure returns (string memory output) {
        output = string.concat("Call Trace (", vm.toString(self.calls.length), " calls):\n");

        for (uint256 i = 0; i < self.calls.length; i++) {
            // Add indentation based on depth
            for (uint256 d = 0; d < self.calls[i].depth; d++) {
                output = string.concat(output, "  ");
            }
            output = string.concat(output, format(self.calls[i]), "\n");
        }
    }
}

/// @notice Global trace entry point
library trace {
    using TraceLib for CallTrace;
    using TraceLib for CallNode;

    function captureCall(address target, bytes memory callData)
        internal
        returns (CallNode memory node, bool success, bytes memory returnData)
    {
        return TraceLib.captureCall(target, callData);
    }

    function captureStaticCall(address target, bytes memory callData)
        internal
        view
        returns (CallNode memory node, bool success, bytes memory returnData)
    {
        return TraceLib.captureStaticCall(target, callData);
    }

    function startRecording() internal {
        TraceLib.startRecording();
    }

    function stopRecording() internal returns (Vm.AccountAccess[] memory) {
        return TraceLib.stopRecording();
    }
}
