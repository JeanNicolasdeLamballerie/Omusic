import 'package:flutter/material.dart';
import 'package:omusic/login.dart';
import 'package:omusic/frog.dart';

class RoutingAppBar extends StatefulWidget {
  final Widget child;
  const RoutingAppBar({Key? key, required this.current, required this.child})
      : super(key: key);
  final String current;
  @override
  RoutingAppBarState createState() => RoutingAppBarState();
}

class RoutingAppBarState extends State<RoutingAppBar> {
  @override
  Widget build(BuildContext context) {
    return InheritedSongWrapper(
      child: Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.current,
              style: Theme.of(context).appBarTheme.titleTextStyle),
        ),
        body: widget.child,
        floatingActionButton: FloatingActionButton(
          onPressed: () => 3 * 3, //_changeSong('newName'), //_incrementCounter,
          tooltip: 'Search',
          child: const Icon(Icons.search),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}
