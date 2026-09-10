// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.13 <0.9.0;

import {Test, stdJson} from "../src/Test.sol";

contract StdJsonTest is Test {
    using stdJson for string;

    string root;
    string path;

    function setUp() public {
        root = vm.projectRoot();
        path = string.concat(root, "/test/fixtures/test.json");
    }

    struct SimpleJson {
        uint256 a;
        string b;
    }

    struct NestedJson {
        uint256 a;
        string b;
        SimpleJson c;
    }

    function test_readJson() public view {
        string memory json = vm.readFile(path);
        assertEq(json.readUint(".a"), 123);
    }

    // Regression test for https://github.com/foundry-rs/forge-std/issues/592
    // `parseRaw` infers a value's type, encoding a 20-byte hex string as an `address` and a
    // 32-byte one as a `bytes32`. Reading either back as `bytes` reverts, which is how
    // `readBytes` broke when it decoded `parseRaw` output instead of calling
    // `vm.parseJsonBytes`. Pin the lengths on both sides of each inference boundary.
    function test_ReadBytesAtInferredTypeLengths() public pure {
        string memory nineteen = '{"a":"0x00000000000000000000000000000000000000"}';
        assertEq(nineteen.readBytes(".a"), hex"00000000000000000000000000000000000000");

        string memory twentyZeros = '{"a":"0x0000000000000000000000000000000000000000"}';
        assertEq(twentyZeros.readBytes(".a"), hex"0000000000000000000000000000000000000000");

        string memory twentyAddressShaped = '{"a":"0x4bf5122f344554c53bde2ebb8cd2b7e3d1600ad6"}';
        assertEq(twentyAddressShaped.readBytes(".a"), hex"4bf5122f344554c53bde2ebb8cd2b7e3d1600ad6");

        string memory twentyOne = '{"a":"0x000000000000000000000000000000000000000000"}';
        assertEq(twentyOne.readBytes(".a"), hex"000000000000000000000000000000000000000000");

        string memory thirtyOne = '{"a":"0x00000000000000000000000000000000000000000000000000000000000012"}';
        assertEq(thirtyOne.readBytes(".a"), hex"00000000000000000000000000000000000000000000000000000000000012");

        string memory thirtyTwo = '{"a":"0x4bf5122f344554c53bde2ebb8cd2b7e3d1600ad64bf5122f344554c53bde2ebb"}';
        assertEq(thirtyTwo.readBytes(".a"), hex"4bf5122f344554c53bde2ebb8cd2b7e3d1600ad64bf5122f344554c53bde2ebb");

        string memory thirtyThree = '{"a":"0x4bf5122f344554c53bde2ebb8cd2b7e3d1600ad64bf5122f344554c53bde2ebb00"}';
        assertEq(thirtyThree.readBytes(".a"), hex"4bf5122f344554c53bde2ebb8cd2b7e3d1600ad64bf5122f344554c53bde2ebb00");
    }

    function test_writeJson() public {
        string memory json = "json";
        json.serialize("a", uint256(123));
        string memory semiFinal = json.serialize("b", string("test"));
        string memory finalJson = json.serialize("c", semiFinal);
        finalJson.write(path);

        string memory json_ = vm.readFile(path);
        bytes memory data = json_.parseRaw("$");
        NestedJson memory decodedData = abi.decode(data, (NestedJson));

        assertEq(decodedData.a, 123);
        assertEq(decodedData.b, "test");
        assertEq(decodedData.c.a, 123);
        assertEq(decodedData.c.b, "test");
    }
}
