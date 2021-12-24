// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.10;

contract stdlib {
	Vm vm = Vm(address(bytes20(uint160(uint256(keccak256('hevm cheat code'))))));

	bytes[] public assertionError = abi.encodeWithSignature("Panic(uint256)", 0x01);
	bytes[] public arithmeticError = abi.encodeWithSignature("Panic(uint256)", 0x11);
	bytes[] public divisionError = abi.encodeWithSignature("Panic(uint256)", 0x12);
	bytes[] public enumConversionError = abi.encodeWithSignature("Panic(uint256)", 0x21);
	bytes[] public encodeStorageError = abi.encodeWithSignature("Panic(uint256)", 0x22);
	bytes[] public popError = abi.encodeWithSignature("Panic(uint256)", 0x31);
	bytes[] public indexOOBError = abi.encodeWithSignature("Panic(uint256)", 0x32);
	bytes[] public memOverflowError = abi.encodeWithSignature("Panic(uint256)", 0x41);
	bytes[] public zeroVarError = abi.encodeWithSignature("Panic(uint256)", 0x51);

}
