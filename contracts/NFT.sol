// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTContract is ERC721Enumerable, Ownable {
    uint256 public nftPrice;

    constructor(
        uint256 _nftPrice,
        address initialOwner
    ) ERC721("MyNFT", "MNFT") Ownable(initialOwner) {
        nftPrice = _nftPrice;
    }

    function mint() external payable {
        require(msg.value == nftPrice, "Incorrect payment amount");
        uint256 tokenId = totalSupply() + 1;
        _safeMint(msg.sender, tokenId);
    }
}
