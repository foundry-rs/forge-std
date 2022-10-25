// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;
pragma experimental ABIEncoderV2;

import "./Vm.sol";

/// @dev To add a new chain:
///   1. Add it into the `Chains` struct, named using CamelCase.
///   2. Initialize it in the `stdChains` declaration.
///   3. Add a corresponding `else if` line into the constructor, remembering to check for both
///      underscore and hyphenated versions of the chain-name when appropriate.
abstract contract StdChains {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    struct Chain {
        // The chain name, using underscores as the separator to match `foundry.toml` conventions.
        string name;
        // The chain's Chain ID.
        uint256 chainId;
        // A default RPC endpoint for this chain.
        // NOTE: This default RPC URL is included for convenience to facilitate quick tests and
        // experimentation. Do not use this RPC URL for production test suites, CI, or other heavy
        // usage as you will be throttled and this is a disservice to others who need this endpoint.
        string rpcUrl;
    }

    struct Chains {
        Chain Anvil;
        Chain Hardhat;
        Chain Mainnet;
        Chain Goerli;
        Chain Sepolia;
        Chain Optimism;
        Chain OptimismGoerli;
        Chain ArbitrumOne;
        Chain ArbitrumOneGoerli;
        Chain ArbitrumNova;
        Chain Polygon;
        Chain PolygonMumbai;
        Chain Avalanche;
        Chain AvalancheFuji;
        Chain BnbSmartChain;
        Chain BnbSmartChainTestnet;
        Chain GnosisChain;
    }

    Chains stdChains = Chains({
        Anvil: Chain("Anvil", 31337, "http://127.0.0.1:8545"),
        Hardhat: Chain("Hardhat", 31337, "http://127.0.0.1:8545"),
        Mainnet: Chain("Mainnet", 1, "https://api.mycryptoapi.com/eth"),
        Goerli: Chain("Goerli", 5, "https://goerli.infura.io/v3/84842078b09946638c03157f83405213"), // Default Infura key from ethers.js: https://github.com/ethers-io/ethers.js/blob/c80fcddf50a9023486e9f9acb1848aba4c19f7b6/packages/providers/src.ts/infura-provider.ts
        Sepolia: Chain("Sepolia", 11155111, "https://rpc.sepolia.dev"),
        Optimism: Chain("Optimism", 10, "https://mainnet.optimism.io"),
        OptimismGoerli: Chain("OptimismGoerli", 420, "https://goerli.optimism.io"),
        ArbitrumOne: Chain("ArbitrumOne", 42161, "https://arb1.arbitrum.io/rpc"),
        ArbitrumOneGoerli: Chain("ArbitrumOneGoerli", 421613, "https://goerli-rollup.arbitrum.io/rpc"),
        ArbitrumNova: Chain("ArbitrumNova", 42170, "https://nova.arbitrum.io/rpc"),
        Polygon: Chain("Polygon", 137, "https://polygon-rpc.com"),
        PolygonMumbai: Chain("PolygonMumbai", 80001, "https://rpc-mumbai.matic.today"),
        Avalanche: Chain("Avalanche", 43114, "https://api.avax.network/ext/bc/C/rpc"),
        AvalancheFuji: Chain("AvalancheFuji", 43113, "https://api.avax-test.network/ext/bc/C/rpc"),
        BnbSmartChain: Chain("BnbSmartChain", 56, "https://bsc-dataseed1.binance.org"),
        BnbSmartChainTestnet: Chain("BnbSmartChainTestnet", 97, "https://data-seed-prebsc-1-s1.binance.org:8545"),
        GnosisChain: Chain("GnosisChain", 100, "https://rpc.gnosischain.com")
    });

    // TODO how can we hide the compiler warnings by default? We can't remove the visibility since it's needed for ^0.6.2 compatibility.
    constructor() internal {
        // Loop over RPC URLs in the config file to replace the default RPC URLs
        (string[2][] memory rpcs) = vm.rpcUrls();
        for (uint256 i = 0; i < rpcs.length; i++) {
            (string memory name, string memory rpcUrl) = (rpcs[i][0], rpcs[i][1]);
            // forgefmt: disable-start
            if (isEqual(name, "anvil")) stdChains.Anvil.rpcUrl = rpcUrl;
            else if (isEqual(name, "hardhat")) stdChains.Hardhat.rpcUrl = rpcUrl;
            else if (isEqual(name, "mainnet")) stdChains.Mainnet.rpcUrl = rpcUrl;
            else if (isEqual(name, "goerli")) stdChains.Goerli.rpcUrl = rpcUrl;
            else if (isEqual(name, "sepolia")) stdChains.Sepolia.rpcUrl = rpcUrl;
            else if (isEqual(name, "optimism")) stdChains.Optimism.rpcUrl = rpcUrl;
            else if (isEqual(name, "optimism_goerli", "optimism-goerli")) stdChains.OptimismGoerli.rpcUrl = rpcUrl;
            else if (isEqual(name, "arbitrum_one", "arbitrum-one")) stdChains.ArbitrumOne.rpcUrl = rpcUrl;
            else if (isEqual(name, "arbitrum_one_goerli", "arbitrum-one-goerli")) stdChains.ArbitrumOneGoerli.rpcUrl = rpcUrl;
            else if (isEqual(name, "arbitrum_nova", "arbitrum-nova")) stdChains.ArbitrumNova.rpcUrl = rpcUrl;
            else if (isEqual(name, "polygon")) stdChains.Polygon.rpcUrl = rpcUrl;
            else if (isEqual(name, "polygon_mumbai", "polygon-mumbai")) stdChains.PolygonMumbai.rpcUrl = rpcUrl;
            else if (isEqual(name, "avalanche")) stdChains.Avalanche.rpcUrl = rpcUrl;
            else if (isEqual(name, "avalanche_fuji", "avalanche-fuji")) stdChains.AvalancheFuji.rpcUrl = rpcUrl;
            else if (isEqual(name, "bnb_smart_chain", "bnb-smart-chain")) stdChains.BnbSmartChain.rpcUrl = rpcUrl;
            else if (isEqual(name, "bnb_smart_chain_testnet", "bnb-smart-chain-testnet")) stdChains.BnbSmartChainTestnet.rpcUrl = rpcUrl;
            else if (isEqual(name, "gnosis_chain", "gnosis-chain")) stdChains.GnosisChain.rpcUrl = rpcUrl;
            // forgefmt: disable-end
        }
    }

    function isEqual(string memory a, string memory b) private pure returns (bool) {
        return keccak256(abi.encode(a)) == keccak256(abi.encode(b));
    }

    function isEqual(string memory a, string memory b, string memory c) private pure returns (bool) {
        return keccak256(abi.encode(a)) == keccak256(abi.encode(b))
            || keccak256(abi.encode(a)) == keccak256(abi.encode(c));
    }
}
