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
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child:
              // SizedBox(
              //   height: 700.0,
              //child:
              Column(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Invoke "debug painting" (press "p" in the console, choose the
            // "Toggle Debug Paint" action from the Flutter Inspector in Android
            // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
            // to see the wireframe for each widget.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              //Text(InheritedSongWrapper.of(context).name),
              Expanded(child: LoginWidget()),
              // Column(children: const <Widget>[]),
              // ElevatedButton(
              //     onPressed: () => InheritedSongWrapper.of(context)
              //         .changeSongName("newName"),
              //     child: const Text("Hello World"))
              //  style: Theme.of(context).textTheme.headline4,
            ],
          ),
        ),
        // ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => 3 * 3, //_changeSong('newName'), //_incrementCounter,
          tooltip: 'Search',
          child: const Icon(Icons.search),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}
