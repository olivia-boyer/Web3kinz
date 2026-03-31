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

    // pet struct
    // pet is NFT
    struct pet {
        // pet needs
        uint32 hunger;
        uint32 happiness;
        uint32 sleep;
        // pet information
        uint32 petID; // unique pet id
        uint64 birthTime; // to give the pet a birthday
    }

    // constructor
    constructor() payable {
        //
    }

    // *************
    // ** storage **
    // *************

    // mappings + arrays

    // ***************
    // ** functions **
    // ***************

    // modifier for only owner

    // *******************
    // ** eth functions **
    // *******************

    // adoption
    function functionName() public {
        //
    }

    // purchase KinzCash

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

    // modifier isSleeping - cannot play games when pet is sleeping

    // feed pet

    // modifier isComa - pay eth to "revive" pet / take to doctor

    // ************************
    // ** gameplay functions **
    // ************************

    // spinning a wheel - give you furniture, clothes, KinzCash - once a day

    // wishing well - slot machine (3 random number generators) - KinzCash, once a day x5

    // yahtzee - requires user input?? - bonus points - once a day - receive berries
    // berries have special function

    // gem hunt - 
    // three tries to uncover a gem - 5 colors (white, red, blue, green, yellow), 6 per color
    // receive crown after collecting all 
    // gem is NFT

    // **********************
    // ** friend functions **
    // **********************

    // trading - everything but food
    // transactions open to the ethernet
    // how to ensure cannot ensure? - probably in the slides
}