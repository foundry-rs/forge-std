// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import {Vm} from "./Vm.sol";

struct StdStorage {
    mapping(address => mapping(bytes4 => mapping(bytes32 => uint256))) dynamic_slots;
    mapping(address => mapping(bytes4 => mapping(bytes32 => bool))) dynamic_finds;
    mapping(address => mapping(bytes4 => mapping(bytes32 => uint256))) slots;
    mapping(address => mapping(bytes4 => mapping(bytes32 => bool))) finds;
    bytes32[] _keys;
    bytes4 _sig;
    uint256 _depth;
    address _target;
    bytes32 _set;
}

library stdStorageSafe {
    event SlotFound(address who, bytes4 fsig, bytes32 keysHash, uint256 slot);
    event WARNING_UninitedSlot(address who, uint256 slot);

    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    function sigs(string memory sigStr) internal pure returns (bytes4) {
        return bytes4(keccak256(bytes(sigStr)));
    }

    /// @notice find an arbitrary storage slot given a function sig, input data, address of the contract and a value to check against
    // slot complexity:
    //  if flat, will be bytes32(uint256(uint));
    //  if map, will be keccak256(abi.encode(key, uint(slot)));
    //  if deep map, will be keccak256(abi.encode(key1, keccak256(abi.encode(key0, uint(slot)))));
    //  if map struct, will be bytes32(uint256(keccak256(abi.encode(key1, keccak256(abi.encode(key0, uint(slot)))))) + structFieldDepth);
    function find(StdStorage storage self) internal returns (bool, uint256) {
        address who = self._target;
        bytes4 fsig = self._sig;
        uint256 field_depth = self._depth;
        bytes32[] memory ins = self._keys;

        // calldata to test against
        if (self.finds[who][fsig][keccak256(abi.encodePacked(ins, field_depth))]) {
            return (false, self.slots[who][fsig][keccak256(abi.encodePacked(ins, field_depth))]);
        } else if (self.dynamic_finds[who][fsig][keccak256(abi.encodePacked(ins, field_depth))]) {
            return (true, self.dynamic_slots[who][fsig][keccak256(abi.encodePacked(ins, field_depth))]);
        }

        bytes memory cald = abi.encodePacked(fsig, flatten(ins));
        vm.record();
        bytes32 fdat;
        {
            (, bytes memory rdat) = who.staticcall(cald);
            fdat = bytesToBytes32(rdat, 32 * field_depth);
        }

        (bytes32[] memory reads,) = vm.accesses(address(who));
        if (reads.length == 1) {
            bytes32 curr = vm.load(who, reads[0]);
            if (curr == bytes32(0)) {
                emit WARNING_UninitedSlot(who, uint256(reads[0]));
            }
            if (fdat != curr) {
                require(
                    false,
                    "stdStorage find(StdStorage): Packed slot. This would cause dangerous overwriting and currently isn't supported."
                );
            }
            emit SlotFound(who, fsig, keccak256(abi.encodePacked(ins, field_depth)), uint256(reads[0]));
            self.slots[who][fsig][keccak256(abi.encodePacked(ins, field_depth))] = uint256(reads[0]);
            self.finds[who][fsig][keccak256(abi.encodePacked(ins, field_depth))] = true;
        } else if (reads.length > 1) {
            for (uint256 i = 0; i < reads.length; i++) {
                bytes32 prev = vm.load(who, reads[i]);
                if (prev == bytes32(0)) {
                    emit WARNING_UninitedSlot(who, uint256(reads[i]));
                }
                // store
                vm.store(who, reads[i], bytes32(hex"1337"));
                bool success;
                bytes memory rdat;
                {
                    (success, rdat) = who.staticcall(cald);
                    fdat = bytesToBytes32(rdat, 32 * field_depth);
                }

                if (success && fdat == bytes32(hex"1337")) {
                    // we found which of the slots is the actual one
                    emit SlotFound(who, fsig, keccak256(abi.encodePacked(ins, field_depth)), uint256(reads[i]));
                    self.slots[who][fsig][keccak256(abi.encodePacked(ins, field_depth))] = uint256(reads[i]);
                    self.finds[who][fsig][keccak256(abi.encodePacked(ins, field_depth))] = true;
                    vm.store(who, reads[i], prev);
                    break;
                }
                vm.store(who, reads[i], prev);
            }
        } else {
            require(false, "stdStorage find(StdStorage): No storage use detected for target.");
        }

        if (!self.finds[who][fsig][keccak256(abi.encodePacked(ins, field_depth))]) {
            // attempt to find a dynamic kind
            return (true, find_dynamic(self));
        } else {
            delete self._target;
            delete self._sig;
            delete self._keys;
            delete self._depth;

            return (false, self.slots[who][fsig][keccak256(abi.encodePacked(ins, field_depth))]);
        }
    }

    function find_dynamic(StdStorage storage self) internal returns (uint256) {
        address who = self._target;
        bytes4 fsig = self._sig;
        uint256 field_depth = self._depth;
        bytes32[] memory ins = self._keys;

        // calldata to test against
        if (self.dynamic_finds[who][fsig][keccak256(abi.encodePacked(ins, field_depth))]) {
            return self.dynamic_slots[who][fsig][keccak256(abi.encodePacked(ins, field_depth))];
        }

        bytes memory cald = abi.encodePacked(fsig, flatten(ins));
        vm.record();
        (, bytes memory rdat) = who.staticcall(cald);
        // chop off offset and length specifier
        rdat = abi.decode(rdat, (bytes));

        (bytes32[] memory reads,) = vm.accesses(address(who));
        uint256[] memory slots = reads_to_dedup_uint(reads);
        if (slots.length == 1) {
            bytes32 curr = vm.load(who, reads[0]);
            if (curr == bytes32(0)) {
                emit WARNING_UninitedSlot(who, uint256(reads[0]));
            }
            if (keccak256(rdat) != keccak256(abi.encodePacked(unpack_single_slot_dynamic(uint256(curr))))) {
                require(
                    false,
                    "stdStorage find(StdStorage): Packed slot. This would cause dangerous overwriting and currently isn't supported."
                );
            }
            emit SlotFound(who, fsig, keccak256(abi.encodePacked(ins, field_depth)), uint256(reads[0]));

            self.dynamic_slots[who][fsig][keccak256(abi.encodePacked(ins, field_depth))] = uint256(reads[0]);
            self.dynamic_finds[who][fsig][keccak256(abi.encodePacked(ins, field_depth))] = true;
        } else if (reads.length > 1) {
            (uint256[] memory matches_slots, bytes[] memory matches) = matching_reads(who, slots);

            for (uint256 i; i < matches.length; i++) {
                if (keccak256(matches[i]) == keccak256(rdat)) {
                    self.dynamic_slots[who][fsig][keccak256(abi.encodePacked(ins, field_depth))] = matches_slots[i];
                    self.dynamic_finds[who][fsig][keccak256(abi.encodePacked(ins, field_depth))] = true;
                    break;
                }
            }
        } else {
            require(false, "stdStorage find(StdStorage): No storage use detected for target.");
        }

        require(
            self.dynamic_finds[who][fsig][keccak256(abi.encodePacked(ins, field_depth))],
            "stdStorage find(StdStorage): Slot(s) not found."
        );

        delete self._target;
        delete self._sig;
        delete self._keys;
        delete self._depth;

        return self.dynamic_slots[who][fsig][keccak256(abi.encodePacked(ins, field_depth))];
    }

    function reads_to_dedup_uint(bytes32[] memory reads) internal pure returns (uint256[] memory) {
        uint256 uniques;
        uint256[] memory slots = new uint256[](reads.length);
        for (uint256 i = 0; i < reads.length; i++) {
            bool is_unique = true;
            for (uint256 j; j < uniques; j++) {
                if (slots[j] == uint256(reads[i])) {
                    is_unique = false;
                    break;
                }
            }
            if (is_unique) {
                slots[uniques] = uint256(reads[i]);
                uniques += 1;
            }
        }

        assembly {
            mstore(slots, uniques)
        }

        return slots;
    }

    function slot_to_data_slot(uint256 slot) internal pure returns (uint256) {
        return uint256(keccak256(abi.encode(slot)));
    }

    // takes a selection of reads, and finds corresponding slots for strings and bytes storage types
    function matching_reads(address who, uint256[] memory reads)
        internal
        view
        returns (uint256[] memory, bytes[] memory)
    {
        uint256 matches;
        uint256[] memory slots = new uint256[](reads.length);
        bytes[] memory potential_matches = new bytes[](reads.length);

        for (uint256 i = 0; i < reads.length; i++) {
            uint256 slot = uint256(reads[i]);
            (uint256 filled, uint256[] memory data_slots) = check_for_data(slot, reads);
            if (filled != 0) {
                bytes memory data = load_data_slots(who, filled, slot, data_slots);
                // add to potential matches
                potential_matches[matches] = data;
                slots[matches] = slot;
                matches += 1;
            } else {
                bytes memory data = unpack_single_slot_dynamic(uint256(vm.load(who, bytes32(slot))));
                potential_matches[matches] = data;
                slots[matches] = slot;
                matches += 1;
            }
        }
        return (slots, potential_matches);
    }

    function check_for_data(uint256 slot, uint256[] memory reads)
        internal
        pure
        returns (uint256 filled, uint256[] memory data_slots)
    {
        uint256 target_data_slot = slot_to_data_slot(slot);
        data_slots = new uint256[](reads.length);
        for (uint256 j = 0; j < reads.length; j++) {
            if (reads[j] == target_data_slot) {
                data_slots[0] = target_data_slot;
                filled += 1;
            } else if (filled > 0 && reads[j] == data_slots[filled - 1] + 1) {
                data_slots[filled] = reads[j];
                filled += 1;
            }
        }
    }

    function load_data_slots(address who, uint256 filled, uint256 slot, uint256[] memory data_slots)
        internal
        view
        returns (bytes memory data)
    {
        // we found a matching data slot
        bytes32[] memory curr = new bytes32[](filled);
        for (uint256 i; i < filled; i++) {
            curr[i] = vm.load(who, bytes32(data_slots[i]));
        }
        // construct the data
        data = flatten(curr);
        // load in length
        // if filled is greater than 1, the main slot has length * 2 + 1,
        // so to get back normal length you do (vm.load - 1) / 2
        // ref: https://docs.soliditylang.org/en/v0.8.17/internals/layout_in_storage.html#bytes-and-string
        uint256 len = (uint256(vm.load(who, bytes32(slot))) - 1) / 2;
        assembly {
            mstore(data, len)
        }
    }

    function target(StdStorage storage self, address _target) internal returns (StdStorage storage) {
        self._target = _target;
        return self;
    }

    function sig(StdStorage storage self, bytes4 _sig) internal returns (StdStorage storage) {
        self._sig = _sig;
        return self;
    }

    function sig(StdStorage storage self, string memory _sig) internal returns (StdStorage storage) {
        self._sig = sigs(_sig);
        return self;
    }

    function with_key(StdStorage storage self, address who) internal returns (StdStorage storage) {
        self._keys.push(bytes32(uint256(uint160(who))));
        return self;
    }

    function with_key(StdStorage storage self, uint256 amt) internal returns (StdStorage storage) {
        self._keys.push(bytes32(amt));
        return self;
    }

    function with_key(StdStorage storage self, bytes32 key) internal returns (StdStorage storage) {
        self._keys.push(key);
        return self;
    }

    function depth(StdStorage storage self, uint256 _depth) internal returns (StdStorage storage) {
        self._depth = _depth;
        return self;
    }

    function read(StdStorage storage self) private returns (bytes memory) {
        address t = self._target;
        (bool is_dynamic, uint256 s) = find(self);
        if (is_dynamic) {
            return read_dynamic(t, s);
        } else {
            return abi.encode(vm.load(t, bytes32(s)));
        }
    }

    function read_dynamic(address t, uint256 slot) internal view returns (bytes memory) {
        uint256 base_slot = uint256(vm.load(t, bytes32(slot)));
        // if the smallest bit is set, we know its a multislot
        // if its not, we know its a single slot
        if (base_slot & 1 == 1) {
            // has to be multi-slot
            uint256 true_len = (base_slot - 1) / 2;
            uint256 num_slots = (true_len / 32) + 1;
            uint256 start_slot = slot_to_data_slot(slot);
            bytes32[] memory vals = new bytes32[](num_slots);
            for (uint256 i; i < num_slots; i++) {
                vals[i] = vm.load(t, bytes32(start_slot + i));
            }

            bytes memory data = flatten(vals);
            assembly {
                mstore(data, true_len)
            }
            return data;
        } else {
            // has to be single slot, get length from last byte
            return unpack_single_slot_dynamic(base_slot);
        }
    }

    function unpack_single_slot_dynamic(uint256 slot_val) private pure returns (bytes memory) {
        uint256 true_len = (slot_val & 0xff) / 2;
        bytes memory data;
        /// @solidity memory-safe-assembly
        assembly {
            let removed_len := shl(shr(slot_val, 8), 8)
            let free_mem := mload(0x40)
            mstore(free_mem, true_len)
            mstore(add(0x20, free_mem), removed_len)
            data := free_mem
            mstore(0x40, add(0x40, free_mem))
        }
        return data;
    }

    function read_bytes32(StdStorage storage self) internal returns (bytes32) {
        return abi.decode(read(self), (bytes32));
    }

    function read_bool(StdStorage storage self) internal returns (bool) {
        int256 v = read_int(self);
        if (v == 0) return false;
        if (v == 1) return true;
        revert("stdStorage read_bool(StdStorage): Cannot decode. Make sure you are reading a bool.");
    }

    function read_address(StdStorage storage self) internal returns (address) {
        return abi.decode(read(self), (address));
    }

    function read_uint(StdStorage storage self) internal returns (uint256) {
        return abi.decode(read(self), (uint256));
    }

    function read_int(StdStorage storage self) internal returns (int256) {
        return abi.decode(read(self), (int256));
    }

    function read_string(StdStorage storage self) internal returns (string memory) {
        bytes memory data = read(self);
        string memory a;
        assembly {
            a := data
        }
        return a;
    }

    function read_bytes(StdStorage storage self) internal returns (bytes memory) {
        return read(self);
    }

    function bytesToBytes32(bytes memory b, uint256 offset) private pure returns (bytes32) {
        bytes32 out;

        uint256 max = b.length > 32 ? 32 : b.length;
        for (uint256 i = 0; i < max; i++) {
            out |= bytes32(b[offset + i] & 0xFF) >> (i * 8);
        }
        return out;
    }

    function flatten(bytes32[] memory b) private pure returns (bytes memory) {
        bytes memory result = new bytes(b.length * 32);
        for (uint256 i = 0; i < b.length; i++) {
            bytes32 k = b[i];
            /// @solidity memory-safe-assembly
            assembly {
                mstore(add(result, add(32, mul(32, i))), k)
            }
        }

        return result;
    }
}

