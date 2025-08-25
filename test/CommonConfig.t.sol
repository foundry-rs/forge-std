// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;
pragma experimental ABIEncoderV2;

import {Test} from "../src/Test.sol";

contract CommonConfigTest is Test {
    function test_loadConfig() public {
        // Deploy the config contract with the test fixture.
        _loadConfig("./test/fixtures/config.toml");

        // -- MAINNET --------------------------------------------------------------

        // Read and assert RPC URL for Mainnet (chain ID 1)
        assertEq(config.getRpcUrl(1), "https://eth.llamarpc.com");

        // Read and assert boolean values
        assertTrue(config.getBool(1, "is_live"));
        bool[] memory bool_array = config.getBoolArray(1, "bool_array");
        assertTrue(bool_array[0]);
        assertFalse(bool_array[1]);

        // Read and assert address values
        assertEq(config.getAddress(1, "weth"), 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
        address[] memory address_array = config.getAddressArray(1, "deps");
        assertEq(address_array[0], 0x0000000000000000000000000000000000000000);
        assertEq(address_array[1], 0x1111111111111111111111111111111111111111);

        // Read and assert uint values
        assertEq(config.getUint(1, "number"), 1234);
        uint256[] memory uint_array = config.getUintArray(1, "number_array");
        assertEq(uint_array[0], 5678);
        assertEq(uint_array[1], 9999);

        // Read and assert bytes32 values
        assertEq(config.getBytes32(1, "word"), bytes32(uint256(1234)));
        bytes32[] memory bytes32_array = config.getBytes32Array(1, "word_array");
        assertEq(bytes32_array[0], bytes32(uint256(5678)));
        assertEq(bytes32_array[1], bytes32(uint256(9999)));

        // Read and assert bytes values
        assertEq(config.getBytes(1, "b"), hex"abcd");
        bytes[] memory bytes_array = config.getBytesArray(1, "b_array");
        assertEq(bytes_array[0], hex"dead");
        assertEq(bytes_array[1], hex"beef");

        // Read and assert string values
        assertEq(config.getString(1, "str"), "foo");
        string[] memory string_array = config.getStringArray(1, "str_array");
        assertEq(string_array[0], "bar");
        assertEq(string_array[1], "baz");

        // -- OPTIMISM -------------------------------------------------------------

        // Read and assert RPC URL for Optimism (chain ID 10)
        assertEq(config.getRpcUrl(10), "https://mainnet.optimism.io");

        // Read and assert boolean values
        assertFalse(config.getBool(10, "is_live"));
        bool_array = config.getBoolArray(10, "bool_array");
        assertFalse(bool_array[0]);
        assertTrue(bool_array[1]);

        // Read and assert address values
        assertEq(config.getAddress(10, "weth"), 0x4200000000000000000000000000000000000006);
        address_array = config.getAddressArray(10, "deps");
        assertEq(address_array[0], 0x2222222222222222222222222222222222222222);
        assertEq(address_array[1], 0x3333333333333333333333333333333333333333);

        // Read and assert uint values
        assertEq(config.getUint(10, "number"), 9999);
        uint_array = config.getUintArray(10, "number_array");
        assertEq(uint_array[0], 1234);
        assertEq(uint_array[1], 5678);

        // Read and assert bytes32 values
        assertEq(config.getBytes32(10, "word"), bytes32(uint256(9999)));
        bytes32_array = config.getBytes32Array(10, "word_array");
        assertEq(bytes32_array[0], bytes32(uint256(1234)));
        assertEq(bytes32_array[1], bytes32(uint256(5678)));

        // Read and assert bytes values
        assertEq(config.getBytes(10, "b"), hex"dcba");
        bytes_array = config.getBytesArray(10, "b_array");
        assertEq(bytes_array[0], hex"c0ffee");
        assertEq(bytes_array[1], hex"babe");

        // Read and assert string values
        assertEq(config.getString(10, "str"), "alice");
        string_array = config.getStringArray(10, "str_array");
        assertEq(string_array[0], "bob");
        assertEq(string_array[1], "charlie");
    }

    function test_loadConfigAndForks() public {
        _loadConfigAndForks("./test/fixtures/config.toml");

        // assert that the map of chain id and fork ids is created and that the chain ids actually match
        assertEq(forkOf[1], 0);
        vm.selectFork(forkOf[1]);
        assertEq(vm.getChainId(), 1);

        assertEq(forkOf[10], 1);
        vm.selectFork(forkOf[10]);
        assertEq(vm.getChainId(), 10);
    }

    function test_writeConfig() public {
        // Create a temporary copy of the config file to avoid modifying the original.
        string memory originalConfig = "./test/fixtures/config.toml";
        string memory testConfig = "./test/fixtures/config.t.toml";
        vm.copyFile(originalConfig, testConfig);

        // Deploy the config contract with the temporary fixture.
        _loadConfig(testConfig);

        // Update a single boolean value and verify the change.
        config.set(1, "is_live", false, true);

        assertFalse(config.getBool(1, "is_live"));

        string memory content = vm.readFile(testConfig);
        assertFalse(vm.parseTomlBool(content, "$.mainnet.bool.is_live"));

        // Update a single address value and verify the change.
        address new_addr = 0xDeaDbeefdEAdbeefdEadbEEFdeadbeEFdEaDbeeF;
        config.set(1, "weth", new_addr, true);

        assertEq(config.getAddress(1, "weth"), new_addr);

        content = vm.readFile(testConfig);
        assertEq(vm.parseTomlAddress(content, "$.mainnet.address.weth"), new_addr);

        // Update a uint array and verify the change.
        uint256[] memory new_numbers = new uint256[](3);
        new_numbers[0] = 1;
        new_numbers[1] = 2;
        new_numbers[2] = 3;
        config.set(10, "number_array", new_numbers, true);

        uint256[] memory updated_numbers_mem = config.getUintArray(10, "number_array");
        assertEq(updated_numbers_mem.length, 3);
        assertEq(updated_numbers_mem[0], 1);
        assertEq(updated_numbers_mem[1], 2);
        assertEq(updated_numbers_mem[2], 3);

        content = vm.readFile(testConfig);
        uint256[] memory updated_numbers_disk = vm.parseTomlUintArray(content, "$.optimism.uint.number_array");
        assertEq(updated_numbers_disk.length, 3);
        assertEq(updated_numbers_disk[0], 1);
        assertEq(updated_numbers_disk[1], 2);
        assertEq(updated_numbers_disk[2], 3);

        // Update a string array and verify the change.
        string[] memory new_strings = new string[](2);
        new_strings[0] = "hello";
        new_strings[1] = "world";
        config.set(1, "str_array", new_strings, true);

        string[] memory updated_strings_mem = config.getStringArray(1, "str_array");
        assertEq(updated_strings_mem.length, 2);
        assertEq(updated_strings_mem[0], "hello");
        assertEq(updated_strings_mem[1], "world");

        content = vm.readFile(testConfig);
        string[] memory updated_strings_disk = vm.parseTomlStringArray(content, "$.mainnet.string.str_array");
        assertEq(updated_strings_disk.length, 2);
        assertEq(updated_strings_disk[0], "hello");
        assertEq(updated_strings_disk[1], "world");

        // Create a new uint variable and verify the change.
        config.set(1, "new_uint", 42, true);

        assertEq(config.getUint(1, "new_uint"), 42);

        content = vm.readFile(testConfig);
        assertEq(vm.parseTomlUint(content, "$.mainnet.uint.new_uint"), 42);

        // Create a new bytes32 array and verify the change.
        bytes32[] memory new_words = new bytes32[](2);
        new_words[0] = bytes32(uint256(0xDEAD));
        new_words[1] = bytes32(uint256(0xBEEF));
        config.set(10, "new_words", new_words, true);

        bytes32[] memory updated_words_mem = config.getBytes32Array(10, "new_words");
        assertEq(updated_words_mem.length, 2);
        assertEq(updated_words_mem[0], new_words[0]);
        assertEq(updated_words_mem[1], new_words[1]);

        content = vm.readFile(testConfig);
        bytes32[] memory updated_words_disk = vm.parseTomlBytes32Array(content, "$.optimism.bytes32.new_words");
        assertEq(updated_words_disk.length, 2);
        assertEq(vm.toString(updated_words_disk[0]), vm.toString(new_words[0]));
        assertEq(vm.toString(updated_words_disk[1]), vm.toString(new_words[1]));

        // Clean up the temporary file.
        vm.removeFile(testConfig);
    }
}
