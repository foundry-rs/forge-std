// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;
pragma experimental ABIEncoderV2;

import {VmSafe} from "./Vm.sol";

/// @notice  A contract that parses a toml configuration file and load its
///          variables into storage, automatically casting them, on deployment.
///
/// @dev     This contract assumes a toml structure where top-level keys
///          represent chain ids or aliases. Under each chain key, variables are
///          organized by type in separate sub-tables like `[<chain>.<type>]`, where
///          type must be: `bool`, `address`, `uint`, `bytes32`, `string`, or `bytes`.
///
///          Supported format:
///          ```
///          [mainnet]
///          endpoint_url = "${MAINNET_RPC}"
///
///          [mainnet.bool]
///          is_live = true
///
///          [mainnet.address]
///          weth = "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2"
///          whitelisted_admins = [
///             "${MAINNET_ADMIN}",
///             "0x00000000000000000000000000000000deadbeef",
///             "0x000000000000000000000000000000c0ffeebabe"
///          ]
///
///          [mainnet.uint]
///          important_number = 123
///          ```
contract StdConfig {
    // -- CONSTANTS ------------------------------------------------------------

    /// @dev Forge Standard Library VM interface for cheat codes.
    VmSafe private constant vm = VmSafe(address(uint160(uint256(keccak256("hevm cheat code")))));

    // -- STORAGE (CACHE FROM CONFIG FILE) ------------------------------------

    // Path to the loaded TOML configuration file.
    string private _filePath;

    // List of top-level keys found in the TOML file, assumed to be chain names/aliases.
    string[] private _chainKeys;

    // Storage for the configured RPC URL for each chain [`chainId` -> `url`].
    mapping(uint256 => string) private _rpcOf;

    // Storage for values and arrays, organized by chain ID and variable key [`chainId` -> `key` -> `value`].
    mapping(uint256 => mapping(string => bytes)) private _valuesOf;
    mapping(uint256 => mapping(string => bytes)) private _arraysOf;

    // -- CONSTRUCTOR ----------------------------------------------------------

    /// @notice Reads the TOML file and iterates through each top-level key, which is
    ///         assumed to be a chain name or ID. For each chain, it caches its RPC
    ///         endpoint and all variables defined in typed sub-tables like `[<chain>.<type>]`,
    ///         where type must be: `bool`, `address`, `uint`, `bytes32`, `string`, or `bytes`.
    ///
    ///         The constructor attempts to parse each variable first as a single value,
    ///         and if that fails, as an array of that type. If a variable cannot be
    ///         parsed as either, the constructor will revert with an error.
    ///
    /// @param  configFilePath: The local path to the TOML configuration file.
    constructor(string memory configFilePath) public {
        _filePath = configFilePath;
        string memory content = vm.resolveEnv(vm.readFile(configFilePath));
        string[] memory chain_keys = vm.parseTomlKeys(content, "$");

        string[] memory types = new string[](6);
        types[0] = "bool";
        types[1] = "address";
        types[2] = "uint";
        types[3] = "bytes32";
        types[4] = "string";
        types[5] = "bytes";

        // Cache the entire configuration to storage
        for (uint256 i = 0; i < chain_keys.length; i++) {
            string memory chain_key = chain_keys[i];
            // Ignore top-level keys that are not tables
            if (vm.parseTomlKeys(content, _concat("$.", chain_key)).length == 0) {
                continue;
            }
            uint256 chain_id = resolveChainId(chain_key);
            _chainKeys.push(chain_key);

            // Cache the configure rpc endpoint for that chain.
            // Falls back to `[rpc_endpoints]`. Panics if no rpc endpoint is configured.
            try vm.parseTomlString(content, _concat("$.", chain_key, ".endpoint_url")) returns (string memory url) {
                _rpcOf[chain_id] = vm.resolveEnv(url);
            } catch {
                _rpcOf[chain_id] = vm.resolveEnv(vm.rpcUrl(chain_key));
            }

            for (uint256 t = 0; t < types.length; t++) {
                string memory var_type = types[t];
                string memory path_to_type = _concat("$.", chain_key, ".", var_type);

                try vm.parseTomlKeys(content, path_to_type) returns (string[] memory var_keys) {
                    for (uint256 j = 0; j < var_keys.length; j++) {
                        string memory var_key = var_keys[j];
                        string memory path_to_var = _concat(path_to_type, ".", var_key);
                        _loadAndCacheValue(content, path_to_var, chain_id, var_key, var_type);
                    }
                } catch {} // Section does not exist, ignore.
            }
        }
    }

    function _loadAndCacheValue(
        string memory content,
        string memory path_to_var,
        uint256 chain_id,
        string memory var_key,
        string memory var_type
    ) private {
        bytes32 typeHash = keccak256(bytes(var_type));
        bool success = false;

        if (typeHash == keccak256(bytes("bool"))) {
            try vm.parseTomlBool(content, path_to_var) returns (bool val) {
                _valuesOf[chain_id][var_key] = abi.encode(val);
                success = true;
            } catch {
                try vm.parseTomlBoolArray(content, path_to_var) returns (bool[] memory val) {
                    _arraysOf[chain_id][var_key] = abi.encode(val);
                    success = true;
                } catch {}
            }
        } else if (typeHash == keccak256(bytes("address"))) {
            try vm.parseTomlAddress(content, path_to_var) returns (address val) {
                _valuesOf[chain_id][var_key] = abi.encode(val);
                success = true;
            } catch {
                try vm.parseTomlAddressArray(content, path_to_var) returns (address[] memory val) {
                    _arraysOf[chain_id][var_key] = abi.encode(val);
                    success = true;
                } catch {}
            }
        } else if (typeHash == keccak256(bytes("uint"))) {
            try vm.parseTomlUint(content, path_to_var) returns (uint256 val) {
                _valuesOf[chain_id][var_key] = abi.encode(val);
                success = true;
            } catch {
                try vm.parseTomlUintArray(content, path_to_var) returns (uint256[] memory val) {
                    _arraysOf[chain_id][var_key] = abi.encode(val);
                    success = true;
                } catch {}
            }
        } else if (typeHash == keccak256(bytes("bytes32"))) {
            try vm.parseTomlBytes32(content, path_to_var) returns (bytes32 val) {
                _valuesOf[chain_id][var_key] = abi.encode(val);
                success = true;
            } catch {
                try vm.parseTomlBytes32Array(content, path_to_var) returns (bytes32[] memory val) {
                    _arraysOf[chain_id][var_key] = abi.encode(val);
                    success = true;
                } catch {}
            }
        } else if (typeHash == keccak256(bytes("bytes"))) {
            try vm.parseTomlBytes(content, path_to_var) returns (bytes memory val) {
                _valuesOf[chain_id][var_key] = abi.encode(val);
                success = true;
            } catch {
                try vm.parseTomlBytesArray(content, path_to_var) returns (bytes[] memory val) {
                    _arraysOf[chain_id][var_key] = abi.encode(val);
                    success = true;
                } catch {}
            }
        } else if (typeHash == keccak256(bytes("string"))) {
            try vm.parseTomlString(content, path_to_var) returns (string memory val) {
                _valuesOf[chain_id][var_key] = abi.encode(val);
                success = true;
            } catch {
                try vm.parseTomlStringArray(content, path_to_var) returns (string[] memory val) {
                    _arraysOf[chain_id][var_key] = abi.encode(val);
                    success = true;
                } catch {}
            }
        }

        if (!success) {
            revert(_concat("Unable to parse variable '", var_key, "'"));
        }
    }

    // -- HELPER FUNCTIONS -----------------------------------------------------\n

    /// @notice Resolves a chain alias or a chain id string to its numerical chain id.
    /// @param aliasOrId The string representing the chain alias (i.e. "mainnet") or a numerical ID (i.e. "1").
    /// @return The numerical chain ID.
    /// @dev It first attempts to parse the input as a number. If that fails, it uses `vm.getChain` to resolve a named alias.
    ///      Reverts if the alias is not valid or not a number.
    function resolveChainId(string memory aliasOrId) public view returns (uint256) {
        try vm.parseUint(aliasOrId) returns (uint256 chainId) {
            return chainId;
        } catch {
            try vm.getChain(aliasOrId) returns (VmSafe.Chain memory chainInfo) {
                return chainInfo.chainId;
            } catch {
                revert(_concat("chain key: '", aliasOrId, "' is not a valid alias nor a number."));
            }
        }
    }

    /// @dev Retrieves the chain key/alias from the configuration based on the chain ID.
    function _getChainKeyFromId(uint256 chainId) private view returns (string memory) {
        for (uint256 i = 0; i < _chainKeys.length; i++) {
            if (resolveChainId(_chainKeys[i]) == chainId) {
                return _chainKeys[i];
            }
        }
        revert(_concat("chain id: '", vm.toString(chainId), "' not found in configuration"));
    }

    /// @dev concatenates two strings
    function _concat(string memory s1, string memory s2) private pure returns (string memory) {
        return string(abi.encodePacked(s1, s2));
    }

    /// @dev concatenates three strings
    function _concat(string memory s1, string memory s2, string memory s3) private pure returns (string memory) {
        return string(abi.encodePacked(s1, s2, s3));
    }

    /// @dev concatenates four strings
    function _concat(string memory s1, string memory s2, string memory s3, string memory s4)
        private
        pure
        returns (string memory)
    {
        return string(abi.encodePacked(s1, s2, s3, s4));
    }

    /// @dev Wraps a string in double quotes for JSON compatibility.
    function _quote(string memory s) private pure returns (string memory) {
        return _concat('"', s, '"');
    }

    /// @dev Writes a JSON-formatted value to a specific key in the TOML file.
    /// @param chainId The chain id to write under.
    /// @param ty The type category ('bool', 'address', 'uint', 'bytes32', 'string', or 'bytes').
    /// @param key The variable key name.
    /// @param jsonValue The JSON-formatted value to write.
    function _writeToToml(uint256 chainId, string memory ty, string memory key, string memory jsonValue) private {
        string memory chainKey = _getChainKeyFromId(chainId);
        string memory valueKey = _concat("$.", chainKey, ".", _concat(ty, ".", key));
        vm.writeTomlUpsert(jsonValue, _filePath, valueKey);
    }

    // -- GETTER FUNCTIONS -----------------------------------------------------

    /// @notice Returns the numerical chain ids for all configured chains.
    function getChainIds() public view returns (uint256[] memory) {
        string[] memory keys = _chainKeys;

        uint256[] memory ids = new uint256[](keys.length);
        for (uint256 i = 0; i < keys.length; i++) {
            ids[i] = resolveChainId(keys[i]);
        }

        return ids;
    }

    /// @notice Reads the RPC URL for a specific chain id.
    function getRpcUrl(uint256 chain_id) public view returns (string memory) {
        return _rpcOf[chain_id];
    }

    /// @notice Reads the RPC URL for the current chain.
    function getRpcUrl() public view returns (string memory) {
        return _rpcOf[vm.getChainId()];
    }

    /// @notice Reads a boolean value for a given key and chain ID.
    function getBool(uint256 chain_id, string memory key) public view returns (bool) {
        bytes memory val = _valuesOf[chain_id][key];
        require(val.length > 0, "Value not found");
        return abi.decode(val, (bool));
    }

    /// @notice Reads a boolean value for a given key on the current chain.
    function getBool(string memory key) public view returns (bool) {
        return getBool(vm.getChainId(), key);
    }

    /// @notice Reads a uint256 value for a given key and chain ID.
    function getUint(uint256 chain_id, string memory key) public view returns (uint256) {
        bytes memory val = _valuesOf[chain_id][key];
        require(val.length > 0, "Value not found");
        return abi.decode(val, (uint256));
    }

    /// @notice Reads a uint256 value for a given key on the current chain.
    function getUint(string memory key) public view returns (uint256) {
        return getUint(vm.getChainId(), key);
    }

    /// @notice Reads an address value for a given key and chain ID.
    function getAddress(uint256 chain_id, string memory key) public view returns (address) {
        bytes memory val = _valuesOf[chain_id][key];
        require(val.length > 0, "Value not found");
        return abi.decode(val, (address));
    }

    /// @notice Reads an address value for a given key on the current chain.
    function getAddress(string memory key) public view returns (address) {
        return getAddress(vm.getChainId(), key);
    }

    /// @notice Reads a bytes32 value for a given key and chain ID.
    function getBytes32(uint256 chain_id, string memory key) public view returns (bytes32) {
        bytes memory val = _valuesOf[chain_id][key];
        require(val.length > 0, "Value not found");
        return abi.decode(val, (bytes32));
    }

    /// @notice Reads a bytes32 value for a given key on the current chain.
    function getBytes32(string memory key) public view returns (bytes32) {
        return getBytes32(vm.getChainId(), key);
    }

    /// @notice Reads a string value for a given key and chain ID.
    function getString(uint256 chain_id, string memory key) public view returns (string memory) {
        bytes memory val = _valuesOf[chain_id][key];
        require(val.length > 0, "Value not found");
        return abi.decode(val, (string));
    }

    /// @notice Reads a string value for a given key on the current chain.
    function getString(string memory key) public view returns (string memory) {
        return getString(vm.getChainId(), key);
    }

    /// @notice Reads a bytes value for a given key and chain ID.
    function getBytes(uint256 chain_id, string memory key) public view returns (bytes memory) {
        bytes memory val = _valuesOf[chain_id][key];
        require(val.length > 0, "Value not found");
        return abi.decode(val, (bytes));
    }

    /// @notice Reads a bytes value for a given key on the current chain.
    function getBytes(string memory key) public view returns (bytes memory) {
        return getBytes(vm.getChainId(), key);
    }

    /// @notice Reads a boolean array for a given key and chain ID.
    function getBoolArray(uint256 chain_id, string memory key) public view returns (bool[] memory) {
        bytes memory val = _arraysOf[chain_id][key];
        require(val.length > 0, "Value not found");
        return abi.decode(val, (bool[]));
    }

    /// @notice Reads a boolean array for a given key on the current chain.
    function getBoolArray(string memory key) public view returns (bool[] memory) {
        return getBoolArray(vm.getChainId(), key);
    }

    /// @notice Reads a uint256 array for a given key and chain ID.
    function getUintArray(uint256 chain_id, string memory key) public view returns (uint256[] memory) {
        bytes memory val = _arraysOf[chain_id][key];
        require(val.length > 0, "Value not found");
        return abi.decode(val, (uint256[]));
    }

    /// @notice Reads a uint256 array for a given key on the current chain.
    function getUintArray(string memory key) public view returns (uint256[] memory) {
        return getUintArray(vm.getChainId(), key);
    }

    /// @notice Reads an address array for a given key and chain ID.
    function getAddressArray(uint256 chain_id, string memory key) public view returns (address[] memory) {
        bytes memory val = _arraysOf[chain_id][key];
        require(val.length > 0, "Value not found");
        return abi.decode(val, (address[]));
    }

    /// @notice Reads an address array for a given key on the current chain.
    function getAddressArray(string memory key) public view returns (address[] memory) {
        return getAddressArray(vm.getChainId(), key);
    }

    /// @notice Reads a bytes32 array for a given key and chain ID.
    function getBytes32Array(uint256 chain_id, string memory key) public view returns (bytes32[] memory) {
        bytes memory val = _arraysOf[chain_id][key];
        require(val.length > 0, "Value not found");
        return abi.decode(val, (bytes32[]));
    }

    /// @notice Reads a bytes32 array for a given key on the current chain.
    function getBytes32Array(string memory key) public view returns (bytes32[] memory) {
        return getBytes32Array(vm.getChainId(), key);
    }

    /// @notice Reads a string array for a given key and chain ID.
    function getStringArray(uint256 chain_id, string memory key) public view returns (string[] memory) {
        bytes memory val = _arraysOf[chain_id][key];
        require(val.length > 0, "Value not found");
        return abi.decode(val, (string[]));
    }

    /// @notice Reads a string array for a given key on the current chain.
    function getStringArray(string memory key) public view returns (string[] memory) {
        return getStringArray(vm.getChainId(), key);
    }

    /// @notice Reads a bytes array for a given key and chain ID.
    function getBytesArray(uint256 chain_id, string memory key) public view returns (bytes[] memory) {
        bytes memory val = _arraysOf[chain_id][key];
        require(val.length > 0, "Value not found");
        return abi.decode(val, (bytes[]));
    }

    /// @notice Reads a bytes array for a given key on the current chain.
    function getBytesArray(string memory key) public view returns (bytes[] memory) {
        return getBytesArray(vm.getChainId(), key);
    }

    // -- SETTER FUNCTIONS -----------------------------------------------------

    /// @notice Sets a boolean value for a given key and chain ID.
    /// @dev    Sets the cached value in storage and optionally writes the change back to the TOML file.
    function set(uint256 chainId, string memory key, bool value, bool write) public {
        _valuesOf[chainId][key] = abi.encode(value);
        if (write) _writeToToml(chainId, "bool", key, vm.toString(value));
    }

    /// @notice Sets a boolean value for a given key on the current chain.
    /// @dev    Sets the cached value in storage and optionally writes the change back to the TOML file.
    function set(string memory key, bool value, bool write) public {
        set(vm.getChainId(), key, value, write);
    }

    /// @notice Sets a uint256 value for a given key and chain ID.
    /// @dev    Sets the cached value in storage and optionally writes the change back to the TOML file.
    function set(uint256 chainId, string memory key, uint256 value, bool write) public {
        _valuesOf[chainId][key] = abi.encode(value);
        if (write) _writeToToml(chainId, "uint", key, vm.toString(value));
    }

    /// @notice Sets a uint256 value for a given key on the current chain.
    /// @dev    Sets the cached value in storage and optionally writes the change back to the TOML file.
    function set(string memory key, uint256 value, bool write) public {
        set(vm.getChainId(), key, value, write);
    }

    /// @notice Sets an address value for a given key and chain ID.
    /// @dev    Sets the cached value in storage and optionally writes the change back to the TOML file.
    function set(uint256 chainId, string memory key, address value, bool write) public {
        _valuesOf[chainId][key] = abi.encode(value);
        if (write) _writeToToml(chainId, "address", key, _quote(vm.toString(value)));
    }

    /// @notice Sets an address value for a given key on the current chain.
    /// @dev    Sets the cached value in storage and optionally writes the change back to the TOML file.
    function set(string memory key, address value, bool write) public {
        set(vm.getChainId(), key, value, write);
    }

    /// @notice Sets a bytes32 value for a given key and chain ID.
    /// @dev    Sets the cached value in storage and optionally writes the change back to the TOML file.
    function set(uint256 chainId, string memory key, bytes32 value, bool write) public {
        _valuesOf[chainId][key] = abi.encode(value);
        if (write) _writeToToml(chainId, "bytes32", key, _quote(vm.toString(value)));
    }

    /// @notice Sets a bytes32 value for a given key on the current chain.
    /// @dev    Sets the cached value in storage and optionally writes the change back to the TOML file.
    function set(string memory key, bytes32 value, bool write) public {
        set(vm.getChainId(), key, value, write);
    }

    /// @notice Sets a string value for a given key and chain ID.
    /// @dev    Sets the cached value in storage and optionally writes the change back to the TOML file.
    function set(uint256 chainId, string memory key, string memory value, bool write) public {
        _valuesOf[chainId][key] = abi.encode(value);
        if (write) _writeToToml(chainId, "string", key, _quote(value));
    }

    /// @notice Sets a string value for a given key on the current chain.
    /// @dev    Sets the cached value in storage and optionally writes the change back to the TOML file.
    function set(string memory key, string memory value, bool write) public {
        set(vm.getChainId(), key, value, write);
    }

    /// @notice Sets a bytes value for a given key and chain ID.
    /// @dev    Sets the cached value in storage and optionally writes the change back to the TOML file.
    function set(uint256 chainId, string memory key, bytes memory value, bool write) public {
        _valuesOf[chainId][key] = abi.encode(value);
        if (write) _writeToToml(chainId, "bytes", key, _quote(vm.toString(value)));
    }

    /// @notice Sets a bytes value for a given key on the current chain.
    /// @dev    Sets the cached value in storage and optionally writes the change back to the TOML file.
    function set(string memory key, bytes memory value, bool write) public {
        set(vm.getChainId(), key, value, write);
    }

    /// @notice Sets a boolean array for a given key and chain ID.
    /// @dev    Sets the cached value in storage and optionally writes the change back to the TOML file.
    function set(uint256 chainId, string memory key, bool[] memory value, bool write) public {
        _arraysOf[chainId][key] = abi.encode(value);
        if (write) {
            string memory json = "[";
            for (uint256 i = 0; i < value.length; i++) {
                json = _concat(json, vm.toString(value[i]));
                if (i < value.length - 1) json = _concat(json, ",");
            }
            json = _concat(json, "]");
            _writeToToml(chainId, "bool", key, json);
        }
    }

    /// @notice Sets a boolean array for a given key on the current chain.
    /// @dev    Sets the cached value in storage and optionally writes the change back to the TOML file.
    function set(string memory key, bool[] memory value, bool write) public {
        set(vm.getChainId(), key, value, write);
    }

    /// @notice Sets a uint256 array for a given key and chain ID.
    /// @dev    Sets the cached value in storage and optionally writes the change back to the TOML file.
    function set(uint256 chainId, string memory key, uint256[] memory value, bool write) public {
        _arraysOf[chainId][key] = abi.encode(value);
        if (write) {
            string memory json = "[";
            for (uint256 i = 0; i < value.length; i++) {
                json = _concat(json, vm.toString(value[i]));
                if (i < value.length - 1) json = _concat(json, ",");
            }
            json = _concat(json, "]");
            _writeToToml(chainId, "uint", key, json);
        }
    }

    /// @notice Sets a uint256 array for a given key on the current chain.
    /// @dev    Sets the cached value in storage and optionally writes the change back to the TOML file.
    function set(string memory key, uint256[] memory value, bool write) public {
        set(vm.getChainId(), key, value, write);
    }

    /// @notice Sets an address array for a given key and chain ID.
    /// @dev    Sets the cached value in storage and optionally writes the change back to the TOML file.
    function set(uint256 chainId, string memory key, address[] memory value, bool write) public {
        _arraysOf[chainId][key] = abi.encode(value);
        if (write) {
            string memory json = "[";
            for (uint256 i = 0; i < value.length; i++) {
                json = _concat(json, _quote(vm.toString(value[i])));
                if (i < value.length - 1) json = _concat(json, ",");
            }
            json = _concat(json, "]");
            _writeToToml(chainId, "address", key, json);
        }
    }

    /// @notice Sets an address array for a given key on the current chain.
    /// @dev    Sets the cached value in storage and optionally writes the change back to the TOML file.
    function set(string memory key, address[] memory value, bool write) public {
        set(vm.getChainId(), key, value, write);
    }

    /// @notice Sets a bytes32 array for a given key and chain ID.
    /// @dev    Sets the cached value in storage and optionally writes the change back to the TOML file.
    function set(uint256 chainId, string memory key, bytes32[] memory value, bool write) public {
        _arraysOf[chainId][key] = abi.encode(value);
        if (write) {
            string memory json = "[";
            for (uint256 i = 0; i < value.length; i++) {
                json = _concat(json, _quote(vm.toString(value[i])));
                if (i < value.length - 1) json = _concat(json, ",");
            }
            json = _concat(json, "]");
            _writeToToml(chainId, "bytes32", key, json);
        }
    }

    /// @notice Sets a bytes32 array for a given key on the current chain.
    /// @dev    Sets the cached value in storage and optionally writes the change back to the TOML file.
    function set(string memory key, bytes32[] memory value, bool write) public {
        set(vm.getChainId(), key, value, write);
    }

    /// @notice Sets a string array for a given key and chain ID.
    /// @dev    Sets the cached value in storage and optionally writes the change back to the TOML file.
    function set(uint256 chainId, string memory key, string[] memory value, bool write) public {
        _arraysOf[chainId][key] = abi.encode(value);
        if (write) {
            string memory json = "[";
            for (uint256 i = 0; i < value.length; i++) {
                json = _concat(json, _quote(value[i]));
                if (i < value.length - 1) json = _concat(json, ",");
            }
            json = _concat(json, "]");
            _writeToToml(chainId, "string", key, json);
        }
    }

    /// @notice Sets a string array for a given key on the current chain.
    /// @dev    Sets the cached value in storage and optionally writes the change back to the TOML file.
    function set(string memory key, string[] memory value, bool write) public {
        set(vm.getChainId(), key, value, write);
    }

    /// @notice Sets a bytes array for a given key and chain ID.
    /// @dev    Sets the cached value in storage and optionally writes the change back to the TOML file.
    function set(uint256 chainId, string memory key, bytes[] memory value, bool write) public {
        _arraysOf[chainId][key] = abi.encode(value);
        if (write) {
            string memory json = "[";
            for (uint256 i = 0; i < value.length; i++) {
                json = _concat(json, _quote(vm.toString(value[i])));
                if (i < value.length - 1) json = _concat(json, ",");
            }
            json = _concat(json, "]");
            _writeToToml(chainId, "bytes", key, json);
        }
    }

    /// @notice Sets a bytes array for a given key on the current chain.
    /// @dev    Sets the cached value in storage and optionally writes the change back to the TOML file.
    function set(string memory key, bytes[] memory value, bool write) public {
        set(vm.getChainId(), key, value, write);
    }
}
