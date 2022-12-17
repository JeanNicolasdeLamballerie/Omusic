import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/material.dart';
import 'package:omusic/login.dart';
import 'package:googleapis/drive/v3.dart' as ga;
import 'package:googleapis_auth/googleapis_auth.dart' as gapis;

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

// class FetchingClient extends http.BaseClient {
//   final http.Client _httpClient;
//   final Map<String, String> partialDownloadHeaders = {
//     'Range': '1-10/'
//     // other headers
//   };
//   FetchingClient(this._httpClient);

//   @override
//   Future<http.StreamedResponse> send(http.BaseRequest request) {
//     request.headers.addAll(partialDownloadHeaders);
//     return _httpClient.send(request);
//   }
// }

void signInSilently(context, currentUser) async {
  await _googleSignIn.signInSilently();
  final gapis.AuthClient? client = await _googleSignIn.authenticatedClient();
  Future.delayed(Duration.zero, () {
    if (client != null) {
      LoginWrapper.of(context).setUser(currentUser);
      LoginWrapper.of(context).setToken(currentUser?.displayName ?? '');
      LoginWrapper.of(context).setClient(client);
    } else {
      print("ERROR /!\\ : CLIENT IS NULL");
    }
  });
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
      print(mounted);

      if (mounted) {
        setState(() {
          _currentUser = account;
          print(account);
        });
        signInSilently(context, _currentUser);
      }
      // if (_currentUser != null) {
      //   //_handleGetContact(_currentUser!);
      // }
    });
  }

  Future<void> _handleSignIn() async {
    try {
      var c = await _googleSignIn.signIn();
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
                onPressed: _handleSignOut,
                child: const Text('SIGN OUT'),
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

class UserBar extends StatelessWidget {
  final GoogleSignInAccount user;
  final String title;
  final TextStyle? style;
  const UserBar({Key? key, required this.user, required this.title, this.style})
      : super(key: key);

  @override
  build(context) {
    Future<void> _handleSignOut() {
      LoginWrapper.of(context).removeToken();
      LoginWrapper.of(context).removeUser();
      LoginWrapper.of(context).removeClient();
      return _googleSignIn.disconnect();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          flex: 4,
          child: ListTile(
            leading: GoogleUserCircleAvatar(
              identity: user,
            ),
            title: Text((user.displayName ?? '') + ' > ' + title, style: style),
            subtitle: Text(user.email, style: style),
            trailing: ElevatedButton(
              child: const Text('SIGN OUT'),
              onPressed: _handleSignOut,
            ),
          ),
        ),
        // const Expanded(
        //   flex: 6,
        //   child: Text("Signed in successfully."),
        // ),
      ],
    );
  }
}
