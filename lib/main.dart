import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:remisse_arequipa_driver/authentication/signup_screen.dart';
import 'package:remisse_arequipa_driver/authentication/welcome.dart';
import 'package:remisse_arequipa_driver/pages/dashboard.dart';
import 'package:remisse_arequipa_driver/widgets/splash_Screen.dart';

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
      builder: (context, orientation, deviceType) => MaterialApp(
          theme: ThemeData(fontFamily: 'Satoshi'),
          //home: const SignupScreen()),
          home: FirebaseAuth.instance.currentUser == null ? const WelcomePage() : const Dashboard()),
    );
  }
}



// class MyApp extends StatelessWidget
// {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context)
//   {
//     return MaterialApp(
//       title: 'Drivers App',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData.dark().copyWith(
//         scaffoldBackgroundColor: Colors.black,
//       ),
      
//       home: const WelcomePage(),
//       // home: FirebaseAuth.instance.currentUser == null ? LoginScreen() : Dashboard(),
//     );
//   }
// }


// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:remisse_arequipa_driver/authentication/login_screen.dart';
// import 'package:remisse_arequipa_driver/firebase_options.dart';
// import 'package:remisse_arequipa_driver/pages/assign_route_page';
// import 'package:remisse_arequipa_driver/pages/create_client_page.dart';
// import 'package:remisse_arequipa_driver/pages/dashboard.dart';
// import 'package:remisse_arequipa_driver/pages/home_page.dart';
// import 'package:remisse_arequipa_driver/pages/driver_home_page.dart';

// //import 'package:remisse_arequipa/users/Profile_Users.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   await Permission.locationWhenInUse.isDenied.then((value){
//     if(value){
//       Permission.locationWhenInUse.request();
//     }
//   });

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Remisse Arequipa',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
//         useMaterial3: true,
//       ),
//       //home: FirebaseAuth.instance.currentUser == null ? const LoginScreen() : const Dashboard(), 
//       home: const LoginScreen(),
//     );
//   }
// }

// class AuthWrapper extends StatelessWidget {
//   const AuthWrapper({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const CircularProgressIndicator(); // Muestra un indicador de carga si está esperando
//         } else if (snapshot.hasData) {
//           return const HomePage(); // Si el usuario está autenticado, va a HomePage
//         } else {
//           return const LoginScreen(); // Si no está autenticado, va a LoginScreen
//         }
//       },
//     );
//   }
// }
 






// import 'dart:io';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl_phone_field/intl_phone_field.dart';
// import 'package:remisse_arequipa_driver/authentication/login_screen.dart';
// import 'package:remisse_arequipa_driver/methods/common_methods.dart';
// import 'package:remisse_arequipa_driver/pages/dashboard.dart';
// import 'package:remisse_arequipa_driver/widgets/loading_dialog.dart';

// class SignupScreen extends StatefulWidget {
//   const SignupScreen({super.key});

//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }

// class _SignupScreenState extends State<SignupScreen> {
//   bool _obscureText = true;
//   bool _termsAccepted = false;

//   final FocusNode _nameFocusNode = FocusNode();
//   final FocusNode _lastNameFocusNode = FocusNode();

//   final FocusNode _emailFocusNode = FocusNode();
//   final FocusNode _passwordFocusNode = FocusNode();
//   final FocusNode _confirmPasswordFocusNode = FocusNode();

//     final FocusNode _vehicleModelFocusNode = FocusNode();
//     final FocusNode _vehicleColorFocusNode = FocusNode();
//     final FocusNode _vehicleNumberFocusNode = FocusNode();


//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _confirmPasswordController =
//       TextEditingController();

//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _lastNameController = TextEditingController();

//   TextEditingController userNameTextEditingController = TextEditingController();
//   TextEditingController userLastNameTextEditingController = TextEditingController();
//   TextEditingController userPhoneTextEditingController = TextEditingController();
//   TextEditingController emailTextEditingController = TextEditingController();
//   TextEditingController passwordTextEditingController = TextEditingController();
//   TextEditingController vehicleModelTextEditingController = TextEditingController();
//   TextEditingController vehicleColorTextEditingController = TextEditingController();
//   TextEditingController vehicleNumberTextEditingController = TextEditingController();



//   checkIfNetworkIsAvailable()
//   {
//     cMethods.checkConnectivity(context);

//     if(imageFile != null) //image validation
//     {
//       signUpFormValidation();
//     }
//     else
//     {
//       cMethods.displaysnackbar("Please choose image first.", context);
//     }
//   }

