const hre = require("hardhat");

async function main() {
    [owner, user] = await ethers.getSigners();

    // Deploy pet nft contract
    const PetNFT = await hre.ethers.getContractFactory("Web3KinzPet");
    pet = await PetNFT.deploy(owner.address);
    await pet.waitForDeployment();

    // Deploy Food contract
    const Food = await ethers.getContractFactory("Web3kinzFood");
    food = await Food.deploy(owner.address);
    await food.waitForDeployment();

    // Deploy Clothes contract
    const Clothes = await ethers.getContractFactory("Web3KinzClothing");
    clothes = await Clothes.deploy(owner.address);
    await clothes.waitForDeployment();

    // Deploy main contract
    const Main = await ethers.getContractFactory("Web3Kinz");
    web3kinz = await Main.deploy(pet.target, clothes.target, food.target);
    await web3kinz.waitForDeployment();

    
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});