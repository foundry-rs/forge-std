
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {VmSafe} from "./Vm.sol";

/// @notice  A contract that parses a toml configuration file and load its
///          variables into storage, automatically casting them, on deployment.
///
/// @dev     This contract assumes a toml structure where top-level keys
///          represent chain ids or profiles. Under each chain key, variables are
///          organized by type in separate sub-tables.
///
///          Supported format:
///          ```
///          [mainnet]
///          endpoint_url = "https://eth.llamarpc.com"
///
///          [mainnet.bool]
///          is_live = true
///
///          [mainnet.address]
///          weth = "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2"
///          whitelisted_admins = [
///             "0x0000000000000000000000000000000000000001",
///             "0x0000000000000000000000000000000000000002"
///          ]
///
///          [optimism.uint]
///          important_number = 123
///          ```
contract StdConfig {
    VmSafe private constant vm = VmSafe(address(uint160(uint256(keccak256("hevm cheat code")))));

    // -- STORAGE (CACHE FROM CONFIG FILE) -------------------------------------

    // File path
    string private _filePath;

    // Keys of the configured chains.
    string[] private _chainKeys;

    // Storage for the configured RPC url.
    mapping(uint256 chainId => string url) private _rpcOf;

    // Storage for variable types.
    mapping(uint256 chainId => mapping(string key => bool value)) private _boolsOf;
    mapping(uint256 chainId => mapping(string key => uint256 value)) private _uintsOf;
    mapping(uint256 chainId => mapping(string key => address value)) private _addressesOf;
    mapping(uint256 chainId => mapping(string key => bytes32 value)) private _bytes32sOf;
    mapping(uint256 chainId => mapping(string key => string value)) private _stringsOf;
    mapping(uint256 chainId => mapping(string key => bytes value)) private _bytesOf;

    // Storage for array variable types.
    mapping(uint256 chainId => mapping(string key => bool[] value)) private _boolArraysOf;
    mapping(uint256 chainId => mapping(string key => uint256[] value)) private _uintArraysOf;
    mapping(uint256 chainId => mapping(string key => address[] value)) private _addressArraysOf;
    mapping(uint256 chainId => mapping(string key => bytes32[] value)) private _bytes32ArraysOf;
    mapping(uint256 chainId => mapping(string key => string[] value)) private _stringArraysOf;
    mapping(uint256 chainId => mapping(string key => bytes[] value)) private _bytesArraysOf;

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
    constructor(string memory configFilePath) {
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
        for (uint i = 0; i < chain_keys.length; i++) {
            string memory chain_key = chain_keys[i];
            // Top-level keys that are not tables should be ignored (e.g. `profile = "default"`).
            if (vm.parseTomlKeys(content, string.concat("$.", chain_key)).length == 0) {
                continue;
            }
            uint256 chain_id = resolveChainId(chain_key);
            _chainKeys.push(chain_key);

            // Cache the configure rpc endpoint for that chain.
            // Falls back to `[rpc_endpoints]`. Panics if no rpc endpoint is configured.
            try vm.parseTomlString(content, string.concat("$.", chain_key, ".endpoint_url")) returns (string memory url) {
                _rpcOf[chain_id] = vm.resolveEnv(url);
            } catch {
                _rpcOf[chain_id] = vm.resolveEnv(vm.rpcUrl(chain_key));
            }

            for (uint t = 0; t < types.length; t++) {
                string memory var_type = types[t];
                string memory path_to_type = string.concat("$.", chain_key, ".", var_type);

                try vm.parseTomlKeys(content, path_to_type) returns (string[] memory var_keys) {
                    for (uint j = 0; j < var_keys.length; j++) {
                        string memory var_key = var_keys[j];
                        string memory path_to_var = string.concat(path_to_type, ".", var_key);
                        bool success = false;

                        if (keccak256(bytes(var_type)) == keccak256(bytes("bool"))) {
                            try vm.parseTomlBool(content, path_to_var) returns (bool val) {
                                _boolsOf[chain_id][var_key] = val;
                                success = true;
                            } catch {
                                try vm.parseTomlBoolArray(content, path_to_var) returns (bool[] memory val) {
                                    _boolArraysOf[chain_id][var_key] = val;
                                    success = true;
                                } catch {}
                            }
                        } else if (keccak256(bytes(var_type)) == keccak256(bytes("address"))) {
                            try vm.parseTomlAddress(content, path_to_var) returns (address val) {
                                _addressesOf[chain_id][var_key] = val;
                                success = true;
                            } catch {
                                try vm.parseTomlAddressArray(content, path_to_var) returns (address[] memory val) {
                                    _addressArraysOf[chain_id][var_key] = val;
                                    success = true;
                                } catch {}
                            }
                        } else if (keccak256(bytes(var_type)) == keccak256(bytes("uint"))) {
                            try vm.parseTomlUint(content, path_to_var) returns (uint256 val) {
                                _uintsOf[chain_id][var_key] = val;
                                success = true;
                            } catch {
                                try vm.parseTomlUintArray(content, path_to_var) returns (uint256[] memory val) {
                                    _uintArraysOf[chain_id][var_key] = val;
                                    success = true;
                                } catch {}
                            }
                        } else if (keccak256(bytes(var_type)) == keccak256(bytes("bytes32"))) {
                            try vm.parseTomlBytes32(content, path_to_var) returns (bytes32 val) {
                                _bytes32sOf[chain_id][var_key] = val;
                                success = true;
                            } catch {
                                try vm.parseTomlBytes32Array(content, path_to_var) returns (bytes32[] memory val) {
                                    _bytes32ArraysOf[chain_id][var_key] = val;
                                    success = true;
                                } catch {}
                            }
                        } else if (keccak256(bytes(var_type)) == keccak256(bytes("bytes"))) {
                            try vm.parseTomlBytes(content, path_to_var) returns (bytes memory val) {
                                _bytesOf[chain_id][var_key] = val;
                                success = true;
                            } catch {
                                try vm.parseTomlBytesArray(content, path_to_var) returns (bytes[] memory val) {
                                    _bytesArraysOf[chain_id][var_key] = val;
                                    success = true;
                                } catch {}
                            }
                        } else if (keccak256(bytes(var_type)) == keccak256(bytes("string"))) {
                            try vm.parseTomlString(content, path_to_var) returns (string memory val) {
                                _stringsOf[chain_id][var_key] = val;
                                success = true;
                            } catch {
                                try vm.parseTomlStringArray(content, path_to_var) returns (string[] memory val) {
                                    _stringArraysOf[chain_id][var_key] = val;
                                    success = true;
                                } catch {}
                            }
                        }

                        if (!success) {
                            revert(
                                string.concat(
                                    "Unable to parse variable '", var_key, "' from '[", chain_key, ".", var_type, "]'"
                                )
                            );
                        }
                    }
                } catch {} // Section does not exist, ignore.
            }
        }
    }

    // -- HELPER FUNCTIONS -----------------------------------------------------\n

    function resolveChainId(string memory aliasOrId) public view returns (uint256) {
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

    function _getChainKeyFromId(uint256 chainId) private view returns (string memory) {
        for (uint i = 0; i < _chainKeys.length; i++) {
            if (resolveChainId(_chainKeys[i]) == chainId) {
                return _chainKeys[i];
            }
        }
        revert(string.concat("chain id: '", vm.toString(chainId), "' not found in configuration"));
    }

    /// @dev Wraps a string in double quotes for JSON compatibility.
    function _quote(string memory s) private pure returns (string memory) {
        return string.concat('"', s, '"');
    }

    /// @dev Writes a JSON-formatted value to a specific key in the TOML file.
    function _writeToToml(uint256 chainId, string memory ty, string memory key, string memory jsonValue) private {
        string memory chainKey = _getChainKeyFromId(chainId);
        string memory valueKey = string.concat("$.", chainKey, ".", ty, ".", key);
        vm.writeToml(jsonValue, _filePath, valueKey);
    }

    // -- GETTER FUNCTIONS -----------------------------------------------------

    function readChainIds() public view returns (uint256[] memory) {
        string[] memory keys = _chainKeys;

        uint256[] memory ids = new uint256[](keys.length);
        for (uint i = 0; i < keys.length; i++) {
            ids[i] = resolveChainId(keys[i]);
        }

        return ids;
    }

    function readRpcUrl(uint256 chain_id) public view returns (string memory) {
        return _rpcOf[chain_id];
    }

    function readRpcUrl() public view returns (string memory) {
        return _rpcOf[vm.activeChain()];
    }

    function readBool(uint256 chain_id, string memory key) public view returns (bool) {
        return _boolsOf[chain_id][key];
    }

    function readBool(string memory key) public view returns (bool) {
        return _boolsOf[vm.activeChain()][key];
    }

    function readUint(uint256 chain_id, string memory key) public view returns (uint256) {
        return _uintsOf[chain_id][key];
    }

    function readUint(string memory key) public view returns (uint256) {
        return _uintsOf[vm.activeChain()][key];
    }

    function readAddress(uint256 chain_id, string memory key) public view returns (address) {
        return _addressesOf[chain_id][key];
    }

    function readAddress(string memory key) public view returns (address) {
        return _addressesOf[vm.activeChain()][key];
    }

    function readBytes32(uint256 chain_id, string memory key) public view returns (bytes32) {
        return _bytes32sOf[chain_id][key];
    }

    function readBytes32(string memory key) public view returns (bytes32) {
        return _bytes32sOf[vm.activeChain()][key];
    }

    function readString(uint256 chain_id, string memory key) public view returns (string memory) {
        return _stringsOf[chain_id][key];
    }

    function readString(string memory key) public view returns (string memory) {
        return _stringsOf[vm.activeChain()][key];
    }

    function readBytes(uint256 chain_id, string memory key) public view returns (bytes memory) {
        return _bytesOf[chain_id][key];
    }

    function readBytes(string memory key) public view returns (bytes memory) {
        return _bytesOf[vm.activeChain()][key];
    }

    function readBoolArray(uint256 chain_id, string memory key) public view returns (bool[] memory) {
        return _boolArraysOf[chain_id][key];
    }

    function readBoolArray(string memory key) public view returns (bool[] memory) {
        return _boolArraysOf[vm.activeChain()][key];
    }

    function readUintArray(uint256 chain_id, string memory key) public view returns (uint256[] memory) {
        return _uintArraysOf[chain_id][key];
    }

    function readUintArray(string memory key) public view returns (uint256[] memory) {
        return _uintArraysOf[vm.activeChain()][key];
    }

    function readAddressArray(uint256 chain_id, string memory key) public view returns (address[] memory) {
        return _addressArraysOf[chain_id][key];
    }

    function readAddressArray(string memory key) public view returns (address[] memory) {
        return _addressArraysOf[vm.activeChain()][key];
    }

    function readBytes32Array(uint256 chain_id, string memory key) public view returns (bytes32[] memory) {
        return _bytes32ArraysOf[chain_id][key];
    }

    function readBytes32Array(string memory key) public view returns (bytes32[] memory) {
        return _bytes32ArraysOf[vm.activeChain()][key];
    }

    function readStringArray(uint256 chain_id, string memory key) public view returns (string[] memory) {
        return _stringArraysOf[chain_id][key];
    }

    function readStringArray(string memory key) public view returns (string[] memory) {
        return _stringArraysOf[vm.activeChain()][key];
    }

    function readBytesArray(uint256 chain_id, string memory key) public view returns (bytes[] memory) {
        return _bytesArraysOf[chain_id][key];
    }

    function readBytesArray(string memory key) public view returns (bytes[] memory) {
        return _bytesArraysOf[vm.activeChain()][key];
    }

    // -- SETTER FUNCTIONS -----------------------------------------------------

    function update(uint256 chainId, string memory key, bool value, bool write) public {
        _boolsOf[chainId][key] = value;
        if (write) _writeToToml(chainId, "bool", key, vm.toString(value));
    }

    function update(string memory key, bool value, bool write) public {
        uint256 chainId = vm.activeChain();
        _boolsOf[chainId][key] = value;
        if (write) _writeToToml(chainId, "bool", key, vm.toString(value));
    }

    function update(uint256 chainId, string memory key, uint256 value, bool write) public {
        _uintsOf[chainId][key] = value;
        if (write) _writeToToml(chainId, "uint", key, vm.toString(value));
    }

    function update(string memory key, uint256 value, bool write) public {
        uint256 chainId = vm.activeChain();
        _uintsOf[chainId][key] = value;
        if (write) _writeToToml(chainId, "uint", key, vm.toString(value));
    }

    function update(uint256 chainId, string memory key, address value, bool write) public {
        _addressesOf[chainId][key] = value;
        if (write) _writeToToml(chainId, "address", key, _quote(vm.toString(value)));
    }

    function update(string memory key, address value, bool write) public {
        uint256 chainId = vm.activeChain();
        _addressesOf[chainId][key] = value;
        if (write) _writeToToml(chainId, "address", key, _quote(vm.toString(value)));
    }

    function update(uint256 chainId, string memory key, bytes32 value, bool write) public {
        _bytes32sOf[chainId][key] = value;
        if (write) _writeToToml(chainId, "bytes32", key, _quote(vm.toString(value)));
    }

    function update(string memory key, bytes32 value, bool write) public {
        uint256 chainId = vm.activeChain();
        _bytes32sOf[chainId][key] = value;
        if (write) _writeToToml(chainId, "bytes32", key, _quote(vm.toString(value)));
    }

    function update(uint256 chainId, string memory key, string memory value, bool write) public {
        _stringsOf[chainId][key] = value;
        if (write) _writeToToml(chainId, "string", key, _quote(value));
    }

    function update(string memory key, string memory value, bool write) public {
        uint256 chainId = vm.activeChain();
        _stringsOf[chainId][key] = value;
        if (write) _writeToToml(chainId, "string", key, _quote(value));
    }

    function update(uint256 chainId, string memory key, bytes memory value, bool write) public {
        _bytesOf[chainId][key] = value;
        if (write) _writeToToml(chainId, "bytes", key, _quote(vm.toString(value)));
    }

    function update(string memory key, bytes memory value, bool write) public {
        uint256 chainId = vm.activeChain();
        _bytesOf[chainId][key] = value;
        if (write) _writeToToml(chainId, "bytes", key, _quote(vm.toString(value)));
    }

    function update(uint256 chainId, string memory key, bool[] memory value, bool write) public {
        _boolArraysOf[chainId][key] = value;
        if (write) {
            string memory json = "[";
            for (uint i = 0; i < value.length; i++) {
                json = string.concat(json, vm.toString(value[i]));
                if (i < value.length - 1) json = string.concat(json, ",");
            }
            json = string.concat(json, "]");
            _writeToToml(chainId, "bool", key, json);
        }
    }

    function update(string memory key, bool[] memory value, bool write) public {
        uint256 chainId = vm.activeChain();
        update(chainId, key, value, write);
    }

    function update(uint256 chainId, string memory key, uint256[] memory value, bool write) public {
        _uintArraysOf[chainId][key] = value;
        if (write) {
            string memory json = "[";
            for (uint i = 0; i < value.length; i++) {
                json = string.concat(json, vm.toString(value[i]));
                if (i < value.length - 1) json = string.concat(json, ",");
            }
            json = string.concat(json, "]");
            _writeToToml(chainId, "uint", key, json);
        }
    }

    function update(string memory key, uint256[] memory value, bool write) public {
        uint256 chainId = vm.activeChain();
        update(chainId, key, value, write);
    }

    function update(uint256 chainId, string memory key, address[] memory value, bool write) public {
        _addressArraysOf[chainId][key] = value;
        if (write) {
            string memory json = "[";
            for (uint i = 0; i < value.length; i++) {
                json = string.concat(json, _quote(vm.toString(value[i])));
                if (i < value.length - 1) json = string.concat(json, ",");
            }
            json = string.concat(json, "]");
            _writeToToml(chainId, "address", key, json);
        }
    }

    function update(string memory key, address[] memory value, bool write) public {
        uint256 chainId = vm.activeChain();
        update(chainId, key, value, write);
    }

    function update(uint256 chainId, string memory key, bytes32[] memory value, bool write) public {
        _bytes32ArraysOf[chainId][key] = value;
        if (write) {
            string memory json = "[";
            for (uint i = 0; i < value.length; i++) {
                json = string.concat(json, _quote(vm.toString(value[i])));
                if (i < value.length - 1) json = string.concat(json, ",");
            }
            json = string.concat(json, "]");
            _writeToToml(chainId, "bytes32", key, json);
        }
    }

    function update(string memory key, bytes32[] memory value, bool write) public {
        uint256 chainId = vm.activeChain();
        update(chainId, key, value, write);
    }

    function update(uint256 chainId, string memory key, string[] memory value, bool write) public {
        _stringArraysOf[chainId][key] = value;
        if (write) {
            string memory json = "[";
            for (uint i = 0; i < value.length; i++) {
                json = string.concat(json, _quote(value[i]));
                if (i < value.length - 1) json = string.concat(json, ",");
            }
            json = string.concat(json, "]");
            _writeToToml(chainId, "string", key, json);
        }
    }

    function update(string memory key, string[] memory value, bool write) public {
        uint256 chainId = vm.activeChain();
        update(chainId, key, value, write);
    }

    function update(uint256 chainId, string memory key, bytes[] memory value, bool write) public {
        _bytesArraysOf[chainId][key] = value;
        if (write) {
            string memory json = "[";
            for (uint i = 0; i < value.length; i++) {
                json = string.concat(json, _quote(vm.toString(value[i])));
                if (i < value.length - 1) json = string.concat(json, ",");
            }
            json = string.concat(json, "]");
            _writeToToml(chainId, "bytes", key, json);
        }
    }

    function update(string memory key, bytes[] memory value, bool write) public {
        uint256 chainId = vm.activeChain();
        update(chainId, key, value, write);
    }
}
