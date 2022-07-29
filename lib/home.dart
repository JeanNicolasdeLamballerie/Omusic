import 'package:flutter/material.dart';
import 'package:omusic/login.dart';
import 'package:omusic/components/appbar.dart';
import 'package:omusic/components/library.dart';
import 'package:omusic/components/drive_api.dart';
import 'package:omusic/components/player.dart';
import 'package:audio_service/audio_service.dart';

class HomeController extends StatefulWidget {
  final String titleHome = "Home Page";
  final String titleLogin = "Log in to Omusic";
  const HomeController({Key? key}) : super(key: key);
  @override
  createState() => HomeControllerState();
}

class HomeControllerState extends State<HomeController> {
  bool isConnected = false;
  late AudioPlayerHandler handler;
  dynamic loginState;

  void setLoginState(bool connected) {
    setState(() {
      isConnected = connected;
    });
  }

  @override
  void initState() {
    super.initState();
    getHandler() async {
      handler = await AudioService.init(builder: () => AudioPlayerHandler());
    }

    getHandler();
  }

  @override
  build(context) {
    loginState = LoginWrapper.of(context);
    print(loginState);
    if (loginState.isConnected == !isConnected) {
      setLoginState(loginState.isConnected);
    }
    if (isConnected) {
      var client = loginState.gClient;
      var api = DriveAPI(client: client);
      api.initAPI();
      return RoutingAppBar(
          current: "Library",
          api: api,
          handler: handler,
          child: LibraryView(api: api, handler: handler));
    } else {
      return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.titleLogin,
              style: Theme.of(context).appBarTheme.titleTextStyle),
        ),
        body: const LoginWidget(),
        // ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => ('newName'), //_incrementCounter,
          tooltip: 'Search',
          child: const Icon(Icons.search),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      );
    }
  }
}
