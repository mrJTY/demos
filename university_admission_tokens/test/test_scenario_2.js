
const UniAdmissionToken = artifacts.require("UniAdmissionToken");


/*
 * Tests scenarios as outlined by the requirements file
 */
contract("UniAdmissionToken", accounts => {
  const coo = accounts[0];
  const uniAdmin01 = accounts[1];
  const student01 = accounts[2];
  const student02 = accounts[3];
  const student03 = accounts[4];
  const student04 = accounts[5];
  const student05 = accounts[6];

  const eventRoleGranted = "RoleGranted";
  const eventStudentAdmitted = "StudentAdmitted";
  const eventTransfer = "Transfer";
  const eventStudentPaidFees = "StudentPaidFees";
  const eventCourseCreated = "CourseCreated";
  const eventCourseModified = "CourseModified";
  const feesPerUoc = 1000;

  const students = [student01, student02, student03, student04, student05];

  describe("Test scenario 2", () => {
    let uat = null;
    before(async() => {
      uat = await UniAdmissionToken.deployed();
      // COO sets the feesPerUOC
      await uat.setFeesPerUoc(feesPerUoc);

      // UniAdmin role granted by COO
      await uat.grantUniAdminRole(uniAdmin01, {from: coo});

      // Admit students
      await uat.admitStudentToUni(student01, {from: uniAdmin01});
      await uat.admitStudentToUni(student02, {from: uniAdmin01});
      await uat.admitStudentToUni(student03, {from: uniAdmin01});
      await uat.admitStudentToUni(student04, {from: uniAdmin01});
      await uat.admitStudentToUni(student05, {from: uniAdmin01});

      // Create courses
      const deadline = Date.now() + 1000;
      await uat.createCourse("COMP6451", 2, deadline, {from: uniAdmin01});
      await uat.createCourse("COMP4212", 3, deadline, {from: uniAdmin01});

      // Each student pays for 18 UOC
      const uocToBuy = 18;
      const feesInWei = uocToBuy*feesPerUoc;
      for(i=0; i< students.length; i++) {
          await uat.payFees({from: students[i], value: feesInWei});
      }

      // First round
      await uat.bidAdmissionTokens("COMP6451", {from: student01, value: 1200});
      await uat.bidAdmissionTokens("COMP6451", {from: student02, value: 800});
      await uat.bidAdmissionTokens("COMP6451", {from: student03, value: 1000});
      await uat.bidAdmissionTokens("COMP6451", {from: student04, value: 600});
      await uat.bidAdmissionTokens("COMP6451", {from: student05, value: 600});
      await uat.closeEnrollment("COMP6451", {from: uniAdmin01});

    });

    it("should reject student01's bid", async () => {
      try{
        await uat.bidAdmissionTokens("COMP4212", {from: student01, value: 800});
      } catch(e) {
        assert(e.message.includes("Not enough tokens"));
      }
    });

    it("should enroll students 2,3 and 4", async () => {
      await uat.bidAdmissionTokens("COMP4212", {from: student02, value: 800});
      await uat.bidAdmissionTokens("COMP4212", {from: student03, value: 800});
      await uat.bidAdmissionTokens("COMP4212", {from: student04, value: 900});
      await uat.bidAdmissionTokens("COMP4212", {from: student05, value: 700});

      // Admin closes the enrollment
      await uat.closeEnrollment("COMP4212", {from: uniAdmin01});

      // Get who is enrolled
      const course = await uat.getCourse("COMP4212");
      const studentsEnrolled = course[3];

      assert.equal(studentsEnrolled.indexOf(student01)>=0, false, "Student 1 should NOT have been enrolled");
      assert.equal(studentsEnrolled.indexOf(student02)>=0, true, "Student 2 should have been enrolled");
      assert.equal(studentsEnrolled.indexOf(student03)>=0, true, "Student 3 should have been enrolled");
      assert.equal(studentsEnrolled.indexOf(student04)>=0, true, "Student 4 should have been enrolled");
      assert.equal(studentsEnrolled.indexOf(student05)>=0, false, "Student 5 should NOT have been enrolled");
    });

    it("should have the correct student balances after enrollment", async() => {
        const studentData01 = await uat.getStudent(student01);
        const balance01 = studentData01[1];
        assert.equal(Number(balance01), 600);
        
        const studentData02 = await uat.getStudent(student02);
        const balance02 = studentData02[1];
        assert.equal(Number(balance02), 1000);
        
        const studentData03 = await uat.getStudent(student03);
        const balance03 = studentData03[1];
        assert.equal(Number(balance03), 0);
        
        const studentData04 = await uat.getStudent(student04);
        const balance04 = studentData04[1];
        assert.equal(Number(balance04), 900);
        
        const studentData05 = await uat.getStudent(student05);
        const balance05 = studentData05[1];
        assert.equal(Number(balance05), 1800);

    });

  });
})
