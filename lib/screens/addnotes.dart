import 'dart:io';
import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_course/component/alert.dart';
import 'package:firebase_course/screens/homePage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

class AddNotes extends StatefulWidget {
  const AddNotes({super.key});

  @override
  State<AddNotes> createState() => _AddNotesState();
}

class _AddNotesState extends State<AddNotes> {
  @override
  Widget build(BuildContext context) {
    File? _pickedImage;
    bool ontapAddNote = false;
    final ImagePicker _picker = ImagePicker();

    Future _pickImage() async {
      final pickedImageFile =
          await _picker.pickImage(source: ImageSource.camera);

      // if (pickedImageFile != null) {
      setState(() {
        _pickedImage = File(pickedImageFile!.path);
      });
    }

    var imagepecker = ImagePicker();
    // bool ontapAddNote = false;
    File? file;
    var refstorge;
    Reference ref = FirebaseStorage.instance.ref("images");
    CollectionReference noteref =
        FirebaseFirestore.instance.collection("notes");
    TextEditingController textControllerTitle = TextEditingController();
    TextEditingController textControllerNote = TextEditingController();

    Future uploadImgaes(source) async {
      var random = Random().nextInt(10000000);

      final imgpicker = await imagepecker.pickImage(source: source);
      if (imgpicker != null) {
        var nameimage = imgpicker.name;
        var randomName = "$random$nameimage";
        file = File(imgpicker.path);
        print("========================================");
        print("$random$nameimage");

        //start upload image
        refstorge = FirebaseStorage.instance.ref("images/$randomName");
        //end upload image

      } else {
        AwesomeDialog(
                context: context,
                dialogType: DialogType.WARNING,
                animType: AnimType.bottomSlide,
                title: "Error",
                desc: "Pleas Chose image")
            .show();
      }
      final imtTemp = File(imgpicker!.path);
      setState(() {
        file = imtTemp;
      });
    }

    GlobalKey<FormState> formstate = GlobalKey<FormState>();
    var title, note, imageurl;

    addNote() async {
      if (file == null) {
        return AwesomeDialog(
                context: context,
                dialogType: DialogType.warning,
                animType: AnimType.bottomSlide,
                title: "Important",
                desc: "Pleas Choose image")
            .show();
      } else {
        showLoading(context);
        var formdata = formstate.currentState;
        if (formdata!.validate()) {
          formdata.save();
          await ref.putFile(file!);
          imageurl = await ref.getDownloadURL();
          await noteref
              .add({
                "title": title,
                "note": note,
                "imageurl": imageurl,
                "userid": FirebaseAuth.instance.currentUser!.uid
              })
              .then((value) => {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => MyHomePage(title: "title")))
                  })
              .catchError((e) {
                print("$e");
              });
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add Note",
          style: TextStyle(fontSize: 30),
        ),
        backgroundColor: Colors.grey[800],
      ),
      body: Container(
        child: Column(
          children: [
            Form(
              key: formstate,
              child: Column(
                children: [
                  InkWell(
                      child: Icon(Icons.image),
                      onTap: () async {
                        final pickedImageFile =
                            await _picker.pickImage(source: ImageSource.camera);

                        // if (pickedImageFile != null) {
                        setState(() {
                          _pickedImage = File(pickedImageFile!.path);
                        });
                      }),
                  const SizedBox(
                    height: 20,
                  ),
                  _pickedImage != null
                      ? Image.file(_pickedImage!)
                      : Text("Pick imagee"),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    validator: (val) {
                      if (val!.length > 30) {
                        return "Title Can't to be larger than 30 letter!";
                      } else if (val.length < 2) {
                        return "Title Can't to be less than 2 letter!";
                      }
                    },
                    onSaved: (val) {
                      title = val;
                    },
                    maxLength: 30,
                    controller: textControllerTitle,
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.folder_copy_outlined),
                        labelStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                        labelText: "Title Note",
                        errorMaxLines: 30,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(50))),
                  ),
                  TextFormField(
                    validator: (val) {
                      if (val!.length > 255) {
                        return "Note Can't to be larger than 255 letter!";
                      } else if (val.length < 10) {
                        return "Note Can't to be less than 10 letter!";
                      }
                    },
                    onSaved: (val) {
                      note = val;
                    },
                    minLines: 1,
                    maxLines: 3,
                    maxLength: 200,
                    controller: textControllerNote,
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.folder_copy_outlined),
                        labelStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                        labelText: "Note",
                        errorMaxLines: 200,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(50))),
                  ),
                ],
              ),
            ),
            InkWell(
              child: Container(
                  color: Colors.orange,
                  height: 40,
                  width: 200,
                  child: const Center(
                      child: Text(
                    "Add Image For Note",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ))),
              onTap: () {
                showModalBottomSheet(
                  backgroundColor: Colors.grey[800],
                  context: context,
                  builder: (BuildContext context) {
                    return SizedBox(
                      height: 150,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text(
                            "Please Choose Image",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 30,
                                fontWeight: FontWeight.bold),
                          ),
                          InkWell(
                            onTap: () async {
                              var picked = await ImagePicker()
                                  .pickImage(source: ImageSource.gallery);
                              if (picked != null) {
                                file = File(picked.path);
                                var rand = Random().nextInt(100000);
                                var imagename = "$rand" + picked.name;
                                ref = FirebaseStorage.instance
                                    .ref("images")
                                    .child("$imagename");
                              } else {
                                AwesomeDialog(
                                        context: context,
                                        dialogType: DialogType.WARNING,
                                        animType: AnimType.bottomSlide,
                                        title: "Error",
                                        desc: "Pleas Chose image")
                                    .show();
                              }
                              Navigator.of(context).pop();
                            },
                            child: Container(
                                height: 50,
                                width: double.infinity,
                                color: Colors.orange,
                                child: Center(
                                  child: Row(
                                    children: const [
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Icon(Icons.image),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        "From Gallery",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 30),
                                      ),
                                    ],
                                  ),
                                )),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          InkWell(
                            onTap: () async {
                              var picked = await ImagePicker()
                                  .pickImage(source: ImageSource.camera);
                              if (picked != null) {
                                file = File(picked.path);
                                var rand = Random().nextInt(100000);
                                var imagename = "$rand" + picked.name;
                                ref.child("$imagename");
                              } else {
                                AwesomeDialog(
                                        context: context,
                                        dialogType: DialogType.WARNING,
                                        animType: AnimType.bottomSlide,
                                        title: "Error",
                                        desc: "Pleas Chose image")
                                    .show();
                              }
                              Navigator.of(context).pop();
                            },
                            child: Container(
                                width: double.infinity,
                                height: 50,
                                color: Colors.orange,
                                child: Center(
                                  child: Row(
                                    children: const [
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Icon(Icons.camera),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Text("From Camera",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 30)),
                                    ],
                                  ),
                                )),
                          )
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(
              height: 20,
            ),
            InkWell(
              child: Container(
                  color: Colors.orange,
                  height: 60,
                  width: 300,
                  child: const Center(
                      child: Text(
                    "Add Note",
                    style: TextStyle(color: Colors.white, fontSize: 30),
                  ))),
              onTap: () {
                addNote();
              },
            )
          ],
        ),
      ),
    );
  }
}
