import 'package:flutter/material.dart';
import 'package:omusic/models/library.dart';
import 'package:omusic/login.dart';
import 'package:googleapis/drive/v3.dart';

class LibraryView extends StatefulWidget {
  final DriveApi drive;
  const LibraryView({Key? key, required this.drive}) : super(key: key);
  @override
  createState() => LibraryState();
}

class LibraryState extends State<LibraryView> {
  bool loading = true;
  @override
  Widget build(context) {
    print(widget.drive);

    if (loading) {
      return Text('Loading');
    } else {
      return Text('Loaded');
    }
  }
}
