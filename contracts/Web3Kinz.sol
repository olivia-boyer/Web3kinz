// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

/// @title Base contract for Web3Kinz. Holds all common structs, events, and base variables.
/// @author people
interface NFT {
    function safeMint(address) external returns (uint256);
}

contract Web3Kinz {

    // *************
    // ** structs **
    // *************

      /// @dev The main pet struct. Every pet in Web3Kinz is represented by a copy of this
    ///  stuct, which fits neatly into 256 bytes of space. Each pet is an NFT.
    //modifications for additional data storage, not exactly 256
    struct Pet {
        // pet needs
        uint16 hunger;
        uint16 happiness;
        uint8 sleeplevel;
        //for calculating sleeplevel
        //same variable for sleeping time and wake-time
        //usage depends on asleep bool
        uint32 sleeptime;
        //pet status
        bool asleep;
        bool comatose;
        // pet information
        uint256 petID; // unique pet id (from nft code)
        bytes32 petType; // pet type
        bytes32 petName; // pet name (this can be a bug)
        uint64 birthTime; // to give the pet a birthday
    }

    //stores information on each user
    struct UserInfo {
        uint256 balance; //ammount of kinzcash
        //times reset after 24 hours
        uint64 lastGemHunt; //time of last gem hunt
        uint64 lastWheelOfWoW; //time of last wheel spin
        uint64 lastWish; //time of last wish in wishing well
        uint8 wishes; //number of daily wishes left
        bool exists; //used for checking if user in users mapping
       // Pet[] pets; // pets owned by user
    }

    // *************
    // ** storage **
    // *************

    // for pet nft contract
    NFT public nft;
    NFT public clothing;

    //owner
    address owner;

    // global variable for total amount of food items
    uint256 gameFoodCount = 100;

    // global variable for total amount of furniture items
    uint256 gameFurnitureCount = 100;

    // global variable for total amount of clothing items
    uint256 gameClothingCount = 100;




    // mappings + arrays

    // general
    mapping(uint256 => address) public petToOwner; // petID to owner address
    Pet[] public pets; // index = petID

    mapping(address => UserInfo) public users; //mapping of users and their information

    uint256 private nonce = 0; // used for random number generation

    mapping(address => uint256[]) public userGems; // stores users' gems

    // mapping cooldown for each game - possibly - need to google
    // store timestamp of the time the game was played and compare to current time
    // have a mapping for each game, map user address to timestamp

    // array of food
    // directory of all food types available in the game
    uint256[100] public gameFoodDirectory;

    // mapping of user (key) to amount of each food (value) the user has in their inventory
    // user = address = msg.sender
    // amount of each food = uint256[]
    mapping(address => uint256[100]) userFoodCount;

    // mapping of user (key) to last play time (value) for wheelOfWow()
    // user = address = msg.sender
    // last play time = uint64 = block.timestamp
   //OLD MAPPING mapping(address => uint64) wheelOfWowTime;

   // mapping(address => uint64) wishingWellTime;
    // ***************
    // ** Events **
    // ***************
    event GemFound(address user, string gem);

    // ***************
    // ** functions **
    // ***************

    // modifier for only owner
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    // modifier isSleeping - cannot play games when pet is sleeping
    modifier isAwake(Pet memory target) {
        require(target.asleep == false, "Your pet is asleep. Wake them up!");
        _;
    }

    //check if pet is comatose
    modifier notComatose(Pet memory target) {
        require(target.comatose == false, "Your pet is comatose. Take them to the vet!!");
        _;
    }

    //check if sender had adopted a pet
    //needed to play games
    modifier hasPet(address addr) {
        require(users[addr].exists, "You need to adopt a pet first!!");
        _;
    }

    //check if sender is the owner of the pet they are interacting with
    modifier isPetOwner(uint32 petid) {
    require(petToOwner[petid] == msg.sender);
        _;
    }


    // constructor
    // deploy Web3kinzPet.sol first, get contract address, then pass into this contract
    constructor(address _nftAddress, address _clothaddr) payable {
        owner = msg.sender;
        nft = NFT(_nftAddress);
        clothing = NFT(_clothaddr);
    }


    // *******************
    // ** eth functions **
    // *******************

    // adoption
    function adoptPet(bytes32 petType, bytes32 petName) public payable {
        // payment
        require(msg.value >= 0.01 ether, "Adopting a pet costs 0.01 eth"); // idk what price we want

        // create pet struct
        uint256 petId = nft.safeMint(msg.sender);
        Pet memory p = Pet({hunger: 100, happiness: 100, sleeplevel: 100, sleeptime: uint32(block.timestamp), 
        asleep: false, comatose: false, petID: petId, petType: petType, petName: petName, 
        birthTime: uint64(block.timestamp)});

        // assign pet to owner & store pet
        if (!users[msg.sender].exists) {
            uint64 curtime = uint64(block.timestamp);
            users[msg.sender] = UserInfo({balance: 0, lastGemHunt: curtime - 1 days, lastWheelOfWoW: curtime - 1 days, lastWish: curtime - 1 days, wishes: 5, exists: true});
        }
        petToOwner[petId] = msg.sender;
        pets.push(p);
    }

    // purchase KinzCash
    function buyKinzCash() public payable{
        //1 kinzCash == 1000 wei
        uint256 bought = msg.value / 1000;
        users[msg.sender].balance += bought;
    }

    // ************************
    // ** KinzCash functions **
    // ************************
    
    // purchase furniture - furniture is NFT
    
    // purchase pet clothing - clothing is NFT
    //if add uri- include uint8 parameter to select clothing style
    //don't need to store all clothing items
    function purchaseClothing() public payable {
        require(msg.value >= 0.001 ether, "clothing items cose 0.001 eth");
        clothing.safeMint(msg.sender);
    }

    // purchase pet food - food is ERC20

    // ************************
    // ** pet care functions **
    // ************************
/*
    function getabs(int256 target) private returns (int256) {
            if (target < 0) {
                return -target;
            }
            return target;
    }
    */
    // put pet to bed
    function naptime(uint32 petid) isPetOwner(petid) public {
        require(!pets[petid].asleep, "Your pet is already sleeping!");
        pets[petid].asleep = true;
        //update sleeptime
        pets[petid].sleeptime = uint32(block.timestamp);
    }

    //wake pet up
       function wakeup(uint32 petid) isPetOwner(petid) public {
        require(pets[petid].asleep, "Your pet is already awake!");
        pets[petid].asleep = false;
       //full sleep is a little under 8 hours, regain sleep level at rate of 13 per hour
        uint32 addup = ((uint32(block.timestamp) - pets[petid].sleeptime)/3600)*13;
        //maximum sleep level is 100
        if (addup > 100) {
            addup = 100;
        }
        if (addup + pets[petid].sleeplevel > 100) {
            pets[petid].sleeplevel = 100;
        } else {
            pets[petid].sleeplevel += uint8(addup);
        }
        //update wake time
        pets[petid].sleeptime = uint32(block.timestamp); 
    }

    // feed pet

    // modifier isComa - pay eth to "revive" pet / take to doctor

    // ************************
    // ** gameplay functions **
    // ************************

    //TODO: modify to match new storage form
    // spinning a wheel - give you furniture, clothes, KinzCash - once a day //glory
    function wheelOfWow() public {
        // check the time, ensure 24 hours has past since last play time
        require(block.timestamp >= users[msg.sender].lastWheelOfWoW + 1 days, "24 hours have not yet passed!!");
        // update mapping to current time
        users[msg.sender].lastWheelOfWoW = uint64(block.timestamp);

        // generate a random number
        uint256 wowValue = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))) % 100;
        nonce++;

        // logic for prizes
        // random selection of clothing
        if (wowValue < 10) {
            //
        }
        // random selection of furniture
        else if (wowValue < 30) {
            //
        }
        // random selection of food
        else if (wowValue < 50) {
            // generate a random number to select a random food from the gameFoodDirectory array
            uint256 foodIndex = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))) % gameFoodCount;
            nonce++;

            // increment count for specific food item in user's inventory
            userFoodCount[msg.sender][foodIndex] += 1;
        }
        // random amount of KinzCash
        else {
            // receive 20 KinzCash
            if (wowValue < 60) {
                // specified win value
                uint256 cashAmount = 20;

                // add given amount to user's KinzCash balance
                users[msg.sender].balance += cashAmount;
            }
            // receive 50 KinzCash
            else if (wowValue < 70) {
                // specified win value
                uint256 cashAmount = 50;

                // add given amount to user's KinzCash balance
                users[msg.sender].balance += cashAmount;
            }
            // receive 100 KinzCash
            else if (wowValue < 80) {
                // specified win value
                uint256 cashAmount = 100;

                // add given amount to user's KinzCash balance
                users[msg.sender].balance += cashAmount;
            }
            // receive 500 KinzCash
            else if (wowValue < 90) {
                // specified win value
                uint256 cashAmount = 500;

                // add given amount to user's KinzCash balance
                users[msg.sender].balance += cashAmount;
            }
            // receive random amount of KinzCash between 20 and 500
            else if (wowValue < 100) {
                // 500 - 20 = 480 => use % 481 to include 480 and add 20 to make up for the offset
                uint256 cashAmount = (uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))) % 481) + 20;
                nonce++;

                // add generate amount to user's KinzCash balance
                users[msg.sender].balance += cashAmount;
            }
        }
    }

    //helper function for Wishing Well game
    //converts random number to a value from 0-8
    //representing the 9 possible icons rolled
    function findResult(uint8 target) private pure returns (uint8) {
        //checks if is fruit
        if (target < 80) {
            //decide if fruit number 0-3
            return target / 20;
        }
        //checks if is animal
        if (target < 100) {
            //decide if animal number 4-7
            return 4 + ((target - 80) / 5);
        }
        //must be well
        return 8;
    }

    // wishing well - slot machine (3 random number generators) - KinzCash, once a day x5// olivia
   function wishingWell() public {

           // check the time, ensure 24 hours has past since last play time
     
        if (block.timestamp >= users[msg.sender].lastWish + 1 days){
        // update mapping to current time
        users[msg.sender].lastWish = uint64(block.timestamp);
        users[msg.sender].wishes = 5;
        }

        require(users[msg.sender].wishes > 0, "You've run out of wishes, come back tomorrow!");

        uint16 prize = 0;
        uint8 col1;
        uint8 col2;
        uint8 col3;
        uint8 typematch;
        uint8 matchCount;
        uint16 rowprize;
        //there are three rows
        for (int i = 0; i < 3; i++) {
                //generate items randomly 
                //9 options: 4 fruits, 4 animals; and 1 well
                //odds of fruit: 19.8%; odds of animal: 5%; odds of well: 0.99%
                col1 = uint8(uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))) % 101);
                col1 = findResult(col1);
                nonce++;
                col2 = uint8(uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))) % 101);
                col2 = findResult(col2);
                nonce++;
                col3 = uint8(uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))) % 101);
                col3 = findResult(col3);
                nonce++;

                //type of item there was a match of
                typematch = 27; //random number outside of range of item numbers
                //max number of matching items
                matchCount = 1;

                if (col1 == col2) {
                    typematch = col1;
                    matchCount++;
                } 
                if (col2 == col3) {
                    typematch = col2;
                    matchCount++;
                }
                
                rowprize = 0;
                if (matchCount == 2) {
                    //fruit
                    if (typematch < 4) {
                        rowprize = 5;
                    //animal
                    } else if (typematch < 8) {
                        rowprize =10;
                    } else {
                    //well
                        rowprize = 50;
                    }
                    //check type and dole out rewards
                } else if (matchCount == 3) {
                    //fruit
                     if (typematch < 4) {
                        rowprize = 35;
                    //animal
                    } else if (typematch < 8) {
                        rowprize = 100;
                    //well
                    } else {
                        rowprize = 1000;
                    }
                    //check if there is a single well
                } else if (matchCount == 1) {
                    if (col1 == 8 || col2 == 8 || col3 == 8) {
                        rowprize == 5;
                    }
                }
                //the prize for the middle row is tripled
                if (i == 1) {
                    rowprize = rowprize * 3;
                }
                prize += rowprize;
        }
        users[msg.sender].wishes -= 1; //decrement daily wish count before cashout
        users[msg.sender].balance += prize; //add prize money to user balance
    }


    // gem hunt
    // gems are tracked as numbers in array, not nfts
        function gemHunt() public {
        // check time
        require(block.timestamp - users[msg.sender].lastGemHunt >= 1 days, "Gem hunt can only be played once a day");

        // update time
        users[msg.sender].lastGemHunt = uint64(block.timestamp);

        // for 3 tries
        for (int i=0; i<3; i++) {
            // generate random number
            uint256 randomNumber = uint256(keccak256(abi.encodePacked(
                block.timestamp, 
                msg.sender, 
                nonce
            )));
            nonce++;

            // got gem
            if ((randomNumber % 100) < 50) {
                string memory gem;

                // randomly choose gem (weighted by rarity)
                uint256 randomNumber2 = uint256(keccak256(abi.encodePacked(
                    block.timestamp, 
                    msg.sender, 
                    nonce
                )));
                nonce++;
                
                uint256 gemNum = randomNumber2 % 425;

                // white gems
                if (gemNum < 5) {
                    gem = "webkinz diamond";
                    userGems[msg.sender][0]++;
                } else if (gemNum < 15) {
                    gem = "unicorn horn";
                    userGems[msg.sender][1]++;
                } else if (gemNum < 25) {
                    gem = "yum zum sparkle";
                    userGems[msg.sender][2]++;
                } else if (gemNum < 45) {
                    gem = "zingos zincoz";
                    userGems[msg.sender][3]++;
                } else if (gemNum < 65) {
                    gem = "goober glitter";
                    userGems[msg.sender][4]++;
                } else if (gemNum < 85) {
                    gem = "booger nugget";
                    userGems[msg.sender][5]++;

                // red gems
                } else if (gemNum < 90) {
                    gem = "red ruby heart";
                    userGems[msg.sender][6]++;
                } else if (gemNum < 100) {
                    gem = "ember amber";
                    userGems[msg.sender][7]++;
                } else if (gemNum < 110) {
                    gem = "volcano viscose";
                    userGems[msg.sender][8]++;
                } else if (gemNum < 130) {
                    gem = "flare fyca";
                    userGems[msg.sender][9]++;
                } else if (gemNum < 150) {
                    gem = "torch treasure";
                    userGems[msg.sender][10]++;
                } else if (gemNum < 170) {
                    gem = "lava lamp";
                    userGems[msg.sender][11]++;

                // green gems
                } else if (gemNum < 175) {
                    gem = "earth emerald";
                    userGems[msg.sender][12]++;
                } else if (gemNum < 185) {
                    gem = "moss marble";
                    userGems[msg.sender][13]++;
                } else if (gemNum < 195) {
                    gem = "cat's eye glint";
                    userGems[msg.sender][14]++;
                } else if (gemNum < 215) {
                    gem = "jaded envy";
                    userGems[msg.sender][15]++;
                } else if (gemNum < 235) {
                    gem = "pearl egg";
                    userGems[msg.sender][16]++;
                } else if (gemNum < 255) {
                    gem = "terra tectonic";
                    userGems[msg.sender][17]++;

                // blue gems
                } else if (gemNum < 260) {
                    gem = "ocean sapphire";
                    userGems[msg.sender][18]++;
                } else if (gemNum < 270) {
                    gem = "teardrop tower";
                    userGems[msg.sender][19]++;
                } else if (gemNum < 280) {
                    gem = "sea stone";
                    userGems[msg.sender][20]++;
                } else if (gemNum < 300) {
                    gem = "rainbow flower";
                    userGems[msg.sender][21]++;
                } else if (gemNum < 320) {
                    gem = "river ripple";
                    userGems[msg.sender][22]++;
                } else if (gemNum < 340) {
                    gem = "aqua orb";
                    userGems[msg.sender][23]++;
                }

                // yellow gems
                else if (gemNum < 345) {
                    gem = "corona topaz";
                    userGems[msg.sender][24]++;
                } else if (gemNum < 355) {
                    gem = "aurora rax";
                    userGems[msg.sender][25]++;
                } else if (gemNum < 365) {
                    gem = "pyramid plunder";
                    userGems[msg.sender][26]++;
                } else if (gemNum < 385) {
                    gem = "starlight shimmer";
                    userGems[msg.sender][27]++;
                } else if (gemNum < 405) {
                    gem = "lemon drop";
                    userGems[msg.sender][28]++;
                } else if (gemNum < 425) {
                    gem = "carat eclipse";
                    userGems[msg.sender][29]++;
                }

                emit GemFound(msg.sender, gem);
                break; // only 1 gem per game
            }

            // no gem
        }
        
    }

    // user can check amount of gems (have to use gem index)
    function checkGemAmount(uint256 index) public view returns (uint256) {
        require(index < 6 && index >= 0, "Invalid index");
        return userGems[msg.sender][index];
    }

    // user can sell gems at any time for kinzcash
    function sellGem(uint256 index) public {
        require(userGems[msg.sender][index] > 0, "You don't have that gem");

        // check if uncommon
        uint8[10] memory uncommonIndicies = [1, 2, 7, 8, 13, 14, 19, 20, 25, 26];
        bool uncommon = false;
        for (uint i=0; i<uncommonIndicies.length; i++) {
            if (index == uncommonIndicies[i])
                uncommon = true;
        }

        // remove gem & give kinzcash
        if (index % 6 == 0) { // rare gem
            userGems[msg.sender][index]--;
            users[msg.sender].balance += 100;
        } else if (uncommon) { // uncommon gem
            userGems[msg.sender][index]--;
            users[msg.sender].balance += 50;
        } else { // common gem
            userGems[msg.sender][index]--;
            users[msg.sender].balance += 15;
        }
    }

    // user or redeem crown function can call, check if enough gems for crown
    function checkCrown(address user) public view returns (bool) {
        for (uint i=0; i<6; i++) {
            if (userGems[user][i] == 0)
                return false;
        }
        return true;
    }

    // user can call to redeem
    function redeemCrown() public {
        require(checkCrown(msg.sender), "You don't have enough gems");

        // remove gems
        for (uint i=0; i<6; i++) {
            userGems[msg.sender][i]--;
        }

        // give crown (idk if it should be nft)
        // maybe should be a clothing item
    }


    // **********************
    // ** friend functions **
    // **********************

    // trading - everything but food
    // transactions open to the ethernet
    // how to ensure cannot ensure? - probably in the slides
}