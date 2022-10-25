// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "../src/Test.sol";

contract StdChainsTest is Test {
    function testChainRpcInitialization() public {
        // RPCs specified in `foundry.toml` should be updated.
        assertEq(stdChains.Mainnet.rpcUrl, "https://api.mycryptoapi.com/eth/");
        assertEq(stdChains.OptimismGoerli.rpcUrl, "https://goerli.optimism.io/");
        assertEq(stdChains.ArbitrumOneGoerli.rpcUrl, "https://goerli-rollup.arbitrum.io/rpc/");

        // Other RPCs should remain unchanged.
        assertEq(stdChains.Anvil.rpcUrl, "http://127.0.0.1:8545");
        assertEq(stdChains.Hardhat.rpcUrl, "http://127.0.0.1:8545");
        assertEq(stdChains.Sepolia.rpcUrl, "https://rpc.sepolia.dev");
    }

    // Ensure we can connect to the default RPC URL for each chain.
    function testRpcs() public {
        (string[2][] memory rpcs) = vm.rpcUrls();
        for (uint256 i = 0; i < rpcs.length; i++) {
            ( /* string memory name */ , string memory rpcUrl) = (rpcs[i][0], rpcs[i][1]);
            vm.createSelectFork(rpcUrl);
        }
    }
}
