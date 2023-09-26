// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

/// Cheatcodes are marked as view/pure/none using the following rules:
///
///   1. A call's observable behavior includes its return value, logs, reverts and state writes,
///   2. If it can influence a later call's observable behavior, it's neither view nor pure (it is modifying some
///   state be it the EVM, interpreter, filesystem, etc),
///   3. Otherwise, if it can be influenced by an earlier call, or if reading some state, it's view,
///   4. Otherwise, it's pure.

/// @notice An EVM interpreter written with testing and debugging in mind. This is usually either HEVM or REVM.
/// @dev This interface can be safely used in scripts running on a live network, so for example you don't accidentally
/// change the block timestamp and use a fake timestamp as a value somewhere.
interface VmSafe {
    enum CallerMode {
        None,
        Broadcast,
        RecurrentBroadcast,
        Prank,
        RecurrentPrank
    }

    struct DirEntry {
        string errorMessage;
        string path;
        uint64 depth;
        bool isDir;
        bool isSymlink;
    }

    struct FfiResult {
        // solhint-disable-next-line var-name-mixedcase
        int32 exit_code;
        bytes stdout;
        bytes stderr;
    }

    struct FsMetadata {
        bool isDir;
        bool isSymlink;
        uint256 length;
        bool readOnly;
        uint256 modified;
        uint256 accessed;
        uint256 created;
    }

    struct Log {
        bytes32[] topics;
        bytes data;
        address emitter;
    }

    struct Rpc {
        string key;
        string url;
    }

    struct Wallet {
        address addr;
        uint256 publicKeyX;
        uint256 publicKeyY;
        uint256 privateKey;
    }

    /// @dev Gets all accessed reads and write slot from a recording session, for a given address.
    function accesses(address target) external returns (bytes32[] memory readSlots, bytes32[] memory writeSlots);

    /// @dev Gets the address for a given private key.
    function addr(uint256 privateKey) external pure returns (address keyAddr);

    /// @dev If the condition is false, discard this run's fuzz inputs and generate new ones.
    function assume(bool condition) external pure;

    /// @dev Writes a breakpoint to jump to in the debugger.
    function breakpoint(string calldata char) external;

    /// @dev Writes a conditional breakpoint to jump to in the debugger.
    function breakpoint(string calldata char, bool value) external;

    /// @dev Using the address that calls the test contract, has the next call (at this call depth only) create a
    /// transaction that can later be signed and sent onchain.
    function broadcast() external;

    /// @dev Has the next call (at this call depth only) create a transaction with the address provided as
    /// the sender that can later be signed and sent onchain.
    function broadcast(address signer) external;

    /// @dev Has the next call (at this call depth only) create a transaction with the private key provided as
    /// the sender that can later be signed and sent onchain
    function broadcast(uint256 privateKey) external;

    /// @dev Closes file for reading, resetting the offset and allowing to read it from beginning with readLine.
    function closeFile(string calldata path) external;

    /// @dev Copies the contents of one file to another. This function will **overwrite** the contents of `to`.
    /// On success, the total number of bytes copied is returned and it is equal to the length of the `to` file as
    /// reported by `metadata`.
    /// Both `from` and `to` are relative to the project root.
    function copyFile(string calldata from, string calldata to) external returns (uint64 copied);

    /// @dev Creates a new, empty directory at the provided path, which is relative to the project root.
    /// This cheatcode will revert in the following situations, but is not limited to just these cases:
    ///   - User lacks permissions to modify `path`.
    ///   - A parent of the given path doesn't exist and `recursive` is false.
    ///   - `path` already exists and `recursive` is false.
    function createDir(string calldata path, bool recursive) external;

    /// @dev Derives a private key from the name, labels the account with that name, and returns the wallet.

    function createWallet(string calldata walletLabel) external returns (Wallet memory wallet);
    /// @dev Generates a wallet from the private key and returns the wallet.

    function createWallet(uint256 privateKey) external returns (Wallet memory wallet);

