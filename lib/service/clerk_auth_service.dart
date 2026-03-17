// lib/services/clerk_auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ClerkAuthService {
  final String _baseUrl = "https://api.clerk.com/v1";

  Future<Map<String, dynamic>?> fetchMe(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }
}
