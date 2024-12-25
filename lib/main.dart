import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:remisse_arequipa_driver/presentation/pages/form/home_form/form_home_screen.dart';
import 'package:remisse_arequipa_driver/presentation/pages/form/home_form/form_home_viewmodel.dart';
import 'package:remisse_arequipa_driver/presentation/pages/landing/landing_screen.dart';
import 'package:remisse_arequipa_driver/presentation/pages/route/generator_screen.dart';
import 'package:sizer/sizer.dart';
import 'package:remisse_arequipa_driver/presentation/pages/auth/login/login_viewmodel.dart';
import 'data/datasources/auth_remote_data_source.dart';
import 'data/datasources/user_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/user_repository_impl.dart';
import 'domain/usecases/form_home_usercase.dart';
import 'domain/usecases/login_usercase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
    final authDataSource = AuthRemoteDataSource(FirebaseAuth.instance);
    final authRepository = AuthRepositoryImpl(authDataSource);
    final loginUseCase = LoginUseCase(authRepository);

    final userDataSource = UserRemoteDataSource(FirebaseAuth.instance);
    final userRepository = UserRepositoryImpl(userDataSource);
    final formHomeUseCase = FormHomeUseCase(userRepository);



    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LoginViewModel(loginUseCase),
        ),
        ChangeNotifierProvider(
          create: (_) => FormHomeViewModel(formHomeUseCase),
        ),

      ],
      child: Sizer(
        builder: (context, orientation, deviceType) {
          return MaterialApp(
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.teal,
                brightness: Brightness.light,
              ),
              fontFamily: 'Roboto',
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.teal,
                brightness: Brightness.dark,
              ),
            ),
            routes: {
              '/': (context) => const GeneratorScreen(),
              '/home': (context) => const LandingScreen(),
            },
          );
        },
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
          return const FormHomeScreen();
        } else {
          return const LandingScreen();
        }
      },
    );
  }
}