    /// @dev Generates a wallet from the private key, labels the account with that name, and returns the wallet.
    function createWallet(uint256 privateKey, string calldata walletLabel) external returns (Wallet memory wallet);

    /// @dev Derive a private key from a provided mnenomic string (or mnenomic file path) at the derivation
    /// path m/44'/60'/0'/0/{index}
    function deriveKey(string calldata mnemonic, uint32 index) external pure returns (uint256 privateKey);

    /// @dev Derive a private key from a provided mnenomic string (or mnenomic file path) at {derivationPath}{index}
    function deriveKey(string calldata mnemonic, string calldata derivationPath, uint32 index)
        external
        pure
        returns (uint256 privateKey);

    /// @dev Reads environment variables, (name) => (value)
    function envAddress(string calldata name) external view returns (address value);

    function envBool(string calldata name) external view returns (bool value);

    function envBytes(string calldata name) external view returns (bytes memory value);

    function envBytes32(string calldata name) external view returns (bytes32 value);

    function envInt(string calldata name) external view returns (int256 value);

    function envString(string calldata name) external view returns (string memory value);

    function envUint(string calldata name) external view returns (uint256 value);

    /// @dev Reads environment variables as arrays.
    function envAddress(string calldata name, string calldata delim) external view returns (address[] memory values);

    function envBool(string calldata name, string calldata delim) external view returns (bool[] memory values);

    function envBytes(string calldata name, string calldata delim) external view returns (bytes[] memory values);

    function envBytes32(string calldata name, string calldata delim) external view returns (bytes32[] memory values);

    function envInt(string calldata name, string calldata delim) external view returns (int256[] memory values);

    function envString(string calldata name, string calldata delim) external view returns (string[] memory values);

    function envUint(string calldata name, string calldata delim) external view returns (uint256[] memory values);

    /// @dev Reads environment variables with a default value.
    function envOr(string calldata name, bool defaultValue) external returns (bool value);

    function envOr(string calldata name, uint256 defaultValue) external returns (uint256 value);

    function envOr(string calldata name, int256 defaultValue) external returns (int256 value);

    function envOr(string calldata name, address defaultValue) external returns (address value);

    function envOr(string calldata name, bytes32 defaultValue) external returns (bytes32 value);

    function envOr(string calldata name, string calldata defaultValue) external returns (string memory value);

    function envOr(string calldata name, bytes calldata defaultValue) external returns (bytes memory value);

    /// @dev Reads environment variables as arrays with default value.
    function envOr(string calldata name, string calldata, bool[] calldata defaultValue)
        external
        returns (bool[] memory value);

    function envOr(string calldata name, string calldata, uint256[] calldata defaultValue)
        external
        returns (uint256[] memory value);

    function envOr(string calldata name, string calldata, int256[] calldata defaultValue)
        external
        returns (int256[] memory value);

    function envOr(string calldata name, string calldata, address[] calldata defaultValue)
        external
        returns (address[] memory value);

    function envOr(string calldata name, string calldata, bytes32[] calldata defaultValue)
        external
        returns (bytes32[] memory value);

    function envOr(string calldata name, string calldata, string[] calldata defaultValue)
        external
        returns (string[] memory value);

    function envOr(string calldata name, string calldata, bytes[] calldata defaultValue)
        external
        returns (bytes[] memory value);

    /// @dev Returns true if the given path points to an existing entity, else returns false.
    function exists(string calldata path) external returns (bool result);

    /// @dev Performs a foreign function call via the terminal.
    function ffi(string[] calldata commandInput) external returns (bytes memory result);

    /// @dev Given a path, query the file system to get information about a file, directory, etc.
    function fsMetadata(string calldata fileOrDir) external returns (FsMetadata memory metadata);

    /// @dev Gets the code from an artifact file. Takes in the relative path to the json file.
    function getCode(string calldata artifactPath) external view returns (bytes memory creationBytecode);

