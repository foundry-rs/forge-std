// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.13 <0.9.0;

/// @dev Library for interaction with secp256k1 elliptic curve,
/// described by equation `y^2 = x^3 + ax + b (mod p)`
/// where `a = 0` and `b = 7`.
/// @dev Curve parameters taken from:
/// - https://en.bitcoin.it/wiki/Secp256k1
/// - https://github.com/ethereum/go-ethereum/blob/v1.17.5/crypto/secp256k1/curve.go#L267
library StdSecp256k1 {
    /// @dev Curve parameter `a = 0`.
    uint256 internal constant A = 0x0000000000000000000000000000000000000000000000000000000000000000;
    /// @dev Curve parameter `b = 7`.
    uint256 internal constant B = 0x0000000000000000000000000000000000000000000000000000000000000007;
    /// @dev Prime number, public key `(x, y)`, where `(x, y)` must be in `[0, StdSecp256k1.P)`.
    uint256 internal constant P = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F;
    /// @dev Prime number, scalar `s` must be in `[0, StdSecp256k1.N)`, non-zero scalar must be in `[1, StdSecp256k1.N)`.
    uint256 internal constant N = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141;
    /// @dev X coordinate of generator point (`G`).
    uint256 internal constant GX = 0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798;
    /// @dev Y coordinate of generator point (`G`).
    uint256 internal constant GY = 0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8;

    /// @notice Returns whether the affine point `(x, y)` is the point at infinity `(0, 0)`.
    function isIdentityAffine(uint256 x, uint256 y) internal pure returns (bool) {
        return x == 0 && y == 0;
    }

    /// @notice Returns the secp256k1 point at infinity in affine coordinates as `(0, 0)`.
    function identityAffine() internal pure returns (uint256 x, uint256 y) {
        return (0, 0);
    }

    /// @notice Returns the secp256k1 generator point `G` in affine coordinates as `(GX, GY)`.
    function generatorAffine() internal pure returns (uint256 x, uint256 y) {
        return (GX, GY);
    }

    /// @notice Returns whether the projective point `(x, y, z)` is the point at infinity.
    /// @dev `y` is ignored; infinity is `(0, y, 0)` for any non-zero `y` accepted by Vm,
    /// but normalized form is `(0, 1, 0)`.
    function isIdentityProjective(uint256 x, uint256, uint256 z) internal pure returns (bool) {
        return x == 0 && z == 0;
    }

    /// @notice Returns the secp256k1 point at infinity in projective coordinates as `(0, 1, 0)`.
    function identityProjective() internal pure returns (uint256 x, uint256 y, uint256 z) {
        return (0, 1, 0);
    }

    /// @notice Returns the secp256k1 generator point `G` in projective coordinates as `(GX, GY, 1)`.
    function generatorProjective() internal pure returns (uint256 x, uint256 y, uint256 z) {
        return (GX, GY, 1);
    }
}
