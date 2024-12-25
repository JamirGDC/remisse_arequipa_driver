import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remisse_arequipa_driver/presentation/pages/home/home_page.dart';
import 'package:sizer/sizer.dart';
import '../../../../views/auth/signup_screen.dart';
import 'form_home_viewmodel.dart';

class FormHomeScreen extends StatefulWidget {
  const FormHomeScreen({super.key});

  @override
  _FormHomeScreenState createState() => _FormHomeScreenState();
}

class _FormHomeScreenState extends State<FormHomeScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    emailController.addListener(_checkFormValidity);
    passwordController.addListener(_checkFormValidity);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<FormHomeViewModel>();
      if (viewModel != null) {
        viewModel.loadDriverName();
        viewModel.getGreeting();
        viewModel.fetchLastChecklistDate();


      }
    });
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
    final viewModel = context.watch<FormHomeViewModel>();

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(''),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "${viewModel.greeting} \n${viewModel.driverName}" ?? 'Cargando...',
                  style: TextStyle(
                    fontSize: 23.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 1.h),

                Container(
                  padding: EdgeInsets.all(3.h),
                  decoration: BoxDecoration(
                    color: (viewModel.isBothFormsComplete)
                        ? Colors.black
                        : Colors.black, // Amarillo si no
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 3,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        viewModel.isBothFormsComplete
                            ? Icons.check
                            : Icons.close,
                        color: viewModel.isBothFormsComplete
                            ? Colors.green[
                        800] // Verde si ambos formularios están completos
                            : Colors.orange[800], // Naranja si no
                        size: 7.w,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          (viewModel.isBothFormsComplete)
                              ? ' Ambos formularios están completos: \n ❤️‍🩹 Salud: ${viewModel.lastHealthChecklistDate} \n 🔧 Mecanica: ${viewModel.lastMechanicalChecklistDate}'
                              : ' Formulario de Salud: ${viewModel.lastHealthChecklistDate ?? 'No disponible'} \n Formulario de Mecánica: ${viewModel.lastMechanicalChecklistDate ?? 'No disponible'}',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 4.h),

                ElevatedButton(
                  onPressed: (viewModel.isEnableHealth ?? true)
                      ? null
                      : () {
                    viewModel.healthFormButton(
                        context);
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Satoshi',
                    ),
                    backgroundColor: (viewModel.isEnableHealth ??
                        true)
                        ? Colors.grey // Color cuando está deshabilitado
                        : Colors.black, // Color original
                    foregroundColor: Colors.amberAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    '❤️    Rellenar Formulario de Salud',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),

                ElevatedButton(
                  onPressed: (viewModel.isEnableMechanical ?? true)
                      ? null
                      : () {
                    viewModel.mechanicalFormButton(
                        context);
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Satoshi',
                    ),
                    backgroundColor: (viewModel.isEnableMechanical ??
                        true)
                        ? Colors.grey
                        : Colors.black,
                    foregroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    '🔧    Rellenar Formulario de Mecanica',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),


                Expanded(child: SizedBox(height: 1.h)),

                ElevatedButton(
                  onPressed: (viewModel.isBothFormsComplete)
                      ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomePage(),
                      ),
                    );
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Satoshi',
                    ),
                    backgroundColor: viewModel.isBothFormsComplete
                        ? const Color.fromARGB(255, 0, 0, 0)
                        : Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Continuar',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
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
