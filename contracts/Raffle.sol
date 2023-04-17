//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface/sol";
error Raffle__NotEnoughEHEntered();
error Raffle__TransverFailed();
contract raffle is VRFConsumerBaseV2 {
    /* State variable */
    address payable[] private s_players;
    uint256 private immutable i_entranceFee; 
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    bytes64 private immutable i_subscriptionId;
    uint16  private constant REQUEST_CONFIRMATION = 3 ;
    uint32  private constant i_callbackGasLimit;
    uint16  private constant numWords = 1 ;

    address private s_recentWinner ;

    /* events */
    event RaffleEnter(address indexed player);
    event RequestRaffleWinner(uint256 indexed requestId);
    event WinnerPicked(address indexed winner);

    constructor(address vrfCoordinatorV2, uint256 entranceFee, bytes32 gasLane, bytes64 subscriptionId,uint32 callbackGasLimit) VRFConsumerBaseV2(vrfCoordinatorV2){
        i_entranceFee = entranceFee ;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId ;
        i_callbackGasLimit = callbackGasLimit;
    }

    function enterRaffle() public payable {
        if (msg.value < i_entranceFee ) {revert Raffle__NotEnoughEHEntered();}
        s_players.push(payable(msg.sender));
        emit RaffleEnter(msg.sender);
    }

    function requestRandomWinner() external {
        //request a random number
        uint256 reequestId = i_vrfCoordinator.requestRandomWords(
        i_gasLane,
        i_subscriptionId,
        REQUEST_CONFIRMATION,
        i_callbackGasLimit,
        numWords
    ); 
        emit RequestRaffleWinner(reequestId);
    }

    function fullfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexOfWinner];
        s_recentWinner = recentWinner ;
        (bool, success, ) = recentWinner.call{value: address(this).balance}("");
        if (!success) {
            revert Raffle__TransverFailed();
        }
        emit WinnerPicked(s_recentWinner);
    }

    /* View / pure functions */
    function getEntranceFee() public view returns (uint256) {
    return i_entranceFee ;
    }

    function getPlayers(uint256 index) public view returns (address) {
        return s_players[index];
    }

    function getRecentWinner() public view returns ( address) {
        return s_recentWinner ;
    }

}
//Enter the lottery ( paaying some money )
//pick a random winner ( verifiably random)
//winner to be selected every X minutes -> completly automated


//chainlink to get the randomness from outside the blockchain, Autamted Execution( chainlink keepers)