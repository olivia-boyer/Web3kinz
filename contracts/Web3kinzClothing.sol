// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.6.0

// Pet NFT contract
// Must run npm install @openzeppelin/contracts to compile
//created primarily via NFT Wizard at https://wizard.openzeppelin.com/#erc721
//with a few additions to customize to what we want, so don't skip reading
pragma solidity ^0.8.27;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Burnable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract Web3KinzClothing is ERC721, ERC721URIStorage, ERC721Burnable, Ownable {
    uint256 private _nextTokenId;

    //two possible clothing options currently
    string[2] private images = ["ipfs://bafkreib62nibyvfegj2omkxmytg632fhxz473yxfcij7k7hvzynlf5jseu","bafkreibzets4aisvn75hanrdr2usjqu5okyktbyjliv4wphgtn5t2nvgoq"];

    constructor(address initialOwner)
        ERC721("Web3KinzClothing", "Clothes")
        Ownable(initialOwner)
    {}

   //modified
    function safeMint(address to, uint8 kind)
        public
        onlyOwner
        returns (uint256)
    {
        //100 kinds of clothes listed in program
        //but only actually making two for now
        //in a more robust implementation with line would not exist
        kind = kind % 2;
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        //if building web application, would use nft metadata to correlate to how object appears in game
        _setTokenURI(tokenId, images[kind]);
        return tokenId;
    }

    // The following functions are overrides required by Solidity.
    //unmodified
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
