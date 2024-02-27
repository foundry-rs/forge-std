// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

library stdMath {
    // Minimum value of int256
    int256 private constant INT256_MIN = -57896044618658097711785492504343953926634992332820282019728792003956564819968;

    // Returns the absolute value of an int256 number
    function abs(int256 a) internal pure returns (uint256) {
        // Required for handling INT256_MIN
        if (a == INT256_MIN) {
            return 57896044618658097711785492504343953926634992332820282019728792003956564819968;
        }

        return uint256(a > 0 ? a : -a);
    }

    // Returns the absolute difference between two uint256 numbers
    function delta(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a - b : b - a;
    }

    // Returns the absolute difference between two int256 numbers
    function delta(int256 a, int256 b) internal pure returns (uint256) {
        // If a and b have the same sign, return the absolute difference
        if ((a ^ b) > -1) {
            return delta(abs(a), abs(b));
        }

        // If a and b have opposite signs, return the sum of their absolute values
        return abs(a) + abs(b);
    }

    // Returns the percentage difference between two uint256 numbers
    function percentDelta(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 absDelta = delta(a, b);

        // Calculate the percentage difference
        return absDelta * 1e18 / b;
    }

    // Returns the percentage difference between two int256 numbers
    function percentDelta(int256 a, int256 b) internal pure returns (uint256) {
        uint256 absDelta = delta(a, b);
        uint256 absB = abs(b);

        // Calculate the percentage difference
        return absDelta * 1e18 / absB;
    }
}

