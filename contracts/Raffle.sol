//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
error Raffle__NotEnoughEHEntered();
contract raffle is VRFConsumerBaseV2{
    /* State variable */
    address payable[] private s_players;
    uint256 private immutable i_entranceFee; 

    /* events */
    event RaffleEnter(address indexed player);

    constructor(uint256 entranceFee){
        i_entranceFee = entranceFee ;
    }

    function enterRaffle() public payable {
        if (msg.value < i_entranceFee ) {revert Raffle__NotEnoughEHEntered();}
        s_players.push(payable(msg.sender));
        emit RaffleEnter(msg.sender);
    }

    function requestRandomWinner() external {
        //request a random number
        // once we get it, do something with it
        // picking number is a 2 transactions process
    }

    function fullfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {}

    /* View / pure functions */
    function getEntranceFee() public view returns (uint256) {
    return i_entranceFee ;
    }

    function getPlayers(uint256 index) public view returns (address) {
        return s_players[index];
    }

}
//Enter the lottery ( paaying some money )
//pick a random winner ( verifiably random)
//winner to be selected every X minutes -> completly automated


//chainlink to get the randomness from outside the blockchain, Autamted Execution( chainlink keepers)