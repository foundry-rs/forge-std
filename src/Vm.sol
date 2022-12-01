// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

pragma experimental ABIEncoderV2;

// Cheatcodes are marked as view/pure/none using the following rules:
// 0. A call's observable behaviour includes its return value, logs, reverts and state writes,
// 1. If you can influence a later call's observable behaviour, you're neither `view` nor `pure (you are modifying some state be it the EVM, interpreter, filesystem, etc),
// 2. Otherwise if you can be influenced by an earlier call, or if reading some state, you're `view`,
// 3. Otherwise you're `pure`.

interface VmSafe {
    struct Log {
        bytes32[] topics;
        bytes data;
        address emitter;
    }

    struct Rpc {
        string key;
        string url;
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

    // Loads a storage slot from an address (who, slot)
    function load(address who, bytes32 slot) external view returns (bytes32);
    // Signs data, (privateKey, digest) => (v, r, s)
    function sign(uint256 privateKey, bytes32 digest) external pure returns (uint8, bytes32, bytes32);
    // Gets the address for a given private key, (privateKey) => (address)
    function addr(uint256 privateKey) external pure returns (address);
    // Gets the nonce of an account
    function getNonce(address account) external view returns (uint64);
    // Performs a foreign function call via the terminal, (stringInputs) => (result)
    function ffi(string[] calldata stringInputs) external returns (bytes memory);
    // Sets environment variables, (name, value)
    function setEnv(string calldata name, string calldata value) external;
    // Reads environment variables, (name) => (value)
    function envBool(string calldata name) external view returns (bool);
    function envUint(string calldata name) external view returns (uint256);
    function envInt(string calldata name) external view returns (int256);
    function envAddress(string calldata name) external view returns (address);
    function envBytes32(string calldata name) external view returns (bytes32);
    function envString(string calldata name) external view returns (string memory);
    function envBytes(string calldata name) external view returns (bytes memory);
    // Reads environment variables as arrays
    function envBool(string calldata name, string calldata delim) external view returns (bool[] memory);
    function envUint(string calldata name, string calldata delim) external view returns (uint256[] memory);
    function envInt(string calldata name, string calldata delim) external view returns (int256[] memory);
    function envAddress(string calldata name, string calldata delim) external view returns (address[] memory);
    function envBytes32(string calldata name, string calldata delim) external view returns (bytes32[] memory);
    function envString(string calldata name, string calldata delim) external view returns (string[] memory);
    function envBytes(string calldata name, string calldata delim) external view returns (bytes[] memory);
    // Read environment variables with default value
    function envOr(string calldata name, bool defaultValue) external returns (bool value);
    function envOr(string calldata name, uint256 defaultValue) external returns (uint256 value);
    function envOr(string calldata name, int256 defaultValue) external returns (int256 value);
    function envOr(string calldata name, address defaultValue) external returns (address value);
    function envOr(string calldata name, bytes32 defaultValue) external returns (bytes32 value);
    function envOr(string calldata name, string calldata defaultValue) external returns (string memory value);
    function envOr(string calldata name, bytes calldata defaultValue) external returns (bytes memory value);
    // Read environment variables as arrays with default value, (name, value[]) => (value[])
    function envOr(string calldata name, string calldata, bool[] calldata defaultValue) external returns (bool[] memory value);
    function envOr(string calldata name, string calldata, uint256[] calldata defaultValue) external returns (uint256[] memory value);
    function envOr(string calldata name, string calldata, int256[] calldata defaultValue) external returns (int256[] memory value);
    function envOr(string calldata name, string calldata, address[] calldata defaultValue) external returns (address[] memory value);
    function envOr(string calldata name, string calldata, bytes32[] calldata defaultValue) external returns (bytes32[] memory value);
    function envOr(string calldata name, string calldata, string[] calldata defaultValue) external returns (string[] memory value);
    function envOr(string calldata name, string calldata, bytes[] calldata defaultValue) external returns (bytes[] memory value);
    // Records all storage reads and writes
    function record() external;
    // Gets all accessed reads and write slot from a recording session, for a given address
    function accesses(address who) external returns (bytes32[] memory reads, bytes32[] memory writes);
    // Gets the _creation_ bytecode from an artifact file. Takes in the relative path to the json file
    function getCode(string calldata path) external view returns (bytes memory);
    // Gets the _deployed_ bytecode from an artifact file. Takes in the relative path to the json file
    function getDeployedCode(string calldata path) external view returns (bytes memory);
    // Labels an address in call traces
    function label(address, string calldata) external;
    // Using the address that calls the test contract, has the next call (at this call depth only) create a transaction that can later be signed and sent onchain
    function broadcast() external;
    // Has the next call (at this call depth only) create a transaction with the address provided as the sender that can later be signed and sent onchain
    function broadcast(address) external;
    // Has the next call (at this call depth only) create a transaction with the private key provided as the sender that can later be signed and sent onchain
    function broadcast(uint256) external;
    // Using the address that calls the test contract, has all subsequent calls (at this call depth only) create transactions that can later be signed and sent onchain
    function startBroadcast() external;
    // Has all subsequent calls (at this call depth only) create transactions with the address provided that can later be signed and sent onchain
    function startBroadcast(address broadcaster) external;
    // Has all subsequent calls (at this call depth only) create transactions with the private key provided that can later be signed and sent onchain
    function startBroadcast(uint256 privateKey) external;
    // Stops collecting onchain transactions
    function stopBroadcast() external;
    // Reads the entire content of file to string, (path) => (data)
    function readFile(string calldata path) external view returns (string memory);
    // Reads the entire content of file as binary. Path is relative to the project root. (path) => (data)
    function readFileBinary(string calldata path) external view returns (bytes memory);
    // Get the path of the current project root
    function projectRoot() external view returns (string memory);
    // Get the metadata for a file/directory
    function fsMetadata(string calldata fileOrDir) external returns (FsMetadata memory metadata);
    // Reads next line of file to string, (path) => (line)
    function readLine(string calldata path) external view returns (string memory);
    // Writes data to file, creating a file if it does not exist, and entirely replacing its contents if it does.
    // (path, data) => ()
    function writeFile(string calldata path, string calldata data) external;
    // Writes binary data to a file, creating a file if it does not exist, and entirely replacing its contents if it does.
    // Path is relative to the project root. (path, data) => ()
    function writeFileBinary(string calldata path, bytes calldata data) external;
    // Writes line to file, creating a file if it does not exist.
    // (path, data) => ()
    function writeLine(string calldata path, string calldata data) external;
    // Closes file for reading, resetting the offset and allowing to read it from beginning with readLine.
    // (path) => ()
    function closeFile(string calldata path) external;
    // Removes file. This cheatcode will revert in the following situations, but is not limited to just these cases:
    // - Path points to a directory.
    // - The file doesn't exist.
    // - The user lacks permissions to remove the file.
    // (path) => ()
    function removeFile(string calldata path) external;
    // Convert values to a string, (value) => (stringified value)
    function toString(address value) external pure returns (string memory);
    function toString(bytes calldata value) external pure returns (string memory);
    function toString(bytes32 value) external pure returns (string memory);
    function toString(bool value) external pure returns (string memory);
    function toString(uint256 value) external pure returns (string memory);
    function toString(int256 value) external pure returns (string memory);
    // Convert values from a string, (string) => (parsed value)
    function parseBytes(string calldata value) external pure returns (bytes memory);
    function parseAddress(string calldata value) external pure returns (address);
    function parseUint(string calldata value) external pure returns (uint256);
    function parseInt(string calldata value) external pure returns (int256);
    function parseBytes32(string calldata value) external pure returns (bytes32);
    function parseBool(string calldata value) external pure returns (bool);
    // Record all the transaction logs
    function recordLogs() external;
    // Gets all the recorded logs, () => (logs)
    function getRecordedLogs() external returns (Log[] memory);
    // Derive a private key from a provided mnenomic string (or mnenomic file path) at the derivation path m/44'/60'/0'/0/{index}
    function deriveKey(string calldata mnemonic, uint32 index) external pure returns (uint256);
    // Derive a private key from a provided mnenomic string (or mnenomic file path) at the derivation path {path}{index}
    function deriveKey(string calldata mnemonic, string calldata derivationPath, uint32 index) external pure returns (uint256);
    // Adds a private key to the local forge wallet and returns the address
    function rememberKey(uint256 privateKey) external returns (address);
    //
    // parseJson
    //
    // ----
    // In case the returned value is a JSON object, it's encoded as a ABI-encoded tuple. As JSON objects
    // don't have the notion of ordered, but tuples do, they JSON object is encoded with it's fields ordered in
    // ALPHABETICAL order. That means that in order to successfully decode the tuple, we need to define a tuple that
    // encodes the fields in the same order, which is alphabetical. In the case of Solidity structs, they are encoded
    // as tuples, with the attributes in the order in which they are defined.
    // For example: json = { 'a': 1, 'b': 0xa4tb......3xs}
    // a: uint256
    // b: address
    // To decode that json, we need to define a struct or a tuple as follows:
    // struct json = { uint256 a; address b; }
    // If we defined a json struct with the opposite order, meaning placing the address b first, it would try to
    // decode the tuple in that order, and thus fail.
    // ----
    // Given a string of JSON, return it as ABI-encoded, (stringified json, key) => (ABI-encoded data)
    function parseJson(string calldata json, string calldata key) external pure returns (bytes memory);
    function parseJson(string calldata json) external pure returns (bytes memory);
    //
    // writeJson
    //
    // ----
    // Let's assume we want to write the following JSON to a file:
    //
    // { "boolean": true, "number": 342, "object": { "title": "finally json serialization" } }
    //
    // ```
    //  string memory json1 = "some key";
    //  vm.serializeBool(json1, "boolean", true);
    //  vm.serializeBool(json1, "number", uint256(342));
    //  json2 = "some other key";
    //  string memory output = vm.serializeString(json2, "title", "finally json serialization");
    //  string memory finalJson = vm.serialize(json1, "object", output);
    //  vm.writeJson(finalJson, "./output/example.json");
    // ```
    //  The critical insight is that every invocation of serialization will return the stringified version of the JSON
    // up to that point. That means we can construct arbitrary JSON objects and then use the return stringified version
    // to serialize them as values to another JSON object.
    //
    //  json1 and json2 are simply keys used by the backend to keep track of the objects. So vm.serializeJson(json1,..)
    //  will find the object in-memory that is keyed by "some key".   // writeJson
    // ----
    // Serialize a key and value to a JSON object stored in-memory that can be later written to a file
    // It returns the stringified version of the specific JSON file up to that moment.
    // (objectKey, valueKey, value) => (stringified JSON)
    function serializeBool(string calldata objectKey, string calldata valueKey, bool value) external returns (string memory);
    function serializeUint(string calldata objectKey, string calldata valueKey, uint256 value) external returns (string memory);
    function serializeInt(string calldata objectKey, string calldata valueKey, int256 value) external returns (string memory);
    function serializeAddress(string calldata objectKey, string calldata valueKey, address value) external returns (string memory);
    function serializeBytes32(string calldata objectKey, string calldata valueKey, bytes32 value) external returns (string memory);
    function serializeString(string calldata objectKey, string calldata valueKey, string calldata value) external returns (string memory);
    function serializeBytes(string calldata objectKey, string calldata valueKey, bytes calldata value) external returns (string memory);

