// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

pragma experimental ABIEncoderV2;

/// @title Multicall3
/// @dev SEE: https://github.com/mds1/multicall3/blob/main/src/Multicall3.sol
interface IMulticall3 {
    struct Call {
        address target;
        bytes callData;
    }

    struct Call3 {
        address target;
        bool allowFailure;
        bytes callData;
    }

    struct Call3Value {
        address target;
        bool allowFailure;
        uint256 value;
        bytes callData;
    }

    struct Result {
        bool success;
        bytes returnData;
    }

    /// @notice Backwards-compatible call aggregation with Multicall.
    /// @param calls An array of Call structs.
    /// @return blockNumber The block number where the calls were executed.
    /// @return returnData An array of bytes containing the responses.
    function aggregate(Call[] calldata calls)
        external
        payable
        returns (uint256 blockNumber, bytes[] memory returnData);

    /// @notice Aggregate calls, ensuring each returns success if required.
    /// @param calls An array of Call3 structs.
    /// @return returnData An array of Result structs.
    function aggregate3(Call3[] calldata calls) external payable returns (Result[] memory returnData);

    /// @notice Aggregate calls with a msg value.
    /// @notice Reverts if msg.value is less than the sum of the call values.
    /// @param calls An array of Call3Value structs.
    /// @return returnData An array of Result structs.
    function aggregate3Value(Call3Value[] calldata calls) external payable returns (Result[] memory returnData);

    /// @notice Backwards-compatible with Multicall2.
    /// @notice Aggregate calls and allow failures using tryAggregate.
    /// @param calls An array of Call structs.
    /// @return blockNumber The block number where the calls were executed.
    /// @return blockHash The hash of the block where the calls were executed.
    /// @return returnData An array of Result structs.
    function blockAndAggregate(Call[] calldata calls)
        external
        payable
        returns (uint256 blockNumber, bytes32 blockHash, Result[] memory returnData);

    /// @notice Gets the base fee of the given block.
    /// @notice Can revert if the BASEFEE opcode is not implemented by the given chain.
    function getBasefee() external view returns (uint256 basefee);

    /// @notice Returns the block hash for the given block number.
    /// @param blockNumber The block number.
    function getBlockHash(uint256 blockNumber) external view returns (bytes32 blockHash);

    /// @notice Returns the block number.
    function getBlockNumber() external view returns (uint256 blockNumber);

    /// @notice Returns the chain id.
    function getChainId() external view returns (uint256 chainid);

    /// @notice Returns the block coinbase.
    function getCurrentBlockCoinbase() external view returns (address coinbase);

    /// @notice Returns the block difficulty.
    function getCurrentBlockDifficulty() external view returns (uint256 difficulty);

    /// @notice Returns the block gas limit.
    function getCurrentBlockGasLimit() external view returns (uint256 gaslimit);

    /// @notice Returns the block timestamp.
    function getCurrentBlockTimestamp() external view returns (uint256 timestamp);

    /// @notice Returns the (ETH) balance of a given address.
    function getEthBalance(address addr) external view returns (uint256 balance);

    /// @notice Returns the block hash of the last block.
    function getLastBlockHash() external view returns (bytes32 blockHash);

    /// @notice Backwards-compatible with Multicall2.
    /// @notice Aggregate calls without requiring success.
    /// @param requireSuccess If true, require all calls to succeed.
    /// @param calls An array of Call structs.
    /// @return returnData An array of Result structs.
    function tryAggregate(bool requireSuccess, Call[] calldata calls)
        external
        payable
        returns (Result[] memory returnData);

    /// @notice Backwards-compatible with Multicall2.
    /// @notice Aggregate calls and allow failures using tryAggregate.
    /// @param calls An array of Call structs.
    /// @return blockNumber The block number where the calls were executed.
    /// @return blockHash The hash of the block where the calls were executed.
    /// @return returnData An array of Result structs.
    function tryBlockAndAggregate(bool requireSuccess, Call[] calldata calls)
        external
        payable
        returns (uint256 blockNumber, bytes32 blockHash, Result[] memory returnData);
}
