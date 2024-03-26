// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import {console2 as console } from "./console2.sol";
import {StdChains} from "./StdChains.sol";
import {StdCheatsSafe} from "./StdCheats.sol";
import {StdInvariant} from "./StdInvariant.sol";
import {StdStorage} from "./StdStorage.sol";
import {VmSafe} from "./Vm.sol";
import {IMulticall3} from "./interfaces/IMulticall3.sol";
import {StorageTest} from "../test/StdStorage.t.sol";

library forgeStdLogHelper {
    function log(VmSafe.Log memory _struct, string memory _prefix) internal pure {
        console.log(string.concat(_prefix, "topics[0]"));
        console.logBytes32(bytes32(_struct.topics[0]));
        console.log(string.concat(_prefix, "topics.length"), _struct.topics.length);
        console.log(string.concat(_prefix, "data"));
        console.logBytes(_struct.data);
        console.log(string.concat(_prefix, "emitter"), _struct.emitter);
    }

    function log(VmSafe.Rpc memory _struct, string memory _prefix) internal pure {
        console.log(string.concat(_prefix, "key"), _struct.key);
        console.log(string.concat(_prefix, "url"), _struct.url);
    }

    function log(VmSafe.DirEntry memory _struct, string memory _prefix) internal pure {
        console.log(string.concat(_prefix, "errorMessage"), _struct.errorMessage);
        console.log(string.concat(_prefix, "path"), _struct.path);
        console.log(string.concat(_prefix, "depth"), uint256(_struct.depth));
        console.log(string.concat(_prefix, "isDir"), _struct.isDir);
        console.log(string.concat(_prefix, "isSymlink"), _struct.isSymlink);
    }

    function log(VmSafe.FsMetadata memory _struct, string memory _prefix) internal pure {
        console.log(string.concat(_prefix, "isDir"), _struct.isDir);
        console.log(string.concat(_prefix, "isSymlink"), _struct.isSymlink);
        console.log(string.concat(_prefix, "length"), uint256(_struct.length));
        console.log(string.concat(_prefix, "readOnly"), _struct.readOnly);
        console.log(string.concat(_prefix, "modified"), uint256(_struct.modified));
        console.log(string.concat(_prefix, "accessed"), uint256(_struct.accessed));
        console.log(string.concat(_prefix, "created"), uint256(_struct.created));
    }

    function log(VmSafe.Wallet memory _struct, string memory _prefix) internal pure {
        console.log(string.concat(_prefix, "addr"), _struct.addr);
        console.log(string.concat(_prefix, "publicKeyX"), uint256(_struct.publicKeyX));
        console.log(string.concat(_prefix, "publicKeyY"), uint256(_struct.publicKeyY));
        console.log(string.concat(_prefix, "privateKey"), uint256(_struct.privateKey));
    }

    function log(IMulticall3.Call memory _struct, string memory _prefix) internal pure {
        console.log(string.concat(_prefix, "target"), _struct.target);
        console.log(string.concat(_prefix, "callData"));
        console.logBytes(_struct.callData);
    }

    function log(IMulticall3.Call3 memory _struct, string memory _prefix) internal pure {
        console.log(string.concat(_prefix, "target"), _struct.target);
        console.log(string.concat(_prefix, "allowFailure"), _struct.allowFailure);
        console.log(string.concat(_prefix, "callData"));
        console.logBytes(_struct.callData);
    }

    function log(IMulticall3.Call3Value memory _struct, string memory _prefix) internal pure {
        console.log(string.concat(_prefix, "target"), _struct.target);
        console.log(string.concat(_prefix, "allowFailure"), _struct.allowFailure);
        console.log(string.concat(_prefix, "value"), uint256(_struct.value));
        console.log(string.concat(_prefix, "callData"));
        console.logBytes(_struct.callData);
    }

    function log(IMulticall3.Result memory _struct, string memory _prefix) internal pure {
        console.log(string.concat(_prefix, "success"), _struct.success);
        console.log(string.concat(_prefix, "returnData"));
        console.logBytes(_struct.returnData);
    }

    function log(StdChains.ChainData memory _struct, string memory _prefix) internal pure {
        console.log(string.concat(_prefix, "name"), _struct.name);
        console.log(string.concat(_prefix, "chainId"), uint256(_struct.chainId));
        console.log(string.concat(_prefix, "rpcUrl"), _struct.rpcUrl);
    }

    function log(StdChains.Chain memory _struct, string memory _prefix) internal pure {
        console.log(string.concat(_prefix, "name"), _struct.name);
        console.log(string.concat(_prefix, "chainId"), uint256(_struct.chainId));
        console.log(string.concat(_prefix, "chainAlias"), _struct.chainAlias);
        console.log(string.concat(_prefix, "rpcUrl"), _struct.rpcUrl);
    }

    function log(StdCheatsSafe.RawTx1559 memory _struct, string memory _prefix) internal pure {
        console.log(string.concat(_prefix, "arguments[0]"), _struct.arguments[0]);
        console.log(string.concat(_prefix, "arguments.length"), _struct.arguments.length);
        console.log(string.concat(_prefix, "contractAddress"), _struct.contractAddress);
        console.log(string.concat(_prefix, "contractName"), _struct.contractName);
        console.log(string.concat(_prefix, "functionSig"), _struct.functionSig);
        console.log(string.concat(_prefix, "hash"));
        console.logBytes32(bytes32(_struct.hash));
        log(_struct.txDetail, string.concat(_prefix, "txDetail."));
        console.log(string.concat(_prefix, "opcode"), _struct.opcode);
    }

    function log(StdCheatsSafe.RawTx1559Detail memory _struct, string memory _prefix) internal pure {
        log(_struct.accessList[0], string.concat(_prefix, "accessList[0]."));
        console.log(string.concat(_prefix, "accessList.length"), _struct.accessList.length);
        console.log(string.concat(_prefix, "data"));
        console.logBytes(_struct.data);
        console.log(string.concat(_prefix, "from"), _struct.from);
        console.log(string.concat(_prefix, "gas"));
        console.logBytes(_struct.gas);
        console.log(string.concat(_prefix, "nonce"));
        console.logBytes(_struct.nonce);
        console.log(string.concat(_prefix, "to"), _struct.to);
        console.log(string.concat(_prefix, "txType"));
        console.logBytes(_struct.txType);
        console.log(string.concat(_prefix, "value"));
        console.logBytes(_struct.value);
    }

    function log(StdCheatsSafe.Tx1559 memory _struct, string memory _prefix) internal pure {
        console.log(string.concat(_prefix, "arguments[0]"), _struct.arguments[0]);
        console.log(string.concat(_prefix, "arguments.length"), _struct.arguments.length);
        console.log(string.concat(_prefix, "contractAddress"), _struct.contractAddress);
        console.log(string.concat(_prefix, "contractName"), _struct.contractName);
        console.log(string.concat(_prefix, "functionSig"), _struct.functionSig);
        console.log(string.concat(_prefix, "hash"));
        console.logBytes32(bytes32(_struct.hash));
        log(_struct.txDetail, string.concat(_prefix, "txDetail."));
        console.log(string.concat(_prefix, "opcode"), _struct.opcode);
    }

    function log(StdCheatsSafe.Tx1559Detail memory _struct, string memory _prefix) internal pure {
        log(_struct.accessList[0], string.concat(_prefix, "accessList[0]."));
        console.log(string.concat(_prefix, "accessList.length"), _struct.accessList.length);
        console.log(string.concat(_prefix, "data"));
        console.logBytes(_struct.data);
        console.log(string.concat(_prefix, "from"), _struct.from);
        console.log(string.concat(_prefix, "gas"), uint256(_struct.gas));
        console.log(string.concat(_prefix, "nonce"), uint256(_struct.nonce));
        console.log(string.concat(_prefix, "to"), _struct.to);
        console.log(string.concat(_prefix, "txType"), uint256(_struct.txType));
        console.log(string.concat(_prefix, "value"), uint256(_struct.value));
    }

    function log(StdCheatsSafe.TxLegacy memory _struct, string memory _prefix) internal pure {
        console.log(string.concat(_prefix, "arguments[0]"), _struct.arguments[0]);
        console.log(string.concat(_prefix, "arguments.length"), _struct.arguments.length);
        console.log(string.concat(_prefix, "contractAddress"), _struct.contractAddress);
        console.log(string.concat(_prefix, "contractName"), _struct.contractName);
        console.log(string.concat(_prefix, "functionSig"), _struct.functionSig);
        console.log(string.concat(_prefix, "hash"), _struct.hash);
        console.log(string.concat(_prefix, "opcode"), _struct.opcode);
        log(_struct.transaction, string.concat(_prefix, "transaction."));
    }

    function log(StdCheatsSafe.TxDetailLegacy memory _struct, string memory _prefix) internal pure {
        log(_struct.accessList[0], string.concat(_prefix, "accessList[0]."));
        console.log(string.concat(_prefix, "accessList.length"), _struct.accessList.length);
        console.log(string.concat(_prefix, "chainId"), uint256(_struct.chainId));
        console.log(string.concat(_prefix, "data"));
        console.logBytes(_struct.data);
        console.log(string.concat(_prefix, "from"), _struct.from);
        console.log(string.concat(_prefix, "gas"), uint256(_struct.gas));
        console.log(string.concat(_prefix, "gasPrice"), uint256(_struct.gasPrice));
        console.log(string.concat(_prefix, "hash"));
        console.logBytes32(bytes32(_struct.hash));
        console.log(string.concat(_prefix, "nonce"), uint256(_struct.nonce));
        console.log(string.concat(_prefix, "opcode"));
        console.logBytes32(bytes32(_struct.opcode));
        console.log(string.concat(_prefix, "r"));
        console.logBytes32(bytes32(_struct.r));
        console.log(string.concat(_prefix, "s"));
        console.logBytes32(bytes32(_struct.s));
        console.log(string.concat(_prefix, "txType"), uint256(_struct.txType));
        console.log(string.concat(_prefix, "to"), _struct.to);
        console.log(string.concat(_prefix, "v"), uint256(_struct.v));
        console.log(string.concat(_prefix, "value"), uint256(_struct.value));
    }

    function log(StdCheatsSafe.AccessList memory _struct, string memory _prefix) internal pure {
        console.log(string.concat(_prefix, "accessAddress"), _struct.accessAddress);
        console.log(string.concat(_prefix, "storageKeys[0]"));
        console.logBytes32(bytes32(_struct.storageKeys[0]));
        console.log(string.concat(_prefix, "storageKeys.length"), _struct.storageKeys.length);
    }

    function log(StdCheatsSafe.RawReceipt memory _struct, string memory _prefix) internal pure {
        console.log(string.concat(_prefix, "blockHash"));
        console.logBytes32(bytes32(_struct.blockHash));
        console.log(string.concat(_prefix, "blockNumber"));
        console.logBytes(_struct.blockNumber);
        console.log(string.concat(_prefix, "contractAddress"), _struct.contractAddress);
        console.log(string.concat(_prefix, "cumulativeGasUsed"));
        console.logBytes(_struct.cumulativeGasUsed);
        console.log(string.concat(_prefix, "effectiveGasPrice"));
        console.logBytes(_struct.effectiveGasPrice);
        console.log(string.concat(_prefix, "from"), _struct.from);
        console.log(string.concat(_prefix, "gasUsed"));
        console.logBytes(_struct.gasUsed);
        log(_struct.logs[0], string.concat(_prefix, "logs[0]."));
        console.log(string.concat(_prefix, "logs.length"), _struct.logs.length);
        console.log(string.concat(_prefix, "logsBloom"));
        console.logBytes(_struct.logsBloom);
        console.log(string.concat(_prefix, "status"));
        console.logBytes(_struct.status);
        console.log(string.concat(_prefix, "to"), _struct.to);
        console.log(string.concat(_prefix, "transactionHash"));
        console.logBytes32(bytes32(_struct.transactionHash));
        console.log(string.concat(_prefix, "transactionIndex"));
        console.logBytes(_struct.transactionIndex);
    }

    function log(StdCheatsSafe.Receipt memory _struct, string memory _prefix) internal pure {
        console.log(string.concat(_prefix, "blockHash"));
        console.logBytes32(bytes32(_struct.blockHash));
        console.log(string.concat(_prefix, "blockNumber"), uint256(_struct.blockNumber));
        console.log(string.concat(_prefix, "contractAddress"), _struct.contractAddress);
        console.log(string.concat(_prefix, "cumulativeGasUsed"), uint256(_struct.cumulativeGasUsed));
        console.log(string.concat(_prefix, "effectiveGasPrice"), uint256(_struct.effectiveGasPrice));
        console.log(string.concat(_prefix, "from"), _struct.from);
        console.log(string.concat(_prefix, "gasUsed"), uint256(_struct.gasUsed));
        log(_struct.logs[0], string.concat(_prefix, "logs[0]."));
        console.log(string.concat(_prefix, "logs.length"), _struct.logs.length);
        console.log(string.concat(_prefix, "logsBloom"));
        console.logBytes(_struct.logsBloom);
        console.log(string.concat(_prefix, "status"), uint256(_struct.status));
        console.log(string.concat(_prefix, "to"), _struct.to);
        console.log(string.concat(_prefix, "transactionHash"));
        console.logBytes32(bytes32(_struct.transactionHash));
        console.log(string.concat(_prefix, "transactionIndex"), uint256(_struct.transactionIndex));
    }

    function log(StdCheatsSafe.EIP1559ScriptArtifact memory _struct, string memory _prefix) internal pure {
        console.log(string.concat(_prefix, "libraries[0]"), _struct.libraries[0]);
        console.log(string.concat(_prefix, "libraries.length"), _struct.libraries.length);
        console.log(string.concat(_prefix, "path"), _struct.path);
        console.log(string.concat(_prefix, "pending[0]"), _struct.pending[0]);
        console.log(string.concat(_prefix, "pending.length"), _struct.pending.length);
        log(_struct.receipts[0], string.concat(_prefix, "receipts[0]."));
        console.log(string.concat(_prefix, "receipts.length"), _struct.receipts.length);
        console.log(string.concat(_prefix, "timestamp"), uint256(_struct.timestamp));
        log(_struct.transactions[0], string.concat(_prefix, "transactions[0]."));
        console.log(string.concat(_prefix, "transactions.length"), _struct.transactions.length);
        log(_struct.txReturns[0], string.concat(_prefix, "txReturns[0]."));
        console.log(string.concat(_prefix, "txReturns.length"), _struct.txReturns.length);
    }

    function log(StdCheatsSafe.RawEIP1559ScriptArtifact memory _struct, string memory _prefix) internal pure {
        console.log(string.concat(_prefix, "libraries[0]"), _struct.libraries[0]);
        console.log(string.concat(_prefix, "libraries.length"), _struct.libraries.length);
        console.log(string.concat(_prefix, "path"), _struct.path);
        console.log(string.concat(_prefix, "pending[0]"), _struct.pending[0]);
        console.log(string.concat(_prefix, "pending.length"), _struct.pending.length);
        log(_struct.receipts[0], string.concat(_prefix, "receipts[0]."));
        console.log(string.concat(_prefix, "receipts.length"), _struct.receipts.length);
        log(_struct.txReturns[0], string.concat(_prefix, "txReturns[0]."));
        console.log(string.concat(_prefix, "txReturns.length"), _struct.txReturns.length);
        console.log(string.concat(_prefix, "timestamp"), uint256(_struct.timestamp));
        log(_struct.transactions[0], string.concat(_prefix, "transactions[0]."));
        console.log(string.concat(_prefix, "transactions.length"), _struct.transactions.length);
    }

    function log(StdCheatsSafe.RawReceiptLog memory _struct, string memory _prefix) internal pure {
        console.log(string.concat(_prefix, "logAddress"), _struct.logAddress);
        console.log(string.concat(_prefix, "blockHash"));
        console.logBytes32(bytes32(_struct.blockHash));
        console.log(string.concat(_prefix, "blockNumber"));
        console.logBytes(_struct.blockNumber);
        console.log(string.concat(_prefix, "data"));
        console.logBytes(_struct.data);
        console.log(string.concat(_prefix, "logIndex"));
        console.logBytes(_struct.logIndex);
        console.log(string.concat(_prefix, "removed"), _struct.removed);
        console.log(string.concat(_prefix, "topics[0]"));
        console.logBytes32(bytes32(_struct.topics[0]));
        console.log(string.concat(_prefix, "topics.length"), _struct.topics.length);
        console.log(string.concat(_prefix, "transactionHash"));
        console.logBytes32(bytes32(_struct.transactionHash));
        console.log(string.concat(_prefix, "transactionIndex"));
        console.logBytes(_struct.transactionIndex);
        console.log(string.concat(_prefix, "transactionLogIndex"));
        console.logBytes(_struct.transactionLogIndex);
    }

    function log(StdCheatsSafe.ReceiptLog memory _struct, string memory _prefix) internal pure {
        console.log(string.concat(_prefix, "logAddress"), _struct.logAddress);
        console.log(string.concat(_prefix, "blockHash"));
        console.logBytes32(bytes32(_struct.blockHash));
        console.log(string.concat(_prefix, "blockNumber"), uint256(_struct.blockNumber));
        console.log(string.concat(_prefix, "data"));
        console.logBytes(_struct.data);
        console.log(string.concat(_prefix, "logIndex"), uint256(_struct.logIndex));
        console.log(string.concat(_prefix, "topics[0]"));
        console.logBytes32(bytes32(_struct.topics[0]));
        console.log(string.concat(_prefix, "topics.length"), _struct.topics.length);
        console.log(string.concat(_prefix, "transactionIndex"), uint256(_struct.transactionIndex));
        console.log(string.concat(_prefix, "transactionLogIndex"), uint256(_struct.transactionLogIndex));
        console.log(string.concat(_prefix, "removed"), _struct.removed);
    }

    function log(StdCheatsSafe.TxReturn memory _struct, string memory _prefix) internal pure {
        console.log(string.concat(_prefix, "internalType"), _struct.internalType);
        console.log(string.concat(_prefix, "value"), _struct.value);
    }

    function log(StdCheatsSafe.Account memory _struct, string memory _prefix) internal pure {
        console.log(string.concat(_prefix, "addr"), _struct.addr);
        console.log(string.concat(_prefix, "key"), uint256(_struct.key));
    }

    function log(StorageTest.UnpackedStruct memory _struct, string memory _prefix) internal pure {
        console.log(string.concat(_prefix, "a"), uint256(_struct.a));
        console.log(string.concat(_prefix, "b"), uint256(_struct.b));
    }

    function log(StdInvariant.FuzzSelector memory _struct, string memory _prefix) internal pure {
        console.log(string.concat(_prefix, "addr"), _struct.addr);
        console.log(string.concat(_prefix, "selectors[0]"));
        console.logBytes32(bytes32(_struct.selectors[0]));
        console.log(string.concat(_prefix, "selectors.length"), _struct.selectors.length);
    }

    function log(StdStorage storage _struct, string memory _prefix) internal view {
        console.log(string.concat(_prefix, "_keys[0]"));
        console.logBytes32(bytes32(_struct._keys[0]));
        console.log(string.concat(_prefix, "_keys.length"), _struct._keys.length);
        console.log(string.concat(_prefix, "_sig"));
        console.logBytes32(bytes32(_struct._sig));
        console.log(string.concat(_prefix, "_depth"), uint256(_struct._depth));
        console.log(string.concat(_prefix, "_target"), _struct._target);
        console.log(string.concat(_prefix, "_set"));
        console.logBytes32(bytes32(_struct._set));
    }
}
