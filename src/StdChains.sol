// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import {VmSafe} from "./Vm.sol";

/// @title StdChains
/// @notice Provides information about EVM compatible chains that can be used in scripts/tests.
/// For each chain, the chain's name, chain ID, and a default RPC URL are provided. Chains are
/// identified by their alias, which is the same as the alias in the `[rpc_endpoints]` section of
/// the `foundry.toml` file. For best UX, ensure the alias in the `foundry.toml` file match the
/// alias used in this contract, which can be found as the first argument to the
/// `_setChainWithDefaultRpcUrl` call in the `_initializeStdChains` function.
///
/// There are two main ways to use this contract:
///   1. Set a chain with `setChain(string memory chainAlias, ChainData memory chain)` or
///      `setChain(string memory chainAlias, Chain memory chain)`
///   2. Get a chain with `getChain(string memory chainAlias)` or `getChain(uint256 chainId)`.
///
/// The first time either of those are used, chains are initialized with the default set of RPC URLs.
/// This is done in `_initializeStdChains`, which uses `_setChainWithDefaultRpcUrl`. Defaults are recorded in
/// `defaultRpcUrls`.
///
/// The `setChain` function is straightforward, and it simply saves off the given chain data.
///
/// The `getChain` methods use `_getChainWithUpdatedRpcUrl` to return a chain. For example, let's say
/// we want to retrieve the RPC URL for `mainnet`:
///   - If you have specified data with `setChain`, it will return that.
///   - If you have configured a mainnet RPC URL in `foundry.toml`, it will return the URL, provided it
///     is valid (e.g. a URL is specified, or an environment variable is given and exists).
///   - If neither of the above conditions is met, the default data is returned.
///
/// Summarizing the above, the prioritization hierarchy is:
///   1. `setChain`
///   2. `foundry.toml`
///   3. Environment variable
///   4. Default RPC URL
abstract contract StdChains {
    VmSafe private constant vm = VmSafe(address(uint160(uint256(keccak256("hevm cheat code")))));

    /// @dev Chain data for a chain.
    /// @param name The chain name.
    /// @param chainId The chain's Chain ID.
    /// @param rpcUrl The chain's RPC URL.
    struct ChainData {
        string name;
        uint256 chainId;
        string rpcUrl;
    }

    /// @dev Chain data for a chain with an alias.
    /// @param name The chain name.
    /// @param chainId The chain's Chain ID.
    /// @param chainAlias The chain's alias. (i.e. what gets specified in `foundry.toml`).
    /// @param rpcUrl The chain's default RPC URL.
    struct Chain {
        string name;
        uint256 chainId;
        string chainAlias;
        // NOTE: This default RPC URL is included for convenience to facilitate quick tests and
        // experimentation. Do not use this RPC URL for production test suites, CI, or other heavy
        // usage as you will be throttled and this is a disservice to others who need this endpoint.
        string rpcUrl;
    }

    /// @dev Maps from the chain's alias (matching the alias in the `foundry.toml` file) to chain data.
    mapping(string => Chain) private _chains;

    /// @dev Maps from the chain's alias to it's default RPC URL.
    mapping(string => string) private _defaultRpcUrls;

    /// @dev Maps from a chain ID to it's alias.
    mapping(uint256 => string) private _idToAlias;

    /// @dev Whether the standard chains have been initialized for caching purposes.
    bool private _stdChainsInitialized;

    /// @dev Whether to fallback to default RPC URLs if the chain's RPC URL is not found.
    bool private _fallbackToDefaultRpcUrls = true;

    /// @dev Returns the chain data for the chain with the given alias.
    /// @param chainAlias The alias of the chain to retrieve.
    /// @return chain The chain data for the chain with the given alias.
    /// @dev The RPC URL will be fetched from config or defaultRpcUrls if possible.
    function getChain(string memory chainAlias) internal virtual returns (Chain memory chain) {
        require(bytes(chainAlias).length != 0, "StdChains getChain(string): Chain alias cannot be the empty string.");

        _initializeStdChains();
        chain = _chains[chainAlias];
        require(
            chain.chainId != 0,
            string(abi.encodePacked("StdChains getChain(string): Chain with alias \"", chainAlias, "\" not found."))
        );

        chain = _getChainWithUpdatedRpcUrl(chainAlias, chain);
    }

    /// @dev Returns the chain data for the chain with the given chain ID.
    /// @param chainId The chain ID of the chain to retrieve.
    /// @return chain The chain data for the chain with the given chain ID.
    function getChain(uint256 chainId) internal virtual returns (Chain memory chain) {
        require(chainId != 0, "StdChains getChain(uint256): Chain ID cannot be 0.");

        _initializeStdChains();

        string memory chainAlias = _idToAlias[chainId];

        chain = _chains[chainAlias];

        require(
            chain.chainId != 0,
            string(abi.encodePacked("StdChains getChain(uint256): Chain with ID ", vm.toString(chainId), " not found."))
        );

        chain = _getChainWithUpdatedRpcUrl(chainAlias, chain);
    }

    /// @dev Sets the chain data for the chain with the given alias.
    /// @param chainAlias The alias of the chain to set.
    /// @param chain The chain data to set.
    /// @dev The argument's rpcUrl field will take priority over the chainAlias' rpcUrl in `foundry.toml`.
    function setChain(string memory chainAlias, ChainData memory chain) internal virtual {
        require(
            bytes(chainAlias).length != 0,
            "StdChains setChain(string,ChainData): Chain alias cannot be the empty string."
        );
        require(chain.chainId != 0, "StdChains setChain(string,ChainData): Chain ID cannot be 0.");

        _initializeStdChains();

        string memory foundAlias = _idToAlias[chain.chainId];

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

        uint256 oldChainId = _chains[chainAlias].chainId;
        delete _idToAlias[oldChainId];

        _chains[chainAlias] =
            Chain({name: chain.name, chainId: chain.chainId, chainAlias: chainAlias, rpcUrl: chain.rpcUrl});
        _idToAlias[chain.chainId] = chainAlias;
    }

    /// @dev Sets the chain data for the chain with the given alias.
    /// @param chainAlias The alias of the chain to set.
    /// @param chain The chain data to set.
    /// @dev The argument's rpcUrl field will take priority over the chainAlias' rpcUrl in `foundry.toml`.
    function setChain(string memory chainAlias, Chain memory chain) internal virtual {
        setChain(chainAlias, ChainData({name: chain.name, chainId: chain.chainId, rpcUrl: chain.rpcUrl}));
    }

    /// @dev Sets whether to fallback to default RPC URLs if the chain's RPC URL is not found.
    function setFallbackToDefaultRpcUrls(bool useDefault) internal {
        _fallbackToDefaultRpcUrls = useDefault;
    }

    /// @dev Initializes the standard chains with the default set of chains.
    function _initializeStdChains() private {
        if (_stdChainsInitialized) return;

        _stdChainsInitialized = true;

        // If adding an RPC here, make sure to test the default RPC URL in `test_Rpcs` in `StdChains.t.sol`
        _setChainWithDefaultRpcUrl("anvil", ChainData("Anvil", 31337, "http://127.0.0.1:8545"));
        _setChainWithDefaultRpcUrl(
            "mainnet", ChainData("Mainnet", 1, "https://eth-mainnet.alchemyapi.io/v2/pwc5rmJhrdoaSEfimoKEmsvOjKSmPDrP")
        );
        _setChainWithDefaultRpcUrl(
            "sepolia", ChainData("Sepolia", 11155111, "https://sepolia.infura.io/v3/b9794ad1ddf84dfb8c34d6bb5dca2001")
        );
        _setChainWithDefaultRpcUrl("holesky", ChainData("Holesky", 17000, "https://rpc.holesky.ethpandaops.io"));
        _setChainWithDefaultRpcUrl("optimism", ChainData("Optimism", 10, "https://mainnet.optimism.io"));
        _setChainWithDefaultRpcUrl(
            "optimism_sepolia", ChainData("Optimism Sepolia", 11155420, "https://sepolia.optimism.io")
        );
        _setChainWithDefaultRpcUrl("arbitrum_one", ChainData("Arbitrum One", 42161, "https://arb1.arbitrum.io/rpc"));
        _setChainWithDefaultRpcUrl(
            "arbitrum_one_sepolia", ChainData("Arbitrum One Sepolia", 421614, "https://sepolia-rollup.arbitrum.io/rpc")
        );
        _setChainWithDefaultRpcUrl("arbitrum_nova", ChainData("Arbitrum Nova", 42170, "https://nova.arbitrum.io/rpc"));
        _setChainWithDefaultRpcUrl("polygon", ChainData("Polygon", 137, "https://polygon-rpc.com"));
        _setChainWithDefaultRpcUrl(
            "polygon_amoy", ChainData("Polygon Amoy", 80002, "https://rpc-amoy.polygon.technology")
        );
        _setChainWithDefaultRpcUrl("avalanche", ChainData("Avalanche", 43114, "https://api.avax.network/ext/bc/C/rpc"));
        _setChainWithDefaultRpcUrl(
            "avalanche_fuji", ChainData("Avalanche Fuji", 43113, "https://api.avax-test.network/ext/bc/C/rpc")
        );
        _setChainWithDefaultRpcUrl(
            "bnb_smart_chain", ChainData("BNB Smart Chain", 56, "https://bsc-dataseed1.binance.org")
        );
        _setChainWithDefaultRpcUrl(
            "bnb_smart_chain_testnet",
            ChainData("BNB Smart Chain Testnet", 97, "https://rpc.ankr.com/bsc_testnet_chapel")
        );
        _setChainWithDefaultRpcUrl("gnosis_chain", ChainData("Gnosis Chain", 100, "https://rpc.gnosischain.com"));
        _setChainWithDefaultRpcUrl("moonbeam", ChainData("Moonbeam", 1284, "https://rpc.api.moonbeam.network"));
        _setChainWithDefaultRpcUrl(
            "moonriver", ChainData("Moonriver", 1285, "https://rpc.api.moonriver.moonbeam.network")
        );
        _setChainWithDefaultRpcUrl("moonbase", ChainData("Moonbase", 1287, "https://rpc.testnet.moonbeam.network"));
        _setChainWithDefaultRpcUrl("base_sepolia", ChainData("Base Sepolia", 84532, "https://sepolia.base.org"));
        _setChainWithDefaultRpcUrl("base", ChainData("Base", 8453, "https://mainnet.base.org"));
        _setChainWithDefaultRpcUrl("blast_sepolia", ChainData("Blast Sepolia", 168587773, "https://sepolia.blast.io"));
        _setChainWithDefaultRpcUrl("blast", ChainData("Blast", 81457, "https://rpc.blast.io"));
        _setChainWithDefaultRpcUrl("fantom_opera", ChainData("Fantom Opera", 250, "https://rpc.ankr.com/fantom/"));
        _setChainWithDefaultRpcUrl(
            "fantom_opera_testnet", ChainData("Fantom Opera Testnet", 4002, "https://rpc.ankr.com/fantom_testnet/")
        );
        _setChainWithDefaultRpcUrl("fraxtal", ChainData("Fraxtal", 252, "https://rpc.frax.com"));
        _setChainWithDefaultRpcUrl(
            "fraxtal_testnet", ChainData("Fraxtal Testnet", 2522, "https://rpc.testnet.frax.com")
        );
        _setChainWithDefaultRpcUrl(
            "berachain_bartio_testnet", ChainData("Berachain bArtio Testnet", 80084, "https://bartio.rpc.berachain.com")
        );
        _setChainWithDefaultRpcUrl("flare", ChainData("Flare", 14, "https://flare-api.flare.network/ext/C/rpc"));
        _setChainWithDefaultRpcUrl(
            "flare_coston2", ChainData("Flare Coston2", 114, "https://coston2-api.flare.network/ext/C/rpc")
        );

        _setChainWithDefaultRpcUrl("mode", ChainData("Mode", 34443, "https://mode.drpc.org"));
        _setChainWithDefaultRpcUrl("mode_sepolia", ChainData("Mode Sepolia", 919, "https://sepolia.mode.network"));

        _setChainWithDefaultRpcUrl("zora", ChainData("Zora", 7777777, "https://zora.drpc.org"));
        _setChainWithDefaultRpcUrl(
            "zora_sepolia", ChainData("Zora Sepolia", 999999999, "https://sepolia.rpc.zora.energy")
        );

        _setChainWithDefaultRpcUrl("race", ChainData("Race", 6805, "https://racemainnet.io"));
        _setChainWithDefaultRpcUrl("race_sepolia", ChainData("Race Sepolia", 6806, "https://racemainnet.io"));

        _setChainWithDefaultRpcUrl("metal", ChainData("Metal", 1750, "https://metall2.drpc.org"));
        _setChainWithDefaultRpcUrl("metal_sepolia", ChainData("Metal Sepolia", 1740, "https://testnet.rpc.metall2.com"));

        _setChainWithDefaultRpcUrl("binary", ChainData("Binary", 624, "https://rpc.zero.thebinaryholdings.com"));
        _setChainWithDefaultRpcUrl(
            "binary_sepolia", ChainData("Binary Sepolia", 625, "https://rpc.zero.thebinaryholdings.com")
        );

        _setChainWithDefaultRpcUrl("orderly", ChainData("Orderly", 291, "https://rpc.orderly.network"));
        _setChainWithDefaultRpcUrl(
            "orderly_sepolia", ChainData("Orderly Sepolia", 4460, "https://testnet-rpc.orderly.org")
        );
    }

    /// @dev Sets the chain data for the chain with the given alias, with priority to the chainAlias' RPC URL in `foundry.toml`.
    /// @param chainAlias The alias of the chain to set.
    /// @param chain The chain data to set.
    function _setChainWithDefaultRpcUrl(string memory chainAlias, ChainData memory chain) private {
        string memory rpcUrl = chain.rpcUrl;
        _defaultRpcUrls[chainAlias] = rpcUrl;
        chain.rpcUrl = "";
        setChain(chainAlias, chain);
        chain.rpcUrl = rpcUrl; // restore argument
    }

    /// @dev Returns the chain data for the chain with the given alias, updating the RPC URL if needed.
    /// @param chainAlias The alias of the chain to retrieve.
    /// @param chain The chain data for the chain with the given alias.
    /// @return _ The chain data for the chain with the given alias and updated RPC URL if needed.
    /// @dev The RPC URL will be fetched in the following order:
    /// 1. If the chain's RPC URL is set, it will be returned.
    /// 2. If the chain's RPC URL is not set, the RPC URL from the config (foundry.toml) will be returned.
    /// 3. If the chain's RPC URL is not set in the config, the RPC URL from the environment variable will be returned.
    /// 4. If the chain's RPC URL is not set in the environment variable, the default RPC URL will be returned.
    function _getChainWithUpdatedRpcUrl(string memory chainAlias, Chain memory chain)
        private
        view
        returns (Chain memory)
    {
        if (bytes(chain.rpcUrl).length == 0) {
            try vm.rpcUrl(chainAlias) returns (string memory configRpcUrl) {
                chain.rpcUrl = configRpcUrl;
            } catch (bytes memory err) {
                string memory envName = string(abi.encodePacked(vm.toUppercase(chainAlias), "_RPC_URL"));
                if (_fallbackToDefaultRpcUrls) {
                    chain.rpcUrl = vm.envOr(envName, _defaultRpcUrls[chainAlias]);
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
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, err), mload(err))
                    }
                }
            }
        }
        return chain;
    }
}
