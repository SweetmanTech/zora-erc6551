// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {ERC6551Registry} from "lib/ERC6551/src/ERC6551Registry.sol";
import {AccountV3} from "lib/tokenbound/src/AccountV3.sol";
import {AccountGuardian} from "lib/tokenbound/src/AccountGuardian.sol";
import {EntryPoint} from "lib/account-abstraction/contracts/core/EntryPoint.sol";
import {Multicall3} from "lib/multicall-authenticated/src/Multicall3.sol";

contract ERC6551RegistryMock {
    // ERC6551
    ERC6551Registry erc6551Registry;
    AccountGuardian guardian;
    Multicall3 forwarder;
    EntryPoint entryPoint;
    AccountV3 erc6551Implementation;

    function _setupErc6551() internal {
        erc6551Registry = new ERC6551Registry();
        guardian = new AccountGuardian(address(0));
        forwarder = new Multicall3();
        entryPoint = new EntryPoint();
        erc6551Implementation = new AccountV3(
            address(entryPoint),
            address(forwarder),
            address(erc6551Registry),
            address(guardian)
        );
    }

    function isContract(address _addr) internal view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    function getTBA(
        address _target,
        uint256 tokenId
    ) internal view returns (address) {
        address payable tokenBoundAccount = payable(
            erc6551Registry.account(
                address(erc6551Implementation),
                0,
                block.chainid,
                _target,
                tokenId
            )
        );
        return tokenBoundAccount;
    }
}
