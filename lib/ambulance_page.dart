import 'home_page.dart';
import 'find a donor.dart' hide HospitalsPage;
import 'doctors_page.dart' hide HospitalsPage;
import 'hospitals_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher package

class AmbulanceScreen extends StatefulWidget {
  const AmbulanceScreen({super.key});

  @override
  State<AmbulanceScreen> createState() => _AmbulanceScreenState();
}

class _AmbulanceScreenState extends State<AmbulanceScreen> {
  int _currentIndex = 4; // Default to Ambulance tab (index 4)

  // Navigation to different pages
  void _navigateToPage(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HospitalsPage()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DoctorPage()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FindaDonor()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
        title: const Text(
          "AMBULANCES",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundImage: AssetImage("assets/profile.png"),
              radius: 15,
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Text(
              "Nearby Ambulances",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: const [
                AmbulanceCard(
                  name: "Maharjan",
                  location: "Adyar, Chennai",
                  phone: " 9841234789",
                  email: "Maharajan@gmail.com",
                ),
                SizedBox(height: 10),
                AmbulanceCard(
                  name: "Niraj",
                  location: "OMR, Chennai",
                  phone: " 9841234789",
                  email: "Niraj.kl@gmail.com",
                ),
                SizedBox(height: 10),
                AmbulanceCard(
                  name: "Sanjiv",
                  location: "T Nagar, Chennai",
                  phone: " 9080642927",
                  email: "sanjiv@gmail.com",
                ),
                SizedBox(height: 10),
                AmbulanceCard(
                  name: "Arun Srinivas",
                  location: "Sowkarpet, Chennai",
                  phone: "8807121454",
                  email: "arunsrinivas@gmail.com",
                ),
                SizedBox(height: 10),
                AmbulanceCard(
                  name: "Nitish",
                  location: "Mahabalipuram, Chennai",
                  phone: "7810075534",
                  email: "msnrnitish@gmail.com",
                ),
                SizedBox(height: 10),
                AmbulanceCard(
                  name: "Logeshwar",
                  location: "ECR, Chennai",
                  phone: "9786001567",
                  email: "LOgesh@gmail.com",
                ),
              ],
            ),
          ),
          // Bottom Navigation Bar with Floating Emergency Button
          Stack(
            alignment: Alignment.center,
            children: [
              // Regular bottom navigation bar
              Container(
                height: 70,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem('assets/hospitals.png', index: 0),
                    _buildNavItem('assets/doctors.png', index: 1),
                    // Empty space for the floating button
                    const SizedBox(width: 24),
                    _buildNavItem('assets/blood_donor.png', index: 3),
                    _buildNavItem('assets/ambulance.png',
                        index: 4, isSelected: true),
                  ],
                ),
              ),

              // Floating emergency button
              Positioned(
                top:
                    1, // Adjust this value to control how much the button floats
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: FloatingActionButton(
                    backgroundColor: const Color(0xFFCD1C18),
                    elevation: 0,
                    onPressed: () {
                      _navigateToPage(2); // Navigate to Emergency/Home page
                    },
                    child: Image.asset(
                      'assets/emergency.png',
                      width: 30,
                      height: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(String iconPath,
      {required int index, bool isSelected = false}) {
    return InkWell(
      onTap: () => _navigateToPage(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            iconPath,
            width: 24,
            height: 24,
            color: isSelected ? const Color(0xFFCD1C18) : Colors.black54,
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class AmbulanceCard extends StatelessWidget {
  final String name;
  final String location;
  final String phone;
  final String email;

  const AmbulanceCard({
    super.key,
    required this.name,
    required this.location,
    required this.phone,
    required this.email,
  });

  // Function to make a phone call
  Future<void> _makePhoneCall(String phoneNumber) async {
    // Clean up the phone number by removing spaces and plus sign
    final String cleanedNumber = phoneNumber.replaceAll(" ", "");

    // Create the URL with the tel: scheme
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: cleanedNumber,
    );

    // Launch the URL to make a call
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        // If unable to launch the URL, show an error
        debugPrint('Could not launch $launchUri');
      }
    } catch (e) {
      debugPrint('Error making phone call: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Color(0xFFCD1C18),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: Image.asset(
                "assets/ambulance.png",
                width: 24,
                height: 24,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.orange,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  phone,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _makePhoneCall(phone),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Color(0xFFCD1C18),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.phone,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
