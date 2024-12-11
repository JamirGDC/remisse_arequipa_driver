import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:remisse_arequipa_driver/components/button_secondary.dart';
import 'package:remisse_arequipa_driver/global.dart';
import 'package:remisse_arequipa_driver/methods/common_methods.dart';
import 'package:remisse_arequipa_driver/views/home_page.dart';
import 'package:remisse_arequipa_driver/viewmodels/auth/signup_viewmodel.dart';
import 'package:remisse_arequipa_driver/views/auth/login_screen.dart';
import 'package:sizer/sizer.dart';
import '../../components/button_main.dart';
import '../../components/input_main.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _carModelController = TextEditingController();
  final TextEditingController _carColorController = TextEditingController();
  final TextEditingController _carPlateController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  var focusNodeEmail = FocusNode();
  var focusNodePassword = FocusNode();
  var focusNodeName = FocusNode();
  var focusNodeCarModel = FocusNode();
  var focusNodeCarColor = FocusNode();
  var focusNodeCarPlate = FocusNode();
  var focusNodePhone = FocusNode();

  bool isFocusedEmail = false;
  bool isFocusedPassword = false;
  bool isFocusedName = false;
  bool isFocusedCarModel = false;
  bool isFocusedCarColor = false;
  bool isFocusedCarPlate = false;
  bool _isPasswordVisible = false;
  bool isFocusedPhone = false;

  XFile? imageFile;

  int _currentPage = 0;
  CommonMethods cMethods = CommonMethods();
  String urlOfUploadedImage = "";

  void _nextPage(SignupViewmodel signupViewModel) {
  String errorMessage = '';

  switch (_currentPage) {
    case 0:
      if (_emailController.text.isEmpty) {
        errorMessage = 'El campo de email está vacío. Por favor, ingresa tu email para continuar.';
      }
      break;
    case 1:
      if (_phoneController.text.isEmpty) {
        errorMessage = 'El campo de telefono está vacío. Por favor, ingresa un Telefono Valido para continuar.';
      }
      break;
    case 2:
      if (_nameController.text.isEmpty) {
        errorMessage = 'El campo de nombre está vacío. Por favor, ingresa tu nombre para continuar.';
      }
      break;
    case 3:
      if (_carPlateController.text.isEmpty ||
          _carModelController.text.isEmpty ||
          _carColorController.text.isEmpty) {
        errorMessage = 'Por favor, completa todos los campos del vehículo para continuar';
      }
      break;
    case 4:
      if (signupViewModel.profileImage == null) {
        errorMessage = 'Por favor, sube imagen para continuar.';
      }
      break;
    case 5:
      if (_passwordController.text.isEmpty) {
        errorMessage = 'Por favor introduce una contraseña valida';
      }
      break;
  }

  if (errorMessage.isNotEmpty) {
    cMethods.showTopAlert(context, this, errorMessage);
  } else {
    if (_currentPage < 5) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }
}


  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.animateToPage(
        _currentPage - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  Future<void> signInDriver(context, signupViewModel, child) async {
    cMethods.checkConnectivity(context);

    await signupViewModel.signUp(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _nameController.text.trim(),
      _phoneController.text.trim(),
      _carModelController.text.trim(),
      _carColorController.text.trim(),
      _carPlateController.text.trim(),
      signupViewModel.profileImage,
    );

    if (!mounted) return;

    if (signupViewModel.user != null) {
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else if (signupViewModel.errorMessage != null) {
      cMethods.showTopAlert(context, this, signupViewModel.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body:
        Consumer<SignupViewmodel>(builder: (context, signupViewModel, child) {
      return Column(
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
                    SizedBox(height: 5.h),
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
                        ),
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
                            'Bienvenido!',
                            style: TextStyle(
                              fontSize: 23.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: 1.h),
                        FadeInDown(
                          delay: const Duration(milliseconds: 700),
                          duration: const Duration(milliseconds: 800),
                          child: Text(
                            'Vamos a Registrarte',
                            style: TextStyle(
                              fontSize: 21.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        FadeInDown(
                          delay: const Duration(milliseconds: 700),
                          duration: const Duration(milliseconds: 800),
                          child: LinearProgressIndicator(
                            value: (_currentPage + 1) / 6,
                          ),
                        ),
                      ],
                    ),
                    Flexible(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (int page) {
                          setState(() {
                            _currentPage = page;
                          });
                        },
                        children: [
                          _buildEmailInput(),
                          _buildPhoneInput(),
                          _buildNameInput(),
                          _buildCarInput(),
                          _buildPhotoInput(),
                          _buildPasswordInput(),
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
                            '¿Ya tienes Cuenta?',
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
                                      builder: (context) => const LoginScreen(),
                                    ));
                              },
                              child: const Text(
                                'Iniciar Sesión',
                                style: TextStyle(
                                  color: brandColor,
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
            ),
          ),
        ],
      );
    }));
  }

  Widget _buildEmailInput() {
    return
    
    Scaffold(
      body: Consumer<SignupViewmodel>(
        builder: (context, signupViewModel, child) {
          return
          Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 1.h,
        ),
        FadeInDown(
          delay: const Duration(milliseconds: 700),
          duration: const Duration(milliseconds: 800),
          child: InputMain(
            hintText: 'usuario@app.com',
            labelText: 'Introduce tu Email para Continuar',
            controller: _emailController,
            focusNode: focusNodeEmail,
            isFocused: isFocusedEmail,
          ),
        ),
        SizedBox(
          height: 2.h,
        ),
        FadeInUp(
            delay: const Duration(milliseconds: 600),
            duration: const Duration(milliseconds: 700),
            child: Row(children: [
              Expanded(
                child: ButtonMain(
                  text: 'Continuar',
                  onPressed: () => _nextPage(signupViewModel),
                ),
              ),
            ]))
      ],
    );
        }
      )  );  
    
    
    
     
  }

  Widget _buildPhoneInput() {
    return 
    Scaffold(
      body: Consumer<SignupViewmodel>(
        builder: (context, signupViewModel, child) {
          return
          Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 1.h,
        ),
        FadeInDown(
          delay: const Duration(milliseconds: 700),
          duration: const Duration(milliseconds: 800),
          child: InputMain(
            hintText: '+51 95 9 110 619',
            labelText: 'Introduce un Numero de telefono para Continuar',
            controller: _phoneController,
            focusNode: focusNodePhone,
            isFocused: isFocusedPhone,
          ),
        ),
        SizedBox(
          height: 2.h,
        ),
        FadeInUp(
          delay: const Duration(milliseconds: 600),
          duration: const Duration(milliseconds: 700),
          child: Row(
            children: [
              Expanded(
                child: FadeInUp(
                  delay: const Duration(milliseconds: 600),
                  duration: const Duration(milliseconds: 700),
                  child: ButtonSecondary(
                    text: 'Volver',
                    onPressed: _previousPage,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FadeInUp(
                  delay: const Duration(milliseconds: 600),
                  duration: const Duration(milliseconds: 700),
                  child: ButtonMain(
                    text: 'Siguiente',
                    onPressed: () => _nextPage(signupViewModel),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
        }
      )  ); 
    
    
    
  }

  Widget _buildNameInput() {
    return 
    Scaffold(
      body: Consumer<SignupViewmodel>(
        builder: (context, signupViewModel, child) {
          return
          Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 1.h,
        ),
        FadeInDown(
          delay: const Duration(milliseconds: 700),
          duration: const Duration(milliseconds: 800),
          child: InputMain(
            hintText: 'Nombre y Apellidos',
            labelText: 'Introduce tu Nombre y Apellido',
            controller: _nameController,
            focusNode: focusNodeName,
            isFocused: isFocusedName,
          ),
        ),
        SizedBox(
          height: 2.h,
        ),
        FadeInUp(
          delay: const Duration(milliseconds: 600),
          duration: const Duration(milliseconds: 700),
          child: Row(
            children: [
              Expanded(
                child: FadeInUp(
                  delay: const Duration(milliseconds: 600),
                  duration: const Duration(milliseconds: 700),
                  child: ButtonSecondary(
                    text: 'Volver',
                    onPressed: _previousPage,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FadeInUp(
                  delay: const Duration(milliseconds: 600),
                  duration: const Duration(milliseconds: 700),
                  child: ButtonMain(
                    text: 'Siguiente',
                    onPressed: () => _nextPage(signupViewModel),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
        }
      )  ); 
    
    
    
  }

  Widget _buildCarInput() {
    return
    Scaffold(
      body: Consumer<SignupViewmodel>(
        builder: (context, signupViewModel, child) {
          return
          Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 1.h,
        ),
        FadeInDown(
          delay: const Duration(milliseconds: 700),
          duration: const Duration(milliseconds: 800),
          child: const Text(
            'Introduce Placa, Modelo y Color de tu Vehículo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(
          height: 2.h,
        ),
        FadeInDown(
          delay: const Duration(milliseconds: 600),
          duration: const Duration(milliseconds: 700),
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 0.8.h),
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: .3.h),
            decoration: BoxDecoration(
                color:
                    isFocusedCarPlate ? Colors.white : const Color(0xFFF1F0F5),
                border: Border.all(width: 1, color: const Color(0xFFD2D2D4)),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  if (isFocusedCarPlate)
                    BoxShadow(
                        color: const Color(0xFF835DF1).withOpacity(.3),
                        blurRadius: 4.0,
                        spreadRadius: 2.0)
                ]),
            child: TextField(
              style: const TextStyle(fontWeight: FontWeight.w500),
              decoration: const InputDecoration(
                  border: InputBorder.none, hintText: 'Placa de Vehículo'),
              focusNode: focusNodeCarPlate,
              controller: _carPlateController,
            ),
          ),
        ),
        FadeInDown(
          delay: const Duration(milliseconds: 600),
          duration: const Duration(milliseconds: 700),
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 0.8.h),
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: .3.h),
            decoration: BoxDecoration(
                color:
                    isFocusedCarModel ? Colors.white : const Color(0xFFF1F0F5),
                border: Border.all(width: 1, color: const Color(0xFFD2D2D4)),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  if (isFocusedCarModel)
                    BoxShadow(
                        color: const Color(0xFF835DF1).withOpacity(.3),
                        blurRadius: 4.0,
                        spreadRadius: 2.0)
                ]),
            child: TextField(
              style: const TextStyle(fontWeight: FontWeight.w500),
              decoration: const InputDecoration(
                  border: InputBorder.none, hintText: 'Modelo de Vehículo'),
              focusNode: focusNodeCarModel,
              controller: _carModelController,
            ),
          ),
        ),
        FadeInDown(
          delay: const Duration(milliseconds: 600),
          duration: const Duration(milliseconds: 700),
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 0.8.h),
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: .3.h),
            decoration: BoxDecoration(
                color:
                    isFocusedCarColor ? Colors.white : const Color(0xFFF1F0F5),
                border: Border.all(width: 1, color: const Color(0xFFD2D2D4)),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  if (isFocusedCarColor)
                    BoxShadow(
                        color: const Color(0xFF835DF1).withOpacity(.3),
                        blurRadius: 4.0,
                        spreadRadius: 2.0
                        // Glow Color
                        )
                ]),
            child: TextField(
              style: const TextStyle(fontWeight: FontWeight.w500),
              decoration: const InputDecoration(
                  border: InputBorder.none, hintText: 'Color de Vehículo'),
              focusNode: focusNodeCarColor,
              controller: _carColorController,
            ),
          ),
        ),
        SizedBox(
          height: 2.h,
        ),
        FadeInUp(
          delay: const Duration(milliseconds: 600),
          duration: const Duration(milliseconds: 700),
          child: Row(
            children: [
              Expanded(
                child: FadeInUp(
                  delay: const Duration(milliseconds: 600),
                  duration: const Duration(milliseconds: 700),
                  child: ButtonSecondary(
                    text: 'Volver',
                    onPressed: _previousPage,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FadeInUp(
                  delay: const Duration(milliseconds: 600),
                  duration: const Duration(milliseconds: 700),
                  child: ButtonMain(
                    text: 'Siguiente',
                    onPressed: () => _nextPage(signupViewModel),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
        }
      )  ); 
    
    
     
  }

  Widget _buildPhotoInput() {
    return Consumer<SignupViewmodel>(
      builder: (context, signupViewModel, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 5.h,
            ),
            FadeInDown(
              delay: const Duration(milliseconds: 700),
              duration: const Duration(milliseconds: 800),
              child: const Text(
                'Sube una Foto de Perfil',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              height: 2.h,
            ),
            FadeInDown(
              delay: const Duration(milliseconds: 600),
              duration: const Duration(milliseconds: 700),
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 0.8.h),
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: .3.h),
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border:
                        Border.all(width: 1, color: const Color(0xFFD2D2D4)),
                    borderRadius: BorderRadius.circular(12)),
                child: signupViewModel.profileImage == null
                    ? const CircleAvatar(
                        radius: 86,
                        backgroundImage:
                            AssetImage("lib/assets/profileuser.png"),
                      )
                    : CircleAvatar(
                        radius: 86,
                        backgroundImage:
                            FileImage(File(signupViewModel.profileImage!.path)),
                      ),
              ),
            ),
            FadeInDown(
              delay: const Duration(milliseconds: 600),
              duration: const Duration(milliseconds: 700),
              child: GestureDetector(
                onTap: signupViewModel.chooseImageFromGallery,
                child: const Text(
                  "Elegir Imagen",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 2.h,
            ),
            FadeInUp(
              delay: const Duration(milliseconds: 600),
              duration: const Duration(milliseconds: 700),
              child: Row(
                children: [
                  Expanded(
                    child: ButtonSecondary(
                      text: 'Volver',
                      onPressed: _previousPage,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ButtonMain(
                      text: 'Siguiente',
                      onPressed: () => _nextPage(signupViewModel),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPasswordInput() {
    return Scaffold(body:
        Consumer<SignupViewmodel>(builder: (context, signupViewModel, child) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 20,
          ),
          FadeInDown(
            delay: const Duration(milliseconds: 700),
            duration: const Duration(milliseconds: 800),
            child: const Text(
              'Introduce tu Contraseña',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          FadeInDown(
            delay: const Duration(milliseconds: 600),
            duration: const Duration(milliseconds: 700),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color:
                    isFocusedPassword ? Colors.white : const Color(0xFFF1F0F5),
                border: Border.all(width: 1, color: const Color(0xFFD2D2D4)),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  if (isFocusedPassword)
                    BoxShadow(
                      color: const Color(0xFF835DF1).withOpacity(.3),
                      blurRadius: 4.0,
                      spreadRadius: 2.0,
                    )
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _passwordController,
                      focusNode: focusNodePassword,
                      obscureText: !_isPasswordVisible,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Contraseña',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          FadeInUp(
            delay: const Duration(milliseconds: 600),
            duration: const Duration(milliseconds: 700),
            child: Row(
              children: [
                Expanded(
                  child: FadeInUp(
                    delay: const Duration(milliseconds: 600),
                    duration: const Duration(milliseconds: 700),
                    child: ButtonSecondary(
                      text: 'Volver',
                      onPressed: _previousPage,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FadeInUp(
                    delay: const Duration(milliseconds: 600),
                    duration: const Duration(milliseconds: 700),
                    child: ButtonMain(
                      text: 'Finalizar',
                      onPressed: () =>
                          signInDriver(context, signupViewModel, child),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }));
  }
}
