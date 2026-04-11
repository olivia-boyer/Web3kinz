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

    // adopt pet (should fail)
    const petType2 = ethers.encodeBytes32String("cat");
    const petName2 = ethers.encodeBytes32String("Hera");
    const tx2 = await web3kinz.adoptPet(petType2, petName2, { value: hre.ethers.parseEther("0.001") });

    // get pet id from event
    const receipt2 = await tx2.wait();
    const event2 = receipt2.logs.find(log => log.fragment && log.fragment.name === "PetAdopted");
    const petId2 = event2.args.petId;
    console.log("Adopted pet with id:", petId2.toString());

    // two different ids yay!!
    
    // check sleep level
    //const sleepLevel = await web3kinz.checkStats(petId);
    //console.log("Sleep level:", sleepLevel);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});