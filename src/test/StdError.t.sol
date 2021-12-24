// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.10;

import "ds-test/test.sol";
import "../stdlib.sol";
import "../Vm.sol";

contract StdErrorsTest is DSTest {
    Vm public constant vm = Vm(HEVM_ADDRESS);

    ErrorsTest test;
    function setUp() public {
        test = new ErrorsTest();
    }

    function testExpectArithmetic() public {
        vm.expectRevert(stdError.arithmeticError);
        test.arithmeticError(10);
    }

    function testExpectDiv() public {
        vm.expectRevert(stdError.divisionError);
        test.divError(0);
    }

    function testExpectOOB() public {
        vm.expectRevert(stdError.indexOOBError);
        test.indexOOBError(1);
    }
}

contract ErrorsTest {
    function arithmeticError(uint256 a) public {
        uint256 a = a - 100;
    }

    function divError(uint256 a) public {
        uint256 a = 100 / a;
    }

    function indexOOBError(uint256 a) public {
        uint256[] memory t = new uint256[](0);
        uint256 b = t[a];
    }
}
