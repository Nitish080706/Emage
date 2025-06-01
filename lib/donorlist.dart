import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DonorList extends StatefulWidget {
  final String? bloodGroup;
  final String? location;

  const DonorList({super.key, this.bloodGroup, this.location});

  @override
  State<DonorList> createState() => _DonorListState();
}

class _DonorListState extends State<DonorList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  List<Map<String, dynamic>> _donors = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDonors();
  }

  Future<void> _fetchDonors() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Start with the base query
      Query query = _firestore.collection('donors');
      
      // Apply blood group filter if provided
      if (widget.bloodGroup != null && widget.bloodGroup!.isNotEmpty) {
        query = query.where('bloodType', isEqualTo: widget.bloodGroup);
      }
      
      // Execute the query
      final QuerySnapshot snapshot = await query.get();
      
      // Convert the documents to a list of maps
      final List<Map<String, dynamic>> donorsList = snapshot.docs
          .map((doc) => {
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              })
          .toList();
      
      // Apply location filter if provided (done client-side since Firestore doesn't support contains queries)
      if (widget.location != null && widget.location!.isNotEmpty) {
        final String normalizedLocation = widget.location!.trim().toLowerCase();
        
        _donors = donorsList.where((donor) {
          final String donorLocation = (donor['location'] as String? ?? '').toLowerCase();
          return donorLocation.contains(normalizedLocation);
        }).toList();
      } else {
        _donors = donorsList;
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error fetching donors: $e';
      });
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
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "BLOOD DONORS",
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
            child: const CircleAvatar(
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
              "Available Blood Donors",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFCD1C18),
                    ),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Color(0xFFCD1C18),
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _fetchDonors,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFCD1C18),
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _donors.isEmpty
                        ? const Center(child: Text("No donors found"))
                        : RefreshIndicator(
                            onRefresh: _fetchDonors,
                            color: const Color(0xFFCD1C18),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: _donors.length,
                              itemBuilder: (context, index) {
                                final donor = _donors[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: DonorCard(
                                    name: donor["name"] ?? "Unknown",
                                    location: donor["location"] ?? "Unknown",
                                    phone: donor["phone"] ?? "No phone",
                                    email: donor["email"] ?? "No email provided",
                                    bloodType: donor["bloodType"] ?? "?",
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class DonorCard extends StatelessWidget {
  final String name;
  final String location;
  final String phone;
  final String email;
  final String bloodType;

  const DonorCard({
    super.key,
    required this.name,
    required this.location,
    required this.phone,
    required this.email,
    required this.bloodType,
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
              color: const Color(0xFFCD1C18),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: Text(
                bloodType,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
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
                color: const Color(0xFFCD1C18),
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