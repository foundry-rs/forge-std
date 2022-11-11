// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

pragma experimental ABIEncoderV2;

import "../Test.sol";
import "../Script.sol";

// Even though these contracts are in the `src/` directory, they are test contracts. They simply inherit
// from the abstract contracts to test compilation in CI across versions, in particular with
// via-ir. We cannot compile Test directly because it is abstract, and we don't place this in the
// `test/` directory because otherwise we need to compile that full directory, which increases CI
// time, especially with via-ir.
contract CompilationTest is Test {}

contract CompilationTestBase is TestBase {}

contract CompilationScript is Script {}

contract CompilationScriptBase is ScriptBase {}
