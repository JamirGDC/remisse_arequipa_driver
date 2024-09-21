import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class TripsHistoryPage extends StatefulWidget {
  const TripsHistoryPage({super.key});

  @override
  State<TripsHistoryPage> createState() => _TripsHistoryPageState();
}

class _TripsHistoryPageState extends State<TripsHistoryPage> {
  final completedTripRequestsOfCurrentDriver = FirebaseDatabase.instance.ref().child("tripRequests");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 5.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInDown(
                  delay: const Duration(milliseconds: 800),
                  duration: const Duration(milliseconds: 900),
                  child: Text(
                    'Historial de Servicios',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Aquí usamos Expanded para que el ListView pueda hacer scroll
          Expanded(
            child: StreamBuilder(
              stream: completedTripRequestsOfCurrentDriver.onValue,
              builder: (BuildContext context, snapshotData) {
                if (snapshotData.hasError) {
                  return const Center(
                    child: Text(
                      "Error Occurred.",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                if (!snapshotData.hasData) {
                  return const Center(
                    child: Text(
                      "No record found.",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                Map dataTrips = snapshotData.data!.snapshot.value as Map;
                List tripsList = [];
                dataTrips.forEach((key, value) => tripsList.add({"key": key, ...value}));

                return ListView.builder(
                  itemCount: tripsList.length,
                  itemBuilder: ((context, index) {
                    if (tripsList[index]["status"] != null &&
                        tripsList[index]["status"] == "ended" &&
                        tripsList[index]["driverID"] == FirebaseAuth.instance.currentUser!.uid) {
                      return Card(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Pickup - fare amount
                              Row(
                                children: [
                                  Image.asset('lib/assets/initial.png', height: 16, width: 16),
                                  const SizedBox(width: 18),
                                  Expanded(
                                    child: Text(
                                      tripsList[index]["pickUpAddress"].toString(),
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    "S/. ${tripsList[index]["fareAmount"]}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Dropoff
                              Row(
                                children: [
                                  Image.asset('lib/assets/final.png', height: 16, width: 16),
                                  const SizedBox(width: 18),
                                  Expanded(
                                    child: Text(
                                      tripsList[index]["dropOffAddress"].toString(),
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
