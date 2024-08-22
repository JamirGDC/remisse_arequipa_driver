import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CreateClientPage extends StatefulWidget {
  const CreateClientPage({super.key});

  @override
  State<CreateClientPage> createState() => _CreateClientPageState();
}

class _CreateClientPageState extends State<CreateClientPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _homeAddressController = TextEditingController();
  final _workAddressController = TextEditingController();

  LatLng? _homeLatLng;
  LatLng? _workLatLng;

  final DatabaseReference clientsRef = FirebaseDatabase.instance.ref().child("users");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear Cliente"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Nombre"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: "Apellido"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese un apellido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _homeAddressController,
                decoration: const InputDecoration(labelText: "Dirección de Casa"),
              ),
              ElevatedButton(
                onPressed: () async {
                  LatLng? selectedLocation = await _selectLocationOnMap();
                  if (selectedLocation != null) {
                    setState(() {
                      _homeLatLng = selectedLocation;
                    });
                  }
                },
                child: const Text("Seleccionar Ubicación de Casa en el Mapa"),
              ),
              if (_homeLatLng != null)
                Text("Ubicación de Casa: Lat: ${_homeLatLng!.latitude}, Lng: ${_homeLatLng!.longitude}"),
              const SizedBox(height: 16),
              TextFormField(
                controller: _workAddressController,
                decoration: const InputDecoration(labelText: "Dirección de Trabajo"),
              ),
              ElevatedButton(
                onPressed: () async {
                  LatLng? selectedLocation = await _selectLocationOnMap();
                  if (selectedLocation != null) {
                    setState(() {
                      _workLatLng = selectedLocation;
                    });
                  }
                },
                child: const Text("Seleccionar Ubicación de Trabajo en el Mapa"),
              ),
              if (_workLatLng != null)
                Text("Ubicación de Trabajo: Lat: ${_workLatLng!.latitude}, Lng: ${_workLatLng!.longitude}"),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveClient,
                child: const Text("Guardar Cliente"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<LatLng?> _selectLocationOnMap() async {
    LatLng? selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SelectLocationOnMapPage(),
      ),
    );
    return selectedLocation;
  }

  void _saveClient() async {
    if (_formKey.currentState!.validate() && _homeLatLng != null && _workLatLng != null) {
      String clientId = clientsRef.push().key!;

      Map<String, dynamic> clientData = {
        "name": _nameController.text,
        "lastName": _lastNameController.text,
        "directions": {
          "home": {
            "address": _homeAddressController.text,
            "latitude": _homeLatLng!.latitude,
            "longitude": _homeLatLng!.longitude,
          },
          "work": {
            "address": _workAddressController.text,
            "latitude": _workLatLng!.latitude,
            "longitude": _workLatLng!.longitude,
          },
        }
      };

      await clientsRef.child(clientId).set(clientData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cliente creado con éxito')),
      );

      // Limpiar el formulario
      _formKey.currentState!.reset();
      _nameController.clear();
      _lastNameController.clear();
      _homeAddressController.clear();
      _workAddressController.clear();
      setState(() {
        _homeLatLng = null;
        _workLatLng = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, complete todos los campos y seleccione las ubicaciones en el mapa')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _homeAddressController.dispose();
    _workAddressController.dispose();
    super.dispose();
  }
}

class SelectLocationOnMapPage extends StatefulWidget {
  const SelectLocationOnMapPage({super.key});

  @override
  State<SelectLocationOnMapPage> createState() => _SelectLocationOnMapPageState();
}

class _SelectLocationOnMapPageState extends State<SelectLocationOnMapPage> {
  final LatLng _initialPosition = const LatLng(-16.409047, -71.537451);// Coordenadas iniciales
  LatLng? _selectedPosition;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Seleccionar Ubicación"),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _initialPosition,
          zoom: 14,
        ),
        onTap: (position) {
          setState(() {
            _selectedPosition = position;
          });
        },
        markers: _selectedPosition != null
            ? {
                Marker(markerId: const MarkerId('selected'), position: _selectedPosition!)
              }
            : {},
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context, _selectedPosition);
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
