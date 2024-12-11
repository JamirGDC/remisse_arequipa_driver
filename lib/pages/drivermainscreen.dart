import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remisse_arequipa_driver/viewmodels/form/timerWorckdriver.dart';

class DriverMainScreen extends StatefulWidget {
  const DriverMainScreen({super.key});

  @override
  DriverMainScreenState createState() => DriverMainScreenState();
}

class DriverMainScreenState extends State<DriverMainScreen> {
  @override
  Widget build(BuildContext context) {
    // Obtén la instancia de Timerworckdriver usando Provider
    final timerWorkDriver = Provider.of<Timerworckdriver>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 245, 137, 36),
      ),
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
              'Bienvenido ${timerWorkDriver.getDriverName}',
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Hoy',
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 20.0),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.blueGrey),
                      const SizedBox(width: 8.0),
                      Text(
                        timerWorkDriver
                            .formatElapsedTime(), // Muestra el tiempo transcurrido que devuelve el método formatElapsedTime
                        style: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Hoy',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        timerWorkDriver.isTimerActive
                            ? 'Activo'
                            : 'Pausa', // Muestra el estado del temporizador
                        style: const TextStyle(
                          fontSize: 16.0,
                          color: Colors.black87,
                        ),
                      ),
                      Transform.scale(
                        scale: 1.5,
                        child: Switch(
                          value: timerWorkDriver
                              .isTimerActive, // Le da el valor del estado del temporizador
                          onChanged: timerWorkDriver.switchEnabled
                              ? (bool value) {
                                  timerWorkDriver.handleSwitchChange(
                                      value); // Cambia el estado del temporizador si el Switch está habilitado
                                }
                              : null, // Si el Switch está deshabilitado, no se puede cambiar
                          activeColor: Colors.green,
                          inactiveThumbColor: Colors.grey,
                          inactiveTrackColor: Colors.grey.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: ValueListenableBuilder<bool>(
                      valueListenable:timerWorkDriver.buttonEnabled,
                      builder: (context, isEnabled, child) {
                        return ElevatedButton(
                          onPressed: isEnabled
                              ? () {
                                  timerWorkDriver.showConfirmationDialog(context);
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 185, 112, 9),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 10.0),
                          ), // Si `isEnabled` es false, `onPressed` es null y el botón se deshabilita.
                          child: const Text('Fin de la jornada'),
                        );
                      },
                    ),
                  ),

                  if (!timerWorkDriver.switchEnabled)
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "Toma un descanso",
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontSize:
                              16.0, // Puedes ajustar el tamaño de la fuente si es necesario
                        ),
                      ),
                    ),
                  //aqui iba el formulario pegar desde aqui
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}