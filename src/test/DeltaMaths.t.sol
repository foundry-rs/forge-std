// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.10;

import "../Test.sol";

contract DeltaMathsTest is Test
{
    function testGetAbs() external {
        assertEq(deltaMaths.abs(-50),   50);
        assertEq(deltaMaths.abs(50),    50);
        assertEq(deltaMaths.abs(-1337), 1337);
        assertEq(deltaMaths.abs(0),     0);

        assertEq(deltaMaths.abs(type(int256).min), (type(uint256).max >> 1) + 1);
        assertEq(deltaMaths.abs(type(int256).max), (type(uint256).max >> 1));
    }

    function testGetAbs_Fuzz(int256 a) external {
        uint256 manualAbs = getAbs(a);

        uint256 abs = deltaMaths.abs(a);

        assertEq(abs, manualAbs);
    }

    function testGetDelta_Uint() external {
        assertEq(deltaMaths.getDelta(uint256(0),        uint256(0)),        0);
        assertEq(deltaMaths.getDelta(uint256(0),        uint256(1337)),     1337);
        assertEq(deltaMaths.getDelta(uint256(0),        type(uint64).max),  type(uint64).max);
        assertEq(deltaMaths.getDelta(uint256(0),        type(uint128).max), type(uint128).max);
        assertEq(deltaMaths.getDelta(uint256(0),        type(uint256).max), type(uint256).max);

        assertEq(deltaMaths.getDelta(0,                 uint256(0)),        0);
        assertEq(deltaMaths.getDelta(1337,              uint256(0)),        1337);
        assertEq(deltaMaths.getDelta(type(uint64).max,  uint256(0)),        type(uint64).max);
        assertEq(deltaMaths.getDelta(type(uint128).max, uint256(0)),        type(uint128).max);
        assertEq(deltaMaths.getDelta(type(uint256).max, uint256(0)),        type(uint256).max);

        assertEq(deltaMaths.getDelta(1337,              uint256(1337)),     0);
        assertEq(deltaMaths.getDelta(type(uint256).max, type(uint256).max), 0);
        assertEq(deltaMaths.getDelta(5000,              uint256(1250)),     3750);
    }

    function testGetDelta_Uint_Fuzz(uint256 a, uint256 b) external {
        uint256 manualDelta;
        if (a > b) {
            manualDelta = a - b;
        } else {
            manualDelta = b - a;
        }

        uint256 delta = deltaMaths.getDelta(a, b);

        assertEq(delta, manualDelta);
    }

    function testGetDelta_Int() external {
        assertEq(deltaMaths.getDelta(int256(0),         int256(0)),         0);
        assertEq(deltaMaths.getDelta(int256(0),         int256(1337)),      1337);
        assertEq(deltaMaths.getDelta(int256(0),         type(int64).max),   type(uint64).max >> 1);
        assertEq(deltaMaths.getDelta(int256(0),         type(int128).max),  type(uint128).max >> 1);
        assertEq(deltaMaths.getDelta(int256(0),         type(int256).max),  type(uint256).max >> 1);

        assertEq(deltaMaths.getDelta(0,                 int256(0)),         0);
        assertEq(deltaMaths.getDelta(1337,              int256(0)),         1337);
        assertEq(deltaMaths.getDelta(type(int64).max,   int256(0)),         type(uint64).max >> 1);
        assertEq(deltaMaths.getDelta(type(int128).max,  int256(0)),         type(uint128).max >> 1);
        assertEq(deltaMaths.getDelta(type(int256).max,  int256(0)),         type(uint256).max >> 1);

        assertEq(deltaMaths.getDelta(-0,                int256(0)),         0);
        assertEq(deltaMaths.getDelta(-1337,             int256(0)),         1337);
        assertEq(deltaMaths.getDelta(type(int64).min,   int256(0)),         (type(uint64).max >> 1) + 1);
        assertEq(deltaMaths.getDelta(type(int128).min,  int256(0)),         (type(uint128).max >> 1) + 1);
        assertEq(deltaMaths.getDelta(type(int256).min,  int256(0)),         (type(uint256).max >> 1) + 1);

        assertEq(deltaMaths.getDelta(int256(0),         -0),                0);
        assertEq(deltaMaths.getDelta(int256(0),         -1337),             1337);
        assertEq(deltaMaths.getDelta(int256(0),         type(int64).min),   (type(uint64).max >> 1) + 1);
        assertEq(deltaMaths.getDelta(int256(0),         type(int128).min),  (type(uint128).max >> 1) + 1);
        assertEq(deltaMaths.getDelta(int256(0),         type(int256).min),  (type(uint256).max >> 1) + 1);

        assertEq(deltaMaths.getDelta(1337,              int256(1337)),      0);
        assertEq(deltaMaths.getDelta(type(int256).max,  type(int256).max),  0);
        assertEq(deltaMaths.getDelta(type(int256).min,  type(int256).min),  0);
        assertEq(deltaMaths.getDelta(type(int256).min,  type(int256).max),  type(uint256).max);
        assertEq(deltaMaths.getDelta(5000,              int256(1250)),      3750);
    }

    function testGetDelta_Int_Fuzz(int256 a, int256 b) external {
        uint256 absA = getAbs(a);
        uint256 absB = getAbs(b);
        uint256 absDelta = absA > absB
            ? absA - absB
            : absB - absA;

        uint256 manualDelta;
        if ((a >= 0 && b >= 0) || (a < 0 && b < 0)) {
            manualDelta = absDelta;
        }
        // (a < 0 && b >= 0) || (a >= 0 && b < 0)
        else {
            manualDelta = absA + absB;
        }

        uint256 delta = deltaMaths.getDelta(a, b);

        assertEq(delta, manualDelta);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                   HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function getAbs(int256 a) private pure returns (uint256) {
        if (a < 0)
            return a == type(int256).min ? uint256(type(int256).max) + 1 : uint256(-a);

        return uint256(a);
    }
}
