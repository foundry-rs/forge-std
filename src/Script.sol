// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0 <0.9.0;

import "./Vm.sol";
import "./console.sol";
import "./console2.sol";

abstract contract Script {
    bool public IS_SCRIPT = true;
    address constant private VM_ADDRESS =
        address(bytes20(uint160(uint256(keccak256('hevm cheat code')))));

    Vm public constant vm = Vm(VM_ADDRESS);

    // Calcuate the corresponding contract creation address for a given address and nonce
    function addressFrom(address origin, uint256 nonce) internal pure returns (address creation) {
        bytes memory data;
        if (nonce == 0x00)
            data = abi.encodePacked(bytes1(0xd6), bytes1(0x94), origin, bytes1(0x80));
        else if (nonce <= 0x7f)
            data = abi.encodePacked(bytes1(0xd6), bytes1(0x94), origin, uint8(nonce));
        else if (nonce <= 0xff)
            data = abi.encodePacked(
                bytes1(0xd7),
                bytes1(0x94),
                origin,
                bytes1(0x81),
                uint8(nonce)
            );
        else if (nonce <= 0xffff)
            data = abi.encodePacked(
                bytes1(0xd8),
                bytes1(0x94),
                origin,
                bytes1(0x82),
                uint16(nonce)
            );
        else if (nonce <= 0xffffff)
            data = abi.encodePacked(
                bytes1(0xd9),
                bytes1(0x94),
                origin,
                bytes1(0x83),
                uint24(nonce)
            );
        else
            data = abi.encodePacked(
                bytes1(0xda),
                bytes1(0x94),
                origin,
                bytes1(0x84),
                uint32(nonce)
            );
        bytes32 hash = keccak256(data);
        assembly {
            mstore(0, hash)
            creation := mload(0)
        }
    }
}
