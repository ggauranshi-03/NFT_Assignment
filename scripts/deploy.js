const { ethers } = require("hardhat");

async function main() {
  // Get the deployer's signer
  const [deployer] = await ethers.getSigners();

  console.log("Deploying NFTContract...");

  // Deploy NFTContract
  const NFTContract = await ethers.getContractFactory("NFTContract");
  const nftContract = await NFTContract.deploy(100, deployer.address); // Assuming the NFT price is 100 wei
  await nftContract.deployed();
  console.log("NFTContract deployed to:", nftContract.address);

  console.log("Deploying PoolContract...");

  // Deploy PoolContract and pass NFTContract address as a constructor parameter
  const PoolContract = await ethers.getContractFactory("PoolContract");
  const poolContract = await PoolContract.deploy(
    nftContract.address,
    deployer.address
  );
  await poolContract.deployed();
  console.log("PoolContract deployed to:", poolContract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
