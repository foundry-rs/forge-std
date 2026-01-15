// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.20 <0.9.0;

import {Vm} from "./Vm.sol";

/// @title Mock - Structured Mock/Spy Helpers
/// @notice Create mocks with expectations and verify calls in a structured way
/// @dev Designed for AI/agent readability with clear expectation chains
///
/// Example usage:
/// ```solidity
/// // Create a mock that returns specific values
/// MockSetup memory m = mock.create(address(token))
///     .whenCalled(IERC20.balanceOf.selector)
///     .withAnyArgs()
///     .returns(abi.encode(1000 ether))
///     .times(2);
///
/// m.setup();
///
/// // Later, verify the mock was called
/// MockVerification memory v = m.verify();
/// assertEq(v.callCount, 2);
/// ```

// ═══════════════════════════════════════════════════════════════════════════
// MOCK TYPES
// ═══════════════════════════════════════════════════════════════════════════

struct MockCall {
    bytes4 selector;
    bytes args;
    bool matchAnyArgs;
    bytes returnData;
    bool shouldRevert;
    bytes revertData;
    uint256 expectedCalls;
    uint256 actualCalls;
    uint256 value;
    bool applied;
}

struct MockSetup {
    address target;
    MockCall[] calls;
    bool deployed;
    bytes deployedCode;
    string label;
}

struct MockVerification {
    address target;
    bytes4 selector;
    uint256 expectedCalls;
    uint256 actualCalls;
    bool satisfied;
    bytes[] capturedArgs;
    bytes[] capturedReturns;
}

struct SpyRecord {
    bytes4 selector;
    bytes args;
    bytes returnData;
    uint256 timestamp;
    uint256 blockNumber;
    address caller;
    uint256 value;
}

struct Spy {
    address target;
    SpyRecord[] records;
    bool active;
}

