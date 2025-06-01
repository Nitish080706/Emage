import 'package:flutter/material.dart';
import 'donorlist.dart';
import 'become a donor.dart';
import 'doctors_page.dart';
import 'ambulance_page.dart';
import 'home_page.dart';
import 'hospitals_page.dart';

class FindaDonor extends StatefulWidget {
  const FindaDonor({super.key});

  @override
  _FindADonorScreenState createState() => _FindADonorScreenState();
}

class _FindADonorScreenState extends State<FindaDonor> {
  TextEditingController locationController = TextEditingController();
  String selectedBloodGroup = "";
  int _currentIndex = 3;

  void _navigateToPage(int index) {
    if (index == _currentIndex) return;
    setState(() {
      _currentIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const HospitalsPage()));
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (context) => DoctorPage()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage()));
        break;
      case 4:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AmbulanceScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "FIND DONOR",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      // Use a SingleChildScrollView to make the content scrollable
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("🩸 Blood Group",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const BecomeADonor()),
                      );
                      setState(() {});
                    },
                    icon: const Icon(Icons.add, color: Colors.white, size: 18),
                    label: const Text("Become a Donor", style: TextStyle(color: Colors.white, fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFCD1C18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: ["A+", "O+", "B+", "AB+", "A-", "O-", "B-", "AB-"].map((bloodType) {
                  return BloodGroupButton(
                    bloodType: bloodType,
                    isSelected: selectedBloodGroup == bloodType,
                    onTap: () {
                      setState(() {
                        selectedBloodGroup = bloodType;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              const Text("📍 LOCATION",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 12),
              TextField(
                controller: locationController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.location_on, color: Colors.grey),
                  hintText: "Enter your location",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 32),
              
              // Search Button
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DonorList(
                          bloodGroup: selectedBloodGroup,
                          location: locationController.text.trim(),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFCD1C18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Search", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // All Donors Button
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DonorList()
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFCD1C18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("All Donors", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
              // Add some extra padding at the bottom to ensure content doesn't get hidden behind bottom navigation
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      // Use resizeToAvoidBottomInset to prevent the bottom navigation from being pushed up
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: Stack(
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
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
    );
  }

  // Bottom Navigation Item
  Widget _buildNavItem(String iconPath, {required int index}) {
    return InkWell(
      onTap: () => _navigateToPage(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            iconPath,
            width: 24,
            height: 24,
            color: _currentIndex == index ? const Color(0xFFCD1C18) : Colors.black54,
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class BloodGroupButton extends StatelessWidget {
  final String bloodType;
  final bool isSelected;
  final VoidCallback onTap;

  const BloodGroupButton({super.key, required this.bloodType, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 22),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFCD1C18) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey),
             boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
        ),
        child: Text(
          bloodType,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}
