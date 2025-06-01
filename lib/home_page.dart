import 'dart:async';
import 'package:flutter/material.dart';
import 'package:another_telephony/telephony.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'find a donor.dart' hide HospitalsPage;
import 'hospitals_page.dart' hide AmbulanceScreen;
import 'profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'doctors_page.dart' hide HospitalsPage;
import 'ambulance_page.dart' hide HospitalsPage;
import 'chatbot_page.dart' hide HospitalsPage, FindaDonor, AmbulanceScreen, DoctorPage;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser;
  int _currentIndex = 2; // Set to Emergency (index 2) by default

  // Emergency information variables
  String _currentLocation = "Unknown location";
  String _selectedEmergencyType = "Emergency"; // Default emergency type
  List<String> _emergencyContacts = [
    '+91 7810075534',
    '+91 9080642927',
    '+91 9786001567',
    '+91 8807121454'
  ]; // Will be populated from Firestore
  Position? _position; // Current GPS position

  // Initialize another_telephony
  final Telephony _telephony = Telephony.instance;

  // UI state variables
  bool _isMyselfSelected = true;
  Color _sosButtonColor = Colors.grey;

  // Variables for press and hold functionality
  bool _isSOSPressed = false;
  int _sosHoldDuration = 0;

  // SOS activation status
  bool _sosActivated = false;

  // Timer for tracking hold duration
  Timer? _sosTimer;

  final Map<String, Color> _emergencyColors = {
    "Accident": Colors.purple,
    "Fire": Colors.red,
    "Medical": Colors.green,
    //"Rescue": Colors.orange,
  };

  @override
  void initState() {
    super.initState();
    _requestAllPermissions();
    _getCurrentLocation();
    _loadEmergencyContacts();
    _getCurrentLocation(); // Initialize location
    _loadUserData();
  }

  @override
  void dispose() {
    _sosTimer?.cancel();
    super.dispose();
  }

  // Request all required permissions
  Future<void> _requestAllPermissions() async {
    await _requestSmsPermission();
    await _requestLocationPermission();
    await _requestPhonePermission();
  }

  // Request SMS permission for another_telephony
  Future<void> _requestSmsPermission() async {
    bool? granted = await _telephony.requestSmsPermissions;
    print("SMS permission granted: $granted");

    // Also request through permission_handler for redundancy
    var status = await Permission.sms.request();
    print("SMS permission status via permission_handler: $status");
  }

  // Request phone state permission
  Future<void> _requestPhonePermission() async {
    var status = await Permission.phone.request();
    print("Phone permission status: $status");
  }

  Future<void> _loadEmergencyContacts() async {
    try {
      final user = this.user;
      if (user != null) {
        final docSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (docSnapshot.exists && docSnapshot.data() != null) {
          final userData = docSnapshot.data()!;
          if (userData.containsKey('emergencyContacts')) {
            setState(() {
              _emergencyContacts =
                  List<String>.from(userData['emergencyContacts']);
            });
            print('Loaded emergency contacts: $_emergencyContacts');
          } else {
            print('No emergency contacts found in user data');
          }
        } else {
          print('User document does not exist or is empty');
        }
      } else {
        print('No user is currently logged in');
      }
    } catch (e) {
      print('Error loading emergency contacts: $e');
    }
  }

  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      _getCurrentLocation();
      print('Location permission granted');
    } else {
      print('Location permission denied: $status');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      // First check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled');
        return;
      }

      // Then check for permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied');
        return;
      }

      // Get current position with timeout
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10));

      setState(() {
        _position = position;
        _currentLocation = "${position.latitude}, ${position.longitude}";
      });
      print('Current location updated: $_currentLocation');
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  void _startSOSHold() {
    if (_selectedEmergencyType == "Emergency") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an emergency type first'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // If already activated, don't start the timer again
    if (_sosActivated) return;

    setState(() {
      _isSOSPressed = true;
      _sosHoldDuration = 0;
    });

    // Cancel any existing timer
    _sosTimer?.cancel();

    // Start a new timer
    _sosTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _sosHoldDuration++;
      });

      // If held for 3 seconds, trigger the SOS action
      if (_sosHoldDuration >= 3) {
        _triggerSOS();
        timer.cancel();
      }
    });
  }

  void _endSOSHold() {
    setState(() {
      _isSOSPressed = false;
    });
    _sosTimer?.cancel();
  }

  void _triggerSOS() {
    setState(() {
      _sosButtonColor = Colors.red;
      _sosActivated = true;
    });

    _sendEmergencyMessages();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('SOS ACTIVATED for $_selectedEmergencyType emergency!'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _setEmergencyType(String type) {
    setState(() {
      if (_selectedEmergencyType == type) {
        _selectedEmergencyType = "Emergency";
        _sosButtonColor = Colors.grey;
        _sosActivated = false;
      } else {
        _selectedEmergencyType = type;
        _sosButtonColor = _emergencyColors[type] ?? Colors.grey;
        _sosActivated = false;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("Selected emergency type: $_selectedEmergencyType")),
    );
  }
// Class level variables

  String _name = "DIVYANAND";
  bool _isLoading = true;
  Map<String, dynamic> userData = {}; // To store user data from Firestore
  Map<String, dynamic> otherPersonData = {}; // For someone else's data

  Future<void> _loadUserData() async {
    // Check if user is logged in

    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Get user document from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (userDoc.exists) {
        // Store the entire user data map
        userData = userDoc.data() as Map<String, dynamic>;

        setState(() {
          // You can also set individual variables if needed for the UI
          _name = userData['name'] ?? "DIVYANAND";
          // Add other fields as needed
          _isLoading = false;
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

  void _sendEmergencyMessages() async {
    print('Starting emergency message sending process...');

    // Make sure we have SMS permissions
    bool? permissionGranted = await _telephony.requestSmsPermissions;
    print('SMS permissions granted: $permissionGranted');

    // Check if we have a valid position
    if (_position == null) {
      await _getCurrentLocation(); // Try to get location again
      if (_position == null) {
        print('Unable to get location for emergency message');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  "Unable to get your location. Messages will be sent without location.")),
        );
      }
    }

    // Compose message based on current settings
    String who = _isMyselfSelected ? "Myself" : "Someone else";
    int age = calculateAgeFromDob(userData['dob'] ?? '');
    String message;
    if (who == "Myself") {
      message = "EMERGENCY ALERT: $who \n"
          "T: $_selectedEmergencyType \n"
          "L: $_currentLocation \n"
          "BG:${userData['bloodGroup']}\n"
          "MedCond: ${userData['medicalConditions']}\n"
          "Age: $age\n"
          "Map: https://maps.google.com/?q=${_position?.latitude ?? 0},${_position?.longitude ?? 0}";

      print('Emergency message content: $message');
    } else {
      message = "EMERGENCY ALERT: $who \n"
          "T: $_selectedEmergencyType \n"
          "L: $_currentLocation \n"
          "Map: https://maps.google.com/?q=${_position?.latitude ?? 0},${_position?.longitude ?? 0}";

      print('Emergency message content: $message');
    }

    // Send SMS if we have emergency contacts using another_telephony
    if (_emergencyContacts.isNotEmpty) {
      try {
        // Send to each emergency contact
        for (String contact in _emergencyContacts) {
          print('Attempting to send SMS to: $contact');

          // Format phone number correctly (sometimes + can cause issues)
          String formattedNumber = contact;
          if (contact.startsWith('+')) {
            formattedNumber = contact; // Keep + for SMS
          }

          _telephony.sendSms(
            to: formattedNumber,
            message: message,
            statusListener: (SendStatus status) {
              print('SMS to $contact - Status: $status');
              if (status == SendStatus.SENT) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("SMS sent to $contact")),
                );
              } else if (status == SendStatus.DELIVERED) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("SMS delivered to $contact")),
                );
              }
            },
          );
        }
      } catch (e) {
        print('Detailed SMS error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error sending SMS: ${e.toString()}")),
        );
      }
    } else {
      print('No emergency contacts found');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "No emergency contacts found. Add contacts in your profile.")),
      );
    }

    // Also send via WhatsApp to the first contact if available
    if (_emergencyContacts.isNotEmpty) {
      for (String contact in _emergencyContacts) {
        _sendWhatsAppMessage(contact, message);
        // Add a small delay between sends to avoid overwhelming the system
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
  }

  void _openChatbot() {
    // Show a snackbar notification
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening chatbot...'),
        duration: Duration(seconds: 2),
      ),
    );

    // Navigate to ChatbotPage
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatbotPage()),
    );
  }