//   signUpFormValidation()
//   {
//     if(userNameTextEditingController.text.trim().length < 3)
//     {
//       cMethods.displaysnackbar("your name must be atleast 4 or more characters.", context);
//     }
//     else if(userPhoneTextEditingController.text.trim().length < 7)
//     {
//       cMethods.displaysnackbar("your phone number must be atleast 8 or more characters.", context);
//     }
//     else if(!emailTextEditingController.text.contains("@"))
//     {
//       cMethods.displaysnackbar("please write valid email.", context);
//     }
//     else if(passwordTextEditingController.text.trim().length < 5)
//     {
//       cMethods.displaysnackbar("your password must be atleast 6 or more characters.", context);
//     }
//     else if(vehicleModelTextEditingController.text.trim().isEmpty)
//     {
//       cMethods.displaysnackbar("please write your car model", context);
//     }
//     else if(vehicleColorTextEditingController.text.trim().isEmpty)
//     {
//       cMethods.displaysnackbar("please write your car color.", context);
//     }
//     else if(vehicleNumberTextEditingController.text.isEmpty)
//     {
//       cMethods.displaysnackbar("please write your car number.", context);
//     }
//     else
//     {
//       uploadImageToStorage();
//     }
//   }

//   uploadImageToStorage() async
//   {
//     String imageIDName = DateTime.now().millisecondsSinceEpoch.toString();
//     Reference referenceImage = FirebaseStorage.instance.ref().child("Images").child(imageIDName);

//     UploadTask uploadTask = referenceImage.putFile(File(imageFile!.path));
//     TaskSnapshot snapshot = await uploadTask;
//     urlOfUploadedImage = await snapshot.ref.getDownloadURL();

//     setState(() {
//       urlOfUploadedImage;
//     });

//     registerNewDriver();
//   }

//   registerNewDriver() async
//   {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) => const LoadingDialog(messageText: "Registering your account..."),
//     );

//     final User? userFirebase = (
//       await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: emailTextEditingController.text.trim(),
//         password: passwordTextEditingController.text.trim(),
//       ).catchError((errorMsg)
//       {
//         Navigator.pop(context);
//         cMethods.displaysnackbar(errorMsg.toString(), context);
//       })
//     ).user;

//     if(!context.mounted) return;
//     Navigator.pop(context);

//     DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("drivers").child(userFirebase!.uid);

//     Map driverCarInfo =
//     {
//       "carColor": vehicleColorTextEditingController.text.trim(),
//       "carModel": vehicleModelTextEditingController.text.trim(),
//       "carNumber": vehicleNumberTextEditingController.text.trim(),
//     };
    
//     Map driverDataMap =
//     {
//       "photo": urlOfUploadedImage,
//       "car_details": driverCarInfo,
//       "name": userNameTextEditingController.text.trim(),
//       "email": emailTextEditingController.text.trim(),
//       "phone": userPhoneTextEditingController.text.trim(),
//       "id": userFirebase.uid,
//       "blockStatus": "no",
//     };
//     usersRef.set(driverDataMap);

//     Navigator.push(context, MaterialPageRoute(builder: (c)=> const Dashboard()));
//   }

//   chooseImageFromGallery() async
//   {
//     final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

