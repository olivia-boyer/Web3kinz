const hre = require("hardhat");

async function main() {
    [owner, user] = await ethers.getSigners();

    // Deploy main contract
    const Main = await hre.ethers.getContractFactory("Web3Kinz");
    web3kinz = await Main.deploy();
    await web3kinz.waitForDeployment();

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
    /*const petType2 = ethers.encodeBytes32String("cat");
    const petName2 = ethers.encodeBytes32String("Hera");
    const tx2 = await web3kinz.adoptPet(petType2, petName2, { value: hre.ethers.parseEther("0.001") });

    // get pet id from event
    const receipt2 = await tx2.wait();
    const event2 = receipt2.logs.find(log => log.fragment && log.fragment.name === "PetAdopted");
    const petId2 = event2.args.petId;
    console.log("Adopted pet with id:", petId2.toString());*/

    // two different ids yay!!

    // check kinzcash balance
    const kinztx = await web3kinz.checkKinzcashBalance();
    const receipt1 = await kinztx.wait();
    const kinzevent = receipt1.logs.find(log => log.fragment && log.fragment.name === "KinzcashBalance");
    const balance = kinzevent.args.balance;
    console.log("kinzcash balance:", balance.toString());

    // gem game
    const gemtx = await web3kinz.gemHunt(petId);
    const receipt2 = await gemtx.wait();
    const gemevent = receipt2.logs.find(log => log.fragment && log.fragment.name === "GemFound");
    const gem = gemevent.args.gem;
    console.log("Found gem:", gem);

    // try to play again not after 24 hours
    //const gemtx2 = await web3kinz.gemHunt(petId);

    // check gem amount
    const gctx = await web3kinz.checkGemAmount(gem.toString());
    const receipt3 = await gctx.wait();
    const gcevent = receipt3.logs.find(log => log.fragment && log.fragment.name === "GemAmount");
    const gemamount = gcevent.args.amount;
    console.log("amount of gem", gem, gemamount.toString());

    // sell gem
    const selltx = await web3kinz.sellGem(gem.toString());
    const receipt4 = await selltx.wait();
    
    // check amount after selling
    const gctx2 = await web3kinz.checkGemAmount(gem.toString());
    const receipt5 = await gctx2.wait();
    const gcevent2 = receipt5.logs.find(log => log.fragment && log.fragment.name === "GemAmount");
    const gemamount2 = gcevent2.args.amount;
    console.log("amount of gem", gem, gemamount2.toString());

    // check kinzcash balance after selling
    const cashtx = await web3kinz.checkKinzcashBalance();
    const receipt6 = await cashtx.wait();
    const kcevent = receipt6.logs.find(log => log.fragment && log.fragment.name === "KinzcashBalance");
    const kinzbalance = kcevent.args.balance;
    console.log("kinzcash balance:", kinzbalance.toString());

    // check hunger level
    const hltx = await web3kinz.checkHunger(petId);
    const receipt7 = await hltx.wait();
    const hlevent = receipt7.logs.find(log => log.fragment && log.fragment.name === "HungerLevel");
    const hungerLevel = hlevent.args.hunger;
    console.log("hunger level:", hungerLevel.toString());

    // buy food
    const foodtx = await web3kinz.purchaseFood(5);
    await foodtx.wait();

    // feed pet
    const feedtx = await web3kinz.feedPet(petId, 5);
    await feedtx.wait();

    // check hunger level after feeding
    const hltx2 = await web3kinz.checkHunger(petId);
    const receipt8 = await hltx2.wait();
    const hlevent2 = receipt8.logs.find(log => log.fragment && log.fragment.name === "HungerLevel");
    const hungerLevel2 = hlevent2.args.hunger;
    console.log("hunger level after feeding:", hungerLevel2.toString());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});