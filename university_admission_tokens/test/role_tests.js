const UniAdmissionToken = artifacts.require("UniAdmissionToken");


/*
 * Tests on basic role functionalities
 */
contract("UniAdmissionToken", accounts => {

  const coo = accounts[0];
  const uniAdmin01 = accounts[1];
  const uniAdmin02 = accounts[2];
  const student01 = accounts[3];
  const student02 = accounts[4];
  const outsider = accounts[5];
  const lecturer01 = accounts[6];

  const eventRoleGranted = "RoleGranted";
  const eventStudentAdmitted = "StudentAdmitted";
  const eventTransfer = "Transfer";
  const eventStudentPaidFees = "StudentPaidFees";
  const eventCourseCreated = "CourseCreated";
  const eventCourseModified = "CourseModified";
  const feesPerUoc = (10**3);
 
  describe("The COO role", () =>{
    let uat = null;
    before(async() => {
      uat = await UniAdmissionToken.deployed();
      // UniAdmin role granted by COO
      await uat.grantUniAdminRole(uniAdmin01, {from: coo});
      await uat.grantUniAdminRole(uniAdmin02, {from: coo});
      // Admit students
      await uat.admitStudentToUni(student01, {from: uniAdmin01});
      await uat.admitStudentToUni(student02, {from: uniAdmin02});
    });

    it("should be able to setFeesPerUoc", async () => {
      const newPrice = 10**2;
      const tx = await uat.setFeesPerUoc(newPrice);
      const expectedEvent = "FeesPerUocChanged";
      const actualEvent = tx.logs[0].event;
      assert.equal(
        actualEvent,
        expectedEvent,
        "fees should have changed",
      );

      const gotNewFeesPerUoc = await uat.getFeesPerUoc();
      assert.equal(
        gotNewFeesPerUoc,
        newPrice,
        "fees should have changed",
      );

      // Change the fees back again
      await uat.setFeesPerUoc(feesPerUoc);
    });

  })
  
  describe("A UniAdmin role", () =>{
    let uat = null;
    beforeEach(async() => {
      uat = await UniAdmissionToken.deployed();
      // UniAdmin role granted by COO
      await uat.grantUniAdminRole(uniAdmin01, {from: coo});
      await uat.grantUniAdminRole(uniAdmin02, {from: coo});
    });

    it("should be able to admit a student", async () => {
      const tx = await uat.admitStudentToUni(student01, {from: uniAdmin01});
      assert.equal(
        tx.logs[0].event,
        eventStudentAdmitted,
        "student must have emitted an StudentAdmitted event",
      );
      // Get the created student attributes
      const studentCreatedAttr = await uat.getStudent(student01);
      const gotAddress = studentCreatedAttr[0];
      const gotAdmissionTokens = studentCreatedAttr[1];
      assert.equal(
        gotAddress,
        student01,
        "admitted student must have the same address as originally given"
      );
      assert.equal(
        gotAdmissionTokens,
        0,
        "admitted student starts with 0 tokens"
      );
    });

    it("should be able to create a course", async() => {
      const deadline = 1617533564;
      const tx = await uat.createCourse("COMP01", 100, deadline, {from: uniAdmin01});
      assert.equal(
        tx.logs[0].event,
        eventCourseCreated,
        "Course should have been created"
      );
    });
    
    it("should be able to modify a course", async() => {
      const biddingDeadline = 1617533560;
      const quota = 2;
      const course = "COMP02";
      await uat.createCourse(course, quota, biddingDeadline, {from: uniAdmin01});
      const newQuota = quota + 10;
      const newDeadline = 123;
      const prereqs = ["COMP03"];
      const tx = await uat.modifyCourse(course, newQuota, newDeadline, lecturer01, prereqs, {from: uniAdmin01});
      assert.equal(
        tx.logs[0].event,
        eventCourseModified,
        "Course should have been modified"
      );
    });


  })

  describe("A Student role", () =>{
    let uat = null;
    beforeEach(async() => {
      uat = await UniAdmissionToken.deployed();
      // UniAdmin role granted by COO
      await uat.grantUniAdminRole(uniAdmin01, {from: coo});
      await uat.grantUniAdminRole(uniAdmin02, {from: coo});
      // Admit students
      await uat.admitStudentToUni(student01, {from: uniAdmin01});
      await uat.admitStudentToUni(student02, {from: uniAdmin02});
    });

    it("should be able to pay for 3 uoc and get 300 admission tokens", async() => {
      // Check balance initially
      const contractAddress = await uat.getContractAddress();
      const contractBalanceBefore = Number(await web3.eth.getBalance(contractAddress));
      assert.equal(
        contractBalanceBefore,
        0,
        "Contract balance must be 0"
      );

      const uocToBuy = 3;
      const feesInWei = uocToBuy*feesPerUoc;
      const tx = await uat.payFees({from: student01, value: feesInWei});
      assert.equal(
        tx.logs[0].event,
        eventStudentPaidFees,
        "Student should have been able to pay fees"
      );
    
      // 3 UOC bought == 300 admission tokens
      const expectedAdmissionTokens = (feesInWei / feesPerUoc) * 100;
      const studentCreatedAttr = await uat.getStudent(student01);
      const gotAdmissionTokens = studentCreatedAttr[1];
      assert.equal(
        Number(gotAdmissionTokens),
        expectedAdmissionTokens,
        "student should have gotten 300 admission token"
      );
      
      // Check the balance. WHY DOUBLE??
      const contractBalance = Number(await web3.eth.getBalance(contractAddress));
      assert.equal(
        contractBalance,
        feesInWei,
        "Balance must be the same as student paid"
      );
    
    });

    it("should not be able to admit another student", async() => {
      try {
        const tx = await uat.admitStudentToUni(student01, {from: student02});
        assert.fail("Student should not have been able to admit another student");
      } catch(e) {
        assert(e.message.includes("Not UniAdmin"));
      }
    });
    
    it("should throw an error if student is not found", async() => {
      try {
        const studentCreatedAttr = await uat.getStudent(outsider);
        assert.fail("Missing student should fail");
      } catch(e) {
        assert(e.message.includes("Student not found"));
      }
    });
  });

});
