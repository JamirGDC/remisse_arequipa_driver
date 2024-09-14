
import 'package:flutter/material.dart';
//import 'package:remisse_arequipa_driver/pages/driver_home_page.dart';
import 'package:remisse_arequipa_driver/pages/home_page.dart';
import 'package:remisse_arequipa_driver/pages/drivermainscreen.dart';
import 'package:remisse_arequipa_driver/pages/profile_page.dart';
import 'package:remisse_arequipa_driver/pages/trips_page.dart';


class Dashboard extends StatefulWidget
{
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}



class _DashboardState extends State<Dashboard> with SingleTickerProviderStateMixin
{
  TabController? controller;
  int indexSelected = 0;


  onBarItemClicked(int i)
  {
    setState(() {
      indexSelected = i;
      controller!.index = indexSelected;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    controller = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: controller,
        children: const [
          HomePage(),
          DriverMainScreen(),
          TripsPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const
        [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Inicio"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.check),
              label: "Checkings"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_tree),
              label: "Servicios"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Mi Perfil"
          ),
        ],
        currentIndex: indexSelected,
        //backgroundColor: Colors.grey,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.pink,
        showSelectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 12),
        type: BottomNavigationBarType.fixed,
        onTap: onBarItemClicked,
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:remisse_arequipa_driver/global.dart';
// import 'package:remisse_arequipa_driver/pages/driver_home_page.dart';
// import 'package:remisse_arequipa_driver/pages/home_page.dart';
// import 'package:remisse_arequipa_driver/pages/profile_page.dart';
// import 'package:remisse_arequipa_driver/pages/trips_history_page.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class Dashboard extends StatefulWidget {
//   final int initialTabIndex;
//   final String? tripKey;
//   final LatLng? startLocation;
//   final LatLng? endLocation;

//   const Dashboard({super.key, this.initialTabIndex = 0, this.tripKey, this.startLocation, this.endLocation});

//   @override
//   State<Dashboard> createState() => _DashboardState();
// }

// class _DashboardState extends State<Dashboard> with SingleTickerProviderStateMixin {
//   TabController? controller;
//   int indexSelected = 0;

//   @override
//   void initState() {
//     super.initState();

//     controller = TabController(length: 4, vsync: this);
//     indexSelected = widget.initialTabIndex;
//     controller!.index = indexSelected;
//   }

//   @override
//   void dispose() {
//     controller!.dispose();
//     super.dispose();
//   }

//   onBarItemClicked(int i) {
//     setState(() {
//       indexSelected = i;
//       controller!.index = indexSelected;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: TabBarView(
//         physics: const NeverScrollableScrollPhysics(),
//         controller: controller,
//         children: [
//           HomePage(
//             tripKey: widget.tripKey, 
//             startLocation: widget.startLocation, 
//             endLocation: widget.endLocation
//           ), // Pasar todos los parámetros a HomePage
//           const DriverHomePage(),
//           const TripsHistoryPage(),
//           const ProfilePage(),
//         ],
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
//           BottomNavigationBarItem(icon: Icon(Icons.check), label: "Checkings"),
//           BottomNavigationBarItem(icon: Icon(Icons.account_tree), label: "Viajes"),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
//         ],
//         currentIndex: indexSelected,
//         unselectedItemColor: Colors.grey,
//         selectedItemColor: brandColor,
//         showSelectedLabels: true,
//         selectedLabelStyle: const TextStyle(fontSize: 12),
//         type: BottomNavigationBarType.fixed,
//         onTap: onBarItemClicked,
//       ),
//     );
//   }
// }
