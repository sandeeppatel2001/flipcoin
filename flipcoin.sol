// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <=0.8.0;
//LuckyDraw function is the main function in which we define all the different function require for running the flipcoin game
contract flipcoin {
    // participant function intializes variable when a player enters the flipcoin game
    struct participant {
        address payable participant_address;
        uint amount;
    }
    participant participantInfo; // create state variable with struct as the reference type
    participant[] public participants; // Create an array with struct as the reference type
    
    address payable public manager; // initializes manager and it will manage the whole game
    uint public total_participants; // declares variable for total participants
    uint public contractBalance;    // initializes variable for contract balance
    address public winner;          //intializes variable to pick the winner
    // added ethereum must be greater than 0.5 ethereum so that player can't join with 0 ethereum
    modifier isPaymentEnough(){
        require( msg.value >= 0.5 ether );        
        _;
    }
    modifier restricted(){
        require( msg.sender == manager ); // Only Manager Can Call This Function
        _;
    }
    modifier ifOnlyHasParticipant(){

        require( total_participants > 0 );
        _;
    }
    constructor(){
        manager = payable(msg.sender);//this function tells who will be the manager
    }
    function entercoinflip() public payable isPaymentEnough //this function allows participants to enter the game
    {
        participantInfo = participant(payable(msg.sender), msg.value);
        participants.push( participantInfo );
        updateCondition();
    }
    function random() private view returns(uint) //this function generate the random number by using harmony VRF
    {
        return uint(keccak256(abi.encodePacked(block.difficulty,block.timestamp))) % total_participants;
    }
    function findWinner() public restricted ifOnlyHasParticipant //finds which participant is winner using random function(harmony VRF)
    {
        uint index = random();
        winner = participants[index].participant_address;
        participants[index].participant_address.transfer( address(this).balance );/// This is  rewardBets function which tranfer ethereum from one participant to another participant
        for( uint x = 0; x < total_participants; x++ ){
            participants.pop();
        }
        updateCondition();
    }
    function destroyContract() public //This function helps to restart the game by destroying the contract
    {
        selfdestruct( manager);
    }
    function updateCondition() private //This will update the variables and functions in their initial form
    {
        contractBalance =  address(this).balance; 
        total_participants = participants.length; 
    }
    
}



