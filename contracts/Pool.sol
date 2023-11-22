// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PoolContract is ERC721Enumerable, Ownable {
    IERC721 public nftContract;
    uint256 public lockDuration = 30 days;
    uint256 public rewardRate = 15; // 15% annual interest

    mapping(address => uint256) public stakeTimestamp;
    mapping(address => uint256) public lastClaimedTimestamp;

    event NFTDeposited(address indexed user, uint256 tokenId);
    event NFTWithdrawn(address indexed user, uint256 tokenId, uint256 interest);

    constructor(
        address _nftContract,
        address initialOwner
    ) ERC721("MyNFTPool", "MNFTPOOL") Ownable(initialOwner) {
        nftContract = IERC721(_nftContract);
    }

    function depositNFT(uint256 tokenId) public {
        require(
            nftContract.ownerOf(tokenId) == msg.sender,
            "Not the owner of the NFT"
        );
        require(stakeTimestamp[msg.sender] == 0, "Already staked an NFT");

        nftContract.transferFrom(msg.sender, address(this), tokenId);

        stakeTimestamp[msg.sender] = block.timestamp;
        emit NFTDeposited(msg.sender, tokenId);
    }

    function withdrawNFT() public {
        require(stakeTimestamp[msg.sender] > 0, "No NFT staked");
        require(
            block.timestamp >= stakeTimestamp[msg.sender] + lockDuration,
            "NFT still locked"
        );

        uint256 interest = calculateInterest(msg.sender);
        nftContract.transferFrom(
            address(this),
            msg.sender,
            nftContract.balanceOf(address(this))
        );

        stakeTimestamp[msg.sender] = 0;
        lastClaimedTimestamp[msg.sender] = block.timestamp;

        emit NFTWithdrawn(
            msg.sender,
            nftContract.balanceOf(msg.sender),
            interest
        );
    }

    function calculateInterest(address user) internal view returns (uint256) {
        uint256 timeElapsed = block.timestamp - lastClaimedTimestamp[user];
        return
            (nftContract.balanceOf(user) * rewardRate * timeElapsed) /
            (365 days * 100);
    }
}
