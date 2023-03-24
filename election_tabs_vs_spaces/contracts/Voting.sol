pragma solidity >=0.4.25 <0.7.0;

contract Voting {
    mapping(string => uint256) public votes;

    // Records who voted for what, could be turned off if anonymous voting
    event Vote(address voter, string candidate);

    constructor() public {
        votes["tabs"] = 0;
        votes["spaces"] = 0;
    }

    function getTotalVotes(string memory candidate) view public returns(uint256) {
        return votes[candidate];
    }
    
    function vote(string memory candidate) payable public {
        emit Vote(msg.sender, candidate);
        votes[candidate] = votes[candidate] + 1;
    }
    
}