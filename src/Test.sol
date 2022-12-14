// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import {CommonBase} from "./Common.sol";
import {DSTest} from "ds-test/test.sol";
import {console} from "./console.sol";
import {console2} from "./console2.sol";
import {StdAssertions} from "./StdAssertions.sol";
import {StdChains} from "./StdChains.sol";
import {StdCheats} from "./StdCheats.sol";
import {stdError} from "./StdError.sol";
import {stdJson} from "./StdJson.sol";
import {stdMath} from "./StdMath.sol";
import {StdStorage, stdStorage} from "./StdStorage.sol";
import {StdUtils} from "./StdUtils.sol";
import {Vm} from "./Vm.sol";

abstract contract TestBase is CommonBase {
    // Default address for tx.origin and msg.sender, 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38.
    address internal constant DEFAULT_SENDER = address(uint160(uint256(keccak256("foundry default caller"))));

    // Address of the test contract, deployed by the DEFAULT_SENDER.
    address internal constant DEFAULT_TEST_CONTRACT = 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f;
}

abstract contract Test is DSTest, StdAssertions, StdChains, StdCheats, StdUtils, TestBase {}
