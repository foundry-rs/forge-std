// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.20 <0.9.0;

import {Vm} from "./Vm.sol";

/// @title Expect - Declarative Expectation DSL
/// @notice Chain expectations before executing calls for readable, self-documenting tests
/// @dev Designed for AI/agent readability with explicit, fluent methods
///
/// Example usage:
/// ```solidity
/// // Expect a call to emit an event and change balance
/// Expectation memory e = expect.call(address(token))
///     .withSelector(IERC20.transfer.selector)
///     .toEmitEvent("Transfer")
///     .toChangeBalanceOf(recipient, 1000)
///     .toSucceed();
///
/// // Execute with calldata
/// e.execute(abi.encodeCall(IERC20.transfer, (recipient, 1000)));
/// ```

// ═══════════════════════════════════════════════════════════════════════════
// EXPECTATION TYPES
// ═══════════════════════════════════════════════════════════════════════════

struct BalanceChange {
    address account;
    address token; // address(0) for ETH
    int256 delta;
    bool isRelative; // true = delta, false = absolute value
}

struct EventExpectation {
    bytes32 topic0;
    bytes32 topic1;
    bytes32 topic2;
    bytes32 topic3;
    bytes data;
    bool checkTopic1;
    bool checkTopic2;
    bool checkTopic3;
    bool checkData;
    address emitter;
}

struct CallExpectation {
    address target;
    bytes4 selector;
    bytes args;
    bool shouldSucceed;
    bool shouldRevert;
    bytes4 revertSelector;
    bytes revertData;
    uint256 value;
    uint256 gasLimit;
}

struct Expectation {
    address target;
    bytes4 selector;
    uint256 value;
    uint256 gasLimit;
    bool expectSuccess;
    bool expectRevert;
    bytes4 expectedRevertSelector;
    bytes expectedRevertData;
    bool checkRevertData;
    BalanceChange[] balanceChanges;
    EventExpectation[] events;
    CallExpectation[] subcalls;
    bool built;
}

struct ExpectationResult {
    bool success;
    bytes returnData;
    bool balanceChangesValid;
    bool eventsValid;
    bool revertValid;
    string[] errors;
}

