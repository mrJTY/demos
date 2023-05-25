import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Client httpClient;

  late Web3Client ethClient;

  String myAddress = "";
  String blockchainUrl = "http://localhost:7546";
  String contractAddress = "";
  String walletKey = "";

  var totalVotesA;
  var totalVotesB;

  @override
  void initState() {
    httpClient = Client();
    ethClient = Web3Client(blockchainUrl, httpClient);
    getTotalVotes();
    super.initState();
  }

  void updateContractAddress(String address) {
    setState(() => {contractAddress = address});
  }

  void updateMyAddress(String address) {
    setState(() => {myAddress = address});
  }

  void updateWalletKey(String key) {
    setState(() => {walletKey = key});
  }

  void updateBlockchainUrl(String url) {
    setState(() => {blockchainUrl = url});
  }

  Future<DeployedContract> getContract() async {
    // Assumes you have done a truffle compile
    String abiFile = await rootBundle.loadString("build/contracts/Voting.json");


    // TODO: Parse out only the 'abi' section
    // ContractAbi.fromJson expects only an iterable list
    // var data = json.decode(abiFile);

    // print("Reading from contract address ${contractAddress}");
    final contractAbi = ContractAbi.fromJson(abiFile, "Voting");
    final ethContractAddress = EthereumAddress.fromHex(contractAddress);
    final contract = DeployedContract(contractAbi, ethContractAddress);

    return contract;
  }

  Future<List<dynamic>> callFunction(String name, String candidate) async {
    final contract = await getContract();
    final function = contract.function(name);
    final result = await ethClient
        .call(contract: contract, function: function, params: [candidate]);
    return result;
  }

  Future<void> getTotalVotes() async {
    List<dynamic> resultsA = await callFunction("getTotalVotes", "tabs");
    List<dynamic> resultsB = await callFunction("getTotalVotes", "spaces");
    totalVotesA = resultsA[0];
    totalVotesB = resultsB[0];

    setState(() {});
  }

  snackBar({String? label}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label!),
            CircularProgressIndicator(
              color: Colors.white,
            )
          ],
        ),
        duration: Duration(days: 1),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> vote(bool voteTabs) async {
    // Pass in parameter
    String voteFor = "spaces";
    if (voteTabs) {
      voteFor = "tabs";
    } else {
      voteFor = "spaces";
    }
    print("Vote was for ${voteFor}");

    snackBar(label: "Recording vote");
    //obtain private key for write operation
    Credentials key = EthPrivateKey.fromHex(walletKey);

    //obtain our contract from abi in json file
    final contract = await getContract();

    // extract function from json file
    final function = contract.function("vote");

    //send transaction using the our private key, function and contract
    await ethClient.sendTransaction(
        key,
        Transaction.callContract(
            contract: contract, function: function, parameters: [voteFor]),
        chainId: 4);
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    snackBar(label: "verifying vote");
    //set a 20 seconds delay to allow the transaction to be verified before trying to retrieve the balance
    Future.delayed(const Duration(seconds: 20), () {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      snackBar(label: "retrieving votes");
      getTotalVotes();

      ScaffoldMessenger.of(context).clearSnackBars();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(30),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        CircleAvatar(
                          child: Text("Tabs"),
                          radius: 30,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Total Votes: ${totalVotesA ?? ""}",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    Column(
                      children: [
                        CircleAvatar(
                          child: Text("Spaces"),
                          radius: 30,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text("Total Votes: ${totalVotesB ?? ""}",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      vote(true);
                    },
                    child: Text('Vote Tabs'),
                    style: ElevatedButton.styleFrom(shape: StadiumBorder()),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      vote(false);
                    },
                    child: Text('Vote Spaces'),
                    style: ElevatedButton.styleFrom(shape: StadiumBorder()),
                  )
                ],
              ),
              Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Enter the contract address',
                    ),
                    onChanged: (text) {
                      updateContractAddress(text);
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Enter your address',
                    ),
                    onChanged: (text) {
                      updateMyAddress(text);
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Enter your key',
                    ),
                    onChanged: (text) {
                      updateWalletKey(text);
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: "Enter the blockchain URL",
                    ),
                    onChanged: (text) {
                      updateBlockchainUrl(text);
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
