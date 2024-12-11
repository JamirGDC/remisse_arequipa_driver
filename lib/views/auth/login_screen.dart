import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remisse_arequipa_driver/global.dart';
import 'package:remisse_arequipa_driver/methods/common_methods.dart';
import 'package:remisse_arequipa_driver/views/home_page.dart';
import 'package:remisse_arequipa_driver/views/auth/signup_screen.dart';
import 'package:sizer/sizer.dart';
import '../../viewmodels/auth/login_viewmodel.dart';
import '../../components/button_main.dart';
import '../../components/input_main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin 
{
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  CommonMethods cMethods = CommonMethods();

  var focusNodeEmail = FocusNode();
  var focusNodePassword = FocusNode();
  bool isFocusedEmail = false;
  bool isFocusedPassword = false;

  Future<void> signInDriver(context, loginViewModel, child) async {
    cMethods.checkConnectivity(context);

    await loginViewModel.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (!mounted) return;

    if (loginViewModel.user != null) {
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else if (loginViewModel.errorMessage != null) {
      cMethods.showTopAlert(context, this, loginViewModel.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<LoginViewModel>(
        builder: (context, loginViewModel, child) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Container(
                    height: 100.h,
                    padding:
                        EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 5.h),
                        FadeInDown(
                          delay: const Duration(milliseconds: 900),
                          duration: const Duration(milliseconds: 1000),
                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.arrow_back, size: 3.6.h),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FadeInDown(
                                delay: const Duration(milliseconds: 800),
                                duration: const Duration(milliseconds: 900),
                                child: Text(
                                  'Bienvenido De Nuevo!',
                                  style: TextStyle(
                                    fontSize: 23.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 1.h,
                              ),
                              FadeInDown(
                                delay: const Duration(milliseconds: 700),
                                duration: const Duration(milliseconds: 800),
                                child: Text(
                                  'Vamos a Iniciar Sesión',
                                  style: TextStyle(
                                    fontSize: 21.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              FadeInDown(
                                delay: const Duration(milliseconds: 600),
                                duration: const Duration(milliseconds: 700),
                                child: Text(
                                  'Introduce tu email y contraseña para continuar',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              )
                            ]),
                        SizedBox(
                          height: 5.h,
                        ),
                        FadeInDown(
                          delay: const Duration(milliseconds: 700),
                          duration: const Duration(milliseconds: 800),
                          child: InputMain(
                            hintText: 'usuario@app.com',
                            labelText: 'Email',
                            controller: emailController,
                            focusNode: focusNodeEmail,
                            isFocused: isFocusedEmail,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        FadeInDown(
                          delay: const Duration(milliseconds: 700),
                          duration: const Duration(milliseconds: 800),
                          child: InputMain(
                            hintText: '**********',
                            labelText: 'Contraseña',
                            controller: passwordController,
                            focusNode: focusNodePassword,
                            isFocused: isFocusedPassword,
                          ),
                        ),
                        const Expanded(
                            child: SizedBox(
                          height: 10,
                        )),

                        FadeInUp(
                          delay: const Duration(milliseconds: 600),
                          duration: const Duration(milliseconds: 700),

                          child: Row(
                            children: [
                              Expanded(child: ButtonMain(
                                    text: 'Continuar',
                                    onPressed: () => signInDriver(context, loginViewModel, child),
                                  ),
                                ), 
                            ]   
                          )  
                          
                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SignupScreen()),
                              );
                            },
                            child: FadeInUp(
                              delay: const Duration(milliseconds: 800),
                              duration: const Duration(milliseconds: 900),
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
                                              builder: (context) =>
                                                  const SignupScreen(),
                                            ));
                                      },
                                      child: const Text(
                                        'Registrate',
                                        style: TextStyle(
                                          color: brandColor,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ))
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
