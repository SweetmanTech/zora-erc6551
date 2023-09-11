// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IWmatic {
    function allowance(
        address spender,
        address caller
    ) external returns (uint256);

    function deposit() external payable;

    function approve(address guy, uint wad) external returns (bool);
}
