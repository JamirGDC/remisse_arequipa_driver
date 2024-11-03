import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:remisse_arequipa_driver/authentication/signup_screen.dart';
import 'package:remisse_arequipa_driver/methods/common_methods.dart';
import 'package:remisse_arequipa_driver/pages/dashboard.dart';
import 'package:sizer/sizer.dart';

class LoginScreen extends StatefulWidget 
{
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin 
{
    var focusNodeEmail = FocusNode();
    var focusNodePassword = FocusNode();
    bool isFocusedEmail = false;
    bool isFocusedPassword = false;

    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
    CommonMethods cMethods = CommonMethods();

  signInDriver() {
    cMethods.checkConnectivity(context);
    signIn();
  }

  Future<void> signIn() async {
  showDialog(
    context: context,
    builder: (context) {
      return const Center(child: CircularProgressIndicator());
    },
  );

  try {
    final User? userFirebase = (await FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            ))
        .user;

    if (userFirebase != null) {
      DatabaseReference usersRef = FirebaseDatabase.instance
          .ref()
          .child("drivers")
          .child(userFirebase.uid);
          usersRef.once().then((snap) {
          if (snap.snapshot.value != null) {
            if ((snap.snapshot.value as Map)["blockStatus"] == "no") {
              if(!mounted)return;
              Navigator.push(
                  context, MaterialPageRoute(builder: (c) => const Dashboard()));
            } else {
              FirebaseAuth.instance.signOut();
              if(!mounted)return;
              cMethods.showTopAlert(context, this,
                  "Esta cuenta esta bloqueada. Contacta con el administrador.");
            }
        } else {
          FirebaseAuth.instance.signOut();
          if(!mounted) return;

              Navigator.pop(context);
              cMethods.showTopAlert(context, this, 
              "Tu usuario o contraseña no son correctos.");
        }
      });
    }

  } on FirebaseAuthException catch (errorMsg) 
  {
    if(errorMsg.code == "invalid-credential")
      {
        if (!mounted) return;
        Navigator.pop(context);
        cMethods.showTopAlert(context, this, "Tu usuario o contraseña no son correctos.");
      }
      else
      {
        if (!mounted) return;
        Navigator.pop(context);
        cMethods.showTopAlert(context, this, errorMsg.toString());
      }
    
  }
}
  @override
  void initState() {
    focusNodeEmail.addListener(() {
      setState(() {
        isFocusedEmail = focusNodeEmail.hasFocus;
      });
    });
    focusNodePassword.addListener(() {
      setState(() {
        isFocusedPassword = focusNodePassword.hasFocus;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
              child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              height: 100.h,
              decoration: const BoxDecoration(color: Colors.white),
              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 5.h,
                  ),
                  FadeInDown(
                    delay: const Duration(milliseconds: 900),
                    duration: const Duration(milliseconds: 1000),
                    child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          IconlyBroken.arrow_left,
                          size: 3.6.h,
                        )),
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
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
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  FadeInDown(
                    delay: const Duration(milliseconds: 700),
                    duration: const Duration(milliseconds: 800),
                    child: const Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  FadeInDown(
                    delay: const Duration(milliseconds: 600),
                    duration: const Duration(milliseconds: 700),
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 0.8.h),
                      padding:
                          EdgeInsets.symmetric(horizontal: 5.w, vertical: .3.h),
                      decoration: BoxDecoration(
                          color: isFocusedEmail
                              ? Colors.white
                              : const Color(0xFFF1F0F5),
                          border: Border.all(
                              width: 1, color: const Color(0xFFD2D2D4)),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            if (isFocusedEmail)
                              BoxShadow(
                                  color:
                                      const Color(0xFF835DF1).withOpacity(.3),
                                  blurRadius: 4.0,
                                  spreadRadius: 2.0
                                  // Glow Color
                                  )
                          ]),
                      child: TextField(
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        decoration: const InputDecoration(
                            border: InputBorder.none, hintText: 'Tu Email'),
                        focusNode: focusNodeEmail,
                        controller: _emailController,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  FadeInDown(
                    delay: const Duration(milliseconds: 500),
                    duration: const Duration(milliseconds: 600),
                    child: const Text(
                      'Contraseña',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  FadeInDown(
                    delay: const Duration(milliseconds: 400),
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 0.8.h),
                      padding:
                          EdgeInsets.symmetric(horizontal: 5.w, vertical: .3.h),
                      decoration: BoxDecoration(
                          color: isFocusedPassword
                              ? Colors.white
                              : const Color(0xFFF1F0F5),
                          border: Border.all(
                              width: 1, color: const Color(0xFFD2D2D4)),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            if (isFocusedPassword)
                              BoxShadow(
                                  color:
                                      const Color(0xFF835DF1).withOpacity(.3),
                                  blurRadius: 4.0,
                                  spreadRadius: 2.0
                                  // Glow Color
                                  )
                          ]),
                      child: TextField(
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                            suffixIcon: Icon(
                              Icons.visibility_off_outlined,
                              color: Colors.grey,
                              size: 16.sp,
                            ),
                            border: InputBorder.none,
                            hintText: 'Contraseña'),
                        focusNode: focusNodePassword,
                        controller: _passwordController,
                      ),
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
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              signInDriver();
                            },
                            style: ElevatedButton.styleFrom(
                                elevation: 0,
                                textStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Satoshi'),
                                backgroundColor: const Color(0xFF835DF1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16)),
                            child: FadeInUp(
                                delay: const Duration(milliseconds: 700),
                                duration: const Duration(milliseconds: 800),
                                child: const Text('Sign In')),
                          ),
                        )
                      ],
                    ),
                  ),
                  FadeInUp(
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
                                    builder: (context) => const SignupScreen(),
                                  ));
                            },
                            child: const Text(
                              'Registrate',
                              style: TextStyle(
                                color: Color(0xFF835DF1),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ))
                      ],
                    ),
                  )
                ],
              ),
            ),
          ))
        ],
      ),
    );
  }
}
