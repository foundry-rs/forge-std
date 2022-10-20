// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "src/Test.sol";

contract StdChainsTest is Test {
    function testChainRpcInitialization() public {
        // RPCs specified in `foundry.toml` should be updated.
        assertEq(stdChains.Mainnet.rpcUrl, "https://mainnet-rpc.com");
        assertEq(stdChains.OptimismGoerli.rpcUrl, "https://optimism_goerli-rpc.com");
        assertEq(stdChains.ArbitrumOneGoerli.rpcUrl, "https://arbitrum_one_goerli-rpc.com");

        // Other RPCs should remain unchanged.
        assertEq(stdChains.Anvil.rpcUrl, "http://127.0.0.1:8545");
        assertEq(stdChains.Hardhat.rpcUrl, "http://127.0.0.1:8545");
    }
}
