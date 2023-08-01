import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Text("This Work"),
          StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection("users").snapshots(),
              builder: (context, snapshot) {
                List<Row> clintwidets = [];
                if (snapshot.hasData) {
                  final clints = snapshot.data?.docs.reversed.toList();
                  for (var clinet in clints!) {
                    final clintwedget = Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [Text(clinet['email'])],
                    );
                    clintwidets.add(clintwedget);
                  }
                }

                return Expanded(
                    child: ListView(
                  children: clintwidets,
                ));
              })
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
    );
  }
}
