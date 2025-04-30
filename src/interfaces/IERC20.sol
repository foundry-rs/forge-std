// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

/// @title ERC-20: Token Standard
/// @dev SEE: https://eips.ethereum.org/EIPS/eip-20
interface IERC20 {
    /// @notice Emitted when `value` tokens are moved from one account (`from`) to another (`to`).
    event Transfer(address indexed from, address indexed to, uint256 value);

    /// @notice Emitted when the allowance of a `spender` for an `owner` is set,
    /// where `value` is the new allowance.
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /// @notice Returns the name of the token.
    function name() external view returns (string memory);

    /// @notice Returns the symbol of the token.
    function symbol() external view returns (string memory);

    /// @notice Returns the number of decimal places used for user representation.
    function decimals() external view returns (uint8);

    /// @notice Returns the total supply of tokens in existence.
    function totalSupply() external view returns (uint256);

    /// @notice Returns the balance of tokens owned by a given `account`.
    function balanceOf(address account) external view returns (uint256);

    /// @notice Transfers `amount` tokens from the caller’s account to the `to` address.
    /// @param to The recipient address.
    /// @param amount The number of tokens to transfer.
    /// @return A boolean indicating whether the transfer was successful.
    /// @dev Emits a {Transfer} event.
    function transfer(address to, uint256 amount) external returns (bool);

    /// @notice Transfers `amount` tokens from `from` to `to` using the allowance mechanism.
    /// The caller must have prior approval for at least `amount` tokens from `from`.
    /// The allowance is reduced accordingly.
    /// @param from The address holding the tokens.
    /// @param to The recipient address.
    /// @param amount The number of tokens to transfer.
    /// @return A boolean indicating whether the transfer was successful.
    /// @dev Emits a {Transfer} event.
    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    /// @notice Approves `spender` to transfer up to `amount` tokens on behalf of the caller.
    /// @param spender The address that will be allowed to spend the tokens.
    /// @param amount The maximum number of tokens that can be spent.
    /// @return A boolean indicating whether the approval was successful.
    /// @dev Emits an {Approval} event. Be aware of the allowance front-running attack:
    /// https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729.
    function approve(address spender, uint256 amount) external returns (bool);

    /// @notice Returns the remaining number of tokens that `spender` is allowed to spend on behalf of `owner`.
    /// @param owner The owner of the tokens.
    /// @param spender The spender who has been approved.
    /// @return The number of tokens `spender` can still spend.
    function allowance(address owner, address spender) external view returns (uint256);
}
