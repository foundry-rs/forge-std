// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

library stdMath {
    int256 private constant INT256_MIN = -57896044618658097711785492504343953926634992332820282019728792003956564819968;

    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        // Compute floor(x * y / denominator) with full 512-bit precision to avoid overflow.
        // This implementation is adapted from well-known public domain algorithms
        // (e.g., Uniswap v3 FullMath / OpenZeppelin Math.mulDiv).
        assembly {
            let mm := mulmod(x, y, not(0))
            let prod0 := mul(x, y)
            let prod1 := sub(sub(mm, prod0), lt(mm, prod0))

            // If the high 256 bits are zero, we can perform a standard division.
            if iszero(prod1) {
                result := div(prod0, denominator)
                leave
            }

            // Ensure the result is less than 2^256. Also prevents denominator == 0.
            if iszero(gt(denominator, prod1)) { revert(0, 0) }

            // Make division exact by subtracting the remainder from [prod1 prod0].
            let remainder := mulmod(x, y, denominator)
            prod1 := sub(prod1, gt(remainder, prod0))
            prod0 := sub(prod0, remainder)

            // Factor powers of two out of denominator and compute largest power-of-two divisor.
            let twos := and(denominator, sub(0, denominator))
            denominator := div(denominator, twos)

            // Divide [prod1 prod0] by the factors of two.
            prod0 := div(prod0, twos)
            twos := add(div(sub(0, twos), twos), 1)
            prod0 := or(prod0, mul(prod1, twos))

            // Compute the modular inverse of the denominator modulo 2^256.
            // Newton-Raphson iteration to improve the precision.
            let inv := mul(3, denominator)
            inv := xor(inv, 2)
            inv := mul(inv, sub(2, mul(denominator, inv)))
            inv := mul(inv, sub(2, mul(denominator, inv)))
            inv := mul(inv, sub(2, mul(denominator, inv)))
            inv := mul(inv, sub(2, mul(denominator, inv)))
            inv := mul(inv, sub(2, mul(denominator, inv)))
            inv := mul(inv, sub(2, mul(denominator, inv)))

            // Multiply by the modular inverse to perform the division.
            result := mul(prod0, inv)
        }
    }

    function abs(int256 a) internal pure returns (uint256) {
        // Required or it will fail when `a = type(int256).min`
        if (a == INT256_MIN) {
            return 57896044618658097711785492504343953926634992332820282019728792003956564819968;
        }

        return uint256(a > 0 ? a : -a);
    }

    function delta(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a - b : b - a;
    }

    function delta(int256 a, int256 b) internal pure returns (uint256) {
        // a and b are of the same sign
        // this works thanks to two's complement, the left-most bit is the sign bit
        if ((a ^ b) > -1) {
            return delta(abs(a), abs(b));
        }

        // a and b are of opposite signs
        return abs(a) + abs(b);
    }

    function percentDelta(uint256 a, uint256 b) internal pure returns (uint256) {
        // Prevent division by zero
        require(b != 0, "stdMath percentDelta(uint256,uint256): Divisor is zero");
        uint256 absDelta = delta(a, b);

        return mulDiv(absDelta, 1e18, b);
    }

    function percentDelta(int256 a, int256 b) internal pure returns (uint256) {
        uint256 absDelta = delta(a, b);
        uint256 absB = abs(b);
        // Prevent division by zero
        require(absB != 0, "stdMath percentDelta(int256,int256): Divisor is zero");

        return mulDiv(absDelta, 1e18, absB);
    }
}
