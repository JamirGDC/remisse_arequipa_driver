import 'package:flutter/material.dart';
import '../../../../domain/usecases/login_usercase.dart';

class LoginViewModel extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  bool isLoading = false;
  String? errorMessage;

  LoginViewModel(this.loginUseCase);

  Future<bool> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await loginUseCase.execute(email, password);
    result.fold(
          (failure) => errorMessage = failure.message,
          (_) => errorMessage = null,
    );

    isLoading = false;
    notifyListeners();

    return errorMessage == null;
  }

  String getErrorMessage(String firebaseError) {
    switch (firebaseError) {
      case 'user-not-found':
        return 'No se encontró una cuenta con este correo. Por favor, regístrate.';
      case 'wrong-password':
        return 'La contraseña es incorrecta. Inténtalo de nuevo.';
      case 'invalid-email':
        return 'El formato del correo es inválido. Verifica e inténtalo nuevamente.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada. Contacta al soporte.';
      default:
        return 'Ocurrió un error inesperado. Por favor, inténtalo más tarde.';
    }
  }

}
