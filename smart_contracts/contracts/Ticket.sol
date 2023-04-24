// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract Ticket is ERC721URIStorage {
    uint public ticketCount = 0;
    constructor() ERC721("RaffleTime", "Tickets"){}
    function mint(string memory _tokenURI) external returns(uint) {
      ticketCount++;
      _safeMint(msg.sender, ticketCount);
      _setTokenURI(ticketCount, _tokenURI);
      return ticketCount;
    }
}