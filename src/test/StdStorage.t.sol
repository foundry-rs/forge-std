// SPDX-License-Identifier: Unlicense
pragma solidity >=0.7.0 <0.9.0;

import "../Test.sol";

contract StdStorageTest is Test {
    using stdStorage for StdStorage;

    StorageTest test;

    function setUp() public {
        test = new StorageTest();
    }

    function testStorageHidden() public {
        assertEq(stdstore.target(address(test)).sig("hidden()").find(), uint256(keccak256("my.random.var")));
    }

    function testStorageObvious() public {
        assertEq(stdstore.target(address(test)).sig("exists()").find(), uint256(0));
    }

    function testStorageCheckedWriteHidden() public {
        stdstore.target(address(test)).sig(test.hidden.selector).checked_write(100);
        assertEq(uint256(test.hidden()), 100);
    }

    function testStorageCheckedWriteObvious() public {
        stdstore.target(address(test)).sig(test.exists.selector).checked_write(100);
        assertEq(test.exists(), 100);
    }

    function testStorageMapStructA() public {
        uint256 slot = stdstore
            .target(address(test))
            .sig(test.map_struct.selector)
            .with_key(address(this))
            .depth(0)
            .find();
        assertEq(slot, uint256(keccak256(abi.encode(address(this), 4))));
    }

    function testStorageMapStructB() public {
        uint256 slot = stdstore
            .target(address(test))
            .sig(test.map_struct.selector)
            .with_key(address(this))
            .depth(1)
            .find();
       assertEq(slot, uint256(keccak256(abi.encode(address(this), 4))) + 1);
    }

    function testStorageDeepMap() public {
        uint256 slot = stdstore
            .target(address(test))
            .sig(test.deep_map.selector)
            .with_key(address(this))
            .with_key(address(this))
            .find();
        assertEq(slot, uint256(keccak256(abi.encode(address(this), keccak256(abi.encode(address(this), uint(5)))))));
    }

    function testStorageCheckedWriteDeepMap() public {
        stdstore
            .target(address(test))
            .sig(test.deep_map.selector)
            .with_key(address(this))
            .with_key(address(this))
            .checked_write(100);
        assertEq(test.deep_map(address(this), address(this)), 100);
    }

    function testStorageDeepMapStructA() public {
        uint256 slot = stdstore
            .target(address(test))
            .sig(test.deep_map_struct.selector)
            .with_key(address(this))
            .with_key(address(this))
            .depth(0)
            .find();
        assertEq(bytes32(slot), bytes32(uint256(keccak256(abi.encode(address(this), keccak256(abi.encode(address(this), uint(6)))))) + 0));
    }

    function testStorageDeepMapStructB() public {
        uint256 slot = stdstore
            .target(address(test))
            .sig(test.deep_map_struct.selector)
            .with_key(address(this))
            .with_key(address(this))
            .depth(1)
            .find();
        assertEq(bytes32(slot), bytes32(uint256(keccak256(abi.encode(address(this), keccak256(abi.encode(address(this), uint(6)))))) + 1));
    }

    function testStorageCheckedWriteDeepMapStructA() public {
        stdstore
            .target(address(test))
            .sig(test.deep_map_struct.selector)
            .with_key(address(this))
            .with_key(address(this))
            .depth(0)
            .checked_write(100);
        (uint256 a, uint256 b) = test.deep_map_struct(address(this), address(this));
        assertEq(a, 100);
        assertEq(b, 0);
    }

    function testStorageCheckedWriteDeepMapStructB() public {
        stdstore
            .target(address(test))
            .sig(test.deep_map_struct.selector)
            .with_key(address(this))
            .with_key(address(this))
            .depth(1)
            .checked_write(100);
        (uint256 a, uint256 b) = test.deep_map_struct(address(this), address(this));
        assertEq(a, 0);
        assertEq(b, 100);
    }

    function testStorageCheckedWriteMapStructA() public {
        stdstore
            .target(address(test))
            .sig(test.map_struct.selector)
            .with_key(address(this))
            .depth(0)
            .checked_write(100);
        (uint256 a, uint256 b) = test.map_struct(address(this));
        assertEq(a, 100);
        assertEq(b, 0);
    }

    function testStorageCheckedWriteMapStructB() public {
        stdstore
            .target(address(test))
            .sig(test.map_struct.selector)
            .with_key(address(this))
            .depth(1)
            .checked_write(100);
        (uint256 a, uint256 b) = test.map_struct(address(this));
        assertEq(a, 0);
        assertEq(b, 100);
    }

    function testStorageStructA() public {
        uint256 slot = stdstore.target(address(test)).sig(test.basic.selector).depth(0).find();
        assertEq(slot, uint256(7));
    }

    function testStorageStructB() public {
        uint256 slot = stdstore.target(address(test)).sig(test.basic.selector).depth(1).find();
        assertEq(slot, uint256(7) + 1);
    }

    function testStorageCheckedWriteStructA() public {
        stdstore.target(address(test)).sig(test.basic.selector).depth(0).checked_write(100);
        (uint256 a, uint256 b) = test.basic();
        assertEq(a, 100);
        assertEq(b, 1337);
    }

    function testStorageCheckedWriteStructB() public {
        stdstore.target(address(test)).sig(test.basic.selector).depth(1).checked_write(100);
        (uint256 a, uint256 b) = test.basic();
        assertEq(a, 1337);
        assertEq(b, 100);
    }

    function testStorageStructWithBoolA() public {
        uint256 slot = stdstore.target(address(test)).sig(test.basicWithBool.selector).depth(0).find();
        assertEq(slot, 9);
    }

    function testStorageStructWithBoolB() public {
        uint256 slot = stdstore.target(address(test)).sig(test.basicWithBool.selector).depth(1).find();
        assertEq(slot, 10);
    }

    function testStorageCheckedWriteStructWithBoolA() public {
        stdstore.target(address(test)).sig(test.basicWithBool.selector).depth(0).checked_write(100);
        (uint256 a, bool b) = test.basicWithBool();
        assertEq(a, 100);
        assertTrue(b);
    }

    function testStorageCheckedWriteStructWithBoolB() public {
        stdstore.target(address(test)).sig(test.basicWithBool.selector).depth(1).checked_write(false);
        (uint256 a, bool b) = test.basicWithBool();
        assertEq(a, 1337);
        assertFalse(b);
    }

    function testStorageMapAddrFound() public {
        uint256 slot = stdstore.target(address(test)).sig(test.map_addr.selector).with_key(address(this)).find();
        assertEq(slot, uint256(keccak256(abi.encode(address(this), uint(1)))));
    }

    function testStorageMapUintFound() public {
        uint256 slot = stdstore.target(address(test)).sig(test.map_uint.selector).with_key(100).find();
        assertEq(slot, uint256(keccak256(abi.encode(100, uint(2)))));
    }

    function testStorageCheckedWriteMapUint() public {
        stdstore.target(address(test)).sig(test.map_uint.selector).with_key(100).checked_write(100);
        assertEq(test.map_uint(100), 100);
    }

    function testStorageCheckedWriteMapAddr() public {
        stdstore.target(address(test)).sig(test.map_addr.selector).with_key(address(this)).checked_write(100);
        assertEq(test.map_addr(address(this)), 100);
    }

    function testStorageCheckedWriteMapBool() public {
        stdstore.target(address(test)).sig(test.map_bool.selector).with_key(address(this)).checked_write(true);
        assertTrue(test.map_bool(address(this)));
    }

    function testFailStorageCheckedWriteMapPacked() public {
        // expect PackedSlot error but not external call so cant expectRevert
        stdstore.target(address(test)).sig(test.read_struct_lower.selector).with_key(address(uint160(1337))).checked_write(100);
    }

    function testStorageCheckedWriteMapPackedSuccess() public {
        uint256 full = test.map_packed(address(1337));
        // keep upper 128, set lower 128 to 1337
        full = (full & (uint256((1 << 128) - 1) << 128)) | 1337;
        stdstore.target(address(test)).sig(test.map_packed.selector).with_key(address(uint160(1337))).checked_write(full);
        assertEq(test.read_struct_lower(address(1337)), 1337);
    }

    function testFailStorageConst() public {
        // vm.expectRevert(abi.encodeWithSignature("NotStorage(bytes4)", bytes4(keccak256("const()"))));
        stdstore.target(address(test)).sig("const()").find();
    }

    function testFailStorageNativePack() public {
        stdstore.target(address(test)).sig(test.tA.selector).find();
        stdstore.target(address(test)).sig(test.tB.selector).find();
        
        // these both would fail
        stdstore.target(address(test)).sig(test.tC.selector).find();
        stdstore.target(address(test)).sig(test.tD.selector).find();
    }

    function testStorageReadBytes32() public {
        bytes32 val = stdstore.target(address(test)).sig(test.tE.selector).read_bytes32();
        assertEq(val, hex"1337");
    }

    function testStorageReadBool_False() public {
        bool val = stdstore.target(address(test)).sig(test.tB.selector).read_bool();
        assertEq(val, false);
    }

    function testStorageReadBool_True() public {
        bool val = stdstore.target(address(test)).sig(test.tH.selector).read_bool();
        assertEq(val, true);
    }

    function testStorageReadBool_Revert() public {
        vm.expectRevert("stdStorage read_bool(StdStorage): Cannot decode. Make sure you are reading a bool.");
        this.readNonBoolValue();
    }

    function readNonBoolValue() public {
        stdstore.target(address(test)).sig(test.tE.selector).read_bool();
    }

    function testStorageReadAddress() public {
        address val = stdstore.target(address(test)).sig(test.tF.selector).read_address();
        assertEq(val, address(1337));
    }

    function testStorageReadUint() public {
        uint256 val = stdstore.target(address(test)).sig(test.exists.selector).read_uint();
        assertEq(val, 1);
    }

    function testStorageReadInt() public {
        int256 val = stdstore.target(address(test)).sig(test.tG.selector).read_int();
        assertEq(val, type(int256).min);
    }
}

