import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:mydemosecond/home/home_page.dart';
import 'package:mydemosecond/provider/login_provider.dart';
import 'package:mydemosecond/provider/screen/phone_screen.dart';
import 'package:mydemosecond/utils/show_otp.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FirebaseAuth? _auth;
  FacebookAccessToken? _token;
  FacebookUserProfile? _profile;
  FacebookLogin? plugin;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login App"),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
      ),

      // body of our ui

      body: loginUI(),
    );
  }

  // creating a function loginUI

  loginUI() {
    // loggedINUI
    // loginControllers

    return Consumer<MyLoginController>(builder: (context, model, child) {
      // if we are already logged in
      if (model.userDetails != null) {
        return Center(
          child: loggedInUI(model),
        );
      } else {
        return loginControllers(context);
      }
    });
  }

  loggedInUI(MyLoginController model) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,

      // our ui will have 3 children, name, email, photo , logout button

      children: [
        CircleAvatar(
          backgroundImage:
              Image.network(model.userDetails!.photoURL ?? "").image,
          radius: 50,
        ),

        Text(model.userDetails!.displayName ?? ""),
        Text(model.userDetails!.email ?? ""),

        // logout
        ActionChip(
            avatar: Icon(Icons.logout),
            label: Text("Logout"),
            onPressed: () {
              Provider.of<MyLoginController>(context, listen: false).logout();
            })
      ],
    );
  }

  loginControllers(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
              child: Image.asset(
                "assets/google.png",
                width: 240,
              ),
              onTap: () {
                Provider.of<MyLoginController>(context, listen: false)
                    .googleLogin();
              }),
          SizedBox(
            height: 10,
          ),
          GestureDetector(
              child: Image.asset(
                "assets/fb.png",
                width: 240,
              ),
              onTap: () {
                Provider.of<MyLoginController>(context, listen: false)
                    .facebooklogin();
              }),
          SizedBox(
            height: 250,
          ),
          ElevatedButton(
            onPressed: () {
              _onPressedLogInButton();
              signInWithFacebook();
            },
            child: Text(
              'Login With Facebook',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              signOut(context);
            },
            child: Text(
              'Logout',
            ),
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginWithPhone(),
                  ),
                );
              },
              child: Text('Login With OTP'))
        ],
      ),
    );
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
      //  getFCMToken();
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false);
    });
  }

  Future<void> _onPressedLogInButton() async {
    await plugin?.logIn(permissions: [
      FacebookPermission.publicProfile,
      FacebookPermission.email,
    ]);
    developer.log(
        "Facebook Information____________${FacebookPermission.publicProfile.name}");
    await _updateLoginInfo();
  }

  Future<void> _updateLoginInfo() async {
    final plugin = this.plugin;
    final token = await plugin?.accessToken;
    FacebookUserProfile? profile;
    String? email;
    String? imageUrl;

    if (token != null) {
      profile = await plugin?.getUserProfile();

      String? firstName = profile?.firstName;
      String? lastName = profile?.lastName;
      String? loginEmail = await plugin?.getUserEmail();

      developer.log("UserProfile________________$profile");
      if (token.permissions.contains(FacebookPermission.email.name)) {
        email = await plugin?.getUserEmail();

        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const HomePage()));

        //SharedPreferences? myPrefs;

        //myPrefs?.setString('userEmail', email.toString());
      }
      imageUrl = await plugin?.getProfileImageUrl(width: 100);
    }

    setState(() {
      _token = token;
      _profile = profile;
      imageUrl = imageUrl;
    });
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await _auth?.signOut();
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()))); // Displaying the error message
    }
  }

  Future<void> phoneSignIn(
    BuildContext context,
    String phoneNumber,
  ) async {
    TextEditingController codeController = TextEditingController();
    if (kIsWeb) {
      // !!! Works only on web !!!
      ConfirmationResult result =
          await _auth!.signInWithPhoneNumber(phoneNumber);

      // Diplay Dialog Box To accept OTP
      showOTPDialog(
        codeController: codeController,
        context: context,
        onPressed: () async {
          PhoneAuthCredential credential = PhoneAuthProvider.credential(
            verificationId: result.verificationId,
            smsCode: codeController.text.trim(),
          );

          await _auth!.signInWithCredential(credential);
          Navigator.of(context).pop(); // Remove the dialog box
        },
      );
    } else {
      // FOR ANDROID, IOS
      await _auth?.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        //  Automatic handling of the SMS code
        verificationCompleted: (PhoneAuthCredential credential) async {
          // !!! works only on android !!!
          await _auth?.signInWithCredential(credential);
        },
        // Displays a message when verification fails
        verificationFailed: (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                e.toString(),
              ),
            ),
          );
        },
        // Displays a dialog box when OTP is sent
        codeSent: ((String verificationId, int? resendToken) async {
          showOTPDialog(
            codeController: codeController,
            context: context,
            onPressed: () async {
              PhoneAuthCredential credential = PhoneAuthProvider.credential(
                verificationId: verificationId,
                smsCode: codeController.text.trim(),
              );

              // !!! Works only on Android, iOS !!!
              await _auth!.signInWithCredential(credential);
              Navigator.of(context).pop(); // Remove the dialog box
            },
          );
        }),
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto-resolution timed out...
        },
      );
    }
  }
}
