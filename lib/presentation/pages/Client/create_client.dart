import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class CreateClientView extends StatefulWidget {
  const CreateClientView({Key? key}) : super(key: key);

  @override
  _CreateClientViewState createState() => _CreateClientViewState();
}

class _CreateClientViewState extends State<CreateClientView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _homeAddressController = TextEditingController();
  final _workAddressController = TextEditingController();

  String? _selectedCompany;
  final List<String> _companies = ["Cerro Verde", "Las Bambas"];

  final DatabaseReference _database = FirebaseDatabase.instance.ref().child('clients');

  void _saveClient() async {
    if (_formKey.currentState!.validate()) {
      final clientData = {
        'Name': _nameController.text.trim(),
        'Surname': _surnameController.text.trim(),
        'Phone': _phoneController.text.trim(),
        'HomeAddress': _homeAddressController.text.trim(),
        'WorkAddress': _workAddressController.text.trim(),
        'Company': _selectedCompany,
        'CreatedAt': DateTime.now().toIso8601String(),
        'isActive': true,
      };

      try {
        await _database.push().set(clientData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cliente creado exitosamente.')),
        );
        _formKey.currentState!.reset();
        setState(() {
          _selectedCompany = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear el cliente: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Cliente'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _surnameController,
                decoration: const InputDecoration(
                  labelText: 'Apellido',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa un apellido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa un teléfono';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _homeAddressController,
                decoration: const InputDecoration(
                  labelText: 'Dirección de Casa',
                  prefixIcon: Icon(Icons.home_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa una dirección de casa';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _workAddressController,
                decoration: const InputDecoration(
                  labelText: 'Dirección de Trabajo',
                  prefixIcon: Icon(Icons.work_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa una dirección de trabajo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedCompany,
                items: _companies.map((company) {
                  return DropdownMenuItem(
                    value: company,
                    child: Text(company),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCompany = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Empresa',
                  prefixIcon: Icon(Icons.business_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecciona una empresa';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32.0),
              ElevatedButton.icon(
                onPressed: _saveClient,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Guardar Cliente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
