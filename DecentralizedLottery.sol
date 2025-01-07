// Decentralized lottery system 
// User can buy tickets 
// Randamize the prize 

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract DecentralizedLottery {
    address public owner;
    address[] public players;
    uint public ticketPrice;
    bool public lotteryOpen;

    event TicketPurchased(address indexed player, uint amount);
    event WinnerSelected(address indexed winner, uint prize);

    constructor(uint _ticketPrice){
        owner = msg.sender;
        ticketPrice = _ticketPrice;
        lotteryOpen = true;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action"
        );
        _;
    }

    modifier isLotteryOpen() {
        require(lotteryOpen, "The lottery is closed");
        _;
    }

    function buyTicket() public payable isLotteryOpen {
        require(msg.value == ticketPrice, "Incorrect ticket price");
        players.push(msg.sender);
        emit TicketPurchased(msg.sender, msg.value);
    }

    function drawWinner() public onlyOwner {
        require(players.length > 0, "No players in the lottery");

        uint randomIndex = uint(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, players))) % players.length;
        address winner = players[randomIndex];
        uint prize = address(this).balance;

        (bool success, ) = winner.call{value: prize}("");
        require(success, "Prize transfer failed");

        emit WinnerSelected(winner, prize);

        players = new address[](0);  
        lotteryOpen = false;
    }

    function startNewRound(uint _ticketPrice) public onlyOwner {
        require(!lotteryOpen, "Current lottery still active");
        ticketPrice = _ticketPrice;
        lotteryOpen = true;
    }

    function getPlayer() public view returns (address[] memory) {
        return players;
    }
}
