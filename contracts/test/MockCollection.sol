// SPDX-License-Identifier: MIT
pragma solidity >=0.8.3;

contract MockCollection {
    event MintedWithExternalURI(address indexed to, uint256 slot, string tokenURI);

    function mockMintWithExternalURI(address to, uint256 slot, string memory tokenURI) external {
        emit MintedWithExternalURI(to, slot, tokenURI);
    }
}
