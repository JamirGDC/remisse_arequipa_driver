import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:remisse_arequipa_driver/views/form/form_home_page.dart';
import 'package:remisse_arequipa_driver/viewmodels/auth/signup_viewmodel.dart';
import 'package:remisse_arequipa_driver/views/profile/profile_screen.dart';
import 'package:remisse_arequipa_driver/views/auth/signup_screen.dart';
import 'package:remisse_arequipa_driver/views/welcome_screen.dart';
import 'package:sizer/sizer.dart';
import 'package:remisse_arequipa_driver/views/form/form_check_list.dart';
import 'package:remisse_arequipa_driver/pages/create_questions.dart';
import 'package:remisse_arequipa_driver/pages/driver_home_page.dart';
import 'package:remisse_arequipa_driver/views/home_page.dart';
import 'package:remisse_arequipa_driver/viewmodels/form/formprovider.dart';
import 'package:remisse_arequipa_driver/viewmodels/form/timerWorckdriver.dart';
import 'package:remisse_arequipa_driver/viewmodels/auth/login_viewmodel.dart';
import 'package:remisse_arequipa_driver/pages/drivermainscreen.dart';
import 'package:remisse_arequipa_driver/views/auth/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Manejo asíncrono de permisos
  if (await Permission.locationWhenInUse.isDenied) {
    await Permission.locationWhenInUse.request();
  }

  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => Timerworckdriver()),
          ChangeNotifierProvider(create: (_) => Formprovider()),
          ChangeNotifierProvider(create: (_) => LoginViewModel()),
          ChangeNotifierProvider(create: (_) => SignupViewmodel()),


        ],
        child: MaterialApp(
          theme: ThemeData(
            fontFamily: 'Roboto',
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.grey,
            ).copyWith(
              primary: Colors.black,
              secondary: Colors.black,
            ),
            useMaterial3: true,
          ),
          routes: {
            '/HomePage': (context) => const HomePage(),
            '/signup': (context) => const SignupScreen(),
            '/login': (context) => const LoginScreen(),
            '/driverHomePage': (context) => const DriverHomePage(),
            '/formHomePage': (context) => const FormHomePage(),
            '/formChecklist': (context) => const Formchecklist(),
            '/driverMainScreen': (context) => const DriverMainScreen(),
            '/createquestions': (context) => const CreateQuestions(),
            '/Profile': (context) => const ProfilePage(),

          },
          home: const AuthWrapper(),
        ),
      ),
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
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text("Ha ocurrido un error"));
        } else if (snapshot.hasData) {
          return const FormHomePage(); 
        } else {
          return const WelcomePage(); 
        }
      },
    );
  }
}
