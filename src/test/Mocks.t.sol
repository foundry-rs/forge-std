// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0 <0.9.0;

import "../Test.sol";
import "../Mocks.sol";

contract MocksTest is Test, Mocks {
    function testFailStrictMockWhenUnstubbedFunctionIsCalled() public {
        address thirdParty = mock("ThirParty");
        SomeThirdParty(thirdParty).foo();
    }

    function testStrictMockCanStubAndVerifyParameterlessVoidFunctions() public {
        address thirdParty = mock("ThirParty");

        mockVoidCall(
            thirdParty,
            abi.encodeWithSelector(SomeThirdParty.foo.selector)
        );

        vm.expectCall(
            thirdParty,
            abi.encodeWithSelector(SomeThirdParty.foo.selector)
        );

        SomeThirdParty(thirdParty).foo();
    }

    function testStrictMockCanStubAndVerifyVoidFunctions() public {
        address thirdParty = mock("ThirParty");

        // When making verifications, it's easier to leave the function params out cause the error message
        // in case there's a mismatch parameter is better
        mockVoidCall(
            thirdParty,
            abi.encodeWithSelector(SomeThirdParty.bar.selector)
        );

        vm.expectCall(
            thirdParty,
            abi.encodeWithSelector(SomeThirdParty.bar.selector, 42)
        );

        SomeThirdParty(thirdParty).bar(42);
    }

    function testFailStrictMockOnUnexpectedParams() public {
        address thirdParty = mock("ThirParty");

        // When making verifications, it's easier to leave the function params out cause the error message
        // in case there's a mismatch parameter is better
        mockVoidCall(
            thirdParty,
            abi.encodeWithSelector(SomeThirdParty.bar.selector)
        );

        vm.expectCall(
            thirdParty,
            abi.encodeWithSelector(SomeThirdParty.bar.selector, 42)
        );

        SomeThirdParty(thirdParty).bar(43);
    }

    function testStrictMockCanStubAndVerifyFunctions() public {
        address thirdParty = mock("ThirParty");

        // When making verifications, it's easier to leave the function params out cause the error message
        // in case there's a mismatch parameter is better
        vm.mockCall(
            thirdParty,
            abi.encodeWithSelector(SomeThirdParty.baz.selector),
            abi.encode(69420)
        );

        vm.expectCall(
            thirdParty,
            abi.encodeWithSelector(SomeThirdParty.baz.selector, 42)
        );

        assertEq(SomeThirdParty(thirdParty).baz(42), 69420);
    }

    function testLenientMockCanVerifyUnstubbedParameterlessVoidFunctions()
        public
    {
        address thirdParty = lenientMock("ThirParty");

        vm.expectCall(
            thirdParty,
            abi.encodeWithSelector(SomeThirdParty.foo.selector)
        );

        SomeThirdParty(thirdParty).foo();
    }

    function testLenientMockCanVerifyUnstubbedVoidFunctions() public {
        address thirdParty = lenientMock("ThirParty");

        vm.expectCall(
            thirdParty,
            abi.encodeWithSelector(SomeThirdParty.bar.selector, 42)
        );

        SomeThirdParty(thirdParty).bar(42);
    }

    function testFailLenientMockCanVerifyUnstubbedVoidFunctions() public {
        address thirdParty = lenientMock("ThirParty");

        vm.expectCall(
            thirdParty,
            abi.encodeWithSelector(SomeThirdParty.bar.selector, 42)
        );

        SomeThirdParty(thirdParty).bar(43);
    }

    function testFailCantUseLenientMockOnNonVoidFunctions() public {
        address thirdParty = lenientMock("ThirParty");
        SomeThirdParty(thirdParty).baz(43);
    }

    function testCanDeployStrictMockOnArbitraryAddress() public {
        address thirdParty = mockAt(address(1), "ThirParty");

        mockVoidCall(
            thirdParty,
            abi.encodeWithSelector(SomeThirdParty.foo.selector)
        );

        vm.expectCall(
            thirdParty,
            abi.encodeWithSelector(SomeThirdParty.foo.selector)
        );

        SomeThirdParty(address(1)).foo();
    }

    function testCanDeployLenientMockOnArbitraryAddress() public {
        address thirdParty = lenientMockAt(address(1), "ThirParty");

        vm.expectCall(
            thirdParty,
            abi.encodeWithSelector(SomeThirdParty.foo.selector)
        );

        SomeThirdParty(address(1)).foo();
    }
}

interface SomeThirdParty {
    function foo() external;

    function bar(uint256 i) external;

    function baz(uint256 i) external returns (uint256);
}
