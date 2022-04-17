// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0 <0.9.0;

import "./Vm.sol";
import "./Test.sol";

contract Mocks is Test {
    /// @dev creates a strict mock and labels it, it's a good practice to always use strict mocks unless you really, really want leniency.
    function mock(string memory label) internal returns (address mock_) {
        mock_ = address(new StrictMock());
        vm.label(mock_, label);
    }

    /// @dev same as `mock` but it deploys a lenient mock.
    function lenientMock(string memory label) internal returns (address mock_) {
        mock_ = address(new LenientMock());
        vm.label(mock_, label);
    }

    /// @dev creates a strict mock (and labels it) on a pre-specified address,
    /// useful to replace existing contracts on a fork or to test contracts that rely on deterministic addresses like uniswap pools
    function mockAt(address where, string memory label)
        internal
        returns (address)
    {
        vm.etch(where, vm.getCode("Mocks.sol:StrictMock"));
        vm.label(where, label);
        return where;
    }

    /// @dev same as `mockAt` but it deploys a lenient mock.
    function lenientMockAt(address where, string memory label)
        internal
        returns (address)
    {
        vm.etch(where, vm.getCode("Mocks.sol:LenientMock"));
        vm.label(where, label);
        return where;
    }

    function mockVoidCall(address _mock, bytes memory _calldata) internal {
        vm.mockCall(
            _mock,
            _calldata,
            abi.encode(0) // Would be nice to have a `vm.mockCall` that didn't require a return value
        );
    }
}

/// @dev Empty contract to deploy and use as a Mock, needed due to the fact that `vm.mockCall()` doesn't with non-contract addresses
/// @notice this contract will purposely fail if called on an un-stubbed method
contract StrictMock {
    fallback() external payable {
        revert("Not mocked!");
    }
}

/// @dev Empty contract to deploy and use as a Mock, needed due to the fact that `vm.mockCall()` doesn't with non-contract addresses
/// @notice this contract will do nothing if called on a method that wasn't previously stubbed
contract LenientMock {
    fallback() external payable {}
}
