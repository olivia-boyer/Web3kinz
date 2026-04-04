// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
/// @author Dieter Shirley <dete@axiomzen.co> (https://github.com/dete) - from CryptoKitties.
contract ERC721 {
    // Required methods
    function totalSupply() public view returns (uint256 total);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function ownerOf(uint256 _tokenId) external view returns (address owner);
    function approve(address _to, uint256 _tokenId) external;
    function transfer(address _to, uint256 _tokenId) external;
    function transferFrom(address _from, address _to, uint256 _tokenId) external;

    // Events
    event Transfer(address from, address to, uint256 tokenId);
    event Approval(address owner, address approved, uint256 tokenId);

    // Optional
    // function name() public view returns (string name);
    // function symbol() public view returns (string symbol);
    // function tokensOfOwner(address _owner) external view returns (uint256[] tokenIds);
    // function tokenMetadata(uint256 _tokenId, string _preferredTransport) public view returns (string infoUrl);

    // ERC-165 Compatibility (https://github.com/ethereum/EIPs/issues/165)
    function supportsInterface(bytes4 _interfaceID) external view returns (bool);
}

/// @title Base contract for Web3Kinz. Holds all common structs, events, and base variables.
/// @author people
contract Web3Kinz {
    // insert variables here

    //owner
    adress owner;

    // global variable for total amount of food items
    uint256 gameFoodCount = 100;

    // global variable for total amount of furniture items
    uint256 gameFurnitureCount = 100;

    // global variable for total amount of clothing items
    uint256 gameClothingCount = 100;

    /// @dev The main pet struct. Every pet in Web3Kinz is represented by a copy of this
    ///  stuct, which fits neatly into 256 bytes of space. Each pet is an NFT.
    //modifications for additional data storage, not exactly 256
    struct Pet {
        // pet needs
        uint16 hunger;
        uint16 happiness;
        uint16 sleep;
        bool asleep;
        bool comatose;
        // pet information
        uint32 petID; // unique pet id
        bytes32 petType; // pet type
        bytes32 petName; // pet name (this can be a bug)
        uint64 birthTime; // to give the pet a birthday
    }

    // constructor
    constructor() payable {
        //
        owner = msg.sender;
    }

    // *************
    // ** storage **
    // *************

    // mappings + arrays

    // general
    mapping(uint32 => address) public petToOwner; // petID to owner address
    Pet[] public pets; // index = petID

    mapping(address => uint256) public userKinzcash; // user to kinzcash amount

    uint256 private nonce = 0; // used for random number generation

    // gem hunt
    mapping(address => uint64) public lastGemHunt; // stores time of last gem hunt
    mapping(address => uint256[]) public userGems; // stores users' gems

    // mapping cooldown for each game - possibly - need to google
    // store timestamp of the time the game was played and compare to current time
    // have a mapping for each game, map user address to timestamp

    // array of food
    // directory of all food types available in the game
    bytes2[gameFoodCount] public gameFoodDirectory;

    // mapping of user (key) to amount of each food (value) the user has in their inventory
    // user = address = msg.sender
    // amount of each food = uint256[]
    mapping(address => uint256[gameFoodCount]) userFoodCount;

    // mapping of user (key) to last play time (value) for wheelOfWow()
    // user = address = msg.sender
    // last play time = uint64 = block.timestamp
    mapping(address => uint64) wheelOfWowTime;

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
    modifier isAwake(Pet target) {
        require(target.asleep == false, "Your pet is asleep. Wake them up!");
        _;
    }

    //check if pet is comatose
    modifier notComatose(Pet target) {
        require(target.comatose == false, "Your pet is comatose. Take them to the vet!!");
        _;
    }

    // *******************
    // ** eth functions **
    // *******************

    // adoption
    function adoptPet(uint32 petID, bytes32 petType, bytes32 petName) public {
        // create pet struct
        Pet memory p = Pet({hunger: 100, happiness: 100, sleep: 100, petID: petID, petType: petType, petName: petName, birthTime: uint64(block.timestamp)});

        // assign pet to owner & store pet
        petToOwner[petID] = msg.sender;
        pets.push(p);

        // figure out how to actually mint the pet as an NFT later
    }

    // purchase KinzCash
    function buyKinzCash() public payable{
        uint256 bought = msg.value / 1000
        userKinzcash(msg.sender) += bought;
    }

    // ************************
    // ** KinzCash functions **
    // ************************
    
    // purchase furniture - furniture is NFT
    
    // purchase pet clothing - clothing is NFT

    // purchase pet food - food is ERC20

    // ************************
    // ** pet care functions **
    // ************************

    // put pet to bed

    // feed pet

    // modifier isComa - pay eth to "revive" pet / take to doctor

    // ************************
    // ** gameplay functions **
    // ************************

    // spinning a wheel - give you furniture, clothes, KinzCash - once a day //glory
    function wheelOfWow() public {
        // check the time, ensure 24 hours has past since last play time
        require(block.timestamp >= wheelOfWowTime[msg.sender] + 1 days, "24 hours have not yet passed!!");
        // update mapping to current time
        wheelOfWowTime[msg.sender] = uint64(block.timestamp);

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
                userKinzcash[msg.sender] += cashAmount;
            }
            // receive 50 KinzCash
            else if (wowValue < 70) {
                // specified win value
                uint256 cashAmount = 50;

                // add given amount to user's KinzCash balance
                userKinzcash[msg.sender] += cashAmount;
            }
            // receive 100 KinzCash
            else if (wowValue < 80) {
                // specified win value
                uint256 cashAmount = 100;

                // add given amount to user's KinzCash balance
                userKinzcash[msg.sender] += cashAmount;
            }
            // receive 500 KinzCash
            else if (wowValue < 90) {
                // specified win value
                uint256 cashAmount = 500;

                // add given amount to user's KinzCash balance
                userKinzcash[msg.sender] += cashAmount;
            }
            // receive random amount of KinzCash between 20 and 500
            else if (wowValue < 100) {
                // 500 - 20 = 480 => use % 481 to include 480 and add 20 to make up for the offset
                uint256 cashAmount = (uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))) % 481) + 20;
                nonce++;

                // add generate amount to user's KinzCash balance
                userKinzcash[msg.sender] += cashAmount;
            }
        }
    }

    // wishing well - slot machine (3 random number generators) - KinzCash, once a day x5// olivia

    // yahtzee - requires user input?? - bonus points - once a day - receive berries
    // berries have special function

    // gem hunt
    // gems are tracked as numbers in array, not nfts
        function gemHunt() public {
        // check time
        require(block.timestamp - lastGemHunt[msg.sender] >= 1 days, "Gem hunt can only be played once a day");

        // update time
        lastGemHunt[msg.sender] = uint64(block.timestamp);

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
    function checkGemAmount(uint256 index) public returns (uint256) {
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
            userKinzcash[msg.sender] += 100;
        } else if (uncommon) { // uncommon gem
            userGems[msg.sender][index]--;
            userKinzcash[msg.sender] += 50;
        } else { // common gem
            userGems[msg.sender][index]--;
            userKinzcash[msg.sender] += 15;
        }
    }

    // user or redeem crown function can call, check if enough gems for crown
    function checkCrown(address user) public returns (bool) {
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