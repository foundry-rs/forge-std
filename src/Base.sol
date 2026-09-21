// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.13 <0.9.0;

import {StdStorage} from "./StdStorage.sol";
import {Vm, VmSafe} from "./Vm.sol";

/// @notice Base contract shared by `TestBase` and `ScriptBase`, exposing the addresses and
///         instances that every Forge test or script depends on (the cheatcode VM, the console,
///         the deterministic CREATE2 factory, and so on).
abstract contract CommonBase {
    /// @notice The cheat code address that exposes Forge's VM API.
    /// @dev Calculated as `address(uint160(uint256(keccak256("hevm cheat code"))))`.
    address internal constant VM_ADDRESS = 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D;

    /// @notice The address used by `console.sol` / `console2.sol` to forward log payloads via staticcall.
    /// @dev Calculated as `address(uint160(uint88(bytes11("console.log"))))`.
    address internal constant CONSOLE = 0x000000000000000000636F6e736F6c652e6c6f67;

    /// @notice The deterministic CREATE2 factory used when deploying via create2.
    /// @dev Taken from https://github.com/Arachnid/deterministic-deployment-proxy.
    address internal constant CREATE2_FACTORY = 0x4e59b44847b379578588920cA78FbF26c0B4956C;

    /// @notice The default address for `tx.origin` and `msg.sender` during Forge tests and scripts.
    /// @dev Calculated as `address(uint160(uint256(keccak256("foundry default caller"))))`.
    address internal constant DEFAULT_SENDER = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;

    /// @notice The address of the first contract `CREATE`d by a running test contract.
    /// @dev When running tests, each test contract is `CREATE`d by `DEFAULT_SENDER` with nonce 1.
    ///      Calculated as `VM.computeCreateAddress(VM.computeCreateAddress(DEFAULT_SENDER, 1), 1)`.
    address internal constant DEFAULT_TEST_CONTRACT = 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f;

    /// @notice The deterministic deployment address of the Multicall3 contract.
    /// @dev Taken from https://www.multicall3.com.
    address internal constant MULTICALL3_ADDRESS = 0xcA11bde05977b3631167028862bE2a173976CA11;

    /// @notice The order of the secp256k1 curve, useful when constraining signature components.
    uint256 internal constant SECP256K1_ORDER =
        115792089237316195423570985008687907852837564279074904382605163141518161494337;

    /// @notice The largest representable `uint256`, equal to `type(uint256).max`.
    uint256 internal constant UINT256_MAX =
        115792089237316195423570985008687907853269984665640564039457584007913129639935;

    /// @notice The cheatcode VM interface, callable from both tests and scripts.
    Vm internal constant vm = Vm(VM_ADDRESS);

    /// @notice Standard-library helper for reading and writing storage slots by name.
    StdStorage internal stdstore;
}

/// @notice Base contract that test contracts inherit from. Adds no extra state beyond `CommonBase`
///         but exists as a distinct type so cheatcodes restricted to tests can be gated.
abstract contract TestBase is CommonBase {}

/// @notice Base contract that script contracts inherit from. Exposes the safe (script-only)
///         subset of the cheatcode VM in addition to everything provided by `CommonBase`.
abstract contract ScriptBase is CommonBase {
    /// @notice The safe-cheatcode VM interface available to scripts (no test-only cheatcodes).
    VmSafe internal constant vmSafe = VmSafe(VM_ADDRESS);
}
