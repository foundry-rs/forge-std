// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "./Cheats.sol";
import "./console.sol";
import "./console2.sol";
import "./Utils.sol";

abstract contract Script is Cheats, Utils {
    bool public IS_SCRIPT = true;
}
