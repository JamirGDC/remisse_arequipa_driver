import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Formprovider extends ChangeNotifier {
  // Variables
  String driverName = "";
  final DatabaseReference questionsRef = FirebaseDatabase.instance.ref().child('questions');
  final Map<String, String> _responses = {}; // Usando String para almacenar las respuestas seleccionadas
  List<Map<String, dynamic>> questions = [];
  final List<String> options = ['Bien', 'Mal', 'N/A', 'Sí', 'No']; // Opciones del checklist
  bool isSaving = false; // Variable para manejar el estado del botón
 String? lastChecklistDate; // Fecha del último checklist guardado
 bool? isEnable = false;
  // Constructor
  Formprovider() {
    // Inicializar variables
    _getUserName();
    fetchLastChecklistDate();
    _loadQuestions();
  }



// BOTONES
  void continueButton(BuildContext context) {
    Navigator.pushNamed(context, '/HomePage');
  }
void healthFormButton(BuildContext context) {
    Navigator.pushNamed(context, '/formChecklist');
  }
  void mechanicalFormButton (BuildContext context) {
    Navigator.pushNamed(context, '/formChecklist');
  }




  // Obtener el nombre del conductor
  Future<void> _getUserName() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Referencia a la base de datos de Firebase
        DatabaseReference driversRef =
            FirebaseDatabase.instance.ref().child('drivers').child(user.uid);

        DatabaseEvent event = await driversRef.once();
        DataSnapshot snapshot = event.snapshot;

        if (snapshot.exists) {
          driverName = snapshot.child('name').value as String? ?? 'Conductor';
        } else {
          driverName = 'Conductor no encontrado';
        }

        notifyListeners();
      } catch (e) {
        driverName = 'Error al obtener el nombre';
        notifyListeners();
      }
    } else {
      driverName = 'Conductor no logueado';
      notifyListeners();
    }
  }

  // Obtener el saludo concatenado con el nombre del conductor
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Buenos días, $driverName";
    } else if (hour < 18) {
      return "Buenas tardes, $driverName";
    } else {
      return "Buenas noches, $driverName";
    }
  }

  // Cargar preguntas desde Firebase
  Future<void> _loadQuestions() async {
    try {
      final DatabaseEvent event = await questionsRef.once();
      final DataSnapshot dataSnapshot = event.snapshot;

      List<Map<String, dynamic>> tempQuestions = [];

      for (var data in dataSnapshot.children) {
        final String? key = data.key;
        final questionData = Map<String, dynamic>.from(data.value as Map);

        if (questionData['isActive'] && key != null) {
          tempQuestions.add({
            'id': key,
            'text': questionData['text'],
          });
          // Inicializa la respuesta como "N/A"
          _responses[key] = 'N/A';
        }
      }

      questions = tempQuestions;
      notifyListeners();
    } catch (error) {
      print('Error al cargar las preguntas: $error');
    }
  }

  // Validar respuestas antes de guardar
  bool validateResponses() {
    for (var response in _responses.values) {
      if (response == 'N/A') {
        return false;
      }
    }
    return true;
  }

  // Reiniciar las respuestas después de guardar
  void resetResponses() {
    _responses.updateAll((key, value) => 'N/A');
    notifyListeners();
  }

  // Guardar el checklist en Firebase
  Future<String?> saveChecklist() async {
    if (isSaving) return 'Guardando en progreso'; // Evitar múltiples guardados

    if (!validateResponses()) return 'Complete todo el formulario antes de guardar'; // Validar respuestas

    isSaving = true;
    notifyListeners();

    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      isSaving = false;
      notifyListeners();
      return 'Debe estar autenticado para guardar el cuestionario';
    }

    final DatabaseReference checklistRef = FirebaseDatabase.instance.ref().child('drivers/${user.uid}/checklists');

    try {
      String checklistId = checklistRef.push().key!;
      await checklistRef.child(checklistId).set({
        'createdAt': DateTime.now().toIso8601String(),
        'responses': _responses,
      });
      resetResponses(); // Resetea las respuestas después de guardar con éxito
      return 'Cuestionario guardado con éxito';
    } catch (error) {
      return 'Error al guardar el cuestionario: $error';
    } finally {
      isSaving = false;
      getLastChecklistDate(); // Actualiza la fecha del último checklist
      fetchLastChecklistDate(); // Actualiza la fecha del último checklist
      notifyListeners();
    }
  }

 //Obtener la fecha  del ultimo cheklist
 Future<String> getLastChecklistDate() async {
    User? user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    return 'Usuario no autenticado';
  }

  try {
    // Referencia al checklist del usuario
    DatabaseReference checklistRef = FirebaseDatabase.instance.ref().child('drivers/${user.uid}/checklists');

    // Ordenamos por fecha y limitamos a uno (el último)
    final Query lastChecklistQuery = checklistRef.orderByChild('createdAt').limitToLast(1);

    DatabaseEvent event = await lastChecklistQuery.once();
    DataSnapshot snapshot = event.snapshot;

    if (snapshot.exists && snapshot.children.isNotEmpty) {
      // Obtenemos el primer (y único) elemento del snapshot
      DataSnapshot lastChecklist = snapshot.children.first;

      // Extraemos la fecha de creación del checklist
      String lastDate = lastChecklist.child('createdAt').value as String;

      return lastDate;
    } else {
      return 'No se encontró ningún checklist guardado';
    }
  } catch (e) {
    return 'Error al obtener la última fecha del checklist: $e';
  }
  }

Future<void> fetchLastChecklistDate() async {
  String? isoDate = await getLastChecklistDate(); 
    // Convertir la fecha ISO en un objeto DateTime
  DateTime parsedDate = DateTime.parse(isoDate);

  // Formatear la fecha en día/mes/año
  lastChecklistDate = '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
// Verifica si la fecha coincide con hoy
DateTime today = DateTime.now();
    isEnable = parsedDate.year == today.year && 
                    parsedDate.month == today.month && 
                    parsedDate.day == today.day;
    print('Fecha del último checklist: $lastChecklistDate');
     print('Fecha actual: ${today.day}/${today.month}/${today.year}');
    print('Formulario lleno hoy: $isEnable');
  notifyListeners(); // Notificar a los listeners que la UI debe actualizarse
}

// Obtener la respuesta seleccionada para una pregunta específica
String? getResponse(String questionId) {
  return _responses[questionId];
}

// Establecer la respuesta para una pregunta específica
void setResponse(String questionId, String response) {
  _responses[questionId] = response;
  notifyListeners(); // Actualiza la UI
}


}

 