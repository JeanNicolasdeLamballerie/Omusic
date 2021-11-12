import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:biometric_storage/biometric_storage.dart';
import 'package:omusic/login_provider.dart';
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

  void setToken(String token) {
    print("changing token : " + token);
    setState(() {
      gToken = token;
    });
  }

  void removeToken() {
    print("removing token from state");
    //todo remove token from secure box ?
    setState(() {
      gToken = "";
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
    return const SignIn();
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
