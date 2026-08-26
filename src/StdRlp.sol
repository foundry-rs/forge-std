// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

pragma experimental ABIEncoderV2;

import {VmSafe} from "./Vm.sol";

// TODO: Account Fields (CodeHash, Balance, Nonce, StorageRoot).

/// @notice A general-purpose library for working with RLP (Recursive Length Prefix)
///         encoded data in Ethereum.
///
/// @dev    This library provides utilities for decoding and working with RLP-encoded
///         data structures. Currently focused on block header parsing, but designed
///         to be extensible for other RLP use cases.
///
///         Block header usage:
///         ```solidity
///         import {stdRlp} from "forge-std/StdRlp.sol";
///
///         stdRlp.BlockHeader memory header = stdRlp.getBlockHeader(block.number);
///         console.log("stateRoot:", header.stateRoot);
///
///         bytes memory rawHeader = vm.getRawBlockHeader(block.number);
///         stdRlp.BlockHeader memory header = stdRlp.toBlockHeader(rawHeader);
///         console.log("stateRoot:", header.stateRoot);
///         ```
library stdRlp {
    VmSafe private constant vm = VmSafe(address(uint160(uint256(keccak256("hevm cheat code")))));

    /// @notice Represents a parsed Ethereum block header with all standard fields.
    /// @dev    Contains all fields from modern Ethereum block headers, including
    ///         post-merge (baseFeePerGas), post-Shapella (withdrawalsRoot), post-Cancun
    ///         (blobGasUsed, excessBlobGas, parentBeaconRoot), and post-Dencun (requestsHash) fields.
    struct BlockHeader {
        bytes32 hash;
        bytes32 parentHash;
        bytes32 ommersHash;
        address beneficiary;
        bytes32 stateRoot;
        bytes32 transactionsRoot;
        bytes32 receiptsRoot;
        bytes logsBloom;
        uint256 difficulty;
        uint256 number;
        uint256 gasLimit;
        uint256 gasUsed;
        uint256 timestamp;
        bytes extraData;
        bytes32 mixHash;
        uint256 nonce;
        uint256 baseFeePerGas;
        bytes32 withdrawalsRoot;
        uint256 blobGasUsed;
        uint256 excessBlobGas;
        bytes32 parentBeaconRoot;
        bytes32 requestsHash;
    }

    /// @notice Parses a raw RLP-encoded block header into a structured `BlockHeader`.
    /// @dev    Uses the Foundry cheatcode `vm.fromRlp` to decode the RLP structure.
    ///         The block hash is computed as the keccak256 of the raw header bytes.
    ///         Fields are extracted in the order defined by the Ethereum specification.
    /// @param  rawBlockHeader The RLP-encoded block header bytes.
    /// @return blockHeader The parsed block header with all fields populated.
    function toBlockHeader(bytes memory rawBlockHeader) internal pure returns (BlockHeader memory blockHeader) {
        bytes[] memory fields = vm.fromRlp(rawBlockHeader);

        blockHeader.hash = keccak256(rawBlockHeader);
        blockHeader.parentHash = bytes32(fields[0]);
        blockHeader.ommersHash = bytes32(fields[1]);
        blockHeader.beneficiary = address(bytes20(fields[2]));
        blockHeader.stateRoot = bytes32(fields[3]);
        blockHeader.transactionsRoot = bytes32(fields[4]);
        blockHeader.receiptsRoot = bytes32(fields[5]);
        blockHeader.logsBloom = fields[6];
        blockHeader.difficulty = _toUint(fields[7]);
        blockHeader.number = _toUint(fields[8]);
        blockHeader.gasLimit = _toUint(fields[9]);
        blockHeader.gasUsed = _toUint(fields[10]);
        blockHeader.timestamp = _toUint(fields[11]);
        blockHeader.extraData = fields[12];
        blockHeader.mixHash = bytes32(fields[13]);
        blockHeader.nonce = _toUint(fields[14]);
        blockHeader.baseFeePerGas = _toUint(fields[15]);
        blockHeader.withdrawalsRoot = bytes32(fields[16]);
        blockHeader.blobGasUsed = _toUint(fields[17]);
        blockHeader.excessBlobGas = _toUint(fields[18]);
        blockHeader.parentBeaconRoot = bytes32(fields[19]);
        blockHeader.requestsHash = bytes32(fields[20]);

        return blockHeader;
    }

    /// @notice Fetches and parses the block header for a specific block number.
    /// @dev    Combines `vm.getRawBlockHeader` with `toBlockHeader` for convenience.
    ///         This is a view function because it reads blockchain state via the vm cheatcode.
    /// @param blockNumber The block number to fetch the header for.
    /// @return blockHeader The parsed block header with all fields populated.
    function getBlockHeader(uint256 blockNumber) internal view returns (BlockHeader memory blockHeader) {
        return toBlockHeader(vm.getRawBlockHeader(blockNumber));
    }

    /// @dev    Internal helper to convert variable-length bytes to uint256.
    ///         Handles RLP-encoded integers by treating the bytes as big-endian
    ///         and right-shifting to account for shorter lengths.
    function _toUint(bytes memory b) internal pure returns (uint256 r) {
        unchecked {
            return uint256(bytes32(b)) >> (8 * (32 - b.length));
        }
    }
}
