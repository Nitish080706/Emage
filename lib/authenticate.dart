import 'package:app/sign_in.dart';
import 'package:flutter/material.dart';

class Authenticate extends StatefulWidget{
  const Authenticate({super.key});

  @override
  _AuthenticateState createState()=> _AuthenticateState();

}
class _AuthenticateState extends State<Authenticate>{

  @override
  Widget build(BuildContext context){
    return Container(
   child: SignInPage()
    );
  }
}