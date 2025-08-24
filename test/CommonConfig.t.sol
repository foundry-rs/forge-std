// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import {Test} from "../src/Test.sol";

contract CommonConfigTest is Test {
function test_loadConfig() public {
    // Deploy the config contract with the test fixture.
    _loadConfig("./test/fixtures/config.toml");

    // -- MAINNET --------------------------------------------------------------

    // Read and assert RPC URL for Mainnet (chain ID 1)
    assertEq(config.readRpcUrl(1), "https://eth.llamarpc.com");

    // Read and assert boolean values
    assertTrue(config.readBool(1, "is_live"));
    bool[] memory bool_array = config.readBoolArray(1, "bool_array");
    assertTrue(bool_array[0]);
    assertFalse(bool_array[1]);

    // Read and assert address values
    assertEq(config.readAddress(1, "weth"), 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address[] memory address_array = config.readAddressArray(1, "deps");
    assertEq(address_array[0], 0x0000000000000000000000000000000000000000);
    assertEq(address_array[1], 0x1111111111111111111111111111111111111111);

    // Read and assert uint values
    assertEq(config.readUint(1, "number"), 1234);
    uint256[] memory uint_array = config.readUintArray(1, "number_array");
    assertEq(uint_array[0], 5678);
    assertEq(uint_array[1], 9999);

    // Read and assert bytes32 values
    assertEq(config.readBytes32(1, "word"), bytes32(uint256(1234)));
    bytes32[] memory bytes32_array = config.readBytes32Array(1, "word_array");
    assertEq(bytes32_array[0], bytes32(uint256(5678)));
    assertEq(bytes32_array[1], bytes32(uint256(9999)));

    // Read and assert bytes values
    assertEq(config.readBytes(1, "b"), hex"abcd");
    bytes[] memory bytes_array = config.readBytesArray(1, "b_array");
    assertEq(bytes_array[0], hex"dead");
    assertEq(bytes_array[1], hex"beef");

    // Read and assert string values
    assertEq(config.readString(1, "str"), "foo");
    string[] memory string_array = config.readStringArray(1, "str_array");
    assertEq(string_array[0], "bar");
    assertEq(string_array[1], "baz");

    // -- OPTIMISM -------------------------------------------------------------

    // Read and assert RPC URL for Optimism (chain ID 10)
    assertEq(config.readRpcUrl(10), "https://mainnet.optimism.io");

    // Read and assert boolean values
    assertFalse(config.readBool(10, "is_live"));
    bool_array = config.readBoolArray(10, "bool_array");
    assertFalse(bool_array[0]);
    assertTrue(bool_array[1]);

    // Read and assert address values
    assertEq(config.readAddress(10, "weth"), 0x4200000000000000000000000000000000000006);
    address_array = config.readAddressArray(10, "deps");
    assertEq(address_array[0], 0x2222222222222222222222222222222222222222);
    assertEq(address_array[1], 0x3333333333333333333333333333333333333333);

    // Read and assert uint values
    assertEq(config.readUint(10, "number"), 9999);
    uint_array = config.readUintArray(10, "number_array");
    assertEq(uint_array[0], 1234);
    assertEq(uint_array[1], 5678);

    // Read and assert bytes32 values
    assertEq(config.readBytes32(10, "word"), bytes32(uint256(9999)));
    bytes32_array = config.readBytes32Array(10, "word_array");
    assertEq(bytes32_array[0], bytes32(uint256(1234)));
    assertEq(bytes32_array[1], bytes32(uint256(5678)));

    // Read and assert bytes values
    assertEq(config.readBytes(10, "b"), hex"dcba");
    bytes_array = config.readBytesArray(10, "b_array");
    assertEq(bytes_array[0], hex"c0ffee");
    assertEq(bytes_array[1], hex"babe");

    // Read and assert string values
    assertEq(config.readString(10, "str"), "alice");
    string_array = config.readStringArray(10, "str_array");
    assertEq(string_array[0], "bob");
    assertEq(string_array[1], "charlie");
}


    function test_loadConfigAndForks() public {
        _loadConfigAndForks("./test/fixtures/config.toml");

        // assert that the map of chain id and fork ids is created and that the chain ids actually match
        assertEq(forkOf[1], 0);
        vm.selectFork(forkOf[1]);
        assertEq(vm.activeChain(), 1);

        assertEq(forkOf[10], 1);
        vm.selectFork(forkOf[10]);
        assertEq(vm.activeChain(), 10);
    }
}
