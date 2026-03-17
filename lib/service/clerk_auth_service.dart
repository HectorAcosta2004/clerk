import 'dart:convert';
import 'package:http/http.dart' as http;

class ClerkAuthService {
  final String _baseUrl = "https://api.clerk.com/v1";

  // Usa el Secret Key de tu dashboard (mantenlo privado)
  final String _secretKey =
      "sk_test_IbcmbNY1hg03BM071i3ppGQjFinDTV5pJnlqEtSKrl";

  Future<Map<String, dynamic>?> getUserProfile(String sessionToken) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/me'),
      headers: {
        'Authorization': 'Bearer $sessionToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }
}
