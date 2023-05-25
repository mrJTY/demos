const UniAdmissionToken = artifacts.require("UniAdmissionToken");

/**
 * Tests for transferring funds.
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
  const eventStudentToStudentTransfer = "StudentToStudentTransfer";
  const feesPerUoc = (10**3);
  describe("The COO transferring tokens", () =>{
    let uat = null;
    before(async() => {
      uat = await UniAdmissionToken.deployed();
      // UniAdmin role granted by COO
      await uat.grantUniAdminRole(uniAdmin01, {from: coo});
      await uat.grantUniAdminRole(uniAdmin02, {from: coo});
      // UniAdmin role granted by COO
      await uat.grantUniAdminRole(uniAdmin01, {from: coo});
      await uat.grantUniAdminRole(uniAdmin02, {from: coo});
      // Admit students
      await uat.admitStudentToUni(student01, {from: uniAdmin01});
      await uat.admitStudentToUni(student02, {from: uniAdmin02});
    });

    it("should be able to transfer to an outsider", async() => {
      // Student01 purchases 3UOC with wei
      const uocToBuy = 3;
      const feesInWei = uocToBuy*feesPerUoc;
      await uat.payFees({from: student01, value: feesInWei});

      // Check outsider's balance before
      const outsiderBalanceBefore = await web3.eth.getBalance(outsider);
      const transferAmount = 42;

      // Withdraw funds as COO
      const tx = await uat.withdrawFunds(outsider, transferAmount, {from: coo});

      // Check balance of outsider after
      const outsiderBalanceAfter = BigInt(await web3.eth.getBalance(outsider));
      const expected = BigInt(outsiderBalanceBefore) + BigInt(transferAmount);
      assert.deepEqual(
        outsiderBalanceAfter,
        expected,
        "Outsider should have received funds"
      );
    });
  });

  describe("An Outsider transferring tokens", () =>{
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

    it("should not be able to pay fees if not admitted", async() => {
      const uocToBuy = 3;
      const feesInWei = uocToBuy*feesPerUoc;
      try {
        const tx = await uat.payFees({from: outsider, value: feesInWei});
        assert.fail("Outsider should not be able to pay fees");
      } catch(e) {
        assert(e.message.includes("Not Student"));
      }
    })
  });

  describe("A Student transfering tokens", () =>{
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

    it("should be able to transfer funds to another student", async() => {
        // Student 1 buys some tokens...
        const uocToBuy = 2;
        const feesInWei = uocToBuy*feesPerUoc;
        await uat.payFees({from: student01, value: feesInWei});

        // Get token balances before transfer
        const student01Before = await uat.getStudent(student01);
        const student02Before = await uat.getStudent(student02);
        const student01BalanceBefore = student01Before[1];
        const student02BalanceBefore = student02Before[1];

        const transferTokens = 50;
        // contract takes a 10% cut
        const cut = transferTokens * 0.1;
        const transferMinusCut = transferTokens - cut;
        const tx = await uat.studentToStudentTransfer(student02, transferTokens, {from: student01});
        assert.equal(
            tx.logs[0].event,
            eventStudentToStudentTransfer,
            "First event should have been a student to student transfer"
        );

        // Get balances after
        const student01After = await uat.getStudent(student01);
        const student02After = await uat.getStudent(student02);
        const student01BalanceAfter = student01After[1];
        const student02BalanceAfter = student02After[1];

        assert.equal(
            Number(student01BalanceAfter),
            Number(student01BalanceBefore) - transferTokens - cut,
            "Student01's tokens should have been reduced"
        );

        assert.equal(
            Number(student02BalanceAfter),
            Number(student02BalanceBefore) + transferTokens,
            "Student02's tokens should have been increased with a 10% cut"
        );

    });

  });


});
