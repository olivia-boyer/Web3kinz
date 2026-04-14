# Web3kinz
A simplified version of the game Webkinz implemented on the blockchain. Users can adopt pets,
play three daily games, and attend to pets' needs of happiness (increased by playing games), hunger 
(increased by feeding), and sleep (increased by putting to bed). Users can also buy clothing and furniture
for their pets.

Files:
Web3Kinz.sol: The main web3kinz contract. This contract deploys the three NFT ontracts and one token contract. 
Functionality includes adopting pets, buying kinzcash, and playing three games: Wheel of Wow, Wishing Well, and 
Gem Hunt.

Web3kinzClothing.sol: ERC-721 implementation used for minting clothing NFTS. Currently there are three
options: a t-shirt, a bow shirt, and the crown that is the prize for completing the gem hunt game.

Web3kinzFood.sol: ERC-20 implementation for minting and burning food tokens. These tokens can be used to
increase the hunger bar (i.e. making pet less hungry).

Web3kinzFurniture.sol: ERC-721 implementation used for minting furniture NFTS.

Web3kinzPet.sol: ERC-721 implementation used for minting pet NFTS. Called in the adoptpet function of the main contract.

Known Issues:
1. The pet struct is unecessarily large.
2. Issues may arise from trying to make the pet name too long.
3. Calling PurchaseClothing with a multiple of three could allow users to buy crown. Modulus operation in Web3kinzClothing contract was meant to be temporary but lacked time to draw 100 unique clothing items.
