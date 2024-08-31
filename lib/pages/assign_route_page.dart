import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AssignRoutePage extends StatefulWidget {
  const AssignRoutePage({super.key});

  @override
  State<AssignRoutePage> createState() => _AssignRoutePageState();
}

class _AssignRoutePageState extends State<AssignRoutePage> {
  String? selectedClientId;
  String? selectedDriverId;
  LatLng? clientHomePosition;
  LatLng? clientWorkPosition;

  final DatabaseReference clientsRef = FirebaseDatabase.instance.ref().child("users");
  final DatabaseReference driversRef = FirebaseDatabase.instance.ref().child("drivers");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Asignar Ruta"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Seleccionar Cliente:"),
            StreamBuilder(
              stream: clientsRef.onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                Map clients = snapshot.data!.snapshot.value as Map;
                List<DropdownMenuItem<String>> clientItems = clients.keys.map<DropdownMenuItem<String>>((key) {
                  String name = clients[key]["name"] ?? 'N/A';
                  String lastName = clients[key]["lastName"] ?? 'N/A';

                  return DropdownMenuItem<String>(
                    value: key,
                    child: Text('$name $lastName'),
                  );
                }).toList();

                return DropdownButton<String>(
                  value: selectedClientId,
                  items: clientItems,
                  onChanged: (value) {
                    setState(() {
                      selectedClientId = value;
                      clientHomePosition = LatLng(
                        clients[value]["directions"]["home"]["latitude"] ?? 0.0,
                        clients[value]["directions"]["home"]["longitude"] ?? 0.0
                      );
                      clientWorkPosition = LatLng(
                        clients[value]["directions"]["work"]["latitude"] ?? 0.0,
                        clients[value]["directions"]["work"]["longitude"] ?? 0.0
                      );
                    });
                  },
                  hint: const Text("Seleccionar Cliente"),
                );
              },
            ),
            const SizedBox(height: 16),
            const Text("Seleccionar Conductor:"),
            StreamBuilder(
              stream: driversRef.onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                Map drivers = snapshot.data!.snapshot.value as Map;
                List<DropdownMenuItem<String>> driverItems = drivers.keys.map<DropdownMenuItem<String>>((key) {
                  String name = drivers[key]["name"] ?? 'N/A';
                  String lastName = drivers[key]["lastName"] ?? 'N/A';

                  return DropdownMenuItem<String>(
                    value: key,
                    child: Text('$name $lastName'),
                  );
                }).toList();

                return DropdownButton<String>(
                  value: selectedDriverId,
                  items: driverItems,
                  onChanged: (value) {
                    setState(() {
                      selectedDriverId = value;
                    });
                  },
                  hint: const Text("Seleccionar Conductor"),
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (selectedClientId != null && selectedDriverId != null) {
                  assignRoute();
                }
              },
              child: const Text("Asignar Ruta"),
            ),
          ],
        ),
      ),
    );
  }

  void assignRoute() async {
    if (clientHomePosition != null && clientWorkPosition != null) {
      // Generar la ruta y asignarla al conductor
      DatabaseReference tripRequestRef = FirebaseDatabase.instance.ref().child("tripRequests").push();
      String tripId = tripRequestRef.key!;

      Map<String, dynamic> tripData = {
        "driverID": selectedDriverId,
        "clientID": selectedClientId,
        "pickUpAddress": clientHomePosition!.latitude.toString() + ", " + clientHomePosition!.longitude.toString(),
        "dropOffAddress": clientWorkPosition!.latitude.toString() + ", " + clientWorkPosition!.longitude.toString(),
        "status": "pending",
      };

      // Guardar el viaje en tripRequests
      await tripRequestRef.set(tripData);

      // Guardar el viaje en la tabla del conductor
      DatabaseReference driverTripsRef = FirebaseDatabase.instance.ref()
          .child("drivers")
          .child(selectedDriverId!)
          .child("trips")
          .child(tripId);

      await driverTripsRef.set(tripData);

      // Navegar de vuelta a la pantalla de inicio
      Navigator.pop(context);
    }
  }
}
