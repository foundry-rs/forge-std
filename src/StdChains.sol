// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;
pragma experimental ABIEncoderV2;

import "src/Vm.sol";

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
        Chain Ropsten;
        Chain Rinkeby;
        Chain Goerli;
        Chain Kovan;
        Chain Sepolia;
        Chain Optimism;
        Chain OptimismGoerli;
        Chain OptimismKovan;
        Chain ArbitrumOne;
        Chain ArbitrumOneGoerli;
        Chain ArbitrumOneRinkeby;
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
        Mainnet: Chain("Mainnet", 1, ""),
        Ropsten: Chain("Ropsten", 3, ""),
        Rinkeby: Chain("Rinkeby", 4, ""),
        Goerli: Chain("Goerli", 5, ""),
        Kovan: Chain("Kovan", 42, ""),
        Sepolia: Chain("Sepolia", 0, ""),
        Optimism: Chain("Optimism", 10, ""),
        OptimismGoerli: Chain("OptimismGoerli", 69, ""),
        OptimismKovan: Chain("OptimismKovan", 420, ""),
        ArbitrumOne: Chain("ArbitrumOne", 42161, ""),
        ArbitrumOneGoerli: Chain("ArbitrumOneGoerli", 0, ""),
        ArbitrumOneRinkeby: Chain("ArbitrumOneRinkeby", 0, ""),
        Polygon: Chain("Polygon", 137, ""),
        PolygonMumbai: Chain("PolygonMumbai", 0, ""),
        Avalanche: Chain("Avalanche", 0, ""),
        AvalancheFuji: Chain("AvalancheFuji", 0, ""),
        BnbSmartChain: Chain("BnbSmartChain", 0, ""),
        BnbSmartChainTestnet: Chain("BnbSmartChainTestnet", 0, ""),
        GnosisChain: Chain("GnosisChain", 0, "")
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
            else if (isEqual(name, "ropsten")) stdChains.Ropsten.rpcUrl = rpcUrl;
            else if (isEqual(name, "rinkeby")) stdChains.Rinkeby.rpcUrl = rpcUrl;
            else if (isEqual(name, "goerli")) stdChains.Goerli.rpcUrl = rpcUrl;
            else if (isEqual(name, "kovan")) stdChains.Kovan.rpcUrl = rpcUrl;
            else if (isEqual(name, "sepolia")) stdChains.Sepolia.rpcUrl = rpcUrl;
            else if (isEqual(name, "optimism")) stdChains.Optimism.rpcUrl = rpcUrl;
            else if (isEqual(name, "optimism_goerli", "optimism-goerli")) stdChains.OptimismGoerli.rpcUrl = rpcUrl;
            else if (isEqual(name, "optimism_kovan", "optimism-kovan")) stdChains.OptimismKovan.rpcUrl = rpcUrl;
            else if (isEqual(name, "arbitrum_one", "arbitrum-one")) stdChains.ArbitrumOne.rpcUrl = rpcUrl;
            else if (isEqual(name, "arbitrum_one_goerli", "arbitrum-one-goerli")) stdChains.ArbitrumOneGoerli.rpcUrl = rpcUrl;
            else if (isEqual(name, "arbitrum_one_rinkeby", "arbitrum-one-rinkeby")) stdChains.ArbitrumOneRinkeby.rpcUrl = rpcUrl;
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
