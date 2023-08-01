import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:firebase_course/screens/homePage.dart';
import 'package:firebase_course/screens/signIn.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';

bool isLogin = false;

Future<void> backgroundMessage(RemoteMessage message) async {
  print("========================BackGround Massage");
  print("Title: ${message.notification?.title}");
  print("body: ${message.notification?.body}");
  print("Payload: ${message.data}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(backgroundMessage);
  var user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    isLogin = false;
  } else {
    isLogin = true;
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: "NoteSerif",
        primaryColor: Colors.orange,
        buttonColor: Colors.grey[800],
        textTheme: TextTheme(
          headline5: const TextStyle(fontSize: 30, color: Colors.orange),
          headline6: TextStyle(fontSize: 30, color: Colors.grey[800]),
          bodyText2: TextStyle(fontSize: 20, color: Colors.grey[800]),
        ),
        primarySwatch: Colors.blue,
      ),
      home: isLogin == true
          ? const MyHomePage(
              title: "title",
            )
          : const SignIn(),
    );
  }
}
