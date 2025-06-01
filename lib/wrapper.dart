import 'home_page.dart';
import 'sign_in.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'verifyemail.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              print(snapshot.hasData);
              if (snapshot.data!.emailVerified) {
                return HomePage();
              } else {
                return Verify();
              }
              // return Homepage();
            } else {
              return SignInPage();
            }
          }),
    );
  }
}
