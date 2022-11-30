// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "../src/Test.sol";

contract StdChainsTest is Test {
    function testChainRpcInitialization() public {
        // RPCs specified in `foundry.toml` should be updated.
        assertEq(getChain(1).rpcUrl, "https://mainnet.infura.io/v3/7a8769b798b642f6933f2ed52042bd70");
        assertEq(getChain("optimism_goerli").rpcUrl, "https://goerli.optimism.io/");
        assertEq(getChain("arbitrum_one_goerli").rpcUrl, "https://goerli-rollup.arbitrum.io/rpc/");

        // Other RPCs should remain unchanged.
        assertEq(getChain(31337).rpcUrl, "http://127.0.0.1:8545");
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

    function testCannotSetChain_ChainIdExists() public {
        setChain({key: "custom_chain", name: "Custom Chain", chainId: 123456789, rpcUrl: "https://custom.chain/"});

        vm.expectRevert(
            'StdChains setChain(string,string,uint256,string): Chain ID 123456789 already used by "custom_chain".'
        );

        setChain({key: "another_custom_chain", name: "", chainId: 123456789, rpcUrl: ""});
    }

    function testSetChain() public {
        setChain({key: "custom_chain", name: "Custom Chain", chainId: 123456789, rpcUrl: "https://custom.chain/"});
        Chain memory customChain = getChain("custom_chain");
        assertEq(customChain.name, "Custom Chain");
        assertEq(customChain.chainId, 123456789);
        assertEq(customChain.rpcUrl, "https://custom.chain/");
        Chain memory chainById = getChain(123456789);
        assertEq(chainById.name, customChain.name);
        assertEq(chainById.chainId, customChain.chainId);
        assertEq(chainById.rpcUrl, customChain.rpcUrl);
    }

    function testSetChain_ExistingOne() public {
        setChain({key: "custom_chain", name: "Custom Chain", chainId: 123456789, rpcUrl: "https://custom.chain/"});
        assertEq(getChain(123456789).chainId, 123456789);

        setChain({key: "custom_chain", name: "Modified Chain", chainId: 999999999, rpcUrl: "https://modified.chain/"});
        assertEq(getChain(123456789).chainId, 0);

        Chain memory modifiedChain = getChain(999999999);
        assertEq(modifiedChain.name, "Modified Chain");
        assertEq(modifiedChain.chainId, 999999999);
        assertEq(modifiedChain.rpcUrl, "https://modified.chain/");
    }
}
