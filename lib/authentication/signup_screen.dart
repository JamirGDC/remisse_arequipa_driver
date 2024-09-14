import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:image_picker/image_picker.dart';
import 'package:remisse_arequipa_driver/methods/common_methods.dart';
import 'package:sizer/sizer.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with TickerProviderStateMixin{
  final PageController _pageController = PageController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _carModelController = TextEditingController();
  final TextEditingController _carColorController = TextEditingController();
  final TextEditingController _carPlateController = TextEditingController();

  var focusNodeEmail = FocusNode();
  var focusNodePassword = FocusNode();
  var focusNodeName = FocusNode();
  var focusNodeCarModel = FocusNode();
  var focusNodeCarColor = FocusNode();
  var focusNodeCarPlate = FocusNode();

  bool isFocusedEmail = false;
  bool isFocusedPassword = false;
  bool isFocusedName = false;
  bool isFocusedCarModel = false;
  bool isFocusedCarColor = false;
  bool isFocusedCarPlate = false;
  bool _isPasswordVisible = false;

  XFile? imageFile;

  int _currentPage = 0;
  CommonMethods cMethods = CommonMethods();
  String urlOfUploadedImage = "";

  
  chooseImageFromGallery() async
  {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if(pickedFile != null)
    {
      setState(() {
        imageFile = pickedFile;
      });
    }
  }


  void _nextPage() {
  String errorMessage = '';

  switch (_currentPage) {
    case 0: // Página de Email
      if (_emailController.text.isEmpty) {
        errorMessage = 'El campo de email está vacío. Por favor, ingresa tu email para continuar.';
      }
      break;
    case 1: // Página de Nombre
      if (_nameController.text.isEmpty) {
        errorMessage = 'El campo de nombre está vacío. Por favor, ingresa tu nombre para continuar.';
      }
      break;
    case 2: // Página de Vehículo
      if (_carPlateController.text.isEmpty || _carModelController.text.isEmpty || _carColorController.text.isEmpty) {
        errorMessage = 'Por favor, completa todos los campos del vehículo para continuar.';
      }
      break;
    // Agrega más casos si tienes más páginas que necesiten validación
  }

  if (errorMessage.isNotEmpty) {
    // Mostrar mensaje de error
        cMethods.showTopAlert(context, this, errorMessage);

  } else {
    // Avanzar a la siguiente página si no hay errores
    if (_currentPage < 4) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Barra de navegación
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
                        LinearProgressIndicator(
                          value: (_currentPage + 1) / 5,
                        ),
                      ],
                    ),
                    // Inserción del PageView
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (int page) {
                          setState(() {
                            _currentPage = page;
                          });
                        },
                        children: [
                          _buildEmailInput(),
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
                              onPressed: () {},
                              child: const Text(
                                'Iniciar Sesión',
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailInput() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 1.h,
        ),
        FadeInDown(
          delay: const Duration(milliseconds: 700),
          duration: const Duration(milliseconds: 800),
          child: const Text(
            'Introduce tu Email para Continuar',
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
                color: isFocusedEmail ? Colors.white : const Color(0xFFF1F0F5),
                border: Border.all(width: 1, color: const Color(0xFFD2D2D4)),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  if (isFocusedEmail)
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
                  border: InputBorder.none, hintText: 'Tu Email'),
              focusNode: focusNodeEmail,
              controller: _emailController,
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
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                      elevation: 0,
                      textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Satoshi'),
                      backgroundColor: const Color(0xFF835DF1),
                      foregroundColor: Colors.white,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: FadeInUp(
                      delay: const Duration(milliseconds: 700),
                      duration: const Duration(milliseconds: 800),
                      child: const Text('Continuar')),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNameInput() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 1.h,
        ),
        FadeInDown(
          delay: const Duration(milliseconds: 700),
          duration: const Duration(milliseconds: 800),
          child: const Text(
            'Introduce tu Nombre y Apellidos',
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
                color: isFocusedName ? Colors.white : const Color(0xFFF1F0F5),
                border: Border.all(width: 1, color: const Color(0xFFD2D2D4)),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  if (isFocusedName)
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
                  border: InputBorder.none, hintText: 'Nombre y Apellidos'),
              focusNode: focusNodeName,
              controller: _nameController,
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
                child: ElevatedButton(
                  onPressed: _previousPage,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Satoshi'),
                        
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: FadeInUp(
                    delay: const Duration(milliseconds: 700),
                    duration: const Duration(milliseconds: 800),
                    child: const Text('Volver'),
                  ),
                ),
              ),
              const SizedBox(width: 10), // Espacio entre los botones
              Expanded(
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Satoshi'),
                    backgroundColor: const Color(0xFF835DF1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: FadeInUp(
                    delay: const Duration(milliseconds: 700),
                    duration: const Duration(milliseconds: 800),
                    child: const Text('Continuar'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCarInput() {
    return Column(
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
                color: isFocusedCarPlate ? Colors.white : const Color(0xFFF1F0F5),
                border: Border.all(width: 1, color: const Color(0xFFD2D2D4)),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  if (isFocusedCarPlate)
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
                color: isFocusedCarModel ? Colors.white : const Color(0xFFF1F0F5),
                border: Border.all(width: 1, color: const Color(0xFFD2D2D4)),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  if (isFocusedCarModel)
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
                color: isFocusedCarColor ? Colors.white : const Color(0xFFF1F0F5),
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
                child: ElevatedButton(
                  onPressed: _previousPage,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Satoshi'),
                        
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: FadeInUp(
                    delay: const Duration(milliseconds: 700),
                    duration: const Duration(milliseconds: 800),
                    child: const Text('Volver'),
                  ),
                ),
              ),
              const SizedBox(width: 10), // Espacio entre los botones
              Expanded(
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Satoshi'),
                    backgroundColor: const Color(0xFF835DF1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: FadeInUp(
                    delay: const Duration(milliseconds: 700),
                    duration: const Duration(milliseconds: 800),
                    child: const Text('Continuar'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoInput() {
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
                color: isFocusedCarColor ? Colors.white : const Color(0xFFF1F0F5),
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
                
            child: 
            imageFile == null ?
              const CircleAvatar(
                radius: 86,
                backgroundImage: AssetImage("lib/assets/profileuser.png"),
              ) : Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                  image: DecorationImage(
                    fit: BoxFit.fitHeight,
                    image: FileImage(
                      File(
                        imageFile!.path,
                      ),
                    )
                  )
                ),
              ),

              
            
            
          ),
        ),

        FadeInDown(
          delay: const Duration(milliseconds: 600),
          duration: const Duration(milliseconds: 700),
          child:
          GestureDetector(
                onTap: ()
                {
                  chooseImageFromGallery();
                },
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
                child: ElevatedButton(
                  onPressed: _previousPage,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Satoshi'),
                        
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: FadeInUp(
                    delay: const Duration(milliseconds: 700),
                    duration: const Duration(milliseconds: 800),
                    child: const Text('Volver'),
                  ),
                ),
              ),
              const SizedBox(width: 10), // Espacio entre los botones
              Expanded(
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Satoshi'),
                    backgroundColor: const Color(0xFF835DF1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: FadeInUp(
                    delay: const Duration(milliseconds: 700),
                    duration: const Duration(milliseconds: 800),
                    child: const Text('Continuar'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordInput() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          height: 20, // Ajusta la altura según sea necesario
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
          height: 20, // Ajusta la altura según sea necesario
        ),
        FadeInDown(
          delay: const Duration(milliseconds: 600),
          duration: const Duration(milliseconds: 700),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: isFocusedPassword ? Colors.white : const Color(0xFFF1F0F5),
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
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
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
          height: 20, // Ajusta la altura según sea necesario
        ),
        FadeInUp(
          delay: const Duration(milliseconds: 600),
          duration: const Duration(milliseconds: 700),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _previousPage,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Satoshi',
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: FadeInUp(
                    delay: const Duration(milliseconds: 700),
                    duration: const Duration(milliseconds: 800),
                    child: const Text('Volver'),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Satoshi',
                    ),
                    backgroundColor: const Color(0xFF835DF1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: FadeInUp(
                    delay: const Duration(milliseconds: 700),
                    duration: const Duration(milliseconds: 800),
                    child: const Text('Finalizar'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

}



