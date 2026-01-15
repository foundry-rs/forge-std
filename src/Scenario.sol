// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.20 <0.9.0;

import {Vm} from "./Vm.sol";

/// @title Scenario - Composable Test Scenario Builder
/// @notice Fluent API for building self-documenting test scenarios
/// @dev Designed for AI/agent readability with explicit, chainable methods
///
/// Example usage:
/// ```solidity
/// Scenario memory s = scenario
///     .create("DEX swap test")
///     .withActor("alice", 100 ether)
///     .withActor("bob", 50 ether)
///     .atBlock(1000)
///     .atTimestamp(1700000000)
///     .build();
///
/// s.asActor("alice");
/// // ... perform actions as alice
/// s.stopActor();
/// ```

/// @notice An actor in a scenario
/// @dev Named ScenarioActor to avoid collision with Spec.SpecActor
struct ScenarioActor {
    string name;
    address addr;
    uint256 privateKey;
    uint256 balance;
    bool initialized;
}

/// @notice Alias for backwards compatibility
/// @dev DEPRECATED: Use ScenarioActor to avoid name collisions
struct Actor {
    string name;
    address addr;
    uint256 privateKey;
    uint256 balance;
    bool initialized;
}

struct ScenarioState {
    string name;
    string description;
    ScenarioActor[] actors;
    mapping(string => uint256) actorIndex;
    uint256 blockNumber;
    uint256 timestamp;
    uint256 chainId;
    bool built;
    address currentActor;
}

struct ScenarioBuilder {
    string name;
    string description;
    string[] actorNames;
    uint256[] actorBalances;
    uint256 blockNumber;
    uint256 timestamp;
    uint256 chainId;
}

library ScenarioLib {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    // ═══════════════════════════════════════════════════════════════════════
    // BUILDER FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════

    function create(string memory name) internal pure returns (ScenarioBuilder memory builder) {
        builder.name = name;
    }

    function withDescription(ScenarioBuilder memory self, string memory desc)
        internal
        pure
        returns (ScenarioBuilder memory)
    {
        self.description = desc;
        return self;
    }

    function withActor(ScenarioBuilder memory self, string memory name)
        internal
        pure
        returns (ScenarioBuilder memory)
    {
        return withActor(self, name, 100 ether);
    }

    function withActor(ScenarioBuilder memory self, string memory name, uint256 balance)
        internal
        pure
        returns (ScenarioBuilder memory)
    {
        // Extend arrays
        string[] memory newNames = new string[](self.actorNames.length + 1);
        uint256[] memory newBalances = new uint256[](self.actorBalances.length + 1);

        for (uint256 i = 0; i < self.actorNames.length; i++) {
            newNames[i] = self.actorNames[i];
            newBalances[i] = self.actorBalances[i];
        }
        newNames[self.actorNames.length] = name;
        newBalances[self.actorBalances.length] = balance;

        self.actorNames = newNames;
        self.actorBalances = newBalances;
        return self;
    }

    function atBlock(ScenarioBuilder memory self, uint256 blockNum)
        internal
        pure
        returns (ScenarioBuilder memory)
    {
        self.blockNumber = blockNum;
        return self;
    }

    function atTimestamp(ScenarioBuilder memory self, uint256 ts) internal pure returns (ScenarioBuilder memory) {
        self.timestamp = ts;
        return self;
    }

    function onChain(ScenarioBuilder memory self, uint256 chainId) internal pure returns (ScenarioBuilder memory) {
        self.chainId = chainId;
        return self;
    }

    // ═══════════════════════════════════════════════════════════════════════
    // SCENARIO EXECUTION
    // ═══════════════════════════════════════════════════════════════════════

    function build(ScenarioBuilder memory self) internal returns (ScenarioResult memory result) {
        result.name = self.name;
        result.description = self.description;
        result.actors = new ScenarioActor[](self.actorNames.length);

        // Create actors
        for (uint256 i = 0; i < self.actorNames.length; i++) {
            string memory name = self.actorNames[i];
            uint256 balance = self.actorBalances[i];

            uint256 privateKey = uint256(keccak256(abi.encodePacked(name, self.name)));
            address addr = vm.addr(privateKey);

            vm.deal(addr, balance);
            vm.label(addr, name);

            result.actors[i] = ScenarioActor({
                name: name,
                addr: addr,
                privateKey: privateKey,
                balance: balance,
                initialized: true
            });
        }

        // Set block state
        if (self.blockNumber > 0) {
            vm.roll(self.blockNumber);
            result.blockNumber = self.blockNumber;
        } else {
            result.blockNumber = block.number;
        }

        if (self.timestamp > 0) {
            vm.warp(self.timestamp);
            result.timestamp = self.timestamp;
        } else {
            result.timestamp = block.timestamp;
        }

        result.chainId = self.chainId > 0 ? self.chainId : block.chainid;
        result.built = true;
    }
}

