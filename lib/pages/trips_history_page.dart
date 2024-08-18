import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:remisse_arequipa_driver/pages/dashboard.dart';

class TripsHistoryPage extends StatefulWidget {
  const TripsHistoryPage({super.key});

  @override
  State<TripsHistoryPage> createState() => _TripsHistoryPageState();
}

class _TripsHistoryPageState extends State<TripsHistoryPage> {
  late DatabaseReference tripRequestsRef;
  late String currentDriverId;

  @override
  void initState() {
    super.initState();
    currentDriverId = FirebaseAuth.instance.currentUser!.uid;
    tripRequestsRef = FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(currentDriverId)
        .child("trips");
  }

  void navigateToHomeWithRoute(String tripKey, LatLng startLocation, LatLng endLocation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Dashboard(
          initialTabIndex: 0, // Navegar a la página de inicio (HomePage)
          tripKey: tripKey, // Pasar el tripKey al Dashboard
          startLocation: startLocation, // Pasar la ubicación de inicio
          endLocation: endLocation, // Pasar la ubicación de destino
        ),
      ),
    );
  }

  void updateTripStatus(String tripKey, String newStatus) {
    // Referencia al viaje específico en la base de datos
    DatabaseReference tripRef = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("trips")
        .child(tripKey);

    // Actualizar el estado del viaje en la base de datos
    tripRef.update({
      "status": newStatus,
    }).then((_) {
      print("Trip status updated to $newStatus");
    }).catchError((error) {
      print("Failed to update trip status: $error");
    });
  }

  LatLng _parseLatLng(String address) {
    final parts = address.split(',');
    return LatLng(
      double.parse(parts[0].trim()), // latitud
      double.parse(parts[1].trim()), // longitud
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mis Viajes',
          style: TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 0, 0, 0)),
        ),
      ),
      body: StreamBuilder(
        stream: tripRequestsRef.onValue,
        builder: (BuildContext context, snapshotData) {
          if (snapshotData.hasError) {
            return const Center(
              child: Text(
                "Ocurrió un error.",
                style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
              ),
            );
          }

          if (!snapshotData.hasData || snapshotData.data!.snapshot.value == null) {
            return const Center(
              child: Text(
                "No se encontraron registros.",
                style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
              ),
            );
          }

          Map dataTrips = snapshotData.data!.snapshot.value as Map;
          List tripsList = [];
          dataTrips.forEach((key, value) => tripsList.add({"key": key, ...value}));

          return ListView.builder(
            shrinkWrap: true,
            itemCount: tripsList.length,
            itemBuilder: ((context, index) {
              // Variable para almacenar el nombre del cliente y la empresa
              String clientName = tripsList[index]["clientName"] ?? "Cliente Desconocido";
              String companyName = tripsList[index]["companyName"] ?? "Empresa Desconocida";

              // Formatear la fecha y hora de recogida
              String? pickUpTimeString;
              if (tripsList[index]["pickUpTime"] != null) {
                DateTime pickUpTime = DateTime.parse(tripsList[index]["pickUpTime"]);
                pickUpTimeString = DateFormat('dd/MM/yyyy hh:mm a').format(pickUpTime);
              }

              // Obtener direcciones como objetos LatLng
              LatLng startLocation = _parseLatLng(tripsList[index]["pickUpAddress"]);
              LatLng endLocation = _parseLatLng(tripsList[index]["dropOffAddress"]);

              // Obtener el estado del viaje
              String tripStatus = tripsList[index]["status"] ?? "Desconocido";

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        clientName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        companyName,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (pickUpTimeString != null) ...[
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Colors.blue, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              pickUpTimeString,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                      Row(
                        children: [
                          const Icon(Icons.location_pin, color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              tripsList[index]["pickUpAddress"],
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.flag, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              tripsList[index]["dropOffAddress"],
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (tripStatus == "pending")
                            ElevatedButton(
                              onPressed: () {
                                updateTripStatus(tripsList[index]["key"], "accepted");
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white, backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: const Text("Aceptar Viaje"),
                            ),
                          if (tripStatus == "accepted")
                            ElevatedButton(
                              onPressed: () {
                                navigateToHomeWithRoute(tripsList[index]["key"], startLocation, endLocation);
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white, backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: const Text("Ver Ruta"),
                            ),
                          if (tripStatus == "completed")
                            const Text(
                              "Viaje Finalizado",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
