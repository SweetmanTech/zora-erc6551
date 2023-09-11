// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {Test} from "@forge-std/src/Test.sol";
import {SmartWalletMinter} from "../src/SmartWalletMinter.sol";
import {ZoraDropMock} from "./mocks/ZoraDropMock.sol";

contract SmartWalletMinterTest is Test {
    SmartWalletMinter public adapter;
    ZoraDropMock public drop;
    address public DEFAULT_MINTER = address(0x01);
    address public DEFAULT_MINTER_TWO = address(0x02);
    address public DEFAULT_MINT_REFERRAL = address(0x0333);

    function setUp() public {
        adapter = new SmartWalletMinter();
        drop = new ZoraDropMock();
    }

    function testPurchase(address _to, uint256 _quantity) public {
        _assumeUint256(_quantity);
        _assumeAddress(_to);
        assertEq(drop.balanceOf(_to), 0);
        adapter.mintWithRewards(
            address(drop),
            _to,
            _quantity,
            "smart wallet created",
            DEFAULT_MINT_REFERRAL
        );
        assertEq(drop.balanceOf(_to), _quantity);
    }

    function testPurchaseMany(uint256 _quantity, address _thirdMinter) public {
        testPurchase(DEFAULT_MINTER, _quantity);
        assertEq(drop.balanceOf(DEFAULT_MINTER), _quantity);
        assertEq(drop.ownerOf(1), DEFAULT_MINTER);

        testPurchase(DEFAULT_MINTER_TWO, _quantity);
        assertEq(drop.balanceOf(DEFAULT_MINTER_TWO), _quantity);
        assertEq(drop.ownerOf(_quantity * 2), DEFAULT_MINTER_TWO);

        testPurchase(_thirdMinter, _quantity);
        assertEq(drop.balanceOf(_thirdMinter), _quantity);
        assertEq(drop.ownerOf(_quantity * 3), _thirdMinter);
    }

    function _assumeUint256(uint256 _num) internal pure {
        vm.assume(_num > 0);
        vm.assume(_num < 100);
    }

    function _assumeAddress(address wallet) internal pure {
        vm.assume(wallet != address(0));
    }
}
