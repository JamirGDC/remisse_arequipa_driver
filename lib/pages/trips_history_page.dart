import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:remisse_arequipa_driver/components/trip_card.dart';

class TripsHistoryPage extends StatefulWidget {
  const TripsHistoryPage({super.key});

  @override
  State<TripsHistoryPage> createState() => _TripsHistoryPageState();
}

class _TripsHistoryPageState extends State<TripsHistoryPage> with TickerProviderStateMixin {
  final completedTripRequestsOfCurrentDriver = FirebaseDatabase.instance.ref().child("tripRequests");
  late final TabController _tabController;
  late final Stream<List<Map<String, dynamic>>> _tripRequestsStream;
  late final Stream<List<Map<String, dynamic>>> _secondTripRequestsStream;

  Stream<List<Map<String, dynamic>>> getAllTripRequests() {
    return completedTripRequestsOfCurrentDriver.onValue.map((event) {
      final data = event.snapshot.value;

      if (data == null) {
        return <Map<String, dynamic>>[];
      }

      final Map<String, dynamic> tripRequests = Map<String, dynamic>.from(data as Map);
      return tripRequests.entries.map((entry) {
        return {
          "key": entry.key,
          ...Map<String, dynamic>.from(entry.value),
        };
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tripRequestsStream = getAllTripRequests().asBroadcastStream();
    _secondTripRequestsStream = getAllTripRequests().asBroadcastStream();

  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Servicios'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(
              icon: Icon(Icons.drive_eta),
              text: "Servicios",
            ),
            Tab(
              icon: Icon(Icons.people),
              text: "Clientes",
            ),
            Tab(
              icon: Icon(Icons.history),
              text: "Historial",
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          FirstTab(tripRequestsStream: _tripRequestsStream),
          ClientListScreen(),
          SecondTab(secondTripRequestsStream: _secondTripRequestsStream)


          // const Center(
          //   child: Text("It's sunny here"),
          // ),
        ],
      ),
    );
  }
}

class FirstTab extends StatefulWidget {
  final Stream<List<Map<String, dynamic>>> tripRequestsStream;

  const FirstTab({required this.tripRequestsStream, Key? key}) : super(key: key);

  @override
  _FirstTabState createState() => _FirstTabState();
}

class _FirstTabState extends State<FirstTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool showToday = true;
  bool showTomorrow = true;
  bool showUpcoming = true;