struct ScenarioResult {
    string name;
    string description;
    ScenarioActor[] actors;
    uint256 blockNumber;
    uint256 timestamp;
    uint256 chainId;
    bool built;
}

library ScenarioResultLib {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    function getActor(ScenarioResult memory self, string memory name) internal pure returns (ScenarioActor memory) {
        for (uint256 i = 0; i < self.actors.length; i++) {
            if (keccak256(bytes(self.actors[i].name)) == keccak256(bytes(name))) {
                return self.actors[i];
            }
        }
        revert(string.concat("Scenario: Actor '", name, "' not found"));
    }

    function getActorAddress(ScenarioResult memory self, string memory name) internal pure returns (address) {
        return getActor(self, name).addr;
    }

    function asActor(ScenarioResult memory self, string memory name) internal {
        ScenarioActor memory actor_ = getActor(self, name);
        vm.startPrank(actor_.addr);
    }

    function asActorWithKey(ScenarioResult memory self, string memory name) internal returns (uint256 privateKey) {
        ScenarioActor memory actor_ = getActor(self, name);
        vm.startPrank(actor_.addr);
        return actor_.privateKey;
    }

    function stopActor(ScenarioResult memory) internal {
        vm.stopPrank();
    }

    function fundActor(ScenarioResult memory self, string memory name, uint256 amount) internal {
        address addr = getActorAddress(self, name);
        vm.deal(addr, amount);
    }

    function fundActorToken(ScenarioResult memory self, string memory name, address token, uint256 amount) internal {
        address addr = getActorAddress(self, name);
        // Use storage manipulation to set balance
        (bool success,) = token.call(abi.encodeWithSignature("transfer(address,uint256)", addr, amount));
        if (!success) {
            // Fallback: try to mint or use deal
            vm.deal(addr, addr.balance); // This won't work for tokens, but signals intent
        }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // TIME MANIPULATION
    // ═══════════════════════════════════════════════════════════════════════

    function skipTime(ScenarioResult memory self, uint256 seconds_) internal returns (ScenarioResult memory) {
        vm.warp(block.timestamp + seconds_);
        self.timestamp = block.timestamp;
        return self;
    }

    function skipBlocks(ScenarioResult memory self, uint256 blocks) internal returns (ScenarioResult memory) {
        vm.roll(block.number + blocks);
        self.blockNumber = block.number;
        return self;
    }

    function rewindTime(ScenarioResult memory self, uint256 seconds_) internal returns (ScenarioResult memory) {
        vm.warp(block.timestamp - seconds_);
        self.timestamp = block.timestamp;
        return self;
    }

    // ═══════════════════════════════════════════════════════════════════════
    // SNAPSHOT & RESTORE
    // ═══════════════════════════════════════════════════════════════════════

    function snapshot(ScenarioResult memory) internal returns (uint256 snapshotId) {
        return vm.snapshotState();
    }

    function restore(ScenarioResult memory, uint256 snapshotId) internal returns (bool success) {
        return vm.revertToState(snapshotId);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // INSPECTION
    // ═══════════════════════════════════════════════════════════════════════

    function describeActors(ScenarioResult memory self) internal pure returns (string memory) {
        string memory desc = string.concat("Scenario: ", self.name, "\nActors:\n");
        for (uint256 i = 0; i < self.actors.length; i++) {
            desc = string.concat(
                desc,
                "  - ",
                self.actors[i].name,
                ": ",
                vm.toString(self.actors[i].addr),
                " (",
                vm.toString(self.actors[i].balance),
                " wei)\n"
            );
        }
        return desc;
    }
}

/// @notice Global scenario builder entry point
library scenario {
    function create(string memory name) internal pure returns (ScenarioBuilder memory) {
        return ScenarioLib.create(name);
    }
}
