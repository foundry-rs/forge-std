// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.20 <0.9.0;

import {Vm} from "./Vm.sol";

// ═══════════════════════════════════════════════════════════════════════════
//
//   ███████╗██████╗ ███████╗ ██████╗
//   ██╔════╝██╔══██╗██╔════╝██╔════╝
//   ███████╗██████╔╝█████╗  ██║
//   ╚════██║██╔═══╝ ██╔══╝  ██║
//   ███████║██║     ███████╗╚██████╗
//   ╚══════╝╚═╝     ╚══════╝ ╚═════╝
//
//   SPECIFICATION-FIRST TESTING
//
// ═══════════════════════════════════════════════════════════════════════════
//
// The test suite IS the specification. Not the other way around.
//
// OLD WAY (test-first):
//   1. Write contract
//   2. Write tests that exercise code paths
//   3. Hope tests cover important properties
//   4. Invariants added as afterthought
//
// NEW WAY (spec-first):
//   1. Define WHAT must always be true (invariants)
//   2. Define HOW state can change (actions)  
//   3. Let the fuzzer prove your spec holds
//   4. Implementation is just an artifact
//
// ═══════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════
// CORE PRIMITIVES
// ═══════════════════════════════════════════════════════════════════════════

/// @notice An actor in the specification - someone who can take actions
/// @dev Named SpecActor to avoid collision with Scenario.Actor
struct SpecActor {
    address addr;
    uint256 key;
    string name;
}

/// @notice Result of a property check
struct PropertyResult {
    bool holds;
    string property;
    string violation;
    bytes counterexample;
}

/// @notice Tracking state changes
struct StateChange {
    bytes32 slot;
    bytes32 oldValue;
    bytes32 newValue;
    address target;
}

// ═══════════════════════════════════════════════════════════════════════════
// SPEC - THE BASE CONTRACT
// ═══════════════════════════════════════════════════════════════════════════

