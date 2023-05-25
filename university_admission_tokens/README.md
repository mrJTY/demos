# UniAdmissionToken

# Objective

The objective of the assignment is to implement a smart contract that can facilitate a hypothetical university enrollment system. Students will be able to bid for their preferred courses by purchasing and bidding university admission tokens (UAT).

# Prerequisites

The smart contract was developed with Truffle.

To setup it up:

* Install Bazel
  * This is optional but highly recommended because it can manage dependencies such as NodeJS version and NPM packages
  * [](https://docs.bazel.build/versions/master/install.html)

Alternatively without Bazel, manage these packages manually:
* Install NPM: [](https://nodejs.org/en/)
* Install the packages manaually: `npm install`
* Install Truffle globally (optional): `npm install -g truffle`

# Quickstart

If you have Bazel installed, then this shell script will install the dependencies and run the test:

```sh
$ ./bin/test.sh
Starting local Bazel server and connecting to it...
Loading: 0 packages loaded
    currently loading:
    Fetching @npm; Running npm install on //:package.json 10s
```

Alternatively by just using `npm` and `truffle`:

```sh
# Setup npm dependencies
./bin/setup-npm.sh

# (optional): install truffle globally
npm install -g truffle
truffle test
```

# Implementation details

## ERC20
This contract uses OpenZeppelin's implementation of the ERC20 interface: https://docs.openzeppelin.com/contracts/2.x/erc20

The token is called a UniversityAdmissionToken (UAT). The token constructor mints 0 tokens at the beginning.

## Roles
The contract uses OpenZeppelin to assign roles to addresses: https://docs.openzeppelin.com/contracts/2.x/access-control

The roles defines an address' limitations as follows:

* ChiefOperatingOfficer
  * The admin of the contract.
  * Only the COO can withdraw funds.
  * Only the COO can set fees.
* UniAdmin
  * Only the UniAdmins can create courses and admit students
  * Only UniAdmins can close enrollments
* Student
  * can buy tokens to be able to bid for their preferred courses.
  * can exchange tokens to another student while the contract takes a cut.

## Testing
The `tests` directory uses the Mocha testing framework which asserts these descriptions. These test outputs should be self-descriptive on the areas being tested:

```
$ ./bin/test.sh


  Contract: UniAdmissionToken
    One bidding student
      ✓ should be able to bid tokens (83ms)
      ✓ should not be able to modify a bid if it is the same (531ms)
      ✓ should be able to modify a bid with a higher value (68ms)
      ✓ should be able to modify a bid with a lower value (76ms)
      ✓ should not be able to modify a non-existent bid (47ms)
      ✓ should log transaction costs (318ms)

  Contract: UniAdmissionToken
    Enrollments:
      ✓ uniAdmin should be able to close enrollments for COMP01 (81ms)
      ✓ uniAdmin should be able to close enrollments for COMP02 (99ms)
      ✓ student01 should not be able to enroll in COMP01 due to quota limitations
      ✓ student02 should be able to enroll in COMP01
      ✓ both student01 and student02 should be able to enroll in COMP02

  Contract: UniAdmissionToken
    The COO role
      ✓ should be able to setFeesPerUoc (59ms)
    A UniAdmin role
      ✓ should be able to admit a student (67ms)
      ✓ should be able to create a course (43ms)
      ✓ should be able to modify a course (75ms)
    A Student role
      ✓ should be able to pay for 3 uoc and get 300 admission tokens (52ms)
      ✓ should not be able to admit another student
      ✓ should throw an error if student is not found

  Contract: UniAdmissionToken
    Test scenario 1
      ✓ should have a contract balance of 90,000
      ✓ should have given each student 1800 tokens (61ms)
      ✓ should be enroll students 1 and 3 (310ms)
      ✓ should have the correct student balances after enrollment (59ms)

  Contract: UniAdmissionToken
    Test scenario 2
      ✓ should reject student01's bid
      ✓ should enroll students 2,3 and 4 (360ms)
      ✓ should have the correct student balances after enrollment (78ms)

  Contract: UniAdmissionToken
    Test scenario 3
      ✓ should place bids (269ms)
      ✓ should have a contract balance of 90,000
      ✓ should take a 10% cut from a student transfer (56ms)
      ✓ should be able to modify bid (45ms)
      ✓ should be able close enrollments (177ms)
      ✓ should be able to get the correct balances at the end (47ms)

  Contract: UniAdmissionToken
    The COO transferring tokens
      ✓ should be able to transfer to an outsider (80ms)
    An Outsider transferring tokens
      ✓ should not be able to pay fees if not admitted
    A Student transferring tokens
      ✓ should be able to transfer funds to another student (150ms)


  34 passing (9s)

```

## Data Model

### Students
The `students` state variable is a mapping of student address to a `Student struct`. The struct contains detail of a student:

```c
struct Student {
  address studentAddress;
  uint256 admissionTokens;
}
mapping(address => Student) public students;
```

### Course

The `courses` mapping contains the available courses.
```c
struct Course {
  string courseCode;
  uint quota;
  uint biddingDeadline;
  address[] studentsEnrolled;
}
mapping(string => Course) public courses;
```

### Bidding rounds

`bids` contains a list of `Bids`. The mapping is from a `courseCode` -> `List of Bids`. It contains a list of Bids made by students with their admission tokens.

```c
  struct Bid {
    address studentAddress;
    string courseCode;
    uint256 bidAmount;
    uint256 bidTime;
  }
  mapping(string => Bid[]) bids;
```

### Closing enrollments
Enrollments are closed by a `UniAdmin` who calls `.closeEnrollment(courseCode)`.

The enrollment would prefer:
* highest bidder
* if there are equal amount of bids, then take the earliest. It assumes that ordering in the list as a proxy for time.

Repeat this step until quota has been filled or the bids

```js
uint numStudentsEnrolled = 0;
uint bidsCovered = 0;
while(numStudentsEnrolled < quota && bidsCovered < bids[courseCode].length) {
  topBidder = findMaxBidder(bids);
  // Enroll student to the course
  courses[courseCode].studentsEnrolled.push(topBidder);
  // Remove the bid
  delete bids[courseCode][topBidderIndex];
  numStudentsEnrolled++;
  emit StudentEnrolled(topBidder, courseCode, msg.sender);
  emit CourseEnrollmentClosed(courseCode, msg.sender);
}
```

If there are still open bids remaining, refund any students who did not make it in the quota.

This is intentionally a simple and naive search approach as a proof-of-concept. There is still room for improvement to optimise the search.

# Cost analysis
A test file under `test/cost_analysis` runs through the bare minimum set of actions needed by a student to be enrolled in a course.

The actions are:
* The COO creates the contract
* The COO grants the UniAdmin role to an address
* A UniAdmin admits a student into the uni
* A UniAdmin creates a course
* A Student pays for fees and received UniAdmissionTokens (UAT)
* A Student bids tokens for a course
* A UniAdmin closes the enrollment by running the bidding system

The total amount of gas used is:
```
Cost of granting uni admin role: 47377
Cost of admitting a student to uni: 73033
Cost of creating a course: 132910
Cost of paying fees: 70163 (excluding the actual UOC fees paid to the contract's address)
Cost of bidding: 124775
Cost of enrollment: 53397
Total gas used: 501655
```

At the time of writing, this amounts to 1.2431 USD.

Gas prices were calculated using: [](https://www.cryps.info/en/Gwei_to_USD/)

# Stretch goal

The stretch goal is to add a new role for a lecturer.

The first step is to add the lecturer's address as part of the course. The course will also contain prerequisites.

```c
struct Course {
  string courseCode;
  uint quota;
  uint biddingDeadline;
  address[] studentsEnrolled;
  address lecturerAddress;
  string[] prerequisites;
}
mapping(string => Course) private courses;
```

Students will also now have a record of their completed courses

```c
struct Student {
  address studentAddress;
  uint256 admissionTokens;
  string[] coursesCompleted;
}
mapping(address => Student) private students;
```

Only UniAdmins can push items to the coursesCompleted list in the Student struct.

```js
function addCourseCompletedToStudent(address studentAddress, string memory courseCode) external {
  require(hasRole(UNI_ADMIN_ROLE, msg.sender), "Not UniAdmin");
  students[studentAddress].coursesCompleted.push(courseCode);
}
```

Additional restriction is added to the student so that they can only bid if:
* they meet the prerequisites or
* have an approval from the lecturer.

I've ran into contract size limitations at this point. In hindsight, it could have been created as multiple contracts. Access control may have been more complex as I can't reuse the OpenZepellin library which made roles easy to implement.

In pseudocode, this check can be added to the `bidAdmissionTokens`:

```js
if (courses[courseCode].prerequisites.length > 0) {
  bool metPrerequisites = Utils.meetsPrerequisites(courses[courseCode].prerequisites, students[msg.sender].coursesCompleted);
  // Assuming we have lecturer's public key and the lecturer
  // signed the student's address with the lecturer's private key
  bool lecturerApproved = Utils.checkLecturerSignature(lecturerAddress.publicKey, signature);
  if(!metPrerequisites ){
    revert("Prerequisites not met");
  } else if (!lecturerApproved) {
    revert("Not approved by lecturer");
  }
}
// If no issues, allow Student to bid as normal
```

# Suitability of the Ethereum platform

Contract size limitations were reached as the complexity of the contract grew. This was solved by trimming down the contract. This can however limit the application's functionality and code readability.

Fair ordering of the bids may be an issue as it depends on when the block has been received by miners. If enough miners are malicious, they can collude with students who want preference over others. If there is enough incentive for a group of miners to do so, they may even deny the ability for certain students to be enrolled. On a bigger scale of things, this may not be that profitable to do so.

Although it is unit-tested, TheDAO attack has shown that bugs may come up in an Ethereum smart contract. Because smart contracts are immutable, any bug would require a contract redeployment. Extending the contract for future use cases will also require redeployment.

The transaction costs may not be feasible for real world use. Asking students to take on this additional cost on top of university fees may not get a positive uptake. The price volatility of Ethereum can make paying uni fees unpredictable.

In terms of efficiency, Ethereum can only support up to 15 TPS. Ethereum 2.0 claims to be able to do 100,000 TPS, but this is still work in progress. A centralised database running on a modern cloud infrastructure were already proven as efficient and reliable systems. For example, an AWS RDS instance on an r3.8x large claims to be able to do 500,000 selects/sec and 100,000 updates/sec [](https://aws.amazon.com/rds/aurora/faqs).

Given all these drawbacks, a distributed application on the Ethereum network may not be the most suitable platform to develop an enrollment system.

# Design alternatives

Considering the problem at hand, a university admission system may be better off developed in a traditional non-distributed way. Current limitations of developing a distributed application are still in early days but it may have a promising future. This depends of course on the problem and if it fits the use case.

If a distributed application route is further explored, the following describes some alternative solutions.

This assignment was done as a single contract for simplicity. The `AccessControl` library from OpenZeppelin assigns roles well within a single contract. In hindsight, it could have been re-architected as smaller contracts. However, this comes at a higher complexity, especially with managing permissions.

My survey paper for assignment 3 will cover Hedera Hashgraph and it may provide a suitable alternative for a distributed application. A key differentiator is that they offer managed services which solves commonly encountered problems when developing a distributed application.

The [Hedera Consensus Service](https://hedera.com/consensus-service) (HCS) provides fair ordering which is a good use case for a bidding system. Getting consensus on the ordering is important for students to get their class enrollments fairly.

Contracts written in Solidity can be deployed to their [Smart Contract Service](https://docs.hedera.com/guides/docs/sdks/smart-contracts). Contracts are still limited with the same TPS as the Ethereum network.

The [Hedera Token Service](https://hedera.com/token-service) is a simpler alternative to managing tokens. They claim tokens in this service are more efficient
that can go up to 100,000 TPS. Using a managed service for tokens may also help reduce the contract size issue.

Finally, Hedera offers very low transaction costs because of its technical innovation. It's technical innovation claims to support upt o 100,000 TPS and that [transaction fees are to a fiat currency](https://hedera.com/fees) which will make fees more predictable. This can reduce a developer's risk exposure to a coin's price volatility.

It is not in scope for this assignment, but it may be worth doing some more exploration for my own curiosity.

# Resources
* https://docs.soliditylang.org/en/develop/solidity-by-example.html
* Hands-On Smart Contract Development: https://www.oreilly.com/library/view/hands-on-smart-contract/9781492045250/
* https://blog.crowdbotics.com/solidity-crud-tutorial-part-1-building-a-smart-contract-with-crud-operations/
* https://blog.crowdbotics.com/solidity-crud-tutorial-part-2-testing-your-smart-contract-with-truffle/
* https://github.com/OpenZeppelin/openzeppelin-contracts/blob/67bca857eedf99bf44a4b6a0fc5b5ed553135316/contracts/access/Roles.sol
* https://medium.com/swlh/understanding-ownership-and-role-based-access-with-solidity-and-open-zeppelin-dbd096e4bd99
* https://docs.openzeppelin.com/contracts/4.x/access-control
* https://medium.com/coinmonks/ethereum-solidity-memory-vs-storage-which-to-use-in-local-functions-72b593c3703a
* https://www.cryptocompare.com/coins/guides/what-is-the-gas-in-ethereum/
