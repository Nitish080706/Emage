import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final user = FirebaseAuth.instance.currentUser;
  bool _isLoading = true;
  String _name = "DIVYANAND";
  String _phone = "408-841-0926";
  String? _profileImageUrl;
  bool _imageError = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _name = userData['name'] ?? "DIVYANAND";
          _phone = userData['phone'] ?? "408-841-0926";
          _profileImageUrl = userData['profileImageUrl'];
          _isLoading = false;
          _imageError = false;
        });
        
        print("Loaded profile image URL: $_profileImageUrl");
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading user data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _handleImageError() {
    setState(() {
      _imageError = true;
    });
    print("Error loading profile image from URL: $_profileImageUrl");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Personal Info",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfileScreen()),
              );
              if (result == true) {
                // Refresh data if profile was updated
                setState(() {
                  _isLoading = true;
                });
                _loadUserData();
              }
            },
            child: const Text(
              "EDIT",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.red))
          : RefreshIndicator(
              onRefresh: _loadUserData,
              color: Colors.red,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _profileImageUrl != null && !_imageError
                          ? CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: NetworkImage(_profileImageUrl!),
                              onBackgroundImageError: (_, __) => _handleImageError(),
                            )
                          : CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: AssetImage('assets/profile.png'),
                            ),
                      const SizedBox(height: 10),
                      Text(
                        _name,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        user?.email ?? "No Email",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            children: [
                              _infoTile(Icons.person_outline, "FULL NAME", _name),
                              const Divider(),
                              _infoTile(Icons.email_outlined, "EMAIL",
                                  user?.email ?? "No Email"),
                              const Divider(),
                              _infoTile(Icons.phone_outlined, "PHONE NUMBER", _phone),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.red),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}