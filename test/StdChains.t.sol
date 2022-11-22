// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "../src/Test.sol";

contract StdChainsTest is Test {
    function testChainRpcInitialization() public {
        // RPCs specified in `foundry.toml` should be updated.
        assertEq(getChain("mainnet").rpcUrl, "https://mainnet.infura.io/v3/7a8769b798b642f6933f2ed52042bd70");
        assertEq(getChain("optimism_goerli").rpcUrl, "https://goerli.optimism.io/");
        assertEq(getChain("arbitrum_one_goerli").rpcUrl, "https://goerli-rollup.arbitrum.io/rpc/");

        // Other RPCs should remain unchanged.
        assertEq(getChain("anvil").rpcUrl, "http://127.0.0.1:8545");
        assertEq(getChain("hardhat").rpcUrl, "http://127.0.0.1:8545");
        assertEq(getChain("sepolia").rpcUrl, "https://rpc.sepolia.dev");
    }

    // Ensure we can connect to the default RPC URL for each chain.
    function testRpcs() public {
        (string[2][] memory rpcs) = vm.rpcUrls();
        for (uint256 i = 0; i < rpcs.length; i++) {
            ( /* string memory name */ , string memory rpcUrl) = (rpcs[i][0], rpcs[i][1]);
            vm.createSelectFork(rpcUrl);
        }
    }

    function testSetChain() public {
        setChain({name: "custom_chain", chainId: 123456789, rpcUrl: "https://custom.chain/"});
        Chain memory customChain = getChain("custom_chain");
        assertEq(customChain.name, "custom_chain");
        assertEq(customChain.chainId, 123456789);
        assertEq(customChain.rpcUrl, "https://custom.chain/");
    }
}
