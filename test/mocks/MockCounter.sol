// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/// @notice Simple counter contract for testing multi-EVM deployments.
contract MockCounter {
    uint256 public count;

    constructor() payable {
        count = 0;
    }

    function increment() public {
        count++;
    }

    function reset() public {
        count = 0;
    }
}
