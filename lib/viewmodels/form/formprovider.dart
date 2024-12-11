import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:remisse_arequipa_driver/methods/common_methods.dart';

class Formprovider extends ChangeNotifier {
  // Variables
  String driverName = "";
  String? errorMessage; // Agregar variable para manejar mensajes de error
  final DatabaseReference questionsRef =
      FirebaseDatabase.instance.ref().child('questions');
  final Map<String, String> _responses =
      {}; // Usando String para almacenar las respuestas seleccionadas
  List<Map<String, dynamic>> questions = [];
  final List<String> options = [
    'Sí',
    'No'
  ]; // Opciones del checklist
  bool isSaving = false; // Variable para manejar el estado del botón
  String? lastHealthChecklistDate; // Fecha del último checklist de salud
  String? lastMechanicalChecklistDate; // Fecha del último checklist de mecánica
  bool? isEnableHealth = false; // Para habilitar el formulario de salud
  bool? isEnableMechanical = false; // Para habilitar el formulario de mecánica
  String? checklistType; // Tipo de checklist (salud o mecánica)
  bool get isBothFormsComplete {
    return (isEnableHealth ?? false) && (isEnableMechanical ?? false);
  } // Verificar si ambos formularios están completos
  CommonMethods cMethods = CommonMethods();

  // Constructor
  Formprovider() {
    // Inicializar variables
    _getUserName();
    fetchLastChecklistDate();
  }

// BOTONES
  void continueButton(BuildContext context) {
    Navigator.pushNamed(context, '/HomePage');
  }

  void healthFormButton(BuildContext context) async {
    checklistType = 'health'; // Establecer el tipo de checklist
    // Cargar preguntas de salud
    await _loadQuestions('questions_health');
// Navegar a la página del formulario de salud
    Navigator.pushNamed(context, '/formChecklist');
  }

  void mechanicalFormButton(BuildContext context) async {
    checklistType = 'mechanical'; // Establecer el tipo de checklist
// Cargar preguntas de mecánica
    await _loadQuestions('questions_machines');

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
  Future<void> _loadQuestions(String node) async {
    try {
      final DatabaseReference questionsRef =
          FirebaseDatabase.instance.ref().child('questions/$node');
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
       if (questions.isEmpty) {
        errorMessage = 'No se encontraron preguntas.';
      }

      notifyListeners();
    } catch (error) {
      errorMessage = 'Error al cargar las preguntas: $error';
      notifyListeners();
    }
  }

  // Validar respuestas antes de guardar
  bool validateResponses() {
    for (var entry in _responses.entries) {
      if (entry.value == 'N/A') {
        return false; // Devuelve false si hay respuestas no seleccionadas
      }
    }
    return true; // Devuelve true si todas las respuestas están completas
  }

  // Reiniciar las respuestas después de guardar
  void resetResponses() {
    _responses.updateAll((key, value) => 'N/A');
    notifyListeners();
  }

  // Guardar el checklist en Firebase
  Future<String?> saveChecklist() async {
    if (isSaving) return 'Guardando en progreso'; // Evitar múltiples guardados

    if (!validateResponses()) {
      return 'Complete todo el formulario antes de guardar'; // Validar respuestas
    }

    isSaving = true;
    notifyListeners();

    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      isSaving = false;
      notifyListeners();
      return 'Debe estar autenticado para guardar el cuestionario';
    }

    final DatabaseReference checklistRef =
        FirebaseDatabase.instance.ref().child('drivers/${user.uid}/checklists');

    try {
      String checklistId = checklistRef.push().key!;
      await checklistRef.child(checklistId).set({
        'createdAt': DateTime.now().toIso8601String(),
        'responses': _responses,
        'type': checklistType, // Guardar el tipo de checklist
      });
      resetResponses(); // Resetea las respuestas después de guardar con éxito
      return 'Cuestionario guardado con éxito';
    } catch (error) {
      return 'Error al guardar el cuestionario: $error';
    } finally {
      isSaving = false;
      fetchLastChecklistDate(); // Actualiza la fecha del último checklist
      _responses.clear(); // Limpiar las respuestas después de guardar
      notifyListeners();
    }
  }

  //Obtener la fecha  del ultimo cheklist
  Future<String?> getLastChecklistDate(String type) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return 'Usuario no autenticado';
    }

    try {
      // Referencia al checklist del usuario
      DatabaseReference checklistRef = FirebaseDatabase.instance
          .ref()
          .child('drivers/${user.uid}/checklists');

      // Ordenamos por fecha y limitamos a uno (el último)
      final Query lastChecklistQuery =
          checklistRef.orderByChild('type').equalTo(type).limitToLast(1);

      DatabaseEvent event = await lastChecklistQuery.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists && snapshot.children.isNotEmpty) {
        // Obtenemos el primer (y único) elemento del snapshot
        DataSnapshot lastChecklist = snapshot.children.first;

        // Extraemos la fecha de creación del checklist
        String lastDate = lastChecklist.child('createdAt').value as String;

        //convertimos la cadena iso en un objeto DateTime
        DateTime parsedDate = DateTime.parse(lastDate);

        //formateamos la fecha en un formato más legible
        String formattedDate =
            '${parsedDate.day.toString().padLeft(2, '0')}/${parsedDate.month.toString().padLeft(2, '0')}/${parsedDate.year}';

        lastDate = formattedDate;

        return lastDate;
      } else {
        return null; // Devuelve null si no hay checklist
      }
    } catch (e) {
      return 'Error al obtener la última fecha del checklist: $e';
    }
  }

// Función para formatear la fecha actual como 'dd/MM/yyyy'
  String formatDateToString(DateTime date) {
    String day = date.day
        .toString()
        .padLeft(2, '0'); // Asegura que el día tenga 2 dígitos
    String month = date.month
        .toString()
        .padLeft(2, '0'); // Asegura que el mes tenga 2 dígitos
    String year = date.year.toString();
    return "$day/$month/$year";
  }

  Future<void> fetchLastChecklistDate() async {
    String? healthChecklistDate = await getLastChecklistDate('health');
    String? mechanicalChecklistDate = await getLastChecklistDate('mechanical');

    // Actualizar las variables de fecha
    lastHealthChecklistDate = healthChecklistDate;
    lastMechanicalChecklistDate = mechanicalChecklistDate;

    // Formatear la fecha actual como dd/MM/yyyy
    String todayFormatted = formatDateToString(DateTime.now());

    // Verifica si la fecha de salud coincide con hoy
    isEnableHealth = healthChecklistDate == todayFormatted;

    // Verifica si la fecha de mecánica coincide con hoy
    isEnableMechanical = mechanicalChecklistDate == todayFormatted;

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
