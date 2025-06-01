import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_tts/flutter_tts.dart'; // Import the TTS package
import 'widgets/speech_button.dart';
import 'services/api_service.dart';
import 'hospitals_page.dart' hide AmbulanceScreen;
import 'find a donor.dart' hide HospitalsPage;
import 'doctors_page.dart' hide HospitalsPage;
import 'home_page.dart';
import 'ambulance_page.dart' hide HospitalsPage;

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final ApiService _apiService = ApiService();
  final TextEditingController _textController = TextEditingController();
  final FlutterTts _flutterTts = FlutterTts(); // Initialize the TTS engine
  String _userText = '';
  String _botResponse = '';
  final bool _isListening = false;
  bool _isSpeaking = false; // Track if TTS is currently speaking
  int _currentIndex = 2; // Set to 2 for the emergency/home button

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
          MaterialPageRoute(builder: (context) => DoctorPage()),
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
  void initState() {
    super.initState();
    requestMicrophonePermission();
    _initTts();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  // Initialize text-to-speech settings
  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5); // Slightly slower for clarity
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setStartHandler(() {
      setState(() {
        _isSpeaking = true;
      });
    });

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });

    _flutterTts.setErrorHandler((message) {
      setState(() {
        _isSpeaking = false;
      });
      print("TTS Error: $message");
    });
  }

  // Function to speak the text
  Future<void> _speak(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  // Function to stop speaking
  Future<void> _stopSpeaking() async {
    await _flutterTts.stop();
    setState(() {
      _isSpeaking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'EMAGE BOT',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Bot info section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.grey[200],
            width: double.infinity,
            child: const Text(
              'EMAGE Quick response\nfirst aid Bot',
              style: TextStyle(fontSize: 16),
            ),
          ),

          // Chat area - adjusted flex ratio to make input lower
          Expanded(
            flex:
                7, // Increased from 5 to 7 to make chat area larger and push input down
            child: Container(
              color: Colors.grey[100],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Instruction bubble
                  Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Type or Speak to chat with EmageBot to overcome your Emergency Situation.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),

                  // User message display
                  if (_userText.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        'You: $_userText',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),

                  // Bot response display with audio controls
                  if (_botResponse.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bot: $_botResponse',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),

                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Play/Pause button for audio
                              IconButton(
                                icon: Icon(
                                  _isSpeaking
                                      ? Icons.pause_circle_filled
                                      : Icons.play_circle_filled,
                                  color: Colors.blue[800],
                                ),
                                onPressed: () {
                                  if (_isSpeaking) {
                                    _stopSpeaking();
                                  } else {
                                    _speak(_botResponse);
                                  }
                                },
                              ),
                              Text(
                                _isSpeaking ? 'Stop Audio' : 'Play Audio',
                                style: TextStyle(
                                  color: Colors.blue[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Input area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Row(
              children: [
                // Text input field
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText:
                          _isListening
                              ? 'Listening. Speak your query'
                              : 'Type to chat',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                  ),
                ),

                // Send button
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.red),
                  onPressed: () {
                    if (_textController.text.isNotEmpty) {
                      _processTextInput(_textController.text);
                    }
                  },
                ),

                // Speech button
                SpeechButton(
                  onTextReceived: (text) {
                    setState(() {
                      _userText = text;
                    });
                  },
                  onResponseReceived: (response) {
                    setState(() {
                      _botResponse = response;
                      // Auto-play the response
                      _speak(response);
                    });
                  },
                ),
              ],
            ),
          ),

          // Empty space below the input area - reduced
          Expanded(
            flex: 0, // Reduced from 1 to 0 to minimize the space below
            child: Container(color: Colors.grey[100]),
          ),
        ],
      ),
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
            color:
                _currentIndex == index
                    ? const Color(0xFFCD1C18)
                    : Colors.black54,
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  // Permission handling function
  Future<void> requestMicrophonePermission() async {
    var status = await Permission.microphone.request();

    if (status.isPermanentlyDenied) {
      debugPrint(
        'Microphone permission permanently denied. Speech recognition will not work.',
      );
    } else if (status.isDenied) {
      debugPrint(
        'Microphone permission denied. Speech recognition will not work.',
      );
    } else {
      debugPrint('Microphone permission granted.');
    }
  }

  void _processTextInput(String text) async {
    setState(() {
      _userText = text;
      _textController.clear();
    });

    try {
      final response = await _apiService.processQuery(text);
      setState(() {
        _botResponse = response.response;
        // Auto-play the response
        _speak(_botResponse);
      });
    } catch (e) {
      print('Error processing text input: $e');
      setState(() {
        _botResponse = 'Sorry, I encountered an error. Please try again.';
        _speak(_botResponse);
      });
    }
  }
}