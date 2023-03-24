// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract UniAdmissionToken is ERC20, Ownable, AccessControl {

  address cooAddress;
  uint64 feesPerUoc = 10**3;
  uint admissionTokensPerUoc = 100;
  uint256 balance = 0;

  // https://docs.openzeppelin.com/contracts/4.x/access-control
  bytes32 public constant STUDENT_ROLE = keccak256("STUDENT_ROLE");
  bytes32 public constant UNI_ADMIN_ROLE = keccak256("UNI_ADMIN_ROLE");
  bytes32 public constant LECTURER_ROLE = keccak256("LECTURER_ROLE");

  // Events
  event FeesPerUocChanged(uint64 newPrice);
  event StudentToStudentTransfer(address senderAddress, address receiverStudentAddress, uint256 tokenAmount);
  event StudentAdmitted(address studentAddress);
  event CourseCreated(string courseCode);
  event CourseModified(string courseCode);
  event StudentPaidFees(address studentAddress, uint256 feesPaidInWei);
  event BidCreated(address bidder, string courseCode, uint bidAmount, uint256 bidTime);
  event BidModified(address bidder, string courseCode, uint bidAmount, uint256 bidTime);
  event StudentEnrolled(address studentAddress, string courseCode, address enrolledBy);
  event CourseEnrollmentClosed(string courseCode, address closedByAdmin);

  struct Student {
    address studentAddress;
    uint256 admissionTokens;
    string[] coursesCompleted;
  }
  mapping(address => Student) private students;

  struct Course {
    string courseCode;
    uint quota;
    uint biddingDeadline;
    address[] studentsEnrolled;
    address lecturerAddress;
    string[] prerequisites;
  }
  mapping(string => Course) private courses;

  struct Bid {
    address studentAddress;
    string courseCode;
    uint256 bidAmount;
    uint256 bidTime;
  } 
  mapping(string => Bid[]) bids;

  constructor() ERC20("UniAdmissionToken", "UAT") public {
    uint256 initialSupply = 0;
    _mint(msg.sender, initialSupply);
    cooAddress = msg.sender;
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
  }

  /**
  * Returns the balance of the contract in wei
  * Reference: https://youtu.be/4k_ak3SFczc
  */
  function balanceOf() external view returns(uint) {
    return balance;
  }

  /**
   * Returns the contract's address
   */
  function getContractAddress() external view returns(address) {
    return address(this);
  }

  /**
   * Return a Student's attributes as tuple
   */
  function getStudent(address studentAddress) view external returns(address, uint256) {
    if (students[studentAddress].studentAddress == studentAddress) {
      Student storage s = students[studentAddress];
      return(s.studentAddress, s.admissionTokens);
    }
    else {
      revert("Student not found");
    }
  }

  /**
   * Get a course and return as tuple
   */ 
  function getCourse(string memory courseCode) view external returns(string memory, uint, uint, address[] memory, address, string[] memory) {
    Course storage c = courses[courseCode];
    return(c.courseCode, c.quota, c.biddingDeadline, c.studentsEnrolled, c.lecturerAddress, c.prerequisites);
  }

  /**
   * Returns true if course exists
   */
  function _courseExists(string memory courseCode) view private returns(bool) {
    // Strings can only be compared by hash
    if(keccak256(abi.encodePacked(courses[courseCode].courseCode)) == keccak256(abi.encodePacked(courseCode))){
      return true;
    }
    return false;
  }
  
  function getFeesPerUoc() view external returns(uint) {
    return feesPerUoc;
  }


  /**
   ****************************************************
   * COO Methods
   ****************************************************
  */
  function setFeesPerUoc(uint64 newPrice) external {
    // Only the COO can change the fees
    require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Not COO");
    feesPerUoc = newPrice;
    emit FeesPerUocChanged(newPrice);
  }


  /** 
   * Only the COO can withdraw funds out of the contract
   * Reference: https://youtu.be/_Nvl-gz-tRs
   */
  function withdrawFunds(address payable receiver, uint256 amountInWei) external {
    require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Not COO");
    require(amountInWei <= balance, "Withdraw request above current balance");
    balance -= amountInWei;
    receiver.transfer(amountInWei);
  }
  

  /**
   * Grants the uniAdminRole to an address.
   * Only the COO can call this.
   */
  function grantUniAdminRole(address ad) external returns(bool) {
    require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Not COO");
    _setupRole(UNI_ADMIN_ROLE, ad);
    return true;
  }

  /**
   ****************************************************
   * Uni Admin Methods
   ****************************************************
  */

  /**
   * Admit a student to the uni.
   * Only a UniAdmin can do this. 
   */
  function admitStudentToUni(address studentAddress) external {
    require(hasRole(UNI_ADMIN_ROLE, msg.sender), "Not UniAdmin");
    // empty list of courses completed
    string[] storage coursesCompleted;
    students[studentAddress] = Student(studentAddress, 0, coursesCompleted);
    // Emit student event admitted
    emit StudentAdmitted(studentAddress);
    // Grant student role
    _setupRole(STUDENT_ROLE, studentAddress);
  }


  /**
   * Create a course
   */
  function createCourse(string memory courseCode, uint quota, uint biddingDeadline) external returns(bool) {
    require(hasRole(UNI_ADMIN_ROLE, msg.sender), "Not UniAdmin");
    // Solidity is weird, can't compare with courseCode because it is memory vs storage...
    if (_courseExists(courseCode)) {
      revert("Course already exists");
    }
    // Init an empty list of students
    address[] memory emptyStudents = new address[](10);
    // Create an empty list of prerequisites
    string[] memory emptyPrereqs;
    // Assign address(0) for lecturer
    courses[courseCode] = Course(courseCode, quota, biddingDeadline, emptyStudents, address(0), emptyPrereqs);
    emit CourseCreated(courseCode);
    return true;
  }

  function modifyCourse(string memory courseCode, uint quota, uint biddingDeadline, address lecturerAddress, string[] memory prerequisite) external returns(bool) {
    require(hasRole(UNI_ADMIN_ROLE, msg.sender), "Not UniAdmin");
    courses[courseCode].quota = quota;
    courses[courseCode].biddingDeadline = biddingDeadline;
    courses[courseCode].lecturerAddress = lecturerAddress;
    courses[courseCode].prerequisites = prerequisite;
    emit CourseModified(courseCode);
    return true;
  }

  /**
   * Adds a course to a student's list of courses completed
   * I'VE HIT CONTRACT SIZE LIMTIS :(
   * function addCourseCompletedToStudent(address studentAddress, string memory courseCode) external {
   *   require(hasRole(UNI_ADMIN_ROLE, msg.sender), "Not UniAdmin");
   *   students[studentAddress].coursesCompleted.push(courseCode);
   * }
   */


  /**
   ****************************************************
   * Student methods
   ****************************************************
  */

  /**
   * Only Student can pay fees. Students must have been admitted beforehand.
   */
  function payFees() external payable {
    require(hasRole(STUDENT_ROLE, msg.sender), "Not Student");
    uint256 feesToPayInWei = msg.value;
    balance += feesToPayInWei;
    // Transfer funds to this contract
    // Transfer(msg.sender, address(this), feesToPayInWei);
    // Student gets tokens
    uint256 admissionTokens = (feesToPayInWei / feesPerUoc) * admissionTokensPerUoc;
    students[msg.sender].admissionTokens += admissionTokens;
    // Student has paid fees
    emit StudentPaidFees(msg.sender, feesToPayInWei);
  }


  /**
   * Allows a student to transfer admission tokens to another student
   * Contract takes a 10% cut in wei
   */
  function studentToStudentTransfer(address receiverStudentAddress, uint256 tokenAmount) external {
    require(hasRole(STUDENT_ROLE, msg.sender), "Not Student");
    require(students[msg.sender].studentAddress == msg.sender, "Sender student address not found");
    require(students[receiverStudentAddress].studentAddress == receiverStudentAddress, "Receiver student address not found");

    // this truncates to nearest int, fixed points are experimental :(
    // https://docs.soliditylang.org/en/v0.8.3/types.html#fixed-point-numbers

    // contract takes a cut (in admission tokens)
    uint256 cut = uint256((tokenAmount * 10 / 100));
    uint256 transferAndFee = tokenAmount + cut;
    require(students[msg.sender].admissionTokens >= (transferAndFee));
    students[msg.sender].admissionTokens -= transferAndFee;
    uint256 transferToReceiverAmount = tokenAmount;
    students[receiverStudentAddress].admissionTokens += transferToReceiverAmount;
    emit StudentToStudentTransfer(msg.sender, receiverStudentAddress, tokenAmount);
    // Convert the 10% cut of admission tokens to wei
    uint256 cutInWei = uint256(cut * feesPerUoc / admissionTokensPerUoc);

    // Using transfer goes beyond the limits :(
    // Transfer(msg.sender, address(this), cutInWei);
    // send the cut to the contract's balance
    balance += cutInWei;
  }



  /**
    * Allows a student to bid tokens to enroll
    */
  function bidAdmissionTokens(string memory courseCode) external payable {
    require(hasRole(STUDENT_ROLE, msg.sender), "Not Student");
    require(_courseExists(courseCode), "Not exist");
    require(students[msg.sender].admissionTokens >= msg.value, "Not enough tokens");


    /** 
    // Student can only bid if it meets course preqs or lecturer approves 
    // if this course has prerequisites
    // Commented out because contract size is too big!
    // Pseudocode:
    if (courses[courseCode].prerequisites.length > 0) {
      bool metPrerequisites = Utils.meetsPrerequisites(courses[courseCode].prerequisites, students[msg.sender].coursesCompleted);
      bool lecturerApproved = Utils.checkLecturerSignature(lecturerAddress.publicKey, signature);
      if(!metPrerequisites ){
        revert("Prerequisites not met");
      } else if (!lecturerApproved) {
        revert("Not approved by lecturer");
      }
    }
    // If no issues, allow Student to bid as normal
    **/

    students[msg.sender].admissionTokens -= msg.value;
    uint256 bidTime = block.timestamp;
    bids[courseCode].push(Bid(msg.sender, courseCode, msg.value, bidTime));
    emit BidCreated(msg.sender, courseCode, msg.value, bidTime);
  }
  

  /**
   * Allows a student to modify an existing bid 
   */ 
  function modifyBid(string memory courseCode, uint256 newBid) external returns(bool) { 
    require(hasRole(STUDENT_ROLE, msg.sender), "Not Student");
    require(_courseExists(courseCode), "Not exist");

    for (uint i = 0; i < bids[courseCode].length; i++){
      if (bids[courseCode][i].studentAddress == msg.sender) {
        Bid storage b = bids[courseCode][i];
        if(b.bidAmount == newBid) {
          // Do nothing
          revert("Bid is the same, not modified");
        } else if(newBid > b.bidAmount){
          // A higher bid is placed
          // check if sender has enough to cover
          uint256 extraTokens = newBid - b.bidAmount;
          require(students[msg.sender].admissionTokens >= extraTokens);
          require(block.timestamp < courses[courseCode].biddingDeadline, "Past deadline");
          // Deduct from student tokens
          students[msg.sender].admissionTokens -= extraTokens;
          // Save changes to the bids mapping
          uint256 bidTime = block.timestamp;
          bids[courseCode][i].bidAmount = newBid;
          bids[courseCode][i].bidTime = bidTime;
          // Emit the event modified
          emit BidModified(msg.sender, courseCode, newBid, bidTime);
          return true;
        } else if(newBid < b.bidAmount ){
          uint256 extraTokens = b.bidAmount - newBid;
          require(block.timestamp < courses[courseCode].biddingDeadline, "Past deadline");
          // A lower bid has been placed
          // Refund tokens to student
          students[msg.sender].admissionTokens += extraTokens;
          // Save changes to the bids mapping
          uint256 bidTime = block.timestamp;
          bids[courseCode][i].bidAmount = newBid;
          bids[courseCode][i].bidTime = bidTime;
          // Emit the event modified
          emit BidModified(msg.sender, courseCode, newBid, bidTime);
          return true;
        }

      }
    }

    revert("NotFound");
  }

  /**
   * Closes the enrollment for a given course
   */
  function closeEnrollment(string memory courseCode) external {
    require(hasRole(UNI_ADMIN_ROLE, msg.sender), "Not UniAdmin");
    require(_courseExists(courseCode), "Not exist");
    require(bids[courseCode].length > 0 , "NoBids");

    uint quota = courses[courseCode].quota;
    uint numStudentsEnrolled = 0;
    uint bidsCovered = 0;

    while(numStudentsEnrolled < quota && bidsCovered < bids[courseCode].length) {

      // Find the highest bidder
      // Iterate through the bidding list
      // This is a simple and naive approach
      // The search can still be optimised
      address topBidder = bids[courseCode][0].studentAddress;
      uint256 topBidderAmount = bids[courseCode][0].bidAmount;
      uint256 topBidderBidTime = bids[courseCode][0].bidTime;
      uint topBidderIndex = 0;

      // Iterate the list
      for (uint i = 0; i < bids[courseCode].length; i++){
        uint256 bidAmount = bids[courseCode][i].bidAmount;
        uint bidTime = bids[courseCode][i].bidAmount;

        if(bidAmount < topBidderAmount){
          // If lower bid, do not change topBidder
          topBidder = topBidder;
        } else if(bidAmount == topBidderAmount && bidTime < topBidderBidTime) {
          // If same amount of bid, take the earliest
          topBidder = bids[courseCode][i].studentAddress;
          topBidderAmount = bids[courseCode][i].bidAmount;
          topBidderBidTime = bids[courseCode][i].bidTime;
          topBidderIndex = i;
        } else if(bidAmount > topBidderAmount) {
          // If current bid amount is higher, change top bidder
          topBidder = bids[courseCode][i].studentAddress;
          topBidderAmount = bids[courseCode][i].bidAmount;
          topBidderBidTime = bids[courseCode][i].bidTime;
          topBidderIndex = i;
        }
      }

      // Enroll student to the course 
      courses[courseCode].studentsEnrolled.push(topBidder);
      // Remove the bid
      delete bids[courseCode][topBidderIndex];
      numStudentsEnrolled++;
      bidsCovered++;
      emit StudentEnrolled(topBidder, courseCode, msg.sender);
      emit CourseEnrollmentClosed(courseCode, msg.sender);
    }

    if(bids[courseCode].length > 0){
      for (uint i = 0; i < bids[courseCode].length; i++){
        students[bids[courseCode][i].studentAddress].admissionTokens+=bids[courseCode][i].bidAmount;
        delete bids[courseCode][i];
      }
    }
  }
}
