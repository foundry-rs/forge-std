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

    function testStorageExpect() public {
        assertEq(stdstore.find(address(test), "hidden()"), uint256(keccak256("my.random.var")));
    }

    function testStorageFound() public {
        assertEq(uint256(0), stdstore.find(address(test), "exists()"));
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

    function testStorageCheckedWriteMapStructPacked() public {
        vm.expectRevert(abi.encodeWithSignature("PackedSlot(bytes32)", uint256(keccak256(abi.encode(address(uint160(1337)), uint(3))))));
        stdstore.checked_write(address(test), "read_struct_lower(address)", address(uint160(1337)), 100);
    }

    function testStorageCheckedWriteMapStructPackedSuccess() public {
        Packed read = test.map_struct(address(1337));
        uint256 full = Packed.unwrap(read);
        // keep upper 128, set lower 128 to 1337
        full = (full & (uint256((1 << 128) - 1) << 128)) | 1337;
        stdstore.checked_write(address(test), "map_struct(address)", address(uint160(1337)), full);
        assertEq(1337, test.read_struct_lower(address(1337)));
    }
}

type Packed is uint256;

contract StorageTest {
    uint256 public exists = 1;
    mapping(address => uint256) public map_addr;
    mapping(uint256 => uint256) public map_uint;
    mapping(address => Packed) public map_struct;

    constructor() {
        uint256 two = (1<<128) | 1;
        map_struct[msg.sender] = Packed.wrap(two);
        map_struct[address(bytes20(uint160(1337)))] = Packed.wrap((1<<128));
    }

    function read_struct_upper(address who) public returns (uint256) {
        return Packed.unwrap(map_struct[who]) >> 128;
    }

    function read_struct_lower(address who) public returns (uint256) {
        return Packed.unwrap(map_struct[who]) & ((1 << 128) - 1);
    }

    function hidden() public returns (bytes32 t) {
        bytes32 slot = keccak256("my.random.var");
        assembly {
            t := sload(slot)
        }
    }
}
