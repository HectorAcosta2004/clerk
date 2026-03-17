import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final String baseUrl = "http://172.16.97.154"; // Ejemplo: http://10.0.2.2/api
  final _storage = const FlutterSecureStorage();

  Future<List<Alumno>> getAlumnos() async {
    String? token = await _storage.read(key: 'auth_token');

    final response = await http.get(
      Uri.parse('$baseUrl/alumnos.php'),
      headers: {
        'Authorization': 'Bearer $token', // Protección con Clerk
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Alumno.fromJson(data)).toList();
    } else {
      throw Exception('Error al cargar alumnos');
    }
  }
}
