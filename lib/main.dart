import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:app_links/app_links.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

// 1. MODELOS DE TU BASE DE DATOS (Mover al principio o a un archivo aparte)
class Alumno {
  final int id;
  final String matricula;
  final String nombre;
  final int? salonId;

  Alumno({
    required this.id,
    required this.matricula,
    required this.nombre,
    this.salonId,
  });

  factory Alumno.fromJson(Map<String, dynamic> json) => Alumno(
    id: json['id'],
    matricula: json['matricula'],
    nombre: json['nombre'],
    salonId: json['salon_id'],
  );
}

// 2. SERVICIO DE API
class ApiService {
  final String baseUrl =
      "http://10.0.2.2/api"; // Cambia esto por tu IP real o dominio

  Future<List<Alumno>> getAlumnos() async {
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'auth_token');

    final response = await http.get(
      Uri.parse('$baseUrl/alumnos.php'),
      headers: {
        'Authorization': 'Bearer $token',
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

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Clerk & Escuela API',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _storage = const FlutterSecureStorage();
  final _appLinks = AppLinks();
  StreamSubscription? _linkSubscription;
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
    _checkAuth();
  }

  void _initDeepLinks() {
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) async {
      final token = uri.queryParameters['token'];
      if (token != null) {
        await _storage.write(key: 'auth_token', value: token);
        setState(() => _isAuthenticated = true);
      }
    });
  }

  Future<void> _checkAuth() async {
    String? token = await _storage.read(key: 'auth_token');
    setState(() {
      _isAuthenticated = token != null;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return _isAuthenticated ? const HomePage() : const LoginScreen();
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  final String clerkAuthUrl =
      "https://workable-opossum-70.accounts.dev/sign-in";

  Future<void> _launchClerk() async {
    final Uri url = Uri.parse(clerkAuthUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('No se pudo abrir $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              "Sistema Escolar",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _launchClerk,
              child: const Text("Iniciar Sesión con Clerk"),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Alumnos Registrados"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await const FlutterSecureStorage().delete(key: 'auth_token');
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const AuthGate()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Alumno>>(
        future: ApiService().getAlumnos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No hay alumnos en la base de datos"),
            );
          } else {
            final alumnos = snapshot.data!;
            return ListView.builder(
              itemCount: alumnos.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(alumnos[index].id.toString()),
                  ),
                  title: Text(alumnos[index].nombre),
                  subtitle: Text("Matrícula: ${alumnos[index].matricula}"),
                  trailing: Chip(
                    label: Text("Salón ${alumnos[index].salonId}"),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
