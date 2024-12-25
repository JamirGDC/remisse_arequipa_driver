import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remisse_arequipa_driver/main.dart';
import 'package:remisse_arequipa_driver/presentation/pages/home/home_page.dart';
import 'package:sizer/sizer.dart';
import '../../../../views/auth/signup_screen.dart';
import '../../../widgets/input_text_field.dart';
import 'login_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    emailController.addListener(_checkFormValidity);
    passwordController.addListener(_checkFormValidity);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _checkFormValidity() {
    final isFormValid = emailController.text.isNotEmpty && passwordController.text.isNotEmpty;
    if (isFormValid != isButtonEnabled) {
      setState(() {
        isButtonEnabled = isFormValid;
      });
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(''),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back, size: 3.6.h),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Bienvenido De Nuevo!',
                  style: TextStyle(
                    fontSize: 23.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Vamos a Iniciar Sesión',
                  style: TextStyle(
                    fontSize: 21.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  'Introduce tu email y contraseña para continuar',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 10.h),
                InputTextField(
                  controller: emailController,
                  labelText: 'Email',
                  obscureText: false,
                  icon: const Icon(Icons.mail_outline),
                ),
                const SizedBox(height: 16),
                InputTextField(
                  controller: passwordController,
                  labelText: 'Contraseña',
                  obscureText: true,
                  icon: const Icon(Icons.lock_open_outlined),
                ),
                Expanded(child: SizedBox(height: 1.h)),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  onPressed: isButtonEnabled
                      ? () async {
                    final success = await viewModel.login(
                      emailController.text,
                      passwordController.text,
                    );
                    if (success) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const AuthWrapper()),
                            (Route<dynamic> route) => false,
                      );

                    }
                    else
                      {
                        final errorMessage =
                        viewModel.getErrorMessage(viewModel.errorMessage ?? '');
                        showErrorDialog(errorMessage);
                      }
                  }
                      : null,
                  child: viewModel.isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Iniciar Sesión'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignupScreen(),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Aún No Tienes Cuenta?',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Registrate',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
