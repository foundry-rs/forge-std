// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "ds-test/test.sol";
import {CommonBase} from "src/Common.sol";
// forgefmt: disable-next-line
import {console, console2, StdAssertions, StdCheats, stdError, stdJson, stdMath, StdStorage, stdStorage, StdUtils, Vm} from "src/Components.sol";

abstract contract TestBase is CommonBase {}

abstract contract Test is TestBase, DSTest, StdAssertions, StdCheats, StdUtils {}
