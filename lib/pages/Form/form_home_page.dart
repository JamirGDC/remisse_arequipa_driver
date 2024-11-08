import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remisse_arequipa_driver/pages/providers/formprovider.dart';
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
                        ? Colors.green
                            .shade100 // Verde si ambos formularios están completos
                        : Colors.yellow.shade100, // Amarillo si no
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
                        Icons.warning_amber_rounded,
                        color: (formProvider1.isBothFormsComplete)
                            ? Colors.green[
                                800] // Verde si ambos formularios están completos
                            : Colors.yellow[800], // Amarillo si no
                        size: 7.w,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          (formProvider1.isBothFormsComplete)
                              ? 'Ambos formularios están completos: Salud: ${formProvider1.lastHealthChecklistDate}|  Mecanica: ${formProvider1.lastMechanicalChecklistDate}'
                              : 'Formulario de Salud: ${formProvider1.lastHealthChecklistDate ?? 'No disponible'} | Formulario de Mecánica: ${formProvider1.lastMechanicalChecklistDate ?? 'No disponible'}',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
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
                    Center(
                      child: SizedBox(
                        width: 80.w, // Define el ancho del botón
                        child: ElevatedButton(
                          onPressed: (formProvider1.isEnableHealth ?? true)
                              ? null
                              : () {
                                  formProvider1.healthFormButton(
                                      context); //llamo al metodo
                                },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            backgroundColor: (formProvider1.isEnableHealth ??
                                    true)
                                ? Colors.grey // Color cuando está deshabilitado
                                : const Color(0xFF835DF1), // Color original
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Rellenar Formulario de Salud',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h), // Espacio entre los dos botones
                    // Segundo botón: Rellenar Formulario de Mecánica
                    Center(
                      child: SizedBox(
                        width: 80.w, // Mismo ancho que el primer botón
                        child: ElevatedButton(
                          onPressed: (formProvider1.isEnableMechanical ?? true)
                              ? null // Deshabilitado si ya fue rellenado hoy
                              : () {
                                  formProvider1.mechanicalFormButton(
                                      context); //llamo al metodo
                                },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            backgroundColor: (formProvider1
                                        .isEnableMechanical ??
                                    true)
                                ? Colors.grey // Color cuando está deshabilitado
                                : const Color(0xFF835DF1), // Color original
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Rellenar Formulario de Mecánica',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                  height:
                      12.h), // Espacio adicional antes del botón "Continuar"
              Center(
                child: ElevatedButton(
                  onPressed: (formProvider1.isBothFormsComplete)
                      ? () {
                          formProvider1.continueButton(
                              context); //llamo al metodo
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.5.h),
                    backgroundColor: formProvider1.isBothFormsComplete
                        ? const Color(0xFF4CAF50)
                        : Colors.grey, // Cambia el color según el estado
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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
            ],
          ),
        ),
      ),
    );
  }
}