    /// @dev Gets the _deployed_ bytecode from an artifact file. Takes in the relative path to the json file.
    function getDeployedCode(string calldata artifactPath) external view returns (bytes memory runtimeBytecode);

    /// @dev Gets the label for the specified address.
    function getLabel(address account) external returns (string memory label);

    /// @dev Gets the map key and parent of a mapping at a given slot, for a given address.
    function getMappingKeyAndParentOf(address target, bytes32 elementSlot)
        external
        returns (bool found, bytes32 key, bytes32 parent);

    /// @dev Gets the number of elements in the mapping at the given slot, for a given address.
    function getMappingLength(address target, bytes32 mappingSlot) external returns (uint256 length);

    /// @dev Gets the elements at index idx of the mapping at the given slot, for a given address. The
    /// index must be less than the length of the mapping (i.e. the number of keys in the mapping).
    function getMappingSlotAt(address target, bytes32 mappingSlot, uint256 idx) external returns (bytes32 value);

    /// @dev Gets the nonce of an account.
    function getNonce(address account) external view returns (uint64 nonce);

    /// @dev Get nonce for a Wallet.
    function getNonce(Wallet calldata wallet) external returns (uint64 nonce);

    /// @dev Gets all the recorded logs.
    function getRecordedLogs() external returns (Log[] memory logs);

    /// @dev Returns true if the path exists on disk and is pointing at a directory, else returns false.
    function isDir(string calldata path) external returns (bool result);

    /// @dev Returns true if the path exists on disk and is pointing at a regular file, else returns false.
    function isFile(string calldata path) external returns (bool result);

    /// @dev Checks if a key exists in a JSON or TOML object.
    function keyExists(string calldata json, string calldata key) external view returns (bool);

    /// @dev Labels an address in call traces.
    function label(address account, string calldata newLabel) external;

    /// @dev Loads a storage slot from an address.
    function load(address target, bytes32 slot) external view returns (bytes32 data);

    /// @dev Convert values from a string
    function parseBytes(string calldata stringifiedValue) external pure returns (bytes memory parsedValue);

    function parseAddress(string calldata stringifiedValue) external pure returns (address parsedValue);

    function parseBool(string calldata stringifiedValue) external pure returns (bool parsedValue);

    function parseBytes32(string calldata stringifiedValue) external pure returns (bytes32 parsedValue);

    function parseInt(string calldata stringifiedValue) external pure returns (int256 parsedValue);

    /// @dev In case the returned value is a JSON object, it's encoded as a ABI-encoded tuple. As JSON objects
    /// don't have the notion of ordered, but tuples do, they JSON object is encoded with it's fields ordered in
    /// ALPHABETICAL order. That means that in order to successfully decode the tuple, we need to define a tuple that
    /// encodes the fields in the same order, which is alphabetical. In the case of Solidity structs, they are encoded
    /// as tuples, with the attributes in the order in which they are defined.
    /// For example: json = { 'a': 1, 'b': 0xa4tb......3xs}
    /// a: uint256
    /// b: address
    /// To decode that json, we need to define a struct or a tuple as follows:
    /// struct json = { uint256 a; address b; }
    /// If we defined a json struct with the opposite order, meaning placing the address b first, it would try to
    /// decode the tuple in that order, and thus fail.
    /// ----
    /// Given a string of JSON, return it as ABI-encoded
    function parseJson(string calldata json) external pure returns (bytes memory abiEncodedData);

    function parseJson(string calldata json, string calldata key) external pure returns (bytes memory abiEncodedData);

    /// @dev The following parseJson cheatcodes will do type coercion, for the type that they indicate.
    /// For example, parseJsonUint will coerce all values to a uint256. That includes stringified numbers "12"
    /// and hex numbers "0xEF".
    /// Type coercion works ONLY for discrete values or arrays. That means that the key must return a value or array,
    /// not a JSON object.
    function parseJsonAddress(string calldata json, string calldata key) external pure returns (address);

