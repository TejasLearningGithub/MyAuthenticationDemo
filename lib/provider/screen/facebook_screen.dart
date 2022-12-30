import 'package:flutter/material.dart';
import 'package:mydemosecond/provider/login_provider.dart';
import 'package:provider/provider.dart';

class FaceBookLoginPage extends StatefulWidget {
  const FaceBookLoginPage({Key? key}) : super(key: key);

  @override
  _FaceBookLoginPageState createState() => _FaceBookLoginPageState();
}

class _FaceBookLoginPageState extends State<FaceBookLoginPage> {
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
        ],
      ),
    );
  }
}
