import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:http/http.dart' as http;
import 'package:mydemosecond/home/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginWithFacebook extends StatefulWidget {
  const LoginWithFacebook({Key? key}) : super(key: key);

  @override
  _LoginWithFacebookState createState() => _LoginWithFacebookState();
}

class _LoginWithFacebookState extends State<LoginWithFacebook> {
  FacebookAccessToken? _token;
  FacebookUserProfile? _profile;
  final FacebookLogin plugin = FacebookLogin(debug: true);
  String? imageUrl;

  var facebookLogin = FacebookLogin();
  String userEmail = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Facebook Login'),
      ),
      body: Container(
        child: Column(
          children: [
            ElevatedButton(
                onPressed: () {
                  _signinWithFacebook();
                },
                child: Text('Log in with facebook')),
            ElevatedButton(
                onPressed: () {}, child: Text('Log out with facebook'))
          ],
        ),
      ),
    );
  }

  getFCMToken() async {
    FirebaseMessaging.instance.getToken().then((value) {
      String? token = value;

      developer.log("Token_________________$token");
    });
  }

  Widget _signinWithFacebook() {
    final isLogin = _token != null && _profile != null;
    return InkWell(
      onTap: () {
        // isLogin ? _onPressedLogOutButton() :
        _onPressedLogInButton();
        signInWithFacebook();
      },
      child: Container(
        height: MediaQuery.of(context).size.height / 13,
        width: double.maxFinite,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35),
          border: Border.all(
            color: Colors.black,
            width: 2,
          ),
        ),
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Icon(
              Icons.facebook,
              color: Colors.blue,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 6,
            ),
            FittedBox(
              fit: BoxFit.fill,
              child: Text(
                'Sign in with facebook',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  signInWithFacebook() async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login();

    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.token);

    // Once signed in, return the UserCredential
    return FirebaseAuth.instance
        .signInWithCredential(facebookAuthCredential)
        .whenComplete(() {
      // MySharedPreferences.instance.setStringValue("isLogin", "true");
      getFCMToken();
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false);
    });
  }

  Future<void> _onPressedLogInButton() async {
    await plugin.logIn(permissions: [
      FacebookPermission.publicProfile,
      FacebookPermission.email,
    ]);
    developer.log(
        "Facebook Information____________${FacebookPermission.publicProfile.name}");
    await _updateLoginInfo();
  }

  Future<void> _updateLoginInfo() async {
    // final plugin = widget.plugin;
    final token = await plugin.accessToken;
    FacebookUserProfile? profile;
    String? email;
    String? imageUrl;

    if (token != null) {
      profile = await plugin.getUserProfile();

      String? firstName = profile?.firstName;
      String? lastName = profile?.lastName;
      String? loginEmail = await plugin.getUserEmail();

      developer.log("UserProfile________________$profile");
      if (token.permissions.contains(FacebookPermission.email.name)) {
        email = await plugin.getUserEmail();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );

        SharedPreferences? myPrefs;

        myPrefs?.setString('userEmail', email.toString());
      }
      imageUrl = await plugin.getProfileImageUrl(width: 100);
    }

    setState(() {
      _token = token;
      _profile = profile;
      imageUrl = imageUrl;
    });
  }
}
