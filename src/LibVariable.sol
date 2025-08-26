// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// Enable globaly.
using LibVariable for Variable global;

struct Variable {
    Type ty;
    bytes data;
}

struct Type {
    TypeKind kind;
    bool isArray;
}

enum TypeKind {
    None,
    Bool,
    Address,
    Uint256,
    Bytes32,
    String,
    Bytes
}

/// @notice Library for type-safe coercion of the `Variable` struct to concrete types.
///
/// @dev    Ensures that when a `Variable` is cast to a concrete Solidity type, the operation is safe and the
///         underlying type matches what is expected.
///         Provides functions to check types, convert them to strings, and coerce `Variable` instances into
///         both single values and arrays of various types.
///
///         Usage example:
///         ```solidity
///         import {LibVariable} from "./LibVariable.sol";
///
///         contract MyContract {
///             using LibVariable for Variable;
///             StdConfig config;   // Assume 'config' is an instance of `StdConfig` and has already been loaded.
///
///             function readValues() public {
///                 // Retrieve a 'uint256' value from the config.
///                 uint256 myNumber = config.get("important_number").toUint();
///
///                 // Would revert with `TypeMismatch` as 'important_number' isn't a `uint256` in the config file.
///                 // string memory notANumber = config.get("important_number").toString();
///
///                 // Retrieve a address array from the config.
///                 string[] memory admins = config.get("whitelisted_admins").toAddressArray();
///          }
///      }
///      ```
library LibVariable {
    error NotInitialized();
    error TypeMismatch(string expected, string actual);

    // -- TYPE HELPERS ----------------------------------------------------

    /// @notice Compares two Type instances for equality.
    function isEqual(Type memory self, Type memory other) internal pure returns (bool) {
        return self.kind == other.kind && self.isArray == other.isArray;
    }

    /// @notice Compares two Type instances for equality. Reverts if they are not equal.
    function assertEq(Type memory self, Type memory other) internal pure {
        if (!isEqual(self, other)) {
            revert TypeMismatch(toString(other), toString(self));
        }
    }

    /// @notice Converts a Type struct to its full string representation (i.e. "uint256[]").
    function toString(Type memory self) internal pure returns (string memory) {
        string memory tyStr = toString(self.kind);
        if (!self.isArray || self.kind == TypeKind.None) {
            return tyStr;
        } else {
            return string(abi.encodePacked(tyStr, "[]"));
        }
    }

    /// @dev Converts a `TypeKind` enum to its base string representation.
    function toString(TypeKind self) internal pure returns (string memory) {
        if (self == TypeKind.Bool) return "bool";
        if (self == TypeKind.Address) return "address";
        if (self == TypeKind.Uint256) return "uint256";
        if (self == TypeKind.Bytes32) return "bytes32";
        if (self == TypeKind.String) return "string";
        if (self == TypeKind.Bytes) return "bytes";
        return "none";
    }

    /// @dev Converts a `TypeKind` enum to its base string representation.
    function toTomlKey(TypeKind self) internal pure returns (string memory) {
        if (self == TypeKind.Bool) return "bool";
        if (self == TypeKind.Address) return "address";
        if (self == TypeKind.Uint256) return "uint";
        if (self == TypeKind.Bytes32) return "bytes32";
        if (self == TypeKind.String) return "string";
        if (self == TypeKind.Bytes) return "bytes";
        return "none";
    }

    // -- VARIABLE HELPERS ----------------------------------------------------

    /// @dev Checks if a `Variable` has been initialized and matches the expected type reverting if not.
    modifier check(Variable memory self, Type memory expected) {
        assertExists(self);
        assertEq(self.ty, expected);
        _;
    }

    /// @dev Checks if a `Variable` has been initialized, reverting if not.
    function assertExists(Variable memory self) public pure {
        if (self.ty.kind == TypeKind.None) {
            revert NotInitialized();
        }
    }

    // -- VARIABLE COERCION FUNCTIONS (SINGLE VALUES) --------------------------

    /// @notice Coerces a `Variable` to a `bool` value.
    function toBool(Variable memory self) internal pure check(self, Type(TypeKind.Bool, false)) returns (bool) {
        return abi.decode(self.data, (bool));
    }

    /// @notice Coerces a `Variable` to a `uint256` value.
    function toUint(Variable memory self) internal pure check(self, Type(TypeKind.Uint256, false)) returns (uint256) {
        return abi.decode(self.data, (uint256));
    }

    /// @notice Coerces a `Variable` to an `address` value.
    function toAddress(Variable memory self)
        internal
        pure
        check(self, Type(TypeKind.Address, false))
        returns (address)
    {
        return abi.decode(self.data, (address));
    }

    /// @notice Coerces a `Variable` to a `bytes32` value.
    function toBytes32(Variable memory self)
        internal
        pure
        check(self, Type(TypeKind.Bytes32, false))
        returns (bytes32)
    {
        return abi.decode(self.data, (bytes32));
    }

    /// @notice Coerces a `Variable` to a `string` value.
    function toString(Variable memory self)
        internal
        pure
        check(self, Type(TypeKind.String, false))
        returns (string memory)
    {
        return abi.decode(self.data, (string));
    }

    /// @notice Coerces a `Variable` to a `bytes` value.
    function toBytes(Variable memory self)
        internal
        pure
        check(self, Type(TypeKind.Bytes, false))
        returns (bytes memory)
    {
        return abi.decode(self.data, (bytes));
    }

    // -- VARIABLE COERCION FUNCTIONS (ARRAYS) ---------------------------------

    /// @notice Coerces a `Variable` to a `bool` array.
    function toBoolArray(Variable memory self)
        internal
        pure
        check(self, Type(TypeKind.Bool, true))
        returns (bool[] memory)
    {
        return abi.decode(self.data, (bool[]));
    }

    /// @notice Coerces a `Variable` to a `uint256` array.
    function toUintArray(Variable memory self)
        internal
        pure
        check(self, Type(TypeKind.Uint256, true))
        returns (uint256[] memory)
    {
        return abi.decode(self.data, (uint256[]));
    }

    /// @notice Coerces a `Variable` to an `address` array.
    function toAddressArray(Variable memory self)
        internal
        pure
        check(self, Type(TypeKind.Address, true))
        returns (address[] memory)
    {
        return abi.decode(self.data, (address[]));
    }

    /// @notice Coerces a `Variable` to a `bytes32` array.
    function toBytes32Array(Variable memory self)
        internal
        pure
        check(self, Type(TypeKind.Bytes32, true))
        returns (bytes32[] memory)
    {
        return abi.decode(self.data, (bytes32[]));
    }

    /// @notice Coerces a `Variable` to a `string` array.
    function toStringArray(Variable memory self)
        internal
        pure
        check(self, Type(TypeKind.String, true))
        returns (string[] memory)
    {
        return abi.decode(self.data, (string[]));
    }

    /// @notice Coerces a `Variable` to a `bytes` array.
    function toBytesArray(Variable memory self)
        internal
        pure
        check(self, Type(TypeKind.Bytes, true))
        returns (bytes[] memory)
    {
        return abi.decode(self.data, (bytes[]));
    }
}
