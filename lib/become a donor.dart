import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BecomeADonor extends StatefulWidget {
  const BecomeADonor({super.key});

  @override
  _BecomeADonorState createState() => _BecomeADonorState();
}

class _BecomeADonorState extends State<BecomeADonor> {
  final TextEditingController locationController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool _isLoadingUserData = true;
  String _name = '';
  String _bloodGroup = '';
  String _phone = '';
  String _email = '';
  String _location = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoadingUserData = true;
    });

    try {
      final User? user = _auth.currentUser;

      if (user != null) {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        final donorsDoc =
            await _firestore.collection('donors').doc(user.uid).get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;
          final donorsData = donorsDoc.data()!;

          setState(() {
            _name = userData['name'] ?? user.displayName ?? 'No name provided';
            _bloodGroup = userData['bloodGroup'] ?? 'Not specified';
            _email = userData['email'];
            _phone = userData['phone'] ?? 'Not provided';
            _location = donorsData['location'] ?? 'Not provided';
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching user data: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingUserData = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("BECOME A DONOR",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            )),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoadingUserData
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFCD1C18)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // User Information Section
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Your Information",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildInfoRow(Icons.person, "Name", _name),
                        const SizedBox(height: 10),
                        _buildInfoRow(
                            Icons.bloodtype, "Blood Group", _bloodGroup),
                        const SizedBox(height: 10),
                        _buildInfoRow(Icons.phone, "Phone Number", _phone),
                        const SizedBox(height: 10),
                        _buildInfoRow(Icons.email, "Email", _email),
                        const SizedBox(height: 10),
                        _buildInfoRow(
                            Icons.location_city, "Location", _location),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),
                  const Text(
                    "Please enter your city",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                      locationController, "City", Icons.location_city),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _registerAsDonor,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCD1C18),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Agree & Continue",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFCD1C18), size: 20),
        const SizedBox(width: 10),
        Text(
          "$label:",
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 15),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hintText, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFCD1C18)),
        ),
      ),
    );
  }

  Future<void> _registerAsDonor() async {
    if (locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your city'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user
      final User? user = _auth.currentUser;

      if (user != null) {
        // Get user data from Firebase
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;

          // Create donor entry with existing user data and new location
          await _firestore.collection('donors').doc(user.uid).set({
            'name': userData['name'] ?? user.displayName ?? '',
            'email': userData['email'] ?? user.email ?? '',
            'phone': userData['phone'] ?? '',
            'bloodType': userData['bloodGroup'] ?? '',
            'location': locationController.text.trim(),
            'userId': user.uid,
            'timestamp': FieldValue.serverTimestamp(),
          });

          // Update user document to mark as donor
          await _firestore.collection('users').doc(user.uid).update({
            'isDonor': true,
            'donorLocation': locationController.text.trim().toUpperCase(),
          });
          await _firestore.collection('donors').doc(user.uid).update({
            'bloodType': userData['bloodGroup'],
            'name': userData['name'],
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thank you for registering as a donor!'),
              backgroundColor: Color(0xFFCD1C18),
            ),
          );

          Navigator.pop(context);
        } else {
          throw Exception('User data not found');
        }
      } else {
        throw Exception('User not authenticated');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    locationController.dispose();
    super.dispose();
  }
}
