import 'package:flutter/material.dart';
import 'package:remisse_arequipa_driver/global.dart';
import 'package:remisse_arequipa_driver/pages/home_page.dart';
import 'package:remisse_arequipa_driver/pages/profile_page.dart';
import 'package:remisse_arequipa_driver/pages/trips_history_page.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int indexSelected = 0;

  onBarItemClicked(int i) {
    setState(() {
      indexSelected = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 199, 0, 0),
      body: Stack(
        children: [
          IndexedStack(
            index: indexSelected,
            children: const [
              HomePage(),         // Pantalla con el mapa
              TripsHistoryPage(),  // Pantalla del historial
              ProfilePage(),       // Pantalla de perfil
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 0),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: BottomNavigationBar(
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: "Inicio",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.account_tree),
                      label: "Servicios",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      label: "Mi Perfil",
                    ),
                  ],
                  currentIndex: indexSelected,
                  unselectedItemColor: const Color.fromARGB(255, 68, 68, 68),
                  selectedItemColor: brandColor,
                  showSelectedLabels: true,
                  selectedLabelStyle: const TextStyle(fontSize: 12),
                  type: BottomNavigationBarType.fixed,
                  onTap: onBarItemClicked,
                  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
