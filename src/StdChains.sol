// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.13 <0.9.0;

import {VmSafe} from "./Vm.sol";

/**
 * StdChains provides information about EVM compatible chains that can be used in scripts/tests.
 * For each chain, the chain's name, chain ID, and a default RPC URL are provided. Chains are
 * identified by their alias, which is the same as the alias in the `[rpc_endpoints]` section of
 * the `foundry.toml` file. For best UX, ensure the alias in the `foundry.toml` file matches the
 * alias used in this contract, which can be found as the first argument to the
 * `setChainWithDefaultRpcUrl` call in the `initializeStdChains` function.
 *
 * There are two main ways to use this contract:
 *   1. Set a chain with `setChain(string memory chainAlias, ChainData memory chain)` or
 *      `setChain(string memory chainAlias, Chain memory chain)`
 *   2. Get a chain with `getChain(string memory chainAlias)` or `getChain(uint256 chainId)`.
 *
 * The first time either of those are used, chains are initialized with the default set of RPC URLs.
 * This is done in `initializeStdChains`, which uses `setChainWithDefaultRpcUrl`. Defaults are recorded in
 * `defaultRpcUrls`.
 *
 * The `setChain` function is straightforward, and it simply saves off the given chain data.
 *
 * The `getChain` methods use `getChainWithUpdatedRpcUrl` to return a chain. For example, let's say
 * we want to retrieve the RPC URL for `mainnet`:
 *   - If you have specified data with `setChain`, it will return that.
 *   - If you have configured a mainnet RPC URL in `foundry.toml`, it will return the URL, provided it
 *     is valid (e.g. a URL is specified, or an environment variable is given and exists).
 *   - If neither of the above conditions is met, the default data is returned.
 *
 * Summarizing the above, the prioritization hierarchy is `setChain` -> `foundry.toml` -> environment variable -> defaults.
 */
