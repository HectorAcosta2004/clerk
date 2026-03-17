import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:app_links/app_links.dart'; // Importante
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Clerk Flutter Auth',
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

  // CONFIGURACIÓN PARA CAPTURAR EL TOKEN DE CLERK
  void _initDeepLinks() {
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) async {
      // Supongamos que Clerk devuelve el token en un parámetro llamado 'token'
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
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return _isAuthenticated ? const HomePage() : const LoginScreen();
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  // RECUERDA: Cambia esto por tu URL real de Clerk
  final String clerkAuthUrl = "https://tu-dominio.clerk.accounts.dev/sign-in";

  Future<void> _launchClerk() async {
    final Uri url = Uri.parse(clerkAuthUrl);
    // mode: LaunchMode.externalApplication es vital para que funcione el Deep Linking
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
            const Icon(Icons.lock_outline, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              "Bienvenido",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _launchClerk,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
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
        title: const Text("Mi App Protegida"),
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
      body: const Center(
        child: Text("¡Felicidades, Hector! Estás autenticado con Clerk."),
      ),
    );
  }
}