//     if(pickedFile != null)
//     {
//       setState(() {
//         imageFile = pickedFile;
//       });
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _emailFocusNode.addListener(() {
//       setState(() {});
//     });
//     _passwordFocusNode.addListener(() {
//       setState(() {});
//     });
//   }

//   @override
//   void dispose() {
//     _emailFocusNode.dispose();
//     _passwordFocusNode.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             colors: [
//               Colors.orange[900] ?? Colors.orange,
//               Colors.orange[400] ?? Colors.orange,
//             ],
//           ),
//         ),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: <Widget>[
//               const SizedBox(height: 80),
              
//               imageFile == null ?
//               const CircleAvatar(
//                 radius: 86,
//                 backgroundImage: AssetImage("assets/images/profileuser.png"),
//               ) : Container(
//                 width: 180,
//                 height: 180,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: Colors.grey,
//                   image: DecorationImage(
//                     fit: BoxFit.fitHeight,
//                     image: FileImage(
//                       File(
//                         imageFile!.path,
//                       ),
//                     )
//                   )
//                 ),
//               ),
              
//               const SizedBox(
//                 height: 10,
//               ),

//               GestureDetector(
//                 onTap: ()
//                 {
//                   chooseImageFromGallery();
//                 },
//                 child: const Text(
//                   "Elegir Imagen",
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),


//               const SizedBox(height: 50),
//               Container(
//                 width: double.infinity,
//                 decoration: const BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(40),
//                     topRight: Radius.circular(40),
//                   ),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(30.0),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: <Widget>[
//                       const Text(
//                         'Registro',
//                         style: TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black,
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       SizedBox(
//                         width: 400,
//                         child: TextField(
//                           controller: userNameTextEditingController,
//                           focusNode: _nameFocusNode,
//                           keyboardType: TextInputType.text,
//                           style: TextStyle(
//                             color: _nameFocusNode.hasFocus
//                                 ? Colors.orange[900]
//                                 : Colors.black,
//                           ), // Texto cambia según el foco
//                           decoration: InputDecoration(
//                             labelText: 'Nombre',
//                             labelStyle: TextStyle(
//                               color: _nameFocusNode.hasFocus
//                                   ? Colors.orange[900]
//                                   : Colors.black,
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(15.0),
//                               borderSide: BorderSide(
//                                 color: Colors.orange[
//                                     900]!, // Color del borde cuando está enfocado
//                               ),
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(15.0),
//                               borderSide: const BorderSide(
//                                 color: Colors
//                                     .black, // Color del borde cuando no está enfocado
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 20),
//                       SizedBox(
//                         width: 400,
//                         child: TextField(
//                           controller: userLastNameTextEditingController,
//                           focusNode: _lastNameFocusNode,
//                           keyboardType: TextInputType.text,
//                           style: TextStyle(
//                             color: _lastNameFocusNode.hasFocus
//                                 ? Colors.orange[900]
//                                 : Colors.black,
//                           ), // Texto cambia según el foco
//                           decoration: InputDecoration(
//                             labelText: 'Apellidos',
//                             labelStyle: TextStyle(
//                               color: _lastNameFocusNode.hasFocus
//                                   ? Colors.orange[900]
//                                   : Colors.black,
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(15.0),
//                               borderSide: BorderSide(
//                                 color: Colors.orange[
//                                     900]!, // Color del borde cuando está enfocado
//                               ),
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(15.0),
//                               borderSide: const BorderSide(
//                                 color: Colors
//                                     .black, // Color del borde cuando no está enfocado
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 20),
//                       SizedBox(
//                         width: 400,
//                         child: TextField(
//                           controller: emailTextEditingController,
//                           focusNode: _emailFocusNode,
//                           keyboardType: TextInputType.emailAddress,
//                           style: TextStyle(
//                             color: _emailFocusNode.hasFocus
//                                 ? Colors.orange[900]
//                                 : Colors.black,
//                           ), // Texto cambia según el foco
//                           decoration: InputDecoration(
//                             labelText: 'Correo Electrónico',
//                             labelStyle: TextStyle(
//                               color: _emailFocusNode.hasFocus
//                                   ? Colors.orange[900]
//                                   : Colors.black,
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(15.0),
//                               borderSide: BorderSide(
//                                 color: Colors.orange[
//                                     900]!, // Color del borde cuando está enfocado
//                               ),
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(15.0),
//                               borderSide: const BorderSide(
//                                 color: Colors
//                                     .black, // Color del borde cuando no está enfocado
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 20),
//                       SizedBox(
//                         width: 400, // Establece el ancho máximo a 400 píxeles
//                         child: IntlPhoneField(
//                           controller: userPhoneTextEditingController,
//                           decoration: InputDecoration(
//                             labelText: 'Número de Teléfono',
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(15.0),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(15.0),
//                               borderSide: BorderSide(
//                                 color: Colors.orange[900]!,
//                               ),
//                             ),
//                           ),
//                           initialCountryCode: 'PE',
//                           onChanged: (phone) {
//                             //print(phone.completeNumber);
//                           },
//                         ),
//                       ),