library stdStorage {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    function sigs(string memory sigStr) internal pure returns (bytes4) {
        return stdStorageSafe.sigs(sigStr);
    }

    function find(StdStorage storage self) internal returns (uint256 slot) {
        (, slot) = stdStorageSafe.find(self);
    }

    function find_dynamic(StdStorage storage self) internal returns (uint256) {
        return stdStorageSafe.find_dynamic(self);
    }

    function target(StdStorage storage self, address _target) internal returns (StdStorage storage) {
        return stdStorageSafe.target(self, _target);
    }

    function sig(StdStorage storage self, bytes4 _sig) internal returns (StdStorage storage) {
        return stdStorageSafe.sig(self, _sig);
    }

    function sig(StdStorage storage self, string memory _sig) internal returns (StdStorage storage) {
        return stdStorageSafe.sig(self, _sig);
    }

    function with_key(StdStorage storage self, address who) internal returns (StdStorage storage) {
        return stdStorageSafe.with_key(self, who);
    }

    function with_key(StdStorage storage self, uint256 amt) internal returns (StdStorage storage) {
        return stdStorageSafe.with_key(self, amt);
    }

    function with_key(StdStorage storage self, bytes32 key) internal returns (StdStorage storage) {
        return stdStorageSafe.with_key(self, key);
    }

    function depth(StdStorage storage self, uint256 _depth) internal returns (StdStorage storage) {
        return stdStorageSafe.depth(self, _depth);
    }

    function checked_write(StdStorage storage self, string memory str) internal {
        bytes memory a;
        assembly {
            a := str
        }
        checked_write_dynamic(self, a);
    }

    function checked_write(StdStorage storage self, bytes memory a) internal {
        checked_write_dynamic(self, a);
    }

    function checked_write(StdStorage storage self, address who) internal {
        checked_write(self, bytes32(uint256(uint160(who))));
    }

    function checked_write(StdStorage storage self, uint256 amt) internal {
        checked_write(self, bytes32(amt));
    }

    function checked_write(StdStorage storage self, bool write) internal {
        bytes32 t;
        /// @solidity memory-safe-assembly
        assembly {
            t := write
        }
        checked_write(self, t);
    }

    function checked_write(StdStorage storage self, bytes32 set) internal {
        address who = self._target;
        bytes4 fsig = self._sig;
        uint256 field_depth = self._depth;
        bytes32[] memory ins = self._keys;

        bytes memory cald = abi.encodePacked(fsig, flatten(ins));
        if (!self.finds[who][fsig][keccak256(abi.encodePacked(ins, field_depth))]) {
            find(self);
        }
        bytes32 slot = bytes32(self.slots[who][fsig][keccak256(abi.encodePacked(ins, field_depth))]);

        bytes32 fdat;
        {
            (, bytes memory rdat) = who.staticcall(cald);
            fdat = bytesToBytes32(rdat, 32 * field_depth);
        }
        bytes32 curr = vm.load(who, slot);

        if (fdat != curr) {
            require(
                false,
                "stdStorage find(StdStorage): Packed slot. This would cause dangerous overwriting and currently isn't supported."
            );
        }
        vm.store(who, slot, set);
        delete self._target;
        delete self._sig;
        delete self._keys;
        delete self._depth;
    }

    function checked_write_dynamic(StdStorage storage self, bytes memory set) internal {
        address who = self._target;
        bytes4 fsig = self._sig;
        uint256 field_depth = self._depth;
        bytes32[] memory ins = self._keys;

        bytes memory cald = abi.encodePacked(fsig, flatten(ins));
        if (!self.dynamic_finds[who][fsig][keccak256(abi.encodePacked(ins, field_depth))]) {
            find_dynamic(self);
        }

        bytes32 base_slot = bytes32(self.dynamic_slots[who][fsig][keccak256(abi.encodePacked(ins, field_depth))]);

        bytes memory curr = stdStorageSafe.read_dynamic(who, uint256(base_slot));
        (, bytes memory rdat) = who.staticcall(cald);
        rdat = abi.decode(rdat, (bytes));
        if (keccak256(rdat) != keccak256(curr)) {
            require(
                false,
                "stdStorage find(StdStorage): Packed slot. This would cause dangerous overwriting and currently isn't supported."
            );
        }

        uint256 len;
        assembly {
            len := mload(set)
        }

        if (len > 31) {
            // split
            assembly {
                // set the length to 2*len + 1
                mstore(set, add(1, mul(2, mload(set))))
            }
            uint256 spanned_slots = len / 32 + 1;
            uint256 target_slot = stdStorageSafe.slot_to_data_slot(uint256(base_slot));
            // store the length in the slot
            vm.store(who, base_slot, bytes32(set.length));
            for (uint256 i; i < spanned_slots; i++) {
                bytes32 val;
                assembly {
                    // load the 32 byte chunk
                    let data_start := add(set, 0x20)
                    val := mload(add(data_start, mul(0x20, i)))
                }
                // store the chunk
                vm.store(who, bytes32(target_slot + i), val);
            }

            // reset old extra slots
            uint256 curr_slots = curr.length / 32 + 1;
            if (curr.length / 32 + 1 > spanned_slots) {
                for (uint256 i; i < (curr_slots - spanned_slots); i++) {
                    vm.store(who, bytes32(target_slot + spanned_slots + i), bytes32(0));
                }
            }
        } else {
            // flatten
            uint256 val;
            assembly {
                // read the actual data
                val := mload(add(0x20, set))
            }
            // set the length to length * 2
            val |= len * 2;
            vm.store(who, bytes32(base_slot), bytes32(val));

            // reset old extra slots
            uint256 curr_slots = curr.length / 32 + 1;
            if (curr_slots > 1) {
                uint256 target_slot = stdStorageSafe.slot_to_data_slot(uint256(base_slot));
                for (uint256 i; i < curr_slots; i++) {
                    vm.store(who, bytes32(target_slot + i), bytes32(0));
                }
            }
        }

        delete self._target;
        delete self._sig;
        delete self._keys;
        delete self._depth;
    }

    function read_bytes32(StdStorage storage self) internal returns (bytes32) {
        return stdStorageSafe.read_bytes32(self);
    }

    function read_bool(StdStorage storage self) internal returns (bool) {
        return stdStorageSafe.read_bool(self);
    }

    function read_address(StdStorage storage self) internal returns (address) {
        return stdStorageSafe.read_address(self);
    }

    function read_uint(StdStorage storage self) internal returns (uint256) {
        return stdStorageSafe.read_uint(self);
    }

    function read_int(StdStorage storage self) internal returns (int256) {
        return stdStorageSafe.read_int(self);
    }

    function read_string(StdStorage storage self) internal returns (string memory) {
        return stdStorageSafe.read_string(self);
    }

    function read_bytes(StdStorage storage self) internal returns (bytes memory) {
        return stdStorageSafe.read_bytes(self);
    }

    // Private function so needs to be copied over
    function bytesToBytes32(bytes memory b, uint256 offset) private pure returns (bytes32) {
        bytes32 out;

        uint256 max = b.length > 32 ? 32 : b.length;
        for (uint256 i = 0; i < max; i++) {
            out |= bytes32(b[offset + i] & 0xFF) >> (i * 8);
        }
        return out;
    }

    // Private function so needs to be copied over
    function flatten(bytes32[] memory b) private pure returns (bytes memory) {
        bytes memory result = new bytes(b.length * 32);
        for (uint256 i = 0; i < b.length; i++) {
            bytes32 k = b[i];
            /// @solidity memory-safe-assembly
            assembly {
                mstore(add(result, add(32, mul(32, i))), k)
            }
        }

        return result;
    }
}
