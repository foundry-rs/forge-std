// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "../src/Test.sol";

contract StdChainsMock is Test {
    function getChain_(string memory chainAlias) public returns (Chain memory) {
        return getChain(chainAlias);
    }

    function getChain_(uint256 chainId) public returns (Chain memory) {
        return getChain(chainId);
    }

    function setChain_(string memory chainAlias, ChainData memory chainData) public {
        setChain(chainAlias, chainData);
    }

    function setFallbackToDefaultRpcUrls_(bool useDefault) public {
        setFallbackToDefaultRpcUrls(useDefault);
    }
}

contract StdChainsTest is Test {
    function testChainRpcInitialization() public {
        // RPCs specified in `foundry.toml` should be updated.
        assertEq(getChain(1).rpcUrl, "https://mainnet.infura.io/v3/b1d3925804e74152b316ca7da97060d3");
        assertEq(getChain("optimism_goerli").rpcUrl, "https://goerli.optimism.io/");
        assertEq(getChain("arbitrum_one_goerli").rpcUrl, "https://goerli-rollup.arbitrum.io/rpc/");

        // Environment variables should be the next fallback
        assertEq(getChain("arbitrum_nova").rpcUrl, "https://nova.arbitrum.io/rpc");
        vm.setEnv("ARBITRUM_NOVA_RPC_URL", "myoverride");
        assertEq(getChain("arbitrum_nova").rpcUrl, "myoverride");
        vm.setEnv("ARBITRUM_NOVA_RPC_URL", "https://nova.arbitrum.io/rpc");

        // Cannot override RPCs defined in `foundry.toml`
        vm.setEnv("MAINNET_RPC_URL", "myoverride2");
        assertEq(getChain("mainnet").rpcUrl, "https://mainnet.infura.io/v3/b1d3925804e74152b316ca7da97060d3");

        // Other RPCs should remain unchanged.
        assertEq(getChain(31337).rpcUrl, "http://127.0.0.1:8545");
        assertEq(getChain("sepolia").rpcUrl, "https://sepolia.infura.io/v3/b9794ad1ddf84dfb8c34d6bb5dca2001");
    }

    function testRpc(string memory rpcAlias) internal {
        string memory rpcUrl = getChain(rpcAlias).rpcUrl;
        vm.createSelectFork(rpcUrl);
    }

    // Ensure we can connect to the default RPC URL for each chain.
    // function testRpcs() public {
    //     testRpc("mainnet");
    //     testRpc("goerli");
    //     testRpc("sepolia");
    //     testRpc("optimism");
    //     testRpc("optimism_goerli");
    //     testRpc("arbitrum_one");
    //     testRpc("arbitrum_one_goerli");
    //     testRpc("arbitrum_nova");
    //     testRpc("polygon");
    //     testRpc("polygon_mumbai");
    //     testRpc("avalanche");
    //     testRpc("avalanche_fuji");
    //     testRpc("bnb_smart_chain");
    //     testRpc("bnb_smart_chain_testnet");
    //     testRpc("gnosis_chain");
    // }

    function testChainNoDefault() public {
        // We deploy a mock to properly test the revert.
        StdChainsMock stdChainsMock = new StdChainsMock();

        vm.expectRevert("StdChains getChain(string): Chain with alias \"does_not_exist\" not found.");
        stdChainsMock.getChain_("does_not_exist");
    }

    function testSetChainFirstFails() public {
        // We deploy a mock to properly test the revert.
        StdChainsMock stdChainsMock = new StdChainsMock();

        vm.expectRevert("StdChains setChain(string,ChainData): Chain ID 31337 already used by \"anvil\".");
        stdChainsMock.setChain_("anvil2", ChainData("Anvil", 31337, "URL"));
    }

    function testChainBubbleUp() public {
        // We deploy a mock to properly test the revert.
        StdChainsMock stdChainsMock = new StdChainsMock();

        stdChainsMock.setChain_("needs_undefined_env_var", ChainData("", 123456789, ""));
        vm.expectRevert(
            "Failed to resolve env var `UNDEFINED_RPC_URL_PLACEHOLDER` in `${UNDEFINED_RPC_URL_PLACEHOLDER}`: environment variable not found"
        );
        stdChainsMock.getChain_("needs_undefined_env_var");
    }

    function testCannotSetChain_ChainIdExists() public {
        // We deploy a mock to properly test the revert.
        StdChainsMock stdChainsMock = new StdChainsMock();

        stdChainsMock.setChain_("custom_chain", ChainData("Custom Chain", 123456789, "https://custom.chain/"));

        vm.expectRevert('StdChains setChain(string,ChainData): Chain ID 123456789 already used by "custom_chain".');

        stdChainsMock.setChain_("another_custom_chain", ChainData("", 123456789, ""));
    }

    function testSetChain() public {
        setChain("custom_chain", ChainData("Custom Chain", 123456789, "https://custom.chain/"));
        Chain memory customChain = getChain("custom_chain");
        assertEq(customChain.name, "Custom Chain");
        assertEq(customChain.chainId, 123456789);
        assertEq(customChain.chainAlias, "custom_chain");
        assertEq(customChain.rpcUrl, "https://custom.chain/");
        Chain memory chainById = getChain(123456789);
        assertEq(chainById.name, customChain.name);
        assertEq(chainById.chainId, customChain.chainId);
        assertEq(chainById.chainAlias, customChain.chainAlias);
        assertEq(chainById.rpcUrl, customChain.rpcUrl);
        customChain.name = "Another Custom Chain";
        customChain.chainId = 987654321;
        setChain("another_custom_chain", customChain);
        Chain memory anotherCustomChain = getChain("another_custom_chain");
        assertEq(anotherCustomChain.name, "Another Custom Chain");
        assertEq(anotherCustomChain.chainId, 987654321);
        assertEq(anotherCustomChain.chainAlias, "another_custom_chain");
        assertEq(anotherCustomChain.rpcUrl, "https://custom.chain/");
        // Verify the first chain data was not overwritten
        chainById = getChain(123456789);
        assertEq(chainById.name, "Custom Chain");
        assertEq(chainById.chainId, 123456789);
    }

    function testSetNoEmptyAlias() public {
        // We deploy a mock to properly test the revert.
        StdChainsMock stdChainsMock = new StdChainsMock();

        vm.expectRevert("StdChains setChain(string,ChainData): Chain alias cannot be the empty string.");
        stdChainsMock.setChain_("", ChainData("", 123456789, ""));
    }

    function testSetNoChainId0() public {
        // We deploy a mock to properly test the revert.
        StdChainsMock stdChainsMock = new StdChainsMock();

        vm.expectRevert("StdChains setChain(string,ChainData): Chain ID cannot be 0.");
        stdChainsMock.setChain_("alias", ChainData("", 0, ""));
    }

    function testGetNoChainId0() public {
        // We deploy a mock to properly test the revert.
        StdChainsMock stdChainsMock = new StdChainsMock();

        vm.expectRevert("StdChains getChain(uint256): Chain ID cannot be 0.");
        stdChainsMock.getChain_(0);
    }

    function testGetNoEmptyAlias() public {
        // We deploy a mock to properly test the revert.
        StdChainsMock stdChainsMock = new StdChainsMock();

        vm.expectRevert("StdChains getChain(string): Chain alias cannot be the empty string.");
        stdChainsMock.getChain_("");
    }

    function testChainIdNotFound() public {
        // We deploy a mock to properly test the revert.
        StdChainsMock stdChainsMock = new StdChainsMock();

        vm.expectRevert("StdChains getChain(string): Chain with alias \"no_such_alias\" not found.");
        stdChainsMock.getChain_("no_such_alias");
    }

    function testChainAliasNotFound() public {
        // We deploy a mock to properly test the revert.
        StdChainsMock stdChainsMock = new StdChainsMock();

        vm.expectRevert("StdChains getChain(uint256): Chain with ID 321 not found.");

        stdChainsMock.getChain_(321);
    }

    function testSetChain_ExistingOne() public {
        // We deploy a mock to properly test the revert.
        StdChainsMock stdChainsMock = new StdChainsMock();

        setChain("custom_chain", ChainData("Custom Chain", 123456789, "https://custom.chain/"));
        assertEq(getChain(123456789).chainId, 123456789);

        setChain("custom_chain", ChainData("Modified Chain", 999999999, "https://modified.chain/"));
        vm.expectRevert("StdChains getChain(uint256): Chain with ID 123456789 not found.");
        stdChainsMock.getChain_(123456789);

        Chain memory modifiedChain = getChain(999999999);
        assertEq(modifiedChain.name, "Modified Chain");
        assertEq(modifiedChain.chainId, 999999999);
        assertEq(modifiedChain.rpcUrl, "https://modified.chain/");
    }

    function testDontUseDefaultRpcUrl() public {
        // We deploy a mock to properly test the revert.
        StdChainsMock stdChainsMock = new StdChainsMock();

        // Should error if default RPCs flag is set to false.
        stdChainsMock.setFallbackToDefaultRpcUrls_(false);
        vm.expectRevert(
            "Failed to get environment variable `ANVIL_RPC_URL` as type `string`: environment variable not found"
        );
        stdChainsMock.getChain_(31337);
        vm.expectRevert(
            "Failed to get environment variable `SEPOLIA_RPC_URL` as type `string`: environment variable not found"
        );
        stdChainsMock.getChain_("sepolia");
    }
}