    function parseJsonAddressArray(string calldata json, string calldata key)
        external
        pure
        returns (address[] memory);

    function parseJsonBool(string calldata json, string calldata key) external pure returns (bool);

    function parseJsonBoolArray(string calldata json, string calldata key) external pure returns (bool[] memory);

    function parseJsonBytes(string calldata json, string calldata key) external pure returns (bytes memory);

    function parseJsonBytesArray(string calldata json, string calldata key) external pure returns (bytes[] memory);

    function parseJsonBytes32(string calldata json, string calldata key) external pure returns (bytes32);

    function parseJsonBytes32Array(string calldata json, string calldata key)
        external
        pure
        returns (bytes32[] memory);

    /// @dev Returns array of keys for a JSON object
    function parseJsonKeys(string calldata json, string calldata key) external pure returns (string[] memory keys);

    function parseJsonInt(string calldata json, string calldata key) external pure returns (int256);

    function parseJsonIntArray(string calldata json, string calldata key) external pure returns (int256[] memory);

    function parseJsonString(string calldata json, string calldata key) external pure returns (string memory);

    function parseJsonStringArray(string calldata json, string calldata key) external pure returns (string[] memory);

    function parseJsonUint(string calldata json, string calldata key) external pure returns (uint256);

    function parseJsonUintArray(string calldata json, string calldata key) external pure returns (uint256[] memory);

    function parseUint(string calldata value) external pure returns (uint256 parsedValue);

    /// @dev Pauses gas metering (i.e. gas usage is not counted). No-op if already paused.
    function pauseGasMetering() external;

    /// @dev Get the path of the current project root
    function projectRoot() external view returns (string memory path);

    /// @dev Removes a directory at the provided path, which is relative to the project root.
    /// This cheatcode will revert in the following situations, but is not limited to just these cases:
    ///   - `path` doesn't exist.
    ///   - `path` isn't a directory.
    ///   - User lacks permissions to modify `path`.
    ///   - The directory is not empty and `recursive` is false.
    function removeDir(string calldata path, bool recursive) external;

    ///  @dev Reads the directory at the given path recursively, up to `max_depth`.
    /// `max_depth` defaults to 1, meaning only the direct children of the given directory will be returned.
    /// Follows symbolic links if `follow_links` is true.
    function readDir(string calldata path) external view returns (DirEntry[] memory entries);
    function readDir(string calldata path, uint64 maxDepth) external view returns (DirEntry[] memory entries);
    function readDir(string calldata path, uint64 maxDepth, bool followLinks)
        external
        view
        returns (DirEntry[] memory entries);

    /// @dev Reads the entire content of file to string. `path` is relative to the project root.
    function readFile(string calldata path) external view returns (string memory data);

    /// @dev Reads the entire content of file as binary. `path` is relative to the project root.
    function readFileBinary(string calldata path) external view returns (bytes memory data);

    /// @dev Reads a symbolic link, returning the path that the link points to.
    /// This cheatcode will revert in the following situations, but is not limited to just these cases:
    ///   - `path` is not a symbolic link.
    ///   - `path` does not exist.
    function readLink(string calldata linkPath) external view returns (string memory targetPath);

    /// @dev Records all storage reads and writes.
    function record() external;

    /// @dev Record all the transaction logs.
    function recordLogs() external;

    /// @dev Adds a private key to the local Forge wallet and returns the address.
    function rememberKey(uint256 privateKey) external returns (address keyAddr);

    /// @dev Resumes gas metering (i.e. gas usage is counted again). No-op if already on.
    function resumeGasMetering() external;

    //// @dev Returns the RPC url for the given alias.
    function rpcUrl(string calldata rpcAlias) external view returns (string memory json);

    //// @dev Returns all rpc urls and their aliases `[alias, url][]`.
    function rpcUrls() external view returns (string[2][] memory urls);

    /// @dev Returns all rpc urls and their aliases as structs.
    function rpcUrlStructs() external view returns (Rpc[] memory urls);

