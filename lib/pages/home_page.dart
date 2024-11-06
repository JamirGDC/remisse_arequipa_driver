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

class _HomePageState extends State<HomePage> {
  final Completer<GoogleMapController> googleMapCompleterController =
      Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  Position? currentPositionOfDriver;
  Color colorToShow = Colors.green;
  String titleToShow = "Conectarse";
  bool isDriverAvailable = false;
  DatabaseReference? newTripRequestReference;
  MapThemeMethods themeMethods = MapThemeMethods();
  String? driverPhoto;

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

    // Re-inicializar el `newTripRequestReference` si es null
    newTripRequestReference ??= FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("newTripStatus");

    // Dejar de compartir la ubicación en Geofire
    var id = FirebaseAuth.instance.currentUser!.uid;
    Geofire.removeLocation(id);

    // Eliminar el estado `waiting` de la base de datos
    await newTripRequestReference!.remove();

    // Desconectar la referencia
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

    retrieveCurrentDriverInfo();
    _getDriverAvailability();
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
                color: Colors.blue,
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
                // Navegar a inicio
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text("Viajes"),
              onTap: () {
                Navigator.pop(context);
                // Navegar a viajes
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Configuración"),
              onTap: () {
                Navigator.pop(context);
                // Navegar a configuración
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text("Ayuda"),
              onTap: () {
                Navigator.pop(context);
                // Navegar a ayuda
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Cerrar sesión"),
              onTap: () {
                Navigator.pop(context);
                // Cerrar sesión
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
                top: 100,
                left: 10,
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
      top: 100,
      right: 0,
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/perfil');
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: driverPhoto != null
                  ? NetworkImage(driverPhoto!)
                  : const AssetImage('assets/profile_placeholder.png')
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
      child: FloatingActionButton(
        onPressed: () {
          setState(() {
            isDriverAvailable = !isDriverAvailable;
            if (isDriverAvailable) {
              goOnlineNow();
              setAndGetLocationUpdates();
            } else {
              goOfflineNow();
            }
          });
        },
        backgroundColor: Colors.white,
        shape: const CircleBorder(),
        child: Icon(
          Icons.power_settings_new,
          color: isDriverAvailable ? Colors.green : Colors.pink,
        ),
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
