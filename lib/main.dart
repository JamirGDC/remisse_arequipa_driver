import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:remisse_arequipa_driver/authentication/signup_screen.dart';
import 'package:remisse_arequipa_driver/authentication/welcome.dart';
import 'package:remisse_arequipa_driver/pages/Form/FormChecklist.dart';
import 'package:remisse_arequipa_driver/pages/Form/form_home_page.dart';
import 'package:remisse_arequipa_driver/pages/check_list_page.dart';
import 'package:remisse_arequipa_driver/pages/create_questions.dart';
import 'package:remisse_arequipa_driver/pages/dashboard.dart';
import 'package:remisse_arequipa_driver/pages/driver_home_page.dart';
import 'package:remisse_arequipa_driver/pages/home_page.dart';
import 'package:remisse_arequipa_driver/pages/providers/formprovider.dart';
import 'package:remisse_arequipa_driver/pages/providers/timerWorckdriver.dart';
import 'authentication/login_screen.dart';
import 'package:remisse_arequipa_driver/pages/drivermainscreen.dart';
import 'package:provider/provider.dart';


import 'package:sizer/sizer.dart';

Future<void> main() async
{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await Permission.locationWhenInUse.isDenied.then((valueOfPermission)
  {
    if(valueOfPermission)
    {
      Permission.locationWhenInUse.request();
    }
  });

  await Permission.notification.isDenied.then((valueOfPermission)
  {
    if(valueOfPermission)
    {
      Permission.notification.request();
    }
  });

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
Widget build(BuildContext context) {
  return Sizer(
    builder: (context, orientation, deviceType) => MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_)=> Timerworckdriver()),
        ChangeNotifierProvider(create: (_)=> Formprovider()),
      ],
      child: MaterialApp(
        theme: ThemeData(
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
            '/dashboard': (context) => const Dashboard(),
            '/driverHomePage': (context) => const DriverHomePage(),
            '/formHomePage': (context) => const FormHomePage(),  // Ruta hacia la página del formulario
            '/formChecklist': (context) => const Formchecklist(), // Ruta hacia la checklist
            '/driverMainScreen': (context) => const DriverMainScreen(),
            '/createquestions': (context) =>   CreateQuestions(),
        }  ,
        //home: FirebaseAuth.instance.currentUser == null ? const SignupScreen() : const Dashboard(),

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
          return const CircularProgressIndicator(); 
        } else if (snapshot.hasData) {
          return const FormHomePage(); 
        } else {
          return const WelcomePage(); 
        }
      },
    );
  }
}