//                       const SizedBox(height: 20),
//                       SizedBox(
//                         width: 400,
//                         child: TextField(
//                           controller: vehicleModelTextEditingController,
//                           focusNode: _vehicleModelFocusNode,
//                           keyboardType: TextInputType.text,
//                           style: TextStyle(
//                             color: _vehicleModelFocusNode.hasFocus
//                                 ? Colors.orange[900]
//                                 : Colors.black,
//                           ), // Texto cambia según el foco
//                           decoration: InputDecoration(
//                             labelText: 'Modelo de Vehículo',
//                             labelStyle: TextStyle(
//                               color: _vehicleModelFocusNode.hasFocus
//                                   ? Colors.orange[900]
//                                   : Colors.black,
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(15.0),
//                               borderSide: BorderSide(
//                                 color: Colors.orange[
//                                     900]!, // Color del borde cuando está enfocado
//                               ),
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(15.0),
//                               borderSide: const BorderSide(
//                                 color: Colors
//                                     .black, // Color del borde cuando no está enfocado
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 20),
//                       SizedBox(
//                         width: 400,
//                         child: TextField(
//                           controller: vehicleColorTextEditingController,
//                           focusNode: _vehicleColorFocusNode,
//                           keyboardType: TextInputType.text,
//                           style: TextStyle(
//                             color: _vehicleColorFocusNode.hasFocus
//                                 ? Colors.orange[900]
//                                 : Colors.black,
//                           ), // Texto cambia según el foco
//                           decoration: InputDecoration(
//                             labelText: 'Color de Vehículo',
//                             labelStyle: TextStyle(
//                               color: _vehicleColorFocusNode.hasFocus
//                                   ? Colors.orange[900]
//                                   : Colors.black,
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(15.0),
//                               borderSide: BorderSide(
//                                 color: Colors.orange[
//                                     900]!, // Color del borde cuando está enfocado
//                               ),
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(15.0),
//                               borderSide: const BorderSide(
//                                 color: Colors
//                                     .black, // Color del borde cuando no está enfocado
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 20),
//                       SizedBox(
//                         width: 400,
//                         child: TextField(
//                           controller: vehicleNumberTextEditingController,
//                           focusNode: _vehicleNumberFocusNode,
//                           keyboardType: TextInputType.text,
//                           style: TextStyle(
//                             color: _vehicleNumberFocusNode.hasFocus
//                                 ? Colors.orange[900]
//                                 : Colors.black,
//                           ), // Texto cambia según el foco
//                           decoration: InputDecoration(
//                             labelText: 'Número de Placa',
//                             labelStyle: TextStyle(
//                               color: _vehicleNumberFocusNode.hasFocus
//                                   ? Colors.orange[900]
//                                   : Colors.black,
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(15.0),
//                               borderSide: BorderSide(
//                                 color: Colors.orange[
//                                     900]!, // Color del borde cuando está enfocado
//                               ),
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(15.0),
//                               borderSide: const BorderSide(
//                                 color: Colors
//                                     .black, // Color del borde cuando no está enfocado
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 20),
//                       SizedBox(
//                         width: 400,
//                         child: TextField(
//                           controller: passwordTextEditingController,
//                           focusNode: _passwordFocusNode,
//                           obscureText: _obscureText,
//                           style: TextStyle(
//                             color: _passwordFocusNode.hasFocus
//                                 ? Colors.orange[900]
//                                 : Colors.black,
//                           ), // Texto cambia según el foco
//                           decoration: InputDecoration(
//                             labelText: 'Contraseña',
//                             labelStyle: TextStyle(
//                               color: _passwordFocusNode.hasFocus
//                                   ? Colors.orange[900]
//                                   : Colors.black,
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(15.0),
//                               borderSide: BorderSide(
//                                 color: Colors.orange[
//                                     900]!, // Color del borde cuando está enfocado
//                               ),
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(15.0),
//                               borderSide: const BorderSide(
//                                 color: Colors
//                                     .black, // Color del borde cuando no está enfocado
//                               ),
//                             ),
//                             suffixIcon: IconButton(
//                               icon: Icon(
//                                 _obscureText
//                                     ? Icons.visibility
//                                     : Icons.visibility_off,
//                                 color: _passwordFocusNode.hasFocus
//                                     ? Colors.orange[900]
//                                     : Colors.black,
//                               ),
//                               onPressed: () {
//                                 setState(() {
//                                   _obscureText = !_obscureText;
//                                 });
//                               },
//                             ),
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 20),
//                       SizedBox(
//                         width: 400,
//                         child: TextField(
//                           controller: _confirmPasswordController,
//                           focusNode: _confirmPasswordFocusNode,
//                           obscureText: _obscureText,
//                           style: TextStyle(
//                             color: _confirmPasswordFocusNode.hasFocus
//                                 ? Colors.orange[900]
//                                 : Colors.black,
//                           ), // Texto cambia según el foco
//                           decoration: InputDecoration(
//                             labelText: 'Repetir Contraseña',
//                             labelStyle: TextStyle(
//                               color: _confirmPasswordFocusNode.hasFocus
//                                   ? Colors.orange[900]
//                                   : Colors.black,
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(15.0),
//                               borderSide: BorderSide(
//                                 color: Colors.orange[
//                                     900]!, // Color del borde cuando está enfocado
//                               ),
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(15.0),
//                               borderSide: const BorderSide(
//                                 color: Colors
//                                     .black, // Color del borde cuando no está enfocado
//                               ),
//                             ),
//                             suffixIcon: IconButton(
//                               icon: Icon(
//                                 _obscureText
//                                     ? Icons.visibility
//                                     : Icons.visibility_off,
//                                 color: _confirmPasswordFocusNode.hasFocus
//                                     ? Colors.orange[900]
//                                     : Colors.black,
//                               ),
//                               onPressed: () {
//                                 setState(() {
//                                   _obscureText = !_obscureText;
//                                 });
//                               },
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Checkbox(
//                             value:
//                                 _termsAccepted, // Esto debe ser una variable booleana en tu clase State
//                             onChanged: (bool? value) {
//                               setState(() {
//                                 _termsAccepted = value ?? false;
//                               });
//                             },
//                           ),
//                           GestureDetector(
//                             onTap: () {
//                               // Navega a una pantalla o muestra un diálogo con los términos y condiciones
//                             },
//                             child: Text(
//                               "Aceptar términos y condiciones",
//                               style: TextStyle(
//                                 color: Colors.orange[900],
//                                 decoration: TextDecoration.underline,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 20),
//                       SizedBox(
//                         width: 400,
//                         child: ElevatedButton(
//                           onPressed: () {
//                             // Acción al presionar el botón de Ingresar
//                             checkIfNetworkIsAvailable();
//                           },
//                           style: ElevatedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 50, vertical: 15),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(50),
//                             ),
//                             backgroundColor: Colors.orange[900],
//                           ),
//                           child: const Text(
//                             'Registrarse',
//                             style: TextStyle(color: Colors.white, fontSize: 18),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 20),

//                       // Añadir un separador con "OR"
//                       Row(
//                         children: <Widget>[
//                           const Expanded(
//                             child: Divider(
//                               thickness: 1,
//                               color: Colors.grey,
//                               indent: 30,
//                               endIndent: 10,
//                             ),
//                           ),
//                           Text(
//                             "OR",
//                             style: TextStyle(
//                               color: Colors.grey[700],
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           const Expanded(
//                             child: Divider(
//                               thickness: 1,
//                               color: Colors.grey,
//                               indent: 10,
//                               endIndent: 30,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 20),

//                       // Botones de Google y Apple
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: <Widget>[
//                           ElevatedButton.icon(
//                             onPressed: () {
//                               // Acción al presionar el botón de Google
//                             },
//                             style: ElevatedButton.styleFrom(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 30, vertical: 10),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(50),
//                               ),
//                               backgroundColor:
//                                   const Color.fromARGB(255, 16, 103, 255),
//                               side: const BorderSide(
//                                   color: Color.fromARGB(255, 15, 153, 233)),
//                               minimumSize: const Size(190, 50),
//                             ),
//                             icon: Image.asset(
//                               'lib/assets/google.png',
//                               width: 20,
//                               height: 20,
//                             ),
//                             label: const Text(
//                               'Google',
//                               style: TextStyle(
//                                   color: Color.fromARGB(255, 252, 251, 250)),
//                             ),
//                           ),
//                           const SizedBox(width: 20),
//                           ElevatedButton.icon(
//                             onPressed: () {
//                               // Acción al presionar el botón de Apple
//                             },
//                             style: ElevatedButton.styleFrom(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 30, vertical: 10),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(50),
//                               ),
//                               backgroundColor:
//                                   const Color.fromARGB(255, 15, 14, 14),
//                               side: const BorderSide(
//                                   color: Color.fromARGB(255, 7, 7, 7)),
//                               minimumSize: const Size(190, 50),
//                             ),
//                             icon: const Icon(
//                               Icons.apple,
//                               color: Color.fromARGB(255, 252, 252, 252),
//                             ),
//                             label: const Text(
//                               'Apple',
//                               style: TextStyle(
//                                   color: Color.fromARGB(255, 247, 245, 243)),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 20),

//                       // Texto "Don't have an account?" seguido de un botón "Sign Up"
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Text(
//                             "¿Ya tienes una cuenta?",
//                             style: TextStyle(
//                               color: Colors.grey,
//                               fontSize: 16,
//                             ),
//                           ),
//                           TextButton(
//                             onPressed: () {
//                               Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (c) => const SignupScreen()));
//                             },
//                             child: Text(
//                               'Ingresa aquí',
//                               style: TextStyle(
//                                 color: Colors.orange[900],
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
