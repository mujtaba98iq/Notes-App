import 'package:flutter/material.dart';

class ViewNote extends StatefulWidget {
  final notes;

  const ViewNote({super.key, this.notes});

  @override
  State<ViewNote> createState() => _ViewNoteState();
}

class _ViewNoteState extends State<ViewNote> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View Noted"),
        backgroundColor: Colors.grey[800],
      ),
      body: Container(
        child: Column(
          children: [
            Image.network(
              widget.notes['imageurl'],
              width: double.infinity,
              height: 300,
              fit: BoxFit.fill,
            ),
            Container(
                margin: EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  widget.notes['title'],
                  style: Theme.of(context).textTheme.headline5,
                )),
            Container(
                margin: EdgeInsets.symmetric(vertical: 15),
                child: Text(widget.notes['note'] ,style: Theme.of(context).textTheme.bodyText2,)),
          ],
        ),
      ),
    );
  }
}
