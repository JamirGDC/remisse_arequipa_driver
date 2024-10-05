import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class CreateQuestions extends StatefulWidget {
  @override
  _CreateQuestionsState createState() => _CreateQuestionsState();
}

class _CreateQuestionsState extends State<CreateQuestions> {
  final TextEditingController _questionController = TextEditingController();
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref().child('questions');
  bool _isActive = true; // Estado activo predeterminado

  // Función para agregar una nueva pregunta a la base de datos en el subnodo especificado
  void _addQuestion(String subNode) {
    String questionText = _questionController.text.trim();

    if (questionText.isNotEmpty) {
      // Crea una nueva clave única para la pregunta
      String? key = _databaseReference.child(subNode).push().key;

      // Guarda la pregunta en el subnodo correspondiente
      _databaseReference.child(subNode).child(key!).set({
        'text': questionText,
        'createdAt': DateTime.now().toIso8601String(),
        'isActive': _isActive, // Añade el estado de activo
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pregunta guardada con éxito'),
            backgroundColor: Colors.green,
          ),
        );
        _questionController.clear();
        setState(() {
          _isActive = true; // Reiniciar el estado a true después de guardar
        });
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar la pregunta: $error'),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Preguntas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _questionController,
              decoration: const InputDecoration(
                labelText: 'Nueva Pregunta',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('Activa'),
                Switch(
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _addQuestion('questions_health'), // Guardar en questions_health
              child: const Text('Guardar Pregunta Salud'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _addQuestion('questions_machines'), // Guardar en questions_machines
              child: const Text('Guardar Pregunta Máquina'),
            ),
          ],
        ),
      ),
    );
  }
}
