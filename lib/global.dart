import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:remisse_arequipa_driver/methods/common_methods.dart';

CommonMethods associateMethods = CommonMethods();

String userName = "";
String userPhone = "";




// Colores globales
const Color brandColor =Color.fromARGB(255, 205, 87, 24); // Color principal utilizado en la app
const Color neutralColor = Colors.white; // Color de fondo para contenedores, texto y otros elementos
const Color gradienteEndColor =  Color(0xFFFF8F17);  // Color de fondo para el gradiente
const Color contrastColor = Colors.black; // Color del texto 
const Color mutedColor= Colors.grey; // Color de las líneas divisorias
const Color acentColor =Color.fromARGB(255, 16, 103, 255);





// Fuentes globales
TextStyle headerTextStyle = const TextStyle(
  fontSize: 30,
  fontWeight: FontWeight.bold,
  color: Colors.white, // Texto en blanco para encabezados
);

TextStyle listTileTextStyle = const TextStyle(
  color: Colors.black, // Texto negro para los list tiles
);

Typography typography = Typography.material2018();

const CameraPosition kArequipa = CameraPosition(
    target: LatLng(-16.409047, -71.537451),
    zoom: 14.4746,
  );

String driverName = "";
String driverPhone = "";
String driverPhoto = "";
String carColor = "";
String carModel = "";
String carNumber = "";

StreamSubscription<Position>? positionStreamHomePage;
StreamSubscription<Position>? positionStreamNewTripPage;

String googleMapKey = "paste your key here";

int driverTripRequestTimeout = 20;

final audioPlayer = AssetsAudioPlayer();

Position? driverCurrentPosition;