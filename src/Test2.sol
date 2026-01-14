// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.13 <0.9.0;

// 💬 ABOUT
// Forge Std's Test with CreateX as the default CREATE2/CREATE3 factory.
// Use this for new tests to leverage the enhanced features of CreateX.

// 🧩 MODULES
import {console} from "./console.sol";
import {console2} from "./console2.sol";
import {safeconsole} from "./safeconsole.sol";
import {StdAssertions} from "./StdAssertions.sol";
import {StdChains} from "./StdChains.sol";
import {StdCheats} from "./StdCheats.sol";
import {StdConstants} from "./StdConstants.sol";
import {stdError} from "./StdError.sol";
import {StdInvariant} from "./StdInvariant.sol";
import {stdJson} from "./StdJson.sol";
import {stdMath} from "./StdMath.sol";
import {StdStorage, stdStorage} from "./StdStorage.sol";
import {StdStyle} from "./StdStyle.sol";
import {stdToml} from "./StdToml.sol";
import {StdUtils} from "./StdUtils.sol";
import {Vm} from "./Vm.sol";
import {ICreateX} from "./interfaces/ICreateX.sol";

// 📦 BOILERPLATE
import {TestBase} from "./Base.sol";

// ⭐️ TEST2
/// @title Test2
/// @notice Enhanced Test contract that defaults to CreateX for deterministic deployments.
/// @dev CreateX provides CREATE2, CREATE3, and deployment-with-initialization patterns.
/// See: https://github.com/pcaversaccio/createx
abstract contract Test2 is TestBase, StdAssertions, StdChains, StdCheats, StdInvariant, StdUtils {
    // Note: IS_TEST() must return true.
    bool public IS_TEST = true;

    /// @dev The CreateX factory instance for convenient access.
    ICreateX internal constant createX = StdConstants.CREATEX;

    /*//////////////////////////////////////////////////////////////////////////
                              CREATE2 DEPLOYMENT HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Deploy a contract using CREATE2 via CreateX.
    /// @param salt The salt for deterministic deployment.
    /// @param initCode The creation bytecode (including constructor args).
    /// @return deployed The address of the deployed contract.
    function deployCreate2(bytes32 salt, bytes memory initCode) internal returns (address deployed) {
        deployed = createX.deployCreate2(salt, initCode);
    }

    /// @notice Deploy a contract using CREATE2 with a pseudo-random salt.
    /// @param initCode The creation bytecode (including constructor args).
    /// @return deployed The address of the deployed contract.
    function deployCreate2(bytes memory initCode) internal returns (address deployed) {
        deployed = createX.deployCreate2(initCode);
    }

    /// @notice Deploy a contract using CREATE2 and call an initializer.
    /// @param salt The salt for deterministic deployment.
    /// @param initCode The creation bytecode (including constructor args).
    /// @param initData The calldata for the initializer function.
    /// @return deployed The address of the deployed contract.
    function deployCreate2AndInit(bytes32 salt, bytes memory initCode, bytes memory initData)
        internal
        returns (address deployed)
    {
        deployed = createX.deployCreate2AndInit(salt, initCode, initData, ICreateX.Values(0, 0));
    }

    /// @notice Deploy a contract using CREATE2 and call an initializer with ETH.
    /// @param salt The salt for deterministic deployment.
    /// @param initCode The creation bytecode (including constructor args).
    /// @param initData The calldata for the initializer function.
    /// @param constructorValue ETH to send to the constructor.
    /// @param initValue ETH to send to the initializer.
    /// @return deployed The address of the deployed contract.
    function deployCreate2AndInit(
        bytes32 salt,
        bytes memory initCode,
        bytes memory initData,
        uint256 constructorValue,
        uint256 initValue
    ) internal returns (address deployed) {
        deployed = createX.deployCreate2AndInit{value: constructorValue + initValue}(
            salt, initCode, initData, ICreateX.Values(constructorValue, initValue)
        );
    }

    /// @notice Compute the CREATE2 address for a deployment via CreateX.
    /// @param salt The salt for deployment.
    /// @param initCodeHash The keccak256 hash of the init code.
    /// @return The computed contract address.
    function computeCreateXCreate2Address(bytes32 salt, bytes32 initCodeHash) internal view returns (address) {
        return createX.computeCreate2Address(salt, initCodeHash);
    }

    /// @notice Compute the CREATE2 address for a deployment via a custom deployer.
    /// @param salt The salt for deployment.
    /// @param initCodeHash The keccak256 hash of the init code.
    /// @param deployer The address of the deployer.
    /// @return The computed contract address.
    function computeCreateXCreate2Address(bytes32 salt, bytes32 initCodeHash, address deployer)
        internal
        pure
        returns (address)
    {
        return ICreateX(deployer).computeCreate2Address(salt, initCodeHash, deployer);
    }

    /*//////////////////////////////////////////////////////////////////////////
                              CREATE3 DEPLOYMENT HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Deploy a contract using CREATE3 via CreateX.
    /// @dev CREATE3 provides addresses independent of init code, useful for upgradeable contracts.
    /// @param salt The salt for deterministic deployment.
    /// @param initCode The creation bytecode (including constructor args).
    /// @return deployed The address of the deployed contract.
    function deployCreate3(bytes32 salt, bytes memory initCode) internal returns (address deployed) {
        deployed = createX.deployCreate3(salt, initCode);
    }

    /// @notice Deploy a contract using CREATE3 with a pseudo-random salt.
    /// @param initCode The creation bytecode (including constructor args).
    /// @return deployed The address of the deployed contract.
    function deployCreate3(bytes memory initCode) internal returns (address deployed) {
        deployed = createX.deployCreate3(initCode);
    }

    /// @notice Deploy a contract using CREATE3 and call an initializer.
    /// @param salt The salt for deterministic deployment.
    /// @param initCode The creation bytecode (including constructor args).
    /// @param initData The calldata for the initializer function.
    /// @return deployed The address of the deployed contract.
    function deployCreate3AndInit(bytes32 salt, bytes memory initCode, bytes memory initData)
        internal
        returns (address deployed)
    {
        deployed = createX.deployCreate3AndInit(salt, initCode, initData, ICreateX.Values(0, 0));
    }

    /// @notice Deploy a contract using CREATE3 and call an initializer with ETH.
    /// @param salt The salt for deterministic deployment.
    /// @param initCode The creation bytecode (including constructor args).
    /// @param initData The calldata for the initializer function.
    /// @param constructorValue ETH to send to the constructor.
    /// @param initValue ETH to send to the initializer.
    /// @return deployed The address of the deployed contract.
    function deployCreate3AndInit(
        bytes32 salt,
        bytes memory initCode,
        bytes memory initData,
        uint256 constructorValue,
        uint256 initValue
    ) internal returns (address deployed) {
        deployed = createX.deployCreate3AndInit{value: constructorValue + initValue}(
            salt, initCode, initData, ICreateX.Values(constructorValue, initValue)
        );
    }

    /// @notice Compute the CREATE3 address for a deployment via CreateX.
    /// @param salt The salt for deployment.
    /// @return The computed contract address.
    function computeCreateXCreate3Address(bytes32 salt) internal view returns (address) {
        return createX.computeCreate3Address(salt);
    }

    /// @notice Compute the CREATE3 address for a deployment via a custom deployer.
    /// @param salt The salt for deployment.
    /// @param deployer The address of the deployer.
    /// @return The computed contract address.
    function computeCreateXCreate3Address(bytes32 salt, address deployer) internal pure returns (address) {
        return ICreateX(deployer).computeCreate3Address(salt, deployer);
    }

    /*//////////////////////////////////////////////////////////////////////////
                              CLONE DEPLOYMENT HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Deploy a minimal proxy (EIP-1167 clone) using CREATE2.
    /// @param salt The salt for deterministic deployment.
    /// @param implementation The address of the implementation contract.
    /// @param initData The calldata for the initializer function (can be empty).
    /// @return proxy The address of the deployed proxy.
    function deployCreate2Clone(bytes32 salt, address implementation, bytes memory initData)
        internal
        returns (address proxy)
    {
        proxy = createX.deployCreate2Clone(salt, implementation, initData);
    }

    /// @notice Deploy a minimal proxy (EIP-1167 clone) using CREATE.
    /// @param implementation The address of the implementation contract.
    /// @param initData The calldata for the initializer function (can be empty).
    /// @return proxy The address of the deployed proxy.
    function deployCreateClone(address implementation, bytes memory initData) internal returns (address proxy) {
        proxy = createX.deployCreateClone(implementation, initData);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                   SALT HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Create a salt with permissioned deploy protection.
    /// @dev The first 20 bytes are set to msg.sender to prevent frontrunning.
    /// @param baseSalt The base salt value.
    /// @return The protected salt.
    function createProtectedSalt(bytes12 baseSalt) internal view returns (bytes32) {
        return bytes32(abi.encodePacked(msg.sender, baseSalt));
    }

    /// @notice Create a salt with cross-chain redeploy protection.
    /// @dev Prevents the same contract from being deployed at the same address on different chains.
    /// @param baseSalt The base salt value.
    /// @return The protected salt.
    function createCrossChainSalt(bytes11 baseSalt) internal view returns (bytes32) {
        return bytes32(abi.encodePacked(msg.sender, uint8(0x01), baseSalt));
    }
}
