// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.20 <0.9.0;

import {Vm} from "./Vm.sol";
import {console} from "./console.sol";

/// @title Gas - Structured Gas Profiling
/// @notice Profile and compare gas usage in a structured, agent-parseable format
/// @dev Provides gas reports that can be programmatically inspected
///
/// Example usage:
/// ```solidity
/// GasProfile memory p = gas.profile("transfer");
///
/// token.transfer(recipient, 100);
///
/// GasReport memory r = gas.endProfile(p);
/// console.log("Gas used:", r.gasUsed);
///
/// // Or use the helper:
/// GasReport memory r2 = gas.measure("approve", address(token), abi.encodeCall(token.approve, (spender, 100)));
/// ```

// ═══════════════════════════════════════════════════════════════════════════
// GAS TYPES
// ═══════════════════════════════════════════════════════════════════════════

struct GasProfile {
    string label;
    uint256 startGas;
    uint256 startTimestamp;
    uint256 startBlock;
    bool active;
}

struct GasReport {
    string label;
    uint256 gasUsed;
    uint256 gasStart;
    uint256 gasEnd;
    uint256 timestamp;
    uint256 blockNumber;
    bool success;
    bytes returnData;
}

struct GasComparison {
    string labelA;
    string labelB;
    uint256 gasA;
    uint256 gasB;
    int256 difference;
    int256 percentDifference; // Basis points (100 = 1%)
    bool aIsCheaper;
}

struct GasBenchmark {
    string name;
    GasReport[] samples;
    uint256 minGas;
    uint256 maxGas;
    uint256 avgGas;
    uint256 medianGas;
    uint256 stdDev;
}

struct GasSnapshot {
    string name;
    uint256 timestamp;
    GasReport[] reports;
}

