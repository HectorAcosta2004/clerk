import 'package:flutter/material.dart';
import 'package:flutter_basico/components/auth_supabase.dart';
import 'package:flutter_basico/components/supabase/home_screen.dart';
import 'package:flutter_basico/components/supabase/login_screen.dart';
//import 'package:flutter_basico/layouts/login.dart';
//import 'package:flutter_basico/components/Texto_Ejemplo.dart';
//import 'package:flutter_basico/layouts/PantallaTarea.dart';
//import 'package:flutter_basico/layouts/Columnas_Ejemplo.dart';
//import 'package:flutter_basico/layouts/Filas_Ejemplo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://bomogmlfwixgreabnpww.supabase.co',
    anonKey: 'sb_publishable_m8qiqIcS6jlnvXlQ6mIsQg_t9yT4quC',
  );
  runApp(MainApp());
}

final supabase = Supabase.instance.client;

class MainApp extends StatelessWidget {
  MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Supabase Auth',
      // 2. Escucha el estado de la sesión
      home: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          final session = snapshot.data?.session;
          if (session != null) {
            return const HomeScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
