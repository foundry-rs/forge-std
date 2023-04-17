// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

struct AccessList {
    address accessAddress;
    bytes32[] storageKeys;
}

struct Account {
    address addr;
    uint256 key;
}

// Data structures to parse the entire broadcast artifact, assuming the
// transactions conform to EIP1559.
struct EIP1559ScriptArtifact {
    string[] libraries;
    string path;
    string[] pending;
    Receipt[] receipts;
    uint256 timestamp;
    Tx1559[] transactions;
    TxReturn[] txReturns;
}

// Data structures to parse Transaction objects from the broadcast artifact
// that conform to EIP1559. The Raw structs is what is parsed from the JSON
// and then converted to the one that is used by the user for better UX.
struct RawTx1559 {
    string[] arguments;
    address contractAddress;
    string contractName;
    // json value name = function
    string functionSig;
    bytes32 hash;
    // json value name = tx
    RawTx1559Detail txDetail;
    // json value name = type
    string opcode;
}

struct RawTx1559Detail {
    AccessList[] accessList;
    bytes data;
    address from;
    bytes gas;
    bytes nonce;
    address to;
    bytes txType;
    bytes value;
}

struct RawEIP1559ScriptArtifact {
    string[] libraries;
    string path;
    string[] pending;
    RawReceipt[] receipts;
    TxReturn[] txReturns;
    uint256 timestamp;
    RawTx1559[] transactions;
}

// Data structures to parse Receipt objects from the broadcast artifact.
// The Raw structs is what is parsed from the JSON
// and then converted to the one that is used by the user for better UX.
struct RawReceipt {
    bytes32 blockHash;
    bytes blockNumber;
    address contractAddress;
    bytes cumulativeGasUsed;
    bytes effectiveGasPrice;
    address from;
    bytes gasUsed;
    RawReceiptLog[] logs;
    bytes logsBloom;
    bytes status;
    address to;
    bytes32 transactionHash;
    bytes transactionIndex;
}

struct RawReceiptLog {
    // json value = address
    address logAddress;
    bytes32 blockHash;
    bytes blockNumber;
    bytes data;
    bytes logIndex;
    bool removed;
    bytes32[] topics;
    bytes32 transactionHash;
    bytes transactionIndex;
    bytes transactionLogIndex;
}

struct Receipt {
    bytes32 blockHash;
    uint256 blockNumber;
    address contractAddress;
    uint256 cumulativeGasUsed;
    uint256 effectiveGasPrice;
    address from;
    uint256 gasUsed;
    ReceiptLog[] logs;
    bytes logsBloom;
    uint256 status;
    address to;
    bytes32 transactionHash;
    uint256 transactionIndex;
}

struct ReceiptLog {
    // json value = address
    address logAddress;
    bytes32 blockHash;
    uint256 blockNumber;
    bytes data;
    uint256 logIndex;
    bytes32[] topics;
    uint256 transactionIndex;
    uint256 transactionLogIndex;
    bool removed;
}

struct Tx1559 {
    string[] arguments;
    address contractAddress;
    string contractName;
    string functionSig;
    bytes32 hash;
    Tx1559Detail txDetail;
    string opcode;
}

struct Tx1559Detail {
    AccessList[] accessList;
    bytes data;
    address from;
    uint256 gas;
    uint256 nonce;
    address to;
    uint256 txType;
    uint256 value;
}

struct TxDetailLegacy {
    AccessList[] accessList;
    uint256 chainId;
    bytes data;
    address from;
    uint256 gas;
    uint256 gasPrice;
    bytes32 hash;
    uint256 nonce;
    bytes1 opcode;
    bytes32 r;
    bytes32 s;
    uint256 txType;
    address to;
    uint8 v;
    uint256 value;
}

// Data structures to parse Transaction objects from the broadcast artifact
// that DO NOT conform to EIP1559. The Raw structs is what is parsed from the JSON
// and then converted to the one that is used by the user for better UX.
struct TxLegacy {
    string[] arguments;
    address contractAddress;
    string contractName;
    string functionSig;
    string hash;
    string opcode;
    TxDetailLegacy transaction;
}

struct TxReturn {
    string internalType;
    string value;
}
