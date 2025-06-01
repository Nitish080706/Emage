// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/emergency_response.dart';

class ApiService {
  // Change this URL to match your Flask backend
  // For Android Emulator
  final String baseUrl = 'http://192.168.22.31:5000';
  // Use 'http://localhost:5000' for iOS simulator or 'http://<your-machine-ip>:5000' for real devices

  Future<EmergencyResponse> processQuery(String query) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/process_query'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'query': query}),
    );

    if (response.statusCode == 200) {
      return EmergencyResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to process query: ${response.statusCode}');
    }
  }
}
