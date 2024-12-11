import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:remisse_arequipa_driver/global.dart';
import 'package:remisse_arequipa_driver/methods/map_theme_methods.dart';
import 'package:remisse_arequipa_driver/pushNotification/push_notification_system.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final Completer<GoogleMapController> googleMapCompleterController =
      Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  Position? currentPositionOfDriver;
  Color colorToShow = Colors.green;
  String titleToShow = "Conectarse";
  bool isDriverAvailable = false;
  DatabaseReference? newTripRequestReference;
  MapThemeMethods themeMethods = MapThemeMethods();
  late AnimationController _animationController;

  getCurrentLiveLocationOfDriver() async {
    Position positionOfUser = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPositionOfDriver = positionOfUser;
    driverCurrentPosition = currentPositionOfDriver;

    LatLng positionOfUserInLatLng = LatLng(
        currentPositionOfDriver!.latitude, currentPositionOfDriver!.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: positionOfUserInLatLng, zoom: 15);
    controllerGoogleMap!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  goOnlineNow() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDriverAvailable', true);
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

  setAndGetLocationUpdates() {
    positionStreamHomePage =
        Geolocator.getPositionStream().listen((Position position) {
      currentPositionOfDriver = position;

      if (isDriverAvailable == true) {
        Geofire.setLocation(
          FirebaseAuth.instance.currentUser!.uid,
          currentPositionOfDriver!.latitude,
          currentPositionOfDriver!.longitude,
        );
      }

      LatLng positionLatLng = LatLng(position.latitude, position.longitude);
      controllerGoogleMap!
          .animateCamera(CameraUpdate.newLatLng(positionLatLng));
    });
  }

  goOfflineNow() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDriverAvailable', false);
    newTripRequestReference ??= FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("newTripStatus");

    var id = FirebaseAuth.instance.currentUser!.uid;
    Geofire.removeLocation(id);
    await newTripRequestReference!.remove();
    newTripRequestReference!.onDisconnect();
    newTripRequestReference = null;
  }

  initializePushNotificationSystem() {
    PushNotificationSystem notificationSystem = PushNotificationSystem();
    notificationSystem.generateDeviceRegistrationToken();
    notificationSystem.startListeningForNewNotification(context);
  }

  retrieveCurrentDriverInfo() async {
    await FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .once()
        .then((snap) {
      driverName = (snap.snapshot.value as Map)["name"];
      driverPhone = (snap.snapshot.value as Map)["phone"];
      driverPhoto = (snap.snapshot.value as Map)["photo"];
      carColor = (snap.snapshot.value as Map)["car_details"]["carColor"];
      carModel = (snap.snapshot.value as Map)["car_details"]["carModel"];
      carNumber = (snap.snapshot.value as Map)["car_details"]["carNumber"];

      setState(() {}); // Actualizar la interfaz para mostrar la imagen
    });

    initializePushNotificationSystem();
  }

  void _getDriverAvailability() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? driverAvailable = prefs.getBool('isDriverAvailable');

    setState(() {
      isDriverAvailable = driverAvailable ?? false;
      colorToShow = isDriverAvailable ? Colors.pink : Colors.green;
      titleToShow = isDriverAvailable ? "Desconectarse" : "Conectarse";

      if (isDriverAvailable) {
        newTripRequestReference = FirebaseDatabase.instance
            .ref()
            .child("drivers")
            .child(FirebaseAuth.instance.currentUser!.uid)
            .child("newTripStatus");
      }
    });
  }

   @override
  void initState() {
    super.initState();

    // Inicializa el controlador de animación para el efecto radar
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    retrieveCurrentDriverInfo();
    _getDriverAvailability();
  }


  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: brandColor,
              ),
              child: Text(
                'Menú',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Inicio"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text("Servicios"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Configuración"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text("Ayuda"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Cerrar sesión"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            padding: const EdgeInsets.only(bottom: 50, right: 3, top: 130),
            mapType: MapType.normal,
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            initialCameraPosition: kArequipa,
            onMapCreated: (GoogleMapController mapController) {
              controllerGoogleMap = mapController;
              themeMethods.updateMapTheme(controllerGoogleMap!);
              googleMapCompleterController.complete(controllerGoogleMap);
              getCurrentLiveLocationOfDriver();
            },
          ),
          Builder(
            builder: (BuildContext context) {
              return Positioned(
                top: 55,
                left: 15,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.menu, color: Colors.black),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            top: 70,
            right: 0,
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/Profile');
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: 
                        NetworkImage(driverPhoto)
                        
                            as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 30,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Añadir el efecto de radar solo si el modo online está activo
                if (isDriverAvailable)
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                    return Transform.scale(
                      scale: 1 + _animationController.value * 0.5, // Factor de escala para el efecto de expansión
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green.withOpacity(1 - _animationController.value),
                        ),
                      ),
                    );
                  },

                  ),
                FloatingActionButton(
                  onPressed: () async {
                    if (!isDriverAvailable) {
                      bool? confirmOnline = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Confirmar"),
                            content: const Text(
                                "Vas a empezar a recibir solicitudes de viajes"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                                child: const Text("Cancelar"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                                child: const Text("Aceptar"),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirmOnline == true) {
                        showDialog(
                          // ignore: use_build_context_synchronously
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return const Dialog(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(width: 20),
                                    Text("Entrando al Modo Online"),
                                  ],
                                ),
                              ),
                            );
                          },
                        );

                        await Future.delayed(const Duration(milliseconds: 200));

                        await goOnlineNow();
                        await setAndGetLocationUpdates();

                        setState(() {
                          isDriverAvailable = true;
                        });

                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      }
                    } else {
                      bool? confirmOffline = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Confirmar"),
                            content: const Text(
                                "Vas a dejar de recibir solicitudes de viajes"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(false); // Cancelar
                                },
                                child: const Text("Cancelar"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true); // Confirmar
                                },
                                child: const Text("Aceptar"),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirmOffline == true) {
                        showDialog(
                          // ignore: use_build_context_synchronously
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return const Dialog(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(width: 20),
                                    Text("Saliendo del Modo Online"),
                                  ],
                                ),
                              ),
                            );
                          },
                        );

                        await Future.delayed(const Duration(milliseconds: 200));
                        await goOfflineNow();

                        setState(() {
                          isDriverAvailable = false;
                        });

                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      }
                    }
                  },
                  backgroundColor: Colors.white,
                  shape: const CircleBorder(),
                  child: Icon(
                    Icons.power_settings_new,
                    color: isDriverAvailable ? Colors.green : Colors.pink,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: FloatingActionButton(
              onPressed: () {
                getCurrentLiveLocationOfDriver();
              },
              backgroundColor: Colors.white,
              shape: const CircleBorder(),
              child: const Icon(Icons.my_location, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
