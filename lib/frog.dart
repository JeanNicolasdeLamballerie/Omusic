import 'package:flutter/material.dart';

class InheritedSongWrapper extends StatefulWidget {
  final Widget child;
  const InheritedSongWrapper({Key? key, required this.child}) : super(key: key);

  static InheritedSongWrapperState of(BuildContext context,
      {bool build = true}) {
    return build
        ? context.dependOnInheritedWidgetOfExactType<InheritedSong>()!.data
        : context
            .findAncestorWidgetOfExactType<InheritedSong>()!
            .data; // If we don't want to rebuild the current widget, we can pass StaticWrapper = InheritedSongWrapper.of(context, false); only using the original data passed down
  }

  @override
  InheritedSongWrapperState createState() => InheritedSongWrapperState();
}

class InheritedSongWrapperState extends State<InheritedSongWrapper> {
  String name = "No song selected";

  void changeSongName(String newName) {
    print("changing name : " + newName);
    setState(() {
      name = newName;
    });
  }

  @override
  Widget build(BuildContext context) {
    print("building widget InheritedSong ");
    print(name);
    return InheritedSong(inheritedChild: widget.child, data: this, name: name);
  }
}

class InheritedSong extends InheritedWidget {
  const InheritedSong(
      {Key? key,
      required this.inheritedChild,
      required this.data,
      required this.name})
      : super(key: key, child: inheritedChild);
  final Widget inheritedChild;
  final String name;
  final InheritedSongWrapperState data;
  @override
  bool updateShouldNotify(InheritedSong oldWidget) {
    return name != oldWidget.name;
  }

  showStatus() {
    return this;
  }
}

// EXAMPLE STATEFUL WIDGET
class WidgetA extends StatefulWidget {
  const WidgetA({Key? key}) : super(key: key);

  @override
  _WidgetAState createState() => _WidgetAState();
}

class _WidgetAState extends State<WidgetA> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed, child: const Text("Success story"));
  }

  onPressed() {
    InheritedSongWrapperState wrapper = InheritedSongWrapper.of(context);
    wrapper.changeSongName("Success !");
  }
}

// EXAMPLE STATELESS WIDGET
class WidgetB extends StatelessWidget {
  const WidgetB({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final InheritedSongWrapperState state = InheritedSongWrapper.of(context,
        build: false); // Uses ancestor instead of current > see doc
    return Text(state.name);
  }
}
