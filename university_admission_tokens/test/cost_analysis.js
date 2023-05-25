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
  const feesPerUoc = (10**3);

  describe("Cost analysis", () =>{
    it("should log transaction costs", async() => {
      const initialTokens = 300;
      const uat = await UniAdmissionToken.deployed();
      // UniAdmin role granted by COO
      const txGrantUniAdminRole = await uat.grantUniAdminRole(uniAdmin01, {from: coo});
      // Admit students
      const txAdminStudentToUni = await uat.admitStudentToUni(student01, {from: uniAdmin01});
      // Create course
      const deadline01 = Date.now() + 1000;
      const quota01 = 1;
      const txCreateCourse = await uat.createCourse("COMP01", quota01, deadline01, {from: uniAdmin01});

      // Student01 buys 100 tokens
      const uocToBuy = 1;
      const feesInWei = uocToBuy*feesPerUoc;
      const txPayFees = await uat.payFees({from: student01, value: feesInWei});

      // Student bids
      const txBid = await uat.bidAdmissionTokens("COMP01", {from: student01, value: 100});

      // Admin closes course
      const txCloseEnrollment = await uat.closeEnrollment("COMP01", {from: uniAdmin01});

      // Log and calculate the total gas used
      let totalGasUsed = 0;

      console.log("Cost of granting uni admin role:");
      console.log(txGrantUniAdminRole['receipt']['gasUsed']);
      totalGasUsed+=txGrantUniAdminRole['receipt']['gasUsed'];

      console.log("Cost of admitting a student to uni:");
      console.log(txAdminStudentToUni['receipt']['gasUsed']);
      totalGasUsed+=txAdminStudentToUni['receipt']['gasUsed'];

      console.log("Cost of creating a course:");
      console.log(txCreateCourse['receipt']['gasUsed']);
      totalGasUsed+=txCreateCourse['receipt']['gasUsed'];

      console.log("Cost of paying fees:");
      console.log(txPayFees['receipt']['gasUsed']);
      totalGasUsed+=txPayFees['receipt']['gasUsed'];

      console.log("Cost of bidding:");
      console.log(txBid['receipt']['gasUsed']);
      totalGasUsed+=txBid['receipt']['gasUsed'];

      console.log("Cost of enrollment:");
      console.log(txCloseEnrollment['receipt']['gasUsed']);
      totalGasUsed+=txCloseEnrollment['receipt']['gasUsed'];

      console.log("Total gas used:");
      console.log(totalGasUsed);
    });

  });

});