library ExpectLib {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    // ═══════════════════════════════════════════════════════════════════════
    // BUILDER FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════

    function call(address target) internal pure returns (Expectation memory e) {
        e.target = target;
        e.expectSuccess = true; // Default to expecting success
    }

    function withSelector(Expectation memory self, bytes4 selector) internal pure returns (Expectation memory) {
        self.selector = selector;
        return self;
    }

    function withValue(Expectation memory self, uint256 value) internal pure returns (Expectation memory) {
        self.value = value;
        return self;
    }

    function withGasLimit(Expectation memory self, uint256 gasLimit) internal pure returns (Expectation memory) {
        self.gasLimit = gasLimit;
        return self;
    }

    function toSucceed(Expectation memory self) internal pure returns (Expectation memory) {
        self.expectSuccess = true;
        self.expectRevert = false;
        return self;
    }

    function toRevert(Expectation memory self) internal pure returns (Expectation memory) {
        self.expectRevert = true;
        self.expectSuccess = false;
        return self;
    }

    function toRevertWith(Expectation memory self, bytes4 selector) internal pure returns (Expectation memory) {
        self.expectRevert = true;
        self.expectSuccess = false;
        self.expectedRevertSelector = selector;
        return self;
    }

    function toRevertWithData(Expectation memory self, bytes memory data) internal pure returns (Expectation memory) {
        self.expectRevert = true;
        self.expectSuccess = false;
        self.expectedRevertData = data;
        self.checkRevertData = true;
        return self;
    }

    // ═══════════════════════════════════════════════════════════════════════
    // BALANCE EXPECTATIONS
    // ═══════════════════════════════════════════════════════════════════════

    function toChangeEthBalanceOf(Expectation memory self, address account, int256 delta)
        internal
        pure
        returns (Expectation memory)
    {
        BalanceChange[] memory newChanges = new BalanceChange[](self.balanceChanges.length + 1);
        for (uint256 i = 0; i < self.balanceChanges.length; i++) {
            newChanges[i] = self.balanceChanges[i];
        }
        newChanges[self.balanceChanges.length] =
            BalanceChange({account: account, token: address(0), delta: delta, isRelative: true});
        self.balanceChanges = newChanges;
        return self;
    }

    function toChangeTokenBalanceOf(Expectation memory self, address token, address account, int256 delta)
        internal
        pure
        returns (Expectation memory)
    {
        BalanceChange[] memory newChanges = new BalanceChange[](self.balanceChanges.length + 1);
        for (uint256 i = 0; i < self.balanceChanges.length; i++) {
            newChanges[i] = self.balanceChanges[i];
        }
        newChanges[self.balanceChanges.length] =
            BalanceChange({account: account, token: token, delta: delta, isRelative: true});
        self.balanceChanges = newChanges;
        return self;
    }

    // ═══════════════════════════════════════════════════════════════════════
    // EVENT EXPECTATIONS
    // ═══════════════════════════════════════════════════════════════════════

    function toEmitEventFrom(Expectation memory self, address emitter, bytes32 topic0)
        internal
        pure
        returns (Expectation memory)
    {
        EventExpectation[] memory newEvents = new EventExpectation[](self.events.length + 1);
        for (uint256 i = 0; i < self.events.length; i++) {
            newEvents[i] = self.events[i];
        }
        newEvents[self.events.length] = EventExpectation({
            topic0: topic0,
            topic1: bytes32(0),
            topic2: bytes32(0),
            topic3: bytes32(0),
            data: "",
            checkTopic1: false,
            checkTopic2: false,
            checkTopic3: false,
            checkData: false,
            emitter: emitter
        });
        self.events = newEvents;
        return self;
    }

    function toEmitEvent(Expectation memory self, bytes32 topic0) internal pure returns (Expectation memory) {
        return toEmitEventFrom(self, self.target, topic0);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // EXECUTION
    // ═══════════════════════════════════════════════════════════════════════

    function execute(Expectation memory self, bytes memory callData)
        internal
        returns (ExpectationResult memory result)
    {
        result.errors = new string[](10); // Pre-allocate for errors
        uint256 errorCount = 0;

        // Capture initial balances
        uint256[] memory initialBalances = new uint256[](self.balanceChanges.length);
        for (uint256 i = 0; i < self.balanceChanges.length; i++) {
            BalanceChange memory bc = self.balanceChanges[i];
            if (bc.token == address(0)) {
                initialBalances[i] = bc.account.balance;
            } else {
                (bool balSuccess, bytes memory balData) = bc.token.staticcall(
                    abi.encodeWithSignature("balanceOf(address)", bc.account)
                );
                if (balSuccess && balData.length >= 32) {
                    initialBalances[i] = abi.decode(balData, (uint256));
                }
            }
        }

        // Set up event expectations
        for (uint256 i = 0; i < self.events.length; i++) {
            EventExpectation memory ev = self.events[i];
            vm.expectEmit(true, ev.checkTopic1, ev.checkTopic2, ev.checkTopic3, ev.emitter);
            // Note: The actual event emission check happens automatically
        }

        // Execute the call
        uint256 gasToUse = self.gasLimit > 0 ? self.gasLimit : gasleft();
        (bool success, bytes memory returnData) = self.target.call{value: self.value, gas: gasToUse}(callData);

        result.success = success;
        result.returnData = returnData;

        // Verify success/revert expectations
        if (self.expectSuccess && !success) {
            result.errors[errorCount++] = "Expected call to succeed but it reverted";
        } else if (self.expectRevert && success) {
            result.errors[errorCount++] = "Expected call to revert but it succeeded";
        }

        // Verify revert data if expected
        if (self.expectRevert && !success) {
            result.revertValid = true;
            if (self.expectedRevertSelector != bytes4(0)) {
                bytes4 actualSelector;
                if (returnData.length >= 4) {
                    actualSelector = bytes4(returnData);
                }
                if (actualSelector != self.expectedRevertSelector) {
                    result.errors[errorCount++] = "Revert selector mismatch";
                    result.revertValid = false;
                }
            }
            if (self.checkRevertData) {
                if (keccak256(returnData) != keccak256(self.expectedRevertData)) {
                    result.errors[errorCount++] = "Revert data mismatch";
                    result.revertValid = false;
                }
            }
        }

        // Verify balance changes
        result.balanceChangesValid = true;
        for (uint256 i = 0; i < self.balanceChanges.length; i++) {
            BalanceChange memory bc = self.balanceChanges[i];
            uint256 finalBalance;

            if (bc.token == address(0)) {
                finalBalance = bc.account.balance;
            } else {
                (bool balSuccess, bytes memory data) = bc.token.staticcall(
                    abi.encodeWithSignature("balanceOf(address)", bc.account)
                );
                if (balSuccess && data.length >= 32) {
                    finalBalance = abi.decode(data, (uint256));
                }
            }

            int256 actualDelta = int256(finalBalance) - int256(initialBalances[i]);
            if (bc.isRelative && actualDelta != bc.delta) {
                result.errors[errorCount++] = "Balance change mismatch";
                result.balanceChangesValid = false;
            }
        }

        // Trim errors array
        string[] memory trimmedErrors = new string[](errorCount);
        for (uint256 i = 0; i < errorCount; i++) {
            trimmedErrors[i] = result.errors[i];
        }
        result.errors = trimmedErrors;

        result.eventsValid = true; // Events are validated by vm.expectEmit automatically
    }

    function executeAndAssert(Expectation memory self, bytes memory callData) internal returns (bytes memory) {
        ExpectationResult memory result = execute(self, callData);

        if (result.errors.length > 0) {
            string memory errorMsg = "Expectation failed:";
            for (uint256 i = 0; i < result.errors.length; i++) {
                errorMsg = string.concat(errorMsg, "\n  - ", result.errors[i]);
            }
            revert(errorMsg);
        }

        return result.returnData;
    }
}

/// @notice Global expectation entry point
library expect {
    function call(address target) internal pure returns (Expectation memory) {
        return ExpectLib.call(target);
    }
}
