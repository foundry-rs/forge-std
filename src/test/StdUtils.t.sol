// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "../Test.sol";

contract StdUtilsTest is Test {
    function testBound() public {
        assertEq(bound(5, 0, 4), 0);
        assertEq(bound(0, 69, 69), 69);
        assertEq(bound(0, 68, 69), 68);
        assertEq(bound(10, 150, 190), 160);
        assertEq(bound(300, 2800, 3200), 3100);
        assertEq(bound(9999, 1337, 6666), 6006);
    }

    function testBound(
        uint256 num,
        uint256 min,
        uint256 max
    ) public {
        if (min > max) (min, max) = (max, min);

        uint256 bounded = bound(num, min, max);

        assertGe(bounded, min);
        assertLe(bounded, max);
    }

    function testBoundUint256Max() public {
        assertEq(bound(0, type(uint256).max - 1, type(uint256).max), type(uint256).max - 1);
        assertEq(bound(1, type(uint256).max - 1, type(uint256).max), type(uint256).max);
    }


    function testCannotBoundMaxLessThanMin() public {
        vm.expectRevert(bytes("Test bound(uint256,uint256,uint256): Max is less than min."));
        bound(5, 100, 10);
    }

    function testCannotBoundMaxLessThanMin(
        uint256 num,
        uint256 min,
        uint256 max
    ) public {
        vm.assume(min > max);
        vm.expectRevert(bytes("Test bound(uint256,uint256,uint256): Max is less than min."));
        bound(num, min, max);
    }
}