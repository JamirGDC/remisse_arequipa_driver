import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remisse_arequipa_driver/global.dart';
import 'package:remisse_arequipa_driver/viewmodels/form/formprovider.dart';
import 'package:sizer/sizer.dart';

class FormHomePage extends StatefulWidget {
  const FormHomePage({super.key});

  @override
  FormHomePageState createState() => FormHomePageState();
}

class FormHomePageState extends State<FormHomePage> {
  @override
  Widget build(BuildContext context) {
//instancia de mi provider y la clase que cree
    final formProvider1 = Provider.of<Formprovider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4.h), // Espacio superior
              Center(
                child: Text(
                  formProvider1.getGreeting(),
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 4.h), // Espacio entre título y recuadro
              FadeInDown(
                duration: const Duration(milliseconds: 800),
                child: Container(
                  padding: EdgeInsets.all(3.h),
                  decoration: BoxDecoration(
                    color: (formProvider1.isBothFormsComplete)
                        ? Colors.black
                        // Verde si ambos formularios están completos
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
                        formProvider1.isBothFormsComplete
                            ? Icons.check
                            : Icons.close,
                        color: formProvider1.isBothFormsComplete
                            ? Colors.green[
                                800] // Verde si ambos formularios están completos
                            : Colors.orange[800], // Naranja si no
                        size: 7.w,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          (formProvider1.isBothFormsComplete)
                              ? ' Ambos formularios están completos: \n ❤️‍🩹 Salud: ${formProvider1.lastHealthChecklistDate} \n 🔧 Mecanica: ${formProvider1.lastMechanicalChecklistDate}'
                              : ' Formulario de Salud: ${formProvider1.lastHealthChecklistDate ?? 'No disponible'} \n Formulario de Mecánica: ${formProvider1.lastMechanicalChecklistDate ?? 'No disponible'}',
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
              ),
              SizedBox(height: 6.h), // Espacio entre recuadro y botones
              FadeInUp(
                duration: const Duration(milliseconds: 700),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment
                      .center, // Centra los botones verticalmente
                  children: [
                    // Primer botón: Rellenar Formulario de Salud
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: (formProvider1.isEnableHealth ?? true)
                              ? null
                              : () {
                                  formProvider1.healthFormButton(
                                      context); //llamo al metodo
                                },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Satoshi',
                            ),
                            backgroundColor: (formProvider1.isEnableHealth ??
                                    true)
                                ? Colors.grey // Color cuando está deshabilitado
                                : brandColor, // Color original
                            foregroundColor: neutralColor,
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
                      ),
                    ]),

                    SizedBox(height: 2.h), // Espacio entre los dos botones
                    // Segundo botón: Rellenar Formulario de Mecánica

                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: (formProvider1.isEnableMechanical ?? true)
                              ? null // Deshabilitado si ya fue rellenado hoy
                              : () {
                                  formProvider1.mechanicalFormButton(
                                      context); //llamo al metodo
                                },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Satoshi',
                            ),
                            backgroundColor: (formProvider1.isEnableMechanical ??
                                    true)
                                ? Colors.grey // Color cuando está deshabilitado
                                : brandColor, // Color original
                            foregroundColor: neutralColor,
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
                      ),
                    ]),





                   
                  ],
                ),
              ),
              const Expanded(
                  child: SizedBox(
                height: 10,
              )), // Espacio adicional antes del botón "Continuar"

              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: (formProvider1.isBothFormsComplete)
                        ? () {
                            formProvider1
                                .continueButton(context); //llamo al metodo
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Satoshi',
                      ),
                      backgroundColor: formProvider1.isBothFormsComplete
                          ? const Color.fromARGB(255, 0, 0, 0)
                          : Colors.grey,
                      foregroundColor: neutralColor,
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
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