    function serializeAddress(string calldata objectKey, string calldata valueKey, address value)
        external
        returns (string memory json);

    function serializeAddress(string calldata objectKey, string calldata valueKey, address[] calldata values)
        external
        returns (string memory json);

    /// @dev Serializes a key and value to a JSON object stored in-memory that can be later written to a file.
    /// It returns the stringified version of the specific JSON file up to that moment.
    function serializeBool(string calldata objectKey, string calldata valueKey, bool value)
        external
        returns (string memory json);

    function serializeBool(string calldata objectKey, string calldata valueKey, bool[] calldata values)
        external
        returns (string memory json);

    function serializeBytes(string calldata objectKey, string calldata valueKey, bytes calldata value)
        external
        returns (string memory json);

    function serializeBytes(string calldata objectKey, string calldata valueKey, bytes[] calldata values)
        external
        returns (string memory json);

    function serializeBytes32(string calldata objectKey, string calldata valueKey, bytes32 value)
        external
        returns (string memory json);

    function serializeBytes32(string calldata objectKey, string calldata valueKey, bytes32[] calldata values)
        external
        returns (string memory json);

    /// @dev Serialize a key and value to a JSON object stored in-memory that can be later written to a file
    /// It returns the stringified version of the specific JSON file up to that moment.
    function serializeJson(string calldata objectKey, string calldata value) external returns (string memory json);

    function serializeInt(string calldata objectKey, string calldata valueKey, int256 value)
        external
        returns (string memory json);

    function serializeInt(string calldata objectKey, string calldata valueKey, int256[] calldata values)
        external
        returns (string memory json);

    function serializeString(string calldata objectKey, string calldata valueKey, string calldata value)
        external
        returns (string memory json);

    function serializeString(string calldata objectKey, string calldata valueKey, string[] calldata values)
        external
        returns (string memory json);

    function serializeUint(string calldata objectKey, string calldata valueKey, uint256 value)
        external
        returns (string memory json);

    function serializeUint(string calldata objectKey, string calldata valueKey, uint256[] calldata values)
        external
        returns (string memory json);

    /// @dev Sets environment variables.
    function setEnv(string calldata name, string calldata value) external;

    /// @dev Signs data.
    function sign(uint256 privateKey, bytes32 digest) external pure returns (uint8 v, bytes32 r, bytes32 s);

    /// @dev Signs data, (Wallet, digest) => (v, r, s)
    function sign(Wallet calldata wallet, bytes32 digest) external returns (uint8 v, bytes32 r, bytes32 s);

    /// @dev Suspends execution of the main thread for `duration` milliseconds.
    function sleep(uint256 duration) external;

    /// @dev Using the address that calls the test contract, has all subsequent calls (at this call depth only)
    /// create transactions that can later be signed and sent onchain.
    function startBroadcast() external;

    /// @dev Has all subsequent calls (at this call depth only) create transactions that can later be signed and
    /// sent onchain.
    function startBroadcast(address broadcaster) external;

    /// @dev Has all subsequent calls (at this call depth only) create transactions with the private key provided that
    /// can later be signed and sent onchain
    function startBroadcast(uint256 privateKey) external;

    /// @dev Stops collecting onchain transactions.
    function stopBroadcast() external;

    /// @dev Starts recording all map SSTOREs for later retrieval.
    function startMappingRecording() external;

    /// @dev Stops recording all map SSTOREs for later retrieval and clears the recorded data.
    function stopMappingRecording() external;

    /// Convert values to a string.
    function toString(address value) external pure returns (string memory stringifiedValue);

    function toString(bool value) external pure returns (string memory stringifiedValue);

    function toString(bytes calldata value) external pure returns (string memory stringifiedValue);

    function toString(bytes32 value) external pure returns (string memory stringifiedValue);

    function toString(int256 value) external pure returns (string memory stringifiedValue);

    function toString(uint256 value) external pure returns (string memory stringifiedValue);

