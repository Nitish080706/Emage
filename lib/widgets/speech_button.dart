// lib/widgets/speech_button.dart
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/api_service.dart';

class SpeechButton extends StatefulWidget {
  final Function(String) onTextReceived;
  final Function(String) onResponseReceived;

  const SpeechButton({
    super.key,
    required this.onTextReceived,
    required this.onResponseReceived,
  });

  @override
  _SpeechButtonState createState() => _SpeechButtonState();
}

class _SpeechButtonState extends State<SpeechButton> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  // Initialize speech recognition
  void _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('Speech status: $status'),
      onError: (errorNotification) => print('Speech error: $errorNotification'),
    );
    
    if (!available) {
      print('Speech recognition not available on this device');
      // You could show a snackbar or dialog to inform the user
    }
  }

  // Toggle listening
  void _toggleListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          print('Speech status: $status');
          if (status == 'done') {
            setState(() => _isListening = false);
          }
        },
        onError: (error) => print('Speech error: $error'),
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) async {
            if (result.finalResult) {
              setState(() => _isListening = false);
              
              String recognizedText = result.recognizedWords;
              if (recognizedText.isNotEmpty) {
                widget.onTextReceived(recognizedText);
                
                try {
                  final response = await _apiService.processQuery(recognizedText);
                  widget.onResponseReceived(response.response);
                } catch (e) {
                  print('Error processing voice input: $e');
                  widget.onResponseReceived('Sorry, I encountered an error. Please try again.');
                }
              }
            }
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleListening,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red,
        ),
        child: Icon(
          _isListening ? Icons.mic : Icons.mic_none,
          color: Colors.white,
        ),
      ),
    );
  }
}