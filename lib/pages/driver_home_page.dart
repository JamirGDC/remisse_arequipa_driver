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
  int totalWorkMinutes = 0;
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
    _loadTotalWorkMinutes();
  }

  Future<void> _loadTotalWorkMinutes() async {
    int minutes = await _getTotalWorkMinutes();
    if (mounted) {
      setState(() {
        totalWorkMinutes = minutes;
      });
    }
  }

  Future<void> _getUserName() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        DatabaseReference driversRef =
            FirebaseDatabase.instance.ref().child('drivers').child(user.uid);

        DatabaseEvent event = await driversRef.once();
        DataSnapshot snapshot = event.snapshot;

        if (snapshot.exists && mounted) {
          setState(() {
            driverName = snapshot.child('name').value as String? ?? 'Conductor';
          });
        } else if (mounted) {
          setState(() {
            driverName = 'Conductor no encontrado';
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            driverName = 'Error al obtener el nombre';
          });
        }
      }
    } else if (mounted) {
      setState(() {
        driverName = 'Conductor no logueado';
      });
    }
  }

  Future<void> _fetchLastFormDate() async {
    Map<String, String> dateTime = await CommonMethods.getLastFormFilledDate();
    if (mounted) {
      setState(() {
        lastFormDate = dateTime["date"] ?? "Cargando...";
        lastFormHour = dateTime["time"] ?? "";
      });
    }
  }

  Future<void> _checkFormCompletion() async {
    final now = DateTime.now();
    final today = '${now.day}-${now.month}-${now.year}';

    if (mounted) {
      setState(() {
        if (lastFormDate == today) {
          isSwitchEnabled = true;
        } else {
          isSwitchEnabled = false;
        }
      });
    }
  }

  void _loadQuestions() async {
    try {
      DatabaseEvent event = await _questionsRef.once();
      final dataSnapshot = event.snapshot;
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

      if (mounted) {
        setState(() {
          _questions = tempQuestions;
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar las preguntas: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _validateResponses() {
    for (var response in _responses.values) {
      if (response == 'N/A') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, rellene todo el formulario antes de guardar.'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    }
    return true;
  }

  void _resetResponses() {
    if (mounted) {
      setState(() {
        _responses.updateAll((key, value) => 'N/A');
      });
    }
  }

  void _saveChecklist() async {
  if (_isSaving) return;

  if (!_validateResponses()) return;

  if (mounted) {
    setState(() {
      _isSaving = true;
    });
  }

  User? user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe estar autenticado para guardar el cuestionario'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isSaving = false;
      });
    }
    return;
  }

  final DatabaseReference checklistRef =
      FirebaseDatabase.instance.ref().child('drivers/${user.uid}/checklists');

  String checklistId = checklistRef.push().key!;

  try {
    await checklistRef.child(checklistId).set({
      'createdAt': DateTime.now().toIso8601String(),
      'responses': _responses,
    });

    print("Checklist guardado correctamente."); // Verifica que esto se imprime

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cuestionario guardado con éxito'),
          backgroundColor: Colors.green,
        ),
      );
      _resetResponses();
    }
  } catch (error) {
    print("Error al guardar el checklist: $error"); // Verifica si ocurre algún error
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar el cuestionario: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    // Esta parte se ejecutará siempre, independientemente de si hubo error o no
    await _resetWorkHours(); // Resetea las horas trabajadas

    if (mounted) {
      setState(() {
        _isSaving = false;
        isSwitchEnabled = false; // Desactivar el botón flotante
      });

      await _fetchLastFormDate();
      await _checkFormCompletion();
    }
  }
}

  // Nueva función para reiniciar las horas trabajadas
