// lib/models/emergency_response.dart
class EmergencyResponse {
  final String response;
  final String match;
  final double score;

  EmergencyResponse({
    required this.response,
    required this.match,
    required this.score,
  });

  factory EmergencyResponse.fromJson(Map<String, dynamic> json) {
    return EmergencyResponse(
      response: json['response'] ?? 'No response available',
      match: json['match'] ?? 'No match found',
      score: json['score']?.toDouble() ?? 0.0,
    );
  }
}