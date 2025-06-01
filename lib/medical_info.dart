import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_medical_info.dart';
import 'profile_page.dart';

class MedicalInfoScreen extends StatefulWidget {
  const MedicalInfoScreen({super.key});

  @override
  _MedicalInfoScreenState createState() => _MedicalInfoScreenState();
}

class _MedicalInfoScreenState extends State<MedicalInfoScreen> {
  final user = FirebaseAuth.instance.currentUser;
  String name = "";
  String age = "";
  String dob = "";
  String emergencyNumber = "";
  String bloodGroup = "";
  String medicalConditions = "";

  @override
  void initState() {
    super.initState();
    _fetchMedicalInfo();
  }

  void _fetchMedicalInfo() async {
    if (user != null) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          name=data['name']?? "";
          dob = data['dob'] ?? "";
          age = _calculateAge(dob);
          emergencyNumber = data['emergencyNumber'] ?? "";
          bloodGroup = data['bloodGroup'] ?? "";
          medicalConditions = data['medicalConditions'] ?? "";
        });
      }
    }
  }

  String _calculateAge(String dob) {
    if (dob.isEmpty) return "";
    List<String> parts = dob.split("-");
    int birthYear = int.parse(parts[2]);
    int birthMonth = int.parse(parts[1]);
    int birthDay = int.parse(parts[0]);

    DateTime birthDate = DateTime(birthYear, birthMonth, birthDay);
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;

    if (today.month < birthMonth ||
        (today.month == birthMonth && today.day < birthDay)) {
      age--;
    }
    return age.toString();
  }

  void _navigateToEditScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMedicalInfoScreen(
          age: age,
          dob: dob,
          emergencyNumber: emergencyNumber,
          bloodGroup: bloodGroup,
          medicalConditions: medicalConditions,
        ),
      ),
    );
    if (result != null) {
      _fetchMedicalInfo(); // Refresh after editing
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          },
        ),
        title: Text("Medical Info", style: TextStyle(color: Colors.black)),
        actions: [
          TextButton(
            onPressed: _navigateToEditScreen,
            child: Text("EDIT", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/profile.png'),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(user?.email ?? "No Email",
                        style: TextStyle(color: Colors.grey)),
                  ],
                )
              ],
            ),
            SizedBox(height: 20),
            Card(
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow(Icons.person, "AGE", age),
                    _infoRow(Icons.calendar_today, "DATE OF BIRTH", dob),
                    _infoRow(Icons.phone, "EMERGENCY NUMBER", emergencyNumber),
                    _infoRow(Icons.bloodtype, "BLOOD GROUP", bloodGroup),
                    _infoRow(Icons.local_hospital, "MEDICAL CONDITIONS",
                        medicalConditions),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.red),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
              Text(value),
            ],
          ),
        ],
      ),
    );
  }
}
