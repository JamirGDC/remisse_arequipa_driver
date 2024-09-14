import 'dart:async';
import 'dart:ffi';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importa Firebase Authentication.

class Timerworckdriver extends ChangeNotifier {
  // Constantes
  static const int _maxWorckTimeinseconds = 11;
  static const int _resetTimeinSeconds = 7;

  // Variables
  String _driverName = '';
  bool _isTimerActive = false;
  bool _switchEnabled = true;
  ValueNotifier<bool> _buttonEnabled = ValueNotifier<bool>(true);
  int _secondselapsed = 0;
  Timer? _timer;
  DateTime? _startTime;
  DateTime? _firstDayTime;
  DateTime? _firstEndTime;
  DateTime? _endTime;

  late DatabaseReference _driverRef;

  // Getters
  String get getDriverName => _driverName;
  bool get isTimerActive => _isTimerActive;
  int get secondsElapsed => _secondselapsed;
  bool get switchEnabled => _switchEnabled;
   ValueNotifier<bool> get buttonEnabled => _buttonEnabled;
  DateTime? get startTime => _startTime;
  DateTime? get endTime => _endTime;

  // Constructor
  Timerworckdriver() {
    _authInitializerDriverWorckTimer();
    _loadDrivernName();
  }

  // Inicializa la referencia de Firebase y carga los datos locales.
  void _authInitializerDriverWorckTimer() async {
    // Obtén el UID del usuario actual autenticado
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Crea la referencia a la base de datos en el nodo específico del conductor
      _driverRef = FirebaseDatabase.instance
          .ref()
          .child('drivers')
          .child(user.uid) // Usa el UID del conductor autenticado
          .child('workhours'); // Nodo donde se guardarán las horas de trabajo

      // Carga los datos locales después de configurar la referencia
      _loadFromPreferences();
    } else {
      // Maneja el caso donde el usuario no está autenticado
      print('Usuario no autenticado.');
    }
  }

  // Carga los datos desde SharedPreferences.
  void _loadFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _secondselapsed = prefs.getInt('secondsElapsed') ?? 0;
    _isTimerActive = prefs.getBool('isTimerActive') ?? false;
    _startTime = DateTime.tryParse(prefs.getString('startTime') ?? '');
    _endTime = DateTime.tryParse(prefs.getString('endTime') ?? '');

    if (_isTimerActive) {
      startTimer();
    }
    notifyListeners();
  }

  // Guarda los datos en SharedPreferences.
  void _saveToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('secondsElapsed', _secondselapsed);
    await prefs.setBool('isTimerActive', _isTimerActive);
    await prefs.setString('startTime', _startTime?.toIso8601String() ?? '');
    await prefs.setString('endTime', _endTime?.toIso8601String() ?? '');
  }

  // Guarda los datos relevantes en la base de datos.
  void _saveToDatabase() {
    _driverRef.set({
      'secondsElapsed': _secondselapsed,
      'isTimerActive': _isTimerActive,
      'startTime': _startTime?.toIso8601String() ?? '',
      'endTime': _endTime?.toIso8601String() ?? '',
      'lastUpdated': DateTime.now().toIso8601String(),
    });
  }

  // Inicia el temporizador.
  Future <void> startTimer() async {
    if (_isTimerActive) return;
    await firstDayTime();
    _isTimerActive = true;
    _startTime = DateTime.now();
    _saveToPreferences();
    _saveToDatabase(); // Guarda el estado inicial en la base de datos.
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      _secondselapsed++;
      notifyListeners();
      _saveToPreferences(); // Guarda los cambios en cada segundo.

      if (_secondselapsed >= _maxWorckTimeinseconds) {
        _endTime = DateTime.now();
        _showWorckCompletemessage();
        stopTimer(); // Detiene el temporizador y guarda los datos finales.

        // aqui debo de deshabilitar el switch es decir _switchEnabled = false; de este modo evitamsoq ue el usuario pueda seguir trabajando y despues ejecutamos el metodo disableSwitchTemporarily(); para que despue de transcurrido el tiempo de descanso se habilite nuevamente el switch
        disableSwitchTemporarily();
      }
    
    });
  }

Future <void> firstDayTime() async{
  if (secondsElapsed == 0) {
    _firstDayTime = DateTime.now();
    print("esto es el startime$_firstDayTime");
    
    }
}
  // Detiene el temporizador.
  void stopTimer() {
    _timer?.cancel();
    _isTimerActive = false;
    _endTime = DateTime.now();
    _saveToPreferences();
    _saveToDatabase(); // Guarda el estado final en la base de datos.
    notifyListeners();
  }

  // Reinicia el temporizador.
  void resetTimer() {
    _timer?.cancel();
    _secondselapsed = 0;
    _isTimerActive = false;
    _startTime = null;
    _endTime = null;
    _saveToPreferences();
    notifyListeners();
  }

  // Deshabilita el switch temporalmente.
