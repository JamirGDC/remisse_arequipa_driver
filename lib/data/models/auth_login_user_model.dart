import '../../domain/entities/user.dart';

class AuthLoginUserModel extends User {
  AuthLoginUserModel({required super.id, required String super.email});

  factory AuthLoginUserModel.fromJson(Map<String, dynamic> json) {
    return AuthLoginUserModel(id: json['id'], email: json['email']);
  }
}
