// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@ERC721A/contracts/ERC721A.sol";

contract LensHubMock is ERC721A {
    constructor() ERC721A("name", "SYM") {}

    function collect(
        uint256 profileId,
        uint256 pubId,
        bytes calldata data
    ) external returns (uint256) {
        _mintNFTs(msg.sender, 1);
        uint256 firstMintedTokenId = _lastMintedTokenId();
        return firstMintedTokenId;
    }

    /// @notice return nft contract address for a publication
    function getCollectNFT(
        uint256 profileId,
        uint256 pubId
    ) external view returns (address) {
        return address(this);
    }

    /// @notice return collect module address for a publication
    function getCollectModule(
        uint256 profileId,
        uint256 pubId
    ) external view returns (address) {
        return address(0x1996);
    }

    /// @notice Getter for last minted token ID (gets next token id and subtracts 1)
    function _lastMintedTokenId() internal view returns (uint256) {
        return _nextTokenId() - 1;
    }

    /// @notice Function to mint NFTs
    /// @dev (important: Does not enforce max supply limit, enforce that limit earlier)
    /// @dev This batches in size of 8 as per recommended by ERC721A creators
    /// @param to address to mint NFTs to
    /// @param quantity number of NFTs to mint
    function _mintNFTs(address to, uint256 quantity) internal {
        uint256 MAX_MINT_BATCH_SIZE = 8;
        do {
            uint256 toMint = quantity > MAX_MINT_BATCH_SIZE
                ? MAX_MINT_BATCH_SIZE
                : quantity;
            _mint({to: to, quantity: toMint});
            quantity -= toMint;
        } while (quantity > 0);
    }

    /// @notice Start token ID for minting (1-100 vs 0-99)
    function _startTokenId() internal pure override returns (uint256) {
        return 1;
    }
}
