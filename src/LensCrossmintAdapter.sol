// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/*
██████╗ ██╗███████╗███████╗
██╔══██╗██║██╔════╝██╔════╝
██████╔╝██║█████╗  █████╗  
██╔══██╗██║██╔══╝  ██╔══╝  
██║  ██║██║██║     ██║     
╚═╝  ╚═╝╚═╝╚═╝     ╚═╝                                                                                                  
*/
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./interfaces/ILensHub.sol";
import {IWmatic} from "./interfaces/IWmatic.sol";

contract LensCrossmintAdapter {
    address public immutable lensHubAddress;
    address public immutable wMaticAddress;

    constructor(address _lensHubAddress, address _wMaticAddress) {
        lensHubAddress = _lensHubAddress;
        wMaticAddress = _wMaticAddress;
    }

    /// @notice convert MATIC to WMATIC
    function wrapMatic() internal {
        IWmatic(wMaticAddress).deposit{value: msg.value}();
    }

    /// @notice collect target Lens Publication
    /// @param _vars Lens collect with sig data
    /// @param _to recipient of tokens
    function collectWithSig(
        DataTypes.CollectWithSigData calldata _vars,
        address _to
    ) external payable {
        // Wrap MATIC to WMATIC
        wrapMatic();

        // Transfer the WMATIC to the user's wallet
        IERC20 wMaticToken = IERC20(wMaticAddress);
        uint256 wMaticBalance = wMaticToken.balanceOf(address(this));
        wMaticToken.transfer(_to, wMaticBalance);

        ILensHub(lensHubAddress).collectWithSig(_vars);
    }

    /// @notice collect target Lens Publication
    /// @param profileId profile id of seller
    /// @param pubId publication id to collect
    /// @param data encoded collect data
    /// @param quantity number of tokens to mint
    /// @param to recipient of tokens
    function collect(
        uint256 profileId,
        uint256 pubId,
        bytes memory data,
        uint256 quantity,
        address to
    ) external payable returns (uint256) {
        (, uint256 price) = abi.decode(data, (address, uint256));

        // Wrap MATIC to WMATIC
        wrapMatic();

        // Approve ERC20 spending
        _approveSpend(profileId, pubId, price * quantity);

        // Lookup NFT Contract to Collect
        address nftAddress = ILensHub(lensHubAddress).getCollectNFT(
            profileId,
            pubId
        );

        // Collect First Publication
        uint256 firstMintedTokenId = _collect(
            profileId,
            pubId,
            data,
            nftAddress,
            to
        );

        // Collect {X} Publications
        for (uint256 i = 1; i < quantity; i++) {
            _collect(profileId, pubId, data, nftAddress, to);
        }

        // Return First Collected Publication
        return firstMintedTokenId;
    }

    /// @notice collect target Lens Publication
    /// @param profileId profile id of seller
    /// @param pubId publication id to collect
    /// @param data encoded collect data
    /// @param nftAddress collect NFT address
    /// @param to recipient of tokens
    function _collect(
        uint256 profileId,
        uint256 pubId,
        bytes memory data,
        address nftAddress,
        address to
    ) internal returns (uint256) {
        uint256 tokenId = ILensHub(lensHubAddress).collect(
            profileId,
            pubId,
            data
        );
        IERC721(nftAddress).safeTransferFrom(
            address(this),
            to,
            tokenId,
            bytes("")
        );

        return tokenId;
    }

    /// @notice approve WMATIC spending
    /// @param profileId profile id of seller
    /// @param pubId publication id to collect
    /// @param totalPrice total amount of ERC20 to spend
    function _approveSpend(
        uint256 profileId,
        uint256 pubId,
        uint256 totalPrice
    ) internal returns (uint256) {
        // COLLECT MODULE SPENDS ERC20
        address collectModuleAddress = ILensHub(lensHubAddress)
            .getCollectModule(profileId, pubId);

        // CHECK CURRENT ERC20 ALLOWANCE
        uint256 allowance = IWmatic(wMaticAddress).allowance(
            address(this),
            collectModuleAddress
        );

        // INCREASE IF INSUFFICIENT
        if (allowance < totalPrice) {
            IWmatic(wMaticAddress).approve(
                collectModuleAddress,
                type(uint256).max
            );
        }
    }
}
