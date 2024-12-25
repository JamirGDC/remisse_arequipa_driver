import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/auth_login_user_model.dart';


class AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth firebaseAuth;

  AuthRemoteDataSource(this.firebaseAuth);

  Future<AuthLoginUserModel> login(String email, String password) async {
    final userCredential = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return AuthLoginUserModel(
      id: userCredential.user!.uid,
      email: userCredential.user!.email!,
    );
  }
}
