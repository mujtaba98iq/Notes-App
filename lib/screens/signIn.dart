
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_course/component/alert.dart';
import 'package:firebase_course/screens/homePage.dart';
import 'package:firebase_course/screens/signUp.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rive/rive.dart';



class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController textControllerEmail = TextEditingController();
  TextEditingController textControllerPassword = TextEditingController();

  StateMachineController? controller;
  SMIInput<bool>? isChecking;
  SMIInput<bool>? isHandsUp;
  SMIInput<bool>? trigSuccess;
  SMIInput<bool>? trigFail;

  FocusNode emailFocusNode = FocusNode();
  final myKey = GlobalKey<FormState>();

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  void initState() {
    emailFocusNode.addListener(emailFoucs);
    super.initState();
  }

  @override
  void dispose() {
    emailFocusNode.removeListener(emailFoucs);
    super.dispose();
  }

  void emailFoucs() {
    isChecking?.change(emailFocusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    UserCredential credential;
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFD6E2EA),
      body: Form(
        key: myKey,
        child: ListView(
          children: [
            const SizedBox(
              height: 70,
            ),
            const Center(
              child: Text(
                "Rejester Acount",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 27, color: Colors.grey),
              ),
            ),
            SizedBox(
              width: size.width,
              height: 250,
              child: RiveAnimation.asset(
                "images/a.riv",
                fit: BoxFit.fitHeight,
                stateMachines: const ["Login Machine"],
                onInit: (artboard) {
                  controller = StateMachineController.fromArtboard(
                      artboard, "Login Machine");
                  if (controller == null) return;
                  artboard.addController(controller!);
                  isChecking = controller?.findInput("isChecking");
                  isHandsUp = controller?.findInput("isHandsUp");
                  trigFail = controller?.findInput("trigFail");
                  trigSuccess = controller?.findInput("trigSuccess");
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  Container(
                    child: TextFormField(
                      onChanged: (value) {
                        if (isHandsUp != null) {
                          isHandsUp!.change(false);
                        }
                        if (isChecking == null) return;
                        isChecking!.change(true);
                      },
                      focusNode: emailFocusNode,
                      validator: (val) {
                        if (val!.isEmpty ||
                            !RegExp(r'[\w-\.]+@([\w-]+\.)+[\w]{2,4}')
                                .hasMatch(val)) {
                          return "Enter Correct email!";
                        } else {
                          return null;
                        }
                      },
                      controller: textControllerEmail,
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email),
                          hintStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                          hintText: "Email",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(50))),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextFormField(
                    onChanged: (value) {
                      if (isChecking != null) {
                        isChecking!.change(false);
                      }
                      if (isHandsUp == null) return;
                      isHandsUp!.change(true);
                    },
                    validator: (val) {
                      if (val!.isEmpty || !RegExp(r'^[0-9]+$').hasMatch(val)) {
                        return "Enter Correct password!";
                      } else {
                        return null;
                      }
                    },
                    obscureText: true,
                    controller: textControllerPassword,
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock),
                        hintStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                        hintText: "Password",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(50))),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 60,
                    width: 350,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(100, 9, 33, 59),
                      borderRadius: BorderRadius.circular(
                        20,
                      ),
                    ),
                    child: Center(
                      child: InkWell(
                        onTap: () async {
                          if (myKey.currentState!.validate()) {
                            try {
                              showLoading(context);
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) =>  MyHomePage(
                                    title: 'title',
                                  ),
                                ),
                              );
                              credential = await FirebaseAuth.instance
                                  .signInWithEmailAndPassword(
                                      email: textControllerEmail.text,
                                      password: textControllerPassword.text);
                              var token= await FirebaseMessaging.instance.getToken();
                              print("==============================="'''''''''''');
                              print(token);
                              var s=await FirebaseFirestore.instance.collection("users").doc();
                              s.update({
                                "token":token
                              });
                            } on FirebaseAuthException catch (e) {
                              if (e.code == 'user-not-found') {
                                Navigator.of(context).pop();
                                showLoading(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  snackBarNotFound(),
                                );
                              } else if (e.code == 'wrong-password') {
                                Navigator.of(context).pop();
                                showLoading(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  snackBarWrongPassword(),
                                );
                              }
                            }
                          }
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(fontSize: 30),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Center(
                    child: InkWell(
                      child: Image.network(
                        "https://cdn.freebiesupply.com/logos/large/2x/google-icon-logo-png-transparent.png",
                        width: 50,
                      ),
                      onTap: () async {
                        UserCredential crid = await signInWithGoogle();
                        print(crid);
                      },
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const SignUp()));
                },
                child: const Text(
                  "Creat Acount",
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  SnackBar snackBarWrongPassword() {
    return SnackBar(
      content: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            height: 90,
            decoration: const BoxDecoration(
                color: Color(0xFFC72C41),
                borderRadius: BorderRadius.all(Radius.circular(20))),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "oh Snap!",
                        style: TextStyle(color: Colors.white, fontSize: 25),
                      ),
                      Text(
                        'Wrong password provided for that user.',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  SnackBar snackBarNotFound() {
    return SnackBar(
      content: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            height: 90,
            decoration: const BoxDecoration(
                color: Color(0xFFC72C41),
                borderRadius: BorderRadius.all(Radius.circular(20))),
            child: Row(
              children: [
                const SizedBox(
                  width: 48,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "oh Snap!",
                        style: TextStyle(color: Colors.white, fontSize: 25),
                      ),
                      Text(
                        "No user found for that email",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }
}
