import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:remisse_arequipa_driver/data/models/info_user_model.dart';

class UserRemoteDataSource {
  final FirebaseAuth firebaseAuth;

  UserRemoteDataSource(this.firebaseAuth);

  Future<InfoUserModel> getUserInfo() async {
    User? user = firebaseAuth.currentUser;

    if (user == null) {
      throw Exception('No hay un usuario autenticado.');
    }

    DatabaseReference driversRef = FirebaseDatabase.instance
        .ref()
        .child('drivers')
        .child(user.uid);

    DataSnapshot snapshot = await driversRef.get();

    if (!snapshot.exists) {
      throw Exception('No se encontraron datos del usuario en la tabla "drivers".');
    }

    return InfoUserModel(
      id: user.uid,
      name: snapshot.child('name').value as String? ?? 'Nombre no disponible',
      lastName: snapshot.child('lastName').value as String? ?? 'Apellido no disponible',
    );
  }
}
