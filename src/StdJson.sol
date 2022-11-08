// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;
pragma experimental ABIEncoderV2;

import "./Vm.sol";

library stdJson {

    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    function parseRaw(string memory json, string memory key)
        internal
        returns (bytes memory)
    {
        return vm.parseJson(json, key);
    }

    function readUint(string memory json, string memory key)
        internal
        returns (uint256)
    {
        return abi.decode(vm.parseJson(json, key), (uint256));
    }

    function readUintArray(string memory json, string memory key)
        internal
        returns (uint256[] memory)
    {
        return abi.decode(vm.parseJson(json, key), (uint256[]));
    }

    function readInt(string memory json, string memory key)
        internal
        returns (int256)
    {
        return abi.decode(vm.parseJson(json, key), (int256));
    }

    function readIntArray(string memory json, string memory key)
        internal
        returns (int256[] memory)
    {
        return abi.decode(vm.parseJson(json, key), (int256[]));
    }

    function readBytes32(string memory json, string memory key)
        internal
        returns (bytes32)
    {
        return abi.decode(vm.parseJson(json, key), (bytes32));
    }

    function readBytes32Array(string memory json, string memory key)
        internal
        returns (bytes32[] memory)
    {
        return abi.decode(vm.parseJson(json, key), (bytes32[]));
    }

    function readString(string memory json, string memory key)
        internal
        returns (string memory)
    {
        return abi.decode(vm.parseJson(json, key), (string));
    }

    function readStringArray(string memory json, string memory key)
        internal
        returns (string[] memory)
    {
        return abi.decode(vm.parseJson(json, key), (string[]));
    }

    function readAddress(string memory json, string memory key)
        internal
        returns (address)
    {
        return abi.decode(vm.parseJson(json, key), (address));
    }

    function readAddressArray(string memory json, string memory key)
        internal
        returns (address[] memory)
    {
        return abi.decode(vm.parseJson(json, key), (address[]));
    }

    function readBool(string memory json, string memory key)
        internal
        returns (bool)
    {
        return abi.decode(vm.parseJson(json, key), (bool));
    }

    function readBoolArray(string memory json, string memory key)
        internal
        returns (bool[] memory)
    {
        return abi.decode(vm.parseJson(json, key), (bool[]));
    }

    function readBytes(string memory json, string memory key)
        internal
        returns (bytes memory)
    {
        return abi.decode(vm.parseJson(json, key), (bytes));
    }

    function readBytesArray(string memory json, string memory key)
        internal
        returns (bytes[] memory)
    {
        return abi.decode(vm.parseJson(json, key), (bytes[]));
    }

    function serialize(string memory jsonKey, string memory key, bool value) external returns(string memory){
        return vm.serializeBool(jsonKey, key, value);
    }

    function serialize(string memory jsonKey, string memory key, bool[] memory value) external returns(string memory){
        return vm.serializeBool(jsonKey, key, value);
    }


    function serialize(string memory jsonKey, string memory key, uint256 value)external returns(string memory){
        return vm.serializeUint(jsonKey, key, value);
    }

    function serialize(string memory jsonKey, string memory key, uint256[] memory value)external returns(string memory){
        return vm.serializeUint(jsonKey, key, value);
    }

    function serialize(string memory jsonKey, string memory key, int256 value)external returns(string memory){
        return vm.serializeInt(jsonKey, key, value);
    }

    function serialize(string memory jsonKey, string memory key, int256[] memory value)external returns(string memory){
        return vm.serializeInt(jsonKey, key, value);
    }

    function serialize(string memory jsonKey, string memory key, address value)external returns(string memory){
        return vm.serializeAddress(jsonKey, key, value);
    }

    function serialize(string memory jsonKey, string memory key, address[] memory value)external returns(string memory){
        return vm.serializeAddress(jsonKey, key, value);
    }

    function serialize(string memory jsonKey, string memory key, bytes32 value)external returns(string memory){
        return vm.serializeBytes32(jsonKey, key, value);
    }

    function serialize(string memory jsonKey, string memory key, bytes32[] memory value)external returns(string memory){
        return vm.serializeBytes32(jsonKey, key, value);
    }

    function serialize(string memory jsonKey, string memory key, string memory value)external returns(string memory){
        return vm.serializeString(jsonKey, key, value);
    }

    function serialize(string memory jsonKey, string memory key, string[] memory value)external returns(string memory){
        return vm.serializeString(jsonKey, key, value);
    }

    function write(string memory jsonKey, string memory path) external {
        vm.writeJson(jsonKey, path);
    }
    function write(string memory jsonKey, string memory path, string memory valueKey) external {
        vm.writeJson(jsonKey, path, valueKey);
    }

}
