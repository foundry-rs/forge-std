// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "../src/Test.sol";

contract StdJsonTest is Test {
    using stdJson for string;
    string json;

    function setUp() public {
        string memory root = vm.projectRoot();
        string memory path = string.concat(
            root,
            "/test/fixtures/broadcast.log.json"
        );
        json = vm.readFile(path);
    }

    // Positives

    function testJsonKeyExists_Object() public view {
        bool keyExists = json.keyExists(".transactions");
        assert(keyExists == true);
    }

    function testJsonKeyExists_String() public view {
        bool keyExists = json.keyExists(".transactions[0].contractName");
        assert(keyExists == true);
    }

    function testJsonKeyExists_Address() public view {
        bool keyExists = json.keyExists(".transactions[0].contractAddress");
        assert(keyExists == true);
    }

    function testJsonKeyExists_Hex() public view {
        bool keyExists = json.keyExists(".transactions[0].type");
        assert(keyExists == true);
    }

    function testJsonKeyExists_Bytes32() public view {
        bool keyExists = json.keyExists(".transactions[0].hash");
        assert(keyExists == true);
    }

    function testJsonKeyExists_ZeroHex() public view {
        bool keyExists = json.keyExists(".transactions[0].tx.value");
        assert(keyExists == true);
    }

    function testJsonKeyExists_Bytes() public view {
        bool keyExists = json.keyExists(".transactions[0].tx.data");
        assert(keyExists == true);
    }

    function testJsonKeyExists_Number() public view {
        bool keyExists = json.keyExists(".timestamp");
        assert(keyExists == true);
    }

    function testJsonKeyExists_BoolFalse() public view {
        bool keyExists = json.keyExists(".receipts[5].logs[0].removed");
        assert(keyExists == true);
    }

    // TODO: Consider adding zero number to json (or create a separate json fixture for testing these)
    function testJsonKeyExists_ZeroNumber() public view {
        string memory testJson = '{"zero":0}';
        bool keyExists = testJson.keyExists(".zero");
        assert(keyExists == true);
    }

    // Negatives

    function testJsonKeyDoesNotExist() public view {
        bool keyExists = json.keyExists(".nonExistingKey");
        assert(keyExists == false);
    }

    // Special cases

    // Empty object is parsed as 0x and reverts as it can't be converted to any solidity type
    function testJsonKeyExists_ButItsEmptyObject() public view {
        console.logBytes(json.parseRaw(".returns"));
        bool keyExists = json.keyExists(".returns");
        assert(keyExists == false);
    }

    // TODO: Empty array is parsed as an empty string (probably should revert instead?)
    function testJsonKeyExists_EmptyArray() public view {
        console.logBytes(json.parseRaw(".pending"));
        bool keyExists = json.keyExists(".pending");
        assert(keyExists == true); // Should be false?
    }

    // TODO: Null is parsed as an empty string (probably should revert instead?)
    function testJsonKeyExists_Null() public view {
        console.logBytes(json.parseRaw(".receipts[0].logs"));
        bool keyExists = json.keyExists(".receipts[0].logs");
        assert(keyExists == true); // Should be false?
    }
}
