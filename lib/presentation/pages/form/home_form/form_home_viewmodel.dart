import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:remisse_arequipa_driver/domain/usecases/form_home_usercase.dart';
import 'package:remisse_arequipa_driver/presentation/pages/form/form_check_list/form_check_list.dart';

class FormHomeViewModel extends ChangeNotifier {
  final FormHomeUseCase formHomeUseCase;
  String? errorMessage;
  String? driverName;
  String? greeting;
  bool? isEnableHealth = false;
  bool? isEnableMechanical = false;
  String? lastMechanicalChecklistDate;
  String? lastHealthChecklistDate;
  String? checklistType;
  List<Map<String, dynamic>> questions = [];
  final Map<String, String> _responses = {};
  bool isSaving = false;

  List<String> get options => ['N/A', 'Sí', 'No'];

  bool get isBothFormsComplete {
    return (isEnableHealth ?? false) && (isEnableMechanical ?? false);
  }

  FormHomeViewModel(this.formHomeUseCase);

  Future<String?> getDriverName() async {
    final result = await formHomeUseCase.getUserInfo();
    return result.fold(
      (failure) {
        errorMessage = failure.message;
        notifyListeners();
        return null;
      },
      (infoUser) {
        return infoUser.name!;
      },
    );
  }

  Future<void> getGreeting() async {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) {
      greeting = "Buenos días ☀️";
    } else if (hour >= 12 && hour < 18) {
      greeting = "Buenas tardes 🌄";
    } else {
      greeting = "Buenas noches 🌙";
    }
    notifyListeners();
  }

  Future<void> loadDriverName() async {
    final name = await getDriverName();
    if (name != null) {
      driverName = name;
      notifyListeners();
    }
  }

  void healthFormButton(BuildContext context) async {
    checklistType = 'health';
    await _loadQuestions('questions_health');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FormCheckListScreen(),
      ),
    );
  }

  void mechanicalFormButton(BuildContext context) async {
    checklistType = 'mechanical';
    await _loadQuestions('questions_machines');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FormCheckListScreen(),
      ),
    );
  }

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

  String? getResponse(String questionId) {
    return _responses[questionId];
  }

  void setResponse(String questionId, String response) {
    _responses[questionId] = response;
    notifyListeners();
  }

  Future<String?> saveChecklist() async {
    isSaving = true;
    notifyListeners();
    User? user = FirebaseAuth.instance.currentUser;
    final DatabaseReference checklistRef = FirebaseDatabase.instance
        .ref()
        .child('drivers/${user?.uid}/checklists');
    try {
      String checklistId = checklistRef.push().key!;

      await checklistRef.child(checklistId).set({
        'createdAt': DateTime.now().toIso8601String(),
        'responses': _responses,
        'type': checklistType,
      });

      if (checklistType == 'health') {
        isEnableHealth = true;
      }

      if (checklistType == 'mechanical') {
        isEnableMechanical = true;
      }

      isSaving = false;
      notifyListeners();
      return 'Cuestionario guardado con éxito';
    } catch (e) {
      isSaving = false;
      errorMessage = 'Error al guardar el cuestionario: $e';
      notifyListeners();
      return errorMessage;
    } finally {
      isSaving = false;
      fetchLastChecklistDate();
      _responses.clear();
      notifyListeners();
    }
  }

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
}