    function serializeBool(string calldata objectKey, string calldata valueKey, bool[] calldata values) external returns (string memory);
    function serializeUint(string calldata objectKey, string calldata valueKey, uint256[] calldata values) external returns (string memory);
    function serializeInt(string calldata objectKey, string calldata valueKey, int256[] calldata values) external returns (string memory);
    function serializeAddress(string calldata objectKey, string calldata valueKey, address[] calldata values)  external returns (string memory);
    function serializeBytes32(string calldata objectKey, string calldata valueKey, bytes32[] calldata values) external returns (string memory);
    function serializeString(string calldata objectKey, string calldata valueKey, string[] calldata values) external returns (string memory);
    function serializeBytes(string calldata objectKey, string calldata valueKey, bytes[] calldata values) external returns (string memory);
    // Write a serialized JSON object to a file. If the file exists, it will be overwritten.
    // (stringified_json, path)
    function writeJson(string calldata json, string calldata path) external;
    // Write a serialized JSON object to an **existing** JSON file, replacing a value with key = <value_key>
    // This is useful to replace a specific value of a JSON file, without having to parse the entire thing
    // (stringified_json, path, value_key)
    function writeJson(string calldata json, string calldata path, string calldata valueKey) external;
    // Returns the RPC url for the given alias
    function rpcUrl(string calldata rpcAlias) external view returns (string memory);
    // Returns all rpc urls and their aliases `[alias, url][]`
    function rpcUrls() external view returns (string[2][] memory);
    // Returns all rpc urls and their aliases as structs.
    function rpcUrlStructs() external view returns (Rpc[] memory);
    // If the condition is false, discard this run's fuzz inputs and generate new ones.
    function assume(bool condition) external pure;
    // Pauses gas metering (i.e. gas usage is not counted). Noop if already paused.
    function pauseGasMetering() external;
    // Resumes gas metering (i.e. gas usage is counted again). Noop if already on.
    function resumeGasMetering() external;
}

interface Vm is VmSafe {
    // Sets block.timestamp (newTimestamp)
    function warp(uint256 newTimestamp) external;
    // Sets block.height (newHeight)
    function roll(uint256 newHeight) external;
    // Sets block.basefee (newBasefee)
    function fee(uint256 newBasefee) external;
    // Sets block.difficulty (newDifficulty)
    function difficulty(uint256 newDifficulty) external;
    // Sets block.chainid
    function chainId(uint256 newChainId) external;
    // Stores a value to an address' storage slot, (who, slot, value)
    function store(address who, bytes32 slot, bytes32 value) external;
    // Sets the nonce of an account; must be higher than the current nonce of the account
    function setNonce(address account, uint64 newNonce) external;
    // Sets the *next* call's msg.sender to be the input address
    function prank(address newCaller) external;
    // Sets all subsequent calls' msg.sender to be the input address until `stopPrank` is called
    function startPrank(address newCaller) external;
    // Sets the *next* call's msg.sender to be the input address, and the tx.origin to be the second input
    function prank(address newCaller, address newTxOrigin) external;
    // Sets all subsequent calls' msg.sender to be the input address until `stopPrank` is called, and the tx.origin to be the second input
    function startPrank(address newCaller, address newTxOrigin) external;
    // Resets subsequent calls' msg.sender to be `address(this)`
    function stopPrank() external;
    // Sets an address' balance, (who, newBalance)
    function deal(address who, uint256 newBalance) external;
    // Sets an address' code, (who, newCode)
    function etch(address who, bytes calldata newCode) external;
    // Expects an error on next call
    function expectRevert(bytes calldata revertdata) external;
    function expectRevert(bytes4 revertdata) external;
    function expectRevert() external;
    // Prepare an expected log with (bool checkTopic1, bool checkTopic2, bool checkTopic3, bool checkData).
    // Call this function, then emit an event, then call a function. Internally after the call, we check if
    // logs were emitted in the expected order with the expected topics and data (as specified by the booleans)
    function expectEmit(bool checkTopic1, bool checkTopic2, bool checkTopic3, bool checkData) external;
    function expectEmit(bool checkTopic1, bool checkTopic2, bool checkTopic3, bool checkData, address emitter) external;
    // Mocks a call to an address, returning specified data.
    // Calldata can either be strict or a partial match, e.g. if you only
    // pass a Solidity selector to the expected calldata, then the entire Solidity
    // function will be mocked.
    function mockCall(address callee, bytes calldata passedData, bytes calldata returnedData) external;
    // Mocks a call to an address with a specific msg.value, returning specified data.
    // Calldata match takes precedence over msg.value in case of ambiguity.
    function mockCall(address callee, uint256 passedMsgValue, bytes calldata passedData, bytes calldata returnedData) external;
    // Clears all mocked calls
    function clearMockedCalls() external;
    // Expects a call to an address with the specified calldata.
    // Calldata can either be a strict or a partial match
    function expectCall(address callee, bytes calldata expectedCalldata) external;
    // Expects a call to an address with the specified msg.value and calldata
    function expectCall(address callee, uint256 expectedMsgValue, bytes calldata expectedCalldata) external;
    // Sets block.coinbase (who)
    function coinbase(address who) external;
    // Snapshot the current state of the evm.
    // Returns the id of the snapshot that was created.
    // To revert a snapshot use `revertTo`
    function snapshot() external returns (uint256);
    // Revert the state of the EVM to a previous snapshot
    // Takes the snapshot id to revert to.
    // This deletes the snapshot and all snapshots taken after the given snapshot id.
    function revertTo(uint256 snapshotId) external returns (bool);
    // Creates a new fork with the given endpoint and block and returns the identifier of the fork
    function createFork(string calldata endpoint, uint256 blockNumber) external returns (uint256);
    // Creates a new fork with the given endpoint and the _latest_ block and returns the identifier of the fork
    function createFork(string calldata endpoint) external returns (uint256);
    // Creates a new fork with the given endpoint and at the block the given transaction was mined in, and replays all transaction mined in the block before the transaction
    function createFork(string calldata endpoint, bytes32 txid) external returns (uint256);
    // Creates _and_ also selects a new fork with the given endpoint and block and returns the identifier of the fork
    function createSelectFork(string calldata endpoint, uint256 blockNumber) external returns (uint256);
    // Creates _and_ also selects new fork with the given endpoint and at the block the given transaction was mined in, and replays all transaction mined in the block before the transaction
    function createSelectFork(string calldata endpoint, bytes32 txid) external returns (uint256);
    // Creates _and_ also selects a new fork with the given endpoint and the latest block and returns the identifier of the fork
    function createSelectFork(string calldata endpoint) external returns (uint256);
    // Takes a fork identifier created by `createFork` and sets the corresponding forked state as active.
    function selectFork(uint256 forkId) external;
    /// Returns the currently active fork
    /// Reverts if no fork is currently active
    function activeFork() external view returns (uint256);
    // Updates the currently active fork to given block number
    // This is similar to `roll` but for the currently active fork
    function rollFork(uint256 blockNumber) external;
    // Updates the currently active fork to given transaction
    // this will `rollFork` with the number of the block the transaction was mined in and replays all transaction mined before it in the block
    function rollFork(bytes32 txid) external;
    // Updates the given fork to given block number
    function rollFork(uint256 forkId, uint256 blockNumber) external;
    // Updates the given fork to block number of the given transaction and replays all transaction mined before it in the block
    function rollFork(uint256 forkId, bytes32 transaction) external;
    // Marks that the account(s) should use persistent storage across fork swaps in a multifork setup
    // Meaning, changes made to the state of this account will be kept when switching forks
    function makePersistent(address account) external;
    function makePersistent(address account0, address account1) external;
    function makePersistent(address account0, address account1, address account2) external;
    function makePersistent(address[] calldata accounts) external;
    // Revokes persistent status from the address, previously added via `makePersistent`
    function revokePersistent(address account) external;
    function revokePersistent(address[] calldata accounts) external;
    // Returns true if the account is marked as persistent
    function isPersistent(address) external view returns (bool);
    // In forking mode, explicitly grant the given address cheatcode access
    function allowCheatcodes(address account) external;
    // Fetches the given transaction from the active fork and executes it on the current state
    function transact(bytes32 txid) external;
    // Fetches the given transaction from the given fork and executes it on the current state
    function transact(uint256 forkId, bytes32 txid) external;
}
