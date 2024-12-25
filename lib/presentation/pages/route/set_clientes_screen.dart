import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class SelectEntitiesScreen extends StatefulWidget {
  final String? company; // Nullable para casos sin empresa
  final bool isDriverSelection; // Determina si es selección de drivers

  const SelectEntitiesScreen({
    this.company,
    required this.isDriverSelection,
  });

  @override
  _SelectEntitiesScreenState createState() => _SelectEntitiesScreenState();
}

class _SelectEntitiesScreenState extends State<SelectEntitiesScreen> {
  List<Map<String, dynamic>> allEntities = [];
  List<Map<String, dynamic>> filteredEntities = [];
  List<String> selectedEntities = [];
  bool selectAll = false;
  String searchQuery = "";

  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    fetchEntities();
  }

  Future<void> fetchEntities() async {
    try {
      Query ref; // Cambiar DatabaseReference a Query
      if (widget.isDriverSelection) {
        // Traer todos los drivers
        ref = databaseRef.child('drivers');
      } else {
        // Traer los clientes por empresa
        ref = databaseRef.child('clients').orderByChild("Company").equalTo(widget.company!);
      }

      final snapshot = await ref.get(); // Obtener datos con el Query
      final entities = <Map<String, dynamic>>[];

      if (snapshot.exists) {
        debugPrint("Datos obtenidos: ${snapshot.value}"); // Debug para ver los datos
        snapshot.children.forEach((child) {
          final data = Map<String, dynamic>.from(child.value as Map);
          entities.add({
            "id": child.key,
            ...data,
          });
        });
      } else {
        debugPrint("No se encontraron datos para la consulta.");
      }

      setState(() {
        allEntities = entities;
        filteredEntities = entities;
      });
    } catch (e) {
      debugPrint("Error fetching entities: $e");
    }
  }


  void filterEntities(String query) {
    setState(() {
      searchQuery = query;
      filteredEntities = allEntities.where((entity) {
        final fullName = entity['name']?.toLowerCase() ?? "";
        return fullName.contains(query.toLowerCase());
      }).toList();
    });
  }

  void toggleSelectAll(bool value) {
    setState(() {
      selectAll = value;
      selectedEntities = value
          ? filteredEntities.map((entity) => entity['id'] as String).toList()
          : [];
    });
  }

  void toggleEntitySelection(String entityId, bool value) {
    setState(() {
      if (value) {
        selectedEntities.add(entityId);
      } else {
        selectedEntities.remove(entityId);
      }

      // Update "Select All" checkbox state
      selectAll = selectedEntities.length == filteredEntities.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isDriverSelection ? "Seleccionar Conductores" : "Seleccionar Clientes";
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, selectedEntities);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: "Buscar por nombre",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                filterEntities(value);
              },
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Checkbox(
                  value: selectAll,
                  onChanged: (bool? value) {
                    toggleSelectAll(value ?? false);
                  },
                ),
                const Text("Seleccionar Todos"),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredEntities.length,
                itemBuilder: (context, index) {
                  final entity = filteredEntities[index];
                  final entityId = entity['id'];
                  return ListTile(
                    leading: Checkbox(
                      value: selectedEntities.contains(entityId),
                      onChanged: (bool? value) {
                        toggleEntitySelection(entityId, value ?? false);
                      },
                    ),
                    title: Text(entity['Name'] ?? "Sin Nombre"),
                    subtitle: Text(entity['phone'] ?? ""),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
