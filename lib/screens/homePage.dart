
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_course/screens/addnotes.dart';
import 'package:firebase_course/screens/editnotes.dart';
import 'package:firebase_course/screens/signIn.dart';
import 'package:firebase_course/screens/viewnotes.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void requsetPermetion() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  CollectionReference notesref = FirebaseFirestore.instance.collection("notes");

  getUser() async {
    var user = FirebaseAuth.instance.currentUser;
    // await FirebaseMessaging.onMessage.listen((event) {
    //
    print(user!.email);
  }

  initalMessage() async {
    var message = await FirebaseMessaging.instance.getInitialMessage();
    if (message != null) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const AddNotes()));
    }
  }

  getToken() async {
    var token = await FirebaseMessaging.instance.getToken();
    print("=====================Token==========");
    print(token);

    print(FirebaseAuth.instance.currentUser?.uid);
    CollectionReference ref =
    await FirebaseFirestore.instance.collection("users");
    ref.doc(FirebaseAuth.instance.currentUser?.uid).update({"tokken": token});
  }

  @override
  initState() {
    getUser();
    getToken();
    initalMessage();
    super.initState();
    requsetPermetion();
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const AddNotes()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("MyHOme"),
          backgroundColor: Colors.grey[800],
          actions: [
            InkWell(
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const SignIn(),
                  ),
                );
              },
              child: const Icon(
                Icons.exit_to_app,
                color: Colors.orange,
              ),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.orange,
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AddNotes()));
          },
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 650,
                child: FutureBuilder(
                  future: notesref
                      .where("userid",
                      isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                      .get(),
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                          itemCount: snapshot.data.docs.length,
                          itemBuilder: (context, i) {
                            return Dismissible(
                              onDismissed: (direction) async {
                                await notesref
                                    .doc(snapshot.data.docs[i].id)
                                    .delete();
                                await FirebaseStorage.instance
                                    .refFromURL(
                                    snapshot.data.docs[i]['imageurl'])
                                    .delete()
                                    .then((value) => {
                                  print(
                                      "=================================="),
                                  print(
                                      "=================================="),
                                  print("deleted"),
                                });
                              },
                              key: UniqueKey(),
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => ViewNote(
                                        notes: snapshot.data.docs[i],
                                      )));
                                },
                                child: ListNotes(
                                  notes: snapshot.data.docs[i],
                                  docid: snapshot.data.docs[i].id,
                                ),
                              ),
                            );
                          });
                    } else if (snapshot.hasError) {
                      return const Text("Errorr");
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.black,
                          ));
                    }
                    return const Text("mujtaba");
                  },
                ),
              ),
            ],
          ),
        ));
  }

  Container designButton(BuildContext context, text, page) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.blue,
      ),
      width: 150,
      height: 40,
      child: InkWell(
        onTap: () {
          Navigator.of(context)
              .pushReplacement(MaterialPageRoute(builder: (context) => page));
        },
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 30),
        ),
      ),
    );
  }
}

class ListNotes extends StatelessWidget {
  final notes;

  final imageurl;
  final docid;

  ListNotes({this.notes, this.imageurl, this.docid});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ViewNote(
              notes: notes,
            )));
      },
      child: Card(
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Image.network(
                "${notes['imageurl']}",
                fit: BoxFit.fill,
                height: 80,
              ),
            ),
            Expanded(
                flex: 3,
                child: ListTile(
                  title: Text("${notes['title']}",
                      style: const TextStyle(fontSize: 20)),
                  subtitle: Text("${notes['note']}",
                      style: const TextStyle(fontSize: 14)),
                  trailing: IconButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => EditNote(
                            docid: docid,
                            list: notes,
                          )));
                    },
                    icon: const Icon(Icons.edit),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
