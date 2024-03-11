// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "../src/Test.sol";

contract StdTomlTest is Test {
    using stdToml for string;

    string root;
    string path;

    function setUp() public {
        root = vm.projectRoot();
        path = string.concat(root, "/test/fixtures/test.toml");
    }

    struct simpleJson {
        uint256 a;
        string b;
    }

    struct notSimpleJson {
        uint256 a;
        string b;
        simpleJson c;
    }

    function test_readToml() public {
        string memory json = vm.readFile(path);
        assertEq(json.readUint(".a"), 123);
    }

    function test_writeToml() public {
        string memory json = "json";
        json.serialize("a", uint256(123));
        string memory semiFinal = json.serialize("b", string("test"));
        string memory finalJson = json.serialize("c", semiFinal);
        finalJson.write(path);

        string memory toml = vm.readFile(path);
        bytes memory data = toml.parseRaw("$");
        notSimpleJson memory decodedData = abi.decode(data, (notSimpleJson));

        assertEq(decodedData.a, 123);
        assertEq(decodedData.b, "test");
        assertEq(decodedData.c.a, 123);
        assertEq(decodedData.c.b, "test");
    }
}
