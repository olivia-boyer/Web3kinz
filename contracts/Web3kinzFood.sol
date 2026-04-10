// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.6.0

// Food contract - erc20 (food items are not unique)
//created primarily via NFT Wizard at https://wizard.openzeppelin.com/#erc20
pragma solidity ^0.8.27;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract Web3kinzFood is ERC20, Ownable, ERC20Burnable, ERC20Permit {
    constructor(address initialOwner)
        ERC20("MyToken", "MTK")
        Ownable(initialOwner)
        ERC20Permit("MyToken")
    {}

    // amount corresponds to hunger points
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}