// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import {CommonBase} from "./Common.sol";
import "./Components.sol";
import "ds-test/test.sol";

abstract contract TestBase is CommonBase {}

abstract contract Test is TestBase, DSTest, StdAssertions, StdCheats, StdUtils {}
