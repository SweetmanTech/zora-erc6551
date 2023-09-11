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
import {Test} from "@forge-std/src/Test.sol";
import {LensCrossmintAdapter} from "../src/LensCrossmintAdapter.sol";
import {LensHubMock} from "./mocks/LensHubMock.sol";
import {WMATIC} from "../src/libraries/WMATIC.sol";

contract LensCrossmintAdapterTest is Test {
    LensCrossmintAdapter public adapter;
    LensHubMock public lensHub;
    WMATIC public wmatic;

    address public DEFAULT_MINTER = address(0x01);
    address public DEFAULT_MINTER_TWO = address(0x02);
    uint256 DEFAULT_PROFILE_ID = 0x123;
    uint256 DEFAULT_PUB_ID = 0x1;

    function setUp() public {
        lensHub = new LensHubMock();
        wmatic = new WMATIC();
        adapter = new LensCrossmintAdapter(address(lensHub), address(wmatic));
    }

    function testCollect_approvedWMaticCollectModule() public {
        uint256 quantity = 1;
        vm.startPrank(DEFAULT_MINTER);
        vm.deal(DEFAULT_MINTER, 1 ether);
        bytes memory data = abi.encode(address(wmatic), 1);

        // VERIFY NO ALLOWANCE
        assertEq(
            wmatic.allowance(
                address(adapter),
                lensHub.getCollectModule(DEFAULT_PROFILE_ID, DEFAULT_PUB_ID)
            ),
            0
        );

        // COLLECT POST
        adapter.collect{value: 1 ether}(
            DEFAULT_PROFILE_ID,
            DEFAULT_PUB_ID,
            data,
            1,
            DEFAULT_MINTER
        );

        // VERIFY MAX ALLOWANCE
        assertEq(
            wmatic.allowance(
                address(adapter),
                lensHub.getCollectModule(DEFAULT_PROFILE_ID, DEFAULT_PUB_ID)
            ),
            type(uint256).max
        );
    }

    function testCollect() public {
        uint256 quantity = 1;
        vm.startPrank(DEFAULT_MINTER);
        vm.deal(DEFAULT_MINTER, 1 ether);
        bytes memory data = abi.encode(address(wmatic), 1);
        uint256 start = lensHub.collect(
            DEFAULT_PROFILE_ID,
            DEFAULT_PUB_ID,
            data
        );
        assertEq(lensHub.balanceOf(DEFAULT_MINTER), quantity);
        adapter.collect{value: 1 ether}(
            DEFAULT_PROFILE_ID,
            DEFAULT_PUB_ID,
            data,
            1,
            DEFAULT_MINTER
        );
        assertEq(lensHub.balanceOf(DEFAULT_MINTER), 2 * quantity);
    }

    function testCollectMany(uint256 quantity) public {
        if (quantity > 1111 || quantity < 2) {
            return;
        }
        vm.deal(DEFAULT_MINTER, 1 ether);
        vm.startPrank(DEFAULT_MINTER);
        bytes memory data = abi.encode(address(wmatic), 1);

        // NORMAL COLLECT DIRECTLY ON LENSHUB
        uint256 start = lensHub.collect(
            DEFAULT_PROFILE_ID,
            DEFAULT_PUB_ID,
            data
        );
        assertEq(lensHub.balanceOf(DEFAULT_MINTER), 1);

        // NEW COLLECT ON ADAPTER
        adapter.collect{value: 1 ether}(
            DEFAULT_PROFILE_ID,
            DEFAULT_PUB_ID,
            data,
            quantity,
            DEFAULT_MINTER_TWO
        );
        assertEq(lensHub.balanceOf(DEFAULT_MINTER), 1);
        assertEq(lensHub.ownerOf(1), DEFAULT_MINTER);
        assertEq(lensHub.balanceOf(DEFAULT_MINTER_TWO), quantity);
        assertEq(lensHub.ownerOf(1 + quantity), DEFAULT_MINTER_TWO);
    }
}
