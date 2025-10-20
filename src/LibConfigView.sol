// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {StdConfig} from "./StdConfig.sol";
import {Variable} from "./LibVariable.sol";

/// @notice A view into a StdConfig instance bound to a specific chain ID.
///         Provides ergonomic access to configuration variables without repeating the chain ID.
struct ConfigView {
    StdConfig stdConfig;
    uint256 chainId;
}

/// @notice Library providing helper methods for ConfigView.
///         All methods delegate to StdConfig, automatically passing the bound chainId.
library LibConfigView {
    // -- GETTER ---------------------------------------------------------------

    /// @notice Reads a configuration variable for the bound chain ID.
    /// @param  self The ConfigView instance.
    /// @param  key The configuration variable key.
    /// @return Variable struct containing the type and ABI-encoded value.
    function get(ConfigView memory self, string memory key) internal view returns (Variable memory) {
        return self.stdConfig.get(self.chainId, key);
    }

    // -- SETTERS (SINGLE VALUES) ----------------------------------------------

    /// @notice Sets a boolean configuration variable.
    function set(ConfigView memory self, string memory key, bool value) internal {
        self.stdConfig.set(self.chainId, key, value);
    }

    /// @notice Sets an address configuration variable.
    function set(ConfigView memory self, string memory key, address value) internal {
        self.stdConfig.set(self.chainId, key, value);
    }

    /// @notice Sets a bytes32 configuration variable.
    function set(ConfigView memory self, string memory key, bytes32 value) internal {
        self.stdConfig.set(self.chainId, key, value);
    }

    /// @notice Sets a uint256 configuration variable.
    function set(ConfigView memory self, string memory key, uint256 value) internal {
        self.stdConfig.set(self.chainId, key, value);
    }

    /// @notice Sets an int256 configuration variable.
    function set(ConfigView memory self, string memory key, int256 value) internal {
        self.stdConfig.set(self.chainId, key, value);
    }

    /// @notice Sets a string configuration variable.
    function set(ConfigView memory self, string memory key, string memory value) internal {
        self.stdConfig.set(self.chainId, key, value);
    }

    /// @notice Sets a bytes configuration variable.
    function set(ConfigView memory self, string memory key, bytes memory value) internal {
        self.stdConfig.set(self.chainId, key, value);
    }

    // -- SETTERS (ARRAYS) -----------------------------------------------------

    /// @notice Sets a boolean array configuration variable.
    function set(ConfigView memory self, string memory key, bool[] memory value) internal {
        self.stdConfig.set(self.chainId, key, value);
    }

    /// @notice Sets an address array configuration variable.
    function set(ConfigView memory self, string memory key, address[] memory value) internal {
        self.stdConfig.set(self.chainId, key, value);
    }

    /// @notice Sets a bytes32 array configuration variable.
    function set(ConfigView memory self, string memory key, bytes32[] memory value) internal {
        self.stdConfig.set(self.chainId, key, value);
    }

    /// @notice Sets a uint256 array configuration variable.
    function set(ConfigView memory self, string memory key, uint256[] memory value) internal {
        self.stdConfig.set(self.chainId, key, value);
    }

    /// @notice Sets an int256 array configuration variable.
    function set(ConfigView memory self, string memory key, int256[] memory value) internal {
        self.stdConfig.set(self.chainId, key, value);
    }

    /// @notice Sets a string array configuration variable.
    function set(ConfigView memory self, string memory key, string[] memory value) internal {
        self.stdConfig.set(self.chainId, key, value);
    }

    /// @notice Sets a bytes array configuration variable.
    function set(ConfigView memory self, string memory key, bytes[] memory value) internal {
        self.stdConfig.set(self.chainId, key, value);
    }
}
