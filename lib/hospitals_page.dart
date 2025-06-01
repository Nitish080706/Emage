import 'package:flutter/material.dart';
import 'home_page.dart';
import 'find a donor.dart';
import 'doctors_page.dart';
import 'ambulance_page.dart' as ambulance;

class HospitalsPage extends StatefulWidget {
  const HospitalsPage({super.key});

  @override
  State<HospitalsPage> createState() => _HospitalsPagetate();
}

class _HospitalsPagetate extends State<HospitalsPage> {
  int _currentIndex = 0; // Default to Hospitals tab (index 0)

  // Navigation to different pages
  void _navigateToPage(int index) {
    if (index == _currentIndex) return;
    
    setState(() {
      _currentIndex = index;
    });
    
    switch (index) {
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
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ambulance.AmbulanceScreen()),
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
          "HOSPITALS",
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
              "Nearby Hospitals",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                HospitalCard(
                  name: "Apollo Hospital",
                  location: "Greams Road, Chennai",
                  doctorCount: "125",
                  type: "Private",
                  doctors: [
                    Doctor("Dr. Vikram Sharma", "Cardiology", 15),
                    Doctor("Dr. Ananya Reddy", "Neurology", 12),
                    Doctor("Dr. Rajesh Patel", "Orthopedics", 18),
                    Doctor("Dr. Neha Verma", "Oncology", 10),
                    Doctor("Dr. Karthik Iyer", "Gastroenterology", 8),
                  ],
                ),
                const SizedBox(height: 10),
                HospitalCard(
                  name: "Government Hospital",
                  location: "Park Town, Chennai",
                  doctorCount: "200",
                  type: "Government",
                  doctors: [
                    Doctor("Dr. Manoj Kumar", "General Medicine", 20),
                    Doctor("Dr. Priya Sundaram", "Pediatrics", 15),
                    Doctor("Dr. Sanjay Verma", "General Surgery", 17),
                    Doctor("Dr. Lakshmi Rao", "Gynecology", 12),
                    Doctor("Dr. Ramesh Babu", "Pulmonology", 14),
                  ],
                ),
                const SizedBox(height: 10),
                HospitalCard(
                  name: "Fortis Malar Hospital",
                  location: "Adyar, Chennai",
                  doctorCount: "85",
                  type: "Private",
                  doctors: [
                    Doctor("Dr. Suresh Menon", "Cardiac Surgery", 22),
                    Doctor("Dr. Aarthi Ganesh", "Dermatology", 9),
                    Doctor("Dr. Vijay Nair", "Nephrology", 14),
                    Doctor("Dr. Divya Krishnan", "Endocrinology", 11),
                    Doctor("Dr. Prakash Kumar", "Urology", 13),
                  ],
                ),
                const SizedBox(height: 10),
                HospitalCard(
                  name: "Rajiv Gandhi Govt Hospital",
                  location: "Chennai Central, Chennai",
                  doctorCount: "175",
                  type: "Government",
                  doctors: [
                    Doctor("Dr. Kavitha Rajan", "Critical Care", 16),
                    Doctor("Dr. Senthil Kumar", "Neurosurgery", 19),
                    Doctor("Dr. Meena Sundari", "Ophthalmology", 13),
                    Doctor("Dr. Gopal Rao", "Psychiatry", 11),
                    Doctor("Dr. Venkat Raman", "Hematology", 15),
                  ],
                ),
                const SizedBox(height: 10),
                HospitalCard(
                  name: "MIOT International",
                  location: "Manapakkam, Chennai",
                  doctorCount: "110",
                  type: "Private",
                  doctors: [
                    Doctor("Dr. Arjun Sharma", "Joint Replacement", 17),
                    Doctor("Dr. Sharmila Devi", "Rheumatology", 12),
                    Doctor("Dr. Venkatesh S", "Plastic Surgery", 14),
                    Doctor("Dr. Anjana Murthy", "Diabetology", 9),
                    Doctor("Dr. Rahul Menon", "Sports Medicine", 11),
                  ],
                ),
                const SizedBox(height: 10),
                HospitalCard(
                  name: "Kauvery Hospital",
                  location: "Alwarpet, Chennai",
                  doctorCount: "95",
                  type: "Private",
                  doctors: [
                    Doctor("Dr. Balaji Krishnan", "Interventional Cardiology", 20),
                    Doctor("Dr. Sudha Raman", "Obstetrics", 16),
                    Doctor("Dr. Mohan Raj", "ENT", 13),
                    Doctor("Dr. Pooja Iyer", "Internal Medicine", 8),
                    Doctor("Dr. Gautam Reddy", "Oncosurgery", 15),
                  ],
                ),
                const SizedBox(height: 10),
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
                    _buildNavItem('assets/hospitals.png', index: 0, isSelected: true),
                    _buildNavItem('assets/doctors.png', index: 1),
                    // Empty space for the floating button
                    const SizedBox(width: 24),
                    _buildNavItem('assets/blood_donor.png', index: 3),
                    _buildNavItem('assets/ambulance.png', index: 4),
                  ],
                ),
              ),

              // Floating emergency button
              Positioned(
                top: 1, // Adjust this value to control how much the button floats
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

  Widget _buildNavItem(String iconPath, {required int index, bool isSelected = false}) {
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

class Doctor {
  final String name;
  final String specialization;
  final int yearsOfExperience;

  Doctor(this.name, this.specialization, this.yearsOfExperience);
}

class HospitalCard extends StatelessWidget {
  final String name;
  final String location;
  final String doctorCount;
  final String type;
  final List<Doctor> doctors;

  const HospitalCard({
    super.key,
    required this.name,
    required this.location,
    required this.doctorCount,
    required this.type,
    required this.doctors,
  });

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
              color: type == "Government" ? const Color(0xFF3F51B5) : const Color(0xFFCD1C18),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: Image.asset(
                "assets/hospitals.png",
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
                Row(
                  children: [
                    const Icon(
                      Icons.people,
                      color: Colors.blue,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "$doctorCount Doctors",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      type == "Government" ? Icons.public : Icons.business,
                      color: type == "Government" ? Colors.green : Colors.purple,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "$type Hospital",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              _showHospitalDetails(context, name, location, doctorCount, type, doctors);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: type == "Government" ? const Color(0xFF3F51B5) : const Color(0xFFCD1C18),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHospitalDetails(BuildContext context, String name, String location, String doctorCount, String type, List<Doctor> doctors) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: type == "Government" ? Colors.green.shade100 : Colors.purple.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                        color: type == "Government" ? Colors.green.shade800 : Colors.purple.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    location,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.people, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    "$doctorCount Doctors working",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                "Facilities Available",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFacilityChip("Emergency"),
                  _buildFacilityChip("ICU"),
                  _buildFacilityChip("Lab Tests"),
                  _buildFacilityChip("Surgery"),
                  _buildFacilityChip("Pharmacy"),
                  _buildFacilityChip("X-Ray"),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                "Doctors",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: doctors.length,
                  itemBuilder: (context, index) {
                    return _buildDoctorListItem(
                      doctors[index].name,
                      doctors[index].specialization,
                      doctors[index].yearsOfExperience,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFacilityChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label),
    );
  }
  
  Widget _buildDoctorListItem(String name, String specialization, int yearsOfExperience) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: Icon(Icons.person, color: Colors.blue.shade800),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                Text(
                  specialization,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "$yearsOfExperience yrs exp",
              style: TextStyle(
                color: Colors.green.shade800,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