    /// @dev Performs a foreign function call via terminal and returns the exit code, stdout, and stderr
    function tryFfi(string[] calldata commandInput) external returns (FfiResult memory result);

    /// @dev Writes data to file, creating a file if it does not exist, and entirely replacing its contents if it does.
    /// `path` is relative to the project root
    function writeFile(string calldata path, string calldata data) external;

    /// @dev Writes binary data to a file, creating a file if it does not exist, and entirely replacing its contents if
    /// it does. `path` is relative to the project root.
    function writeFileBinary(string calldata path, bytes calldata data) external;

    /// @dev Writes line to file, creating a file if it does not exist. `path` is relative to the project root.
    function writeLine(string calldata path, string calldata data) external;

    /// @dev Write a serialized JSON object to a file. If the file exists, it will be overwritten.
    function writeJson(string calldata json, string calldata path) external;

    /// @dev Write a serialized JSON object to an **existing** JSON file, replacing a value with key = <value_key>
    /// This is useful to replace a specific value of a JSON file, without having to parse the entire thing
    function writeJson(string calldata json, string calldata path, string calldata valueKey) external;
}

/// @notice An EVM interpreter written with testing and debugging in mind. This is usually either HEVM or REVM.
/// @dev This interface contains cheatcodes that are potentially unsafe on a live network.
interface Vm is VmSafe {
    //// @dev Returns the identifier of the currently active fork. Reverts if no fork is currently active.
    function activeFork() external view returns (uint256 forkId);

    /// @dev In forking mode, explicitly grant the given address cheatcode access
    function allowCheatcodes(address account) external;

    /// @dev Sets block.chainid.
    function chainId(uint256 newChainId) external;

    /// @dev Clears all mocked calls.
    function clearMockedCalls() external;

    /// @dev Sets block.coinbase
    function coinbase(address newCoinbase) external;

    /// @dev Creates a new fork with the given endpoint and block number and returns the identifier of the fork.
    function createFork(string calldata urlOrAlias, uint256 blockNumber) external returns (uint256);

    /// @dev Creates a new fork with the given endpoint and the _latest_ block and returns the identifier of the fork.
    function createFork(string calldata urlOrAlias) external returns (uint256);

    /// @dev Creates _and_ also selects a new fork with the given endpoint and the latest block and returns the
    /// identifier of the fork.
    function createSelectFork(string calldata urlOrAlias) external returns (uint256);

    /// @dev Creates _and_ also selects a new fork with the given endpoint and block number and returns the identifier
    /// of the fork.
    function createSelectFork(string calldata urlOrAlias, uint256 blockNumber) external returns (uint256);

    /// @dev Creates _and_ also selects new fork with the given endpoint and at the block the given transaction was
    /// mined in, replays all transaction mined in the block before the transaction, returns the identifier of the fork
    function createSelectFork(string calldata urlOrAlias, bytes32 txHash) external returns (uint256 forkId);

    /// @dev Sets an account's balance.
    function deal(address account, uint256 newBalance) external;

    /// @dev Sets block.difficulty
    /// Not available on EVM versions from Paris onwards. Use `prevrandao` instead.
    /// If used on unsupported EVM versions, it will revert.
    function difficulty(uint256 newDifficulty) external;

    /// @dev Sets an address' code.
    function etch(address target, bytes calldata newRuntimeBytecode) external;

    /// @dev Expects a call to an address with the specified calldata.
    /// Calldata can be either a strict or a partial match.
    function expectCall(address callee, bytes calldata data) external;

    /// @dev Expects given number of calls to an address with the specified calldata.
    function expectCall(address callee, bytes calldata data, uint64 count) external;

    /// @dev Expects a call to an address with the specified msg.value and calldata.
    function expectCall(address callee, uint256 msgValue, bytes calldata data) external;

    /// @dev Expects given number of calls to an address with the specified msg.value and calldata
    function expectCall(address callee, uint256 msgValue, bytes calldata data, uint64 count) external;

