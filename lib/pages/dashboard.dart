import 'package:flutter/material.dart';
import 'package:remisse_arequipa_driver/pages/driver_home_page.dart';
import 'package:remisse_arequipa_driver/pages/earnings_page.dart';
import 'package:remisse_arequipa_driver/pages/home_page.dart';
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
    super.initState();

    controller = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
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
          DriverHomePage(),
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
              label: "Viajes"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Perfil"
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
