// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.20 <0.9.0;

import {Test} from "./Test.sol";
import {Vm} from "./Vm.sol";

// ═══════════════════════════════════════════════════════════════════════════
// INVARIANT-FIRST TESTING
// ═══════════════════════════════════════════════════════════════════════════
//
// This is a THIN layer over Foundry's native invariant testing. It provides:
//
// 1. Actor management - create and manage test actors with balances
// 2. Ghost variables - track derived state for invariant checking
// 3. Handler organization - helpers for writing handlers
// 4. Bound helpers - constrain fuzzed inputs to valid ranges
//
// It does NOT replace Foundry's invariant system. You still:
// - Define invariant_ functions that Foundry calls
// - Use targetContract(), targetSender(), etc.
// - Write handler contracts that Foundry fuzzes
//
// The goal is to make invariant tests the NATURAL starting point:
//
// ```solidity
// contract TokenInvariantTest is InvariantBase {
//     Token token;
//     TokenHandler handler;
//
//     function setUp() public {
//         token = new Token();
//         handler = new TokenHandler(token);
//
//         // Create actors for the handler to use
//         _createActors(3);
//         handler.setActors(_actors());
//
//         // Tell Foundry what to fuzz
//         targetContract(address(handler));
//     }
//
//     // Foundry calls this after each fuzz sequence
//     function invariant_supplyMatchesBalances() public view {
//         assertEqUint(
//             token.totalSupply(),
//             _ghost("sumOfBalances")
//         );
//     }
// }
// ```
// ═══════════════════════════════════════════════════════════════════════════

