import 'package:flutter/material.dart';
import 'package:omusic/login.dart';
import 'package:omusic/components/appbar.dart';

class HomeController extends StatefulWidget {
  final String titleHome = "Home Page";
  final String titleLogin = "Log in to Omusic";
  const HomeController({Key? key}) : super(key: key);
  @override
  createState() => HomeControllerState();
}

class HomeControllerState extends State<HomeController> {
  bool isConnected = false;
  dynamic loginState;

  void setLoginState(bool connected) {
    setState(() {
      isConnected = connected;
    });
  }

  @override
  build(context) {
    print('getting login state');
    loginState = LoginWrapper.of(context);
    print(loginState);
    if (loginState.isConnected == !isConnected) {
      setLoginState(loginState.isConnected);
    }
    if (isConnected) {
      return const RoutingAppBar(current: "", child: Text("hello"));
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
