// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.13 <0.9.0;

import {StdSecp256k1} from "../src/StdSecp256k1.sol";
import {Test} from "../src/Test.sol";

contract StdSecp256k1Test is Test {
    function test_CurveParameters() external pure {
        assertEq(StdSecp256k1.A, 0);
        assertEq(StdSecp256k1.B, 7);
        assertEq(StdSecp256k1.P, type(uint256).max - (uint256(1) << 32) - 976);
        assertEq(StdSecp256k1.N, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141);
    }

    function test_AffineIdentity() external pure {
        (uint256 x, uint256 y) = StdSecp256k1.identityAffine();
        assertEq(x, 0);
        assertEq(y, 0);
        assertTrue(StdSecp256k1.isIdentityAffine(x, y));
        assertFalse(StdSecp256k1.isIdentityAffine(0, 1));
        assertFalse(StdSecp256k1.isIdentityAffine(1, 0));
        assertFalse(StdSecp256k1.isOnCurve(x, y));
    }

    function test_ProjectiveIdentity() external pure {
        (uint256 x, uint256 y, uint256 z) = StdSecp256k1.identityProjective();
        assertEq(x, 0);
        assertEq(y, 1);
        assertEq(z, 0);
        assertTrue(StdSecp256k1.isIdentityProjective(x, y, z));
        assertTrue(StdSecp256k1.isIdentityProjective(0, StdSecp256k1.P - 1, 0));
        assertFalse(StdSecp256k1.isIdentityProjective(0, 0, 0));
        assertFalse(StdSecp256k1.isIdentityProjective(0, StdSecp256k1.P, 0));
        assertFalse(StdSecp256k1.isIdentityProjective(0, type(uint256).max, 0));
        assertFalse(StdSecp256k1.isIdentityProjective(1, 1, 0));
        assertFalse(StdSecp256k1.isIdentityProjective(0, 1, 1));
    }

    function test_Generator() external pure {
        (uint256 x, uint256 y) = StdSecp256k1.generatorAffine();
        assertEq(x, 0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798);
        assertEq(y, 0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8);
        assertTrue(StdSecp256k1.isOnCurve(x, y));
        assertFalse(StdSecp256k1.isIdentityAffine(x, y));
        assertTrue(StdSecp256k1.isOnCurve(x, StdSecp256k1.P - y));
        assertFalse(StdSecp256k1.isOnCurve(x, y + 1));
        assertEq(StdSecp256k1.toAddress(x, y), address(0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf));

        (uint256 projectiveX, uint256 projectiveY, uint256 z) = StdSecp256k1.generatorProjective();
        assertEq(projectiveX, x);
        assertEq(projectiveY, y);
        assertEq(z, 1);
        assertFalse(StdSecp256k1.isIdentityProjective(projectiveX, projectiveY, z));
    }

    function test_IsOnCurveRejectsNonCanonicalCoordinates() external pure {
        uint256 x1 = 1;
        uint256 y1 = 0x4218F20AE6C646B363DB68605822FB14264CA8D2587FDD6FBC750D587E76A7EE;
        assertTrue(StdSecp256k1.isOnCurve(x1, y1));
        assertFalse(StdSecp256k1.isOnCurve(x1 + StdSecp256k1.P, y1));

        uint256 x2 = 0x1FE1E5EF3FCEB5C135AB7741333CE5A6E80D68167653F6B2B24BCBCFAAAFF507;
        uint256 y2 = 1;
        assertTrue(StdSecp256k1.isOnCurve(x2, y2));
        assertFalse(StdSecp256k1.isOnCurve(x2, y2 + StdSecp256k1.P));
    }

    function test_ScalarBounds() external pure {
        assertTrue(StdSecp256k1.isValidScalar(0));
        assertFalse(StdSecp256k1.isValidNonZeroScalar(0));
        assertTrue(StdSecp256k1.isValidNonZeroScalar(1));
        assertTrue(StdSecp256k1.isValidScalar(StdSecp256k1.N - 1));
        assertTrue(StdSecp256k1.isValidNonZeroScalar(StdSecp256k1.N - 1));
        assertFalse(StdSecp256k1.isValidScalar(StdSecp256k1.N));
        assertFalse(StdSecp256k1.isValidNonZeroScalar(StdSecp256k1.N));
        assertFalse(StdSecp256k1.isValidScalar(type(uint256).max));
        assertFalse(StdSecp256k1.isValidNonZeroScalar(type(uint256).max));
    }

    function test_ParityBounds() external pure {
        assertEq(StdSecp256k1.yParity(0), 0);
        assertEq(StdSecp256k1.yParity(type(uint256).max), 1);
        assertEq(StdSecp256k1.yParityEthereum(0), 27);
        assertEq(StdSecp256k1.yParityEthereum(type(uint256).max), 28);
        assertEq(StdSecp256k1.yCompressed(0), 2);
        assertEq(StdSecp256k1.yCompressed(type(uint256).max), 3);
    }

    function testFuzz_Parity(uint256 y) external pure {
        assertEq(StdSecp256k1.yParity(y), y % 2);
        assertEq(StdSecp256k1.yParityEthereum(y), 27 + y % 2);
        assertEq(StdSecp256k1.yCompressed(y), 2 + y % 2);
    }

    function testFuzz_PublicKey(uint256 privateKey) external pure {
        privateKey = bound(privateKey, 1, StdSecp256k1.N - 1);
        (uint256 x, uint256 y) = vm.ecMulAffine(StdSecp256k1.GX, StdSecp256k1.GY, privateKey);
        assertTrue(StdSecp256k1.isOnCurve(x, y));
        assertFalse(StdSecp256k1.isIdentityAffine(x, y));
        assertEq(StdSecp256k1.toAddress(x, y), vm.addr(privateKey));
    }

    function testFuzz_ToAddress(uint256 x, uint256 y) external pure {
        assertEq(StdSecp256k1.toAddress(x, y), address(uint160(uint256(keccak256(abi.encode(x, y))))));
    }
}
