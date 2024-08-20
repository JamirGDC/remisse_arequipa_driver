import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:remisse_arequipa_driver/global.dart';
import 'package:remisse_arequipa_driver/models/direction_details.dart';
import 'package:http/http.dart' as http;

class CommonMethods {
  Future<void> checkConnectivity(BuildContext context) async {
    var connectionResult = await Connectivity().checkConnectivity();
    if (connectionResult.isNotEmpty &&
        connectionResult[0] != ConnectivityResult.mobile &&
        connectionResult[0] != ConnectivityResult.wifi) {
      if (!context.mounted) return;
      displaysnackbar(
          "Tu internet no está disponible. Revisa tu configuración de Internet",
          context);
    }
  }

  void displaysnackbar(String messageText, BuildContext context) {
    var snackBar = SnackBar(content: Text(messageText));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  turnOffLocationUpdatesForHomePage() {
    positionStreamHomePage!.pause();

    Geofire.removeLocation(FirebaseAuth.instance.currentUser!.uid);
  }

  turnOnLocationUpdatesForHomePage() {
    positionStreamHomePage!.resume();

    Geofire.setLocation(
      FirebaseAuth.instance.currentUser!.uid,
      driverCurrentPosition!.latitude,
      driverCurrentPosition!.longitude,
    );
  }

  static sendRequestToAPI(String apiUrl) async {
    http.Response responseFromAPI = await http.get(Uri.parse(apiUrl));

    try {
      if (responseFromAPI.statusCode == 200) {
        String dataFromApi = responseFromAPI.body;
        var dataDecoded = jsonDecode(dataFromApi);
        return dataDecoded;
      } else {
        return "error";
      }
    } catch (errorMsg) {
      return "error";
    }
  }

  static Future<DirectionDetails?> getDirectionDetailsFromAPI(
      LatLng source, LatLng destination) async {
    String urlDirectionsAPI =
        "https://maps.googleapis.com/maps/api/directions/json?destination=${destination.latitude},${destination.longitude}&origin=${source.latitude},${source.longitude}&mode=driving&key=$googleMapKey";

    var responseFromDirectionsAPI = await sendRequestToAPI(urlDirectionsAPI);

    if (responseFromDirectionsAPI == "error") {
      return null;
    }

    DirectionDetails detailsModel = DirectionDetails();

    detailsModel.distanceTextString =
        responseFromDirectionsAPI["routes"][0]["legs"][0]["distance"]["text"];
    detailsModel.distanceValueDigits =
        responseFromDirectionsAPI["routes"][0]["legs"][0]["distance"]["value"];

    detailsModel.durationTextString =
        responseFromDirectionsAPI["routes"][0]["legs"][0]["duration"]["text"];
    detailsModel.durationValueDigits =
        responseFromDirectionsAPI["routes"][0]["legs"][0]["duration"]["value"];

    detailsModel.encodedPoints =
        responseFromDirectionsAPI["routes"][0]["overview_polyline"]["points"];

    return detailsModel;
  }

  calculateFareAmount(DirectionDetails directionDetails) {
    double distancePerKmAmount = 0.4;
    double durationPerMinuteAmount = 0.3;
    double baseFareAmount = 2;

    double totalDistanceTravelFareAmount =
        (directionDetails.distanceValueDigits! / 1000) * distancePerKmAmount;
    double totalDurationSpendFareAmount =
        (directionDetails.durationValueDigits! / 60) * durationPerMinuteAmount;

    double overAllTotalFareAmount = baseFareAmount +
        totalDistanceTravelFareAmount +
        totalDurationSpendFareAmount;

    return overAllTotalFareAmount.toStringAsFixed(1);
  }

  static Future<Map<String, String>> getLastFormFilledDate() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // El usuario no está logueado
      return {
        "date": "No se ha podido obtener la información del usuario.",
        "time": ""
      };
    }

    String url =
        "https://remisseaqp-dfd32-default-rtdb.firebaseio.com/drivers/${user.uid}/checklists.json";

    var response = await sendRequestToAPI(url);

    if (response == "error") {
      return {
        "date": "Error al obtener la información del formulario.",
        "time": ""
      };
    }

    if (response != null) {
      // Convertimos los nodos en una lista y ordenamos por la fecha
      List<dynamic> formsList = [];
      response.forEach((key, value) {
        formsList.add(value);
      });

      // Ordenamos los formularios por fecha de creación (createdAt) de más reciente a menos reciente
      formsList.sort((a, b) {
        DateTime dateA = DateTime.parse(a["createdAt"]);
        DateTime dateB = DateTime.parse(b["createdAt"]);
        return dateB
            .compareTo(dateA); // Ordenar de más reciente a menos reciente
      });

     if (formsList.isNotEmpty) {
      DateTime lastFormDateTime = DateTime.parse(formsList.first["createdAt"]);
      String lastFormDate = "${lastFormDateTime.day}-${lastFormDateTime.month}-${lastFormDateTime.year}";
      String lastFormHour = "${lastFormDateTime.hour}:${lastFormDateTime.minute.toString().padLeft(2, '0')}";
      return {
        "date": lastFormDate,
        "time": lastFormHour
      };
    } else {
      return {
        "date": "Aún no has rellenado ningún formulario.",
        "time": ""
      };
    }
  } else {
    return {
      "date": "Aún no has rellenado ningún formulario.",
      "time": ""
    };
  }
}
}