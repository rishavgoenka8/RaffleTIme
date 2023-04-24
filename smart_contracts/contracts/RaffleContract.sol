// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

import './Ticket.sol';

contract RaffleContract is IERC721Receiver, ChainlinkClient {
  using Chainlink for Chainlink.Request;

  string public currentPrice;
  bytes32 private jobId;
  uint256 private fee;

  address payable public immutable platformFeeAccount;
  uint public immutable platformFeePercent;
  uint private totalProfit;
  uint private flipperProfit;
  uint private platformFee;

  address owner;
  string name;
  address public nftAddress;
  uint public nftTokenId;
  uint public ticketPrice;
  uint public salePrice;
  uint public sellPrice;
  uint public endTime;
  address public ticketsAddress;
  uint public ticketCount;
  mapping(uint => address) private tickets;
  address[] public ticketBuyers;
  address payable public winner;
  bool ended;
  bool exists;
  string url;

  address private wethAddress = 0xD087ff96281dcf722AEa82aCA57E8545EA9e6C96;

  Ticket ticket;

  event RequestVolume(bytes32 indexed requestId, string currentPrice);
  event TicketsBought(string raffleName, address raffleAddress, address ticketAddress, uint ticketId);
  event WinnerDeclared(string raffleName, address raffleAddress, address winnerAddress);

  constructor (address payable _platformFeeAccount, address _owner, string memory _name, address _nftAddress, uint _nftTokenId, uint _salePrice, uint _ticketPrice, uint256 _endTime) {
    platformFeeAccount = _platformFeeAccount;
    platformFeePercent = 10;

    owner = _owner; 
    name = _name;
    nftAddress = _nftAddress;
    nftTokenId = _nftTokenId;
    ticketPrice = _ticketPrice;
    endTime = _endTime;
    salePrice = _salePrice;

    ticket = new Ticket(_name);
    ticketsAddress = address(ticket);

    ended = false;
    exists = true;

    setChainlinkToken(0x326C977E6efc84E512bB9C30f76E30c160eD06FB);
    setChainlinkOracle(0x40193c8518BB267228Fc409a613bDbD8eC5a97b3);
    jobId = "7da2702f37fd48e5b1b9a5715e3509b6";
    fee = (1 * LINK_DIVISIBILITY) / 10;

    requestPrice();
    sellPrice = st2num(currentPrice);
  }

  modifier isOwner() {
    require(msg.sender == owner, "Only the owner of the Raffle can call this function.");
    _;
  }

  modifier isActive() {
    require(ended == false, "Raffle has ended.");
    if (block.timestamp > endTime) {
      ended = true;
      exists = false;
      checkRaffleResult();
    }
    _;
  }

  modifier isExists() {
    require(exists == true, "Raffle has been aborted. Tickets are refunded.");
    _;
  }

  modifier checkSellPrice() {
    requestPrice();
    if (st2num(currentPrice) != sellPrice) {
      refundTicket();
      exists = false;
    }
    _;
  }

  function checkRaffleResult() private {
    uint totalCollected = ticketCount * ticketPrice;
    requestPrice();
    if (st2num(currentPrice) != sellPrice) {
      refundTicket();
    } else if (totalCollected > salePrice) {
      declareWinner();
    } else {
      refundTicket();
    }
  }

  function refundTicket() private {
    for(uint i = 0; i < ticketBuyers.length; i++) {
      (bool refundTickets, ) = ticketBuyers[i].call{value: ticketPrice}("");
      require(refundTickets, "Failed to send Ether");
    }
  }

  function buyNFT() private {
    transferNFT();
  }

  function declareWinner() private {
    require(ticketBuyers.length > 0, "No one bought the tickets.");

    uint ticketIdx = _random() % ticketCount;
    winner = payable(tickets[ticketIdx]);
    buyNFT();
    emit WinnerDeclared(name, address(this), winner);
  }

  function transferNFT() private {
    IERC20 weth = IERC20(wethAddress);
    uint totalCollected = ticketCount * ticketPrice;
    totalProfit = totalCollected - sellPrice;

    bool sentToWinner = weth.transfer(winner, sellPrice);
    require(sentToWinner, "Failed to transfer winning amount to winner");

    platformFee = (platformFeePercent * totalProfit) / 100;
    bool sentToPlatform = weth.transfer(platformFeeAccount, platformFee);
    require(sentToPlatform, "Failed to transfer platform fees");

    flipperProfit = totalProfit - platformFee;
    bool sentToFlipper = weth.transfer(owner, flipperProfit);
    require(sentToFlipper, "Failed to transfer Flipper Profit");

    ended = true;
  }

  function st2num(string memory numString) public pure returns(uint) {
    uint  val=0;
    bytes   memory stringBytes = bytes(numString);
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

  function purchaseTickets(string memory _tokenURI) public payable isActive() checkSellPrice() isExists() {
    require(msg.sender != owner, "The owner cannot buy raffle tickets.");
    require(msg.value == ticketPrice, "Inaccurate message value.");

    ticketCount = ticket.mint(_tokenURI);
    tickets[ticketCount] = msg.sender;
    ticketBuyers.push(msg.sender);

    ticket.transferFrom(address(this), msg.sender, ticketCount);

    emit TicketsBought(name, address(this), ticketsAddress, ticketCount);
  }

  /**
  * Create a Chainlink request to retrieve API response, find the target
  * data which is located in a list
  */
  function requestPrice() public returns (bytes32 requestId) {
    Chainlink.Request memory req = buildChainlinkRequest(
        jobId,
        address(this),
        this.fulfill.selector
    );

    url = string(abi.encodePacked("https://testnets-api.opensea.io/v2/orders/mumbai/seaport/listings?format=json&asset_contract_address=", Strings.toHexString(nftAddress), "&token_ids=", Strings.toString(nftTokenId), "&limit=10"));

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
}