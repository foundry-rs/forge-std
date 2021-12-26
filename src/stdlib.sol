// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./Vm.sol";

library stdError {
    bytes public constant assertionError = abi.encodeWithSignature("Panic(uint256)", 0x01);
    bytes public constant arithmeticError = abi.encodeWithSignature("Panic(uint256)", 0x11);
    bytes public constant divisionError = abi.encodeWithSignature("Panic(uint256)", 0x12);
    bytes public constant enumConversionError = abi.encodeWithSignature("Panic(uint256)", 0x21);
    bytes public constant encodeStorageError = abi.encodeWithSignature("Panic(uint256)", 0x22);
    bytes public constant popError = abi.encodeWithSignature("Panic(uint256)", 0x31);
    bytes public constant indexOOBError = abi.encodeWithSignature("Panic(uint256)", 0x32);
    bytes public constant memOverflowError = abi.encodeWithSignature("Panic(uint256)", 0x41);
    bytes public constant zeroVarError = abi.encodeWithSignature("Panic(uint256)", 0x51);

}


contract stdStorage {
    error NotFound(string);
    error NotStorage(string);
    error PackedSlot(bytes32);

    mapping (address => mapping(bytes4 => mapping(bytes32 => uint256))) public slots;
    mapping (address => mapping(bytes4 =>  mapping(bytes32 => bool))) public finds;
    Vm public constant vm = Vm(address(bytes20(uint160(uint256(keccak256('hevm cheat code'))))));
    
    event SlotFound(address who, string sig, bytes32 keysHash, uint slot);

    function sigs(
        string memory sig
    )
        internal
        pure
        returns (bytes4)
    {
        return bytes4(keccak256(bytes(sig)));
    }

    /// @notice find an arbitrary storage slot given a function sig, input data, address of the contract and a value to check against
    // slot complexity:
    //  if flat, will be bytes32(uint256(uint));
    //  if map, will be keccak256(abi.encode(key, uint(slot)));
    //  if deep map, will be keccak256(abi.encode(key1, keccak256(abi.encode(key0, uint(slot)))));
    //  if map struct, will be bytes32(uint256(keccak256(abi.encode(key1, keccak256(abi.encode(key0, uint(slot)))))) + structFieldDepth);
    function find(
        address who, // contract
        string memory sig, // signature to check agains
        bytes32[] memory ins, // see slot complexity
        uint256 depth
    ) 
        public 
        returns (uint256)
    {
        // calldata to test against
        bytes4 fsig = bytes4(keccak256(bytes(sig)));
        bytes memory cald = abi.encodePacked(fsig, flatten(ins));
        vm.record();
        {
            (bool pass, bytes memory dat) = who.staticcall(cald);
        }
        
        (bytes32[] memory reads, bytes32[] memory writes) = vm.accesses(address(who));
        if (reads.length == 1) {
            emit SlotFound(who, sig, keccak256(abi.encodePacked(ins, depth)), uint256(reads[0]));
            slots[who][fsig][keccak256(abi.encodePacked(ins, depth))] = uint256(reads[0]);
            finds[who][fsig][keccak256(abi.encodePacked(ins, depth))] = true;
        } else if (reads.length > 1) {
            for (uint256 i = 0; i < reads.length; i++) {
                 bytes32 prev = vm.load(who, reads[i]);
                // store
                vm.store(who, reads[i], bytes32(hex"1337"));
                bytes32 fdat;
                {
                    (bool pass, bytes memory rdat) = who.staticcall(cald);
                    fdat = bytesToBytes32(rdat, 32*depth);
                }
                
                if (fdat == bytes32(hex"1337")) {
                    // we found which of the slots is the actual one
                    emit SlotFound(who, sig, keccak256(abi.encodePacked(ins, depth)), uint256(reads[i]));
                    slots[who][fsig][keccak256(abi.encodePacked(ins, depth))] = uint256(reads[i]);
                    finds[who][fsig][keccak256(abi.encodePacked(ins, depth))] = true;
                    vm.store(who, reads[i], prev);
                    break;
                }
                vm.store(who, reads[i], prev);
            }
        } else {
            revert NotStorage(sig);
        }

        if (!finds[who][fsig][keccak256(abi.encodePacked(ins, depth))]) revert NotFound(sig);
        return slots[who][fsig][keccak256(abi.encodePacked(ins, depth))];
    }

    function find(
        address who, // contract
        string memory sig, // signature to check agains
        address target
    ) public returns (uint256) {
        bytes32[] memory ins = new bytes32[](1);
        ins[0] = bytes32(uint256(uint160(target)));
        return find(who, sig, ins, 0);
    }

    function find_multi_key(
        address who, // contract
        string memory sig, // signature to check agains
        address[] memory target
    ) public returns (uint256) {
        bytes32[] memory ins = new bytes32[](target.length);
        for (uint256 i = 0; i < target.length; i++) {
            ins[i] = bytes32(uint256(uint160(target[i])));
        }
        return find(who, sig, ins, 0);
    }

    function find_multi_key(
        address who, // contract
        string memory sig, // signature to check agains
        uint256[] memory target
    ) public returns (uint256) {
        bytes32[] memory ins = new bytes32[](target.length);
        for (uint256 i = 0; i < target.length; i++) {
            ins[i] = bytes32(target[i]);
        }
        return find(who, sig, ins, 0);
    }

    function find_multi_key(
        address who, // contract
        string memory sig, // signature to check agains
        bytes32[] memory target
    ) public returns (uint256) {
        return find(who, sig, target, 0);
    }

    function find_multi_key_struct(
        address who, // contract
        string memory sig, // signature to check agains
        address[] memory target,
        uint256 depth
    ) public returns (uint256) {
        bytes32[] memory ins = new bytes32[](target.length);
        for (uint256 i = 0; i < target.length; i++) {
            ins[i] = bytes32(uint256(uint160(target[i])));
        }
        return find(who, sig, ins, depth);
    }

    function find_multi_key_struct(
        address who, // contract
        string memory sig, // signature to check agains
        uint256[] memory target,
        uint256 depth
    ) public returns (uint256) {
        bytes32[] memory ins = new bytes32[](target.length);
        for (uint256 i = 0; i < target.length; i++) {
            ins[i] = bytes32(target[i]);
        }
        return find(who, sig, ins, depth);
    }

    function find_multi_key_struct(
        address who, // contract
        string memory sig, // signature to check agains
        bytes32[] memory target,
        uint256 depth
    ) public returns (uint256) {
        bytes32[] memory ins = new bytes32[](target.length);
        for (uint256 i = 0; i < target.length; i++) {
            ins[i] = bytes32(target[i]);
        }
        return find(who, sig, ins, depth);
    }

    function find(
        address who, // contract
        string memory sig, // signature to check agains
        uint256 target
    ) public returns (uint256) {
        bytes32[] memory ins = new bytes32[](1);
        ins[0] = bytes32(target);
        return find(who, sig, ins, 0);
    }

    function find(
        address who, // contract
        string memory sig // signature to check agains
    ) public returns (uint256) {
        return find(who, sig, new bytes32[](0), 0);
    }

    
    function find_struct(
        address who,
        string memory sig,
        uint256 depth
    ) public returns (uint256) {
        return find(who, sig, new bytes32[](0), depth);
    }

    function find_struct(
        address who,
        string memory sig,
        uint256 target,
        uint256 depth
    ) public returns (uint256) {
        bytes32[] memory ins = new bytes32[](1);
        ins[0] = bytes32(target);
        return find(who, sig, ins, depth);
    }

    function find_struct(
        address who,
        string memory sig,
        address target,
        uint256 depth
    ) public returns (uint256) {
        bytes32[] memory ins = new bytes32[](1);
        ins[0] = bytes32(uint256(uint160(target)));
        return find(who, sig, ins, depth);
    }

    function checked_write(
        address who,
        string memory sig,
        bytes32[] memory ins,
        bytes32 set,
        uint256 depth 
    ) public {
        bytes4 fsig = bytes4(keccak256(bytes(sig)));
        bytes memory cald = abi.encodePacked(fsig, flatten(ins));
        if (!finds[who][fsig][keccak256(abi.encodePacked(ins, depth))]) {
            find(who, sig, ins, depth);
        }
        bytes32 slot = bytes32(slots[who][fsig][keccak256(abi.encodePacked(ins, depth))]);

        bytes32 fdat;
        {
            (bool pass, bytes memory rdat) = who.staticcall(cald);
            fdat = bytesToBytes32(rdat, 32*depth);
        }
        bytes32 curr = vm.load(who, slot);

        if (fdat != curr) {
            revert PackedSlot(slot);
        }
        vm.store(who, slot, set);
    }

    function checked_write(
        address who,
        string memory sig,
        bytes32 set
    ) public {
        checked_write(who, sig, new bytes32[](0), set, 0);
    }

    function checked_write(
        address who,
        string memory sig,
        address set
    ) public {
        checked_write(who, sig, new bytes32[](0), bytes32(bytes20(set)), 0);
    }

    function checked_write(
        address who,
        string memory sig,
        uint256 set
    ) public {
        checked_write(who, sig, new bytes32[](0), bytes32(set), 0);
    }

    function checked_write(
        address who,
        string memory sig,
        bytes32 target,
        bytes32 set
    ) public {
        bytes32[] memory ins = new bytes32[](1);
        ins[0] = target;
        checked_write(who, sig, ins, set, 0);
    }

    function checked_write(
        address who,
        string memory sig,
        uint256 target,
        bytes32 set
    ) public {
        checked_write(who, sig, bytes32(target), set);
    }

    function checked_write(
        address who,
        string memory sig,
        uint256 target,
        uint256 set
    ) public {
        checked_write(who, sig, bytes32(target), bytes32(set));
    }

    function checked_write(
        address who,
        string memory sig,
        address target,
        bytes32 set
    ) public {
        checked_write(who, sig, bytes32(uint256(uint160(target))), set);
    }

    function checked_write(
        address who,
        string memory sig,
        address target,
        address set
    ) public {
        checked_write(who, sig, bytes32(uint256(uint160(target))), bytes32(uint256(uint160(set))));
    }

    function checked_write(
        address who,
        string memory sig,
        address target,
        uint256 set
    ) public {
        checked_write(who, sig, bytes32(uint256(uint160(target))), bytes32(set));
    }

    function checked_write_struct(
        address who,
        string memory sig,
        address target,
        uint256 depth,
        uint256 set
    ) public {
        bytes32[] memory ins = new bytes32[](1);
        ins[0] = bytes32(uint256(uint160(target)));
        checked_write(who, sig, ins, bytes32(set), depth);
    }

    function checked_write_struct(
        address who,
        string memory sig,
        uint256 depth,
        uint256 set
    ) public {
        checked_write(who, sig, new bytes32[](0), bytes32(set), depth);
    }

    function checked_write_multi_key(
        address who, // contract
        string memory sig, // signature to check agains
        address[] memory target,
        uint256 set
    ) public {
        bytes32[] memory ins = new bytes32[](target.length);
        for (uint256 i = 0; i < target.length; i++) {
            ins[i] = bytes32(uint256(uint160(target[i])));
        }
        checked_write(who, sig, ins, bytes32(set), 0);
    }

    function checked_write_multi_key(
        address who, // contract
        string memory sig, // signature to check agains
        uint256[] memory target,
        uint256 set
    ) public {
        bytes32[] memory ins = new bytes32[](target.length);
        for (uint256 i = 0; i < target.length; i++) {
            ins[i] = bytes32(target[i]);
        }
        checked_write(who, sig, ins, bytes32(set), 0);
    }

    function checked_write_multi_key(
        address who, // contract
        string memory sig, // signature to check agains
        bytes32[] memory target,
        uint256 set
    ) public {
        checked_write(who, sig, target, bytes32(set), 0);
    }

    function checked_write_multi_key(
        address who, // contract
        string memory sig, // signature to check agains
        address[] memory target,
        address set
    ) public {
        bytes32[] memory ins = new bytes32[](target.length);
        for (uint256 i = 0; i < target.length; i++) {
            ins[i] = bytes32(uint256(uint160(target[i])));
        }
        checked_write(who, sig, ins, bytes32(uint256(uint160(set))), 0);
    }

    function checked_write_multi_key(
        address who, // contract
        string memory sig, // signature to check agains
        uint256[] memory target,
        address set
    ) public {
        bytes32[] memory ins = new bytes32[](target.length);
        for (uint256 i = 0; i < target.length; i++) {
            ins[i] = bytes32(target[i]);
        }
        checked_write(who, sig, ins, bytes32(uint256(uint160(set))), 0);
    }

    function checked_write_multi_key(
        address who, // contract
        string memory sig, // signature to check agains
        bytes32[] memory target,
        address set
    ) public {
        checked_write(who, sig, target, bytes32(uint256(uint160(set))), 0);
    }

    function checked_write_multi_key_struct(
        address who, // contract
        string memory sig, // signature to check agains
        address[] memory target,
        uint256 depth,
        address set
    ) public {
        bytes32[] memory ins = new bytes32[](target.length);
        for (uint256 i = 0; i < target.length; i++) {
            ins[i] = bytes32(uint256(uint160(target[i])));
        }
        checked_write(who, sig, ins, bytes32(uint256(uint160(set))), depth);
    }

    function checked_write_multi_key_struct(
        address who, // contract
        string memory sig, // signature to check agains
        address[] memory target,
        uint256 depth,
        uint256 set
    ) public {
        bytes32[] memory ins = new bytes32[](target.length);
        for (uint256 i = 0; i < target.length; i++) {
            ins[i] = bytes32(uint256(uint160(target[i])));
        }
        checked_write(who, sig, ins, bytes32(set), depth);
    }

    function checked_write_multi_key_struct(
        address who, // contract
        string memory sig, // signature to check agains
        uint256[] memory target,
        uint256 depth,
        uint256 set
    ) public {
        bytes32[] memory ins = new bytes32[](target.length);
        for (uint256 i = 0; i < target.length; i++) {
            ins[i] = bytes32(target[i]);
        }
        checked_write(who, sig, ins, bytes32(set), depth);
    }

    function checked_write_multi_key_struct(
        address who, // contract
        string memory sig, // signature to check agains
        bytes32[] memory target,
        uint256 depth,
        bytes32 set
    ) public {
        checked_write(who, sig, target, set, depth);
    }

    function bytesToBytes32(bytes memory b, uint offset) public pure returns (bytes32) {
        bytes32 out;

        for (uint i = 0; i < 32; i++) {
            out |= bytes32(b[offset + i] & 0xFF) >> (i * 8);
        }
        return out;
    }

    function flatten(bytes32[] memory b) private pure returns (bytes memory)
    {
        bytes memory result = new bytes(b.length * 32);
        for (uint256 i = 0; i < b.length; i++) {
            bytes32 k = b[i];
            assembly {
                mstore(add(result, add(32, mul(32, i))), k)
            }
        }

        return result;
    }

    // call this to speed up on known storage slots. See SlotFound and add to setup()
    function addKnownVm(address who, bytes4 fsig, bytes32[] memory ins, uint256 depth, uint slot) public {
        slots[who][fsig][keccak256(abi.encodePacked(ins, depth))] = slot;
        finds[who][fsig][keccak256(abi.encodePacked(ins, depth))] = true;
    }
}