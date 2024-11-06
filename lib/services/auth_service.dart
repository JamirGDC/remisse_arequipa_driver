import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  Future<UserModel?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        DatabaseReference usersRef = _database.ref().child("drivers").child(user.uid);
        var snapshot = await usersRef.once();
        if (snapshot.snapshot.value != null &&
            (snapshot.snapshot.value as Map)["blockStatus"] == "no") {
          return UserModel(uid: user.uid, email: user.email!);
        } else {
          _auth.signOut();
          throw Exception("Cuenta bloqueada. Contacta con el administrador.");
        }
      }
    } on FirebaseAuthException catch (e) {
      throw Exception("Error: ${e.message}");
    }
    return null;
  }

  Future<UserModel?>signUpUser(String email, String password, String name, String phone, String carModel, String carColor, String carPlate, String perfilPhoto) async {
    try
    {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
              email: email,
              password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        Map<String, dynamic> userDataMap = {
          "name": name,
          "email": email,
          "phone": phone,
          "photo": perfilPhoto,
          "id": user.uid,
          "blockStatus": "no",
          "car_details": {
            "carModel": carModel,
            "carColor": carColor,
            "carNumber": carPlate,
          },
        };

      
        DatabaseReference usersRef = _database.ref().child("drivers").child(user.uid);
        await usersRef.set(userDataMap);
        var snapshot = await usersRef.once();

        if (snapshot.snapshot.value != null &&
            (snapshot.snapshot.value as Map)["blockStatus"] == "no") {
          return UserModel(uid: user.uid, email: user.email!);
        } else {
          _auth.signOut();
          throw Exception("Cuenta bloqueada. Contacta con el administrador.");
        }
      }
    } on FirebaseAuthException catch (e) {
      throw Exception("Error: ${e.message}");
    }
    return null;




  }



}
