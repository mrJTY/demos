const UniAdmissionToken = artifacts.require("UniAdmissionToken");

/*
 * Tests the closing of enrollments
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
  const eventStudentEnrolled = "StudentEnrolled";
  const eventCourseEnrollmentClosed = "CourseEnrollmentClosed";
  const feesPerUoc = (10**3);
  var cost = 0;

  describe("Enrollments:", () =>{
    let uat = null;
    before(async() => {
      uat = await UniAdmissionToken.deployed();
      // UniAdmin role granted by COO
      await uat.grantUniAdminRole(uniAdmin01, {from: coo});
      await uat.grantUniAdminRole(uniAdmin02, {from: coo});
      // Admit students
      await uat.admitStudentToUni(student01, {from: uniAdmin01});
      await uat.admitStudentToUni(student02, {from: uniAdmin02});
      // Create courses
      const deadline01 = 1617533560;
      const quota01 = 1;
      await uat.createCourse("COMP01", quota01, deadline01, {from: uniAdmin01});
      const deadline02 = 1617533590;
      const quota02 = 2;
      await uat.createCourse("COMP02", quota02, deadline02, {from: uniAdmin01});

      // Student01 buys 300 tokens
      const uocToBuy01 = 3;
      const feesInWei01 = uocToBuy01*feesPerUoc;
      await uat.payFees({from: student01, value: feesInWei01});
      // Bids of student 01
      await uat.bidAdmissionTokens("COMP01", {from: student01, value: 100});
      await uat.bidAdmissionTokens("COMP02", {from: student01, value: 200});

      // Student02 buys 600 tokens
      const uocToBuy02 = 6;
      const feesInWei02 = uocToBuy02*feesPerUoc;
      await uat.payFees({from: student02, value: feesInWei02});
      // Bids of student 02
      await uat.bidAdmissionTokens("COMP01", {from: student02, value: 300});
      await uat.bidAdmissionTokens("COMP02", {from: student02, value: 300});
    });

    it("uniAdmin should be able to close enrollments for COMP01", async() => {
      const tx = await uat.closeEnrollment("COMP01", {from: uniAdmin01});
      assert.equal(
        tx.logs[0].event,
        eventStudentEnrolled,
      );
      assert.equal(
        tx.logs[1].event,
        eventCourseEnrollmentClosed,
      );
    });

    it("uniAdmin should be able to close enrollments for COMP02", async() => {
      const tx = await uat.closeEnrollment("COMP02", {from: uniAdmin02});
      assert.equal(
        tx.logs[0].event,
        eventStudentEnrolled,
      );
      assert.equal(
        tx.logs[1].event,
        eventCourseEnrollmentClosed,
      );
    });

    it("student01 should not be able to enroll in COMP01 due to quota limtations", async() => {
      const course01 = await uat.getCourse("COMP01");
      const studentsEnrolled = course01[3];
      assert.equal(
        studentsEnrolled.includes(student01),
        false,
        "Student01 should not have been able to make it for COMP01"
      );
    });

    it("student02 should be able to enroll in COMP01", async() => {
      const course01 = await uat.getCourse("COMP01");
      const studentsEnrolled = course01[3];
      assert.equal(
        studentsEnrolled.includes(student02),
        true,
        "Student02 should have been able to make it for COMP01"
      );
    });

    it("both student01 and student02 should be able to enroll in COMP02", async() => {
      const course02 = await uat.getCourse("COMP02");
      const studentsEnrolled = course02[3];
      assert.equal(
        studentsEnrolled.includes(student01),
        true,
        "Student01 should have been able to make it for COMP02"
      );
      assert.equal(
        studentsEnrolled.includes(student02),
        true,
        "Student02 should have been able to make it for COMP02"
      );
    });

  });

});
