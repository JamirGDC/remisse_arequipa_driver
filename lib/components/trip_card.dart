import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TripCard extends StatelessWidget {
  final String pickUpAddress;
  final String dropOffAddress;
  final String userName;
  final String userPhone;
  final String publishDateTime;

  const TripCard({
    super.key,
    required this.pickUpAddress,
    required this.dropOffAddress,
    required this.userName,
    required this.userPhone,
    required this.publishDateTime,
  });

  String formatDateTime(String dateTime) {
    try {
      final DateTime parsedDate = DateTime.parse(dateTime);
      final String formattedTime = DateFormat('HH:mm').format(parsedDate);
      final String formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);
      return '$formattedDate H: $formattedTime';
    } catch (e) {
      return dateTime; // Return original if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.history_outlined, color: Colors.blue),
            title: Text(
              ('Cliente: $userName'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Destino: $dropOffAddress \nFecha: ${formatDateTime(publishDateTime)}'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                child: const Text('DETALLES'),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Detalles del Viaje'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: 'Cliente: ',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: userName,
                                    style: const TextStyle(fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                text: 'Teléfono: ',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: userPhone,
                                    style: const TextStyle(fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                text: 'Origen: ',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: pickUpAddress,
                                    style: const TextStyle(fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                text: 'Destino: ',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: dropOffAddress,
                                    style: const TextStyle(fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                text: 'Fecha y Hora: ',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: formatDateTime(publishDateTime),
                                    style: const TextStyle(fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                            ),
                          ],

                        ),
                        actions: [
                          TextButton(
                            child: const Text('CERRAR'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(width: 8),
              // TextButton(
              //   child: const Text('INICIAR VIAJE'),
              //   onPressed: () {},
              // ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
    );
  }
}