    /// @dev Expects a call to an address with the specified msg.value, gas, and calldata.
    function expectCall(address callee, uint256 msgValue, uint64 gas, bytes calldata data) external;

    /// @dev Expects given number of calls to an address with the specified msg.value, gas, and calldata.
    function expectCall(address callee, uint256 msgValue, uint64 gas, bytes calldata data, uint64 count) external;

    /// @dev Expects a call to an address with the specified msg.value and calldata, and a *minimum* amount of gas.
    function expectCallMinGas(address callee, uint256 msgValue, uint64 minGas, bytes calldata data) external;

    /// @dev Expect given number of calls to an address with the specified msg.value and calldata, and a *minimum*
    /// amount of gas.
    function expectCallMinGas(address callee, uint256 msgValue, uint64 minGas, bytes calldata data, uint64 count)
        external;

    /// @dev Prepare an expected log with all four checks enabled.
    /// Call this function, then emit an event, then call a function. Internally after the call, we check if
    /// logs were emitted in the expected order with the expected topics and data.
    /// Second form also checks supplied address against emitting contract.
    function expectEmit() external;
    function expectEmit(address emitter) external;

    /// @dev Prepare an expected log.
    /// Call this function, then emit an event, then call a function. Internally after the call, we check if
    /// logs were emitted in the expected order with the expected topics and data (as specified by the booleans).
    /// Second form also checks supplied address against emitting contract.
    function expectEmit(bool checkTopic1, bool checkTopic2, bool checkTopic3, bool checkData) external;
    function expectEmit(bool checkTopic1, bool checkTopic2, bool checkTopic3, bool checkData, address emitter)
        external;

    /// @dev Expects an error on next call.
    function expectRevert(bytes calldata revertData) external;

    function expectRevert(bytes4 revertData) external;

    function expectRevert() external;

    /// @dev Only allows memory writes to offsets [0x00, 0x60) ∪ [min, max) in the current subcontext. If any other
    /// memory is written to, the test will fail. Can be called multiple times to add more ranges to the set.
    function expectSafeMemory(uint64 min, uint64 max) external;
    /// @dev Only allows memory writes to offsets [0x00, 0x60) ∪ [min, max) in the next created subcontext.
    /// If any other memory is written to, the test will fail. Can be called multiple times to add more ranges
    /// to the set.
    function expectSafeMemoryCall(uint64 min, uint64 max) external;

    /// @dev Sets block.basefee.
    function fee(uint256 newBasefee) external;

    /// @dev Returns true if the account is marked as persistent.
    function isPersistent(address account) external view returns (bool persistent);

    /// @dev Marks that the account(s) should use persistent storage across fork swaps in a multifork setup.
    // Meaning, changes made to the state of this account will be kept when switching forks
    function makePersistent(address account) external;

    function makePersistent(address account0, address account1) external;

    function makePersistent(address account0, address account1, address account2) external;

    function makePersistent(address[] calldata accounts) external;

    /// @dev Mocks a call to an address, returning specified data.
    /// Calldata can either be strict or a partial match, e.g. if you only pass a Solidity selector to the expected
    /// calldata, then the entire Solidity function will be mocked.
    function mockCall(address callee, bytes calldata data, bytes calldata returnData) external;

    /// @dev Mocks a call to an address with a specific msg.value, returning specified data.
    /// Calldata match takes precedence over msg.value in case of ambiguity.
    function mockCall(address callee, uint256 msgValue, bytes calldata data, bytes calldata returnData) external;

    /// @dev Reverts a call to an address with specified revert data.
    function mockCallRevert(address callee, bytes calldata data, bytes calldata revertData) external;

    /// @dev Reverts a call to an address with a specific msg.value, with specified revert data.
    function mockCallRevert(address callee, uint256 msgValue, bytes calldata data, bytes calldata revertData)
        external;

    /// @dev Sets the *next* call's msg.sender to be the input address.
    function prank(address msgSender) external;

