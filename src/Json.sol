// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "console2.sol";
import "Vm.sol";

// Helpers for parsing keys into types.
contract JsonParser {
    string path;
    string json;

    address constant private VM_ADDRESS =
        address(bytes20(uint160(uint256(keccak256('hevm cheat code')))));

    Vm public constant vm = Vm(VM_ADDRESS);

    constructor(string memory _path){
        path = _path;
        console2.log("Created JSON parser for json at", path);
    }

    function readJson()
        public
    {
        json = vm.readFile(path);
    }

    function parseRaw(string memory key)
        public
        returns (bytes memory){
        return vm.parseJson(json, key);
    }
    function printRaw()
        view
        public
    {
        console2.log(json);
    }

    function readUint256(string memory key)
        public
        returns (uint256)
    {
        return abi.decode(vm.parseJson(json, key), (uint256));
    }

    function readUintArray(string memory key)
        public
        returns (uint256[] memory)
    {
        return abi.decode(vm.parseJson(json, key), (uint256[]));
    }

    function readInt(string memory key)
        public
        returns (int256)
    {
        return abi.decode(vm.parseJson(json, key), (int256));
    }

    function readIntArray(string memory key)
        public
        returns (int256[] memory)
    {
        return abi.decode(vm.parseJson(json, key), (int256[]));
    }

    function readBytes32(string memory key)
        public
        returns (bytes32)
    {
        return abi.decode(vm.parseJson(json, key), (bytes32));
    }

    function readBytes32Array(string memory key)
        public
        returns (bytes32[] memory)
    {
        return abi.decode(vm.parseJson(json, key), (bytes32[]));
    }

    function readString(string memory key)
        public
        returns (string memory)
    {
        return abi.decode(vm.parseJson(json, key), (string));
    }

    function readStringArray(string memory key)
        public
        returns (string[] memory)
    {
        return abi.decode(vm.parseJson(json, key), (string[]));
    }

    function readAddress(string memory key)
        public
        returns (address)
    {
        return abi.decode(vm.parseJson(json, key), (address));
    }

    function readAddressArray(string memory key)
        public
        returns (address[] memory)
    {
        return abi.decode(vm.parseJson(json, key), (address[]));
    }

    function readBool(string memory key)
        public
        returns (bool)
    {
        return abi.decode(vm.parseJson(json, key), (bool));
    }

    function readBoolArray(string memory key)
        public
        returns (bool[] memory)
    {
        return abi.decode(vm.parseJson(json, key), (bool[]));
    }

    function readBytes(string memory key)
        public
        returns (bytes memory)
    {
        return abi.decode(vm.parseJson(json, key), (bytes));
    }

    function readBytesArray(string memory key)
        public
        returns (bytes[] memory)
    {
        return abi.decode(vm.parseJson(json, key), (bytes[]));
    }


}
