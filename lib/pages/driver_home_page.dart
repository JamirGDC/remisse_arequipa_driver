import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:remisse_arequipa_driver/global.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:remisse_arequipa_driver/methods/common_methods.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  _DriverHomePageState createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  String driverName = "Conductor";
  bool isFichado = false;
  bool isSwitchEnabled = false;
  Position? currentPositionOfDriver;
  DatabaseReference? newTripRequestReference;
  String lastFormDate = "cargando...";
  String lastFormHour = "cargando...";

  final DatabaseReference _questionsRef =
      FirebaseDatabase.instance.ref().child('questions');
  final Map<String, String> _responses = {};
  List<Map<String, dynamic>> _questions = [];
  final List<String> _options = ['N/A', 'Sí', 'No'];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _getUserName();
     _fetchLastFormDate().then((_) {
    _checkFormCompletion();
  });
    _loadQuestions();
  }

  Future<void> _getUserName() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        DatabaseReference driversRef =
            FirebaseDatabase.instance.ref().child('drivers').child(user.uid);

        DatabaseEvent event = await driversRef.once();
        DataSnapshot snapshot = event.snapshot;

        if (snapshot.exists) {
          setState(() {
            driverName = snapshot.child('name').value as String? ?? 'Conductor';
          });
        } else {
          setState(() {
            driverName = 'Conductor no encontrado';
          });
        }
      } catch (e) {
        setState(() {
          driverName = 'Error al obtener el nombre';
        });
      }
    } else {
      setState(() {
        driverName = 'Conductor no logueado';
      });
    }
  }

  Future<void> _fetchLastFormDate() async {
    Map<String, String> dateTime = await CommonMethods.getLastFormFilledDate();
    setState(() {
      lastFormDate = dateTime["date"] ?? "Cargando...";
      lastFormHour = dateTime["time"] ?? "";
    });
    
  }

  Future<void> _checkFormCompletion() async {

  // Obtén la fecha actual
  final now = DateTime.now();
  final today ='${now.day}-${now.month}-${now.year}';


 // Imprime las fechas para depuración
  print("Fecha del último formulario: $lastFormDate");
  print("Fecha de hoy: $today");
  // Compara las fechas y habilita o deshabilita el switch
  setState(() {
    if (lastFormDate == today) {
       print("Las fechas coinciden. Habilitando el switch.");
      isSwitchEnabled = true;
    } else {
      print("Las fechas no coinciden. Deshabilitando el switch.");
      isSwitchEnabled = false;
    }
  });
  }

  void _loadQuestions() async {
    _questionsRef.once().then((DatabaseEvent event) {
      final dataSnapshot = event.snapshot;
      List<Map<String, dynamic>> tempQuestions = [];

      dataSnapshot.children.forEach((data) {
        final String? key = data.key;
        final questionData = Map<String, dynamic>.from(data.value as Map);

        if (questionData['isActive'] && key != null) {
          tempQuestions.add({
            'id': key,
            'text': questionData['text'],
          });
          _responses[key] = 'N/A';
        }
      });

      setState(() {
        _questions = tempQuestions;
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar las preguntas: $error'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  bool _validateResponses() {
    for (var response in _responses.values) {
      if (response == 'N/A') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Por favor, rellene todo el formulario antes de guardar.'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    }
    return true;
  }

  void _resetResponses() {
    setState(() {
      _responses.updateAll((key, value) => 'N/A');
    });
  }

  void _saveChecklist() async {
    if (_isSaving) return;

    if (!_validateResponses()) return;

    setState(() {
      _isSaving = true;
    });

    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe estar autenticado para guardar el cuestionario'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isSaving = false;
      });
      return;
    }

    final DatabaseReference checklistRef =
        FirebaseDatabase.instance.ref().child('drivers/${user.uid}/checklists');

    String checklistId = checklistRef.push().key!;
    await checklistRef.child(checklistId).set({
      'createdAt': DateTime.now().toIso8601String(),
      'responses': _responses,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cuestionario guardado con éxito'),
          backgroundColor: Colors.green,
        ),
      );
      _resetResponses();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar el cuestionario: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }).whenComplete(() async {
    setState(() {
      _isSaving = false;
    });

    // Espera a que _fetchLastFormDate se complete antes de continuar
    await _fetchLastFormDate();
    await _checkFormCompletion();
  });
  }

  void goOnlineNow() {
    Geofire.initialize("onlineDrivers");

    Geofire.setLocation(
      FirebaseAuth.instance.currentUser!.uid,
      currentPositionOfDriver!.latitude,
      currentPositionOfDriver!.longitude,
    );

    newTripRequestReference = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("newTripStatus");
    newTripRequestReference!.set("waiting");

    newTripRequestReference!.onValue.listen((event) {});
  }

  void goOfflineNow() {
    Geofire.removeLocation(FirebaseAuth.instance.currentUser!.uid);
    newTripRequestReference!.onDisconnect();
    newTripRequestReference!.remove();
    newTripRequestReference = null;
  }

  @override
  Widget build(BuildContext context) {
    final String today = getFormattedDate();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: neutralColor,
      ),
      backgroundColor: neutralColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${getGreeting()}, $driverName',
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: contrastColor,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Hoy, $today',
              style: const TextStyle(
                fontSize: 18.0,
                color: mutedColor,
              ),
            ),
            const SizedBox(height: 20.0),
            Container(
              decoration: BoxDecoration(
                color: neutralColor,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.access_time, color: brandColor),
                      SizedBox(width: 8.0),
                      Text(
                        '0h 00m',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: contrastColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Hoy',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: contrastColor,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isFichado ? 'Activo' : 'Inactivo',
                        style: const TextStyle(
                          fontSize: 16.0,
                          color: contrastColor,
                        ),
                      ),
                      Transform.scale(
                        scale: 1.5,
                        child: Switch(
                          value: isFichado,
                          onChanged: isSwitchEnabled
                              ? (bool value) async {
                                  setState(() {
                                    isFichado = value;
                                  });

                                  if (isFichado) {
                                    Position positionOfUser =
                                        await Geolocator.getCurrentPosition(
                                            desiredAccuracy: LocationAccuracy
                                                .bestForNavigation);
                                    currentPositionOfDriver = positionOfUser;
                                    goOnlineNow();
                                  } else {
                                    goOfflineNow();
                                  }

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(isFichado
                                          ? 'Fichado con éxito'
                                          : 'Desfichado con éxito'),
                                      backgroundColor: acentColor,
                                    ),
                                  );
                                }
                              : null,
                          activeColor: gradienteEndColor,
                          inactiveThumbColor: mutedColor,
                          inactiveTrackColor: mutedColor.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            const Text(
              'Última vez que se rellenó el formulario:',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: contrastColor,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              'Fecha: $lastFormDate, Hora: $lastFormHour',
              style: const TextStyle(
                fontSize: 16.0,
                color: mutedColor,
              ),
            ),
            const SizedBox(height: 20.0),
            _questions.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView(
                      children: _questions.map((question) {
                        return Container(
                          margin: const EdgeInsets.all(8.0),
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                                color:
                                    const Color.fromARGB(255, 252, 252, 252)),
                            borderRadius: BorderRadius.circular(20.0),
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
                                style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8.0),
                              Wrap(
                                spacing: 10.0,
                                children: _options.map((option) {
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Radio<String>(
                                        value: option,
                                        groupValue: _responses[question['id']],
                                        activeColor: const Color.fromARGB(
                                            255, 205, 87, 24),
                                        onChanged: (String? value) {
                                          setState(() {
                                            _responses[question['id']] = value!;
                                          });
                                        },
                                      ),
                                      Text(option),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isSaving ? null : _saveChecklist,
        child: _isSaving ? CircularProgressIndicator() : const Icon(Icons.save),
      ),
    );
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Buenos días";
    } else if (hour < 18) {
      return "Buenas tardes";
    } else {
      return "Buenas noches";
    }
  }

  String getFormattedDate() {
    final now = DateTime.now();
    final months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre'
    ];
    return '${now.day} ${months[now.month - 1]}';
  }
}
