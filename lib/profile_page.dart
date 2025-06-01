import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'personal_info.dart';
import 'medical_info.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser;
  bool _isLoading = true;
  String _name = "DIVYANAND";


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
        
        });
        
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
  


  void signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pop(context);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
            // Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => HomePage()),
            //     );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40, // Reduced size
                    backgroundImage: AssetImage('assets/profile.jpg'),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _name,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(user?.email ?? "No Email",
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),
              ProfileContainer(children: [
                ProfileOption(
                    icon: Icons.person,
                    text: 'Personal Info',
                    onTap: () {
                      print("Personal Info Clicked");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PersonalInfoScreen()),
                      );
                    }),
                ProfileOption(
                    icon: Icons.location_on,
                    text: 'Addresses',
                    iconColor: Colors.blue,
                    onTap: () {
                      print("Addresses Clicked");
                    }),
              ]),
              ProfileContainer(children: [
                ProfileOption(
                    icon: Icons.help,
                    text: 'FAQs',
                    iconColor: Colors.red,
                    onTap: () {
                      print("FAQs Clicked");
                    }),
                ProfileOption(
                    icon: Icons.medical_services,
                    text: 'Medical Info',
                    iconColor: Colors.green,
                    onTap: () {
                      print("Medical Info Clicked");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MedicalInfoScreen()),
                      );
                    }),
                ProfileOption(
                    icon: Icons.settings,
                    text: 'Settings',
                    iconColor: Colors.blue,
                    onTap: () {
                      print("Settings Clicked");
                    }),
              ]),
              ProfileContainer(children: [
                ProfileOption(
                    icon: Icons.logout,
                    text: 'Log Out',
                    isLogout: true,
                    onTap: () {
                      signOut(context);
                    }),
              ]),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}

class ProfileContainer extends StatelessWidget {
  final List<Widget> children;

  const ProfileContainer({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.symmetric(vertical: 8, horizontal: 12), // Reduced padding
      margin: EdgeInsets.symmetric(vertical: 6), // Reduced margin
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: children),
    );
  }
}

class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isLogout;
  final VoidCallback? onTap;
  final Color? iconColor;

  const ProfileOption({
    super.key,
    required this.icon,
    required this.text,
    this.isLogout = false,
    this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            vertical: 10, horizontal: 12), // Smaller button
        margin: EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 3,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6), // Smaller icon padding
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                  ),
                  child: Icon(
                    icon,
                    size: 20, // Reduced icon size
                    color: iconColor ?? (isLogout ? Colors.red : Colors.black),
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  text,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500), // Smaller text
                ),
              ],
            ),
            Icon(Icons.arrow_forward_ios,
                color: Colors.grey, size: 14), // Reduced arrow size
          ],
        ),
      ),
    );
  }

}