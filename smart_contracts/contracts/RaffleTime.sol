// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

import './Ticket.sol';

contract RaffleTime is IERC721Receiver, ChainlinkClient {
  using Chainlink for Chainlink.Request;

  struct Raffle {
    uint raffleId;
    address owner;
    string name;
    address nftAddress;
    uint nftTokenId;
    uint ticketPrice;
    uint salePrice;
    uint sellPrice;
    uint endTime;
    uint ticketCount;
    address[] ticketBuyers;
    mapping(address => uint) ticketIds;
    address payable winner;
    bool ended;
  }

  address payable public platformFeeAccount;
  uint public immutable platformFeePercent;

  uint public raffleId;
  mapping(uint => Raffle) public raffles;
  address[] ticketBuyers;

  address private wethAddress = 0xA6FA4fB5f76172d178d61B04b0ecd319C5d1C0aa;
  IERC20 weth;

  address private seaportAddress = 0x00000000000001ad428e4906aE43D8F9852d0dD6;

  string public currentPrice;
  bytes32 private jobId;
  uint256 private fee;
  string url;

  Ticket ticket;

  event RaffleCreated(uint indexed raffleId, address owner, string name, address nftAdress, uint nftTokenId, uint ticketPrice, uint salePrice, uint sellPrice, uint endTime);
  event TicketsBought(uint indexed raffleId, string raffleName, address buyerAddress, address ticketAddress, uint ticketId);
  event WinnerDeclared(uint indexed raffleId, string raffleName, address winnerAddress);
  event TicketsRefunded(uint indexed raffleId, string raffleName);
  event RequestVolume(bytes32 indexed requestId, string currentPrice);

  constructor(address _ticketAddress) {
    platformFeeAccount = payable(msg.sender);
    platformFeePercent = 10;

    raffleId = 0;

    ticket = Ticket(_ticketAddress);
    weth = IERC20(wethAddress);

    setChainlinkToken(0x326C977E6efc84E512bB9C30f76E30c160eD06FB);
    setChainlinkOracle(0x40193c8518BB267228Fc409a613bDbD8eC5a97b3);
    jobId = "7d80a6386ef543a3abb52817f6707e3b";
    fee = (1 * LINK_DIVISIBILITY) / 10;
  }

  modifier isOwner() {
    require(msg.sender == platformFeeAccount, "Only the owner of the Raffle can call this function.");
    _;
  }

  modifier isActive(uint _raffleId) {
    require(raffles[_raffleId].ended == false, "Raffle has ended.");
    _;
  }

  function st2num(string memory numString) public pure returns(uint) {
    uint val=0;
    bytes memory stringBytes = bytes(numString);
    for (uint  i =  0; i<stringBytes.length; i++) {
      uint exp = stringBytes.length - i;
      bytes1 ival = stringBytes[i];
      uint8 uval = uint8(ival);
      uint jval = uval - uint(0x30);

      val +=  (uint(jval) * (10**(exp-1))); 
    }
    return val;
  }

  function _random() private view returns (uint) {
    uint seed = block.number;

    uint a = 1103515245;
    uint c = 12345;
    uint m = 2 ** 32;

    return (a * seed + c) % m;
  }

  function onERC721Received( address , address , uint256 , bytes calldata  ) public pure override returns (bytes4) {
    return this.onERC721Received.selector;
  }

  /**
  * Create a Chainlink request to retrieve API response, find the target
  * data which is located in a list
  */
  function requestPrice(address _nftAddress, uint _nftTokenId) public returns (bytes32 requestId) {
    Chainlink.Request memory req = buildChainlinkRequest(
        jobId,
        address(this),
        this.fulfill.selector
    );

    url = string(abi.encodePacked("https://testnets-api.opensea.io/v2/orders/mumbai/seaport/listings?format=json&asset_contract_address=", Strings.toHexString(_nftAddress), "&token_ids=", Strings.toString(_nftTokenId), "&limit=10"));

    // Set the URL to perform the GET request on
    req.add(
      "get",
      url
    );

    req.add("path", "orders,0,current_price"); // Chainlink nodes 1.0.0 and later support this format

    return sendChainlinkRequest(req, fee);
  }

  /**
  * Receive the response in the form of string
  */
  function fulfill(
    bytes32 _requestId,
    string memory _currentPrice
  ) public recordChainlinkFulfillment(_requestId) {
    emit RequestVolume(_requestId, _currentPrice);
    currentPrice = _currentPrice;
  }

  /**
  * Allow withdraw of Link tokens from the contract
  */
  function withdrawLink() public isOwner {
    LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
    require(
      link.transfer(msg.sender, link.balanceOf(address(this))),
      "Unable to transfer"
    );
  }

  function createRaffle(string memory _name, address _nftAddress, uint _nftTokenId, uint _salePrice, uint _ticketPrice, uint _sellPrice, uint _endTime) external {
    raffles[raffleId].raffleId = raffleId;
    raffles[raffleId].owner = msg.sender;
    raffles[raffleId].name = _name;
    raffles[raffleId].nftAddress = _nftAddress;
    raffles[raffleId].nftTokenId = _nftTokenId;
    raffles[raffleId].ticketPrice = _ticketPrice;
    raffles[raffleId].salePrice = _salePrice;
    raffles[raffleId].sellPrice = _sellPrice;
    raffles[raffleId].endTime = _endTime;
    raffles[raffleId].ticketCount = 0;
    // raffles[raffleId].ticketBuyers = raffleId;
    raffles[raffleId].ended = false;
    
    emit RaffleCreated(raffles[raffleId].raffleId, raffles[raffleId].owner, raffles[raffleId].name, raffles[raffleId].nftAddress, raffles[raffleId].nftTokenId, raffles[raffleId].ticketPrice, raffles[raffleId].salePrice, raffles[raffleId].sellPrice, raffles[raffleId].endTime);   

    raffleId++;
  }

  function purchaseTickets(uint _raffleId, uint _sellPrice, string memory _tokenURI) public payable isActive(_raffleId) {
    require(msg.sender != raffles[_raffleId].owner, "The owner cannot buy raffle tickets.");
    // require(msg.value == raffles[_raffleId].ticketPrice, "Inaccurate message value.");

    if (block.timestamp > raffles[_raffleId].endTime) {
      checkRaffleResult(_raffleId, _sellPrice);
    } else {
      uint totalCollected = raffles[_raffleId].ticketCount * raffles[_raffleId].ticketPrice;
      if (_sellPrice != raffles[_raffleId].sellPrice) {
        refundTicket(_raffleId);
      } else if (totalCollected >= raffles[_raffleId].salePrice) {
        declareWinner(_raffleId);
      } else {
        weth.transferFrom(msg.sender, address(this), _sellPrice);
    
        uint ticketId = ticket.mint(_tokenURI);
        ticket.transferFrom(address(this), msg.sender, ticketId);

        // // raffles[_raffleId].tickets[raffles[_raffleId].ticketId] = msg.sender;
        raffles[_raffleId].ticketBuyers.push(msg.sender);
        raffles[_raffleId].ticketCount++;
        raffles[_raffleId].ticketIds[msg.sender] = ticketId;

        emit TicketsBought(_raffleId, raffles[_raffleId].name, msg.sender, address(ticket), 0);
      }
    }    
  }

  function getTicketBuyers(uint _raffleId) public view returns(address[] memory) {
    return raffles[_raffleId].ticketBuyers;
  }

  function getTicketId(uint _raffleId, address _buyerAddress) public view returns(uint) {
    return raffles[_raffleId].ticketIds[_buyerAddress];
  }

  function checkRaffleResult(uint _raffleId, uint _sellPrice) private {
    uint totalCollected = raffles[_raffleId].ticketCount * raffles[_raffleId].ticketPrice;
    // requestPrice(raffles[_raffleId].nftAddress, raffles[_raffleId].nftTokenId);
    if (_sellPrice != raffles[_raffleId].sellPrice) {
      refundTicket(_raffleId);
    } else if (totalCollected >= raffles[_raffleId].salePrice) {
      declareWinner(_raffleId);
    } else {
      refundTicket(_raffleId);
    }
  }

  function declareWinner(uint _raffleId) private {
    require(raffles[_raffleId].ticketCount > 0, "No one bought the tickets.");

    uint ticketIdx = _random() % raffles[_raffleId].ticketCount;
    raffles[_raffleId].winner = payable(raffles[_raffleId].ticketBuyers[ticketIdx]);
    buyNFT(_raffleId);
    emit WinnerDeclared(_raffleId, raffles[_raffleId].name, raffles[_raffleId].winner);
    raffles[_raffleId].ended = true;
  }

  function buyNFT(uint _raffleId) private {
    transferNFT(_raffleId);
  }

  function transferNFT(uint _raffleId) private {
    uint totalCollected = raffles[_raffleId].ticketCount * raffles[_raffleId].ticketPrice;
    uint totalProfit = totalCollected - raffles[_raffleId].sellPrice;

    bool sentToWinner = weth.transfer(raffles[_raffleId].winner, raffles[_raffleId].sellPrice);
    require(sentToWinner, "Failed to transfer winning amount to winner");

    uint platformFee = (platformFeePercent * totalProfit) / 100;
    bool sentToPlatform = weth.transfer(platformFeeAccount, platformFee);
    require(sentToPlatform, "Failed to transfer platform fees");

    uint flipperProfit = totalProfit - platformFee;
    bool sentToFlipper = weth.transfer(raffles[_raffleId].owner, flipperProfit);
    require(sentToFlipper, "Failed to transfer Flipper Profit");

    raffles[_raffleId].ended = true;
  }

  function refundTicket(uint _raffleId) private {
    for(uint i = 0; i < raffles[_raffleId].ticketCount; i++) {
      bool refundTickets = weth.transfer(raffles[_raffleId].ticketBuyers[i], raffles[_raffleId].ticketPrice);
      require(refundTickets, "Failed to send Ether");
    }
    emit TicketsRefunded(_raffleId, raffles[_raffleId].name);
    raffles[_raffleId].ended = true;
  }
}