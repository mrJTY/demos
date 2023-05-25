import 'package:flutter/material.dart';
import 'package:election/ui/homepage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    // For this question to update, this needs to be a stateful widget
    // var voteCounts = Row(children: [
    //   Text("Votes counts for A"),
    //   Text("Votes counts for B"),
    // ]);

    // var voteButtons = Row(children: [
    //   ElevatedButton(child: Text("Vote for A"), onPressed: null),
    //   ElevatedButton(child: Text("Vote for B"), onPressed: null),
    // ]);

    // var body = Column(children: [
    //   voteCounts,
    //   voteButtons,
    // ]);

    // // Scaffold changes the boring red text into a nice looking app scaffold
    // var scaffold = Scaffold(
    //     appBar: AppBar(title: Text("My first simple app")), body: body);

    return MaterialApp(home: HomePage());
  }

}