/// @title Spec - Specification-first testing base
/// @notice Inherit from this. Define invariants. Define actions. Let it run.
abstract contract Spec {
    Vm internal constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    bool public IS_TEST = true;

    // ═══════════════════════════════════════════════════════════════════════
    // ACTORS
    // ═══════════════════════════════════════════════════════════════════════

    SpecActor[] internal _actors;
    SpecActor internal currentActor;
    mapping(address => uint256) internal actorIndex;

    /// @notice Get actor by seed (public for actions to call)
    function actor(uint256 seed) public view returns (SpecActor memory) {
        return _actors[seed % _actors.length];
    }

    /// @notice Get actor by seed (internal for spec property tests)
    function _actor(uint256 seed) internal view returns (SpecActor memory) {
        return _actors[seed % _actors.length];
    }

    /// @notice Get actor address by seed (convenience)
    function actorAddr(uint256 seed) public view returns (address) {
        return _actors[seed % _actors.length].addr;
    }

    /// @notice Get number of actors
    function actorCount() public view returns (uint256) {
        return _actors.length;
    }

    /// @notice Create actors for this spec
    function createActors(uint256 count) internal {
        for (uint256 i = 0; i < count; i++) {
            string memory name = string.concat("actor", vm.toString(i));
            uint256 key = uint256(keccak256(abi.encodePacked(name, i)));
            address addr = vm.addr(key);
            vm.deal(addr, 1000 ether);
            vm.label(addr, name);
            _actors.push(SpecActor({addr: addr, key: key, name: name}));
            actorIndex[addr] = i;
        }
    }

    /// @notice Execute as actor
    modifier asActor(uint256 seed) {
        currentActor = actor(seed);
        vm.startPrank(currentActor.addr);
        _;
        vm.stopPrank();
    }

    // ═══════════════════════════════════════════════════════════════════════
    // GHOST STATE
    // ═══════════════════════════════════════════════════════════════════════
    //
    // Ghost variables track "what should be true" independent of implementation.
    // They are the SOURCE OF TRUTH for invariants.
    //

    mapping(bytes32 => uint256) internal ghost;
    mapping(bytes32 => mapping(address => uint256)) internal ghostOf;
    mapping(bytes32 => int256) internal ghostInt;
    mapping(bytes32 => mapping(address => int256)) internal ghostIntOf;

    function G(string memory name) public view returns (uint256) {
        return ghost[keccak256(bytes(name))];
    }

    function G(string memory name, address who) public view returns (uint256) {
        return ghostOf[keccak256(bytes(name))][who];
    }

    function setG(string memory name, uint256 value) public {
        ghost[keccak256(bytes(name))] = value;
    }

    function setG(string memory name, address who, uint256 value) public {
        ghostOf[keccak256(bytes(name))][who] = value;
    }

    function addG(string memory name, uint256 delta) public {
        ghost[keccak256(bytes(name))] += delta;
    }

    function subG(string memory name, uint256 delta) public {
        ghost[keccak256(bytes(name))] -= delta;
    }

    function addG(string memory name, address who, uint256 delta) public {
        ghostOf[keccak256(bytes(name))][who] += delta;
    }

    function subG(string memory name, address who, uint256 delta) public {
        ghostOf[keccak256(bytes(name))][who] -= delta;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Int256 ghost state (for net flows, PnL, debt, etc.)
    // ─────────────────────────────────────────────────────────────────────────

    function GInt(string memory name) public view returns (int256) {
        return ghostInt[keccak256(bytes(name))];
    }

    function GInt(string memory name, address who) public view returns (int256) {
        return ghostIntOf[keccak256(bytes(name))][who];
    }

    function setGInt(string memory name, int256 value) public {
        ghostInt[keccak256(bytes(name))] = value;
    }

    function setGInt(string memory name, address who, int256 value) public {
        ghostIntOf[keccak256(bytes(name))][who] = value;
    }

    function addGInt(string memory name, int256 delta) public {
        ghostInt[keccak256(bytes(name))] += delta;
    }

    function subGInt(string memory name, int256 delta) public {
        ghostInt[keccak256(bytes(name))] -= delta;
    }

    function addGInt(string memory name, address who, int256 delta) public {
        ghostIntOf[keccak256(bytes(name))][who] += delta;
    }

    function subGInt(string memory name, address who, int256 delta) public {
        ghostIntOf[keccak256(bytes(name))][who] -= delta;
    }

    // ═══════════════════════════════════════════════════════════════════════
    // BOUNDS
    // ═══════════════════════════════════════════════════════════════════════

    function bound(uint256 x, uint256 min, uint256 max) internal pure returns (uint256) {
        if (min > max) (min, max) = (max, min);
        if (x >= min && x <= max) return x;
        return min + (x % (max - min + 1));
    }

    function boundAddr(uint256 seed) internal view returns (address) {
        return actor(seed).addr;
    }

    // ═══════════════════════════════════════════════════════════════════════
    // INVARIANT INFRASTRUCTURE
    // ═══════════════════════════════════════════════════════════════════════
    //
    // Foundry calls any function starting with `invariant_` after each
    // fuzz sequence. These ARE your specification.
    //

    /// @notice Helper for invariant assertions
    function require_(bool condition, string memory message) internal pure {
        if (!condition) {
            revert(message);
        }
    }

    /// @notice Assert equality with context
    function eq(uint256 a, uint256 b, string memory ctx) internal pure {
        require_(a == b, string.concat(ctx, ": ", vm.toString(a), " != ", vm.toString(b)));
    }

    /// @notice Assert less-than-or-equal with context
    function le(uint256 a, uint256 b, string memory ctx) internal pure {
        require_(a <= b, string.concat(ctx, ": ", vm.toString(a), " > ", vm.toString(b)));
    }

    /// @notice Assert greater-than-or-equal with context
    function ge(uint256 a, uint256 b, string memory ctx) internal pure {
        require_(a >= b, string.concat(ctx, ": ", vm.toString(a), " < ", vm.toString(b)));
    }

    /// @notice Assert less-than with context
    function lt(uint256 a, uint256 b, string memory ctx) internal pure {
        require_(a < b, string.concat(ctx, ": ", vm.toString(a), " >= ", vm.toString(b)));
    }

    /// @notice Assert greater-than with context
    function gt(uint256 a, uint256 b, string memory ctx) internal pure {
        require_(a > b, string.concat(ctx, ": ", vm.toString(a), " <= ", vm.toString(b)));
    }

    /// @notice Assert int256 equality with context
    function eqInt(int256 a, int256 b, string memory ctx) internal pure {
        require_(a == b, string.concat(ctx, ": ", vm.toString(a), " != ", vm.toString(b)));
    }

    // ═══════════════════════════════════════════════════════════════════════
    // FOUNDRY HOOKS
    // ═══════════════════════════════════════════════════════════════════════

    struct FuzzSelector {
        address addr;
        bytes4[] selectors;
    }

    address[] private _targetContracts;
    address[] private _excludeContracts;
    address[] private _targetSenders;
    FuzzSelector[] private _targetSelectors;

    function target(address t) internal {
        _targetContracts.push(t);
    }

    function exclude(address t) internal {
        _excludeContracts.push(t);
    }

    function sender(address s) internal {
        _targetSenders.push(s);
    }

    function targetSelector(FuzzSelector memory fs) internal {
        _targetSelectors.push(fs);
    }

    function targetContracts() public view returns (address[] memory) {
        return _targetContracts;
    }

    function excludeContracts() public view returns (address[] memory) {
        return _excludeContracts;
    }

    function targetSenders() public view returns (address[] memory) {
        return _targetSenders;
    }

    function targetSelectors() public view returns (FuzzSelector[] memory) {
        return _targetSelectors;
    }

    /// @notice Target an actions contract with automatic selector restriction
    /// @dev If the actions contract implements selectors(), uses those. Otherwise targets all.
    function targetActions(address actions) internal {
        target(actions);
        // Try to get declared selectors from the actions contract
        try IActionSet(actions).selectors() returns (bytes4[] memory sels) {
            if (sels.length > 0) {
                targetSelector(FuzzSelector({addr: actions, selectors: sels}));
            }
        } catch {
            // No selectors() method - fuzzer will call all public functions
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// INTERFACES
// ═══════════════════════════════════════════════════════════════════════════

/// @notice Interface for action contracts that declare their fuzzable selectors
interface IActionSet {
    function selectors() external pure returns (bytes4[] memory);
}

// ═══════════════════════════════════════════════════════════════════════════
// ACTIONS BASE - DECOUPLED FROM SPEC
// ═══════════════════════════════════════════════════════════════════════════

/// @title ActionsBase - Base for action contracts (does NOT inherit Spec)
/// @notice Holds a reference to the spec for actor/ghost access. Safe to target.
/// @dev Action contracts inherit this, not Spec. This prevents the fuzzer from
///      accidentally calling ghost state mutators or other Spec internals.
abstract contract ActionsBase {
    Vm internal constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    /// @notice Reference to the spec for actor and ghost state access
    Spec public spec;

    constructor(Spec spec_) {
        spec = spec_;
    }

    /// @notice Get actor by seed
    function actor(uint256 seed) internal view returns (SpecActor memory) {
        return spec.actor(seed);
    }

    /// @notice Get actor address by seed (convenience)
    function actorAddr(uint256 seed) internal view returns (address) {
        return spec.actorAddr(seed);
    }

    /// @notice Get actor count
    function actorCount() internal view returns (uint256) {
        return spec.actorCount();
    }

    /// @notice Bound a value to a range
    function bound(uint256 x, uint256 min, uint256 max) internal pure returns (uint256) {
        if (min > max) (min, max) = (max, min);
        if (x >= min && x <= max) return x;
        return min + (x % (max - min + 1));
    }

    /// @notice Execute as actor
    modifier asActor(uint256 seed) {
        address who = actorAddr(seed);
        vm.startPrank(who);
        _;
        vm.stopPrank();
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Ghost state helpers (delegate to spec)
    // ─────────────────────────────────────────────────────────────────────────

    function addG(string memory name, uint256 delta) internal {
        spec.addG(name, delta);
    }

    function subG(string memory name, uint256 delta) internal {
        spec.subG(name, delta);
    }

    function addG(string memory name, address who, uint256 delta) internal {
        spec.addG(name, who, delta);
    }

    function subG(string memory name, address who, uint256 delta) internal {
        spec.subG(name, who, delta);
    }

    function setG(string memory name, uint256 value) internal {
        spec.setG(name, value);
    }

    function setG(string memory name, address who, uint256 value) internal {
        spec.setG(name, who, value);
    }

    function addGInt(string memory name, int256 delta) internal {
        spec.addGInt(name, delta);
    }

    function subGInt(string memory name, int256 delta) internal {
        spec.subGInt(name, delta);
    }

    function addGInt(string memory name, address who, int256 delta) internal {
        spec.addGInt(name, who, delta);
    }

    function subGInt(string memory name, address who, int256 delta) internal {
        spec.subGInt(name, who, delta);
    }
}

/// @title Actions - Deprecated alias for ActionsBase
/// @notice Use ActionsBase directly. This exists for migration compatibility.
/// @dev DEPRECATED: Actions used to inherit Spec, which exposed ghost mutators to fuzzing.
abstract contract Actions is ActionsBase {
    constructor(Spec spec_) ActionsBase(spec_) {}
}

// ═══════════════════════════════════════════════════════════════════════════
// EXAMPLE USAGE (for documentation)
// ═══════════════════════════════════════════════════════════════════════════
//
// /// @title TokenSpec - Specification for an ERC20-like token
// contract TokenSpec is Spec {
//     Token token;
//     TokenActions actions;
//
//     function setUp() public {
//         token = new Token();
//         actions = new TokenActions(this, token);
//
//         createActors(5);
//         targetActions(address(actions));  // Safe: only fuzzes action_* methods
//     }
//
//     // ════════════════════════════════════════════════════════════════════
//     // INVARIANTS - What must ALWAYS be true
//     // ════════════════════════════════════════════════════════════════════
//
//     function invariant_supplyIsConsistent() public view {
//         eq(token.totalSupply(), G("totalSupply"), "supply mismatch");
//     }
//
//     function invariant_balancesNeverExceedSupply() public view {
//         for (uint i = 0; i < _actors.length; i++) {
//             le(token.balanceOf(_actors[i].addr), token.totalSupply(), "balance > supply");
//         }
//     }
// }
//
// /// @title TokenActions - What can happen to the token
// /// @dev Inherits ActionsBase (NOT Spec) - safe to target
// contract TokenActions is ActionsBase, IActionSet {
//     Token token;
//
//     constructor(Spec spec_, Token token_) ActionsBase(spec_) {
//         token = token_;
//     }
//
//     /// @notice Declare which functions the fuzzer should call
//     function selectors() external pure returns (bytes4[] memory sels) {
//         sels = new bytes4[](2);
//         sels[0] = this.action_mint.selector;
//         sels[1] = this.action_transfer.selector;
//     }
//
//     function action_mint(uint256 actorSeed, uint256 amount) public {
//         amount = bound(amount, 0, 1e24);
//         address to = actorAddr(actorSeed);
//
//         token.mint(to, amount);
//
//         // Update ghost state - this IS the specification
//         addG("totalSupply", amount);
//         addG("balance", to, amount);
//     }
//
//     function action_transfer(uint256 fromSeed, uint256 toSeed, uint256 amount) public {
//         address from = actorAddr(fromSeed);
//         address to = actorAddr(toSeed);
//
//         uint256 balance = token.balanceOf(from);
//         if (balance == 0 || from == to) return;
//
//         amount = bound(amount, 0, balance);
//
//         vm.prank(from);
//         token.transfer(to, amount);
//
//         // Ghost state unchanged - transfer preserves supply
//         subG("balance", from, amount);
//         addG("balance", to, amount);
//     }
// }
// ═══════════════════════════════════════════════════════════════════════════
