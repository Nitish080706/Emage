import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  File? _image; // Only used on mobile
  XFile? _xFile;
  Uint8List? _webImage; // For web platform
  String? _currentImageUrl;
  bool _isLoading = false;
  bool _isSaving = false;
  double _uploadProgress = 0.0;
  bool _isUploading = false;
  
  final picker = ImagePicker();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user != null) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        print("Loading user data from Firestore");
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          nameController.text = userData['name'] ?? "DIVYANAND";
          phoneController.text = userData['phone'] ?? "408-841-0926";
          
          if (userData.containsKey('profileImageUrl') && userData['profileImageUrl'] != null) {
            setState(() { 
              
              _currentImageUrl = userData['profileImageUrl'];
              print("Loaded profile image URL: $_currentImageUrl");
            });
          }
        } else {
          print("No user document found, using default values");
          nameController.text = "DIVYANAND";
          phoneController.text = "408-841-0926";
        }
      } catch (e) {
        print("Error loading user data: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading profile: $e"))
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      print("Opening image picker");
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 70,
      );
      
      if (pickedFile != null) {
        setState(() {
          _xFile = pickedFile;
        });
        
        print("Image selected: ${pickedFile.path}");
        
        // Handle differently for web and mobile
        if (kIsWeb) {
          // For web: read as bytes
          try {
            print("Processing web image");
            _webImage = await pickedFile.readAsBytes();
            print("Web image size: ${(_webImage!.length / 1024).toStringAsFixed(2)} KB");
            
            if (_webImage!.length / 1024 > 1000) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Warning: Large image (${(_webImage!.length / 1024).toStringAsFixed(0)} KB) may take longer to upload"))
              );
            }
          } catch (e) {
            print("Error reading web image bytes: $e");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error processing image: $e"))
            );
          }
        } else {
          // For mobile: create File object
          _image = File(pickedFile.path);
          final fileSize = await _image!.length();
          print("Mobile image size: ${(fileSize / 1024).toStringAsFixed(2)} KB");
          
          if (fileSize / 1024 > 1000) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Warning: Large image (${(fileSize / 1024).toStringAsFixed(0)} KB) may take longer to upload"))
            );
          }
        }
        
        setState(() {}); // Refresh UI to show selected image
      } else {
        print("No image selected");
      }
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error selecting image: $e"))
      );
    }
  }

  Future<String?> _uploadImageToFirebase() async {
    if (_xFile == null && _image == null && _webImage == null) {
      print("No image to upload");
      return null;
    }
    
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });
    
    try {
      print("Preparing for image upload");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Preparing image for upload..."))
      );
      
      // Create a unique filename
      String fileName = 'profile_${user!.uid}_${DateTime.now().millisecondsSinceEpoch}';
      
      // Create a reference to the file location in Firebase Storage
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(fileName);
      
      UploadTask uploadTask;
      
      // Get image data based on platform
      Uint8List? imageBytes;
      
      if (kIsWeb && _webImage != null) {
        // Web platform, use the web image bytes directly
        imageBytes = _webImage;
      } else if (!kIsWeb && _xFile != null) {
        // Mobile platform, read bytes from XFile
        imageBytes = await _xFile!.readAsBytes();
      } else if (!kIsWeb && _image != null) {
        // Mobile platform, read bytes from File
        imageBytes = await _image!.readAsBytes();
      }
      
      if (imageBytes == null) {
        throw Exception("Could not get image data");
      }
      
      print("Uploading image (${(imageBytes.length / 1024).toStringAsFixed(1)} KB)...");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Uploading image (${(imageBytes.length / 1024).toStringAsFixed(1)} KB)..."))
      );
      
      // Upload the image bytes
      uploadTask = ref.putData(
        imageBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      
      // Listen to upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print("Upload progress: ${(progress * 100).toStringAsFixed(1)}%");
        setState(() {
          _uploadProgress = progress;
        });
      }, onError: (e) {
        print("Error in upload stream: $e");
      });
      
      // Wait for the upload with timeout
      TaskSnapshot snapshot = await uploadTask.timeout(
        Duration(minutes: 2),
        onTimeout: () {
          print("Upload timed out after 2 minutes");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Upload timed out. Please try again with a smaller image."))
          );
          throw TimeoutException("Image upload timed out");
        },
      );
      
      // Get the download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      print("Image uploaded successfully. URL: $downloadUrl");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image uploaded successfully!"))
      );
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Upload failed: ${e.toString().substring(0, min(50, e.toString().length))}..."),
          duration: Duration(seconds: 5),
        )
      );
      return null;
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _saveProfile(BuildContext context) async {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You need to be logged in to save profile"))
      );
      return;
    }
    
    print("Starting profile save process");
    setState(() {
      _isSaving = true;
    });
    
    try {
      // Start with current image URL (may be null)
      String? imageUrl = _currentImageUrl;
      
      // If a new image was selected, upload it to Firebase Storage
      if (_xFile != null || _image != null || _webImage != null) {
        print("About to upload image");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Uploading image..."))
        );
        
        imageUrl = await _uploadImageToFirebase();
        print("Image upload completed or failed. Image URL: $imageUrl");
        
        if (imageUrl == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to upload image. Profile will be saved without new image."))
          );
        }
      }
      
      print("About to update Firestore document");
      // Save profile data to Firestore
      Map<String, dynamic> userData = {
        'name': nameController.text,
        'phone': phoneController.text,
        'email': user!.email,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      // Only add image URL if it's not null (to avoid overwriting with null)
      if (imageUrl != null) {
        userData['profileImageUrl'] = imageUrl;
      }
      
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .set(userData, SetOptions(merge: true))
          .timeout(Duration(seconds: 30), onTimeout: () {
            print("Firestore update timed out");
            throw TimeoutException("Profile save timed out");
          });
          
      print("Firestore update completed");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully"))
      );
      
      Navigator.pop(context, true); // Return success to refresh previous screen
    } catch (e) {
      print("Error saving profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error updating profile: $e"),
          duration: Duration(seconds: 5),
        )
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Edit Profile", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: Colors.red))
        : Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _getProfileImage(),
                      backgroundColor: Colors.grey[200],
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          backgroundColor: Colors.red,
                          radius: 15,
                          child: Icon(Icons.edit, color: Colors.white, size: 15),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_xFile != null) 
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text("New image selected", style: TextStyle(color: Colors.green)),
                  ),
                if (_isUploading)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      children: [
                        Text(
                          "Uploading: ${(_uploadProgress * 100).toStringAsFixed(1)}%",
                          style: TextStyle(color: Colors.blue),
                        ),
                        SizedBox(height: 5),
                        LinearProgressIndicator(
                          value: _uploadProgress,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 20),
                _buildTextField("Full Name", nameController),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Email",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        user?.email ?? "No Email",
                        style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                _buildTextField("Phone Number", phoneController),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: (_isSaving || _isUploading) ? null : () => _saveProfile(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  ),
                  child: _isSaving 
                    ? SizedBox(
                        width: 20, 
                        height: 20, 
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      )
                    : Text("SAVE", style: TextStyle(color: Colors.white)),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
    );
  }

  ImageProvider _getProfileImage() {
    // For web platform with selected image
    if (kIsWeb && _webImage != null) {
      return MemoryImage(_webImage!);
    }
    // For mobile platform with selected image
    else if (!kIsWeb && _image != null) {
      return FileImage(_image!);
    }
    // For existing image from network
    else if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty) {
      try {
        return NetworkImage(_currentImageUrl!);
      } catch (e) {
        print("Error loading network image: $e");
        return AssetImage("assets/profile.png");
      }
    }
    // Default fallback
    else {
      return AssetImage("assets/profile.png");
    }
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}