/// @title InvariantBase - Lightweight base for invariant-first testing
/// @notice Extends Test with actor management and ghost variables
/// @dev Stays close to Foundry's native invariant testing approach
abstract contract InvariantBase is Test {
    // ═══════════════════════════════════════════════════════════════════════
    // ACTOR MANAGEMENT
    // ═══════════════════════════════════════════════════════════════════════

    address[] private __actors;
    mapping(address => uint256) private __actorKeys;
    address internal _currentActor;

    /// @notice Create a single named actor with default balance
    function _createActor(string memory name) internal returns (address actor) {
        return _createActor(name, 100 ether);
    }

    /// @notice Create a single named actor with specified balance
    function _createActor(string memory name, uint256 balance) internal returns (address actor) {
        uint256 key = uint256(keccak256(abi.encodePacked(name, __actors.length)));
        actor = vm.addr(key);
        vm.deal(actor, balance);
        vm.label(actor, name);
        __actors.push(actor);
        __actorKeys[actor] = key;
    }

    /// @notice Create multiple actors with numbered names
    function _createActors(uint256 count) internal {
        _createActors(count, "actor");
    }

    /// @notice Create multiple actors with custom prefix
    function _createActors(uint256 count, string memory prefix) internal {
        for (uint256 i = 0; i < count; i++) {
            _createActor(string.concat(prefix, vm.toString(i)));
        }
    }

    /// @notice Get all actors
    function _actors() internal view returns (address[] memory) {
        return __actors;
    }

    /// @notice Get actor count
    function _actorCount() internal view returns (uint256) {
        return __actors.length;
    }

    /// @notice Get actor by index (bounded)
    function _actor(uint256 seed) internal view returns (address) {
        return __actors[seed % __actors.length];
    }

    /// @notice Get actor's private key (for signing)
    function _actorKey(address actor) internal view returns (uint256) {
        return __actorKeys[actor];
    }

    /// @notice Modifier to execute as a random actor
    modifier asActor(uint256 seed) {
        _currentActor = _actor(seed);
        vm.startPrank(_currentActor);
        _;
        vm.stopPrank();
    }

    // ═══════════════════════════════════════════════════════════════════════
    // GHOST VARIABLES
    // ═══════════════════════════════════════════════════════════════════════
    //
    // Ghost variables track derived state that isn't stored on-chain.
    // Essential for invariants like "sum of all balances == totalSupply".
    //
    // In your handler:
    //   _addGhost("sumOfBalances", amount);  // on mint
    //   _subGhost("sumOfBalances", amount);  // on burn
    //
    // In your invariant:
    //   assertEq(token.totalSupply(), _ghost("sumOfBalances"));
    // ═══════════════════════════════════════════════════════════════════════

    mapping(bytes32 => uint256) private __ghostUint;
    mapping(bytes32 => int256) private __ghostInt;
    mapping(bytes32 => mapping(address => uint256)) private __ghostPerActor;

    /// @notice Get a ghost variable value
    function _ghost(string memory name) internal view returns (uint256) {
        return __ghostUint[keccak256(bytes(name))];
    }

    /// @notice Get a signed ghost variable value
    function _ghostInt(string memory name) internal view returns (int256) {
        return __ghostInt[keccak256(bytes(name))];
    }

    /// @notice Get a per-actor ghost variable
    function _ghostFor(string memory name, address actor) internal view returns (uint256) {
        return __ghostPerActor[keccak256(bytes(name))][actor];
    }

    /// @notice Set a ghost variable (public for handler access)
    function _setGhost(string memory name, uint256 value) public {
        __ghostUint[keccak256(bytes(name))] = value;
    }

    /// @notice Set a signed ghost variable (public for handler access)
    function _setGhostInt(string memory name, int256 value) public {
        __ghostInt[keccak256(bytes(name))] = value;
    }

    /// @notice Set a per-actor ghost variable (public for handler access)
    function _setGhostFor(string memory name, address actor, uint256 value) public {
        __ghostPerActor[keccak256(bytes(name))][actor] = value;
    }

    /// @notice Add to a ghost variable (public for handler access)
    function _addGhost(string memory name, uint256 delta) public {
        __ghostUint[keccak256(bytes(name))] += delta;
    }

    /// @notice Subtract from a ghost variable (public for handler access)
    function _subGhost(string memory name, uint256 delta) public {
        __ghostUint[keccak256(bytes(name))] -= delta;
    }

    /// @notice Add to a per-actor ghost variable (public for handler access)
    function _addGhostFor(string memory name, address actor, uint256 delta) public {
        __ghostPerActor[keccak256(bytes(name))][actor] += delta;
    }

    /// @notice Subtract from a per-actor ghost variable (public for handler access)
    function _subGhostFor(string memory name, address actor, uint256 delta) public {
        __ghostPerActor[keccak256(bytes(name))][actor] -= delta;
    }

    // ═══════════════════════════════════════════════════════════════════════
    // CALL TRACKING
    // ═══════════════════════════════════════════════════════════════════════

    mapping(bytes4 => uint256) private __callCounts;
    uint256 private __totalCalls;

    /// @notice Record a handler call (call from handlers)
    function _recordCall(bytes4 selector) internal {
        __callCounts[selector]++;
        __totalCalls++;
    }

    /// @notice Get call count for a selector
    function _callCount(bytes4 selector) internal view returns (uint256) {
        return __callCounts[selector];
    }

    /// @notice Get total call count
    function _totalCallCount() internal view returns (uint256) {
        return __totalCalls;
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// HANDLER BASE
// ═══════════════════════════════════════════════════════════════════════════

/// @title HandlerBase - Base contract for invariant test handlers
/// @notice Provides actor selection and ghost variable access
/// @dev Handlers are separate contracts that Foundry fuzzes
abstract contract HandlerBase {
    Vm internal constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    /// @notice Reference to the test contract (for ghost updates)
    InvariantBase internal _test;

    /// @notice Available actors for this handler
    address[] internal _actors;

    /// @notice Current actor (set by modifier)
    address internal _currentActor;

    constructor(InvariantBase test_) {
        _test = test_;
    }

    /// @notice Set the actors this handler can use
    function setActors(address[] memory actors_) external {
        _actors = actors_;
    }

    /// @notice Get a bounded actor from seed
    function _actor(uint256 seed) internal view returns (address) {
        if (_actors.length == 0) return address(this);
        return _actors[seed % _actors.length];
    }

    /// @notice Modifier to execute handler call as a random actor
    modifier useActor(uint256 seed) {
        if (_actors.length > 0) {
            _currentActor = _actors[seed % _actors.length];
            vm.startPrank(_currentActor);
        }
        _;
        if (_actors.length > 0) {
            vm.stopPrank();
        }
    }

    /// @notice Bound a value to a range (mirrors StdUtils.bound)
    function _bound(uint256 x, uint256 min, uint256 max) internal pure returns (uint256) {
        if (min > max) (min, max) = (max, min);
        if (x >= min && x <= max) return x;
        uint256 range = max - min + 1;
        return min + (x % range);
    }

    /// @notice Bound to non-zero
    function _boundNonZero(uint256 x, uint256 max) internal pure returns (uint256) {
        return _bound(x, 1, max);
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// EXAMPLE DOCUMENTATION
// ═══════════════════════════════════════════════════════════════════════════
//
// MINIMAL INVARIANT TEST STRUCTURE:
//
// ```solidity
// // 1. Define your handler (what Foundry fuzzes)
// contract TokenHandler is HandlerBase {
//     Token token;
//
//     constructor(Token token_, InvariantBase test_) HandlerBase(test_) {
//         token = token_;
//     }
//
//     function mint(uint256 actorSeed, uint256 amount) external useActor(actorSeed) {
//         amount = _bound(amount, 0, 1e24);
//         token.mint(_currentActor, amount);
//
//         // Update ghost variable
//         _test._addGhost("totalMinted", amount);
//     }
//
//     function transfer(uint256 fromSeed, uint256 toSeed, uint256 amount) external useActor(fromSeed) {
//         address to = _actor(toSeed);
//         uint256 balance = token.balanceOf(_currentActor);
//         amount = _bound(amount, 0, balance);
//
//         if (amount > 0) {
//             token.transfer(to, amount);
//         }
//     }
// }
//
// // 2. Define your invariant test
// contract TokenInvariantTest is InvariantBase {
//     Token token;
//     TokenHandler handler;
//
//     function setUp() public {
//         token = new Token();
//         handler = new TokenHandler(token, this);
//
//         _createActors(5);
//         handler.setActors(_actors());
//
//         targetContract(address(handler));
//     }
//
//     // Foundry calls invariant_ functions after each fuzz sequence
//     function invariant_supplyConsistency() public view {
//         assertEqUint(token.totalSupply(), _ghost("totalMinted"));
//     }
//
//     function invariant_noBalanceExceedsSupply() public view {
//         for (uint256 i = 0; i < _actorCount(); i++) {
//             assertLeUint(token.balanceOf(_actors()[i]), token.totalSupply());
//         }
//     }
// }
// ```
//
// KEY PRINCIPLES:
// - invariant_ functions define your specification
// - Handlers exercise state transitions
// - Ghost variables track derived state
// - Foundry does the fuzzing - we just provide structure
// ═══════════════════════════════════════════════════════════════════════════
