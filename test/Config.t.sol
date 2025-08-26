// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;
pragma experimental ABIEncoderV2;

import {Test} from "../src/Test.sol";
import {Config} from "../src/Config.sol";
import {StdConfig} from "../src/StdConfig.sol";
import {Variable, LibVariable} from "../src/LibVariable.sol";

contract ConfigTest is Test, Config {
    function test_loadConfig() public {
        // Deploy the config contract with the test fixture.
        _loadConfig("./test/fixtures/config.toml");

        // -- MAINNET --------------------------------------------------------------

        // Read and assert RPC URL for Mainnet (chain ID 1)
        assertEq(config.getRpcUrl(1), "https://eth.llamarpc.com");

        // Read and assert boolean values
        assertTrue(config.get(1, "is_live").toBool());
        bool[] memory bool_array = config.get(1, "bool_array").toBoolArray();
        assertTrue(bool_array[0]);
        assertFalse(bool_array[1]);

        // Read and assert address values
        assertEq(config.get(1, "weth").toAddress(), 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
        address[] memory address_array = config.get(1, "deps").toAddressArray();
        assertEq(address_array[0], 0x0000000000000000000000000000000000000000);
        assertEq(address_array[1], 0x1111111111111111111111111111111111111111);

        // Read and assert uint values
        assertEq(config.get(1, "number").toUint(), 1234);
        uint256[] memory uint_array = config.get(1, "number_array").toUintArray();
        assertEq(uint_array[0], 5678);
        assertEq(uint_array[1], 9999);

        // Read and assert bytes32 values
        assertEq(config.get(1, "word").toBytes32(), bytes32(uint256(1234)));
        bytes32[] memory bytes32_array = config.get(1, "word_array").toBytes32Array();
        assertEq(bytes32_array[0], bytes32(uint256(5678)));
        assertEq(bytes32_array[1], bytes32(uint256(9999)));

        // Read and assert bytes values
        assertEq(config.get(1, "b").toBytes(), hex"abcd");
        bytes[] memory bytes_array = config.get(1, "b_array").toBytesArray();
        assertEq(bytes_array[0], hex"dead");
        assertEq(bytes_array[1], hex"beef");

        // Read and assert string values
        assertEq(config.get(1, "str").toString(), "foo");
        string[] memory string_array = config.get(1, "str_array").toStringArray();
        assertEq(string_array[0], "bar");
        assertEq(string_array[1], "baz");

        // -- OPTIMISM ------------------------------------------------------------

        // Read and assert RPC URL for Optimism (chain ID 10)
        assertEq(config.getRpcUrl(10), "https://mainnet.optimism.io");

        // Read and assert boolean values
        assertFalse(config.get(10, "is_live").toBool());
        bool_array = config.get(10, "bool_array").toBoolArray();
        assertFalse(bool_array[0]);
        assertTrue(bool_array[1]);

        // Read and assert address values
        assertEq(config.get(10, "weth").toAddress(), 0x4200000000000000000000000000000000000006);
        address_array = config.get(10, "deps").toAddressArray();
        assertEq(address_array[0], 0x2222222222222222222222222222222222222222);
        assertEq(address_array[1], 0x3333333333333333333333333333333333333333);

        // Read and assert uint values
        assertEq(config.get(10, "number").toUint(), 9999);
        uint_array = config.get(10, "number_array").toUintArray();
        assertEq(uint_array[0], 1234);
        assertEq(uint_array[1], 5678);

        // Read and assert bytes32 values
        assertEq(config.get(10, "word").toBytes32(), bytes32(uint256(9999)));
        bytes32_array = config.get(10, "word_array").toBytes32Array();
        assertEq(bytes32_array[0], bytes32(uint256(1234)));
        assertEq(bytes32_array[1], bytes32(uint256(5678)));

        // Read and assert bytes values
        assertEq(config.get(10, "b").toBytes(), hex"dcba");
        bytes_array = config.get(10, "b_array").toBytesArray();
        assertEq(bytes_array[0], hex"c0ffee");
        assertEq(bytes_array[1], hex"babe");

        // Read and assert string values
        assertEq(config.get(10, "str").toString(), "alice");
        string_array = config.get(10, "str_array").toStringArray();
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

        assertFalse(config.get(1, "is_live").toBool());

        string memory content = vm.readFile(testConfig);
        assertFalse(vm.parseTomlBool(content, "$.mainnet.bool.is_live"));

        // Update a single address value and verify the change.
        address new_addr = 0xDeaDbeefdEAdbeefdEadbEEFdeadbeEFdEaDbeeF;
        config.set(1, "weth", new_addr, true);

        assertEq(config.get(1, "weth").toAddress(), new_addr);

        content = vm.readFile(testConfig);
        assertEq(vm.parseTomlAddress(content, "$.mainnet.address.weth"), new_addr);

        // Update a uint array and verify the change.
        uint256[] memory new_numbers = new uint256[](3);
        new_numbers[0] = 1;
        new_numbers[1] = 2;
        new_numbers[2] = 3;
        config.set(10, "number_array", new_numbers, true);

        uint256[] memory updated_numbers_mem = config.get(10, "number_array").toUintArray();
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

        string[] memory updated_strings_mem = config.get(1, "str_array").toStringArray();
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

        assertEq(config.get(1, "new_uint").toUint(), 42);

        content = vm.readFile(testConfig);
        assertEq(vm.parseTomlUint(content, "$.mainnet.uint.new_uint"), 42);

        // Create a new bytes32 array and verify the change.
        bytes32[] memory new_words = new bytes32[](2);
        new_words[0] = bytes32(uint256(0xDEAD));
        new_words[1] = bytes32(uint256(0xBEEF));
        config.set(10, "new_words", new_words, true);

        bytes32[] memory updated_words_mem = config.get(10, "new_words").toBytes32Array();
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

    function testRevert_InvalidChainKey() public {
        // Create a fixture with an invalid chain key
        string memory invalidChainConfig = "./test/fixtures/config_invalid_chain.toml";
        vm.writeFile(
            invalidChainConfig,
            string(
                abi.encodePacked(
                    "[mainnet]\n",
                    "endpoint_url = \"https://eth.llamarpc.com\"\n",
                    "\n",
                    "[mainnet.uint]\n",
                    "valid_number = 123\n",
                    "\n",
                    "# Invalid chain key (not a number and not a valid alias)\n",
                    "[invalid_chain]\n",
                    "endpoint_url = \"https://invalid.com\"\n",
                    "\n",
                    "[invalid_chain_9999.uint]\n",
                    "some_value = 456\n"
                )
            )
        );

        vm.expectRevert(abi.encodeWithSelector(StdConfig.InvalidChainKey.selector, "invalid_chain"));
        new StdConfig(invalidChainConfig);
        vm.removeFile(invalidChainConfig);
    }

    function testRevert_ChainIdNotFound() public {
        _loadConfig("./test/fixtures/config.toml");

        // Try to write a value for a non-existent chain ID
        vm.expectRevert(abi.encodeWithSelector(StdConfig.ChainIdNotFound.selector, uint256(999999)));
        config.set(999999, "some_key", uint256(123), true);
    }

    function testRevert_UnableToParseVariable() public {
        // Create a fixture with an unparseable variable
        string memory badParseConfig = "./test/fixtures/config_bad_parse.toml";
        vm.writeFile(
            badParseConfig,
            string(
                abi.encodePacked(
                    "[mainnet]\n",
                    "endpoint_url = \"https://eth.llamarpc.com\"\n",
                    "\n",
                    "[mainnet.uint]\n",
                    "bad_value = \"not_a_number\"\n"
                )
            )
        );

        vm.expectRevert(abi.encodeWithSelector(StdConfig.UnableToParseVariable.selector, "bad_value"));
        new StdConfig(badParseConfig);
        vm.removeFile(badParseConfig);
    }
}

/// @dev We must use an external helper contract to ensure proper call depth for `vm.expectRevert`,
///      as direct library calls are inlined by the compiler, causing call depth issues.
contract LibVariableTest is Test, Config {
    LibVariableHelper helper;

    function setUp() public {
        helper = new LibVariableHelper();
        _loadConfig("./test/fixtures/config.toml");
    }

    function testRevert_NotInitialized() public {
        // Try to read a non-existent variable
        Variable memory notInit = config.get(1, "non_existent_key");

        // Test single value types - should revert with NotInitialized
        vm.expectRevert(LibVariable.NotInitialized.selector);
        helper.toBool(notInit);

        vm.expectRevert(LibVariable.NotInitialized.selector);
        helper.toUint(notInit);

        vm.expectRevert(LibVariable.NotInitialized.selector);
        helper.toAddress(notInit);

        vm.expectRevert(LibVariable.NotInitialized.selector);
        helper.toBytes32(notInit);

        vm.expectRevert(LibVariable.NotInitialized.selector);
        helper.toString(notInit);

        vm.expectRevert(LibVariable.NotInitialized.selector);
        helper.toBytes(notInit);

        // Test array types - should also revert with NotInitialized
        vm.expectRevert(LibVariable.NotInitialized.selector);
        helper.toBoolArray(notInit);

        vm.expectRevert(LibVariable.NotInitialized.selector);
        helper.toUintArray(notInit);

        vm.expectRevert(LibVariable.NotInitialized.selector);
        helper.toAddressArray(notInit);

        vm.expectRevert(LibVariable.NotInitialized.selector);
        helper.toBytes32Array(notInit);

        vm.expectRevert(LibVariable.NotInitialized.selector);
        helper.toStringArray(notInit);

        vm.expectRevert(LibVariable.NotInitialized.selector);
        helper.toBytesArray(notInit);
    }

    function testRevert_TypeMismatch() public {
        // Get a boolean variable
        Variable memory boolVar = config.get(1, "is_live");

        // Try to coerce it to wrong single value types - should revert with TypeMismatch
        vm.expectRevert(abi.encodeWithSelector(LibVariable.TypeMismatch.selector, "uint256", "bool"));
        helper.toUint(boolVar);

        vm.expectRevert(abi.encodeWithSelector(LibVariable.TypeMismatch.selector, "address", "bool"));
        helper.toAddress(boolVar);

        vm.expectRevert(abi.encodeWithSelector(LibVariable.TypeMismatch.selector, "bytes32", "bool"));
        helper.toBytes32(boolVar);

        vm.expectRevert(abi.encodeWithSelector(LibVariable.TypeMismatch.selector, "string", "bool"));
        helper.toString(boolVar);

        vm.expectRevert(abi.encodeWithSelector(LibVariable.TypeMismatch.selector, "bytes", "bool"));
        helper.toBytes(boolVar);

        // Get a uint variable
        Variable memory uintVar = config.get(1, "number");

        // Try to coerce it to wrong types
        vm.expectRevert(abi.encodeWithSelector(LibVariable.TypeMismatch.selector, "bool", "uint256"));
        helper.toBool(uintVar);

        vm.expectRevert(abi.encodeWithSelector(LibVariable.TypeMismatch.selector, "address", "uint256"));
        helper.toAddress(uintVar);

        // Get an array variable
        Variable memory boolArrayVar = config.get(1, "bool_array");

        // Try to coerce array to single value - should revert with TypeMismatch
        vm.expectRevert(abi.encodeWithSelector(LibVariable.TypeMismatch.selector, "bool", "bool[]"));
        helper.toBool(boolArrayVar);

        // Try to coerce array to wrong array type
        vm.expectRevert(abi.encodeWithSelector(LibVariable.TypeMismatch.selector, "uint256[]", "bool[]"));
        helper.toUintArray(boolArrayVar);

        // Get a single value and try to coerce to array
        Variable memory singleBoolVar = config.get(1, "is_live");

        vm.expectRevert(abi.encodeWithSelector(LibVariable.TypeMismatch.selector, "bool[]", "bool"));
        helper.toBoolArray(singleBoolVar);
    }
}

/// @dev We must use an external helper contract to ensure proper call depth for `vm.expectRevert`,
///      as direct library calls are inlined by the compiler, causing call depth issues.
contract LibVariableHelper {
    function toBool(Variable memory v) external pure returns (bool) {
        return v.toBool();
    }

    function toUint(Variable memory v) external pure returns (uint256) {
        return v.toUint();
    }

    function toAddress(Variable memory v) external pure returns (address) {
        return v.toAddress();
    }

    function toBytes32(Variable memory v) external pure returns (bytes32) {
        return v.toBytes32();
    }

    function toString(Variable memory v) external pure returns (string memory) {
        return v.toString();
    }

    function toBytes(Variable memory v) external pure returns (bytes memory) {
        return v.toBytes();
    }

    function toBoolArray(Variable memory v) external pure returns (bool[] memory) {
        return v.toBoolArray();
    }

    function toUintArray(Variable memory v) external pure returns (uint256[] memory) {
        return v.toUintArray();
    }

    function toAddressArray(Variable memory v) external pure returns (address[] memory) {
        return v.toAddressArray();
    }

    function toBytes32Array(Variable memory v) external pure returns (bytes32[] memory) {
        return v.toBytes32Array();
    }

    function toStringArray(Variable memory v) external pure returns (string[] memory) {
        return v.toStringArray();
    }

    function toBytesArray(Variable memory v) external pure returns (bytes[] memory) {
        return v.toBytesArray();
    }
}
