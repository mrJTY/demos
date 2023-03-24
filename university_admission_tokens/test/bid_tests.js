const UniAdmissionToken = artifacts.require("UniAdmissionToken");

/*
 * Tests on bidding functionalities
 */
contract("UniAdmissionToken", accounts => {

  const coo = accounts[0];
  const uniAdmin01 = accounts[1];
  const uniAdmin02 = accounts[2];
  const student01 = accounts[3];
  const student02 = accounts[4];
  const outsider = accounts[5];

  const eventRoleGranted = "RoleGranted";
  const eventStudentAdmitted = "StudentAdmitted";
  const eventTransfer = "Transfer";
  const eventStudentPaidFees = "StudentPaidFees";
  const eventCourseCreated = "CourseCreated";
  const eventCourseModified = "CourseModified";
  const eventBidCreated = "BidCreated";
  const eventBidModified = "BidModified";
  const feesPerUoc = 10**3;
 
  describe("One bidding student", () =>{
    let uat = null;
    const initialTokens = 300;
    before(async() => {
      uat = await UniAdmissionToken.deployed();
      // UniAdmin role granted by COO
      await uat.grantUniAdminRole(uniAdmin01, {from: coo});
      await uat.grantUniAdminRole(uniAdmin02, {from: coo});
      // Admit students
      await uat.admitStudentToUni(student01, {from: uniAdmin01});
      await uat.admitStudentToUni(student02, {from: uniAdmin02});
      // Create course
      const deadline01 = Date.now() + 1000;
      const quota01 = 1;
      await uat.createCourse("COMP01", quota01, deadline01, {from: uniAdmin01});
      const deadline02 = Date.now() + 1000;
      const quota02 = 1;
      await uat.createCourse("COMP02", quota02, deadline02, {from: uniAdmin01});

      // Student01 buys 300 tokens
      const uocToBuy = 3;
      const feesInWei = uocToBuy*feesPerUoc;
      await uat.payFees({from: student01, value: feesInWei});
    });

    it("should be able to bid tokens", async() => {
      // Student bought 3 UOC bought == 300 admission tokens
      const studentBeforeBid = await uat.getStudent(student01);
      const tokensBeforeBid = studentBeforeBid[1];
      const expectedTokensBeforeBid = initialTokens;
      console.log(tokensBeforeBid);
      assert.equal(
        Number(tokensBeforeBid),
        expectedTokensBeforeBid,
        "Student must have tokens before bidding"
      );

      // Bid 175 tokens for a course
      const tokensToBid = 175;
      const tx = await uat.bidAdmissionTokens("COMP01", {from: student01, value: tokensToBid});
      assert.equal(
        tx.logs[0].event,
        eventBidCreated,
      );
     
      const studentAfterBid = await uat.getStudent(student01);
      const tokensAfterBid = studentAfterBid[1];
      const expectedTokensAfterBid = expectedTokensBeforeBid - tokensToBid;
      assert.equal(
        Number(tokensAfterBid),
        expectedTokensAfterBid,
        "Student has less tokens in balance"
      );


    });

    it("should not be able to modify a bid if it is the same", async() => {
      try {
        const newBid = 175;
        await uat.modifyBid("COMP01", newBid, {from: student01});
        assert.fail("Same bid should have failed");
      } catch(e) {
        assert(e.message.includes("Bid is the same, not modified"));
      }
    });
    
    it("should be able to modify a bid with a higher value", async() => {
      const newBid = 200;
      const tx = await uat.modifyBid("COMP01", newBid, {from: student01});
      assert.equal(
        tx.logs[0].event,
        eventBidModified,
      )
      const studentAfterBid = await uat.getStudent(student01);
      const tokensAfterBid = studentAfterBid[1];
      const expectedTokensAfterBid = initialTokens- newBid;
      assert.equal(
        tokensAfterBid,
        expectedTokensAfterBid,
        "Student should have only 100 tokens left"
      );
    });

    it("should be able to modify a bid with a lower value", async() => {
      const newBid = 50;
      const tx = await uat.modifyBid("COMP01", newBid, {from: student01});
      assert.equal(
        tx.logs[0].event,
        eventBidModified,
      )
      const studentAfterBid = await uat.getStudent(student01);
      const tokensAfterBid = studentAfterBid[1];
      const expectedTokensAfterBid = initialTokens- newBid;
      assert.equal(
        tokensAfterBid,
        expectedTokensAfterBid,
        "Student should have only 50 tokens left"
      );
    });
    
    it("should not be able to modify a non-existent bid", async() => {
      try {
        const newBid = 50;
        await uat.modifyBid("COMP02", newBid, {from: student01});
        assert.fail("Student should not be able to modify a non-existent bid");
      } catch(e) {
        assert(e.message.includes("NotFound"));
      }
    });
  });

});