abstract contract StdChains {
    VmSafe private constant vm = VmSafe(address(uint160(uint256(keccak256("hevm cheat code")))));

    bool private stdChainsInitialized;

    struct ChainData {
        string name;
        uint256 chainId;
        string rpcUrl;
    }

    struct Chain {
        // The chain name.
        string name;
        // The chain's Chain ID.
        uint256 chainId;
        // The chain's alias. (i.e. what gets specified in `foundry.toml`).
        string chainAlias;
        // A default RPC endpoint for this chain.
        // NOTE: This default RPC URL is included for convenience to facilitate quick tests and
        // experimentation. Do not use this RPC URL for production test suites, CI, or other heavy
        // usage as you will be throttled and this is a disservice to others who need this endpoint.
        string rpcUrl;
    }

    // Maps from the chain's alias (matching the alias in the `foundry.toml` file) to chain data.
    mapping(string => Chain) private chains;
    // Maps from the chain's alias to its default RPC URL.
    mapping(string => string) private defaultRpcUrls;
    // Maps from a chain ID to its alias.
    mapping(uint256 => string) private idToAlias;

    bool private fallbackToDefaultRpcUrls = true;

    /// @dev Retrieves chain configuration by alias. RPC URL is resolved using the prioritization
    ///      hierarchy: setChain > foundry.toml > environment variable > defaults.
    ///      Triggers lazy initialization of default chains on first call.
    /// @param chainAlias The chain alias (e.g., "mainnet", "sepolia"). Must match the alias in
    ///                   foundry.toml [rpc_endpoints] section for config-based resolution.
    /// @return chain The chain configuration with resolved RPC URL.
    /// @custom:reverts If chainAlias is empty or chain not found in the registry.
    function getChain(string memory chainAlias) internal virtual returns (Chain memory chain) {
        require(bytes(chainAlias).length != 0, "StdChains getChain(string): Chain alias cannot be the empty string.");

        initializeStdChains();
        chain = chains[chainAlias];
        require(
            chain.chainId != 0,
            string(abi.encodePacked("StdChains getChain(string): Chain with alias \"", chainAlias, "\" not found."))
        );

        chain = getChainWithUpdatedRpcUrl(chainAlias, chain);
    }

    /// @dev Retrieves chain configuration by chain ID. First resolves chainId to its alias via
    ///      the internal mapping, then delegates to getChain(string). RPC URL resolution follows
    ///      the same prioritization hierarchy: setChain > foundry.toml > env var > defaults.
    /// @param chainId The chain ID (e.g., 1 for mainnet, 11155111 for sepolia).
    /// @return chain The chain configuration with resolved RPC URL.
    /// @custom:reverts If chainId is 0 or chain not found in the registry.
    function getChain(uint256 chainId) internal virtual returns (Chain memory chain) {
        require(chainId != 0, "StdChains getChain(uint256): Chain ID cannot be 0.");
        initializeStdChains();
        string memory chainAlias = idToAlias[chainId];

        chain = chains[chainAlias];

        require(
            chain.chainId != 0,
            string(abi.encodePacked("StdChains getChain(uint256): Chain with ID ", vm.toString(chainId), " not found."))
        );

        chain = getChainWithUpdatedRpcUrl(chainAlias, chain);
    }

    /// @dev Sets custom chain configuration for the given alias. If chain.rpcUrl is provided, it takes
    ///      priority in subsequent getChain calls. Creates bidirectional mappings (alias <-> chainId).
    ///      Overwrites existing configuration if the alias already exists.
    /// @param chainAlias The chain alias to register (must be non-empty).
    /// @param chain The chain data including name, chainId, and optional rpcUrl.
    /// @custom:reverts If chainAlias is empty, chainId is 0, or chainId is already mapped to a different alias.
    /// @custom:sideeffects Updates chains[chainAlias] and idToAlias[chainId] mappings. Removes old chainId mapping if alias is being updated.
    function setChain(string memory chainAlias, ChainData memory chain) internal virtual {
        require(
            bytes(chainAlias).length != 0,
            "StdChains setChain(string,ChainData): Chain alias cannot be the empty string."
        );

        require(chain.chainId != 0, "StdChains setChain(string,ChainData): Chain ID cannot be 0.");

        initializeStdChains();
        string memory foundAlias = idToAlias[chain.chainId];

        require(
            bytes(foundAlias).length == 0 || keccak256(bytes(foundAlias)) == keccak256(bytes(chainAlias)),
            string(
                abi.encodePacked(
                    "StdChains setChain(string,ChainData): Chain ID ",
                    vm.toString(chain.chainId),
                    " already used by \"",
                    foundAlias,
                    "\"."
                )
            )
        );

        uint256 oldChainId = chains[chainAlias].chainId;
        delete idToAlias[oldChainId];

        chains[chainAlias] =
            Chain({name: chain.name, chainId: chain.chainId, chainAlias: chainAlias, rpcUrl: chain.rpcUrl});
        idToAlias[chain.chainId] = chainAlias;
    }

    /// @dev Convenience overload that accepts a Chain struct instead of ChainData. Extracts the
    ///      relevant fields and delegates to setChain(string, ChainData). Behavior is identical
    ///      regarding RPC URL priority and mapping updates.
    /// @param chainAlias The chain alias to register (must be non-empty).
    /// @param chain The Chain struct including name, chainId, chainAlias, and optional rpcUrl.
    /// @custom:reverts Same conditions as setChain(string, ChainData).
    function setChain(string memory chainAlias, Chain memory chain) internal virtual {
        setChain(chainAlias, ChainData({name: chain.name, chainId: chain.chainId, rpcUrl: chain.rpcUrl}));
    }

    function _toUpper(string memory str) private pure returns (string memory) {
        bytes memory strb = bytes(str);
        bytes memory copy = new bytes(strb.length);
        for (uint256 i = 0; i < strb.length; i++) {
            bytes1 b = strb[i];
            if (b >= 0x61 && b <= 0x7A) {
                copy[i] = bytes1(uint8(b) - 32);
            } else {
                copy[i] = b;
            }
        }
        return string(copy);
    }

    /// @dev Internal helper that resolves the RPC URL for a chain using the prioritization hierarchy.
    ///      Priority order: current chain.rpcUrl > foundry.toml config > environment variable > default.
    ///      Environment variable format: {UPPERCASE_ALIAS}_RPC_URL (e.g., MAINNET_RPC_URL).
    /// @param chainAlias The chain alias used for config and env var lookups.
    /// @param chain The chain struct, potentially with an empty rpcUrl to be resolved.
    /// @return The chain struct with rpcUrl populated from the highest priority available source.
    function getChainWithUpdatedRpcUrl(string memory chainAlias, Chain memory chain)
        private
        view
        returns (Chain memory)
    {
        if (bytes(chain.rpcUrl).length == 0) {
            try vm.rpcUrl(chainAlias) returns (string memory configRpcUrl) {
                chain.rpcUrl = configRpcUrl;
            } catch (bytes memory err) {
                string memory envName = string(abi.encodePacked(_toUpper(chainAlias), "_RPC_URL"));
                if (fallbackToDefaultRpcUrls) {
                    chain.rpcUrl = vm.envOr(envName, defaultRpcUrls[chainAlias]);
                } else {
                    chain.rpcUrl = vm.envString(envName);
                }
                // Distinguish 'not found' from 'cannot read'
                // The upstream error thrown by forge for failing cheats changed so we check both the old and new versions
                bytes memory oldNotFoundError =
                    abi.encodeWithSignature("CheatCodeError", string(abi.encodePacked("invalid rpc url ", chainAlias)));
                bytes memory newNotFoundError = abi.encodeWithSignature(
                    "CheatcodeError(string)", string(abi.encodePacked("invalid rpc url: ", chainAlias))
                );
                bytes32 errHash = keccak256(err);
                if (
                    (errHash != keccak256(oldNotFoundError) && errHash != keccak256(newNotFoundError))
                        || bytes(chain.rpcUrl).length == 0
                ) {
                    assembly ("memory-safe") {
                        revert(add(32, err), mload(err))
                    }
                }
            }
        }
        return chain;
    }

    /// @dev Configures whether to fall back to default RPC URLs when foundry.toml config is unavailable.
    ///      When set to false, getChain will revert if the environment variable is not set and no
    ///      config exists. Default value is true.
    /// @param useDefault If true, falls back to default RPC URLs; if false, requires explicit config or env var.
    function setFallbackToDefaultRpcUrls(bool useDefault) internal {
        fallbackToDefaultRpcUrls = useDefault;
    }

    /// @dev Lazy initialization function that populates the default chain registry on first use.
    ///      Called automatically by getChain and setChain. Uses a guard flag to ensure initialization
    ///      happens exactly once per contract instance.
    /// @custom:chains Initializes 50+ chains including mainnet, testnets, and L2s with default RPC URLs.
    function initializeStdChains() private {
        if (stdChainsInitialized) return;

        stdChainsInitialized = true;

        // If adding an RPC here, make sure to test the default RPC URL in `test_Rpcs` in `StdChains.t.sol`
        setChainWithDefaultRpcUrl("anvil", ChainData("Anvil", 31337, "http://127.0.0.1:8545"));
        setChainWithDefaultRpcUrl("mainnet", ChainData("Mainnet", 1, "https://eth.llamarpc.com"));
        setChainWithDefaultRpcUrl(
            "sepolia", ChainData("Sepolia", 11155111, "https://sepolia.infura.io/v3/b9794ad1ddf84dfb8c34d6bb5dca2001")
        );
        setChainWithDefaultRpcUrl("holesky", ChainData("Holesky", 17000, "https://rpc.holesky.ethpandaops.io"));
        setChainWithDefaultRpcUrl("hoodi", ChainData("Hoodi", 560048, "https://rpc.hoodi.ethpandaops.io"));
        setChainWithDefaultRpcUrl("optimism", ChainData("Optimism", 10, "https://mainnet.optimism.io"));
        setChainWithDefaultRpcUrl(
            "optimism_sepolia", ChainData("Optimism Sepolia", 11155420, "https://sepolia.optimism.io")
        );
        setChainWithDefaultRpcUrl("arbitrum_one", ChainData("Arbitrum One", 42161, "https://arb1.arbitrum.io/rpc"));
        setChainWithDefaultRpcUrl(
            "arbitrum_one_sepolia", ChainData("Arbitrum One Sepolia", 421614, "https://sepolia-rollup.arbitrum.io/rpc")
        );
        setChainWithDefaultRpcUrl("arbitrum_nova", ChainData("Arbitrum Nova", 42170, "https://nova.arbitrum.io/rpc"));
        setChainWithDefaultRpcUrl("polygon", ChainData("Polygon", 137, "https://polygon-rpc.com"));
        setChainWithDefaultRpcUrl(
            "polygon_amoy", ChainData("Polygon Amoy", 80002, "https://rpc-amoy.polygon.technology")
        );
        setChainWithDefaultRpcUrl("avalanche", ChainData("Avalanche", 43114, "https://api.avax.network/ext/bc/C/rpc"));
        setChainWithDefaultRpcUrl(
            "avalanche_fuji", ChainData("Avalanche Fuji", 43113, "https://api.avax-test.network/ext/bc/C/rpc")
        );
        setChainWithDefaultRpcUrl(
            "bnb_smart_chain", ChainData("BNB Smart Chain", 56, "https://bsc-dataseed1.binance.org")
        );
        setChainWithDefaultRpcUrl(
            "bnb_smart_chain_testnet",
            ChainData("BNB Smart Chain Testnet", 97, "https://rpc.ankr.com/bsc_testnet_chapel")
        );
        setChainWithDefaultRpcUrl("gnosis_chain", ChainData("Gnosis Chain", 100, "https://rpc.gnosischain.com"));
        setChainWithDefaultRpcUrl("moonbeam", ChainData("Moonbeam", 1284, "https://rpc.api.moonbeam.network"));
        setChainWithDefaultRpcUrl(
            "moonriver", ChainData("Moonriver", 1285, "https://rpc.api.moonriver.moonbeam.network")
        );
        setChainWithDefaultRpcUrl("moonbase", ChainData("Moonbase", 1287, "https://rpc.testnet.moonbeam.network"));
        setChainWithDefaultRpcUrl("base_sepolia", ChainData("Base Sepolia", 84532, "https://sepolia.base.org"));
        setChainWithDefaultRpcUrl("base", ChainData("Base", 8453, "https://mainnet.base.org"));
        setChainWithDefaultRpcUrl("blast_sepolia", ChainData("Blast Sepolia", 168587773, "https://sepolia.blast.io"));
        setChainWithDefaultRpcUrl("blast", ChainData("Blast", 81457, "https://rpc.blast.io"));
        setChainWithDefaultRpcUrl("fantom_opera", ChainData("Fantom Opera", 250, "https://rpc.ankr.com/fantom/"));
        setChainWithDefaultRpcUrl(
            "fantom_opera_testnet", ChainData("Fantom Opera Testnet", 4002, "https://rpc.ankr.com/fantom_testnet/")
        );
        setChainWithDefaultRpcUrl("fraxtal", ChainData("Fraxtal", 252, "https://rpc.frax.com"));
        setChainWithDefaultRpcUrl("fraxtal_testnet", ChainData("Fraxtal Testnet", 2522, "https://rpc.testnet.frax.com"));
        setChainWithDefaultRpcUrl(
            "berachain_bartio_testnet", ChainData("Berachain bArtio Testnet", 80084, "https://bartio.rpc.berachain.com")
        );
        setChainWithDefaultRpcUrl("flare", ChainData("Flare", 14, "https://flare-api.flare.network/ext/C/rpc"));
        setChainWithDefaultRpcUrl(
            "flare_coston2", ChainData("Flare Coston2", 114, "https://coston2-api.flare.network/ext/C/rpc")
        );

        setChainWithDefaultRpcUrl("ink", ChainData("Ink", 57073, "https://rpc-gel.inkonchain.com"));
        setChainWithDefaultRpcUrl(
            "ink_sepolia", ChainData("Ink Sepolia", 763373, "https://rpc-gel-sepolia.inkonchain.com")
        );

        setChainWithDefaultRpcUrl("mode", ChainData("Mode", 34443, "https://mode.drpc.org"));
        setChainWithDefaultRpcUrl("mode_sepolia", ChainData("Mode Sepolia", 919, "https://sepolia.mode.network"));

        setChainWithDefaultRpcUrl("zora", ChainData("Zora", 7777777, "https://zora.drpc.org"));
        setChainWithDefaultRpcUrl(
            "zora_sepolia", ChainData("Zora Sepolia", 999999999, "https://sepolia.rpc.zora.energy")
        );

        setChainWithDefaultRpcUrl("race", ChainData("Race", 6805, "https://racemainnet.io"));
        setChainWithDefaultRpcUrl("race_sepolia", ChainData("Race Sepolia", 6806, "https://racemainnet.io"));

        setChainWithDefaultRpcUrl("radius", ChainData("Radius", 723487, "https://rpc.radiustech.xyz"));
        setChainWithDefaultRpcUrl(
            "radius_testnet", ChainData("Radius Testnet", 72344, "https://rpc.testnet.radiustech.xyz")
        );

        setChainWithDefaultRpcUrl("metal", ChainData("Metal", 1750, "https://metall2.drpc.org"));
        setChainWithDefaultRpcUrl("metal_sepolia", ChainData("Metal Sepolia", 1740, "https://testnet.rpc.metall2.com"));

        setChainWithDefaultRpcUrl("binary", ChainData("Binary", 624, "https://rpc.zero.thebinaryholdings.com"));
        setChainWithDefaultRpcUrl(
            "binary_sepolia", ChainData("Binary Sepolia", 625, "https://rpc.zero.thebinaryholdings.com")
        );

        setChainWithDefaultRpcUrl("orderly", ChainData("Orderly", 291, "https://rpc.orderly.network"));
        setChainWithDefaultRpcUrl(
            "orderly_sepolia", ChainData("Orderly Sepolia", 4460, "https://testnet-rpc.orderly.org")
        );

        setChainWithDefaultRpcUrl("unichain", ChainData("Unichain", 130, "https://mainnet.unichain.org"));
        setChainWithDefaultRpcUrl(
            "unichain_sepolia", ChainData("Unichain Sepolia", 1301, "https://sepolia.unichain.org")
        );

        setChainWithDefaultRpcUrl("tempo", ChainData("Tempo", 4217, "https://rpc.mainnet.tempo.xyz"));
        setChainWithDefaultRpcUrl(
            "tempo_moderato", ChainData("Tempo Moderato", 42431, "https://rpc.moderato.tempo.xyz")
        );
        setChainWithDefaultRpcUrl(
            "tempo_andantino", ChainData("Tempo Andantino", 42429, "https://rpc.testnet.tempo.xyz")
        );

        setChainWithDefaultRpcUrl("grav", ChainData("Gravity", 127001, "https://mainnet-rpc.gravity.xyz"));
    }

    /// @dev Internal helper used during initialization to register chains with default RPC URLs.
    ///      Stores the default URL separately and clears chain.rpcUrl to enable config-based resolution.
    ///      This ensures foundry.toml and env vars take priority over defaults.
    /// @param chainAlias The chain alias to register.
    /// @param chain The chain data with a default RPC URL.
    function setChainWithDefaultRpcUrl(string memory chainAlias, ChainData memory chain) private {
        string memory rpcUrl = chain.rpcUrl;
        defaultRpcUrls[chainAlias] = rpcUrl;
        chain.rpcUrl = "";
        setChain(chainAlias, chain);
        chain.rpcUrl = rpcUrl; // restore argument
    }
}
