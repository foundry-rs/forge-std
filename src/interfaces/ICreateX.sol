// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.4;

/// @title CreateX Factory Interface
/// @author pcaversaccio (https://pcaversaccio.com/)
/// @custom:coauthor Matt Solomon (https://mattsolomon.dev/)
/// @notice Interface for the CreateX universal contract deployer.
/// @dev See: https://github.com/pcaversaccio/createx
interface ICreateX {
    /*//////////////////////////////////////////////////////////////////////////
                                     TYPES
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Struct for specifying ETH amounts for constructor and init calls.
    struct Values {
        uint256 constructorAmount;
        uint256 initCallAmount;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                     EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    event ContractCreation(address indexed newContract, bytes32 indexed salt);
    event ContractCreation(address indexed newContract);
    event Create3ProxyContractCreation(address indexed newContract, bytes32 indexed salt);

    /*//////////////////////////////////////////////////////////////////////////
                                  CUSTOM ERRORS
    //////////////////////////////////////////////////////////////////////////*/

    error FailedContractCreation(address emitter);
    error FailedContractInitialisation(address emitter, bytes revertData);
    error InvalidSalt(address emitter);
    error InvalidNonceValue(address emitter);
    error FailedEtherTransfer(address emitter, bytes revertData);

    /*//////////////////////////////////////////////////////////////////////////
                                     CREATE
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Deploys a contract using the CREATE opcode.
    /// @param initCode The creation bytecode of the contract to deploy.
    /// @return newContract The address of the deployed contract.
    function deployCreate(bytes memory initCode) external payable returns (address newContract);

    /// @notice Deploys a contract using CREATE and calls an initializer.
    /// @param initCode The creation bytecode of the contract to deploy.
    /// @param data The calldata for the initializer function.
    /// @param values The ETH amounts for constructor and init call.
    /// @param refundAddress The address to receive any excess ETH.
    /// @return newContract The address of the deployed contract.
    function deployCreateAndInit(
        bytes memory initCode,
        bytes memory data,
        Values memory values,
        address refundAddress
    ) external payable returns (address newContract);

    /// @notice Deploys a contract using CREATE and calls an initializer.
    /// @param initCode The creation bytecode of the contract to deploy.
    /// @param data The calldata for the initializer function.
    /// @param values The ETH amounts for constructor and init call.
    /// @return newContract The address of the deployed contract.
    function deployCreateAndInit(bytes memory initCode, bytes memory data, Values memory values)
        external
        payable
        returns (address newContract);

    /// @notice Deploys a minimal proxy (clone) using CREATE.
    /// @param implementation The address of the implementation contract.
    /// @param data The calldata for the initializer function.
    /// @return proxy The address of the deployed proxy.
    function deployCreateClone(address implementation, bytes memory data) external payable returns (address proxy);

    /// @notice Computes the address of a contract deployed via CREATE.
    /// @param deployer The address of the deployer.
    /// @param nonce The nonce of the deployer.
    /// @return computedAddress The computed contract address.
    function computeCreateAddress(address deployer, uint256 nonce) external view returns (address computedAddress);

    /// @notice Computes the address of a contract deployed via CREATE from this contract.
    /// @param nonce The nonce of this contract.
    /// @return computedAddress The computed contract address.
    function computeCreateAddress(uint256 nonce) external view returns (address computedAddress);

    /*//////////////////////////////////////////////////////////////////////////
                                     CREATE2
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Deploys a contract using CREATE2 with a given salt.
    /// @param salt The salt for deterministic deployment.
    /// @param initCode The creation bytecode of the contract to deploy.
    /// @return newContract The address of the deployed contract.
    function deployCreate2(bytes32 salt, bytes memory initCode) external payable returns (address newContract);

    /// @notice Deploys a contract using CREATE2 with a pseudo-random salt.
    /// @param initCode The creation bytecode of the contract to deploy.
    /// @return newContract The address of the deployed contract.
    function deployCreate2(bytes memory initCode) external payable returns (address newContract);

    /// @notice Deploys a contract using CREATE2 and calls an initializer.
    /// @param salt The salt for deterministic deployment.
    /// @param initCode The creation bytecode of the contract to deploy.
    /// @param data The calldata for the initializer function.
    /// @param values The ETH amounts for constructor and init call.
    /// @param refundAddress The address to receive any excess ETH.
    /// @return newContract The address of the deployed contract.
    function deployCreate2AndInit(
        bytes32 salt,
        bytes memory initCode,
        bytes memory data,
        Values memory values,
        address refundAddress
    ) external payable returns (address newContract);

    /// @notice Deploys a contract using CREATE2 and calls an initializer.
    /// @param salt The salt for deterministic deployment.
    /// @param initCode The creation bytecode of the contract to deploy.
    /// @param data The calldata for the initializer function.
    /// @param values The ETH amounts for constructor and init call.
    /// @return newContract The address of the deployed contract.
    function deployCreate2AndInit(
        bytes32 salt,
        bytes memory initCode,
        bytes memory data,
        Values memory values
    ) external payable returns (address newContract);

    /// @notice Deploys a contract using CREATE2 and calls an initializer (pseudo-random salt).
    /// @param initCode The creation bytecode of the contract to deploy.
    /// @param data The calldata for the initializer function.
    /// @param values The ETH amounts for constructor and init call.
    /// @param refundAddress The address to receive any excess ETH.
    /// @return newContract The address of the deployed contract.
    function deployCreate2AndInit(
        bytes memory initCode,
        bytes memory data,
        Values memory values,
        address refundAddress
    ) external payable returns (address newContract);

