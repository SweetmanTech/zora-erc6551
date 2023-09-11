// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {IERC721Drop} from "./IERC721Drop.sol";

interface IRewardsDrop is IERC721Drop {
    /// @notice Mint a quantity of tokens with a comment that will pay out rewards
    /// @param recipient recipient of the tokens
    /// @param quantity quantity to purchase
    /// @param comment comment to include in the IERC721Drop.Sale event
    /// @param mintReferral The finder of the mint
    /// @return tokenId of the first token minted
    function mintWithRewards(
        address recipient,
        uint256 quantity,
        string calldata comment,
        address mintReferral
    ) external payable returns (uint256);
}
