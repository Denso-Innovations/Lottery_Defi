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
     // Lets make a mapping to hold players already listed in the array 
     // Our List should not contain duplicate addresses   
     // Reversing !ExistingPlayers[msg.sender] should work  
    mapping(address => bool ) ExistingPlayers ; 

  
    // An array to hold existing players and their information  
    // We'll have a function which populates the players information 
    
    lotteryAccounts[] public Players ; 
    struct lotteryAccounts { 
        address PlayerAddr;
        string accountName ; 
        string createdOn ;
        uint  wins ;
    }

    



   function InitializeAccounts() public {
     
   }
  
    // Specify Ticket Amount as the amount:parameter in TP event
    // So as to see the disticntion between msg.value | ticketprice 
    /* 
	[
	{
		"from": "0x62FF318Bee4D6d605D163Ed3325077E32803599B",
		"topic": "0x0668f5b446eb814fe35b3206f43f14bd8567ba04ddaf7a3ee56516929ab22ccb",
		"event": "TicketPurchased",
		"args": {
			"0": "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4",
			"1": "100",
			"player": "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4",
			"amount": "100" // Change this to reflect ticket price 
		}
	}
]


    */
    event TicketPurchased(address indexed player, uint amount);
    event WinnerSelected(address indexed winner, uint prize);
    // Initializes the contract with values for  Owner , TicketPrice  , LotteryOpen  
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
        // Having msg.value == ticketPrice  means you have to pass a matching set of values | ticket price
        // Lets make sure the user can pay fot more than one ticket if not he should then recharge 
        // Adv : Allow topups to override msg.value 
        // Remember  to pass a value >= ticketprice to the Account calling the contract
        require(msg.value >= ticketPrice, "Insufficient Funds Available For Ticket Purchase");
        // Pushing player address to players array 
        // Let make sure the address is not available in our array  
        players.push(msg.sender);
        // Still looks like ticketPrice is overlapping with the msg.value 
        // Ensure TicketPurchased Returns ( Owner , TicketPrice ) 
        emit TicketPurchased(msg.sender, ticketPrice);

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

