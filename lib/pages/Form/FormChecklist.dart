import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:remisse_arequipa_driver/pages/providers/formprovider.dart';
import 'package:sizer/sizer.dart'; 

class Formchecklist extends StatelessWidget {
  const Formchecklist({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FadeInDown(
          delay: const Duration(milliseconds: 900),
          duration: const Duration(milliseconds: 1000),
          child: Center(
            child: Text(
              'Formulario',
              style: TextStyle(
                fontSize: 18.sp,  // Usando sizer para hacer que el tamaño sea responsivo
                fontWeight: FontWeight.bold, // Negrita
              ),
            ),
          ),
        ),
      ),
      body: Consumer<Formprovider>(
        builder: (context, formProvider, child) {
          if (formProvider.questions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: formProvider.questions.map((question) {
              return FadeInUp(
                delay: const Duration(milliseconds: 400),
                duration: const Duration(milliseconds: 500),
                child: Container(
                  margin: EdgeInsets.all(2.h),  // Ajuste de márgenes según la altura
                  padding: EdgeInsets.all(2.h), // Ajuste de padding según la altura
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color.fromARGB(255, 252, 252, 252)),
                    borderRadius: BorderRadius.circular(2.h),  // Ajuste de borderRadius usando altura
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
                        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),  // Tamaño de texto responsivo
                      ),
                      SizedBox(height: 1.h),  // Espacio responsivo usando altura
                      Wrap(
                        spacing: 5.w,  // Espacio entre radio buttons ajustado con el ancho de pantalla
                        children: formProvider.options.map((option) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio<String>(
                                value: option,
                                groupValue: formProvider.getResponse(question['id']),
                                activeColor: const Color.fromARGB(255, 205, 87, 24), // Color personalizado
                                onChanged: (String? value) {
                                  formProvider.setResponse(question['id'], value!);
                                },
                              ),
                              Text(option, style: TextStyle(fontSize: 10.sp)),  // Tamaño de texto ajustado
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
                      }
                    },
              child: formProvider.isSaving
                  ? const CircularProgressIndicator()
                  : Icon(Icons.save, size: 8.w),  // Tamaño del ícono ajustado
            ),
          );
        },
      ),
    );
  }
}
