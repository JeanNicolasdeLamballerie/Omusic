import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/material.dart';
import 'package:omusic/login.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth show AuthClient;
//import 'dart:convert' show json;

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [
    'email',
    'https://www.googleapis.com/auth/userinfo.profile',
    'https://www.googleapis.com/auth/contacts.readonly',
    'https://www.googleapis.com/auth/drive',
    'https://www.googleapis.com/auth/docs',
    'https://www.googleapis.com/auth/drive.appdata',
  ],
);

signInSilently(context, currentUser) async {
  await _googleSignIn.signInSilently();
  final http.Client? client = await _googleSignIn.authenticatedClient();
  Future.delayed(Duration.zero, () {
    LoginWrapper.of(context).setToken(currentUser?.displayName ?? '');
    if (client != null) {
      LoginWrapper.of(context).setClient(client);
    } else {
      print("ERROR /!\\ : CLIENT IS NULL");
    }
  });
  return client;
}

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State createState() => SignInState();
}

class SignInState extends State<SignIn> {
  GoogleSignInAccount? _currentUser;
  String _contactText = '';

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
        print(account);
      });
      if (_currentUser != null) {
        //_handleGetContact(_currentUser!);
      }
      signInSilently(context, _currentUser);
    });
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleSignOut() {
    LoginWrapper.of(context).removeToken();
    return _googleSignIn.disconnect();
  }

  // Widget _buildBody() {

  // }

  @override
  Widget build(BuildContext context) {
    GoogleSignInAccount? user = _currentUser;
    print(user.toString());

    if (user != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            flex: 4,
            child: ListTile(
              leading: GoogleUserCircleAvatar(
                identity: user,
              ),
              title: Text(user.displayName ?? ''),
              subtitle: Text(user.email),
              trailing: ElevatedButton(
                child: const Text('SIGN OUT'),
                onPressed: _handleSignOut,
              ),
            ),
          ),
          const Expanded(
            flex: 6,
            child: Text("Signed in successfully."),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          const Text(
              "Sign in to your google drive account to start using Omusic !"),
          ElevatedButton(
            child: const Text('SIGN IN'),
            onPressed: _handleSignIn,
          ),
        ],
      );
    }
  }
}
