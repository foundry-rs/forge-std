// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.20 <0.9.0;

import {InvariantBase, HandlerBase} from "../src/InvariantBase.sol";

// ═══════════════════════════════════════════════════════════════════════════
// EXAMPLE: INVARIANT-FIRST TESTING FOR A SIMPLE TOKEN
// ═══════════════════════════════════════════════════════════════════════════
//
// This demonstrates the invariant-first testing pattern:
//
// 1. Start with INVARIANTS (the specification)
// 2. Write HANDLERS that exercise state transitions
// 3. Use GHOST VARIABLES to track derived state
// 4. Let Foundry FUZZ the handlers
//
// Run with: forge test --match-contract TokenInvariant -vvv
// ═══════════════════════════════════════════════════════════════════════════

/// @notice Simple token for demonstration
contract SimpleToken {
    string public name = "Test Token";
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
        totalSupply += amount;
    }

    function burn(address from, uint256 amount) external {
        require(balanceOf[from] >= amount, "Insufficient balance");
        balanceOf[from] -= amount;
        totalSupply -= amount;
    }

    function transfer(address from, address to, uint256 amount) external {
        require(balanceOf[from] >= amount, "Insufficient balance");
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// HANDLER - What Foundry fuzzes
// ═══════════════════════════════════════════════════════════════════════════

contract TokenHandler is HandlerBase {
    SimpleToken public token;

    // Track which actors have received tokens (for invariant checking)
    address[] public touchedActors;
    mapping(address => bool) public isTouched;

    constructor(SimpleToken token_, InvariantBase test_) HandlerBase(test_) {
        token = token_;
    }

    /// @notice Handler for minting tokens
    function mint(uint256 actorSeed, uint256 amount) external useActor(actorSeed) {
        // Bound amount to reasonable range
        amount = _bound(amount, 0, 1e24);

        // Execute the action
        token.mint(_currentActor, amount);

        // Track ghost state
        _test._addGhost("sumOfBalances", amount);
        _test._addGhostFor("balance", _currentActor, amount);

        // Track touched actors
        if (!isTouched[_currentActor]) {
            isTouched[_currentActor] = true;
            touchedActors.push(_currentActor);
        }
    }

    /// @notice Handler for burning tokens
    function burn(uint256 actorSeed, uint256 amount) external useActor(actorSeed) {
        uint256 balance = token.balanceOf(_currentActor);
        // Only burn if actor has balance
        if (balance == 0) return;

        amount = _bound(amount, 0, balance);

        token.burn(_currentActor, amount);

        // Track ghost state
        _test._subGhost("sumOfBalances", amount);
        _test._subGhostFor("balance", _currentActor, amount);
    }

    /// @notice Handler for transfers
    function transfer(uint256 fromSeed, uint256 toSeed, uint256 amount) external useActor(fromSeed) {
        address to = _actor(toSeed);
        uint256 balance = token.balanceOf(_currentActor);

        // Skip if no balance or self-transfer
        if (balance == 0 || _currentActor == to) return;

        amount = _bound(amount, 0, balance);

        token.transfer(_currentActor, to, amount);

        // Update ghost per-actor tracking
        _test._subGhostFor("balance", _currentActor, amount);
        _test._addGhostFor("balance", to, amount);

        // Track touched actors
        if (!isTouched[to]) {
            isTouched[to] = true;
            touchedActors.push(to);
        }
    }

    /// @notice Get all actors that have been touched
    function getTouchedActors() external view returns (address[] memory) {
        return touchedActors;
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// INVARIANT TEST - The specification
// ═══════════════════════════════════════════════════════════════════════════

contract TokenInvariantTest is InvariantBase {
    SimpleToken token;
    TokenHandler handler;

    function setUp() public {
        // Deploy contracts
        token = new SimpleToken();
        handler = new TokenHandler(token, this);

        // Create actors
        _createActors(5);
        handler.setActors(_actors());

        // Tell Foundry what to fuzz
        targetContract(address(handler));

        // Optionally exclude specific selectors
        // excludeSelector(FuzzSelector({
        //     addr: address(handler),
        //     selectors: new bytes4[](1)  // would fill with selectors to skip
        // }));
    }

    // ═══════════════════════════════════════════════════════════════════════
    // INVARIANTS - These define the specification
    // ═══════════════════════════════════════════════════════════════════════

    /// @notice CRITICAL: Total supply must equal sum of all balances
    function invariant_supplyEqualsBalances() public view {
        assertEqUint(
            token.totalSupply(),
            _ghost("sumOfBalances"),
            "Supply must equal sum of balances"
        );
    }

    /// @notice CRITICAL: No individual balance can exceed total supply
    function invariant_noBalanceExceedsSupply() public view {
        address[] memory actors = _actors();
        for (uint256 i = 0; i < actors.length; i++) {
            assertLeUint(
                token.balanceOf(actors[i]),
                token.totalSupply(),
                "No balance should exceed supply"
            );
        }
    }

    /// @notice CONSISTENCY: Ghost per-actor balances match actual balances
    function invariant_ghostBalancesMatch() public view {
        address[] memory actors = _actors();
        for (uint256 i = 0; i < actors.length; i++) {
            assertEqUint(
                token.balanceOf(actors[i]),
                _ghostFor("balance", actors[i]),
                "Ghost balance must match actual"
            );
        }
    }

    /// @notice SANITY: Call summary for debugging
    function invariant_callSummary() public view {
        // This invariant always passes but logs useful info
        // console2.log("Total supply:", token.totalSupply());
        // console2.log("Sum of balances:", _ghost("sumOfBalances"));
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// ALTERNATIVE PATTERN: BOUNDED PROPERTIES
// ═══════════════════════════════════════════════════════════════════════════

/// @notice Demonstrates stateless fuzz testing that can complement invariants
contract TokenPropertyTest is InvariantBase {
    SimpleToken token;

    function setUp() public {
        token = new SimpleToken();
        _createActors(3);
    }

    /// @notice Property: mint increases supply by exact amount
    function testFuzz_mintIncreasesSupply(uint256 actorSeed, uint256 amount) public {
        address actor = _actor(actorSeed);
        amount = bound(amount, 0, 1e24);

        uint256 supplyBefore = token.totalSupply();

        token.mint(actor, amount);

        assertEqUint(token.totalSupply(), supplyBefore + amount);
    }

    /// @notice Property: transfer preserves total supply
    function testFuzz_transferPreservesSupply(
        uint256 fromSeed,
        uint256 toSeed,
        uint256 mintAmount,
        uint256 transferAmount
    ) public {
        address from = _actor(fromSeed);
        address to = _actor(toSeed);
        vm.assume(from != to);

        mintAmount = bound(mintAmount, 1, 1e24);
        token.mint(from, mintAmount);

        transferAmount = bound(transferAmount, 0, mintAmount);
        uint256 supplyBefore = token.totalSupply();

        token.transfer(from, to, transferAmount);

        assertEqUint(token.totalSupply(), supplyBefore);
    }

    /// @notice Property: burn decreases supply by exact amount
    function testFuzz_burnDecreasesSupply(uint256 actorSeed, uint256 mintAmount, uint256 burnAmount) public {
        address actor = _actor(actorSeed);
        mintAmount = bound(mintAmount, 1, 1e24);
        token.mint(actor, mintAmount);

        burnAmount = bound(burnAmount, 0, mintAmount);
        uint256 supplyBefore = token.totalSupply();

        token.burn(actor, burnAmount);

        assertEqUint(token.totalSupply(), supplyBefore - burnAmount);
    }
}
