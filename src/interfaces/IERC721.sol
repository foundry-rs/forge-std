// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

import {IERC165} from "./IERC165.sol";

/// @title ERC-721: Non-Fungible Token Standard
/// @dev SEE: https://eips.ethereum.org/EIPS/eip-721
/// NOTE: the ERC-165 identifier for this interface is 0x80ac58cd.
interface IERC721 is IERC165 {
    /// @notice Emitted when ownership of an NFT changes by any mechanism.
    /// @dev This event is emitted when NFTs are created (`from == address(0)`) and destroyed (`to == address(0)`).
    /// During contract creation, multiple NFTs may be assigned without emitting `Transfer`.
    /// When a transfer occurs, the approved address for that NFT (if any) is reset to `address(0)`.
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    /// @notice Emitted when the approved address for an NFT is changed or reaffirmed.
    /// @dev The zero address (`address(0)`) indicates there is no approved address.
    /// When a `Transfer` event is emitted, this also resets the approved address for that NFT (if any) to `address(0)`.
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    /// @notice Emitted when an operator is enabled or disabled for an owner.
    /// @dev The operator is granted permission to manage all NFTs of the owner.
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    /// @notice Count all NFTs assigned to an owner.
    /// @param _owner An address for whom to query the balance.
    /// @return The number of NFTs owned by `_owner`, possibly zero.
    /// @dev NFTs assigned to the zero address are considered invalid, and this
    /// function throws for queries about the zero address.
    function balanceOf(address _owner) external view returns (uint256);

    /// @notice Find the owner of an NFT.
    /// @param _tokenId The identifier for an NFT.
    /// @return The address of the owner of the NFT.
    /// @dev NFTs assigned to zero address are considered invalid, and queries
    /// about them do throw.
    function ownerOf(uint256 _tokenId) external view returns (address);

    /// @notice Transfers the ownership of an NFT from one address to another address.
    /// @param _from The current owner of the NFT.
    /// @param _to The new owner.
    /// @param _tokenId The NFT to transfer.
    /// @param data Additional data with no specified format, sent in call to `_to`.
    /// @dev
    /// - Throws unless `msg.sender` is the current owner, an authorized
    /// operator, or the approved address for this NFT.
    /// - Throws if `_from` is not the current owner.
    /// - Throws if `_to` is the zero address.
    /// - Throws if `_tokenId` is not a valid NFT.
    /// When transfer is complete, this function
    /// checks if `_to` is a smart contract (code size > 0). If so, it calls
    /// `onERC721Received` on `_to` and throws if the return value is not
    /// `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable;

    /// @notice Transfers the ownership of an NFT from one address to another address.
    /// @param _from The current owner of the NFT.
    /// @param _to The new owner.
    /// @param _tokenId The NFT to transfer.
    /// @dev This works identically to the other function with an extra data parameter,
    /// except this function just sets data to "".
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;

    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
    /// TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    /// THEY MAY BE PERMANENTLY LOST.
    /// @param _from The current owner of the NFT.
    /// @param _to The new owner.
    /// @param _tokenId The NFT to transfer.
    /// @dev
    /// - Throws unless `msg.sender` is the current owner, an authorized
    /// operator, or the approved address for this NFT.
    /// - Throws if `_from` is not the current owner.
    /// - Throws if `_to` is the zero address.
    /// - Throws if `_tokenId` is not a valid NFT.
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

    /// @notice Change or reaffirm the approved address for an NFT.
    /// @param _approved The new approved NFT controller.
    /// @param _tokenId The NFT to approve.
    /// @dev
    /// - The zero address indicates there is no approved address.
    /// - Throws unless `msg.sender` is the current NFT owner, or an authorized operator of the current owner.
    function approve(address _approved, uint256 _tokenId) external payable;

    /// @notice Enable or disable approval for a third party ("operator") to manage all of `msg.sender`'s assets.
    /// @param _operator Address to add to the set of authorized operators.
    /// @param _approved True if the operator is approved, false to revoke approval.
    /// @dev Emits the ApprovalForAll event. The contract MUST allow multiple operators per owner.
    function setApprovalForAll(address _operator, bool _approved) external;

    /// @notice Get the approved address for a single NFT.
    /// @param _tokenId The NFT to find the approved address for.
    /// @return The approved address for this NFT, or the zero address if there is none.
    /// @dev Throws if `_tokenId` is not a valid NFT.
    function getApproved(uint256 _tokenId) external view returns (address);

    /// @notice Query if an address is an authorized operator for another address.
    /// @param _owner The address that owns the NFTs.
    /// @param _operator The address that acts on behalf of the owner.
    /// @return True if `_operator` is an approved operator for `_owner`, false otherwise.
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

/// @dev Note: the ERC-165 identifier for this interface is 0x150b7a02.
interface IERC721TokenReceiver {
    /// @notice Handle the receipt of an NFT
    /// @param _operator The address which called `safeTransferFrom` function.
    /// @param _from The address which previously owned the token.
    /// @param _tokenId The NFT identifier which is being transferred.
    /// @param _data Additional data with no specified format.
    /// @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))` unless throwing.
    /// @dev The ERC721 smart contract calls this function on the recipient
    /// after a `transfer`. This function MAY throw to revert and reject the
    /// transfer. Return of other than the magic value MUST result in the
    /// transaction being reverted.
    /// NOTE: the contract address is always the message sender.
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data)
        external
        returns (bytes4);
}

/// @title ERC-721 Non-Fungible Token Standard, optional metadata extension
/// @dev See https://eips.ethereum.org/EIPS/eip-721
/// NOTE: the ERC-165 identifier for this interface is 0x5b5e139f.
interface IERC721Metadata is IERC721 {
    /// @notice A descriptive name for a collection of NFTs in this contract.
    function name() external view returns (string memory _name);

    /// @notice An abbreviated name for NFTs in this contract.
    function symbol() external view returns (string memory _symbol);

    /// @notice A distinct Uniform Resource Identifier (URI) for a given asset.
    /// @dev Throws if `_tokenId` is not a valid NFT. URIs are defined in RFC
    /// 3986. The URI may point to a JSON file that conforms to the "ERC721
    /// Metadata JSON Schema".
    function tokenURI(uint256 _tokenId) external view returns (string memory);
}

/// @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
/// @dev See https://eips.ethereum.org/EIPS/eip-721
/// NOTE: the ERC-165 identifier for this interface is 0x780e9d63.
interface IERC721Enumerable is IERC721 {
    /// @notice Count NFTs tracked by this contract.
    /// @return A count of valid NFTs tracked by this contract, where each one of
    /// them has an assigned and queryable owner not equal to the zero address.
    function totalSupply() external view returns (uint256);

    /// @notice Enumerate valid NFTs.
    /// @param _index A counter less than `totalSupply()`.
    /// @return The token identifier for the `_index`th NFT, (sort order not specified).
    /// @dev Throws if `_index` >= `totalSupply()`.
    function tokenByIndex(uint256 _index) external view returns (uint256);

    /// @notice Enumerate NFTs assigned to an owner.
    /// @param _owner An address where we are interested in NFTs owned by them.
    /// @param _index A counter less than `balanceOf(_owner)`.
    /// @return The token identifier for the `_index`th NFT assigned to `_owner` (sort order not specified)
    /// @dev Throws if `_index` >= `balanceOf(_owner)` or if `_owner` is the zero address, representing invalid NFTs.
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);
}
