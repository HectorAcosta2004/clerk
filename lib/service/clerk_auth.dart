import 'package:http/http.dart' as http;

class ClerkService {
  final String publishableKey =
      "pk_test_d29ya2FibGUtb3Bvc3N1bS03MC5jbGVyay5hY2NvdW50cy5kZXYk";

  Future<bool> checkSession(String sessionToken) async {
    final response = await http.get(
      Uri.parse('https://api.clerk.com/v1/sessions'),
      headers: {
        'Authorization': 'Bearer $sessionToken',
        'Content-Type': 'application/json',
      },
    );
    return response.statusCode == 200;
  }
}
