import 'package:flutter/material.dart';

class Track extends StatelessWidget {
  final String name;
  final String duration;
  final String artist; //? add id ?

  const Track(
      {Key? key,
      required this.name,
      required this.duration,
      required this.artist})
      : super(key: key);
  @override
  Widget build(context) {
    return const Text("hello");
  }
}