    /// @notice Deploys a contract using CREATE2 and calls an initializer (pseudo-random salt).
    /// @param initCode The creation bytecode of the contract to deploy.
    /// @param data The calldata for the initializer function.
    /// @param values The ETH amounts for constructor and init call.
    /// @return newContract The address of the deployed contract.
    function deployCreate2AndInit(bytes memory initCode, bytes memory data, Values memory values)
        external
        payable
        returns (address newContract);

    /// @notice Deploys a minimal proxy (clone) using CREATE2.
    /// @param salt The salt for deterministic deployment.
    /// @param implementation The address of the implementation contract.
    /// @param data The calldata for the initializer function.
    /// @return proxy The address of the deployed proxy.
    function deployCreate2Clone(bytes32 salt, address implementation, bytes memory data)
        external
        payable
        returns (address proxy);

    /// @notice Deploys a minimal proxy (clone) using CREATE2 (pseudo-random salt).
    /// @param implementation The address of the implementation contract.
    /// @param data The calldata for the initializer function.
    /// @return proxy The address of the deployed proxy.
    function deployCreate2Clone(address implementation, bytes memory data) external payable returns (address proxy);

    /// @notice Computes the CREATE2 address for a contract.
    /// @param salt The salt for deployment.
    /// @param initCodeHash The keccak256 hash of the init code.
    /// @param deployer The address of the deployer.
    /// @return computedAddress The computed contract address.
    function computeCreate2Address(bytes32 salt, bytes32 initCodeHash, address deployer)
        external
        pure
        returns (address computedAddress);

    /// @notice Computes the CREATE2 address for a contract deployed from this factory.
    /// @param salt The salt for deployment.
    /// @param initCodeHash The keccak256 hash of the init code.
    /// @return computedAddress The computed contract address.
    function computeCreate2Address(bytes32 salt, bytes32 initCodeHash)
        external
        view
        returns (address computedAddress);

    /*//////////////////////////////////////////////////////////////////////////
                                     CREATE3
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Deploys a contract using CREATE3 (address independent of initcode).
    /// @param salt The salt for deterministic deployment.
    /// @param initCode The creation bytecode of the contract to deploy.
    /// @return newContract The address of the deployed contract.
    function deployCreate3(bytes32 salt, bytes memory initCode) external payable returns (address newContract);

    /// @notice Deploys a contract using CREATE3 with a pseudo-random salt.
    /// @param initCode The creation bytecode of the contract to deploy.
    /// @return newContract The address of the deployed contract.
    function deployCreate3(bytes memory initCode) external payable returns (address newContract);

    /// @notice Deploys a contract using CREATE3 and calls an initializer.
    /// @param salt The salt for deterministic deployment.
    /// @param initCode The creation bytecode of the contract to deploy.
    /// @param data The calldata for the initializer function.
    /// @param values The ETH amounts for constructor and init call.
    /// @param refundAddress The address to receive any excess ETH.
    /// @return newContract The address of the deployed contract.
    function deployCreate3AndInit(
        bytes32 salt,
        bytes memory initCode,
        bytes memory data,
        Values memory values,
        address refundAddress
    ) external payable returns (address newContract);

    /// @notice Deploys a contract using CREATE3 and calls an initializer.
    /// @param salt The salt for deterministic deployment.
    /// @param initCode The creation bytecode of the contract to deploy.
    /// @param data The calldata for the initializer function.
    /// @param values The ETH amounts for constructor and init call.
    /// @return newContract The address of the deployed contract.
    function deployCreate3AndInit(
        bytes32 salt,
        bytes memory initCode,
        bytes memory data,
        Values memory values
    ) external payable returns (address newContract);

    /// @notice Deploys a contract using CREATE3 and calls an initializer (pseudo-random salt).
    /// @param initCode The creation bytecode of the contract to deploy.
    /// @param data The calldata for the initializer function.
    /// @param values The ETH amounts for constructor and init call.
    /// @param refundAddress The address to receive any excess ETH.
    /// @return newContract The address of the deployed contract.
    function deployCreate3AndInit(
        bytes memory initCode,
        bytes memory data,
        Values memory values,
        address refundAddress
    ) external payable returns (address newContract);

    /// @notice Deploys a contract using CREATE3 and calls an initializer (pseudo-random salt).
    /// @param initCode The creation bytecode of the contract to deploy.
    /// @param data The calldata for the initializer function.
    /// @param values The ETH amounts for constructor and init call.
    /// @return newContract The address of the deployed contract.
    function deployCreate3AndInit(bytes memory initCode, bytes memory data, Values memory values)
        external
        payable
        returns (address newContract);

    /// @notice Computes the CREATE3 address for a contract.
    /// @param salt The salt for deployment.
    /// @param deployer The address of the deployer.
    /// @return computedAddress The computed contract address.
    function computeCreate3Address(bytes32 salt, address deployer) external pure returns (address computedAddress);

    /// @notice Computes the CREATE3 address for a contract deployed from this factory.
    /// @param salt The salt for deployment.
    /// @return computedAddress The computed contract address.
    function computeCreate3Address(bytes32 salt) external view returns (address computedAddress);
}
