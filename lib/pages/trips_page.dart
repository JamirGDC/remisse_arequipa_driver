import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:remisse_arequipa_driver/pages/trips_history_page.dart';

class TripsPage extends StatefulWidget {
  const TripsPage({super.key});

  @override
  State<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> 
{
  String currentDriverTotalTripsCompleted = "";
  
  getCurrentDriverTotalNumberOfTripsCompleted() async
  {
    DatabaseReference tripRequestsRef = FirebaseDatabase.instance.ref().child("tripRequests");

    await tripRequestsRef.once().then((snap)async
    {
      if(snap.snapshot.value != null)
      {
        Map<dynamic, dynamic> allTripsMap = snap.snapshot.value as Map;

        List<String> tripsCompletedByCurrentDriver = [];

        allTripsMap.forEach((key, value)
        {
          if(value["status"] != null)
          {
            if(value["status"] == "ended")
            {
              if(value["driverID"] == FirebaseAuth.instance.currentUser!.uid)
              {
                tripsCompletedByCurrentDriver.add(key);
              }
            }
          }
        });

        setState(() {
          currentDriverTotalTripsCompleted = tripsCompletedByCurrentDriver.length.toString();
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    
    getCurrentDriverTotalNumberOfTripsCompleted();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          //Total Trips
          Center(
            child: Container(
              color: Colors.indigo,
              width: 300,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: [

                    Image.asset("lib/assets/totaltrips.png", width: 120,),

                    const SizedBox(
                      height: 10,
                    ),

                    const Text(
                      "Viajes Completados:",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),

                    Text(
                      currentDriverTotalTripsCompleted,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          //check trip history
          GestureDetector(
            onTap: ()
            {
              Navigator.push(context, MaterialPageRoute(builder: (c)=> const TripsHistoryPage()));
            },
            child: Center(
              child: Container(
                color: Colors.indigo,
                width: 300,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    children: [

                      Image.asset("lib/assets/tripscompleted.png", width: 150,),

                      const SizedBox(
                        height: 10,
                      ),

                      const Text(
                        "Historial de Servicios",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
