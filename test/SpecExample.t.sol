// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.20 <0.9.0;

import {Spec, ActionsBase, IActionSet} from "../src/Spec.sol";

// ═══════════════════════════════════════════════════════════════════════════
//
// SPECIFICATION-FIRST TESTING EXAMPLE
//
// This file demonstrates the new paradigm:
//
// 1. The SPEC (invariants) comes first - it IS the specification
// 2. ACTIONS define how state can change (inherit ActionsBase, not Spec)
// 3. GHOST variables track "what should be true"
// 4. The fuzzer proves the spec holds
//
// Run with:
//   forge test --match-contract VaultSpec -vvv
//
// ═══════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════
// THE CONTRACT UNDER TEST
// ═══════════════════════════════════════════════════════════════════════════

/// @notice A simple vault that tracks deposits per user
contract Vault {
    mapping(address => uint256) public deposits;
    uint256 public totalDeposits;

    function deposit() external payable {
        deposits[msg.sender] += msg.value;
        totalDeposits += msg.value;
    }

    function withdraw(uint256 amount) external {
        require(deposits[msg.sender] >= amount, "insufficient");
        deposits[msg.sender] -= amount;
        totalDeposits -= amount;
        payable(msg.sender).transfer(amount);
    }

    function balance() external view returns (uint256) {
        return address(this).balance;
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// THE SPECIFICATION
// ═══════════════════════════════════════════════════════════════════════════

/// @title VaultSpec - The specification for Vault behavior
/// @notice Invariants define WHAT must always be true
contract VaultSpec is Spec {
    Vault vault;
    VaultActions actions;

    function setUp() public {
        vault = new Vault();
        actions = new VaultActions(this, vault);

        createActors(5);

        // targetActions auto-discovers selectors from IActionSet
        targetActions(address(actions));
    }

    // ═══════════════════════════════════════════════════════════════════════
    // INVARIANTS - The specification itself
    // ═══════════════════════════════════════════════════════════════════════

    /// @notice The vault's balance must equal total deposits
    function invariant_solvency() public view {
        eq(vault.balance(), vault.totalDeposits(), "vault is insolvent");
    }

    /// @notice Total deposits must match our ghost tracking
    function invariant_totalDepositsAccurate() public view {
        eq(vault.totalDeposits(), G("totalDeposits"), "totalDeposits mismatch");
    }

    /// @notice No individual can have more deposited than the total
    function invariant_noDepositExceedsTotal() public view {
        for (uint256 i = 0; i < _actors.length; i++) {
            le(vault.deposits(_actors[i].addr), vault.totalDeposits(), "deposit > total");
        }
    }

    /// @notice Individual deposits must match ghost tracking
    function invariant_individualDepositsAccurate() public view {
        for (uint256 i = 0; i < _actors.length; i++) {
            address who = _actors[i].addr;
            eq(vault.deposits(who), G("deposit", who), string.concat("deposit mismatch for actor ", vm.toString(i)));
        }
    }

    /// @notice Sum of all deposits equals total
    function invariant_sumEqualsTotal() public view {
        uint256 sum = 0;
        for (uint256 i = 0; i < _actors.length; i++) {
            sum += vault.deposits(_actors[i].addr);
        }
        eq(sum, vault.totalDeposits(), "sum != total");
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// THE ACTIONS
// ═══════════════════════════════════════════════════════════════════════════

/// @title VaultActions - What can happen to the vault
/// @notice Inherits ActionsBase (not Spec) - safe to target without manual selector filtering
contract VaultActions is ActionsBase, IActionSet {
    Vault vault;

    constructor(Spec spec_, Vault vault_) ActionsBase(spec_) {
        vault = vault_;
    }

    /// @notice Declare which functions the fuzzer should call
    function selectors() external pure returns (bytes4[] memory sels) {
        sels = new bytes4[](2);
        sels[0] = this.action_deposit.selector;
        sels[1] = this.action_withdraw.selector;
    }

    /// @notice Action: deposit ETH into the vault
    function action_deposit(uint256 actorSeed, uint256 amount) public {
        amount = bound(amount, 0, 10 ether);
        address who = actorAddr(actorSeed);

        if (who.balance < amount) return;

        vm.prank(who);
        vault.deposit{value: amount}();

        // Update ghost state - THIS IS THE SPEC
        addG("totalDeposits", amount);
        addG("deposit", who, amount);
    }

    /// @notice Action: withdraw ETH from the vault
    function action_withdraw(uint256 actorSeed, uint256 amount) public {
        address who = actorAddr(actorSeed);

        uint256 deposited = vault.deposits(who);
        if (deposited == 0) return;
        amount = bound(amount, 0, deposited);

        vm.prank(who);
        vault.withdraw(amount);

        // Update ghost state
        subG("totalDeposits", amount);
        subG("deposit", who, amount);
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// PROPERTY TESTS (complement invariants)
// ═══════════════════════════════════════════════════════════════════════════

/// @title VaultProperties - Individual property tests
contract VaultProperties is Spec {
    Vault vault;

    function setUp() public {
        vault = new Vault();
        createActors(3);
    }

    /// @notice Property: deposit increases balance by exact amount
    function testFuzz_depositIncreasesBalance(uint256 actorSeed, uint256 amount) public {
        address who = _actor(actorSeed).addr;
        amount = bound(amount, 0, 10 ether);

        uint256 before = vault.deposits(who);

        vm.prank(who);
        vault.deposit{value: amount}();

        eq(vault.deposits(who), before + amount, "deposit didn't increase correctly");
    }

    /// @notice Property: withdraw decreases balance by exact amount
    function testFuzz_withdrawDecreasesBalance(uint256 actorSeed, uint256 depositAmt, uint256 withdrawAmt) public {
        address who = _actor(actorSeed).addr;
        depositAmt = bound(depositAmt, 1, 10 ether);

        vm.prank(who);
        vault.deposit{value: depositAmt}();

        withdrawAmt = bound(withdrawAmt, 0, depositAmt);
        uint256 before = vault.deposits(who);

        vm.prank(who);
        vault.withdraw(withdrawAmt);

        eq(vault.deposits(who), before - withdrawAmt, "withdraw didn't decrease correctly");
    }

    /// @notice Property: can't withdraw more than deposited
    function testFuzz_cantOverdraw(uint256 actorSeed, uint256 depositAmt, uint256 withdrawAmt) public {
        address who = _actor(actorSeed).addr;
        depositAmt = bound(depositAmt, 0, 10 ether);

        vm.prank(who);
        vault.deposit{value: depositAmt}();

        withdrawAmt = bound(withdrawAmt, depositAmt + 1, type(uint256).max);

        vm.prank(who);
        vm.expectRevert("insufficient");
        vault.withdraw(withdrawAmt);
    }
}