Future<void> _resetWorkHours() async {

   print("Intentando resetear horas trabajadas...");
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    DatabaseReference workHoursRef = FirebaseDatabase.instance
        .ref()
        .child('drivers/${user.uid}/workHours');

    String today = DateTime.now().toIso8601String().split('T')[0];
    await workHoursRef.child('$today/totalHours').set(0);

    if (mounted) {
      setState(() {
        totalWorkMinutes = 0;
      });
    }
    print("Work hours reset successfully.");
  }
}

  void goOnlineNow() async {
    int totalMinutes = await _getTotalWorkMinutes();

    if (totalMinutes >= 420) { // 7 horas * 60 minutos = 420 minutos
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jornada laboral de 7 horas terminada'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          isFichado = false;
          isSwitchEnabled = false;
        });
      }
      return;
    }

    Geofire.initialize("onlineDrivers");
    await _saveWorkStartTime();
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

  void goOfflineNow() async {
    Geofire.removeLocation(FirebaseAuth.instance.currentUser!.uid);
    newTripRequestReference!.onDisconnect();
    newTripRequestReference!.remove();
    newTripRequestReference = null;

    await _saveWorkEndTimeAndCalculateHours();
    await _loadTotalWorkMinutes();

    int totalMinutes = await _getTotalWorkMinutes();
    if (totalMinutes >= 420) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jornada laboral de 7 horas terminada'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          isFichado = false;
          isSwitchEnabled = false;
        });
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _saveWorkStartTime() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DatabaseReference workHoursRef = FirebaseDatabase.instance
          .ref()
          .child('drivers/${user.uid}/workHours');

      String today = DateTime.now().toIso8601String().split('T')[0];
      await workHoursRef.child('$today/startTimeWork').set(DateTime.now().toIso8601String());
    }
  }

  Future<void> _saveWorkEndTimeAndCalculateHours() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DatabaseReference workHoursRef = FirebaseDatabase.instance
          .ref()
          .child('drivers/${user.uid}/workHours');

      String today = DateTime.now().toIso8601String().split('T')[0];
      await workHoursRef.child('$today/endTimeWork').set(DateTime.now().toIso8601String());

      DatabaseEvent startTimeEvent = await workHoursRef.child('$today/startTimeWork').once();
      DatabaseEvent endTimeEvent = await workHoursRef.child('$today/endTimeWork').once();

      DataSnapshot startTimeSnapshot = startTimeEvent.snapshot;
      DataSnapshot endTimeSnapshot = endTimeEvent.snapshot;

      if (startTimeSnapshot.exists && endTimeSnapshot.exists) {
        DateTime startTime = DateTime.parse(startTimeSnapshot.value as String);
        DateTime endTime = DateTime.parse(endTimeSnapshot.value as String);

        Duration workDuration = endTime.difference(startTime);

        DatabaseEvent totalMinutesEvent = await workHoursRef.child('$today/totalHours').once();
        DataSnapshot totalMinutesSnapshot = totalMinutesEvent.snapshot;

        int previousTotalMinutes = 0;
        if (totalMinutesSnapshot.exists) {
          previousTotalMinutes = totalMinutesSnapshot.value as int;
        }

        int newTotalMinutes = previousTotalMinutes + workDuration.inMinutes;

        await workHoursRef.child('$today/totalHours').set(newTotalMinutes);

        if (newTotalMinutes >= 420) {
          if (mounted) {
            setState(() {
              isFichado = false;
              isSwitchEnabled = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Jornada laboral de 7 horas terminada'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  Future<int> _getTotalWorkMinutes() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DatabaseReference workHoursRef = FirebaseDatabase.instance
          .ref()
          .child('drivers/${user.uid}/workHours');

      String today = DateTime.now().toIso8601String().split('T')[0];
      DatabaseEvent totalMinutesEvent = await workHoursRef.child('$today/totalHours').once();
      DataSnapshot totalMinutesSnapshot = totalMinutesEvent.snapshot;

      if (totalMinutesSnapshot.exists) {
        return totalMinutesSnapshot.value as int;
      }
    }

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final String today = getFormattedDate();
    final int hours = totalWorkMinutes ~/ 60;
    final int minutes = totalWorkMinutes % 60;

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
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: brandColor),
                      const SizedBox(width: 8.0),
                      Text(
                        '${hours}h ${minutes}m',
                        style: const TextStyle(
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
                                            desiredAccuracy: LocationAccuracy.bestForNavigation);
                                    currentPositionOfDriver = positionOfUser;
                                    goOnlineNow();
                                  } else {
                                    goOfflineNow();
                                  }

                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(isFichado
                                            ? 'Fichado con éxito'
                                            : 'Desfichado con éxito'),
                                        backgroundColor: acentColor,
                                      ),
                                    );
                                  }
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
                            border: Border.all(color: const Color.fromARGB(255, 252, 252, 252)),
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
                                    fontSize: 16.0, fontWeight: FontWeight.bold),
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
                                        activeColor: const Color.fromARGB(255, 205, 87, 24),
                                        onChanged: (String? value) {
                                          if (mounted) {
                                            setState(() {
                                              _responses[question['id']] = value!;
                                            });
                                          }
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
        onPressed: (_isSaving || !isSwitchEnabled) ? null : _saveChecklist,
  child: _isSaving ? const CircularProgressIndicator() : const Icon(Icons.save),
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
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return '${now.day} ${months[now.month - 1]}';
  }
}
