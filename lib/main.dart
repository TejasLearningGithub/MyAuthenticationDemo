import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:mydemosecond/facebook_login/login_with_facebook.dart';
import 'package:mydemosecond/firebase_options.dart';
import 'package:mydemosecond/google/sign_in_with_google.dart';
import 'package:mydemosecond/home/home_page.dart';
import 'package:mydemosecond/provider/login_provider.dart';
import 'package:mydemosecond/provider/screen/login_page.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MyLoginController>(
          create: (_) => MyLoginController(),
        )
      ],
      child: const MaterialApp(
        home: LoginPage(),
      ),
    );
  }
}
