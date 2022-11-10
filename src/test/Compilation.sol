// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

pragma experimental ABIEncoderV2;

import "../Test.sol";

// Even though this contract is in the `src/` directory, it is a test contract. It simply inherits
// from Test, which is abstract, to test compilation in CI across versions, in particular with
// via-ir. We cannot compile Test directly because it is abstract, and we don't place this in the
// `test/` directory because otherwise we need to compile that full directory, which increases CI
// time, especially with via-ir.
contract CompilationTest is Test {}
