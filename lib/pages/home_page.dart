import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:remisse_arequipa_driver/methods/common_methods.dart';
import 'package:remisse_arequipa_driver/global.dart';
import 'package:remisse_arequipa_driver/methods/map_theme_methods.dart';
import 'package:remisse_arequipa_driver/models/direction_details.dart';

class HomePage extends StatefulWidget {
  final LatLng? startLocation;
  final LatLng? endLocation;
  final String? tripKey; // Agrega el parámetro tripKey

  const HomePage({super.key, this.tripKey, this.startLocation, this.endLocation});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Completer<GoogleMapController> googleMapCompleterController = Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  Position? currentPositionOfDriver;
  MapThemeMethods themeMethods = MapThemeMethods();
  DirectionDetails? tripDirectionDetails;
  Set<Polyline> polylines = {}; // Para almacenar las polilíneas
  Set<Marker> markers = {}; // Para almacenar los marcadores

  BitmapDescriptor? startMarkerIcon;
  BitmapDescriptor? endMarkerIcon;

  @override
  void initState() {
    super.initState();
    _loadMarkerIcons();
    if (widget.startLocation != null && widget.endLocation != null) {
      _createRoute();
    }
  }

  Future<void> _loadMarkerIcons() async {
    startMarkerIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(24, 24)),
      'lib/assets/initial.png',
    );
    endMarkerIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(24, 24)),
      'lib/assets/final.png',
    );
    setState(() {});
  }

  Future<void> _createRoute() async {
    if (widget.startLocation != null && widget.endLocation != null) {
      tripDirectionDetails = await CommonMethods.getDirectionDetailsFromAPI(widget.startLocation!, widget.endLocation!);
      _showRouteOnMap(tripDirectionDetails);
    }
  }

  void _showRouteOnMap(DirectionDetails? details) {
    if (details != null && controllerGoogleMap != null) {
      PolylinePoints polylinePoints = PolylinePoints();
      List<PointLatLng> decodedPolylinePoints = polylinePoints.decodePolyline(details.encodedPoints!);

      List<LatLng> polylineCoordinates = decodedPolylinePoints.map((point) => LatLng(point.latitude, point.longitude)).toList();

      Polyline polyline = Polyline(
        polylineId: const PolylineId("tripRoute"),
        color: Colors.blue,
        points: polylineCoordinates,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      );

      setState(() {
        polylines.add(polyline);
        markers.add(Marker(
          markerId: const MarkerId("startMarker"),
          position: widget.startLocation!,
          icon: startMarkerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(title: "Punto de inicio"),
        ));
        markers.add(Marker(
          markerId: const MarkerId("endMarker"),
          position: widget.endLocation!,
          icon: endMarkerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: "Punto final"),
        ));
      });

      LatLngBounds bounds;
      if (widget.startLocation!.latitude > widget.endLocation!.latitude && widget.startLocation!.longitude > widget.endLocation!.longitude) {
        bounds = LatLngBounds(southwest: widget.endLocation!, northeast: widget.startLocation!);
      } else if (widget.startLocation!.longitude > widget.endLocation!.longitude) {
        bounds = LatLngBounds(
            southwest: LatLng(widget.startLocation!.latitude, widget.endLocation!.longitude),
            northeast: LatLng(widget.endLocation!.latitude, widget.startLocation!.longitude));
      } else if (widget.startLocation!.latitude > widget.endLocation!.latitude) {
        bounds = LatLngBounds(
            southwest: LatLng(widget.endLocation!.latitude, widget.startLocation!.longitude),
            northeast: LatLng(widget.startLocation!.latitude, widget.endLocation!.longitude));
      } else {
        bounds = LatLngBounds(southwest: widget.startLocation!, northeast: widget.endLocation!);
      }

      controllerGoogleMap!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));
    }
  }

  Future<void> _startTrip() async {
    Position positionOfDriver = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    LatLng driverCurrentPosition = LatLng(positionOfDriver.latitude, positionOfDriver.longitude);

    // Calcular la ruta desde la ubicación actual del conductor hasta el punto de inicio
    DirectionDetails? routeToStartPoint = await CommonMethods.getDirectionDetailsFromAPI(driverCurrentPosition, widget.startLocation!);

    if (routeToStartPoint != null) {
      _showRouteToStartPoint(routeToStartPoint);
    }
  }

  void _showRouteToStartPoint(DirectionDetails details) {
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolylinePoints = polylinePoints.decodePolyline(details.encodedPoints!);

    List<LatLng> polylineCoordinates = decodedPolylinePoints.map((point) => LatLng(point.latitude, point.longitude)).toList();

    Polyline polyline = Polyline(
      polylineId: const PolylineId("routeToStartPoint"),
      color: Colors.red,
      points: polylineCoordinates,
      width: 5,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );

    setState(() {
      polylines.add(polyline);
    });

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        min(widget.startLocation!.latitude, driverCurrentPosition!.latitude),
        min(widget.startLocation!.longitude, driverCurrentPosition!.longitude),
      ),
      northeast: LatLng(
        max(widget.startLocation!.latitude, driverCurrentPosition!.latitude),
        max(widget.startLocation!.longitude, driverCurrentPosition!.longitude),
      ),
    );

    controllerGoogleMap!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));
  }

  void _cancelTrip() {
    setState(() {
      polylines.clear();
      markers.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: const EdgeInsets.only(top: 136),
            mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition: kArequipa,
            polylines: polylines, // Mostrar todas las polilíneas
            markers: markers, // Mostrar todos los marcadores
            onMapCreated: (GoogleMapController mapController) {
              controllerGoogleMap = mapController;
              themeMethods.updateMapTheme(controllerGoogleMap!);
              googleMapCompleterController.complete(controllerGoogleMap);
            },
          ),
          if (tripDirectionDetails != null)
            Positioned(
              bottom: 50,
              left: 20,
              right: 20,
              child: Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Duración del viaje: ${tripDirectionDetails!.durationTextString}"),
                      const SizedBox(height: 8),
                      Text("Dirección inicial: ${widget.startLocation.toString()}"),
                      const SizedBox(height: 8),
                      Text("Dirección final: ${widget.endLocation.toString()}"),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: _startTrip, // Llamar a _startTrip al iniciar el viaje
                            child: const Text("Iniciar Viaje"),
                          ),
                          ElevatedButton(
                            onPressed: _cancelTrip,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text("Cancelar"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
