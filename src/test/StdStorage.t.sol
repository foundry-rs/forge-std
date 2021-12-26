// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "ds-test/test.sol";
import {stdStorage} from "../stdlib.sol";
import "../Vm.sol";

contract StdStorageTest is DSTest {
    Vm public constant vm = Vm(HEVM_ADDRESS);

    stdStorage stdstore;
    StorageTest test;
    function setUp() public {
        stdstore = new stdStorage(); 
        test = new StorageTest();
    }

    function testStorageHidden() public {
        assertEq(uint256(keccak256("my.random.var")), stdstore.find(address(test), "hidden()"));
    }

    function testStorageObvious() public {
        assertEq(uint256(0), stdstore.find(address(test), "exists()"));
    }

    function testStorageCheckedWriteHidden() public {
        stdstore.checked_write(address(test), "hidden()", 100);
        assertEq(uint256(test.hidden()), 100);
    }

    function testStorageCheckedWriteObvious() public {
        stdstore.checked_write(address(test), "exists()", 100);
        assertEq(test.exists(), 100);
    }

    function testStorageMapStructA() public {
        assertEq(uint256(keccak256(abi.encode(address(this), 4))), stdstore.find_struct(address(test), "map_struct(address)", address(this), 0));
    }

    function testStorageMapStructB() public {
       assertEq(uint256(keccak256(abi.encode(address(this), 4))) + 1, stdstore.find_struct(address(test), "map_struct(address)", address(this), 1));
    }

    function testStorageDeepMap() public {
        address[] memory keys = new address[](2);
        keys[0] = address(this);
        keys[1] = address(this);
        assertEq(keccak256(abi.encode(keys[1], keccak256(abi.encode(keys[0], uint(5))))), bytes32(stdstore.find_multi_key(address(test), "deep_map(address,address)", keys)));
    }

    function testStorageCheckedWriteDeepMap() public {
        address[] memory keys = new address[](2);
        keys[0] = address(this);
        keys[1] = address(this);
        stdstore.checked_write_multi_key(address(test), "deep_map(address,address)", keys, 100);
        assertEq(100, test.deep_map(address(this), address(this)));
    }

    function testStorageDeepMapStructA() public {
        address[] memory keys = new address[](2);
        keys[0] = address(this);
        keys[1] = address(this);
        uint256 depth = 0;
        assertEq(bytes32(uint256(keccak256(abi.encode(keys[1], keccak256(abi.encode(keys[0], uint(6)))))) + depth), bytes32(stdstore.find_multi_key_struct(address(test), "deep_map_struct(address,address)", keys, depth)));
    }

    function testStorageDeepMapStructB() public {
        address[] memory keys = new address[](2);
        keys[0] = address(this);
        keys[1] = address(this);
        uint256 depth = 1;
        assertEq(bytes32(uint256(keccak256(abi.encode(keys[1], keccak256(abi.encode(keys[0], uint(6)))))) + depth), bytes32(stdstore.find_multi_key_struct(address(test), "deep_map_struct(address,address)", keys, depth)));
    }

    function testStorageCheckedWriteDeepMapStructA() public {
        address[] memory keys = new address[](2);
        keys[0] = address(this);
        keys[1] = address(this);
        uint256 depth = 0;
        stdstore.checked_write_multi_key_struct(address(test), "deep_map_struct(address,address)", keys, depth, 100);
        (uint256 a, uint256 b) = test.deep_map_struct(address(this), address(this));
        assertEq(100, a);
        assertEq(0, b);
    }

    function testStorageCheckedWriteDeepMapStructB() public {
        address[] memory keys = new address[](2);
        keys[0] = address(this);
        keys[1] = address(this);
        uint256 depth = 1;
        stdstore.checked_write_multi_key_struct(address(test), "deep_map_struct(address,address)", keys, depth, 100);
        (uint256 a, uint256 b) = test.deep_map_struct(address(this), address(this));
        assertEq(0, a);
        assertEq(100, b);
    }

    function testStorageCheckedWriteMapStructA() public {
        stdstore.checked_write_struct(address(test), "map_struct(address)", address(this), 0, 100);
        (uint256 a, uint256 b) = test.map_struct(address(this));
        assertEq(a, 100);
        assertEq(b, 0);
    }

    function testStorageCheckedWriteMapStructB() public {
        stdstore.checked_write_struct(address(test), "map_struct(address)", address(this), 1, 100);
        (uint256 a, uint256 b) = test.map_struct(address(this));
        assertEq(a, 0);
        assertEq(b, 100);
    }

    function testStorageStructA() public {
        assertEq(uint256(7), stdstore.find_struct(address(test), "basic()", 0));
    }

    function testStorageStructB() public {
        assertEq(uint256(7) + 1, stdstore.find_struct(address(test), "basic()", 1));
    }

    function testStorageCheckedWriteStructA() public {
        stdstore.checked_write_struct(address(test), "basic()", 0, 100);
        (uint256 a, uint256 b) = test.basic();
        assertEq(a, 100);
        assertEq(b, 1337);
    }

    function testStorageCheckedWriteStructB() public {
        stdstore.checked_write_struct(address(test), "basic()", 1, 100);
        (uint256 a, uint256 b) = test.basic();
        assertEq(a, 1337);
        assertEq(b, 100);
    }

    function testStorageMapAddrFound() public {
        uint256 slot = stdstore.find(address(test), "map_addr(address)", address(this));
        assertEq(uint256(keccak256(abi.encode(address(this), uint(1)))), slot);
    }

    function testStorageMapUintFound() public {
        uint256 slot = stdstore.find(address(test), "map_uint(uint256)", 100);
        assertEq(uint256(keccak256(abi.encode(100, uint(2)))), slot);
    }

    function testStorageCheckedWriteMapUint() public {
        stdstore.checked_write(address(test), "map_uint(uint256)", 100, 100);
        assertEq(100, test.map_uint(100));
    }

    function testStorageCheckedWriteMapAddr() public {
        stdstore.checked_write(address(test), "map_addr(address)", address(this), 100);
        assertEq(100, test.map_addr(address(this)));
    }

    function testStorageCheckedWriteMapPacked() public {
        vm.expectRevert(abi.encodeWithSignature("PackedSlot(bytes32)", uint256(keccak256(abi.encode(address(uint160(1337)), uint(3))))));
        stdstore.checked_write(address(test), "read_struct_lower(address)", address(uint160(1337)), 100);
    }

    function testStorageCheckedWriteMapPackedSuccess() public {
        Packed read = test.map_packed(address(1337));
        uint256 full = Packed.unwrap(read);
        // keep upper 128, set lower 128 to 1337
        full = (full & (uint256((1 << 128) - 1) << 128)) | 1337;
        stdstore.checked_write(address(test), "map_packed(address)", address(uint160(1337)), full);
        assertEq(1337, test.read_struct_lower(address(1337)));
    }

    function testStorageConst() public {
        vm.expectRevert(abi.encodeWithSignature("NotStorage(string)", string("const()")));
        stdstore.find(address(test), "const()");
    }

    function testStorageNativePack() public {
        stdstore.find(address(test), "tA()");
        stdstore.find(address(test), "tB()");
        vm.expectRevert(abi.encodeWithSignature("PackedSlot(bytes32)", bytes32(uint256(0xa))));
        stdstore.find(address(test), "tC()");
        vm.expectRevert(abi.encodeWithSignature("PackedSlot(bytes32)", bytes32(uint256(0xa))));
        stdstore.find(address(test), "tD()");
    }
}