  List<Map<String, dynamic>> filterTrips(List<Map<String, dynamic>> trips, String category) {
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));

    if (category == "today") {
      return trips.where((trip) {
        final tripDate = DateTime.parse(trip["publishDateTime"]);
        return tripDate.year == today.year && tripDate.month == today.month && tripDate.day == today.day;
      }).toList();
    } else if (category == "tomorrow") {
      return trips.where((trip) {
        final tripDate = DateTime.parse(trip["publishDateTime"]);
        return tripDate.year == tomorrow.year && tripDate.month == tomorrow.month && tripDate.day == tomorrow.day;
      }).toList();
    } else {
      return trips.where((trip) {
        final tripDate = DateTime.parse(trip["publishDateTime"]);
        return tripDate.isAfter(tomorrow);
      }).toList();
    }
  }

  Widget buildTripSection(String title, List<Map<String, dynamic>> trips) {
    return ExpansionTile(
      title: Text(title),
      initiallyExpanded: title == "Hoy" ? showToday : title == "Mañana" ? showTomorrow : showUpcoming,
      onExpansionChanged: (expanded) {
        setState(() {
          if (title == "Hoy") showToday = expanded;
          if (title == "Mañana") showTomorrow = expanded;
          if (title == "Próximos Días") showUpcoming = expanded;
        });
      },
      tilePadding: const EdgeInsets.symmetric(horizontal: 16.0),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      collapsedShape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      children: trips.isEmpty
          ? [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "No hay servicios disponibles.",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ]
          : trips.map((trip) => TripCard(
        pickUpAddress: trip["pickUpAddress"] ?? "Sin dirección de recogida",
        dropOffAddress: trip["dropOffAddress"] ?? "Sin dirección de destino",
        userName: trip["userName"] ?? "Sin nombre",
        userPhone: trip["userPhone"] ?? "Sin teléfono",
        publishDateTime: trip["publishDateTime"] ?? "Sin fecha",
      )).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 1.h),
        ),
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: widget.tripRequestsStream,
            initialData: const [],
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    "Error al cargar los datos.",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              final tripsList = snapshot.data!;
              if (tripsList.isEmpty) {
                return const Center(
                  child: Text(
                    "No se encontraron registros.",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              return ListView(
                children: [
                  buildTripSection("Hoy", filterTrips(tripsList, "today")),
                  buildTripSection("Mañana", filterTrips(tripsList, "tomorrow")),
                  buildTripSection("Próximos Días", filterTrips(tripsList, "upcoming")),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}



class SecondTab extends StatefulWidget {
  final Stream<List<Map<String, dynamic>>> secondTripRequestsStream;

  const SecondTab({required this.secondTripRequestsStream, Key? key}) : super(key: key);

  @override
  _SecondTabState createState() => _SecondTabState();
}

class _SecondTabState extends State<SecondTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        SizedBox(height: 5.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 1.h),
        ),
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: widget.secondTripRequestsStream,
            initialData: const [],
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    "Error al cargar los datos.",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              final tripsList = snapshot.data!;
              if (tripsList.isEmpty) {
                return const Center(
                  child: Text(
                    "No se encontraron registros.",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              return ListView.builder(
                itemCount: tripsList.length,
                itemBuilder: (context, index) {
                  final trip = tripsList[index];
                  if (trip["status"] != null) {
                    return TripCard(
                      pickUpAddress: trip["pickUpAddress"] ?? "Sin dirección de recogida",
                      dropOffAddress: trip["dropOffAddress"] ?? "Sin dirección de destino",
                      userName: trip["userName"] ?? "Sin nombre",
                      userPhone: trip["userPhone"] ?? "Sin teléfono",
                      publishDateTime: trip["publishDateTime"] ?? "Sin fecha",
                    );
                  } else {
                    return Container();
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}


class ClientListScreen extends StatefulWidget {
  @override
  _ClientListScreenState createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  List<Map<String, dynamic>> _clients = [];
  List<Map<String, dynamic>> _filteredClients = [];
  String? _selectedCompany;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchClients();
  }

  void _fetchClients() async {
    final ref = FirebaseDatabase.instance.ref("clients");
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final clientsData = Map<String, dynamic>.from(snapshot.value as Map);
      final clientsList = clientsData.entries.map((entry) {
        final client = Map<String, dynamic>.from(entry.value);
        return {
          "id": entry.key,
          "name": client["Name"] ?? "",
          "surname": client["Surname"] ?? "",
          "phone": client["Phone"] ?? "",
          "homeAddress": client["HomeAddress"] ?? "",
          "workAddress": client["WorkAddress"] ?? "",
          "company": client["Company"] ?? "",
          "createdAt": client["CreatedAt"] ?? "",
          "isActive": client["isActive"] ?? false,
        };
      }).toList();

      setState(() {
        _clients = clientsList;
        _filteredClients = clientsList;
      });
    }
  }

  void _filterClients() {
    setState(() {
      _filteredClients = _clients.where((client) {
        final matchesCompany = _selectedCompany == null || client["company"] == _selectedCompany;
        final matchesSearch = _searchQuery.isEmpty ||
            client["name"].toLowerCase().contains(_searchQuery.toLowerCase()) ||
            client["surname"].toLowerCase().contains(_searchQuery.toLowerCase());
        return matchesCompany && matchesSearch;
      }).toList();
    });
  }

  void _filterByCompany(String? company) {
    _selectedCompany = company;
    _filterClients();
  }

  void _updateSearchQuery(String query) {
    _searchQuery = query;
    _filterClients();
  }

  void _showClientDetails(Map<String, dynamic> client) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text("Client Details"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Nombre: ${client["name"]}"),
                Text("Apellido: ${client["surname"]}"),
                Text("Telefono: ${client["phone"]}"),
                Text("Dirección Casa: ${client["homeAddress"]}"),
                Text("Dirección Trabajo: ${client["workAddress"]}"),
                Text("Empresa: ${client["company"]}"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "Buscar por nombre o apellido...",
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
              ),
              onChanged: _updateSearchQuery,
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list),
            tooltip: "Filtrar",
            onSelected: (value) {
              _filterByCompany(value == "All" ? null : value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: "All", child: Text("Todos")),
              const PopupMenuItem(value: "Cerro Verde", child: Text("Cerro Verde")),
              const PopupMenuItem(value: "Las Bambas", child: Text("Las Bambas")),
            ],
          ),
        ],
      ),
      body: _filteredClients.isEmpty
          ? Center(child: Text("No hay clientes."))
          : ListView.builder(
        itemCount: _filteredClients.length,
        itemBuilder: (context, index) {
          final client = _filteredClients[index];
          return Card(
            child: ListTile(
              title: Text("Cliente: ${client["name"]} ${client["surname"]}"),
              subtitle: Text("Empresa: ${client["company"]}"),
              trailing: ElevatedButton(
                onPressed: () => _showClientDetails(client),
                child: Text("Detalles"),
              ),
            ),
          );
        },
      ),
    );
  }
}
