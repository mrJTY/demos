const Voting = artifacts.require("Voting");

contract("Voting", accounts => {

    const rick = accounts[0];
    const morty = accounts[1];

    describe("Rick", () => {

        let v = null;
        before(async () => {
            // Ensure that you have migrations/1_deploy_contract.js
            v = await Voting.deployed();
        });

        it("has not voted yet", async () => {
            const votes = await v.getTotalVotesCandidate("a");
            const expectedVotes = 0;
            assert.equal(
                Number(votes),
                Number(expectedVotes),
                "There must be zero votes to start with"
            )
        });

        it("should be able to vote for tabs", async () => {
            await v.vote("tabs");
            const votes = await v.getTotalVotesCandidate("tabs");
            const expectedVotes = 1;
            assert.equal(
                Number(votes),
                Number(expectedVotes),
                "There must be one vote for tabs"
            )
        });

    });

    describe("Morty", () => {

        let v = null;
        before(async () => {
            // Ensure that you have migrations/1_deploy_contract.js
            v = await Voting.deployed();
        });
        
        it("should be able to vote for spaces", async () => {
            await v.vote("spaces");
            const votes = await v.getTotalVotesCandidate("spaces");
            const expectedVotes = 1;
            assert.equal(
                Number(votes),
                Number(expectedVotes),
                "There must be one vote for spaces"
            )
        });
    });

});