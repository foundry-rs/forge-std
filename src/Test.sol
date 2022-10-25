// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import {CommonBase} from "./Common.sol";
import "ds-test/test.sol";
// forgefmt: disable-next-line
import {console, console2, StdAssertions, StdCheats, stdError, stdJson, stdMath, StdStorage, stdStorage, StdUtils, Vm} from "./Components.sol";

abstract contract TestBase is CommonBase {}

abstract contract Test is TestBase, DSTest, StdAssertions, StdCheats, StdUtils {}
