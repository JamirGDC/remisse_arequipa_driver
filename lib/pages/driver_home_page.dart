import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:remisse_arequipa_driver/global.dart';
import 'package:remisse_arequipa_driver/pages/check_list_page.dart';
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
  bool isFichado = false; // Estado del switch
  bool isSwitchEnabled = false; // Control de habilitación del switch
  Position? currentPositionOfDriver;
  DatabaseReference? newTripRequestReference;
  String lastFormDate="cargando...";
  String lastFormHour="cargando...";

  @override
  void initState() {
    super.initState();
    _getUserName();
    _checkFormCompletion(); // Verificar si el formulario está completado
    _fetchLastFormDate(); // Obtener la última fecha de formulario
  }

  Future<void> _getUserName() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        DatabaseReference driversRef = FirebaseDatabase.instance
            .ref()
            .child('drivers')
            .child(user.uid);

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
    // Aquí puedes definir la lógica para habilitar el switch
    // Según tus necesidades, puedes reemplazar esta parte con la lógica adecuada.
    // De momento, se mantendrá habilitado siempre.
    setState(() {
      isSwitchEnabled = true; // Habilitar el switch por defecto
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
                          onChanged: isSwitchEnabled ? (bool value) async {
                            setState(() {
                              isFichado = value;
                            });

                            if (isFichado) {
                              Position positionOfUser = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
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
                          } : null,
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
              style:const TextStyle(
                fontSize: 16.0,
                color: mutedColor,
              ),
            ),
            const SizedBox(height: 0.1),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: ChecklistPage(),
                ),
              ),
            ),
          ],
        ),
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
