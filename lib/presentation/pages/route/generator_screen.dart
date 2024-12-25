import 'package:flutter/material.dart';
import 'package:remisse_arequipa_driver/presentation/pages/route/set_clientes_screen.dart';

class GeneratorScreen extends StatefulWidget {
  const GeneratorScreen({super.key});

  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen> with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: const Text('Service Generator'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(
              icon: Icon(Icons.people),
              text: "Varios",
            ),
            Tab(
              icon: Icon(Icons.person),
              text: "Unico",
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          ManyTab(),
          UniqueTab(),
        ],
      ),
    );
  }
}
class ManyTab extends StatefulWidget {
  @override
  _ManyTabState createState() => _ManyTabState();
}

class _ManyTabState extends State<ManyTab> {
  String? selectedCompany;
  bool isOneWay = false;
  final List<String> companies = ["Cerro Verde", "Las Bambas"];
  DateTime? startDate;
  DateTime? endDate;
  TimeOfDay? arrivalTime;
  TimeOfDay? pickupTime;
  List<String> selectedClients = [];
  List<String> selectedDrivers = [];
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Seleccione Empresa",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: selectedCompany,
              hint: const Text("Seleccione una empresa"),
              isExpanded: true,
              items: companies.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedCompany = newValue;
                });
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Solo Ida",
                  style: TextStyle(fontSize: 16),
                ),
                Checkbox(
                  value: isOneWay,
                  onChanged: (bool? newValue) {
                    setState(() {
                      isOneWay = newValue ?? false;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Seleccione Fechas",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final DateTime? pickedStartDate = await showDatePicker(
                      context: context,
                      initialDate: startDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (pickedStartDate != null) {
                      setState(() {
                        startDate = pickedStartDate;

                        if (endDate != null && endDate!.isBefore(startDate!)) {
                          endDate = null;
                        }
                      });
                    }
                  },
                  child: Text(
                    startDate != null
                        ? "Inicio: ${startDate!.day}/${startDate!.month}/${startDate!.year}"
                        : "Seleccionar Inicio",
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (startDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Primero seleccione la fecha de inicio."),
                        ),
                      );
                      return;
                    }

                    final DateTime? pickedEndDate = await showDatePicker(
                      context: context,
                      initialDate: endDate ?? startDate!,
                      firstDate: startDate!,
                      lastDate: DateTime(2100),
                    );
                    if (pickedEndDate != null) {
                      setState(() {
                        endDate = pickedEndDate;
                      });
                    }
                  },
                  child: Text(
                    endDate != null
                        ? "Fin: ${endDate!.day}/${endDate!.month}/${endDate!.year}"
                        : "Seleccionar Fin",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (startDate != null || endDate != null)
              Text(
                "Rango seleccionado: ${startDate != null ? "${startDate!.day}/${startDate!.month}/${startDate!.year}" : 'No seleccionado'} - ${endDate != null ? "${endDate!.day}/${endDate!.month}/${endDate!.year}" : 'No seleccionado'}",
                style: const TextStyle(fontSize: 14),
              ),
            const SizedBox(height: 20),
            const Text(
              "Seleccione Horas",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final TimeOfDay? pickedArrivalTime = await showTimePicker(
                      context: context,
                      initialTime: arrivalTime ?? const TimeOfDay(hour: 0, minute: 0),
                      builder: (context, child) {
                        return MediaQuery(
                          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                          child: TimePickerDialog(
                            initialTime: arrivalTime ?? const TimeOfDay(hour: 0, minute: 0),
                            initialEntryMode: TimePickerEntryMode.input, // Teclado primero
                          ),
                        );
                      },
                    );
                    if (pickedArrivalTime != null) {
                      setState(() {
                        arrivalTime = pickedArrivalTime;
                      });
                    }
                  },
                  child: Text(
                    arrivalTime != null
                        ? "Ida: ${arrivalTime!.hour.toString().padLeft(2, '0')}:${arrivalTime!.minute.toString().padLeft(2, '0')}"
                        : "Ida Hora de Llegada",
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final TimeOfDay? pickedPickupTime = await showTimePicker(
                      context: context,
                      initialTime: pickupTime ?? const TimeOfDay(hour: 0, minute: 0),
                      builder: (context, child) {
                        return MediaQuery(
                          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                          child: TimePickerDialog(
                            initialTime: pickupTime ?? const TimeOfDay(hour: 0, minute: 0),
                            initialEntryMode: TimePickerEntryMode.input, // Teclado primero
                          ),
                        );
                      },
                    );
                    if (pickedPickupTime != null) {
                      setState(() {
                        pickupTime = pickedPickupTime;
                      });
                    }
                  },
                  child: Text(
                    pickupTime != null
                        ? "Vuelta: ${pickupTime!.hour.toString().padLeft(2, '0')}:${pickupTime!.minute.toString().padLeft(2, '0')}"
                        : "Vuelta Hora de Recogida",
                  ),
                ),


              ],
            ),

            const SizedBox(height: 20),
            const Text(
              "Seleccione Clientes",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    if (selectedCompany == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Por favor, seleccione una empresa antes de continuar."),
                        ),
                      );
                      return;
                    }

                    final List<String>? selected = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectEntitiesScreen(
                          company: selectedCompany,
                          isDriverSelection: false,
                        ),
                      ),
                    );

                    if (selected != null) {
                      setState(() {
                        selectedClients = selected;
                      });
                    }
                  },
                  child: const Text("Seleccionar Clientes"),
                ),
                const SizedBox(width: 10),
                const Spacer(),
                Text(
                  "Clientes: ${selectedClients.length}",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final List<String>? selected = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectEntitiesScreen(
                          isDriverSelection: true,
                        ),
                      ),
                    );

                    if (selected != null) {
                      setState(() {
                        selectedDrivers = selected;
                      });
                    }
                  },
                  child: const Text("Seleccionar Conductores"),
                ),
                const SizedBox(width: 10),
                const Spacer(),
                Text(
                  "Conductores: ${selectedDrivers.length}",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 30), // Espacio adicional antes del botón Generar
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (selectedClients.isEmpty && selectedDrivers.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Debe seleccionar al menos un cliente o conductor."),
                      ),
                    );
                    return;
                  }

                  // Lógica del botón "Generar"
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Generando servicio para ${selectedClients.length} cliente(s) y ${selectedDrivers.length} conductor(es).",
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Text(
                  "Generar",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}



class UniqueTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String? selectedOption;
    final List<String> options = ["Opción 1", "Opción 2"];

    return Center(
      child: DropdownButton<String>(
        value: selectedOption,
        hint: const Text("Seleccione una opción"),
        items: options.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newValue) {},
      ),
    );
  }
}
