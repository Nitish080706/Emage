import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class Forgot extends StatefulWidget {
  const Forgot({super.key});

  @override
  State<Forgot> createState() => _ForgotState();
}

class _ForgotState extends State<Forgot> {
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text.trim());
      Get.snackbar(
        'Password Reset Link Sent',
        'Check your email to reset your password.',
        margin: const EdgeInsets.all(20),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        margin: const EdgeInsets.all(20),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   title: const Text("Forgot Password"),
      //   backgroundColor: Colors.red,
      //   centerTitle: true,
      //   elevation: 0,
      // ),
      appBar: AppBar(
  title: const Text(
    "Forgot Password",
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
            Image.asset("assets/forgot_password.png", width: 200),
            const SizedBox(height: 20),
            const Text(
              "Reset Your Password",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              "Enter your email, and we will send you a password reset link.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email",
                  hintText: "Enter your email",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.email, color: Colors.red),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Please enter your email";
                  if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
                    return "Enter a valid email";
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator(color: Colors.red)
                : ElevatedButton.icon(
                    onPressed: resetPassword,
                    icon: const Icon(Icons.send, color: Colors.white),
                    label: const Text("Send Reset Link"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
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