contract StorageTest {
    uint256 public exists = 1;
    mapping(address => uint256) public map_addr;
    mapping(uint256 => uint256) public map_uint;
    mapping(address => uint256) public map_packed;
    mapping(address => UnpackedStruct) public map_struct;
    mapping(address => mapping(address => uint256)) public deep_map;
    mapping(address => mapping(address => UnpackedStruct)) public deep_map_struct;
    UnpackedStruct public basic;
    UnpackedStructWithBool public basicWithBool;

    uint248 public tA;
    bool public tB;


    bool public tC = false;
    uint248 public tD = 1;    


    struct UnpackedStruct {
        uint256 a;
        uint256 b;
    }

    struct UnpackedStructWithBool {
        uint256 a;
        bool b;
    }

    mapping(address => bool) public map_bool;

    bytes32 public tE = hex"1337";
    address public tF = address(1337);
    int256 public tG = type(int256).min;
    bool public tH = true;

    constructor() {
        basic = UnpackedStruct({
            a: 1337,
            b: 1337
        });
        basicWithBool = UnpackedStructWithBool({
            a: 1337,
            b: true
        });

        uint256 two = (1<<128) | 1;
        map_packed[msg.sender] = two;
        map_packed[address(bytes20(uint160(1337)))] = 1<<128;
    }

    function read_struct_upper(address who) public view returns (uint256) {
        return map_packed[who] >> 128;
    }

    function read_struct_lower(address who) public view returns (uint256) {
        return map_packed[who] & ((1 << 128) - 1);
    }

    function hidden() public view returns (bytes32 t) {
        bytes32 slot = keccak256("my.random.var");
        /// @solidity memory-safe-assembly
        assembly {
            t := sload(slot)
        }
    }

    function const() public pure returns (bytes32 t) {
        t = bytes32(hex"1337");
    }
}