library MockLib {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    // ═══════════════════════════════════════════════════════════════════════
    // MOCK CREATION
    // ═══════════════════════════════════════════════════════════════════════

    function create(address target) internal pure returns (MockSetup memory m) {
        m.target = target;
    }

    function createLabeled(address target, string memory label) internal returns (MockSetup memory m) {
        m.target = target;
        m.label = label;
        vm.label(target, label);
    }

    function createFresh(string memory label) internal returns (MockSetup memory m) {
        address target = address(uint160(uint256(keccak256(abi.encodePacked(label, block.timestamp)))));
        m.target = target;
        m.label = label;
        vm.label(target, label);
        vm.etch(target, hex"00"); // Minimal bytecode
    }

    // ═══════════════════════════════════════════════════════════════════════
    // MOCK CONFIGURATION
    // ═══════════════════════════════════════════════════════════════════════

    function whenCalled(MockSetup memory self, bytes4 selector) internal pure returns (MockSetup memory) {
        MockCall[] memory newCalls = new MockCall[](self.calls.length + 1);
        for (uint256 i = 0; i < self.calls.length; i++) {
            newCalls[i] = self.calls[i];
        }
        newCalls[self.calls.length].selector = selector;
        newCalls[self.calls.length].matchAnyArgs = true;
        self.calls = newCalls;
        return self;
    }

    function whenCalledWith(MockSetup memory self, bytes4 selector, bytes memory args)
        internal
        pure
        returns (MockSetup memory)
    {
        MockCall[] memory newCalls = new MockCall[](self.calls.length + 1);
        for (uint256 i = 0; i < self.calls.length; i++) {
            newCalls[i] = self.calls[i];
        }
        newCalls[self.calls.length].selector = selector;
        newCalls[self.calls.length].args = args;
        newCalls[self.calls.length].matchAnyArgs = false;
        self.calls = newCalls;
        return self;
    }

    function withAnyArgs(MockSetup memory self) internal pure returns (MockSetup memory) {
        if (self.calls.length > 0) {
            self.calls[self.calls.length - 1].matchAnyArgs = true;
        }
        return self;
    }

    function withArgs(MockSetup memory self, bytes memory args) internal pure returns (MockSetup memory) {
        if (self.calls.length > 0) {
            self.calls[self.calls.length - 1].args = args;
            self.calls[self.calls.length - 1].matchAnyArgs = false;
        }
        return self;
    }

    function returns_(MockSetup memory self, bytes memory data) internal pure returns (MockSetup memory) {
        if (self.calls.length > 0) {
            self.calls[self.calls.length - 1].returnData = data;
        }
        return self;
    }

    function returnsUint(MockSetup memory self, uint256 value) internal pure returns (MockSetup memory) {
        return returns_(self, abi.encode(value));
    }

    function returnsBool(MockSetup memory self, bool value) internal pure returns (MockSetup memory) {
        return returns_(self, abi.encode(value));
    }

    function returnsAddress(MockSetup memory self, address value) internal pure returns (MockSetup memory) {
        return returns_(self, abi.encode(value));
    }

    function reverts(MockSetup memory self) internal pure returns (MockSetup memory) {
        if (self.calls.length > 0) {
            self.calls[self.calls.length - 1].shouldRevert = true;
        }
        return self;
    }

    function revertsWith(MockSetup memory self, bytes memory data) internal pure returns (MockSetup memory) {
        if (self.calls.length > 0) {
            self.calls[self.calls.length - 1].shouldRevert = true;
            self.calls[self.calls.length - 1].revertData = data;
        }
        return self;
    }

    function times(MockSetup memory self, uint256 n) internal pure returns (MockSetup memory) {
        if (self.calls.length > 0) {
            self.calls[self.calls.length - 1].expectedCalls = n;
        }
        return self;
    }

    function once(MockSetup memory self) internal pure returns (MockSetup memory) {
        return times(self, 1);
    }

    function twice(MockSetup memory self) internal pure returns (MockSetup memory) {
        return times(self, 2);
    }

    function anyTimes(MockSetup memory self) internal pure returns (MockSetup memory) {
        return times(self, type(uint256).max);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // MOCK APPLICATION
    // ═══════════════════════════════════════════════════════════════════════

    function setup(MockSetup memory self) internal {
        for (uint256 i = 0; i < self.calls.length; i++) {
            MockCall memory mc = self.calls[i];

            if (mc.shouldRevert) {
                if (mc.matchAnyArgs) {
                    vm.mockCallRevert(self.target, abi.encodeWithSelector(mc.selector), mc.revertData);
                } else {
                    vm.mockCallRevert(self.target, abi.encodeWithSelector(mc.selector, mc.args), mc.revertData);
                }
            } else {
                if (mc.matchAnyArgs) {
                    vm.mockCall(self.target, abi.encodeWithSelector(mc.selector), mc.returnData);
                } else {
                    vm.mockCall(self.target, abi.encodeWithSelector(mc.selector, mc.args), mc.returnData);
                }
            }

            self.calls[i].applied = true;
        }
    }

    function clear(MockSetup memory self) internal {
        vm.clearMockedCalls();
        for (uint256 i = 0; i < self.calls.length; i++) {
            self.calls[i].applied = false;
            self.calls[i].actualCalls = 0;
        }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // VERIFICATION
    // ═══════════════════════════════════════════════════════════════════════

    function verify(MockSetup memory self) internal pure returns (MockVerification[] memory results) {
        results = new MockVerification[](self.calls.length);

        for (uint256 i = 0; i < self.calls.length; i++) {
            MockCall memory mc = self.calls[i];
            results[i] = MockVerification({
                target: self.target,
                selector: mc.selector,
                expectedCalls: mc.expectedCalls,
                actualCalls: mc.actualCalls,
                satisfied: mc.expectedCalls == type(uint256).max || mc.actualCalls >= mc.expectedCalls,
                capturedArgs: new bytes[](0),
                capturedReturns: new bytes[](0)
            });
        }
    }

    function assertSatisfied(MockSetup memory self) internal pure {
        MockVerification[] memory results = verify(self);
        for (uint256 i = 0; i < results.length; i++) {
            if (!results[i].satisfied) {
                revert(
                    string.concat(
                        "Mock expectation not satisfied for ",
                        vm.toString(results[i].selector),
                        ": expected ",
                        vm.toString(results[i].expectedCalls),
                        " calls, got ",
                        vm.toString(results[i].actualCalls)
                    )
                );
            }
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// SPY FUNCTIONALITY
// ═══════════════════════════════════════════════════════════════════════════

library SpyLib {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    function create(address target) internal pure returns (Spy memory s) {
        s.target = target;
        s.active = true;
    }

    function getCallCount(Spy memory self) internal pure returns (uint256) {
        return self.records.length;
    }

    function getCallCountFor(Spy memory self, bytes4 selector) internal pure returns (uint256) {
        uint256 count = 0;
        for (uint256 i = 0; i < self.records.length; i++) {
            if (self.records[i].selector == selector) {
                count++;
            }
        }
        return count;
    }

    function getCallsFor(Spy memory self, bytes4 selector) internal pure returns (SpyRecord[] memory) {
        // First count
        uint256 count = 0;
        for (uint256 i = 0; i < self.records.length; i++) {
            if (self.records[i].selector == selector) {
                count++;
            }
        }

        // Then collect
        SpyRecord[] memory result = new SpyRecord[](count);
        uint256 idx = 0;
        for (uint256 i = 0; i < self.records.length; i++) {
            if (self.records[i].selector == selector) {
                result[idx++] = self.records[i];
            }
        }
        return result;
    }

    function wasCalledWith(Spy memory self, bytes4 selector, bytes memory args) internal pure returns (bool) {
        for (uint256 i = 0; i < self.records.length; i++) {
            if (self.records[i].selector == selector && keccak256(self.records[i].args) == keccak256(args)) {
                return true;
            }
        }
        return false;
    }

    function getLastCall(Spy memory self) internal pure returns (SpyRecord memory) {
        require(self.records.length > 0, "Spy: No calls recorded");
        return self.records[self.records.length - 1];
    }

    function getFirstCall(Spy memory self) internal pure returns (SpyRecord memory) {
        require(self.records.length > 0, "Spy: No calls recorded");
        return self.records[0];
    }
}

/// @notice Global mock entry point
library mock {
    function create(address target) internal pure returns (MockSetup memory) {
        return MockLib.create(target);
    }

    function createLabeled(address target, string memory label) internal returns (MockSetup memory) {
        return MockLib.createLabeled(target, label);
    }

    function createFresh(string memory label) internal returns (MockSetup memory) {
        return MockLib.createFresh(label);
    }
}

/// @notice Global spy entry point
library spy {
    function create(address target) internal pure returns (Spy memory) {
        return SpyLib.create(target);
    }
}
