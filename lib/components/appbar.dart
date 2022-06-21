import 'package:flutter/material.dart';
import 'package:omusic/login.dart';
import 'package:omusic/frog.dart';
import 'package:omusic/login_provider.dart';
import 'package:omusic/components/player.dart';
import 'package:omusic/components/drive_api.dart';

class RoutingAppBar extends StatefulWidget {
  final Widget child;
  final String current;
  final DriveAPI api;
  final AudioPlayerHandler handler;
  const RoutingAppBar(
      {Key? key,
      required this.current,
      required this.child,
      required this.api,
      required this.handler})
      : super(key: key);
  @override
  RoutingAppBarState createState() => RoutingAppBarState();
}

class RoutingAppBarState extends State<RoutingAppBar> {
  @override
  Widget build(BuildContext context) {
    return InheritedSongWrapper(
      child: Scaffold(
        bottomNavigationBar: SizedBox(
            height: 120,
            width: 200,
            child: Player(api: widget.api, handler: widget.handler)),
        appBar: AppBar(
          flexibleSpace: UserBar(
              title: widget.current,
              user: LoginWrapper.of(context).getUser(),
              style: Theme.of(context).appBarTheme.titleTextStyle),
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
        ),
        body: // Column(
            //   children: [
            //UserBar(user: LoginWrapper.of(context).getUser()),
            widget.child
        // ],
        //)
        ,
        floatingActionButton: FloatingActionButton(
          onPressed: () => 3 * 3, //_changeSong('newName'), //_incrementCounter,
          tooltip: 'Search',
          child: const Icon(Icons.search),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}
