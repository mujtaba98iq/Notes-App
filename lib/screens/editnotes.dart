import 'dart:io';
import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_course/component/alert.dart';
import 'package:firebase_course/screens/homePage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

class EditNote extends StatefulWidget {
  final docid;
  final list;
  final notes;

  const EditNote({super.key, this.docid, this.list, this.notes});

  @override
  State<EditNote> createState() => _EditNoteState();
}

class _EditNoteState extends State<EditNote> {
  @override
  Widget build(BuildContext context) {
    var imagepecker = ImagePicker();
    bool ontapAddNote = false;
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

    editNote() async {
      var formdata = formstate.currentState;
      if (file == null) {
        showLoading(context);
        if (formdata!.validate()) {
          formdata.save();
          await noteref
              .doc(widget.docid)
              .update({
                "title": title,
                "note": note,
              })
              .then((value) => {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => MyHomePage(title: "title")))
                  })
              .catchError((e) {
                print("$e");
              });
        }
      } else {
        showLoading(context);

        if (formdata!.validate()) {
          formdata.save();
          await ref.putFile(file!);
          imageurl = await ref.getDownloadURL();
          await noteref
              .doc(widget.docid)
              .update({
                "title": title,
                "note": note,
                "imageurl": imageurl,
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

    deleteNote() async {
      var formdata = formstate.currentState;
      showLoading(context);

      await noteref.doc(widget.docid).delete();
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MyHomePage(title: "title")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Note",
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
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    initialValue: widget.list['title'],
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
                    initialValue: widget.list['note'],
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
                    "Eidt Image For Note",
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
                            "Edit Image",
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
                    "Edit Note",
                    style: TextStyle(color: Colors.white, fontSize: 30),
                  ))),
              onTap: () {
                editNote();
              },
            ),
            const SizedBox(
              height: 20,
            ),
            InkWell(
              child: Container(
                  color: Colors.red,
                  height: 60,
                  width: 300,
                  child: const Center(
                      child: Text(
                    "Delete Note",
                    style: TextStyle(color: Colors.white, fontSize: 30),
                  ))),
              onTap: () {
                deleteNote();
              },
            )
          ],
        ),
      ),
    );
  }
}
