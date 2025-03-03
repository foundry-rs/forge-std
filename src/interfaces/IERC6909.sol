// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

import {IERC165} from "./IERC165.sol";

/// @title ERC-6909: Minimal Multi-Token Interface
/// @dev SEE: https://eips.ethereum.org/EIPS/eip-6909
/// NOTE: The ERC-165 identifier for this interface is 0x0f632fb3.
interface IERC6909 is IERC165 {
    /// @notice Emitted when the allowance of a `spender` for an `owner` is set for a token of type `id`.
    event Approval(address indexed owner, address indexed spender, uint256 indexed id, uint256 amount);

    /// @notice Emitted when `owner` grants or revokes operator status for a `spender`.
    event OperatorSet(address indexed owner, address indexed spender, bool approved);

    /// @notice Emitted when `amount` tokens of type `id` are moved from `sender` to `receiver` initiated by `caller`.
    event Transfer(
        address caller, address indexed sender, address indexed receiver, uint256 indexed id, uint256 amount
    );

    /// @notice Returns the amount of tokens of type `id` owned by `owner`.
    function balanceOf(address owner, uint256 id) external view returns (uint256);

    /// @notice Returns the amount of tokens of type `id` that `spender` is allowed to spend on behalf of `owner`.
    /// NOTE: Does not include operator allowances.
    function allowance(address owner, address spender, uint256 id) external view returns (uint256);

    /// @notice Returns true if `spender` is set as an operator for `owner`.
    function isOperator(address owner, address spender) external view returns (bool);

    /// @notice Sets an approval to `spender` for `amount` tokens of type `id` from the caller's tokens.
    /// Must return true.
    function approve(address spender, uint256 id, uint256 amount) external returns (bool);

    /// @notice Grants or revokes unlimited transfer permission of any token id to `spender` for the caller's tokens.
    /// Must return true.
    function setOperator(address spender, bool approved) external returns (bool);

    /// @notice Transfers `amount` of token type `id` from the caller's account to `receiver`.
    /// Must return true.
    function transfer(address receiver, uint256 id, uint256 amount) external returns (bool);

    /// @notice Transfers `amount` of token type `id` from `sender` to `receiver`.
    /// Must return true.
    function transferFrom(address sender, address receiver, uint256 id, uint256 amount) external returns (bool);
}

/// @dev Optional extension of {IERC6909} that adds metadata functions.
interface IERC6909Metadata is IERC6909 {
    /// @notice Returns the name of the token of type `id`.
    function name(uint256 id) external view returns (string memory);

    /// @notice Returns the ticker symbol of the token of type `id`.
    function symbol(uint256 id) external view returns (string memory);

    /// @notice Returns the number of decimals for the token of type `id`.
    function decimals(uint256 id) external view returns (uint8);
}

/// @dev Optional extension of {IERC6909} that adds content URI functions.
interface IERC6909ContentURI is IERC6909 {
    /// @notice Returns URI for the contract.
    function contractURI() external view returns (string memory);

    /// @notice Returns the URI for the token of type `id`.
    function tokenURI(uint256 id) external view returns (string memory);
}

/// @dev Optional extension of {IERC6909} that adds a token supply function.
interface IERC6909TokenSupply is IERC6909 {
    /// @notice Returns the total supply of the token of type `id`.
    function totalSupply(uint256 id) external view returns (uint256);
}
