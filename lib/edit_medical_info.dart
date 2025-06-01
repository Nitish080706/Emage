import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditMedicalInfoScreen extends StatefulWidget {
  final String age;
  final String dob;
  final String emergencyNumber;
  final String bloodGroup;
  final String medicalConditions;

  const EditMedicalInfoScreen({super.key, 
    required this.age,
    required this.dob,
    required this.emergencyNumber,
    required this.bloodGroup,
    required this.medicalConditions,
  });

  @override
  _EditMedicalInfoScreenState createState() => _EditMedicalInfoScreenState();
}

class _EditMedicalInfoScreenState extends State<EditMedicalInfoScreen> {
  late TextEditingController dobController;
  late TextEditingController emergencyNumberController;
  late TextEditingController bloodGroupController;
  late TextEditingController medicalConditionsController;

  @override
  void initState() {
    super.initState();
    dobController = TextEditingController(text: widget.dob);
    emergencyNumberController = TextEditingController(text: widget.emergencyNumber);
    bloodGroupController = TextEditingController(text: widget.bloodGroup);
    medicalConditionsController = TextEditingController(text: widget.medicalConditions);
  }

  @override
  void dispose() {
    dobController.dispose();
    emergencyNumberController.dispose();
    bloodGroupController.dispose();
    medicalConditionsController.dispose();
    super.dispose();
  }

  void _saveInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'dob': dobController.text,
        'emergencyNumber': emergencyNumberController.text,
        'bloodGroup': bloodGroupController.text,
        'medicalConditions': medicalConditionsController.text,
      }, SetOptions(merge: true));

      String updatedAge = _calculateAge(dobController.text);

      Navigator.pop(context, {
        'age': updatedAge,
        'dob': dobController.text,
        'emergencyNumber': emergencyNumberController.text,
        'bloodGroup': bloodGroupController.text,
        'medicalConditions': medicalConditionsController.text,
      });
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

    if (today.month < birthMonth || (today.month == birthMonth && today.day < birthDay)) {
      age--;
    }
    return age.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Medical Info", style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage('assets/profile.png'),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.red,
                        child: Icon(Icons.edit, color: Colors.white, size: 14),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              _buildTextField("DATE OF BIRTH", dobController, hint: "DD-MM-YYYY"),
              _buildTextField("BLOOD GROUP", bloodGroupController),
              _buildTextField("EMERGENCY NUMBER", emergencyNumberController),
              _buildTextField("MEDICAL CONDITIONS", medicalConditionsController),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _saveInfo,
                  child: Text("SAVE", style: TextStyle(color: Colors.white)),
                ),
              ),
              // Add padding at the bottom to ensure the content isn't hidden behind the keyboard
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {String hint = ""}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}