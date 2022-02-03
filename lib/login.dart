import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:biometric_storage/biometric_storage.dart';
import 'package:omusic/login_provider.dart';
import 'package:http/http.dart' as http;
//~ Init & logic

retrieveKey() async {
  BiometricStorageFile storageFile =
      await BiometricStorage().getStorage('box_key',
          options: StorageFileInitOptions(
            authenticationRequired: false,
          ));
  String usedKey;
  var rawKey = await storageFile.read();
  Uint8List boxKey;

  bool containsEncryptionKey = (rawKey != null && rawKey != "");
  //! Recover encryption key from BiometricStorage, checks existence

  if (!containsEncryptionKey) {
    //! Generates new encryption key
    var key = Hive.generateSecureKey();
    usedKey = base64UrlEncode(key);
    await storageFile.write(usedKey);
  } else {
    usedKey = rawKey;
  }
  //! Uses encryption key : Extract Uint8List from Base64 key that was either generated or retrieved.
  print('rawKey: $rawKey \nRetrieving and converting to Uint8List');
  boxKey = base64Decode(usedKey);
  print('encryption key: ' + boxKey.toString());

  //! Start Hive.
  await Hive.initFlutter();

  var encryptedBox =
      await Hive.openBox('vaultBox', encryptionCipher: HiveAesCipher(boxKey));
  encryptedBox.put('secret', 'Hive is cool');

  //todo : CHECK SECRET SECURITY if using a secret ! (rotating secret from HTTPS? Even if the secret is securely stored, it's not securely inputted into the box since this is a straight string)
  //& see : https://blog.ostorlab.co/hardcoded-secrets.html

  print(encryptedBox.get('secret'));
  var googleLog = encryptedBox.get('googleLog');
  if (googleLog == null) {
    //todo init login
  } else {
    // todo login

  }

  return encryptedBox;
}

//~ View & state management
class LoginWrapper extends StatefulWidget {
  final Widget child;
  const LoginWrapper({Key? key, required this.child}) : super(key: key);

  static LoginWrapperState of(BuildContext context, {bool build = true}) {
    return build
        ? context.dependOnInheritedWidgetOfExactType<InheritedLogin>()!.data
        : context
            .findAncestorWidgetOfExactType<InheritedLogin>()!
            .data; // If we don't want to rebuild the current widget, we can pass StaticWrapper = LoginWrapper.of(context, false); only using the original data passed down
  }

  @override
  LoginWrapperState createState() => LoginWrapperState();
}

class LoginWrapperState extends State<LoginWrapper> {
  String gToken = "";
  late http.Client? gClient;
  bool isConnected = false;
  var _user;
  void setToken(String token) {
    print("changing token : " + token);
    setState(() {
      gToken = token;
      isConnected = true;
    });
  }

  void setClient(http.Client client) {
    print("changing client : " + client.toString());
    setState(() {
      gClient = client;
      isConnected = true;
    });
  }

  void removeToken() {
    print("removing token from state");
    //todo remove token from secure box ?
    setState(() {
      gToken = "";
      isConnected = false;
    });
  }

  void setUser(user) {
    print("changing user : " + user.toString());
    setState(() {
      _user = user;
    });
  }

  void removeUser() {
    print("removing user from state");
    setState(() {
      _user = null;
    });
  }

  getUser() {
    return _user;
  }

  void removeClient() {
    print("removing client from state");
    //todo remove client from secure box ?
    setState(() {
      gClient = null;
      isConnected = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InheritedLogin(
        inheritedChild: widget.child, data: this, gToken: gToken);
  }
}

class InheritedLogin extends InheritedWidget {
  const InheritedLogin(
      {Key? key,
      required this.inheritedChild,
      required this.data,
      required this.gToken})
      : super(key: key, child: inheritedChild);
  //~ Which "child" are we overriding ?
  final Widget inheritedChild;
  final String gToken;
  final LoginWrapperState data;
  @override
  bool updateShouldNotify(InheritedLogin oldWidget) {
    return gToken != oldWidget.gToken;
  }

  showStatus() {
    return this;
  }
}

// EXAMPLE STATEFUL WIDGET
class LoginWidget extends StatefulWidget {
  const LoginWidget({Key? key}) : super(key: key);

  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
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
          Expanded(child: SignIn()),
          // Column(children: const <Widget>[]),
          // ElevatedButton(
          //     onPressed: () => InheritedSongWrapper.of(context)
          //         .changeSongName("newName"),
          //     child: const Text("Hello World"))
          //  style: Theme.of(context).textTheme.headline4,
        ],
      ),
    );
  }

  onPressed() {
    LoginWrapperState wrapper = LoginWrapper.of(context);
    wrapper.setToken("Success !");
  }
}

// EXAMPLE STATELESS WIDGET

//! Could hold the base login to display if "initialLogin" = null;
class WidgetB extends StatelessWidget {
  const WidgetB({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LoginWrapperState state = LoginWrapper.of(context,
        build: false); // Uses ancestor instead of current > see doc
    return Text(state.gToken.toString());
  }
}