type Packed is uint256;

contract StorageTest {
    uint256 public exists = 1;
    mapping(address => uint256) public map_addr;
    mapping(uint256 => uint256) public map_uint;
    mapping(address => Packed) public map_packed;
    mapping(address => UnpackedStruct) public map_struct;
    mapping(address => mapping(address => uint256)) public deep_map;
    mapping(address => mapping(address => UnpackedStruct)) public deep_map_struct;
    UnpackedStruct public basic;

    uint248 public tA;
    bool public tB;


    bool public tC = false;
    uint248 public tD = 1;    


    struct UnpackedStruct {
        uint256 a;
        uint256 b;
    }

    constructor() {
        basic = UnpackedStruct({
            a: 1337,
            b: 1337
        });

        uint256 two = (1<<128) | 1;
        map_packed[msg.sender] = Packed.wrap(two);
        map_packed[address(bytes20(uint160(1337)))] = Packed.wrap((1<<128));
    }

    function read_struct_upper(address who) public returns (uint256) {
        return Packed.unwrap(map_packed[who]) >> 128;
    }

    function read_struct_lower(address who) public returns (uint256) {
        return Packed.unwrap(map_packed[who]) & ((1 << 128) - 1);
    }

    function hidden() public returns (bytes32 t) {
        bytes32 slot = keccak256("my.random.var");
        assembly {
            t := sload(slot)
        }
    }

    function const() public returns (bytes32 t) {
        t = bytes32(hex"1337");
    }
}
