// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import {Test} from "../src/Test.sol";

contract CommonConfigTest is Test {
    function test_loadConfig() public {
        _loadConfig("./test/fixtures/config.toml");

        address weth;
        address[] memory deps;
        string memory url;

        // mainnet
        weth = config.readAddress(1, "weth");
        deps = config.readAddressArray(1, "deps");
        url = config.readRpcUrl(1);

        assertEq(weth, 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
        assertEq(deps[0], 0x0000000000000000000000000000000000000000);
        assertEq(deps[1], 0x1111111111111111111111111111111111111111);
        assertEq(url, "https://eth.llamarpc.com");

        // optimism
        weth = config.readAddress(10, "weth");
        deps = config.readAddressArray(10, "deps");
        url = config.readRpcUrl(10);

        assertEq(weth, 0x4200000000000000000000000000000000000006);
        assertEq(deps[0], 0x2222222222222222222222222222222222222222);
        assertEq(deps[1], 0x3333333333333333333333333333333333333333);
        assertEq(url, "https://mainnet.optimism.io");
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
