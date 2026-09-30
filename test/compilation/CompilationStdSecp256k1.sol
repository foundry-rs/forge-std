// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.13 <0.9.0;

import {StdSecp256k1} from "../../src/StdSecp256k1.sol";

// Exercise the standalone library in the compiler and via-ir CI matrix.
contract CompilationStdSecp256k1 {
    function identities() external pure returns (uint256, uint256, uint256, uint256, uint256) {
        (uint256 x, uint256 y) = StdSecp256k1.identityAffine();
        (uint256 px, uint256 py, uint256 pz) = StdSecp256k1.identityProjective();
        return (x, y, px, py, pz);
    }

    function generators() external pure returns (uint256, uint256, uint256, uint256, uint256) {
        (uint256 x, uint256 y) = StdSecp256k1.generatorAffine();
        (uint256 px, uint256 py, uint256 pz) = StdSecp256k1.generatorProjective();
        return (x, y, px, py, pz);
    }

    function predicates(uint256 x, uint256 y, uint256 z, uint256 scalar)
        external
        pure
        returns (bool, bool, bool, bool, bool)
    {
        return (
            StdSecp256k1.isIdentityAffine(x, y),
            StdSecp256k1.isIdentityProjective(x, y, z),
            StdSecp256k1.isOnCurve(x, y),
            StdSecp256k1.isValidScalar(scalar),
            StdSecp256k1.isValidNonZeroScalar(scalar)
        );
    }

    function encodings(uint256 x, uint256 y) external pure returns (uint256, uint256, uint256, address) {
        return (
            StdSecp256k1.yParity(y),
            StdSecp256k1.yParityEthereum(y),
            StdSecp256k1.yCompressed(y),
            StdSecp256k1.toAddress(x, y)
        );
    }
}
