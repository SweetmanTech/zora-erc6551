// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {IRewardsDrop} from "./interfaces/IRewardsDrop.sol";
import {ERC6551} from "./utils/ERC6551.sol";

/*
███████╗██╗    ██╗███████╗███████╗████████╗███╗   ███╗ █████╗ ███╗   ██╗   ███████╗████████╗██╗  ██╗
██╔════╝██║    ██║██╔════╝██╔════╝╚══██╔══╝████╗ ████║██╔══██╗████╗  ██║   ██╔════╝╚══██╔══╝██║  ██║
███████╗██║ █╗ ██║█████╗  █████╗     ██║   ██╔████╔██║███████║██╔██╗ ██║   █████╗     ██║   ███████║
╚════██║██║███╗██║██╔══╝  ██╔══╝     ██║   ██║╚██╔╝██║██╔══██║██║╚██╗██║   ██╔══╝     ██║   ██╔══██║
███████║╚███╔███╔╝███████╗███████╗   ██║   ██║ ╚═╝ ██║██║  ██║██║ ╚████║██╗███████╗   ██║   ██║  ██║
╚══════╝ ╚══╝╚══╝ ╚══════╝╚══════╝   ╚═╝   ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝                                                                                              
*/
contract SmartWalletMinter is ERC6551 {
    /// @notice mint target ERC721Drop
    /// @param _target ERC721Drop contract address
    /// @param _quantity number of tokens
    /// @param _to recipient of tokens
    function mintWithRewards(
        address _target,
        address _to,
        uint256 _quantity,
        string memory _comment,
        address _mintReferral,
        address _registry,
        address _implementation,
        bytes memory _initData
    ) public payable returns (uint256 start) {
        IRewardsDrop erc721 = IRewardsDrop(_target);
        start =
            erc721.mintWithRewards{value: msg.value}(
                _to,
                _quantity,
                _comment,
                _mintReferral
            ) +
            1;
        ERC6551.createTokenBoundAccounts(
            _target,
            start,
            _quantity,
            _registry,
            _implementation,
            _initData
        );
    }
}
