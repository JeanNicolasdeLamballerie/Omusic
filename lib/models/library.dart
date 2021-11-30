import 'package:flutter/material.dart';

class Library extends StatefulWidget {
  final String name;
  final Map artists;
  final Map playlists;
  const Library(
      {Key? key,
      required this.name,
      required this.artists,
      required this.playlists})
      : super(key: key);

  @override
  LibraryState createState() => LibraryState();
}

//! State definition

class LibraryState extends State<Library> {
  Map playlists = {};
  String name = "";
  void changeState(parameter) {
    print("changing name : " + parameter);
    setState(() {
      name = parameter;
    });
  }

//! Widget building
  @override
  Widget build(context) {
    if (playlists.isEmpty) {
      return const Text("No playlists yet !");
    }
    return const Text("hello");
  }
}
