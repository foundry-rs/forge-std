// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "../src/Test.sol";

contract StdJsonTest is Test {
    using stdJson for string;

    string root;
    string path;

    function setUp() public {
        root = vm.projectRoot();
        path = string.concat(root, "/test/fixtures/test.json");
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

    function test_readJson() public {
        string memory json = vm.readFile(path);
        assertEq(json.readUint(".a"), 123);
    }

    function test_writeJson() public {
        string memory json = "json";
        json.serialize("a", uint256(123));
        string memory semiFinal = json.serialize("b", string("test"));
        string memory finalJson = json.serialize("c", semiFinal);
        finalJson.write(path);

        string memory json_ = vm.readFile(path);
        bytes memory data = json_.parseRaw("$");
        notSimpleJson memory decodedData = abi.decode(data, (notSimpleJson));

        assertEq(decodedData.a, 123);
        assertEq(decodedData.b, "test");
        assertEq(decodedData.c.a, 123);
        assertEq(decodedData.c.b, "test");
    }
}
