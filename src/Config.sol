// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {VmSafe} from "./Vm.sol";

/**
 * @title Config
 * @notice An abstract contract to parse a TOML configuration file and load its
 *         variables into structured storage on deployment.
 * @dev This contract assumes a flat TOML structure where top-level keys
 *      represent chain IDs or profiles, and the keys under them are the
 *      configuration variables. Nested tables are ignored by this implementation.
 *
 *      Supported TOML Format:
 *      ```
 *      [mainnet]
 *      endpoint_url = "https://eth.llamarpc.com"
 *
 *      [mainnet.vars]
 *      is_live = true
 *      weth = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"
 *      whitelisted_admins = [
 *          "0x0000000000000000000000000000000000000001",
 *          "0x0000000000000000000000000000000000000002"
 *      ]
 *
 *      [optimism]
 *      endpoint_url = "https://mainnet.optimism.io"
 *
 *      [optimism.vars]
 *      is_live = false
 *      weth = "0x4200000000000000000000000000000000000006"
 *      ```
 */
abstract contract Config {
    VmSafe private constant vm = VmSafe(address(uint160(uint256(keccak256("hevm cheat code")))));

    // --- STORAGE (CACHE FROM CONFIG FILE) ------------------------------------

    // Storage for the configured RPC url.
    mapping(uint256 chainId => string url) private rpcOf;

    // Storage for variable types.
    mapping(uint256 chainId => mapping(string key => bool value)) private boolsOf;
    mapping(uint256 chainId => mapping(string key => uint256 value)) private uintsOf;
    mapping(uint256 chainId => mapping(string key => address value)) private addressesOf;
    mapping(uint256 chainId => mapping(string key => bytes32 value)) private bytes32sOf;
    mapping(uint256 chainId => mapping(string key => string value)) private stringsOf;
    mapping(uint256 chainId => mapping(string key => bytes value)) private bytesOf;

    // Storage for array variable types.
    mapping(uint256 chainId => mapping(string key => bool[] value)) private boolArraysOf;
    mapping(uint256 chainId => mapping(string key => uint256[] value)) private uintArraysOf;
    mapping(uint256 chainId => mapping(string key => address[] value)) private addressArraysOf;
    mapping(uint256 chainId => mapping(string key => bytes32[] value)) private bytes32ArraysOf;
    mapping(uint256 chainId => mapping(string key => string[] value)) private stringArraysOf;
    mapping(uint256 chainId => mapping(string key => bytes[] value)) private bytesArraysOf;

    // --- CONSTRUCTOR ---------------------------------------------------------

    /// @notice Reads the TOML file and iterates through each top-level key, which is
    ///         assumed to be a chain name or ID. For each chain, it caches its RPC
    ///         endpoint and all variables defined in its `vars` sub-table.
    ///
    ///         The constructor uses a series of try-catch blocks to determine the type
    ///         of each variable. It attempts to parse array types (e.g., `address[]`)
    ///         before their singular counterparts (`address`) to ensure correct type
    ///         inference. If a variable cannot be parsed as any of the supported types,
    ///         the constructor will revert with an error.
    ///
    /// @param  configFilePath: The local path to the TOML configuration file.
    constructor(string memory configFilePath) {
        string memory content = vm.readFile(configFilePath);
        string[] memory chain_keys = vm.parseTomlKeys(content, "$");

        // Cache the entire configuration to storage
        for (uint i = 0; i < chain_keys.length; i++) {
            string memory chain_key = chain_keys[i];
            uint256 chain_id = resolveChainId(chain_key);

            // Cache the configure rpc endpoint for that chain.
            // Falls back to `[rpc_endpoints]`. Panics if no rpc endpoint is configured.
            try vm.parseTomlString(content, string.concat("$.", chain_key, ".endpoint_url")) returns (string memory url) {
                rpcOf[chain_id] = url;
            } catch {
                rpcOf[chain_id] = vm.rpcUrl(chain_key);
            }

            string memory path_to_chain = string.concat("$.", chain_key, ".vars");
            string[] memory var_keys = vm.parseTomlKeys(content, path_to_chain);

            // Parse and cache variables
            for (uint j = 0; j < var_keys.length; j++) {
                string memory var_key = var_keys[j];
                string memory path_to_var = string.concat(path_to_chain, ".", var_key);

                // Attempt to parse as a boolean array
                try vm.parseTomlBoolArray(content, path_to_var) returns (bool[] memory val) {
                    boolArraysOf[chain_id][var_key] = val;
                    continue;
                } catch {}

                // Attempt to parse as a boolean
                try vm.parseTomlBool(content, path_to_var) returns (bool val) {
                    boolsOf[chain_id][var_key] = val;
                    continue;
                } catch {}

                // Attempt to parse as an address array
                try vm.parseTomlAddressArray(content, path_to_var) returns (address[] memory val) {
                    addressArraysOf[chain_id][var_key] = val;
                    continue;
                } catch {}

                // Attempt to parse as an address
                try vm.parseTomlAddress(content, path_to_var) returns (address val) {
                    addressesOf[chain_id][var_key] = val;
                    continue;
                } catch {}

                // Attempt to parse as a uint256 array
                try vm.parseTomlUintArray(content, path_to_var) returns (uint256[] memory val) {
                    uintArraysOf[chain_id][var_key] = val;
                    continue;
                } catch {}

                // Attempt to parse as a uint256
                try vm.parseTomlUint(content, path_to_var) returns (uint256 val) {
                    uintsOf[chain_id][var_key] = val;
                    continue;
                } catch {}

                // Attempt to parse as a bytes32 array
                try vm.parseTomlBytes32Array(content, path_to_var) returns (bytes32[] memory val) {
                    bytes32ArraysOf[chain_id][var_key] = val;
                    continue;
                } catch {}

                // Attempt to parse as a bytes32
                try vm.parseTomlBytes32(content, path_to_var) returns (bytes32 val) {
                    bytes32sOf[chain_id][var_key] = val;
                    continue;
                } catch {}

                // Attempt to parse as a bytes array
                try vm.parseTomlBytesArray(content, path_to_var) returns (bytes[] memory val) {
                    bytesArraysOf[chain_id][var_key] = val;
                    continue;
                } catch {}

                // Attempt to parse as bytes
                try vm.parseTomlBytes(content, path_to_var) returns (bytes memory val) {
                    bytesOf[chain_id][var_key] = val;
                    continue;
                } catch {}

                // Attempt to parse as a string array
                try vm.parseTomlStringArray(content, path_to_var) returns (string[] memory val) {
                    stringArraysOf[chain_id][var_key] = val;
                    continue;
                } catch {}

                // Attempt to parse as a string (last, as it can be a fallback)
                try vm.parseTomlString(content, path_to_var) returns (string memory val) {
                    stringsOf[chain_id][var_key] = val;
                    continue;
                } catch {}

                revert(string.concat("unable to parse variable: '", var_key, "' from '[", chain_key, "']"));
            }
        }
    }

    // --- HELPER FUNCTIONS ----------------------------------------------------

    function resolveChainId(string memory aliasOrId) private view returns (uint256) {
        try vm.parseUint(aliasOrId) returns (uint256 chainId) {
            return chainId;
        } catch {
            try vm.getChain(aliasOrId) returns (VmSafe.Chain memory chainInfo) {
                return chainInfo.chainId;
            } catch {
                revert(string.concat("chain key: '", aliasOrId, "' is not a valid alias nor a number."));
            }
        }
    }

    // --- GETTER FUNCTIONS ----------------------------------------------------

    function readBool(uint256 chain_id, string memory key) public view returns (bool) {
        return boolsOf[chain_id][key];
    }

    function readUint(uint256 chain_id, string memory key) public view returns (uint256) {
        return uintsOf[chain_id][key];
    }

    function readAddress(uint256 chain_id, string memory key) public view returns (address) {
        return addressesOf[chain_id][key];
    }

    function readBytes32(uint256 chain_id, string memory key) public view returns (bytes32) {
        return bytes32sOf[chain_id][key];
    }

    function readString(uint256 chain_id, string memory key) public view returns (string memory) {
        return stringsOf[chain_id][key];
    }

    function readBytes(uint256 chain_id, string memory key) public view returns (bytes memory) {
        return bytesOf[chain_id][key];
    }

    function readBoolArray(uint256 chain_id, string memory key) public view returns (bool[] memory) {
        return boolArraysOf[chain_id][key];
    }

    function readUintArray(uint256 chain_id, string memory key) public view returns (uint256[] memory) {
        return uintArraysOf[chain_id][key];
    }

    function readAddressArray(uint256 chain_id, string memory key) public view returns (address[] memory) {
        return addressArraysOf[chain_id][key];
    }

    function readBytes32Array(uint256 chain_id, string memory key) public view returns (bytes32[] memory) {
        return bytes32ArraysOf[chain_id][key];
    }

    function readStringArray(uint256 chain_id, string memory key) public view returns (string[] memory) {
        return stringArraysOf[chain_id][key];
    }

    function readBytesArray(uint256 chain_id, string memory key) public view returns (bytes[] memory) {
        return bytesArraysOf[chain_id][key];
    }
}
