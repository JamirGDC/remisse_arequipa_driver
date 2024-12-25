import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remisse_arequipa_driver/presentation/pages/form/home_form/form_home_viewmodel.dart';
import 'package:sizer/sizer.dart';


class FormCheckListScreen extends StatefulWidget {
  const FormCheckListScreen({super.key});

  @override
  _FormCheckListScreenState createState() => _FormCheckListScreenState();
}

class _FormCheckListScreenState extends State<FormCheckListScreen> {
  @override
  Widget build(BuildContext context) {
    final formProvider = Provider.of<FormHomeViewModel>(context, listen: true);

    if (formProvider.questions.isEmpty && formProvider.errorMessage == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(
          child: Text(
            'Formulario',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: formProvider.errorMessage != null
          ? Container(
        padding: EdgeInsets.all(3.h),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
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
              Icons.error,
              color: Colors.red[800],
              size: 7.w,
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                formProvider.errorMessage!,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      )
          : ListView(
        children: formProvider.questions.map((question) {
          return Container(
            margin: EdgeInsets.all(2.h),
            padding: EdgeInsets.all(2.h),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                  color: const Color.fromARGB(255, 252, 252, 252)),
              borderRadius: BorderRadius.circular(2.h),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 3,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question['text'],
                  style: TextStyle(
                      fontSize: 15.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 1.h),
                Wrap(
                  spacing: 5.w,
                  children: formProvider.options.map((option) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Radio<String>(
                          value: option,
                          groupValue:
                          formProvider.getResponse(question['id']),
                          activeColor: const Color.fromARGB(255, 5, 21, 112),
                          onChanged: (String? value) {
                            formProvider.setResponse(
                                question['id'], value!);
                          },
                        ),
                        Text(option,
                            style: TextStyle(fontSize: 15.sp)),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: formProvider.isSaving
            ? null
            : () async {
          String? result = await formProvider.saveChecklist();
          if (result != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result)),
            );
            if (result == 'Cuestionario guardado con éxito') {
              Navigator.pop(context); // Vuelve a la vista anterior
            }
          }
        },
        child: formProvider.isSaving
            ? const CircularProgressIndicator()
            : Icon(Icons.save, size: 8.w),
      ),
    );
  }
}

