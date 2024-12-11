import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:remisse_arequipa_driver/viewmodels/form/formprovider.dart';
import 'package:sizer/sizer.dart';

class Formchecklist extends StatelessWidget {
  const Formchecklist({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: FadeInDown(
          delay: const Duration(milliseconds: 900),
          duration: const Duration(milliseconds: 1000),
          child: Center(
            child: Text(
              'Formulario',
              style: TextStyle(
                fontSize: 18
                    .sp, // Usando sizer para hacer que el tamaño sea responsivo
                fontWeight: FontWeight.bold, // Negrita
              ),
            ),
          ),
        ),
      ),
      body: Consumer<Formprovider>(
        builder: (context, formProvider, child) {
          if (formProvider.questions.isEmpty &&
              formProvider.errorMessage == null) {
            return const Center(child: CircularProgressIndicator());
          }
          // Mostrar mensaje de error
          if (formProvider.errorMessage != null) {
            return FadeInDown(
              duration: const Duration(milliseconds: 800),
              child: Container(
                padding: EdgeInsets.all(3.h),
                decoration: BoxDecoration(
                  color: Colors.red
                      .shade100, // Color rojo claro para el fondo del mensaje de error
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
                      Icons.error, // Cambié a un ícono de error
                      color: Colors.red[800], // Color rojo oscuro para el ícono
                      size: 7.w,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        formProvider
                            .errorMessage!, // Mostrar el mensaje de error
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView(
            children: formProvider.questions.map((question) {
              return FadeInUp(
                delay: const Duration(milliseconds: 400),
                duration: const Duration(milliseconds: 500),
                child: Container(
                  margin:
                      EdgeInsets.all(2.h), // Ajuste de márgenes según la altura
                  padding:
                      EdgeInsets.all(2.h), // Ajuste de padding según la altura
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                        color: const Color.fromARGB(255, 252, 252, 252)),
                    borderRadius: BorderRadius.circular(
                        2.h), // Ajuste de borderRadius usando altura
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 3,
                        offset: const Offset(0, 3), // Sombra hacia abajo
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question['text'],
                        style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight:
                                FontWeight.bold), // Tamaño de texto responsivo
                      ),
                      SizedBox(height: 1.h), // Espacio responsivo usando altura
                      Wrap(
                        spacing: 5
                            .w, // Espacio entre radio buttons ajustado con el ancho de pantalla
                        children: formProvider.options.map((option) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio<String>(
                                value: option,
                                groupValue:
                                    formProvider.getResponse(question['id']),
                                activeColor: const Color.fromARGB(255, 5, 21, 112), // Color personalizado
                                onChanged: (String? value) {
                                  formProvider.setResponse(
                                      question['id'], value!);
                                },
                              ),
                              Text(option,
                                  style: TextStyle(
                                      fontSize:
                                          15.sp)), // Tamaño de texto ajustado
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: Consumer<Formprovider>(
        builder: (context, formProvider, child) {
          return FadeInUp(
            delay: const Duration(milliseconds: 600),
            duration: const Duration(milliseconds: 700),
            child: FloatingActionButton(
              onPressed: formProvider.isSaving
                  ? null
                  : () async {
                      String? result = await formProvider.saveChecklist();
                      if (result != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result)),
                        );
                        // Navegar a la página de inicio después de guardar
                  if (result == 'Cuestionario guardado con éxito') {
                    Navigator.pushNamed(context, '/formHomePage');
                  }
                      }
                    },
              child: formProvider.isSaving
                  ? const CircularProgressIndicator()
                  : Icon(Icons.save, size: 8.w), // Tamaño del ícono ajustado
            ),
          );
        },
      ),
    );
  }
}