library GasLib {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    // ═══════════════════════════════════════════════════════════════════════
    // PROFILING
    // ═══════════════════════════════════════════════════════════════════════

    function profile(string memory label) internal view returns (GasProfile memory p) {
        p.label = label;
        p.startGas = gasleft();
        p.startTimestamp = block.timestamp;
        p.startBlock = block.number;
        p.active = true;
    }

    function endProfile(GasProfile memory self) internal view returns (GasReport memory r) {
        require(self.active, "Gas: Profile not active");

        uint256 endGas = gasleft();

        r.label = self.label;
        r.gasStart = self.startGas;
        r.gasEnd = endGas;
        r.gasUsed = self.startGas - endGas;
        r.timestamp = block.timestamp;
        r.blockNumber = block.number;
        r.success = true;
    }

    // ═══════════════════════════════════════════════════════════════════════
    // MEASUREMENT HELPERS
    // ═══════════════════════════════════════════════════════════════════════

    function measure(string memory label, address target, bytes memory callData)
        internal
        returns (GasReport memory r)
    {
        r.label = label;
        r.timestamp = block.timestamp;
        r.blockNumber = block.number;

        uint256 gasBefore = gasleft();
        (bool success, bytes memory returnData) = target.call(callData);
        uint256 gasAfter = gasleft();

        r.gasStart = gasBefore;
        r.gasEnd = gasAfter;
        r.gasUsed = gasBefore - gasAfter;
        r.success = success;
        r.returnData = returnData;
    }

    function measureWithValue(string memory label, address target, bytes memory callData, uint256 value)
        internal
        returns (GasReport memory r)
    {
        r.label = label;
        r.timestamp = block.timestamp;
        r.blockNumber = block.number;

        uint256 gasBefore = gasleft();
        (bool success, bytes memory returnData) = target.call{value: value}(callData);
        uint256 gasAfter = gasleft();

        r.gasStart = gasBefore;
        r.gasEnd = gasAfter;
        r.gasUsed = gasBefore - gasAfter;
        r.success = success;
        r.returnData = returnData;
    }

    function measureStatic(string memory label, address target, bytes memory callData)
        internal
        view
        returns (GasReport memory r)
    {
        r.label = label;
        r.timestamp = block.timestamp;
        r.blockNumber = block.number;

        uint256 gasBefore = gasleft();
        (bool success, bytes memory returnData) = target.staticcall(callData);
        uint256 gasAfter = gasleft();

        r.gasStart = gasBefore;
        r.gasEnd = gasAfter;
        r.gasUsed = gasBefore - gasAfter;
        r.success = success;
        r.returnData = returnData;
    }

    // ═══════════════════════════════════════════════════════════════════════
    // COMPARISON
    // ═══════════════════════════════════════════════════════════════════════

    function compare(GasReport memory a, GasReport memory b) internal pure returns (GasComparison memory c) {
        c.labelA = a.label;
        c.labelB = b.label;
        c.gasA = a.gasUsed;
        c.gasB = b.gasUsed;
        c.difference = int256(a.gasUsed) - int256(b.gasUsed);
        c.aIsCheaper = a.gasUsed < b.gasUsed;

        // Calculate percent difference in basis points
        if (b.gasUsed > 0) {
            c.percentDifference = (c.difference * 10000) / int256(b.gasUsed);
        }
    }

    function assertGasLessThan(GasReport memory r, uint256 maxGas) internal pure {
        if (r.gasUsed > maxGas) {
            revert(
                string.concat(
                    "Gas assertion failed for '",
                    r.label,
                    "': used ",
                    vm.toString(r.gasUsed),
                    " gas, max allowed ",
                    vm.toString(maxGas)
                )
            );
        }
    }

    function assertGasLessThan(GasReport memory a, GasReport memory b) internal pure {
        if (a.gasUsed >= b.gasUsed) {
            revert(
                string.concat(
                    "Gas assertion failed: '",
                    a.label,
                    "' (",
                    vm.toString(a.gasUsed),
                    ") should use less gas than '",
                    b.label,
                    "' (",
                    vm.toString(b.gasUsed),
                    ")"
                )
            );
        }
    }

    function assertGasWithinPercent(GasReport memory r, uint256 baseline, uint256 maxPercentDiff) internal pure {
        uint256 diff;
        if (r.gasUsed > baseline) {
            diff = r.gasUsed - baseline;
        } else {
            diff = baseline - r.gasUsed;
        }

        uint256 percentDiff = (diff * 100) / baseline;
        if (percentDiff > maxPercentDiff) {
            revert(
                string.concat(
                    "Gas assertion failed for '",
                    r.label,
                    "': ",
                    vm.toString(percentDiff),
                    "% deviation from baseline (",
                    vm.toString(baseline),
                    "), max allowed ",
                    vm.toString(maxPercentDiff),
                    "%"
                )
            );
        }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // BENCHMARKING
    // ═══════════════════════════════════════════════════════════════════════

    function benchmark(string memory name, address target, bytes memory callData, uint256 iterations)
        internal
        returns (GasBenchmark memory b)
    {
        b.name = name;
        b.samples = new GasReport[](iterations);
        b.minGas = type(uint256).max;
        b.maxGas = 0;

        uint256 totalGas = 0;

        // Take snapshots so each iteration starts from same state
        uint256 snapshotId = vm.snapshotState();

        for (uint256 i = 0; i < iterations; i++) {
            GasReport memory r = measure(string.concat(name, "_", vm.toString(i)), target, callData);
            b.samples[i] = r;

            totalGas += r.gasUsed;
            if (r.gasUsed < b.minGas) b.minGas = r.gasUsed;
            if (r.gasUsed > b.maxGas) b.maxGas = r.gasUsed;

            // Restore state for next iteration
            if (i < iterations - 1) {
                vm.revertToState(snapshotId);
                snapshotId = vm.snapshotState();
            }
        }

        b.avgGas = totalGas / iterations;
        b.medianGas = findMedian(b.samples);
        b.stdDev = calculateStdDev(b.samples, b.avgGas);
    }

    function findMedian(GasReport[] memory samples) internal pure returns (uint256) {
        if (samples.length == 0) return 0;
        if (samples.length == 1) return samples[0].gasUsed;

        // Simple bubble sort for small arrays
        uint256[] memory values = new uint256[](samples.length);
        for (uint256 i = 0; i < samples.length; i++) {
            values[i] = samples[i].gasUsed;
        }

        for (uint256 i = 0; i < values.length - 1; i++) {
            for (uint256 j = 0; j < values.length - i - 1; j++) {
                if (values[j] > values[j + 1]) {
                    (values[j], values[j + 1]) = (values[j + 1], values[j]);
                }
            }
        }

        if (values.length % 2 == 0) {
            return (values[values.length / 2 - 1] + values[values.length / 2]) / 2;
        } else {
            return values[values.length / 2];
        }
    }

    function calculateStdDev(GasReport[] memory samples, uint256 mean) internal pure returns (uint256) {
        if (samples.length <= 1) return 0;

        uint256 sumSquaredDiffs = 0;
        for (uint256 i = 0; i < samples.length; i++) {
            uint256 diff = samples[i].gasUsed > mean ? samples[i].gasUsed - mean : mean - samples[i].gasUsed;
            sumSquaredDiffs += diff * diff;
        }

        return sqrt(sumSquaredDiffs / samples.length);
    }

    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // FORMATTING
    // ═══════════════════════════════════════════════════════════════════════

    function format(GasReport memory r) internal pure returns (string memory) {
        return string.concat(
            r.label,
            ": ",
            vm.toString(r.gasUsed),
            " gas",
            r.success ? "" : " [FAILED]"
        );
    }

    function format(GasComparison memory c) internal pure returns (string memory) {
        string memory sign = c.difference >= 0 ? "+" : "";
        return string.concat(
            c.labelA,
            " vs ",
            c.labelB,
            ": ",
            sign,
            vm.toString(uint256(c.difference >= 0 ? c.difference : -c.difference)),
            " gas (",
            sign,
            vm.toString(uint256(c.percentDifference >= 0 ? c.percentDifference : -c.percentDifference) / 100),
            ".",
            vm.toString(uint256(c.percentDifference >= 0 ? c.percentDifference : -c.percentDifference) % 100),
            "%)"
        );
    }

    function format(GasBenchmark memory b) internal pure returns (string memory) {
        return string.concat(
            "Benchmark: ",
            b.name,
            "\n  Samples: ",
            vm.toString(b.samples.length),
            "\n  Min: ",
            vm.toString(b.minGas),
            "\n  Max: ",
            vm.toString(b.maxGas),
            "\n  Avg: ",
            vm.toString(b.avgGas),
            "\n  Median: ",
            vm.toString(b.medianGas),
            "\n  StdDev: ",
            vm.toString(b.stdDev)
        );
    }

    // ═══════════════════════════════════════════════════════════════════════
    // LOGGING
    // ═══════════════════════════════════════════════════════════════════════

    function log(GasReport memory r) internal pure {
        console.logString(format(r));
    }

    function log(GasComparison memory c) internal pure {
        console.logString(format(c));
    }

    function log(GasBenchmark memory b) internal pure {
        console.logString(format(b));
    }
}

/// @notice Global gas profiling entry point
library gas {
    function profile(string memory label) internal view returns (GasProfile memory) {
        return GasLib.profile(label);
    }

    function endProfile(GasProfile memory p) internal view returns (GasReport memory) {
        return GasLib.endProfile(p);
    }

    function measure(string memory label, address target, bytes memory callData)
        internal
        returns (GasReport memory)
    {
        return GasLib.measure(label, target, callData);
    }

    function compare(GasReport memory a, GasReport memory b) internal pure returns (GasComparison memory) {
        return GasLib.compare(a, b);
    }

    function benchmark(string memory name, address target, bytes memory callData, uint256 iterations)
        internal
        returns (GasBenchmark memory)
    {
        return GasLib.benchmark(name, target, callData, iterations);
    }
}
