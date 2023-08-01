import 'package:flutter/material.dart';

showLoading(context){
  return showDialog(context: context, builder: (context){
    return  AlertDialog(
      title: const Text("please Wait"),
      content: Container(
        height: 50,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  });
}