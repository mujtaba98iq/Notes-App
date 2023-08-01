
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_course/component/alert.dart';
import 'package:firebase_course/screens/homePage.dart';
import 'package:firebase_course/screens/signIn.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rive/rive.dart';


class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  var myusername,mypassword,myemail;
  FocusNode emailFocusNode = FocusNode();
  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController textControllerEmail = TextEditingController();
  TextEditingController textControllerPassword = TextEditingController();
  late String email;
  late String password;
  final myKey = GlobalKey<FormState>();
  StateMachineController? controller;
  SMIInput<bool>? isChecking;
  SMIInput<bool>? isHandsUp;
  SMIInput<bool>? trigSuccess;
  SMIInput<bool>? trigFail;


  _SignUpState();
  sent()async{
    bool isVerfied = false;
    UserCredential credential;
     if (myKey.currentState!.validate()) {
      try {
        showLoading(context);
        credential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: textControllerEmail.text,
          password: textControllerPassword.text,
        );
        var token= await FirebaseMessaging.instance.getToken();
        print("==============================="'''''''''''');
        print(token);
        await FirebaseFirestore.instance.collection("users").add({
          "username":usernameController.text,
          "email": textControllerEmail.text,
          "token": token,
        });
        print(credential);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MyHomePage(
              title: 'title',
            ),
          ),
        );
      }
      on FirebaseAuthException catch (e) {

        if (e.code == 'weak-password') {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            snackBar('weak-password'),
          );
        } else if (e.code == 'email-already-in-use') {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            snackBar("email is already in use"),
          );
        }
      }
      isVerfied =
          FirebaseAuth.instance.currentUser!.emailVerified;
      if (!isVerfied) {
        final user = FirebaseAuth.instance.currentUser!;
        await user.sendEmailVerification();
      }
    } else {
      return;
    }
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
                "Creat Acount",
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
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
                      controller: usernameController,
                      validator: (val) {
                        if (val!.isEmpty || !RegExp(r'[a-z]').hasMatch(val)) {
                          return "Enter Correct Name!";
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person),
                        hintStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                        hintText: "UserName",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    child: TextFormField(
                      onChanged: (value) {
                        if (isHandsUp != null) {
                          isHandsUp!.change(false);
                        }
                        if (isChecking == null) return;
                        isChecking!.change(true);
                      },
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
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    child: TextFormField(
                      onChanged: (value) {
                        if (isChecking != null) {
                          isChecking!.change(false);
                        }
                        if (isHandsUp == null) return;
                        isHandsUp!.change(true);
                      },
                      validator: (val) {
                        if (val!.isEmpty ||
                            !RegExp(r'^[0-9]+$').hasMatch(val)) {
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
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 60,
                    width: 350,
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(100, 9, 33, 59),
                        borderRadius: BorderRadius.circular(20)),
                    child: InkWell(
                      onTap: () async {
                       sent();
                      },
                      child: const Center(
                        child: Text(
                          "Sign Up",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 27,
                          ),
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
              height: 20,
            ),
            Center(
              child: InkWell(
                onTap: () async{
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const SignIn()));
                },
                child: const Text(
                  "I Have an Acount",
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

  SnackBar snackBar(errorMassage) {
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
                    children:  [
                      const Text(
                        "oh Snap!",
                        style: TextStyle(color: Colors.white, fontSize: 25),
                      ),
                      Text(
                        errorMassage,
                        style: const TextStyle(fontSize: 20, color: Colors.white),
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

  Container textFildDesign(controler, text, obscure) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        obscureText: obscure,
        controller: controler,
        decoration: InputDecoration(
            hintStyle: const TextStyle(
                color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
            hintText: text,
            filled: true,
            fillColor: Colors.blueAccent,
            border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(50))),
      ),
    );
  }
}
