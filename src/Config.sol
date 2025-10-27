// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {console} from "./console.sol";
import {StdConfig} from "./StdConfig.sol";
import {ConfigView, LibConfigView} from "./LibConfigView.sol";
import {CommonBase} from "./Base.sol";
import {VmSafe} from "./Vm.sol";

/// @notice Boilerplate to streamline the setup of multi-chain environments.
abstract contract Config is CommonBase {
    using LibConfigView for ConfigView;

    // -- ERRORS ---------------------------------------------------------------

    error ForkNotLoaded(uint256 chainId);
    error ForkNotActive(uint256 chainId);
    error ProfileArtifactsNotFound(string profileName, string expectedPath);
    error MultiChainConfig(uint256 numChains);

    // -- STORAGE (CONFIG + CHAINS + FORKS) ------------------------------------

    /// @dev Array of chain IDs for which forks have been created.
    uint256[] internal chainIds;

    /// @dev StdConfig instances for each chain, deployed with profile-specific evm versions.
    ///      Multiple chains may point to the same StdConfig instance if they share an EVM version.
    mapping(uint256 => StdConfig) internal _chainConfig;

    /// @dev A mapping from a chain ID to its initialized fork ID.
    mapping(uint256 => uint256) internal forkOf;

    /// @dev A mapping from a chain ID to its profile metadata.
    mapping(uint256 => VmSafe.ProfileMetadata) internal profile;

    /// @dev Track which StdConfig was deployed for each EVM version (for deduplication).
    mapping(string => StdConfig) internal std_configOf;

    // -- UTILITY FUNCTIONS -----------------------------------------------------

    /// @notice  Creates a ConfigView bound to a specific chain ID.
    ///
    /// @dev     Use this to access configuration variables with a cleaner API.
    ///          Example: `configOf(chainId).get("my_key").toUint256()`
    ///          instead of: `_chainConfig[chainId].get(chainId, "my_key").toUint256()`
    ///
    /// @param   chainId: the chain ID.
    /// @return  ConfigView struct bound to the chain's StdConfig instance.
    function configOf(uint256 chainId) internal view isCached(chainId) returns (ConfigView memory) {
        return ConfigView(_chainConfig[chainId], chainId);
    }

    /// @notice  Loads configuration from a file.
    ///
    /// @dev     This function instantiates a `StdConfig` contract from the default profile.
    ///          Only supports single-chain configurations. For multi-chain setups, use loadConfigAndForks.
    ///
    /// @param   filePath: the path to the TOML configuration file.
    /// @param   writeToFile: whether updates are written back to the TOML file.
    function loadConfig(string memory filePath, bool writeToFile) internal {
        console.log("----------");
        console.log(string.concat("Loading config from '", filePath, "'"));

        // Parse TOML to get all chain keys
        string memory tomlContent = vm.resolveEnv(vm.readFile(filePath));
        string[] memory chainKeys = vm.parseTomlKeys(tomlContent, "$");
        require(chainKeys.length > 0, "Config: no chains found in TOML");

        // Filter out non-table keys and count actual chains
        uint256 numChains = 0;
        uint256[] memory chainIdList = new uint256[](chainKeys.length);
        string[] memory chainKeyList = new string[](chainKeys.length);

        for (uint256 i = 0; i < chainKeys.length; i++) {
            if (vm.parseTomlKeys(tomlContent, string.concat("$.", chainKeys[i])).length > 0) {
                chainKeyList[numChains] = chainKeys[i];
                chainIdList[numChains] = _resolveChainId(chainKeys[i]);
                numChains++;
            }
        }

        // Revert if multiple chains are detected
        if (numChains > 1) revert MultiChainConfig(numChains);

        // Load the single chain
        string memory chainKey = chainKeyList[0];
        uint256 chainId = chainIdList[0];

        // Get profile name for the chain
        string memory profileName;
        try vm.parseTomlString(tomlContent, string.concat("$.", chainKey, ".profile")) returns (
            string memory profileStr
        ) {
            profileName = profileStr;
        } catch {
            profileName = "default";
        }

        // Load profile metadata
        profile[chainId] = vm.getProfile(profileName);

        // Get EVM version
        string memory evmVersion = profile[chainId].evm;

        // Deploy StdConfig from the profile's artifact directory if not already deployed
        if (address(std_configOf[evmVersion]) == address(0)) {
            string memory artifact = string.concat(profile[chainId].artifacts, "/StdConfig.sol/StdConfig.json");

            // Validate artifact exists
            try vm.readFile(artifact) {}
            catch {
                revert ProfileArtifactsNotFound(profileName, artifact);
            }

            bytes memory constructorArgs = abi.encode(filePath, writeToFile, evmVersion);
            address configAddr = vm.deployCode(artifact, constructorArgs);
            std_configOf[evmVersion] = StdConfig(configAddr);
            vm.makePersistent(configAddr);
        }

        // Map this chain to its StdConfig instance
        _chainConfig[chainId] = std_configOf[evmVersion];

        console.log("Config successfully loaded");
        console.log("----------");
    }

    /// @notice  Loads configuration from a file and creates forks for each specified chain.
    ///
    /// @dev     This function deploys one StdConfig instance per unique EVM version from the
    ///          profile-specific artifact directory. Multiple chains sharing the same EVM version
    ///          will reuse the same StdConfig instance. Each StdConfig bytecode matches the EVM
    ///          version it will be called from.
    ///
    /// @param   filePath: the path to the TOML configuration file.
    /// @param   writeToFile: whether updates are written back to the TOML file.
    function loadConfigAndForks(string memory filePath, bool writeToFile) internal {
        console.log("----------");
        console.log(string.concat("Loading config from '", filePath, "'"));

        // Parse TOML to get chain keys
        string memory tomlContent = vm.resolveEnv(vm.readFile(filePath));
        string[] memory chainKeys = vm.parseTomlKeys(tomlContent, "$");

        console.log("Setting up forks for the configured chains...");

        // For each chain, load profile and ensure `StdConfig` is deployed for its EVM version
        for (uint256 i = 0; i < chainKeys.length; i++) {
            string memory chainKey = chainKeys[i];

            // Ignore top-level keys that are not tables
            if (vm.parseTomlKeys(tomlContent, string.concat("$.", chainKey)).length == 0) {
                continue;
            }

            // Get chain ID (from alias or parse as number)
            uint256 chainId = _resolveChainId(chainKey);

            // Get profile name from TOML (with fallback to default profile)
            string memory profileName;
            try vm.parseTomlString(tomlContent, string.concat("$.", chainKey, ".profile")) returns (
                string memory profileStr
            ) {
                profileName = profileStr;
            } catch {
                // Use default profile if not specified
                profileName = "default";
            }

            // Load profile metadata and cache EVM version and artifacts path
            profile[chainId] = vm.getProfile(profileName);

            // Get EVM version for this chain
            string memory evmVersion = profile[chainId].evm;

            // Deploy or reuse StdConfig based on EVM version
            if (address(std_configOf[evmVersion]) == address(0)) {
                // First chain with this EVM version - deploy new StdConfig
                string memory artifact = string.concat(profile[chainId].artifacts, "/StdConfig.sol/StdConfig.json");

                // Validate artifact exists
                try vm.readFile(artifact) {}
                catch {
                    revert ProfileArtifactsNotFound(profileName, artifact);
                }

                bytes memory constructorArgs = abi.encode(filePath, writeToFile, evmVersion);
                address configAddr = vm.deployCode(artifact, constructorArgs);
                std_configOf[evmVersion] = StdConfig(configAddr);
                vm.makePersistent(configAddr);
            }

            // Map this chain to its StdConfig instance (may be shared with other chains)
            _chainConfig[chainId] = std_configOf[evmVersion];

            // Create fork using this chain's RPC URL
            uint256 forkId = vm.createFork(_chainConfig[chainId].getRpcUrl(chainId));
            forkOf[chainId] = forkId;
            chainIds.push(chainId);
        }

        console.log("Forks successfully created");
        console.log("----------");
    }

    /// @notice  Selects the fork and sets the configured evm version associated with the requested chain ID.
    ///
    /// @dev     This function is a simple wrapper around `vm.selectFork` and `vm.setEvmVersion` with an assertion to
    ///          make sure that the chain was previously loaded.
    ///
    /// @param   chainId: the chain ID.
    function selectFork(uint256 chainId) internal isCached(chainId) {
        vm.selectFork(forkOf[chainId]);
        vm.setEvmVersion(profile[chainId].evm);
    }

    // -- DEPLOYMENT HELPERS ---------------------------------------------------

    /// @notice  Deploys a contract from an artifact file of the configured profile for the input chain.
    ///          Reverts if unable to find the artifact file that is derived from the inputs.
    ///          Reverts if the target artifact contains unlinked library placeholders.
    ///          Reverts if the fork of chain ID is not active.
    ///
    /// @param   chainId: the chain ID.
    /// @param   contractFile: the file that contains the contract's source code (i.e. "Counter.sol").
    /// @param   contractName: the name of the contract (i.e. "Counter").
    function deployCode(uint256 chainId, string memory contractFile, string memory contractName)
        internal
        returns (address)
    {
        string memory artifactPath = _getArtifactPath(chainId, contractFile, contractName);
        return vm.deployCode(artifactPath);
    }

    /// @notice  Deploys a contract from an artifact file of the configured profile for the input chain.
    ///          Reverts if unable to find the artifact file that is derived from the inputs.
    ///          Reverts if the target artifact contains unlinked library placeholders.
    ///          Reverts if the fork of chain ID is not active.
    ///
    /// @param   chainId: the chain ID.
    /// @param   contractFile: the file that contains the contract's source code (i.e. "Counter.sol").
    /// @param   contractName: the name of the contract (i.e. "Counter").
    /// @param   constructorArgs: abi-encoded constructor arguments.
    function deployCode(
        uint256 chainId,
        string memory contractFile,
        string memory contractName,
        bytes memory constructorArgs
    ) internal returns (address) {
        string memory artifactPath = _getArtifactPath(chainId, contractFile, contractName);
        return vm.deployCode(artifactPath, constructorArgs);
    }

    /// @notice  Deploys a contract from an artifact file of the configured profile for the input chain.
    ///          Reverts if unable to find the artifact file that is derived from the inputs.
    ///          Reverts if the target artifact contains unlinked library placeholders.
    ///          Reverts if the fork of chain ID is not active.
    ///
    /// @param   chainId: the chain ID.
    /// @param   contractFile: the file that contains the contract's source code (i.e. "Counter.sol").
    /// @param   contractName: the name of the contract (i.e. "Counter").
    /// @param   value: `msg.value`
    function deployCode(uint256 chainId, string memory contractFile, string memory contractName, uint256 value)
        internal
        returns (address)
    {
        string memory artifactPath = _getArtifactPath(chainId, contractFile, contractName);
        return vm.deployCode(artifactPath, value);
    }

    /// @notice  Deploys a contract from an artifact file of the configured profile for the input chain.
    ///          Reverts if unable to find the artifact file that is derived from the inputs.
    ///          Reverts if the target artifact contains unlinked library placeholders.
    ///          Reverts if the fork of chain ID is not active.
    ///
    /// @param   chainId: the chain ID.
    /// @param   contractFile: the file that contains the contract's source code (i.e. "Counter.sol").
    /// @param   contractName: the name of the contract (i.e. "Counter").
    /// @param   constructorArgs: abi-encoded constructor arguments.
    /// @param   value: `msg.value`
    function deployCode(
        uint256 chainId,
        string memory contractFile,
        string memory contractName,
        bytes memory constructorArgs,
        uint256 value
    ) internal returns (address) {
        string memory artifactPath = _getArtifactPath(chainId, contractFile, contractName);
        return vm.deployCode(artifactPath, constructorArgs, value);
    }

    /// @notice  Deploys a contract, using CREATE2, from an artifact file of the configured profile for the input chain.
    ///          Reverts if unable to find the artifact file that is derived from the inputs.
    ///          Reverts if the target artifact contains unlinked library placeholders.
    ///          Reverts if the fork of chain ID is not active.
    ///
    /// @param   chainId: the chain ID.
    /// @param   contractFile: the file that contains the contract's source code (i.e. "Counter.sol").
    /// @param   contractName: the name of the contract (i.e. "Counter").
    /// @param   salt: the salt used in CREATE2.
    function deployCode(uint256 chainId, string memory contractFile, string memory contractName, bytes32 salt)
        internal
        returns (address)
    {
        string memory artifactPath = _getArtifactPath(chainId, contractFile, contractName);
        return vm.deployCode(artifactPath, salt);
    }

    /// @notice  Deploys a contract, using CREATE2, from an artifact file of the configured profile for the input chain.
    ///          Reverts if unable to find the artifact file that is derived from the inputs.
    ///          Reverts if the target artifact contains unlinked library placeholders.
    ///          Reverts if the fork of chain ID is not active.
    ///
    /// @param   chainId: the chain ID.
    /// @param   contractFile: the file that contains the contract's source code (i.e. "Counter.sol").
    /// @param   contractName: the name of the contract (i.e. "Counter").
    /// @param   constructorArgs: abi-encoded constructor arguments.
    /// @param   salt: the salt used in CREATE2.
    function deployCode(
        uint256 chainId,
        string memory contractFile,
        string memory contractName,
        bytes memory constructorArgs,
        bytes32 salt
    ) internal returns (address) {
        string memory artifactPath = _getArtifactPath(chainId, contractFile, contractName);
        return vm.deployCode(artifactPath, constructorArgs, salt);
    }

    /// @notice  Deploys a contract, using CREATE2, from an artifact file of the configured profile for the input chain.
    ///          Reverts if unable to find the artifact file that is derived from the inputs.
    ///          Reverts if the target artifact contains unlinked library placeholders.
    ///          Reverts if the fork of chain ID is not active.
    ///
    /// @param   chainId: the chain ID.
    /// @param   contractFile: the file that contains the contract's source code (i.e. "Counter.sol").
    /// @param   contractName: the name of the contract (i.e. "Counter").
    /// @param   value: `msg.value`
    /// @param   salt: the salt used in CREATE2.
    function deployCode(
        uint256 chainId,
        string memory contractFile,
        string memory contractName,
        uint256 value,
        bytes32 salt
    ) internal returns (address) {
        string memory artifactPath = _getArtifactPath(chainId, contractFile, contractName);
        return vm.deployCode(artifactPath, value, salt);
    }

    /// @notice  Deploys a contract, using CREATE2, from an artifact file of the configured profile for the input chain.
    ///          Reverts if unable to find the artifact file that is derived from the inputs.
    ///          Reverts if the target artifact contains unlinked library placeholders.
    ///          Reverts if the fork of chain ID is not active.
    ///
    /// @param   chainId: the chain ID.
    /// @param   contractFile: the file that contains the contract's source code (i.e. "Counter.sol").
    /// @param   contractName: the name of the contract (i.e. "Counter").
    /// @param   constructorArgs: abi-encoded constructor arguments.
    /// @param   value: `msg.value`
    /// @param   salt: the salt used in CREATE2.
    function deployCode(
        uint256 chainId,
        string memory contractFile,
        string memory contractName,
        bytes memory constructorArgs,
        uint256 value,
        bytes32 salt
    ) internal returns (address) {
        string memory artifactPath = _getArtifactPath(chainId, contractFile, contractName);
        return vm.deployCode(artifactPath, constructorArgs, value, salt);
    }

    // -- INTERNAL HELPER FUNCTIONS AND MODIFIERS ------------------------------

    /// @dev Resolves a chain key to a chain ID (handles both numeric IDs and aliases).
    function _resolveChainId(string memory chainKey) private view returns (uint256) {
        try vm.parseUint(chainKey) returns (uint256 id) {
            return id;
        } catch {
            VmSafe.Chain memory chainInfo = vm.getChain(chainKey);
            return chainInfo.chainId;
        }
    }

    /// @notice  Returns the RPC URL for the requested chain ID.
    ///
    /// @dev     This function returns the RPC URL from the chain's StdConfig instance.
    ///
    /// @param   chainId: the chain ID.
    /// @return  The RPC URL for the chain.
    function _getRpcUrl(uint256 chainId) internal view isCached(chainId) returns (string memory) {
        return _chainConfig[chainId].getRpcUrl(chainId);
    }

    /// @notice  Constructs the artifact path for a contract and validates it has no unresolved libraries.
    ///          Reverts if the fork of chain ID is not active.
    ///
    /// @param   chainId: the chain ID.
    /// @param   contractFile: the file that contains the contract's source code (i.e. "Counter.sol").
    /// @param   contractName: the contract name (i.e. "Counter").
    /// @return  The full path to the artifact JSON file.
    function _getArtifactPath(uint256 chainId, string memory contractFile, string memory contractName)
        internal
        view
        isActive(chainId)
        returns (string memory)
    {
        return string.concat(profile[chainId].artifacts, "/", contractFile, "/", contractName, ".json");
    }

    function _assertCached(uint256 chainId) internal view {
        bool found;
        for (uint256 i = 0; i < chainIds.length; i++) {
            if (chainId == chainIds[i]) {
                found = true;
                break;
            }
        }
        if (!found) revert ForkNotLoaded(chainId);
    }

    function _assertActive(uint256 chainId) internal view {
        if (forkOf[chainId] != vm.activeFork()) revert ForkNotActive(chainId);
    }

    modifier isCached(uint256 chainId) {
        _assertCached(chainId);
        _;
    }

    modifier isActive(uint256 chainId) {
        _assertActive(chainId);
        _;
    }
}
