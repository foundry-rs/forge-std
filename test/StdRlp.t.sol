// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import {Test, stdRlp} from "../src/Test.sol";

contract StdRlpTest is Test {
    // Block 23513000 RLP header from Ethereum mainnet (October 5, 2025)
    // cast block 23513000 --raw
    // vm.getRawBlockHeader(23513000)
    bytes constant BLOCK_23513000_RAW =
        hex"f90286a05b5b6bff48fe6a2167a2c70193bd1ec94e140ad09ebca6d64f468bc273518d36a01dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347944838b106fce9647bdf1e7877bf73ce8b0bad5f97a09099fb0c9d079059756770f425953cbc7965cf14a6f99e2007ceb5fc0c86f695a00ed75b9475c7d88f3656ae833b9af1249efe1d51234ae9c318e92fb9bbc58cefa05a70f4c705bec8d642aef9d9fa593a9292a2b70e85fe303cc20f407af4814be4b901009ff9dbe477c99f97b7556c0ffaf95a41bbeb73bdee22fd307bf7739ae6d7bf37eb3defd7f3ff78d772d5d7b5fc3fb5dddfd9d3f8fe85aeffbfa92cc29aaff5b7e5edf80e6e4addfc7cdbf1ce895bbd71d71d9a756a74cdbcbf7ddca5cbf306d9fedf3b278a7f13ef3545ab52fecd7cfb4eefef63f8e8c6e5a1b8ee57874ff67f0f5beeffd7bc503f6379c76f2ff6a4fff17d7fddbbff336ef42fd1d43ad3bddee246af87a6bdfe977ffb35f57a5dfdfca566d5e5d8f7fc9cba4f4531e666f5f0f3d7bcaf65b7e7708dcdf679afe6b4add57f6f4a3e397efb9cdf9f77f0f7fbcf3bb3bc880b2b71c0b4eee1dee95f72e5ffcd9eefeffc37fecd84ba435ebdf70d80840166c7a88402aea4ea84014204dd8468e2a7cf98546974616e2028746974616e6275696c6465722e78797a29a0542df7cb12be5ee5281247c44fbef1a534899cacf6f4a7cbb005e451dd416de68800000000000000008407e356e5a0740234ba028832cd35e1e2923133d136e54fbded84e1e1f1f21747508c8edb92830c00008404100000a030297d32b4bb781dea1b6861b8b15db62f4428d1ae766615b4c29cd515df3a9da0e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855";

    stdRlp.BlockHeader expectedHeader;

    function setUp() public {
        expectedHeader = stdRlp.BlockHeader({
            hash: 0x65407618ec1f44bd793f024f9ce855d7287ea4a9d7ae4c9e672362a372b9ded4,
            parentHash: 0x5b5b6bff48fe6a2167a2c70193bd1ec94e140ad09ebca6d64f468bc273518d36,
            ommersHash: 0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347,
            beneficiary: 0x4838B106FCe9647Bdf1E7877BF73cE8B0BAD5f97,
            stateRoot: 0x9099fb0c9d079059756770f425953cbc7965cf14a6f99e2007ceb5fc0c86f695,
            transactionsRoot: 0x0ed75b9475c7d88f3656ae833b9af1249efe1d51234ae9c318e92fb9bbc58cef,
            receiptsRoot: 0x5a70f4c705bec8d642aef9d9fa593a9292a2b70e85fe303cc20f407af4814be4,
            logsBloom: hex"009ff9dbe477c99f97b7556c0ffaf95a41bbeb73bdee22fd307bf7739ae6d7bf37eb3defd7f3ff78d772d5d7b5fc3fb5dddfd9d3f8fe85aeffbfa92cc29aaff5b7e5edf80e6e4addfc7cdbf1ce895bbd71d71d9a756a74cdbcbf7ddca5cbf306d9fedf3b278a7f13ef3545ab52fecd7cfb4eefef63f8e8c6e5a1b8ee57874ff67f0f5beeffd7bc503f6379c76f2ff6a4fff17d7fddbbff336ef42fd1d43ad3bddee246af87a6bdfe977ffb35f57a5dfdfca566d5e5d8f7fc9cba4f4531e666f5f0f3d7bcaf65b7e7708dcdf679afe6b4add57f6f4a3e397efb9cdf9f77f0f7fbcf3bb3bc880b2b71c0b4eee1dee95f72e5ffcd9eefeffc37fecd84ba435ebdf70d",
            difficulty: 0,
            number: 23513000,
            gasLimit: 44999914,
            gasUsed: 21103837,
            timestamp: 1759684559,
            extraData: hex"546974616e2028746974616e6275696c6465722e78797a29",
            mixHash: 0x542df7cb12be5ee5281247c44fbef1a534899cacf6f4a7cbb005e451dd416de6,
            nonce: 0,
            baseFeePerGas: 132339429,
            withdrawalsRoot: 0x740234ba028832cd35e1e2923133d136e54fbded84e1e1f1f21747508c8edb92,
            blobGasUsed: 786432,
            excessBlobGas: 68157440,
            parentBeaconRoot: 0x30297d32b4bb781dea1b6861b8b15db62f4428d1ae766615b4c29cd515df3a9d,
            requestsHash: 0xe3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
        });
    }

    function test_GetBlockHeader_BasicFields() public view {
        stdRlp.BlockHeader memory header = stdRlp.toBlockHeader(BLOCK_23513000_RAW);

        // Verify hash
        assertEq(header.hash, keccak256(BLOCK_23513000_RAW), "Hash mismatch");

        // Verify basic fields
        assertEq(header.parentHash, expectedHeader.parentHash, "Parent hash mismatch");
        assertEq(header.ommersHash, expectedHeader.ommersHash, "Ommers hash mismatch");
        assertEq(header.beneficiary, expectedHeader.beneficiary, "Beneficiary mismatch");
        assertEq(header.stateRoot, expectedHeader.stateRoot, "State root mismatch");
        assertEq(header.transactionsRoot, expectedHeader.transactionsRoot, "Transactions root mismatch");
        assertEq(header.receiptsRoot, expectedHeader.receiptsRoot, "Receipts root mismatch");
        assertEq(header.difficulty, expectedHeader.difficulty, "Difficulty mismatch");
        assertEq(header.number, expectedHeader.number, "Number mismatch");
        assertEq(header.gasLimit, expectedHeader.gasLimit, "Gas limit mismatch");
        assertEq(header.gasUsed, expectedHeader.gasUsed, "Gas used mismatch");
        assertEq(header.timestamp, expectedHeader.timestamp, "Timestamp mismatch");
        assertEq(header.extraData, expectedHeader.extraData, "Extra data mismatch");
        assertEq(header.mixHash, expectedHeader.mixHash, "Mix hash mismatch");
        assertEq(header.nonce, expectedHeader.nonce, "Nonce mismatch");
        assertEq(header.baseFeePerGas, expectedHeader.baseFeePerGas, "Base fee per gas mismatch");
        assertEq(header.withdrawalsRoot, expectedHeader.withdrawalsRoot, "Withdrawals root mismatch");
        assertEq(header.blobGasUsed, expectedHeader.blobGasUsed, "Blob gas used mismatch");
        assertEq(header.excessBlobGas, expectedHeader.excessBlobGas, "Excess blob gas mismatch");
        assertEq(header.parentBeaconRoot, expectedHeader.parentBeaconRoot, "Parent beacon root mismatch");
        assertEq(header.requestsHash, expectedHeader.requestsHash, "Requests hash mismatch");
    }
}
