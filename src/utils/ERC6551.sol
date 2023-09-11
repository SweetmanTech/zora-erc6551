// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IERC6551Registry} from "lib/ERC6551/src/interfaces/IERC6551Registry.sol";

/*
███████╗██╗    ██╗███████╗███████╗████████╗███╗   ███╗ █████╗ ███╗   ██╗   ███████╗████████╗██╗  ██╗
██╔════╝██║    ██║██╔════╝██╔════╝╚══██╔══╝████╗ ████║██╔══██╗████╗  ██║   ██╔════╝╚══██╔══╝██║  ██║
███████╗██║ █╗ ██║█████╗  █████╗     ██║   ██╔████╔██║███████║██╔██╗ ██║   █████╗     ██║   ███████║
╚════██║██║███╗██║██╔══╝  ██╔══╝     ██║   ██║╚██╔╝██║██╔══██║██║╚██╗██║   ██╔══╝     ██║   ██╔══██║
███████║╚███╔███╔╝███████╗███████╗   ██║   ██║ ╚═╝ ██║██║  ██║██║ ╚████║██╗███████╗   ██║   ██║  ██║
╚══════╝ ╚══╝╚══╝ ╚══════╝╚══════╝   ╚═╝   ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝                                                                                              
*/
/// @title ERC6551 contract for handling ERC6551 token-bound accounts.
contract ERC6551 {
    /// @notice Creates Token Bound Accounts (TBA) with ERC6551.
    /// @dev Internal function used to create TBAs for a given ERC721 contract.
    /// @param _target Target ERC721 contract address.
    /// @param _startTokenId Token ID to start from.
    /// @param _quantity Number of token-bound accounts to create.
    /// @param _registry Number of token-bound accounts to create.
    /// @param _implementation Number of token-bound accounts to create.
    /// @param _initData Number of token-bound accounts to create.
    function createTokenBoundAccounts(
        address _target,
        uint256 _startTokenId,
        uint256 _quantity,
        address _registry,
        address _implementation,
        bytes _initData
    ) internal {
        IERC6551Registry registry = IERC6551Registry(_registry);
        for (uint256 i = 0; i < _quantity; i++) {
            address smartWallet = registry.createAccount(
                _implementation,
                block.chainid,
                _target,
                _startTokenId + i,
                0,
                _initData
            );
        }
    }
}