// Other methods remain the same
  Future<void> _sendWhatsAppMessage(String phoneNumber, String message) async {
    try {
      // Format phone number correctly - WhatsApp usually requires country code without +
      String formattedNumber = phoneNumber;
      if (phoneNumber.startsWith('+')) {
        formattedNumber = phoneNumber.substring(1); // Remove the + for WhatsApp
      }

      // Encode the message for URL
      String encodedMessage = Uri.encodeComponent(message);

      // Try both methods of launching WhatsApp

      // Method 1: Using wa.me URL format (recommended by WhatsApp)
      Uri whatsappUri =
          Uri.parse("https://wa.me/$formattedNumber?text=$encodedMessage");
      print('Attempting with URI: $whatsappUri');

      // Try to launch with first method
      if (await canLaunchUrl(whatsappUri)) {
        bool launched =
            await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
        print('WhatsApp launch result (method 1): $launched');
        if (launched) return; // Stop if successful
      }

      // Method 2: Try direct intent for Android
      Uri alternateUri = Uri.parse(
          "whatsapp://send?phone=$formattedNumber&text=$encodedMessage");
      print('Attempting alternate URI: $alternateUri');

      if (await canLaunchUrl(alternateUri)) {
        bool launched =
            await launchUrl(alternateUri, mode: LaunchMode.externalApplication);
        print('WhatsApp launch result (method 2): $launched');
        if (!launched) {
          throw 'Could not launch WhatsApp with method 2';
        }
      } else {
        // Method 3: Try with package name for Android
        final Uri androidUri =
            Uri.parse("intent:#Intent;action=android.intent.action.SEND;"
                "package=com.whatsapp;type=text/plain;"
                "S.android.intent.extra.TEXT=$encodedMessage;"
                "end");

        print('Attempting Android intent URI: $androidUri');
        bool launched = await launchUrl(androidUri);
        print('WhatsApp launch result (method 3): $launched');

        if (!launched) {
          throw 'Could not launch WhatsApp with any method';
        }
      }
    } catch (e) {
      print('Detailed WhatsApp error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "WhatsApp error: ${e.toString()}\nPlease verify WhatsApp is installed.")),
      );
    }
  }

  int calculateAgeFromDob(String dobString) {
    // Check if dobString exists and is valid
    if (dobString.isEmpty) {
      return 0; // Return 0 or some other default value
    }

    try {
      // Parse the DOB string in format "dd-MM-yyyy"
      List<String> parts = dobString.split('-');
      if (parts.length != 3) {
        return 0; // Invalid format
      }

      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2]);

      DateTime dob = DateTime(year, month, day);
      DateTime now = DateTime.now();

      // Calculate age
      int age = now.year - dob.year;

      // Adjust age if birthday hasn't occurred yet this year
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day)) {
        age--;
      }

      return age;
    } catch (e) {
      print("Error calculating age: $e");
      return 0; // Return default on error
    }
  }

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
        // Already on HomePage
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

  Widget _buildNavItem(String iconPath, {required int index}) {
    final bool isSelected = index == _currentIndex;

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

  Widget buildToggleSwitch() {
    return Container(
      height: 50,
      width: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(70),
        border: Border.all(color: const Color(0xFFCD1C18)),
      ),
      child: Stack(
        children: [
          // Animated slider background
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            left: _isMyselfSelected
                ? 0
                : MediaQuery.of(context).size.width / 2 - 20,
            child: Container(
              width: MediaQuery.of(context).size.width / 2 - 20,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFCD1C18),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          // Button row
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isMyselfSelected = true;
                    });
                  },
                  child: Center(
                    child: Text(
                      "Myself",
                      style: TextStyle(
                        color: _isMyselfSelected
                            ? Colors.white
                            : const Color(0xFFCD1C18),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isMyselfSelected = false;
                    });
                  },
                  child: Center(
                    child: Text(
                      "Other",
                      style: TextStyle(
                        color: !_isMyselfSelected
                            ? Colors.white
                            : const Color(0xFFCD1C18),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget emergencyButton(String title, String iconPath, Color bgColor) {
    final bool isSelected = _selectedEmergencyType == title;

    return Stack(
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? bgColor : Colors.white,
            side: BorderSide(color: bgColor),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          ),
          onPressed: () => _setEmergencyType(title),
          icon: Image.asset(
            iconPath,
            width: 20,
          ),
          label: Text(
            title,
            style: TextStyle(
                color: isSelected ? Colors.white : bgColor,
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: Colors.black),
                              const SizedBox(width: 5),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Current location",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                  ),
                                  SizedBox(
                                    width: 200,
                                    child: Text(
                                      _currentLocation,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProfilePage()),
                              );
                            },
                            child: const CircleAvatar(
                              radius: 20,
                              backgroundImage: AssetImage("assets/profile.png"),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Are you in an emergency?",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Press the SOS button to share your location with emergency contacts.",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          // Image.asset("assets/emergency_illustration.png",
                          //     width: 90),
                          GestureDetector(
                            onTap: _openChatbot,
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Image.asset(
                                  "assets/chatbot_icon.png",
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.4,
                          maxWidth: MediaQuery.of(context).size.width * 0.8,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(50),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: -1,
                              ),
                            ],
                          ),
                          child: GestureDetector(
                            onLongPressStart: (_) => _startSOSHold(),
                            onLongPressEnd: (_) => _endSOSHold(),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _sosButtonColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: _isSOSPressed
                                        ? Colors.red.withOpacity(0.3)
                                        : Colors.transparent,
                                    blurRadius: 15,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(50),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _sosActivated ? "SOS ACTIVATED" : "SOS",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 5),
                                  if (!_sosActivated)
                                    _isSOSPressed
                                        ? Text(
                                            "Holding: $_sosHoldDuration/3s",
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14),
                                            textAlign: TextAlign.center,
                                          )
                                        : const Text(
                                            "Press and hold for 3 seconds",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14),
                                            textAlign: TextAlign.center,
                                          ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Emergency Categories
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 35),
                      child: Text(
                        "What's your emergency?",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Emergency Buttons with selection state
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          emergencyButton(
                              "Accident", "assets/accident.png", Colors.purple),
                          emergencyButton(
                              "Fire", "assets/fire.png", Colors.red),
                          emergencyButton(
                              "Medical", "assets/medical.png", Colors.green),
                          // emergencyButton(
                          //     "Rescue", "assets/rescue.png", Colors.orange),
                        ],
                      ),
                    ),

                    // Add the Myself & Other Toggle Switch
                    const SizedBox(height: 30),

                    // Myself & Other Toggle Switch
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: buildToggleSwitch(),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom Navigation Bar with Floating Emergency Button
            Stack(
              alignment: Alignment.center,
              children: [
                // Regular bottom navigation bar
                Container(
                  height: 70,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        // Already on the emergency page, no need for navigation
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
      ),
    );
  }
}