    /// @dev Sets the *next* call's msg.sender to be the input address, and the tx.origin to be the second input.
    function prank(address msgSender, address txOrigin) external;

    /// @dev Sets block.prevrandao
    /// Not available on EVM versions before Paris. Use `difficulty` instead.
    /// If used on unsupported EVM versions, it will revert.
    function prevrandao(bytes32 newPrevrandao) external;

    /// @dev Reads the current `msg.sender` and `tx.origin` from state and reports if there is any active caller
    /// modification.
    function readCallers() external returns (CallerMode callerMode, address msgSender, address txOrigin);

    /// @dev Removes a file from the filesystem.
    /// This cheatcode will revert in the following situations, but is not limited to just these cases:
    ///   - `path` points to a directory.
    ///   - The file doesn't exist.
    ///   - The user lacks permissions to remove the file.
    /// `path` is relative to the project root.
    function removeFile(string calldata path) external;

    /// @dev Resets the nonce of an account to 0 for EOAs and 1 for contract accounts.
    function resetNonce(address account) external;

    /// @dev Revert the state of the evm to a previous snapshot.
    /// Takes the snapshot id to revert to.
    /// This deletes the snapshot and all snapshots taken after the given snapshot id.
    function revertTo(uint256 snapshotId) external returns (bool result);

    /// @dev Revokes persistent status from the address, previously added via `makePersistent`
    function revokePersistent(address account) external;

    function revokePersistent(address[] calldata accounts) external;

    /// @dev Sets block.height.
    function roll(uint256 newHeight) external;

    /// @dev Updates the currently active fork to given block number. This is similar to `roll` but for the
    /// currently active fork.
    function rollFork(uint256 forkId) external;

    /// @dev Updates the given fork to given block number.
    function rollFork(uint256 forkId, uint256 blockNumber) external;

    /// @dev Updates the currently active fork to given transaction
    /// this will `rollFork` with the number of the block the transaction was mined in and replays all transaction
    /// mined before it in the block
    function rollFork(bytes32 txHash) external;

    /// @dev Updates the given fork to block number of the given transaction and replays all transaction mined before
    /// it in the block
    function rollFork(uint256 forkId, bytes32 txHash) external;

    /// @dev Takes a fork identifier created by `createFork` and sets the corresponding forked state as active.
    function selectFork(uint256 forkId) external;

    /// @dev Sets the nonce of an account; must be higher than the current nonce of the account.
    function setNonce(address account, uint64 newNonce) external;

    /// @dev Sets the nonce of an account to an arbitrary value.
    function setNonceUnsafe(address account, uint64 newNonce) external;

    /// @dev Marks a test as skipped. Must be called at the top of the test.
    function skip(bool skipTest) external;

    /// @dev Snapshot the current state of the EVM.
    /// Returns the id of the snapshot that was created.
    /// To revert a snapshot use `revertTo`.
    function snapshot() external returns (uint256 snapshotId);

    /// @dev Sets all subsequent calls' msg.sender to be the input address until `stopPrank` is called.
    function startPrank(address msgSender) external;

    /// @dev Sets all subsequent calls' msg.sender to be the input address until `stopPrank` is called, and
    /// the tx.origin to be the second input.
    function startPrank(address msgSender, address txOrigin) external;

    /// @dev Resets subsequent calls' msg.sender to be `address(this)`.
    function stopPrank() external;

    /// @dev Stores a value to an address' storage slot.
    function store(address target, bytes32 slot, bytes32 value) external;

    /// @dev Fetches the given transaction from the active fork and executes it on the current state
    function transact(bytes32 txHash) external;

    /// @dev Fetches the given transaction from the given fork and executes it on the current state
    function transact(uint256 forkId, bytes32 txHash) external;

    /// @dev Sets tx.gasprice.
    function txGasPrice(uint256 newGasPrice) external;

    /// @dev Sets block.timestamp.
    function warp(uint256 timestamp) external;
}
