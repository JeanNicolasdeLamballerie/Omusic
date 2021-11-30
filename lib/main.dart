import 'package:flutter/material.dart';
import 'package:omusic/frog.dart';
import 'package:omusic/login.dart';
import 'package:omusic/models/library.dart';

// followed : https://medium.com/@joshua.akers/storing-hive-encryption-keys-in-flutter-47a7c037d637
// todo : add keychain support (macOs) https://developer.apple.com/documentation/security/keychain_services/keychain_items/sharing_access_to_keychain_items_among_a_collection_of_apps
// todo : https://flutter.dev/desktop#entitlements-and-the-app-sandbox

//? https://pub.dev/packages/biometric_storage

//? If trying to compile in Ubuntu, you need to install the libsecret-1-dev package before executing flutter run. This is a requirement for compiling biometric_storage.
dynamic encryptedBox;

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //~is it still necessary ? To test;
  //encryptedBox = await retrieveKey();
  runApp(const MyApp());
}

const titleStyle = TextStyle(color: Colors.black, fontWeight: FontWeight.bold);
var theming = AppBarTheme(
    backgroundColor: Colors.teal[300],
    foregroundColor: Colors.blue.shade100,
    titleTextStyle: titleStyle);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "O'Music",
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.teal,
        primaryColor: Colors.teal[500],
        appBarTheme: theming,

        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        // primarySwatch: mainColor,
      ),
      home: const MyHomePage(title: 'Omusic : Listen anywhere'),
      routes: <String, WidgetBuilder>{
        '/library': (BuildContext context) {
          print("see context here : ");
          print(context);
          return const Library(name: 'My Library', playlists: {}, artists: {});
        }
        // '/b': (BuildContext context) => MyPage(title: 'page B'),
        // '/c': (BuildContext context) => MyPage(title: 'page C'),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _songName = "";

  void _changeSong(String name) {
    setState(() {
      _songName = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return InheritedSongWrapper(
      child: Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title,
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
          onPressed: () => _changeSong('newName'), //_incrementCounter,
          tooltip: 'Search',
          child: const Icon(Icons.search),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}
class RoutingAppBar extends StatelessWidget{
  
@override
  Widget build(BuildContext context) {
   return InheritedSongWrapper(
      child: Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title,
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
          onPressed: () => _changeSong('newName'), //_incrementCounter,
          tooltip: 'Search',
          child: const Icon(Icons.search),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
}