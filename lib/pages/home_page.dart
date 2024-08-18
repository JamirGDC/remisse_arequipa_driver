import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
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
  bool showTripCard = true;
  bool showInProgressCard = false;
  BitmapDescriptor? startMarkerIcon;
  BitmapDescriptor? endMarkerIcon;
  bool isDriverAvailable = false;
  XFile? imageFile;

    String urlOfUploadedImage = "";

  final TextEditingController _commentController = TextEditingController();

  getCurrentLiveLocationOfDriver() async
  {
    Position positionOfUser = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPositionOfDriver = positionOfUser;
    driverCurrentPosition = currentPositionOfDriver;

    LatLng positionOfUserInLatLng = LatLng(currentPositionOfDriver!.latitude, currentPositionOfDriver!.longitude);

    CameraPosition cameraPosition = CameraPosition(target: positionOfUserInLatLng, zoom: 15);
    controllerGoogleMap!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  setAndGetLocationUpdates()
  {
    positionStreamHomePage = Geolocator.getPositionStream()
        .listen((Position position)
    {
      currentPositionOfDriver = position;

      if(isDriverAvailable == true)
      {
        Geofire.setLocation(
            FirebaseAuth.instance.currentUser!.uid,
            currentPositionOfDriver!.latitude,
            currentPositionOfDriver!.longitude,
        );
      }

      LatLng positionLatLng = LatLng(position.latitude, position.longitude);
      controllerGoogleMap!.animateCamera(CameraUpdate.newLatLng(positionLatLng));
      });
    }

    void _handleIncident() async {
    // Abrir el popup para la incidencia
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Incidencia"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: _pickImageFromCamera,
                child: const Text("Abrir Cámara"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  labelText: "Comentario",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el popup
              },
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: uploadImageToStorage,
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  chooseImageFromGallery() async
  {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if(pickedFile != null)
    {
      setState(() {
        imageFile = pickedFile;
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
  final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);

  if (pickedFile != null) {
    Position positionOfUser = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);

    final watermarkedImage = await _addWatermarkAndSave(pickedFile, positionOfUser);

    if (watermarkedImage != null) {
      setState(() {
        imageFile = XFile(watermarkedImage.path);
      });
    }
  }
  } 


  uploadImageToStorage() async
  {
    String imageIDName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference referenceImage = FirebaseStorage.instance.ref().child("Images").child(imageIDName);

    UploadTask uploadTask = referenceImage.putFile(File(imageFile!.path));
    TaskSnapshot snapshot = await uploadTask;
    urlOfUploadedImage = await snapshot.ref.getDownloadURL();

    setState(() {
      urlOfUploadedImage;
    });

    _saveIncident();
  }


  
  void _saveIncident() {
    // Obtener el UID del conductor actual
    String? driverUid = FirebaseAuth.instance.currentUser?.uid;

    if (driverUid == null) {
      // Manejar el caso en que el UID no esté disponible
      print("No se pudo obtener el UID del conductor.");
      return;
    }

    // Referencia a la base de datos en Firebase
    DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("drivers").child(driverUid);

    if (imageFile != null && _commentController.text.isNotEmpty) {
      // Aquí puedes proceder con la lógica para subir la imagen y guardar el comentario
      // Utiliza 'usersRef' como referencia para almacenar los datos en Firebase
      //guardamos la imagen en user.trips
      usersRef.child("trips").child(widget.tripKey!).child("incident").set({
        "image": urlOfUploadedImage,
        "comment": _commentController.text,
      });
    }

    // Cerrar el popup
    Navigator.of(context).pop();
  }

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
    if (currentPositionOfDriver != null) {
      LatLng driverCurrentPosition = LatLng(
        currentPositionOfDriver!.latitude,
        currentPositionOfDriver!.longitude,
      );

      // Calcular la ruta desde la ubicación actual del conductor hasta el punto de inicio
      DirectionDetails? routeToStartPoint = await CommonMethods.getDirectionDetailsFromAPI(driverCurrentPosition, widget.startLocation!);

      if (routeToStartPoint != null) {
        _showRouteToStartPoint(routeToStartPoint);
      }

      setState(() {
        showTripCard = false;  // Ocultar la tarjeta de inicio de viaje
        showInProgressCard = true; // Mostrar la tarjeta de progreso
      });
    } else {
      // Obtener la ubicación si no está disponible y luego iniciar el viaje
      await getCurrentLiveLocationOfDriver();
      _startTrip();
    }
  }

  Future<File?> _addWatermarkAndSave(XFile originalImage, Position position) async {
  try {
    // Load the image
    final image = File(originalImage.path);
    final imageBytes = await image.readAsBytes();
    final codec = await instantiateImageCodec(imageBytes);
    final frame = await codec.getNextFrame();
    final imageData = frame.image;

    // Create a canvas to draw on the image
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromPoints(Offset.zero, Offset(imageData.width.toDouble(), imageData.height.toDouble())));
    final paint = Paint();

    // Draw the original image on the canvas
    canvas.drawImage(imageData, Offset.zero, paint);

    // Add text with the location and time information
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Lat: ${position.latitude}, Long: ${position.longitude}\nDate: ${DateTime.now().toLocal().toString()}',
        style: const TextStyle(color: Colors.white, fontSize: 20, shadows: [Shadow(blurRadius: 2.0, color: Colors.black, offset: Offset(1.0, 1.0))]),
      ),
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Draw the text at the bottom right corner
    textPainter.paint(canvas, Offset(imageData.width - textPainter.width - 10, imageData.height - textPainter.height - 10));

    // Finish drawing and get the image
    final picture = recorder.endRecording();
    final finalImage = await picture.toImage(imageData.width, imageData.height);
    final byteData = await finalImage.toByteData(format: ImageByteFormat.png);

    if (byteData != null) {
      // Get the directory to save the image
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.png';

      // Save the image with the watermark
      final file = File(filePath);
      await file.writeAsBytes(byteData.buffer.asUint8List());
      return file;
    }
  } catch (e) {
    print('Error adding watermark: $e');
  }
  return null;
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
      showTripCard = false;
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
            polylines: polylines,
            markers: markers,
            onMapCreated: (GoogleMapController mapController) {
              controllerGoogleMap = mapController;
              themeMethods.updateMapTheme(controllerGoogleMap!);
              googleMapCompleterController.complete(controllerGoogleMap);
              getCurrentLiveLocationOfDriver();
            },
          ),
          
          if (tripDirectionDetails != null && showTripCard)
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
                            onPressed: _startTrip,
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
            if (showInProgressCard)
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
                    const Text("Tiempo hacia el punto de inicio: ..."), // Reemplaza con el tiempo real
                    const SizedBox(height: 8),
                    const Text("Tiempo para completar el viaje: ..."), // Reemplaza con el tiempo real
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _handleIncident, // Método para manejar la incidencia
                      child: const Text("Incidencia"),
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
