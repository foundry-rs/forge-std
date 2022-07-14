// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "../Script.sol";
import "../Test.sol";

contract ScriptTest is Test {
    ScriptMock internal script = new ScriptMock();

     function testGenerateCorrectAddress() external {
        address creation = script._computeCreateAddress(0x6C9FC64A53c1b71FB3f9Af64d1ae3A4931A5f4E9, 14);
        assertEq(creation, 0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45);
    }
}

contract ScriptMock is Script {
    function _computeCreateAddress(address deployer, uint256 nonce) external pure returns (address) {
        return computeCreateAddress(deployer, nonce);
    }
}