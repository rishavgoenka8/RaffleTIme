# RaffleTime
### Setting: 
NFT flippers typically buy an NFT during the mint and sell it when there is momentum. Flippers risk their capital to buy the NFT. This is a product in which flippers can make money without risking their capital. We turn high value NFTs listed for sale on a marketplace like OpenSea into a Raffle. The tickets for the raffle can be as low as $1 or $5. Buying a raffle ticket makes a user eligible to win the NFT. When the NFT sale price is met through ticket sales, one of the ticket buyers is chosen as the winner of the raffle. NFT is transferred to the winner. Tickets are refunded when the sale price is not met. Or sale price is changed while the raffle is on-going.

### Incentive for the flipper: 
All of the proceeds from ticket sales left out after buying the NFT go to the flipper. RaffleTime platform fee is 10% from these profits. 

RaffleTime runs as a smart contract deployed on Polygon so that people can trust that the whole system runs as is. Use graph protocol or similar for indexing events from smart contracts. Use OpenSea API for getting the list of NFTs up for sale. Use Chain Link if you need any other oracles.

### What’s out of scope: 
Making the raffle ticket prices, number of tickets sold and NFT details private. For this assignment keep everything public.

### How it works:
- Raffle creators create a raffle by picking an NFT listed for sale on OpenSea
- Creator inputs raffle name, ticket price and when the raffle ticket sales are going to end
  - Raffle can end at a fixed time or whenever it meets the sale price
- Creator shares the link on discord, twitter and other places to sell raffles
- Ticket buyers come to the raffle listing page
  - They will see the NFT against which this raffle is made
  - They will see the raffle ticket price
  - They will see the number of tickets sold so far
  - They can also see the contract address
  - They can buy a ticket on this page
  - This ticket shows up as an NFT
- Ticket buyers comes back next day
  - Raffle sale time has ended
  - Case #1: 
    - NFT is still up for sale
    - Total raffle tickets sold make up for sale price
    - NFT is bought using OpenSea API
    - NFT is transferred to randomly chosen winner

  - Case #2: 
    - NFT sale price has changed
    - Raffle is aborted and tickets are refunded
  
  - Case #3:
    - NFT is still up for sale
    - Total raffle tickets don’t make up for sale price
    - Raffle is aborted
    - Tickets are refunded

### Implementation:
Smart contracts written in Solidity and a cross platform application using Flutter