void disableSwitchTemporarily() {
    _isTimerActive = false;
    notifyListeners();
     _switchEnabled = false;
  notifyListeners();
   // Inicia un temporizador que habilita el switch después de `resetTimeinSecond` segundos
  Timer(const Duration(seconds: _resetTimeinSeconds), () {
    _switchEnabled = true;
    notifyListeners(); // Notifica a la UI que el switch se ha habilitado nuevamente
    resetTimer(); // Reinicia el temporizador
  });
  }

  void disableButtonTemporarily(){
    _buttonEnabled.value = false; // Cambia el valor de _buttonEnabled
    _switchEnabled = false;
    notifyListeners(); // Notifica a los oyentes de cambios
    _firstDayTime = null;
    _firstEndTime = null;
    resetTimer();
    notifyListeners();
    Timer(const Duration(seconds: _resetTimeinSeconds), () {
    _buttonEnabled.value = true; // Rehabilita el botón
    _switchEnabled = true;
      notifyListeners(); // Notifica a los oyentes de cambios
  });
  }
  // Muestra un mensaje indicando que el tiempo de trabajo ha terminado.
  void _showWorckCompletemessage() {
    showWorkDayCompletedDialog?.call();
    _saveToDatabase(); // Guarda los datos cuando se completa el trabajo.
  }


  // Maneja el cambio de estado de un switch en la UI.
  void handleSwitchChange(bool value) {
    if (value) {
      startTimer();
    } else {
      stopTimer();
    }
  }

 void manualResetTimerEndWorckofDay() async{
  if (_firstDayTime == null ) {
    // Si alguna de las fechas es nula, no se guarda nada.
    print('No hay información de tiempo para guardar $_firstDayTime');
    return;
  }
_firstEndTime = DateTime.now();

 // Recupera `secondsElapsed` de SharedPreferences.
  final prefs = await SharedPreferences.getInstance();
  final savedSecondsElapsed = prefs.getInt('secondsElapsed') ?? 0;

  if (savedSecondsElapsed == 0) {
    print('No se encontró o es cero el valor de secondsElapsed en SharedPreferences.');
    return;
  }
  // Genera una nueva clave única para cada entrada de workDay.
  final newWorkDayRef = _driverRef.parent?.child('workdays').push();

  // Guarda la información de trabajo en la nueva entrada.
  newWorkDayRef?.set({
    'firstDayTime': _firstDayTime?.toIso8601String() ?? '',
    'firstEndTime': _firstEndTime?.toIso8601String() ?? '',
    'totalWorkDay': savedSecondsElapsed,
  }).then((_){
    print('Información de jornada laboral guardada exitosamente.');
    disableButtonTemporarily();
    
  }).catchError((error) {
    print('Error al guardar la información de jornada laboral: $error');
  });  
   
  }

  // Formatea el tiempo transcurrido en horas, minutos y segundos.
  String formatElapsedTime() {
    final int hours = secondsElapsed ~/ 3600;
    final int minutes = (secondsElapsed % 3600) ~/ 60;
    final int secondsRemaining = secondsElapsed % 60;
    return '${hours.toString().padLeft(2, '0')}h : ${minutes.toString().padLeft(2, '0')}m : ${secondsRemaining.toString().padLeft(2, '0')}s';
  }

  // Callback que se ejecuta para mostrar un diálogo cuando se completa la jornada laboral.
  VoidCallback? showWorkDayCompletedDialog;

  
// Muestra un diálogo de confirmación antes de finalizar la jornada laboral.
  Future<void> showConfirmationDialog(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmación'),
          content: Text('¿Estás seguro de que deseas finalizar el día laboral?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Aceptar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      manualResetTimerEndWorckofDay();
    }
  }

// metodos que obtienen el nombre del conductor

  void _loadDrivernName() async {
    _driverName = await getDriverName1();
    notifyListeners();
  }

  Future<String> getDriverName1() async {
  final User? user = FirebaseAuth.instance.currentUser;
  
  if (user != null) {
    // Usar DatabaseReference para obtener el nodo específico
    final DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child('drivers')
        .child(user.uid)
        .child('name');
    
    // Obtener el valor una sola vez
    final DatabaseEvent event = await ref.once();
    
    // Extraer el DataSnapshot del DatabaseEvent
    final DataSnapshot snapshot = event.snapshot;

    if (snapshot.exists && snapshot.value != null) {
      // Convertir el valor a String y asignarlo a _driverName
      _driverName = snapshot.value.toString();
    } else {
      // Si no se encuentra el nombre, asignar un valor por defecto
      _driverName = 'Conductor';
    }
print('Nombre del conductor obtenido: $_driverName');
    return _driverName; // Devolver el nombre obtenido
  } else {
    // Si el usuario no está autenticado, devolver el valor por defecto
    _driverName = 'Conductor';
    print('Usuario no autenticado. Nombre asignado por defecto: $_driverName');
    return _driverName;
  }
}


  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}