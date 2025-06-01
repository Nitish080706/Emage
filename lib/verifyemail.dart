import 'package:app/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class Verify extends StatefulWidget {
  const Verify({super.key});

  @override
  State<Verify> createState() => _VerifyState();
}

class _VerifyState extends State<Verify> {
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    sendVerifyLink();
  }

  sendVerifyLink() async {
    setState(() => _isSending = true);
    final user = FirebaseAuth.instance.currentUser!;
    await user.sendEmailVerification().then((value) {
      setState(() => _isSending = false);
      Get.snackbar(
        'Verification Link Sent',
        'Check your email and click the link to verify.',
        margin: const EdgeInsets.all(20),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    });
  }

  reload() async {
    await FirebaseAuth.instance.currentUser!.reload();
    Get.offAll(Wrapper());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   title: const Text("Verify Email"),
      //   backgroundColor: Colors.red,
      //   centerTitle: true,
      //   elevation: 0,
      // ),
       appBar: AppBar(
  title: const Text(
    "Verify Email",
    style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 20,
      color: Colors.white, 
    ),
  ),
  centerTitle: true,
  elevation: 0,
  flexibleSpace: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color.fromARGB(255, 157, 17, 7), Colors.black],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ),
),
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/email_verification.png", width: 200),
            const SizedBox(height: 20),
            const Text(
              "Verify Your Email",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              "A verification link has been sent to your email. Please check and verify to continue.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            _isSending
                ? const CircularProgressIndicator(color: Colors.red)
                : ElevatedButton.icon(
                    onPressed: sendVerifyLink,
                    icon: const Icon(Icons.email, color: Colors.white),
                    label: const Text("Resend Verification Link"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: reload,
              icon: const Icon(Icons.refresh, color: Colors.red),
              label: const Text("I have verified"),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red, width: 2),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
