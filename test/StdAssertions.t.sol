// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "../src/StdAssertions.sol";
import {Vm} from "../src/Vm.sol";

interface VmInternal is Vm {
    function _expectCheatcodeRevert(bytes memory message) external;
}

contract StdAssertionsTest is StdAssertions {
    string constant errorMessage = "User provided message";
    uint256 constant maxDecimals = 77;

    bool constant SHOULD_REVERT = true;
    bool constant SHOULD_RETURN = false;

    bool constant STRICT_REVERT_DATA = true;
    bool constant NON_STRICT_REVERT_DATA = false;

    VmInternal constant vm = VmInternal(address(uint160(uint256(keccak256("hevm cheat code")))));

    function _abs(int256 a) internal pure returns (uint256) {
        // Required or it will fail when `a = type(int256).min`
        if (a == type(int256).min) {
            return uint256(type(int256).max) + 1;
        }

        return uint256(a > 0 ? a : -a);
    }

    function _getDelta(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a - b : b - a;
    }

    function _getDelta(int256 a, int256 b) internal pure returns (uint256) {
        // a and b are of the same sign
        // this works thanks to two's complement, the left-most bit is the sign bit
        if ((a ^ b) > -1) {
            return _getDelta(_abs(a), _abs(b));
        }

        // a and b are of opposite signs
        return _abs(a) + _abs(b);
    }

    function _prefixDecWithZeroes(string memory intPart, string memory decimalPart, uint256 decimals)
        internal
        pure
        returns (string memory)
    {
        while (bytes(decimalPart).length < decimals) {
            decimalPart = string.concat("0", decimalPart);
        }

        return string.concat(intPart, ".", decimalPart);
    }

    function _formatWithDecimals(uint256 value, uint256 decimals) internal pure returns (string memory) {
        string memory intPart = vm.toString(value / (10 ** decimals));
        string memory decimalPart = vm.toString(value % (10 ** decimals));

        return _prefixDecWithZeroes(intPart, decimalPart, decimals);
    }

    function _formatWithDecimals(int256 value, uint256 decimals) internal pure returns (string memory) {
        string memory intPart = vm.toString(value / int256(10 ** decimals));
        int256 mod = value % int256(10 ** decimals);
        string memory decimalPart = vm.toString(mod > 0 ? mod : -mod);

        // Add - if we have something like 0.123
        if ((value < 0) && keccak256(abi.encode(intPart)) == keccak256(abi.encode("0"))) {
            intPart = string.concat("-", intPart);
        }

        return _prefixDecWithZeroes(intPart, decimalPart, decimals);
    }

    function testFuzzAssertEqNotEq(uint256 left, uint256 right, uint256 decimals) public {
        vm.assume(left != right);
        vm.assume(decimals <= maxDecimals);

        assertEq(left, left);
        assertEq(right, right);
        assertNotEq(left, right);
        assertNotEq(right, left);

        vm._expectCheatcodeRevert(
            bytes(string.concat(errorMessage, ": ", vm.toString(left), " != ", vm.toString(right)))
        );
        assertEq(left, right, errorMessage);

        vm._expectCheatcodeRevert(
            bytes(string.concat(errorMessage, ": ", vm.toString(left), " == ", vm.toString(left)))
        );
        assertNotEq(left, left, errorMessage);

        vm._expectCheatcodeRevert(
            bytes(
                string.concat(
                    "assertion failed: ",
                    _formatWithDecimals(left, decimals),
                    " != ",
                    _formatWithDecimals(right, decimals)
                )
            )
        );
        assertEqDecimal(left, right, decimals);

        vm._expectCheatcodeRevert(
            bytes(
                string.concat(
                    "assertion failed: ",
                    _formatWithDecimals(left, decimals),
                    " == ",
                    _formatWithDecimals(left, decimals)
                )
            )
        );
        assertNotEqDecimal(left, left, decimals);
    }

    function testFuzzAssertEqNotEq(int256 left, int256 right, uint256 decimals) public {
        vm.assume(left != right);
        vm.assume(decimals <= maxDecimals);

        assertEq(left, left);
        assertEq(right, right);
        assertNotEq(left, right);
        assertNotEq(right, left);

        vm._expectCheatcodeRevert(
            bytes(string.concat(errorMessage, ": ", vm.toString(left), " != ", vm.toString(right)))
        );
        assertEq(left, right, errorMessage);

        vm._expectCheatcodeRevert(
            bytes(string.concat(errorMessage, ": ", vm.toString(left), " == ", vm.toString(left)))
        );
        assertNotEq(left, left, errorMessage);

        vm._expectCheatcodeRevert(
            bytes(
                string.concat(
                    errorMessage,
                    ": ",
                    _formatWithDecimals(left, decimals),
                    " != ",
                    _formatWithDecimals(right, decimals)
                )
            )
        );
        assertEqDecimal(left, right, decimals, errorMessage);

        vm._expectCheatcodeRevert(
            bytes(
                string.concat(
                    errorMessage, ": ", _formatWithDecimals(left, decimals), " == ", _formatWithDecimals(left, decimals)
                )
            )
        );
        assertNotEqDecimal(left, left, decimals, errorMessage);
    }

    function testFuzzAssertEqNotEq(bool left, bool right) public {
        vm.assume(left != right);

        assertEq(left, left);
        assertEq(right, right);
        assertNotEq(left, right);
        assertNotEq(right, left);

        vm._expectCheatcodeRevert(
            bytes(string.concat(errorMessage, ": ", vm.toString(left), " != ", vm.toString(right)))
        );
        assertEq(left, right, errorMessage);

        vm._expectCheatcodeRevert(
            bytes(string.concat(errorMessage, ": ", vm.toString(left), " == ", vm.toString(left)))
        );
        assertNotEq(left, left, errorMessage);
    }

    function testFuzzAssertEqNotEq(address left, address right) public {
        vm.assume(left != right);

        assertEq(left, left);
        assertEq(right, right);
        assertNotEq(left, right);
        assertNotEq(right, left);

        vm._expectCheatcodeRevert(
            bytes(string.concat(errorMessage, ": ", vm.toString(left), " != ", vm.toString(right)))
        );
        assertEq(left, right, errorMessage);

        vm._expectCheatcodeRevert(
            bytes(string.concat(errorMessage, ": ", vm.toString(left), " == ", vm.toString(left)))
        );
        assertNotEq(left, left, errorMessage);
    }

    function testFuzzAssertEqNotEq(bytes32 left, bytes32 right) public {
        vm.assume(left != right);

        assertEq(left, left);
        assertEq(right, right);
        assertNotEq(left, right);
        assertNotEq(right, left);

        vm._expectCheatcodeRevert(
            bytes(string.concat(errorMessage, ": ", vm.toString(left), " != ", vm.toString(right)))
        );
        assertEq(left, right, errorMessage);

        vm._expectCheatcodeRevert(
            bytes(string.concat(errorMessage, ": ", vm.toString(left), " == ", vm.toString(left)))
        );
        assertNotEq(left, left, errorMessage);
    }

    function testFuzzAssertEqNotEq(string memory left, string memory right) public {
        vm.assume(keccak256(abi.encodePacked(left)) != keccak256(abi.encodePacked(right)));

        assertEq(left, left);
        assertEq(right, right);
        assertNotEq(left, right);
        assertNotEq(right, left);

        vm._expectCheatcodeRevert(bytes(string.concat(errorMessage, ": ", left, " != ", right)));
        assertEq(left, right, errorMessage);

        vm._expectCheatcodeRevert(bytes(string.concat(errorMessage, ": ", left, " == ", left)));
        assertNotEq(left, left, errorMessage);
    }

    function testFuzzAssertEqNotEq(bytes memory left, bytes memory right) public {
        vm.assume(keccak256(left) != keccak256(right));

        assertEq(left, left);
        assertEq(right, right);
        assertNotEq(left, right);
        assertNotEq(right, left);

        vm._expectCheatcodeRevert(
            bytes(string.concat(errorMessage, ": ", vm.toString(left), " != ", vm.toString(right)))
        );
        assertEq(left, right, errorMessage);

        vm._expectCheatcodeRevert(
            bytes(string.concat(errorMessage, ": ", vm.toString(left), " == ", vm.toString(left)))
        );
        assertNotEq(left, left, errorMessage);
    }

    function testFuzzAssertGtLt(uint256 left, uint256 right, uint256 decimals) public {
        vm.assume(left < right);
        vm.assume(decimals <= maxDecimals);

        assertGt(right, left);
        assertLt(left, right);

        vm._expectCheatcodeRevert(
            bytes(string.concat(errorMessage, ": ", vm.toString(left), " <= ", vm.toString(right)))
        );
        assertGt(left, right, errorMessage);

        vm._expectCheatcodeRevert(
            bytes(string.concat(errorMessage, ": ", vm.toString(right), " <= ", vm.toString(right)))
        );
        assertGt(right, right, errorMessage);

        vm._expectCheatcodeRevert(
            bytes(string.concat(errorMessage, ": ", vm.toString(left), " >= ", vm.toString(left)))
        );
        assertLt(left, left, errorMessage);

        vm._expectCheatcodeRevert(
            bytes(string.concat(errorMessage, ": ", vm.toString(right), " >= ", vm.toString(left)))
        );
        assertLt(right, left, errorMessage);

        vm._expectCheatcodeRevert(
            bytes(
                string.concat(
                    "assertion failed: ",
                    _formatWithDecimals(left, decimals),
                    " <= ",
                    _formatWithDecimals(right, decimals)
                )
            )
        );
        assertGtDecimal(left, right, decimals);

        vm._expectCheatcodeRevert(
            bytes(
                string.concat(
                    "assertion failed: ",
                    _formatWithDecimals(right, decimals),
                    " <= ",
                    _formatWithDecimals(right, decimals)
                )
            )
        );
        assertGtDecimal(right, right, decimals);

        vm._expectCheatcodeRevert(
            bytes(
                string.concat(
                    "assertion failed: ",
                    _formatWithDecimals(left, decimals),
                    " >= ",
                    _formatWithDecimals(left, decimals)
                )
            )
        );
        assertLtDecimal(left, left, decimals);

        vm._expectCheatcodeRevert(
            bytes(
                string.concat(
                    "assertion failed: ",
                    _formatWithDecimals(right, decimals),
                    " >= ",
                    _formatWithDecimals(left, decimals)
                )
            )
        );
        assertLtDecimal(right, left, decimals);
    }

    function testFuzzAssertGtLt(int256 left, int256 right, uint256 decimals) public {
        vm.assume(left < right);
        vm.assume(decimals <= maxDecimals);

        assertGt(right, left);
        assertLt(left, right);

        vm._expectCheatcodeRevert(
            bytes(string.concat(errorMessage, ": ", vm.toString(left), " <= ", vm.toString(right)))
        );
        assertGt(left, right, errorMessage);

        vm._expectCheatcodeRevert(
            bytes(string.concat(errorMessage, ": ", vm.toString(right), " <= ", vm.toString(right)))
        );
        assertGt(right, right, errorMessage);

        vm._expectCheatcodeRevert(
            bytes(string.concat(errorMessage, ": ", vm.toString(left), " >= ", vm.toString(left)))
        );
        assertLt(left, left, errorMessage);

        vm._expectCheatcodeRevert(
            bytes(string.concat(errorMessage, ": ", vm.toString(right), " >= ", vm.toString(left)))
        );
        assertLt(right, left, errorMessage);

        vm._expectCheatcodeRevert(
            bytes(
                string.concat(
                    "assertion failed: ",
                    _formatWithDecimals(left, decimals),
                    " <= ",
                    _formatWithDecimals(right, decimals)
                )
            )
        );
        assertGtDecimal(left, right, decimals);

        vm._expectCheatcodeRevert(
            bytes(
                string.concat(
                    "assertion failed: ",
                    _formatWithDecimals(right, decimals),
                    " <= ",
                    _formatWithDecimals(right, decimals)
                )
            )
        );
        assertGtDecimal(right, right, decimals);

        vm._expectCheatcodeRevert(
            bytes(
                string.concat(
                    "assertion failed: ",
                    _formatWithDecimals(left, decimals),
                    " >= ",
                    _formatWithDecimals(left, decimals)
                )
            )
        );
        assertLtDecimal(left, left, decimals);

        vm._expectCheatcodeRevert(
            bytes(
                string.concat(
                    "assertion failed: ",
                    _formatWithDecimals(right, decimals),
                    " >= ",
                    _formatWithDecimals(left, decimals)
                )
            )
        );
        assertLtDecimal(right, left, decimals);
    }

    function testFuzzAssertGeLe(uint256 left, uint256 right, uint256 decimals) public {
        vm.assume(left < right);
        vm.assume(decimals <= maxDecimals);

        assertGe(left, left);
        assertLe(left, left);
        assertGe(right, right);
        assertLe(right, right);
        assertGe(right, left);
        assertLe(left, right);

        vm._expectCheatcodeRevert(
            bytes(string.concat(errorMessage, ": ", vm.toString(left), " < ", vm.toString(right)))
        );
        assertGe(left, right, errorMessage);

        vm._expectCheatcodeRevert(
            bytes(string.concat(errorMessage, ": ", vm.toString(right), " > ", vm.toString(left)))
        );
        assertLe(right, left, errorMessage);

        vm._expectCheatcodeRevert(
            bytes(
                string.concat(
                    "assertion failed: ",
                    _formatWithDecimals(left, decimals),
                    " < ",
                    _formatWithDecimals(right, decimals)
                )
            )
        );
        assertGeDecimal(left, right, decimals);

        vm._expectCheatcodeRevert(
            bytes(
                string.concat(
                    "assertion failed: ",
                    _formatWithDecimals(right, decimals),
                    " > ",
                    _formatWithDecimals(left, decimals)
                )
            )
        );
        assertLeDecimal(right, left, decimals);
    }

    function testFuzzAssertGeLe(int256 left, int256 right, uint256 decimals) public {
        vm.assume(left < right);
        vm.assume(decimals <= maxDecimals);

        assertGe(left, left);
        assertLe(left, left);
        assertGe(right, right);
        assertLe(right, right);
        assertGe(right, left);
        assertLe(left, right);

        vm._expectCheatcodeRevert(
            bytes(string.concat(errorMessage, ": ", vm.toString(left), " < ", vm.toString(right)))
        );
        assertGe(left, right, errorMessage);

        vm._expectCheatcodeRevert(
            bytes(string.concat(errorMessage, ": ", vm.toString(right), " > ", vm.toString(left)))
        );
        assertLe(right, left, errorMessage);

        vm._expectCheatcodeRevert(
            bytes(
                string.concat(
                    "assertion failed: ",
                    _formatWithDecimals(left, decimals),
                    " < ",
                    _formatWithDecimals(right, decimals)
                )
            )
        );
        assertGeDecimal(left, right, decimals);

        vm._expectCheatcodeRevert(
            bytes(
                string.concat(
                    "assertion failed: ",
                    _formatWithDecimals(right, decimals),
                    " > ",
                    _formatWithDecimals(left, decimals)
                )
            )
        );
        assertLeDecimal(right, left, decimals);
    }

    function testFuzzAssertApproxEqAbs(uint256 left, uint256 right, uint256 decimals) public {
        uint256 delta = _getDelta(right, left);
        vm.assume(decimals <= maxDecimals);

        assertApproxEqAbs(left, right, delta);

        if (delta > 0) {
            vm._expectCheatcodeRevert(
                bytes(
                    string.concat(
                        errorMessage,
                        ": ",
                        vm.toString(left),
                        " !~= ",
                        vm.toString(right),
                        " (max delta: ",
                        vm.toString(delta - 1),
                        ", real delta: ",
                        vm.toString(delta),
                        ")"
                    )
                )
            );
            assertApproxEqAbs(left, right, delta - 1, errorMessage);

            vm._expectCheatcodeRevert(
                bytes(
                    string.concat(
                        "assertion failed: ",
                        _formatWithDecimals(left, decimals),
                        " !~= ",
                        _formatWithDecimals(right, decimals),
                        " (max delta: ",
                        _formatWithDecimals(delta - 1, decimals),
                        ", real delta: ",
                        _formatWithDecimals(delta, decimals),
                        ")"
                    )
                )
            );
            assertApproxEqAbsDecimal(left, right, delta - 1, decimals);
        }
    }

    function testFuzzAssertApproxEqAbs(int256 left, int256 right, uint256 decimals) public {
        uint256 delta = _getDelta(right, left);
        vm.assume(decimals <= maxDecimals);

        assertApproxEqAbs(left, right, delta);

        if (delta > 0) {
            vm._expectCheatcodeRevert(
                bytes(
                    string.concat(
                        errorMessage,
                        ": ",
                        vm.toString(left),
                        " !~= ",
                        vm.toString(right),
                        " (max delta: ",
                        vm.toString(delta - 1),
                        ", real delta: ",
                        vm.toString(delta),
                        ")"
                    )
                )
            );
            assertApproxEqAbs(left, right, delta - 1, errorMessage);

            vm._expectCheatcodeRevert(
                bytes(
                    string.concat(
                        "assertion failed: ",
                        _formatWithDecimals(left, decimals),
                        " !~= ",
                        _formatWithDecimals(right, decimals),
                        " (max delta: ",
                        _formatWithDecimals(delta - 1, decimals),
                        ", real delta: ",
                        _formatWithDecimals(delta, decimals),
                        ")"
                    )
                )
            );
            assertApproxEqAbsDecimal(left, right, delta - 1, decimals);
        }
    }

    function testFuzzAssertApproxEqRel(uint256 left, uint256 right, uint256 decimals) public {
        vm.assume(right != 0);
        uint256 delta = _getDelta(right, left);
        vm.assume(delta < type(uint256).max / (10 ** 18));
        vm.assume(decimals <= maxDecimals);

        uint256 percentDelta = delta * (10 ** 18) / right;

        assertApproxEqRel(left, right, percentDelta);

        if (percentDelta > 0) {
            vm._expectCheatcodeRevert(
                bytes(
                    string.concat(
                        errorMessage,
                        ": ",
                        vm.toString(left),
                        " !~= ",
                        vm.toString(right),
                        " (max delta: ",
                        _formatWithDecimals(percentDelta - 1, 16),
                        "%, real delta: ",
                        _formatWithDecimals(percentDelta, 16),
                        "%)"
                    )
                )
            );
            assertApproxEqRel(left, right, percentDelta - 1, errorMessage);

            vm._expectCheatcodeRevert(
                bytes(
                    string.concat(
                        "assertion failed: ",
                        _formatWithDecimals(left, decimals),
                        " !~= ",
                        _formatWithDecimals(right, decimals),
                        " (max delta: ",
                        _formatWithDecimals(percentDelta - 1, 16),
                        "%, real delta: ",
                        _formatWithDecimals(percentDelta, 16),
                        "%)"
                    )
                )
            );
            assertApproxEqRelDecimal(left, right, percentDelta - 1, decimals);
        }
    }

    function testFuzzAssertApproxEqRel(int256 left, int256 right, uint256 decimals) public {
        vm.assume(left < right);
        vm.assume(right != 0);
        uint256 delta = _getDelta(right, left);
        vm.assume(delta < type(uint256).max / (10 ** 18));
        vm.assume(decimals <= maxDecimals);

        uint256 percentDelta = delta * (10 ** 18) / _abs(right);

        assertApproxEqRel(left, right, percentDelta);

        if (percentDelta > 0) {
            vm._expectCheatcodeRevert(
                bytes(
                    string.concat(
                        errorMessage,
                        ": ",
                        vm.toString(left),
                        " !~= ",
                        vm.toString(right),
                        " (max delta: ",
                        _formatWithDecimals(percentDelta - 1, 16),
                        "%, real delta: ",
                        _formatWithDecimals(percentDelta, 16),
                        "%)"
                    )
                )
            );
            assertApproxEqRel(left, right, percentDelta - 1, errorMessage);

            vm._expectCheatcodeRevert(
                bytes(
                    string.concat(
                        "assertion failed: ",
                        _formatWithDecimals(left, decimals),
                        " !~= ",
                        _formatWithDecimals(right, decimals),
                        " (max delta: ",
                        _formatWithDecimals(percentDelta - 1, 16),
                        "%, real delta: ",
                        _formatWithDecimals(percentDelta, 16),
                        "%)"
                    )
                )
            );
            assertApproxEqRelDecimal(left, right, percentDelta - 1, decimals);
        }
    }

    function testAssertEqNotEqArrays() public {
        {
            uint256[] memory arr1 = new uint256[](1);
            arr1[0] = 1;
            uint256[] memory arr2 = new uint256[](2);
            arr2[0] = 1;
            arr2[1] = 2;

            assertEq(arr1, arr1);
            assertEq(arr2, arr2);
            assertNotEq(arr1, arr2);

            vm._expectCheatcodeRevert(bytes("assertion failed: [1] != [1, 2]"));
            assertEq(arr1, arr2);

            vm._expectCheatcodeRevert(bytes(string.concat("assertion failed: [1, 2] == [1, 2]")));
            assertNotEq(arr2, arr2);
        }
        {
            int256[] memory arr1 = new int256[](2);
            int256[] memory arr2 = new int256[](1);
            arr1[0] = 5;
            arr2[0] = type(int256).max;

            assertEq(arr1, arr1);
            assertEq(arr2, arr2);
            assertNotEq(arr1, arr2);

            vm._expectCheatcodeRevert(bytes(string.concat(errorMessage, ": [5, 0] != [", vm.toString(arr2[0]), "]")));
            assertEq(arr1, arr2, errorMessage);

            vm._expectCheatcodeRevert(bytes(string.concat("assertion failed: [5, 0] == [5, 0]")));
            assertNotEq(arr1, arr1);
        }
        {
            bool[] memory arr1 = new bool[](2);
            bool[] memory arr2 = new bool[](2);
            arr1[0] = true;
            arr2[1] = true;

            assertEq(arr1, arr1);
            assertEq(arr2, arr2);
            assertNotEq(arr1, arr2);

            vm._expectCheatcodeRevert(bytes(string.concat(errorMessage, ": [true, false] != [false, true]")));
            assertEq(arr1, arr2, errorMessage);

            vm._expectCheatcodeRevert(bytes(string("assertion failed: [true, false] == [true, false]")));
            assertNotEq(arr1, arr1);
        }
        {
            address[] memory arr1 = new address[](1);
            address[] memory arr2 = new address[](0);

            assertEq(arr1, arr1);
            assertEq(arr2, arr2);
            assertNotEq(arr1, arr2);

            vm._expectCheatcodeRevert(bytes(string.concat(errorMessage, ": [", vm.toString(arr1[0]), "] != []")));
            assertEq(arr1, arr2, errorMessage);

            vm._expectCheatcodeRevert(bytes(string("assertion failed: [] == []")));
            assertNotEq(arr2, arr2);
        }
        {
            bytes32[] memory arr1 = new bytes32[](1);
            bytes32[] memory arr2 = new bytes32[](1);
            arr1[0] = bytes32(uint256(1));

            assertEq(arr1, arr1);
            assertEq(arr2, arr2);
            assertNotEq(arr1, arr2);

            vm._expectCheatcodeRevert(
                bytes(string.concat(errorMessage, ": [", vm.toString(arr1[0]), "] != [", vm.toString(arr2[0]), "]"))
            );
            assertEq(arr1, arr2, errorMessage);

            vm._expectCheatcodeRevert(
                bytes(string.concat("assertion failed: [", vm.toString(arr2[0]), "] == [", vm.toString(arr2[0]), "]"))
            );
            assertNotEq(arr2, arr2);
        }
        {
            string[] memory arr1 = new string[](1);
            string[] memory arr2 = new string[](3);

            arr1[0] = "foo";
            arr2[2] = "bar";

            assertEq(arr1, arr1);
            assertEq(arr2, arr2);
            assertNotEq(arr1, arr2);

            vm._expectCheatcodeRevert(bytes("assertion failed: [foo] != [, , bar]"));
            assertEq(arr1, arr2);

            vm._expectCheatcodeRevert(bytes(string.concat(errorMessage, ": [foo] == [foo]")));
            assertNotEq(arr1, arr1, errorMessage);
        }
        {
            bytes[] memory arr1 = new bytes[](1);
            bytes[] memory arr2 = new bytes[](2);

            arr1[0] = hex"1111";
            arr2[1] = hex"1234";

            assertEq(arr1, arr1);
            assertEq(arr2, arr2);
            assertNotEq(arr1, arr2);

            vm._expectCheatcodeRevert(bytes("assertion failed: [0x1111] != [0x, 0x1234]"));
            assertEq(arr1, arr2);

            vm._expectCheatcodeRevert(bytes(string.concat(errorMessage, ": [0x1111] == [0x1111]")));
            assertNotEq(arr1, arr1, errorMessage);
        }
    }

    function testAssertBool() public {
        assertTrue(true);
        assertFalse(false);

        vm._expectCheatcodeRevert(bytes("assertion failed"));
        assertTrue(false);

        vm._expectCheatcodeRevert(bytes(errorMessage));
        assertTrue(false, errorMessage);

        vm._expectCheatcodeRevert(bytes("assertion failed"));
        assertFalse(true);

        vm._expectCheatcodeRevert(bytes(errorMessage));
        assertFalse(true, errorMessage);
    }

    function testAssertApproxEqRel() public {
        vm._expectCheatcodeRevert(bytes("assertion failed: overflow in delta calculation"));
        assertApproxEqRel(type(int256).min, type(int256).max, 0);

        vm._expectCheatcodeRevert(bytes(string.concat(errorMessage, ": overflow in delta calculation")));
        assertApproxEqRel(int256(1), int256(0), 0, errorMessage);

        vm._expectCheatcodeRevert(bytes(string.concat(errorMessage, ": overflow in delta calculation")));
        assertApproxEqRel(uint256(0), type(uint256).max, 0, errorMessage);

        vm._expectCheatcodeRevert(bytes("assertion failed: overflow in delta calculation"));
        assertApproxEqRel(uint256(1), uint256(0), uint256(0));
    }

    function testFuzz_AssertEqCall_Return_Pass(
        bytes memory callDataA,
        bytes memory callDataB,
        bytes memory returnData,
        bool strictRevertData
    ) external {
        address targetA = address(new TestMockCall(returnData, SHOULD_RETURN));
        address targetB = address(new TestMockCall(returnData, SHOULD_RETURN));

        assertEqCall(targetA, callDataA, targetB, callDataB, strictRevertData);
    }

    function testFuzz_RevertWhenCalled_AssertEqCall_Return_Fail(
        bytes memory callDataA,
        bytes memory callDataB,
        bytes memory returnDataA,
        bytes memory returnDataB,
        bool strictRevertData
    ) external {
        vm.assume(keccak256(returnDataA) != keccak256(returnDataB));

        address targetA = address(new TestMockCall(returnDataA, SHOULD_RETURN));
        address targetB = address(new TestMockCall(returnDataB, SHOULD_RETURN));

        vm._expectCheatcodeRevert(
            bytes(
                string.concat(
                    "Call return data does not match: ", vm.toString(returnDataA), " != ", vm.toString(returnDataB)
                )
            )
        );
        assertEqCall(targetA, callDataA, targetB, callDataB, strictRevertData);
    }

    function testFuzz_AssertEqCall_Revert_Pass(
        bytes memory callDataA,
        bytes memory callDataB,
        bytes memory revertDataA,
        bytes memory revertDataB
    ) external {
        address targetA = address(new TestMockCall(revertDataA, SHOULD_REVERT));
        address targetB = address(new TestMockCall(revertDataB, SHOULD_REVERT));

        assertEqCall(targetA, callDataA, targetB, callDataB, NON_STRICT_REVERT_DATA);
    }

    function testFuzz_RevertWhenCalled_AssertEqCall_Revert_Fail(
        bytes memory callDataA,
        bytes memory callDataB,
        bytes memory revertDataA,
        bytes memory revertDataB
    ) external {
        vm.assume(keccak256(revertDataA) != keccak256(revertDataB));

        address targetA = address(new TestMockCall(revertDataA, SHOULD_REVERT));
        address targetB = address(new TestMockCall(revertDataB, SHOULD_REVERT));

        vm._expectCheatcodeRevert(
            bytes(
                string.concat(
                    "Call revert data does not match: ", vm.toString(revertDataA), " != ", vm.toString(revertDataB)
                )
            )
        );
        assertEqCall(targetA, callDataA, targetB, callDataB, STRICT_REVERT_DATA);
    }

    function testFuzz_RevertWhenCalled_AssertEqCall_Fail(
        bytes memory callDataA,
        bytes memory callDataB,
        bytes memory returnDataA,
        bytes memory returnDataB,
        bool strictRevertData
    ) external {
        address targetA = address(new TestMockCall(returnDataA, SHOULD_RETURN));
        address targetB = address(new TestMockCall(returnDataB, SHOULD_REVERT));

        vm.expectRevert(bytes("assertion failed"));
        this.assertEqCallExternal(targetA, callDataA, targetB, callDataB, strictRevertData);

        vm.expectRevert(bytes("assertion failed"));
        this.assertEqCallExternal(targetB, callDataB, targetA, callDataA, strictRevertData);
    }

    // Helper function to test outcome of assertEqCall via `expect` cheatcodes
    function assertEqCallExternal(
        address targetA,
        bytes memory callDataA,
        address targetB,
        bytes memory callDataB,
        bool strictRevertData
    ) public {
        assertEqCall(targetA, callDataA, targetB, callDataB, strictRevertData);
    }

    function testFailFail() public {
        fail();
    }
}

contract TestMockCall {
    bytes returnData;
    bool shouldRevert;

    constructor(bytes memory returnData_, bool shouldRevert_) {
        returnData = returnData_;
        shouldRevert = shouldRevert_;
    }

    fallback() external payable {
        bytes memory returnData_ = returnData;

        if (shouldRevert) {
            assembly {
                revert(add(returnData_, 0x20), mload(returnData_))
            }
        } else {
            assembly {
                return(add(returnData_, 0x20), mload(returnData_))
            }
        }
    }
}
