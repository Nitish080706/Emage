import 'ambulance_page.dart';
import 'find a donor.dart';
import 'home_page.dart';
import 'package:flutter/material.dart';
import 'hospitals_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class DoctorPage extends StatefulWidget {
  const DoctorPage({super.key});

  @override
  State<DoctorPage> createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> {
  String? selectedCity;
  String? selectedDoctorType;
  List<Doctor> allDoctors = [];
  List<Doctor> filteredDoctors = [];
  bool isLoading = true;
  int _currentIndex = 1; // Default to Doctors tab (index 1)

  @override
  void initState() {
    super.initState();
    fetchDoctors();
  }

  // Fetch doctors from Firebase
  Future<void> fetchDoctors() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      final QuerySnapshot querySnapshot = 
          await FirebaseFirestore.instance.collection('doctors').get();
          
      final List<Doctor> loadedDoctors = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Doctor(
          name: data['name'] ?? '',
          specialist: data['specialist'] ?? '',
          phoneNumber: data['phoneNumber'] ?? '',
          location: data['location'] ?? '',
          address: data['address'] ?? '',
          experience: data['experience'] ?? '',
          rating: (data['rating'] ?? 0.0).toDouble(),
          about: data['about'] ?? '',
        );
      }).toList();
      
      setState(() {
        allDoctors = loadedDoctors;
        filteredDoctors = List.from(allDoctors);
        isLoading = false;
      });
    } catch (error) {
      print('Error fetching doctors: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterDoctors() {
    setState(() {
      filteredDoctors = allDoctors.where((doctor) {
        bool matchesCity =
            selectedCity == null || doctor.location == selectedCity;
        bool matchesType = selectedDoctorType == null ||
            doctor.specialist == selectedDoctorType;
        return matchesCity && matchesType;
      }).toList();
    });
  }

  // Get unique cities from doctor data for dropdown
  List<String> getUniqueCities() {
    final Set<String> cities = allDoctors.map((doctor) => doctor.location).toSet();
    return cities.toList();
  }

  // Get unique specialties from doctor data for dropdown
  List<String> getUniqueSpecialties() {
    final Set<String> specialties = allDoctors.map((doctor) => doctor.specialist).toSet();
    return specialties.toList();
  }

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
          MaterialPageRoute(builder: (context) => const AmbulanceScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Search Your Doctor',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      hint: 'Select Your City',
                      value: selectedCity,
                      onChanged: (value) {
                        setState(() {
                          selectedCity = value;
                        });
                      },
                      items: getUniqueCities(),
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      hint: 'Select Your Doctor Type',
                      value: selectedDoctorType,
                      onChanged: (value) {
                        setState(() {
                          selectedDoctorType = value;
                        });
                      },
                      items: getUniqueSpecialties(),
                    ),
                    const SizedBox(height: 16),
                    _buildSearchButton(),
                    const SizedBox(height: 16),
                    Expanded(
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator(color: Color(0xFFCD1C18)))
                          : filteredDoctors.isEmpty
                              ? const Center(child: Text('No doctors found matching your criteria'))
                              : ListView.separated(
                                  itemCount: filteredDoctors.length,
                                  separatorBuilder: (context, index) =>
                                      const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    return _buildDoctorListItem(filteredDoctors[index]);
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black12),
        ),
      ),
      child: Row(
        children: [
          const BackButton(),
          const Expanded(
            child: Center(
              child: Text(
                'Doctors',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: const DecorationImage(
                image: AssetImage('assets/profile.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required Function(String?) onChanged,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(hint, style: TextStyle(color: Colors.grey.shade600)),
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: filterDoctors,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFCD1C18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Search',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorListItem(Doctor doctor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
              color: const Color(0xFFCD1C18),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: Image.asset(
                "assets/doctorpng.png",
                width: 60,
                height: 60,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.medical_services,
                      color: Colors.teal,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      doctor.specialist,
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
                      Icons.location_on,
                      color: Colors.orange,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      doctor.location,
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
                      Icons.phone,
                      color: Colors.red,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      doctor.phoneNumber,
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
          // Replace the call icon with a book button
          ElevatedButton(
            onPressed: () {
              // Navigate to doctor details page when button is clicked
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DoctorDetailsPage(doctor: doctor),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCD1C18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            ),
            child: const Text(
              'Book',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Stack(
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
              _buildNavItem('assets/doctors.png', index: 1, isSelected: true),
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
                // Navigate to the emergency page
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
class DoctorDetailsPage extends StatelessWidget {
  final Doctor doctor;

  const DoctorDetailsPage({super.key, required this.doctor});

  // Function to make a phone call
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $launchUri';
    }
  }
  // Function to send a message
  Future<void> _sendMessage(BuildContext context, String phoneNumber) async {
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: {'body': 'Hello Dr. ${doctor.name}, I would like to schedule an appointment.'},
    );

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open messaging app'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildDoctorProfile(context),
                    _buildDoctorInfo(),
                    _buildAboutSection(),
                    _buildBookingButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black12),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Doctor Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: const DecorationImage(
                image: AssetImage('assets/profile.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorProfile(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFCD1C18),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Center(
              child: Image.asset(
                "assets/doctorpng.png",
                width: 100,
                height: 100,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            doctor.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            doctor.specialist,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildRatingStars(doctor.rating),
              const SizedBox(width: 8),
              Text(
                '(${doctor.rating})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildContactButton(
                context: context,
                icon: Icons.phone,
                color: Colors.green,
                text: 'Call',
                onTap: () => _makePhoneCall(doctor.phoneNumber),
              ),
              _buildContactButton(
                context: context,
                icon: Icons.message,
                color: Colors.blue,
                text: 'Message',
                onTap: () => _sendMessage(context, doctor.phoneNumber),
              ),
             
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor()
              ? Icons.star
              : (index < rating ? Icons.star_half : Icons.star_border),
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }

  Widget _buildContactButton({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Doctor Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoItem(
            icon: Icons.location_on,
            title: 'Address',
            subtitle: doctor.address,
            color: Colors.orange,
          ),
          const Divider(),
          _buildInfoItem(
            icon: Icons.phone,
            title: 'phone',
            subtitle: doctor.phoneNumber,
            color: Colors.red,
          ),
          const Divider(),
          _buildInfoItem(
            icon: Icons.access_time,
            title: 'Experience',
            subtitle: doctor.experience,
            color: Colors.blue,
          ),
          const Divider(),
          _buildInfoItem(
            icon: Icons.location_city,
            title: 'Location',
            subtitle: doctor.location,
            color: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About Doctor',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            doctor.about,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: () {
            // Show booking confirmation dialog
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Booking Confirmation'),
                  content: Text(
                      'Do you want to book an appointment with Dr. ${doctor.name}?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Appointment with Dr. ${doctor.name} booked successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      child: const Text('Confirm'),
                    ),
                  ],
                );
              },
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFCD1C18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Book Your Doctor',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// Doctor class definition
class Doctor {
  final String name;
  final String specialist;
  final String phoneNumber;
  final String location;
  final String address;
  final String experience;
  final double rating;
  final String about;

  Doctor({
    required this.name,
    required this.specialist,
    required this.phoneNumber,
    required this.location,
    required this.address,
    required this.experience,
    required this.rating,
    required this.about,
  });
}