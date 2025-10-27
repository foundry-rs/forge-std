// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

/// @notice Simple counter contract for testing multi-EVM deployments.
contract MockCounter {
    uint256 public count;

    function increment() public {
        count++;
    }

    function reset() public {
        count = 0;
    }
}
