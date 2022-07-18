// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "./Assertions.sol";
import "./Cheats.sol";
import "./console.sol";
import "./console2.sol";
import "./Errors.sol";
import "./Math.sol";
import "./Storage.sol";
import "./Utils.sol";

abstract contract Test is Assertions, Cheats, Utils {
    address internal constant VM_ADDRESS =
        address(bytes20(uint160(uint256(keccak256("hevm cheat code")))));

    StdStorage internal stdstore;
    Vm internal constant vm = Vm(VM_ADDRESS);
}
