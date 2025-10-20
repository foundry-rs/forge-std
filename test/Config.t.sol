// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "../src/Test.sol";
import {VmSafe} from "../src/Vm.sol";
import {Config} from "../src/Config.sol";
import {StdConfig} from "../src/StdConfig.sol";
import {ConfigView, LibConfigView} from "../src/LibConfigView.sol";

contract ConfigTest is Test, Config {
    using LibConfigView for ConfigView;
    function setUp() public {
        vm.setEnv("MAINNET_RPC", "https://eth.llamarpc.com");
        vm.setEnv("WETH_MAINNET", "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2");
        vm.setEnv("OPTIMISM_RPC", "https://mainnet.optimism.io");
        vm.setEnv("WETH_OPTIMISM", "0x4200000000000000000000000000000000000006");
    }

    function _endsWith(string memory str, string memory suffix) internal pure returns (bool) {
        bytes memory strBytes = bytes(str);
        bytes memory suffixBytes = bytes(suffix);

        if (suffixBytes.length > strBytes.length) {
            return false;
        }

        uint256 offset = strBytes.length - suffixBytes.length;
        for (uint256 i = 0; i < suffixBytes.length; i++) {
            if (strBytes[offset + i] != suffixBytes[i]) {
                return false;
            }
        }
        return true;
    }

    function getArtifactPath(
        uint256 chainId,
        string memory contractFile,
        string memory contractName
    ) external view returns (string memory) {
        return _getArtifactPath(chainId, contractFile, contractName);
    }

    function getRpcUrl(uint256 chainId) external view returns (string memory) {
        return _getRpcUrl(chainId);
    }

    function _createMinimalSingleChainConfig(
        string memory path,
        string memory chainKey,
        string memory profileName
    ) internal {
        vm.writeFile(
            path,
            string.concat(
                "[", chainKey, "]\n",
                "endpoint_url = \"${MAINNET_RPC}\"\n",
                "profile = \"", profileName, "\"\n\n",
                "[", chainKey, ".bool]\n",
                "is_live = true\n"
            )
        );
    }

    function _createFullSingleChainConfig(
        string memory path,
        string memory chainKey,
        string memory profileName
    ) internal {
        vm.writeFile(
            path,
            string.concat(
                "[", chainKey, "]\n",
                "endpoint_url = \"${MAINNET_RPC}\"\n",
                "profile = \"", profileName, "\"\n\n",
                "[", chainKey, ".bool]\n",
                "is_live = true\n",
                "bool_array = [true, false]\n\n",
                "[", chainKey, ".address]\n",
                "weth = \"${WETH_MAINNET}\"\n",
                "deps = [\n",
                "    \"0x0000000000000000000000000000000000000000\",\n",
                "    \"0x1111111111111111111111111111111111111111\",\n",
                "]\n\n",
                "[", chainKey, ".uint]\n",
                "number = 1234\n",
                "number_array = [5678, 9999]\n\n",
                "[", chainKey, ".int]\n",
                "signed_number = -1234\n",
                "signed_number_array = [-5678, 9999]\n\n",
                "[", chainKey, ".bytes32]\n",
                "word = \"0x00000000000000000000000000000000000000000000000000000000000004d2\"\n",
                "word_array = [\n",
                "    \"0x000000000000000000000000000000000000000000000000000000000000162e\",\n",
                "    \"0x000000000000000000000000000000000000000000000000000000000000270f\",\n",
                "]\n\n",
                "[", chainKey, ".bytes]\n",
                "b = \"0xabcd\"\n",
                "b_array = [\"0xdead\", \"0xbeef\"]\n\n",
                "[", chainKey, ".string]\n",
                "str = \"foo\"\n",
                "str_array = [\"bar\", \"baz\"]\n"
            )
        );
    }

    function _createInvalidChainConfig(string memory path) internal {
        vm.writeFile(
            path,
            string.concat(
                "[mainnet]\n",
                "endpoint_url = \"https://eth.llamarpc.com\"\n",
                "profile = \"shanghai\"\n",
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
        );
    }

    function _createUnparsableConfig(string memory path) internal {
        vm.writeFile(
            path,
            string.concat(
                "[mainnet]\n",
                "endpoint_url = \"https://eth.llamarpc.com\"\n",
                "profile = \"shanghai\"\n",
                "\n",
                "[mainnet.uint]\n",
                "bad_value = \"not_a_number\"\n"
            )
        );
    }

    function test_loadConfig() public {
        string memory singleChainConfig = "./test/fixtures/config_single_chain.toml";
        _createFullSingleChainConfig(singleChainConfig, "mainnet", "shanghai");
        loadConfig(singleChainConfig, false);

        // -- MAINNET (single chain) -----------------------------------------------

        assertEq(_chainConfig[1].getRpcUrl(1), "https://eth.llamarpc.com");

        assertTrue(_chainConfig[1].get(1, "is_live").toBool());
        bool[] memory bool_array = _chainConfig[1].get(1, "bool_array").toBoolArray();
        assertTrue(bool_array[0]);
        assertFalse(bool_array[1]);

        assertEq(_chainConfig[1].get(1, "weth").toAddress(), 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
        address[] memory address_array = _chainConfig[1].get(1, "deps").toAddressArray();
        assertEq(address_array[0], 0x0000000000000000000000000000000000000000);
        assertEq(address_array[1], 0x1111111111111111111111111111111111111111);

        assertEq(_chainConfig[1].get(1, "word").toBytes32(), bytes32(uint256(1234)));
        bytes32[] memory bytes32_array = _chainConfig[1].get(1, "word_array").toBytes32Array();
        assertEq(bytes32_array[0], bytes32(uint256(5678)));
        assertEq(bytes32_array[1], bytes32(uint256(9999)));

        assertEq(_chainConfig[1].get(1, "number").toUint256(), 1234);
        uint256[] memory uint_array = _chainConfig[1].get(1, "number_array").toUint256Array();
        assertEq(uint_array[0], 5678);
        assertEq(uint_array[1], 9999);

        assertEq(_chainConfig[1].get(1, "signed_number").toInt256(), -1234);
        int256[] memory int_array = _chainConfig[1].get(1, "signed_number_array").toInt256Array();
        assertEq(int_array[0], -5678);
        assertEq(int_array[1], 9999);

        assertEq(_chainConfig[1].get(1, "b").toBytes(), hex"abcd");
        bytes[] memory bytes_array = _chainConfig[1].get(1, "b_array").toBytesArray();
        assertEq(bytes_array[0], hex"dead");
        assertEq(bytes_array[1], hex"beef");

        assertEq(_chainConfig[1].get(1, "str").toString(), "foo");
        string[] memory string_array = _chainConfig[1].get(1, "str_array").toStringArray();
        assertEq(string_array[0], "bar");
        assertEq(string_array[1], "baz");

        vm.removeFile(singleChainConfig);
    }

    function test_loadConfigAndForks() public {
        loadConfigAndForks("./test/fixtures/config.toml", false);

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
        // Use loadConfigAndForks since this test accesses both chains
        loadConfigAndForks(testConfig, false);

        // Enable writing to file bypassing the context check for both StdConfig instances.
        vm.store(address(_chainConfig[1]), bytes32(uint256(7)), bytes32(uint256(1)));  // Shanghai StdConfig
        vm.store(address(_chainConfig[10]), bytes32(uint256(7)), bytes32(uint256(1))); // Cancun StdConfig

        {
            _chainConfig[1].set(1, "is_live", false);

            assertFalse(_chainConfig[1].get(1, "is_live").toBool());

            string memory content = vm.readFile(testConfig);
            assertFalse(vm.parseTomlBool(content, "$.mainnet.bool.is_live"));

            address new_addr = 0xDeaDbeefdEAdbeefdEadbEEFdeadbeEFdEaDbeeF;
            _chainConfig[1].set(1, "weth", new_addr);

            assertEq(_chainConfig[1].get(1, "weth").toAddress(), new_addr);

            content = vm.readFile(testConfig);
            assertEq(vm.parseTomlAddress(content, "$.mainnet.address.weth"), new_addr);

            uint256[] memory new_numbers = new uint256[](3);
            new_numbers[0] = 1;
            new_numbers[1] = 2;
            new_numbers[2] = 3;
            _chainConfig[10].set(10, "number_array", new_numbers);

            uint256[] memory updated_numbers_mem = _chainConfig[10].get(10, "number_array").toUint256Array();
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

            string[] memory new_strings = new string[](2);
            new_strings[0] = "hello";
            new_strings[1] = "world";
            _chainConfig[1].set(1, "str_array", new_strings);

            string[] memory updated_strings_mem = _chainConfig[1].get(1, "str_array").toStringArray();
            assertEq(updated_strings_mem.length, 2);
            assertEq(updated_strings_mem[0], "hello");
            assertEq(updated_strings_mem[1], "world");

            content = vm.readFile(testConfig);
            string[] memory updated_strings_disk = vm.parseTomlStringArray(content, "$.mainnet.string.str_array");
            assertEq(updated_strings_disk.length, 2);
            assertEq(updated_strings_disk[0], "hello");
            assertEq(updated_strings_disk[1], "world");

            _chainConfig[1].set(1, "new_uint", uint256(42));

            assertEq(_chainConfig[1].get(1, "new_uint").toUint256(), 42);

            content = vm.readFile(testConfig);
            assertEq(vm.parseTomlUint(content, "$.mainnet.uint.new_uint"), 42);

            _chainConfig[1].set(1, "new_int", int256(-42));

            assertEq(_chainConfig[1].get(1, "new_int").toInt256(), -42);

            content = vm.readFile(testConfig);
            assertEq(vm.parseTomlInt(content, "$.mainnet.int.new_int"), -42);

            int256[] memory new_ints = new int256[](2);
            new_ints[0] = -100;
            new_ints[1] = 200;
            _chainConfig[10].set(10, "new_ints", new_ints);

            int256[] memory updated_ints_mem = _chainConfig[10].get(10, "new_ints").toInt256Array();
            assertEq(updated_ints_mem.length, 2);
            assertEq(updated_ints_mem[0], -100);
            assertEq(updated_ints_mem[1], 200);

            content = vm.readFile(testConfig);
            int256[] memory updated_ints_disk = vm.parseTomlIntArray(content, "$.optimism.int.new_ints");
            assertEq(updated_ints_disk.length, 2);
            assertEq(updated_ints_disk[0], -100);
            assertEq(updated_ints_disk[1], 200);

            bytes32[] memory new_words = new bytes32[](2);
            new_words[0] = bytes32(uint256(0xDEAD));
            new_words[1] = bytes32(uint256(0xBEEF));
            _chainConfig[10].set(10, "new_words", new_words);

            bytes32[] memory updated_words_mem = _chainConfig[10].get(10, "new_words").toBytes32Array();
            assertEq(updated_words_mem.length, 2);
            assertEq(updated_words_mem[0], new_words[0]);
            assertEq(updated_words_mem[1], new_words[1]);

            content = vm.readFile(testConfig);
            bytes32[] memory updated_words_disk = vm.parseTomlBytes32Array(content, "$.optimism.bytes32.new_words");
            assertEq(updated_words_disk.length, 2);
            assertEq(vm.toString(updated_words_disk[0]), vm.toString(new_words[0]));
            assertEq(vm.toString(updated_words_disk[1]), vm.toString(new_words[1]));
        }

        vm.removeFile(testConfig);
    }

    function test_writeUpdatesBackToFile() public {
        string memory testConfig = "./test/fixtures/write_config.t.toml";
        _createMinimalSingleChainConfig(testConfig, "mainnet", "shanghai");
        loadConfig(testConfig, false);

        // Update a single boolean value and verify the file is NOT changed.
        _chainConfig[1].set(1, "is_live", false);
        string memory content = vm.readFile(testConfig);
        assertTrue(vm.parseTomlBool(content, "$.mainnet.bool.is_live"), "File should not be updated yet");

        // Enable writing to file bypassing the context check.
        vm.store(address(_chainConfig[1]), bytes32(uint256(7)), bytes32(uint256(1)));

        // Update the value again and verify the file IS changed.
        _chainConfig[1].set(1, "is_live", false);
        content = vm.readFile(testConfig);
        assertFalse(vm.parseTomlBool(content, "$.mainnet.bool.is_live"), "File should be updated now");

        // Disable writing to file.
        _chainConfig[1].writeUpdatesBackToFile(false);

        // Update the value again and verify the file is NOT changed.
        _chainConfig[1].set(1, "is_live", true);
        content = vm.readFile(testConfig);
        assertFalse(vm.parseTomlBool(content, "$.mainnet.bool.is_live"), "File should not be updated again");

        vm.removeFile(testConfig);
    }

    function testRevert_WriteToFileInForbiddenCtxt() public {
        string memory singleChainConfig = "./test/fixtures/config_write_forbidden.toml";
        _createMinimalSingleChainConfig(singleChainConfig, "mainnet", "shanghai");

        // Cannot initialize enabling writing to file unless we are in SCRIPT mode.
        vm.expectRevert(StdConfig.WriteToFileInForbiddenCtxt.selector);
        loadConfig(singleChainConfig, true);

        // Initialize with `writeToFile = false`.
        loadConfig(singleChainConfig, false);

        // Cannot enable writing to file unless we are in SCRIPT mode.
        vm.expectRevert(StdConfig.WriteToFileInForbiddenCtxt.selector);
        _chainConfig[1].writeUpdatesBackToFile(true);

        vm.removeFile(singleChainConfig);
    }

    function testRevert_InvalidChainKey() public {
        string memory invalidChainConfig = "./test/fixtures/config_invalid_chain.toml";
        _createInvalidChainConfig(invalidChainConfig);

        vm.expectRevert(abi.encodeWithSelector(StdConfig.InvalidChainKey.selector, "invalid_chain"));
        new StdConfig(invalidChainConfig, false, "shanghai");
        vm.removeFile(invalidChainConfig);
    }

    function testRevert_ChainNotInitialized() public {
        string memory singleChainConfig = "./test/fixtures/config_chain_init.toml";
        _createMinimalSingleChainConfig(singleChainConfig, "mainnet", "shanghai");
        loadConfig(singleChainConfig, false);

        // Enable writing to file bypassing the context check.
        vm.store(address(_chainConfig[1]), bytes32(uint256(7)), bytes32(uint256(1)));

        // Try to write a value for a non-existent chain ID through the shanghai StdConfig
        // This should fail because the shanghai StdConfig only manages chain 1, not chain 999999
        vm.expectRevert(abi.encodeWithSelector(StdConfig.ChainNotInitialized.selector, uint256(999999)));
        _chainConfig[1].set(999999, "some_key", uint256(123));

        vm.removeFile(singleChainConfig);
    }

    function testRevert_UnableToParseVariable() public {
        string memory badParseConfig = "./test/fixtures/config_bad_parse.toml";
        _createUnparsableConfig(badParseConfig);

        vm.expectRevert(abi.encodeWithSelector(StdConfig.UnableToParseVariable.selector, "bad_value"));
        new StdConfig(badParseConfig, false, "shanghai");
        vm.removeFile(badParseConfig);
    }

    // =========================================================================
    // MULTI-EVM PROFILE TESTS
    // =========================================================================

    function test_chainFilteringByEvmVersion() public {
        loadConfigAndForks("./test/fixtures/config.toml", false);

        // Verify shanghai StdConfig only contains mainnet (chain 1)
        uint256[] memory shanghaiChains = _chainConfig[1].getChainIds();
        assertEq(shanghaiChains.length, 1);
        assertEq(shanghaiChains[0], 1);

        // Verify cancun StdConfig only contains optimism (chain 10)
        uint256[] memory cancunChains = _chainConfig[10].getChainIds();
        assertEq(cancunChains.length, 1);
        assertEq(cancunChains[0], 10);

        // Verify that the two StdConfig instances are different
        assertTrue(
            address(_chainConfig[1]) != address(_chainConfig[10]),
            "Different EVM versions should have different StdConfig instances"
        );
    }

    function test_configViewCleanAPI() public {
        loadConfigAndForks("./test/fixtures/config.toml", false);

        bool isLiveOldWay = _chainConfig[1].get(1, "is_live").toBool();
        bool isLiveNewWay = configOf(1).get("is_live").toBool();
        address wethOldWay = _chainConfig[10].get(10, "weth").toAddress();
        address wethNewWay = configOf(10).get("weth").toAddress();

        // Both ways should return the same values
        assertEq(isLiveOldWay, isLiveNewWay);
        assertEq(wethOldWay, wethNewWay);

        assertTrue(isLiveNewWay);
        assertEq(wethNewWay, 0x4200000000000000000000000000000000000006);
    }

    function testRevert_crossChainAccessDifferentEvmVersions() public {
        loadConfigAndForks("./test/fixtures/config.toml", false);

        // Try to access chain 10 (cancun) through shanghai StdConfig (chain 1's instance)
        // This should revert with ChainNotInitialized because shanghai StdConfig doesn't manage chain 10
        vm.expectRevert(abi.encodeWithSelector(StdConfig.ChainNotInitialized.selector, uint256(10)));
        _chainConfig[1].get(10, "is_live");

        // Try to access chain 1 (shanghai) through cancun StdConfig (chain 10's instance)
        // This should revert with ChainNotInitialized because cancun StdConfig doesn't manage chain 1
        vm.expectRevert(abi.encodeWithSelector(StdConfig.ChainNotInitialized.selector, uint256(1)));
        _chainConfig[10].get(1, "is_live");
    }

    function test_loadConfigWithProfiles() public {
        // Use loadConfigAndForks since the fixture has multiple chains
        loadConfigAndForks("./test/fixtures/config.toml", false);

        // Verify profiles are cached correctly for each chain
        VmSafe.ProfileMetadata memory mainnetProfile = profile[1];
        assertEq(mainnetProfile.evm, "shanghai");
        assertTrue(_endsWith(mainnetProfile.artifacts, "out-shanghai"));

        VmSafe.ProfileMetadata memory optimismProfile = profile[10];
        assertEq(optimismProfile.evm, "cancun");
        assertTrue(_endsWith(optimismProfile.artifacts, "out-cancun"));
    }

    function test_getProfileMetadata() public {
        loadConfigAndForks("./test/fixtures/config.toml", false);

        // Test getting profile by chain ID
        VmSafe.ProfileMetadata memory mainnetProfile = profile[1];
        assertEq(mainnetProfile.evm, "shanghai");

        // Select fork and test getProfile() without chainId (uses active fork)
        selectFork(10);
        VmSafe.ProfileMetadata memory activeProfile = profile[vm.getChainId()];
        assertEq(activeProfile.evm, "cancun");
    }

    function test_selectFork() public {
        loadConfigAndForks("./test/fixtures/config.toml", false);

        // Test selecting mainnet fork
        selectFork(1);
        assertEq(vm.activeFork(), forkOf[1]);
        assertEq(vm.getChainId(), 1);

        // Test selecting optimism fork
        selectFork(10);
        assertEq(vm.activeFork(), forkOf[10]);
        assertEq(vm.getChainId(), 10);
    }

    function test_getRpcUrl() public {
        loadConfigAndForks("./test/fixtures/config.toml", false);

        // Verify cached RPC URLs match the environment variables
        assertEq(_getRpcUrl(1), "https://eth.llamarpc.com");
        assertEq(_getRpcUrl(10), "https://mainnet.optimism.io");

        // Verify it works after switching forks and EVM versions
        selectFork(1);
        assertEq(_getRpcUrl(1), "https://eth.llamarpc.com");

        selectFork(10);
        assertEq(_getRpcUrl(10), "https://mainnet.optimism.io");
    }

    // Nececssary to assert the revert
    function _selectFork(uint256 chainId) external {
        selectFork(chainId);
    }

    function testRevert_selectForkNotLoaded() public {
        loadConfigAndForks("./test/fixtures/config.toml", false);

        // Try to select a fork that was not loaded
        vm.expectRevert(abi.encodeWithSelector(Config.ForkNotLoaded.selector, uint256(999)));
        this._selectFork(999);
    }

    function testRevert_getRpcUrlNotLoaded() public {
        loadConfigAndForks("./test/fixtures/config.toml", false);

        // Try to get RPC URL for a chain that was not loaded
        vm.expectRevert(abi.encodeWithSelector(Config.ForkNotLoaded.selector, uint256(999)));
        this.getRpcUrl(999);
    }

    function test_getArtifactPath() public {
        loadConfigAndForks("./test/fixtures/config.toml", false);

        // Select mainnet fork and get artifact path
        selectFork(1);
        string memory artifactPath = _getArtifactPath(1, "MockCounter.sol", "MockCounter");
        assertTrue(_endsWith(artifactPath, "out-shanghai/MockCounter.sol/MockCounter.json"));

        // Select optimism fork and get artifact path
        selectFork(10);
        artifactPath = _getArtifactPath(10, "MockCounter.sol", "MockCounter");
        assertTrue(_endsWith(artifactPath, "out-cancun/MockCounter.sol/MockCounter.json"));
    }

    function testRevert_getArtifactPathForkNotActive() public {
        loadConfigAndForks("./test/fixtures/config.toml", false);

        // Select mainnet fork
        selectFork(1);

        // Try to get artifact path for optimism fork while mainnet is active
        vm.expectRevert(abi.encodeWithSelector(Config.ForkNotActive.selector, uint256(10)));
        this.getArtifactPath(10, "MockCounter.sol", "MockCounter");
    }

    function test_deployCodeBasic() public {
        loadConfigAndForks("./test/fixtures/config.toml", false);

        // Deploy to mainnet fork
        selectFork(1);
        address counterMainnet = deployCode(1, "MockCounter.sol", "MockCounter");
        assertTrue(counterMainnet != address(0));

        // Deploy to optimism fork
        selectFork(10);
        address counterOptimism = deployCode(10, "MockCounter.sol", "MockCounter");
        assertTrue(counterOptimism != address(0));

        // Verify deployments are different addresses
        assertTrue(counterMainnet != counterOptimism);
    }

    function test_deployCodeWithConstructorArgs() public {
        loadConfigAndForks("./test/fixtures/config.toml", false);

        // Deploy MockCounter (has no constructor args but tests the interface)
        selectFork(1);
        bytes memory constructorArgs = "";
        address counter = deployCode(1, "MockCounter.sol", "MockCounter", constructorArgs);

        assertTrue(counter != address(0));
        (bool success, bytes memory data) = counter.call(abi.encodeWithSignature("count()"));
        assertTrue(success);
        assertEq(abi.decode(data, (uint256)), 0);
    }

    function test_deployCodeWithValue() public {
        loadConfigAndForks("./test/fixtures/config.toml", false);

        // Deploy with msg.value
        selectFork(1);
        uint256 value = 1 ether;
        vm.deal(address(this), value);
        address counter = deployCode(1, "MockCounter.sol", "MockCounter", value);

        assertTrue(counter != address(0));
        assertGe(counter.balance, value);
    }

    function test_deployCodeCreate2() public {
        loadConfigAndForks("./test/fixtures/config.toml", false);

        // Deploy with CREATE2 using salt
        selectFork(1);
        bytes32 salt = bytes32(uint256(12345));
        address counter = deployCode(1, "MockCounter.sol", "MockCounter", salt);

        assertTrue(counter != address(0));

        // Verify same salt produces different addresses due to different bytecode (different EVM versions)
        selectFork(10);
        address counter2 = deployCode(10, "MockCounter.sol", "MockCounter", salt);

        // Note: Addresses will be different because bytecode is different (shanghai vs cancun)
        assertTrue(counter != counter2, "Addresses should differ due to different EVM versions");
    }

    function test_deployCodeCrossChain() public {
        loadConfigAndForks("./test/fixtures/config.toml", false);

        // Deploy MockCounter to mainnet (shanghai profile)
        selectFork(1);
        address mainnetCounter = deployCode(1, "MockCounter.sol", "MockCounter");
        assertTrue(mainnetCounter != address(0));

        // Verify it's using shanghai artifacts
        string memory actualMainnetPath = _getArtifactPath(1, "MockCounter.sol", "MockCounter");
        assertTrue(_endsWith(actualMainnetPath, "out-shanghai/MockCounter.sol/MockCounter.json"));

        // Deploy MockCounter to optimism (cancun profile)
        selectFork(10);
        address optimismCounter = deployCode(10, "MockCounter.sol", "MockCounter");
        assertTrue(optimismCounter != address(0));

        // Verify it's using cancun artifacts
        string memory actualOptimismPath = _getArtifactPath(10, "MockCounter.sol", "MockCounter");
        assertTrue(_endsWith(actualOptimismPath, "out-cancun/MockCounter.sol/MockCounter.json"));
    }

    function test_multiChainDeploymentWorkflow() public {
        loadConfigAndForks("./test/fixtures/config.toml", false);

        selectFork(1);
        assertEq(vm.getChainId(), 1);

        address mainnetCounter = deployCode(1, "MockCounter.sol", "MockCounter");
        assertTrue(mainnetCounter != address(0));

        (bool success1, bytes memory data1) = mainnetCounter.call(abi.encodeWithSignature("count()"));
        assertTrue(success1);
        assertEq(abi.decode(data1, (uint256)), 0);

        (bool success1b,) = mainnetCounter.call(abi.encodeWithSignature("increment()"));
        assertTrue(success1b);

        selectFork(10);
        assertEq(vm.getChainId(), 10);

        address optimismCounter = deployCode(10, "MockCounter.sol", "MockCounter");
        assertTrue(optimismCounter != address(0));

        (bool success2, bytes memory data2) = optimismCounter.call(abi.encodeWithSignature("count()"));
        assertTrue(success2);
        assertEq(abi.decode(data2, (uint256)), 0);

        assertTrue(mainnetCounter != optimismCounter);

        // Switch back to mainnet and verify state is preserved
        selectFork(1);
        (bool success3, bytes memory data3) = mainnetCounter.call(abi.encodeWithSignature("count()"));
        assertTrue(success3);
        assertEq(abi.decode(data3, (uint256)), 1);
    }
}
