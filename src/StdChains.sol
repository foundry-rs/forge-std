// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

pragma experimental ABIEncoderV2;

import "./Vm.sol";

abstract contract StdChains {
    VmSafe private constant vm = VmSafe(address(uint160(uint256(keccak256("hevm cheat code")))));

    struct Chain {
        // The chain name.
        string name;
        // The chain's Chain ID.
        uint256 chainId;
        // A default RPC endpoint for this chain.
        // NOTE: This default RPC URL is included for convenience to facilitate quick tests and
        // experimentation. Do not use this RPC URL for production test suites, CI, or other heavy
        // usage as you will be throttled and this is a disservice to others who need this endpoint.
        string rpcUrl;
    }

    // Maps from a chain's name (matching what's in the `foundry.toml` file) to chain data.
    mapping(string => Chain) private chains;
    mapping(uint256 => string) private idToKey;

    function getChain(string memory name) internal virtual returns (Chain memory) {
        initialize();
        return chains[name];
    }

    function getChain(uint256 chainId) internal virtual returns (Chain memory) {
        initialize();
        return chains[idToKey[chainId]];
    }

    function setChain(string memory key, string memory name, uint256 chainId, string memory rpcUrl) internal virtual {
        chains[key] = Chain(name, chainId, rpcUrl);
        idToKey[chainId] = key;
    }

    bool private initialized;

    function initialize() private {
        if (initialized) return;

        setChain("anvil", "Localhost", 31337, "http://127.0.0.1:8545");
        setChain("hardhat", "Localhost", 31337, "http://127.0.0.1:8545");
        setChain("mainnet", "Mainnet", 1, "https://mainnet.infura.io/v3/6770454bc6ea42c58aac12978531b93f");
        setChain("goerli", "Goerli", 5, "https://goerli.infura.io/v3/6770454bc6ea42c58aac12978531b93f");
        setChain("sepolia", "Sepolia", 11155111, "https://rpc.sepolia.dev");
        setChain("optimism", "Optimism", 10, "https://mainnet.optimism.io");
        setChain("optimism_goerli", "Optimism Goerli", 420, "https://goerli.optimism.io");
        setChain("arbitrum_one", "Arbitrum One", 42161, "https://arb1.arbitrum.io/rpc");
        setChain("arbitrum_one_goerli", "Arbitrum One Goerli", 421613, "https://goerli-rollup.arbitrum.io/rpc");
        setChain("arbitrum_nova", "Arbitrum Nova", 42170, "https://nova.arbitrum.io/rpc");
        setChain("polygon", "Polygon", 137, "https://polygon-rpc.com");
        setChain("polygon_mumbai", "Polygon Mumbai", 80001, "https://rpc-mumbai.matic.today");
        setChain("avalanche", "Avalanche", 43114, "https://api.avax.network/ext/bc/C/rpc");
        setChain("avalanche_fuji", "Avalanche Fuji", 43113, "https://api.avax-test.network/ext/bc/C/rpc");
        setChain("bnb_smart_chain", "BNB Smart Chain", 56, "https://bsc-dataseed1.binance.org");
        setChain("bnb_smart_chain_testnet", "BNB Smart Chain Testnet", 97, "https://data-seed-prebsc-1-s1.binance.org:8545");// forgefmt: disable-line
        setChain("gnosis_chain", "Gnosis Chain", 100, "https://rpc.gnosischain.com");

        // Loop over RPC URLs in the config file to replace the default RPC URLs
        Vm.Rpc[] memory rpcs = vm.rpcUrlStructs();
        for (uint256 i = 0; i < rpcs.length; i++) {
            chains[rpcs[i].name].rpcUrl = rpcs[i].url;
        }

        initialized = true;
    }
}
