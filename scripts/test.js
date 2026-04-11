const hre = require("hardhat");

async function main() {
    [owner, user] = await ethers.getSigners();

    // Deploy pet nft contract
    const PetNFT = await hre.ethers.getContractFactory("Web3KinzPet");
    pet = await PetNFT.deploy(owner.address);
    await pet.waitForDeployment();

    // Deploy Food contract
    const Food = await hre.ethers.getContractFactory("Web3kinzFood");
    food = await Food.deploy(owner.address);
    await food.waitForDeployment();

    // Deploy Clothes contract
    const Clothes = await hre.ethers.getContractFactory("Web3KinzClothing");
    clothes = await Clothes.deploy(owner.address);
    await clothes.waitForDeployment();

    // Deploy main contract
    const Main = await hre.ethers.getContractFactory("Web3Kinz");
    web3kinz = await Main.deploy(pet.target, clothes.target, food.target);
    await web3kinz.waitForDeployment();

    // fix owner issue (temp)
    await pet.connect(owner).transferOwnership(await web3kinz.getAddress());

    // adopt pet
    const petType = ethers.encodeBytes32String("dog");
    const petName = ethers.encodeBytes32String("Chopper");
    const tx = await web3kinz.adoptPet(petType, petName, { value: hre.ethers.parseEther("0.01") });

    // get pet id from event
    const receipt = await tx.wait();
    const event = receipt.logs.find(log => log.fragment && log.fragment.name === "PetAdopted");
    const petId = event.args.petId;
    console.log("Adopted pet with id:", petId.toString());
    
    // check sleep level
    //const sleepLevel = await web3kinz.checkStats(petId);
    //console.log("Sleep level:", sleepLevel);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});