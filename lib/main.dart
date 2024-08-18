import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:remisse_arequipa_driver/authentication/login_screen.dart';
import 'package:remisse_arequipa_driver/firebase_options.dart';
import 'package:remisse_arequipa_driver/pages/dashboard.dart';
import 'package:remisse_arequipa_driver/pages/home_page.dart';
import 'package:remisse_arequipa_driver/pages/driver_home_page.dart';

//import 'package:remisse_arequipa/users/Profile_Users.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Permission.locationWhenInUse.isDenied.then((value){
    if(value){
      Permission.locationWhenInUse.request();
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Remisse Arequipa',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
       //home: FirebaseAuth.instance.currentUser == null ? const LoginScreen() : const Dashboard(), 
       home:const LoginScreen() ,// modificar para trabajar con vistas
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Muestra un indicador de carga si está esperando
        } else if (snapshot.hasData) {
          return const HomePage(); // Si el usuario está autenticado, va a HomePage
        } else {
          return const LoginScreen(); // Si no está autenticado, va a LoginScreen
        }
      },
    );
  }
}
 